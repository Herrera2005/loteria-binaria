import "dotenv/config";

import {
  CurrencyCode,
  LedgerAccountType,
} from "../../apps/api/src/generated/prisma/client";

import { prisma } from "./client";

const EXPECTED_ROLE_CODES = [
  "CLIENTE",
  "VENDEDOR",
  "ADMINISTRADOR",
] as const;

const EXPECTED_PRODUCT_CODES = [
  "OCTAL",
  "DECIMAL",
  "HEXADECIMAL",
] as const;

const EXPECTED_PLATFORM_ACCOUNT_CODES = [
  "SIMULATED_TOPUP_SOURCE_REAL",
  "SIMULATED_PAYOUT_CLEARING_REAL",
  "PLATFORM_REAL_CASH",
  "PLATFORM_VIRTUAL_ISSUANCE",
  "PLATFORM_VIRTUAL_REDEMPTION",
  "GENERAL_CONVERSION_WALLET",
  "CONVERSION_FEES_VIRTUAL",
  "PLATFORM_OPERATIONS_VIRTUAL",
  "ROUNDING_ADJUSTMENTS_VIRTUAL",
  "GUARANTEE_FUND_AVAILABLE",
  "FUTURE_PRIZE_FUND",
  "ACCUMULATION_POOL_OCTAL",
  "ACCUMULATION_POOL_DECIMAL",
  "ACCUMULATION_POOL_HEXADECIMAL",
] as const;

const EXPECTED_SETTING_KEYS = [
  "draw.reveal_seconds_per_symbol",
  "draw.animation_skippable",
  "conversion.platform_fallback_enabled",
  "conversion.platform_fallback_seconds",
  "purchase.maximum_cart_items",
  "security.demo_users_enabled",
  "notifications.email_enabled",
  "storage.object_service_enabled",
] as const;

const EXPECTED_LEGAL_DOCUMENTS = [
  {
    documentType: "TERMS_AND_CONDITIONS",
    version: "1.0.0",
  },
  {
    documentType: "PRIVACY_POLICY",
    version: "1.0.0",
  },
] as const;

const EXPECTED_DEMO_EMAILS = [
  "cliente.demo@example.test",
  "cliente2.demo@example.test",
  "vendedor.demo@example.test",
  "admin.limitado@example.test",
] as const;

function assertCondition(
  condition: unknown,
  message: string,
): asserts condition {
  if (!condition) {
    throw new Error(`[verify] ${message}`);
  }
}

function demoUsersAreEnabled(): boolean {
  return process.env.SEED_DEMO_USERS === "true";
}

async function verifyRoles(): Promise<void> {
  const roles = await prisma.roles.findMany({
    where: {
      code: {
        in: [...EXPECTED_ROLE_CODES],
      },
    },
  });

  assertCondition(
    roles.length === EXPECTED_ROLE_CODES.length,
    `Se esperaban ${EXPECTED_ROLE_CODES.length} roles base y se encontraron ${roles.length}.`,
  );

  for (const role of roles) {
    assertCondition(
      role.is_system,
      `El rol ${role.code} debe tener is_system=true.`,
    );

    assertCondition(
      role.is_active,
      `El rol ${role.code} debe estar activo.`,
    );
  }

  console.info("[verify] Roles base correctos.");
}

async function verifyPermissions(): Promise<void> {
  const permissionCount =
    await prisma.permissions.count({
      where: {
        is_active: true,
      },
    });

  assertCondition(
    permissionCount === 133,
    `Se esperaban 133 permisos activos y se encontraron ${permissionCount}.`,
  );

  const duplicatePermissions =
    await prisma.$queryRaw<
      Array<{
        permission_key: string;
        total: bigint;
      }>
    >`
      SELECT permission_key, COUNT(*) AS total
      FROM permissions
      GROUP BY permission_key
      HAVING COUNT(*) > 1
    `;

  assertCondition(
    duplicatePermissions.length === 0,
    "Existen permission_key duplicados.",
  );

  console.info("[verify] 133 permisos correctos.");
}

async function verifyRolePermissions(): Promise<void> {
  const relations =
    await prisma.rolePermissions.count();

  assertCondition(
    relations === 148,
    `Se esperaban 148 relaciones role_permissions y se encontraron ${relations}.`,
  );

  const byRole = await prisma.roles.findMany({
    where: {
      code: {
        in: [...EXPECTED_ROLE_CODES],
      },
    },

    select: {
      code: true,

      _count: {
        select: {
          rev_role_permissions_role_id: true,
        },
      },
    },
  });

  const expectedByRole: Record<string, number> = {
    CLIENTE: 54,
    VENDEDOR: 47,
    ADMINISTRADOR: 47,
  };

  for (const role of byRole) {
    const actual =
      role._count.rev_role_permissions_role_id;

    assertCondition(
      actual === expectedByRole[role.code],
      `El rol ${role.code} debería tener ${expectedByRole[role.code]} permisos y tiene ${actual}.`,
    );
  }

  console.info(
    "[verify] Relaciones role_permissions correctas.",
  );
}

async function verifyProductsAndRules(): Promise<void> {
  const products =
    await prisma.lotteryProducts.findMany({
      where: {
        code: {
          in: [...EXPECTED_PRODUCT_CODES],
        },
      },

      include: {
        rev_rule_versions_lottery_product_id: {
          include: {
            rev_prize_rule_versions_rule_version_id:
              true,
          },
        },
      },
    });

  assertCondition(
    products.length === 3,
    `Se esperaban 3 productos y se encontraron ${products.length}.`,
  );

  const expectedCombinations: Record<
    string,
    number
  > = {
    OCTAL: 70,
    DECIMAL: 252,
    HEXADECIMAL: 8008,
  };

  for (const product of products) {
    const versionOne =
      product.rev_rule_versions_lottery_product_id.find(
        (rule) => rule.version === 1,
      );

    assertCondition(
      versionOne,
      `Falta RuleVersion 1 para ${product.code}.`,
    );

    assertCondition(
      versionOne.total_combinations ===
        expectedCombinations[product.code],
      `${product.code} tiene total_combinations incorrecto.`,
    );

    assertCondition(
      versionOne.content_hash.length === 64,
      `${product.code} tiene un hash matemático inválido.`,
    );

    const prizeVersion =
      versionOne.rev_prize_rule_versions_rule_version_id.find(
        (rule) => rule.version === 1,
      );

    assertCondition(
      prizeVersion,
      `Falta PrizeRuleVersion 1 para ${product.code}.`,
    );

    assertCondition(
      prizeVersion.content_hash.length === 64,
      `${product.code} tiene un hash económico inválido.`,
    );
  }

  console.info(
    "[verify] Productos y versiones correctos.",
  );
}

async function verifyPlatformAccounts(): Promise<void> {
  const accounts =
    await prisma.ledgerAccounts.findMany({
      where: {
        account_code: {
          in: [...EXPECTED_PLATFORM_ACCOUNT_CODES],
        },
      },
    });

  assertCondition(
    accounts.length ===
      EXPECTED_PLATFORM_ACCOUNT_CODES.length,
    `Se esperaban 14 cuentas técnicas y se encontraron ${accounts.length}.`,
  );

  for (const account of accounts) {
    assertCondition(
      account.wallet_id === null &&
        account.user_id === null &&
        account.draw_event_id === null &&
        account.user_draw_id === null,
      `La cuenta técnica ${account.account_code} no debe tener propietario.`,
    );

    assertCondition(
      account.is_active,
      `La cuenta técnica ${account.account_code} está inactiva.`,
    );

    const shouldAllowNegative =
      account.account_code ===
        "SIMULATED_TOPUP_SOURCE_REAL" ||
      account.account_code ===
        "PLATFORM_VIRTUAL_ISSUANCE";

    assertCondition(
      account.allows_negative ===
        shouldAllowNegative,
      `allows_negative incorrecto en ${account.account_code}.`,
    );
  }

  console.info(
    "[verify] Cuentas técnicas correctas.",
  );
}

async function verifyFunds(): Promise<void> {
  const guaranteeFund =
    await prisma.guaranteeFund.findUnique({
      where: {
        code: "GENERAL_GUARANTEE_FUND",
      },
    });

  assertCondition(
    guaranteeFund,
    "Falta GENERAL_GUARANTEE_FUND.",
  );

  assertCondition(
    guaranteeFund.currency ===
      CurrencyCode.VIRTUAL,
    "El fondo de garantía debe usar moneda VIRTUAL.",
  );

  const futurePrizeFund =
    await prisma.futurePrizeFund.findUnique({
      where: {
        code: "GENERAL_FUTURE_PRIZE_FUND",
      },
    });

  assertCondition(
    futurePrizeFund,
    "Falta GENERAL_FUTURE_PRIZE_FUND.",
  );

  const pools =
    await prisma.accumulationPools.count({
      where: {
        is_active: true,
      },
    });

  assertCondition(
    pools === 3,
    `Se esperaban 3 pools activos y se encontraron ${pools}.`,
  );

  console.info("[verify] Fondos y pools correctos.");
}

async function verifyLegalVersions(): Promise<void> {
  for (
    const definition
    of EXPECTED_LEGAL_DOCUMENTS
  ) {
    const document =
      await prisma.termsVersions.findUnique({
        where: {
          document_type_version: {
            document_type:
              definition.documentType,
            version: definition.version,
          },
        },
      });

    assertCondition(
      document,
      `Falta ${definition.documentType} ${definition.version}.`,
    );

    assertCondition(
      document.content_hash.length === 64,
      `${definition.documentType} tiene hash inválido.`,
    );

    assertCondition(
      document.retired_at === null,
      `${definition.documentType} está retirado.`,
    );
  }

  console.info(
    "[verify] Versiones legales correctas.",
  );
}

async function verifySystemSettings(): Promise<void> {
  const settings =
    await prisma.systemSettings.findMany({
      where: {
        setting_key: {
          in: [...EXPECTED_SETTING_KEYS],
        },
      },
    });

  assertCondition(
    settings.length ===
      EXPECTED_SETTING_KEYS.length,
    `Se esperaban 8 configuraciones y se encontraron ${settings.length}.`,
  );

  console.info(
    "[verify] Configuraciones operativas correctas.",
  );
}

async function verifyDemoUsers(): Promise<void> {
  const demoUsers =
    await prisma.users.findMany({
      where: {
        email: {
          in: [...EXPECTED_DEMO_EMAILS],
        },
      },

      include: {
        rev_wallets_user_id: true,
        rev_user_roles_user_id: true,
      },
    });

  if (!demoUsersAreEnabled()) {
    assertCondition(
      demoUsers.length === 0,
      "Existen usuarios demo aunque SEED_DEMO_USERS=false.",
    );

    console.info(
      "[verify] Usuarios demo correctamente ausentes.",
    );

    return;
  }

  assertCondition(
    demoUsers.length === 4,
    `Se esperaban 4 usuarios demo y se encontraron ${demoUsers.length}.`,
  );

  for (const user of demoUsers) {
    assertCondition(
      user.password_hash.startsWith("$argon2id$"),
      `${user.email} no tiene hash Argon2id.`,
    );

    assertCondition(
      user.rev_wallets_user_id.length === 2,
      `${user.email} debe tener dos wallets.`,
    );

    assertCondition(
      user.rev_user_roles_user_id.some(
        (assignment) =>
          assignment.revoked_at === null,
      ),
      `${user.email} no tiene un rol activo.`,
    );
  }

  const vendor =
    demoUsers.find(
      (user) =>
        user.email ===
        "vendedor.demo@example.test",
    );

  assertCondition(
    vendor,
    "No se encontró el vendedor demo.",
  );

  const vendorProfile =
    await prisma.vendorProfiles.findUnique({
      where: {
        user_id: vendor.id,
      },
    });

  assertCondition(
    vendorProfile,
    "El vendedor demo no tiene perfil.",
  );

  console.info("[verify] Usuarios demo correctos.");
}

async function verifyNoSeededMoney(): Promise<void> {
  if (
    process.env.VERIFY_FRESH_DATABASE !==
    "true"
  ) {
    console.info(
      "[verify] Comprobación de dinero omitida: la base no fue declarada como nueva.",
    );

    return;
  }

  const transactionCount =
    await prisma.ledgerTransactions.count();

  const entryCount =
    await prisma.ledgerEntries.count();

  assertCondition(
    transactionCount === 0,
    `La base nueva contiene ${transactionCount} transacciones contables.`,
  );

  assertCondition(
    entryCount === 0,
    `La base nueva contiene ${entryCount} asientos contables.`,
  );

  console.info(
    "[verify] La base nueva no contiene dinero ni movimientos.",
  );
}

async function main(): Promise<void> {
  console.info("[verify] Iniciando verificación...");

  await verifyRoles();
  await verifyPermissions();
  await verifyRolePermissions();
  await verifyProductsAndRules();
  await verifyPlatformAccounts();
  await verifyFunds();
  await verifyLegalVersions();
  await verifySystemSettings();
  await verifyDemoUsers();
  await verifyNoSeededMoney();

  console.info(
    "[verify] Fase 3 verificada correctamente.",
  );
}

main()
  .catch((error: unknown) => {
    console.error("[verify] Error:", error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
