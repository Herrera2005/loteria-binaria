import {
  AccountStatus,
  CurrencyCode,
  LedgerAccountType,
  VendorProfileStatus,
  WalletStatus,
  type PrismaClient,
} from "../../../apps/api/src/generated/prisma/client";

import type { RoleCode } from "../catalogs/roles.seed";
import { BASELINE_SEED_DATE } from "../constants";
import { generateUuidV7 } from "../helpers/generate-uuid-v7";

type RoleRecord = {
  id: string;
};

interface DemoUserDefinition {
  publicId: string;
  email: string;
  username: string;
  roleCode: RoleCode;
}

const DEMO_USERS: readonly DemoUserDefinition[] = [
  {
    publicId: "DEMO-CLIENT-001",
    email: "cliente.demo@example.test",
    username: "cliente_demo",
    roleCode: "CLIENTE",
  },
  {
    publicId: "DEMO-CLIENT-002",
    email: "cliente2.demo@example.test",
    username: "cliente2_demo",
    roleCode: "CLIENTE",
  },
  {
    publicId: "DEMO-VENDOR-001",
    email: "vendedor.demo@example.test",
    username: "vendedor_demo",
    roleCode: "VENDEDOR",
  },
  {
    publicId: "DEMO-ADMIN-001",
    email: "admin.limitado@example.test",
    username: "admin_limitado",
    roleCode: "ADMINISTRADOR",
  },
];

function demoUsersAreEnabled(): boolean {
  return process.env.SEED_DEMO_USERS === "true";
}

function assertDemoEnvironment(): void {
  const environment = (
    process.env.APP_ENV ??
    process.env.NODE_ENV ??
    "development"
  ).toLowerCase();

  if (
    environment === "production" &&
    demoUsersAreEnabled()
  ) {
    throw new Error(
      "SEED_DEMO_USERS no puede habilitarse en producción.",
    );
  }
}

function getDemoPasswordHash(): string {
  const value =
    process.env.SEED_DEMO_PASSWORD_HASH;

  if (!value) {
    throw new Error(
      "SEED_DEMO_PASSWORD_HASH es obligatorio cuando SEED_DEMO_USERS=true.",
    );
  }

  if (!value.startsWith("$argon2id$")) {
    throw new Error(
      "SEED_DEMO_PASSWORD_HASH debe contener un hash Argon2id.",
    );
  }

  return value;
}

async function ensureUserRole(
  prisma: PrismaClient,
  userId: string,
  roleId: string,
): Promise<void> {
  const existing =
    await prisma.userRoles.findFirst({
      where: {
        user_id: userId,
        role_id: roleId,
        revoked_at: null,
        valid_until: null,
      },
    });

  if (existing) {
    return;
  }

  await prisma.userRoles.create({
    data: {
      id: generateUuidV7(),
      user_id: userId,
      role_id: roleId,
      assigned_by_user_id: null,
      valid_from: BASELINE_SEED_DATE,
      valid_until: null,
      revoked_at: null,
      reason:
        "Asignación inicial del seed demo.",
    },
  });
}

async function ensureWallet(
  prisma: PrismaClient,
  userId: string,
  currency: CurrencyCode,
) {
  return prisma.wallets.upsert({
    where: {
      user_id_currency: {
        user_id: userId,
        currency,
      },
    },

    create: {
      id: generateUuidV7(),
      user_id: userId,
      currency,
      status: WalletStatus.ACTIVE,
      closed_at: null,
    },

    update: {
      status: WalletStatus.ACTIVE,
      closed_at: null,
    },
  });
}

async function ensureUserLedgerAccount(
  prisma: PrismaClient,
  data: {
    accountCode: string;
    userId: string;
    walletId: string;
    currency: CurrencyCode;
    accountType: LedgerAccountType;
  },
): Promise<void> {
  const existing =
    await prisma.ledgerAccounts.findUnique({
      where: {
        account_code: data.accountCode,
      },
    });

  if (!existing) {
    await prisma.ledgerAccounts.create({
      data: {
        id: generateUuidV7(),
        account_code: data.accountCode,
        currency: data.currency,
        account_type: data.accountType,
        wallet_id: data.walletId,
        user_id: data.userId,
        draw_event_id: null,
        user_draw_id: null,
        allows_negative: false,
        is_active: true,
      },
    });

    return;
  }

  if (
    existing.user_id !== data.userId ||
    existing.wallet_id !== data.walletId ||
    existing.currency !== data.currency ||
    existing.account_type !== data.accountType ||
    existing.allows_negative
  ) {
    throw new Error(
      `La cuenta ${data.accountCode} existe con configuración incorrecta.`,
    );
  }
}

async function ensureUserFinancialStructure(
  prisma: PrismaClient,
  user: {
    id: string;
    public_id: string;
  },
): Promise<void> {
  const realWallet = await ensureWallet(
    prisma,
    user.id,
    CurrencyCode.REAL,
  );

  const virtualWallet = await ensureWallet(
    prisma,
    user.id,
    CurrencyCode.VIRTUAL,
  );

  await ensureUserLedgerAccount(prisma, {
    accountCode:
      `USER:${user.public_id}:REAL:AVAILABLE`,
    userId: user.id,
    walletId: realWallet.id,
    currency: CurrencyCode.REAL,
    accountType:
      LedgerAccountType.USER_REAL_AVAILABLE,
  });

  await ensureUserLedgerAccount(prisma, {
    accountCode:
      `USER:${user.public_id}:REAL:RESERVED_CONVERSION`,
    userId: user.id,
    walletId: realWallet.id,
    currency: CurrencyCode.REAL,
    accountType:
      LedgerAccountType.USER_REAL_RESERVED_CONVERSION,
  });

  await ensureUserLedgerAccount(prisma, {
    accountCode:
      `USER:${user.public_id}:REAL:IN_WITHDRAWAL`,
    userId: user.id,
    walletId: realWallet.id,
    currency: CurrencyCode.REAL,
    accountType:
      LedgerAccountType.USER_REAL_IN_WITHDRAWAL,
  });

  await ensureUserLedgerAccount(prisma, {
    accountCode:
      `USER:${user.public_id}:VIRTUAL:AVAILABLE`,
    userId: user.id,
    walletId: virtualWallet.id,
    currency: CurrencyCode.VIRTUAL,
    accountType:
      LedgerAccountType.USER_VIRTUAL_AVAILABLE,
  });
}

export async function seedDemoUsers(
  prisma: PrismaClient,
  roles: Map<RoleCode, RoleRecord>,
): Promise<void> {
  console.info("[seed:demo-users] Iniciando...");

  assertDemoEnvironment();

  if (!demoUsersAreEnabled()) {
    console.info(
      "[seed:demo-users] Omitido: SEED_DEMO_USERS no está habilitado.",
    );

    return;
  }

  const passwordHash =
    getDemoPasswordHash();

  const seededUsers = new Map<
    string,
    {
      id: string;
      public_id: string;
    }
  >();

  for (const definition of DEMO_USERS) {
    const role = roles.get(
      definition.roleCode,
    );

    if (!role) {
      throw new Error(
        `No se encontró el rol ${definition.roleCode}.`,
      );
    }

    const user = await prisma.users.upsert({
      where: {
        email: definition.email,
      },

      create: {
        id: generateUuidV7(),
        public_id: definition.publicId,
        email: definition.email,
        username: definition.username,
        password_hash: passwordHash,
        status: AccountStatus.ACTIVO,
        email_verified_at:
          BASELINE_SEED_DATE,
        phone_verified_at: null,
        deactivated_at: null,
      },

      update: {
        username: definition.username,
        password_hash: passwordHash,
        status: AccountStatus.ACTIVO,
        deactivated_at: null,
      },
    });

    await ensureUserRole(
      prisma,
      user.id,
      role.id,
    );

    await ensureUserFinancialStructure(
      prisma,
      user,
    );

    seededUsers.set(
      definition.email,
      user,
    );
  }

  const admin =
    seededUsers.get(
      "admin.limitado@example.test",
    );

  const vendor =
    seededUsers.get(
      "vendedor.demo@example.test",
    );

  if (!admin || !vendor) {
    throw new Error(
      "No se pudieron resolver el administrador y vendedor demo.",
    );
  }

  const vendorProfile =
    await prisma.vendorProfiles.findUnique({
      where: {
        user_id: vendor.id,
      },
    });

  if (!vendorProfile) {
    await prisma.vendorProfiles.create({
      data: {
        id: generateUuidV7(),
        user_id: vendor.id,
        status:
          VendorProfileStatus.ACTIVE,
        approved_by_user_id: admin.id,
        approved_at:
          BASELINE_SEED_DATE,
        suspended_at: null,
        suspension_reason: null,
      },
    });
  } else if (
    vendorProfile.status !==
      VendorProfileStatus.ACTIVE ||
    vendorProfile.approved_by_user_id !==
      admin.id
  ) {
    throw new Error(
      "El perfil del vendedor demo existe con una configuración diferente.",
    );
  }

  console.info(
    `[seed:demo-users] ${seededUsers.size} usuarios demo verificados.`,
  );
}
