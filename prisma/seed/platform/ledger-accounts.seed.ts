import {
  CurrencyCode,
  LedgerAccountType,
  type PrismaClient,
} from "../../../apps/api/src/generated/prisma/client";

import type { ProductCode } from "../catalogs/products.seed";
import { generateUuidV7 } from "../helpers/generate-uuid-v7";

type ProductRecord = {
  id: string;
};

interface LedgerAccountDefinition {
  accountCode: string;
  currency: CurrencyCode;
  accountType: LedgerAccountType;
  allowsNegative: boolean;
}

const GLOBAL_ACCOUNT_DEFINITIONS: readonly LedgerAccountDefinition[] = [
  {
    accountCode: "SIMULATED_TOPUP_SOURCE_REAL",
    currency: CurrencyCode.REAL,
    accountType:
      LedgerAccountType.SIMULATED_TOPUP_SOURCE_REAL,
    allowsNegative: true,
  },
  {
    accountCode: "SIMULATED_PAYOUT_CLEARING_REAL",
    currency: CurrencyCode.REAL,
    accountType:
      LedgerAccountType.SIMULATED_PAYOUT_CLEARING_REAL,
    allowsNegative: false,
  },
  {
    accountCode: "PLATFORM_REAL_CASH",
    currency: CurrencyCode.REAL,
    accountType:
      LedgerAccountType.PLATFORM_REAL_CASH,
    allowsNegative: false,
  },
  {
    accountCode: "PLATFORM_VIRTUAL_ISSUANCE",
    currency: CurrencyCode.VIRTUAL,
    accountType:
      LedgerAccountType.PLATFORM_VIRTUAL_ISSUANCE,
    allowsNegative: true,
  },
  {
    accountCode: "PLATFORM_VIRTUAL_REDEMPTION",
    currency: CurrencyCode.VIRTUAL,
    accountType:
      LedgerAccountType.PLATFORM_VIRTUAL_REDEMPTION,
    allowsNegative: false,
  },
  {
    accountCode: "GENERAL_CONVERSION_WALLET",
    currency: CurrencyCode.VIRTUAL,
    accountType:
      LedgerAccountType.GENERAL_CONVERSION_WALLET,
    allowsNegative: false,
  },
  {
    accountCode: "CONVERSION_FEES_VIRTUAL",
    currency: CurrencyCode.VIRTUAL,
    accountType:
      LedgerAccountType.CONVERSION_FEES_VIRTUAL,
    allowsNegative: false,
  },
  {
    accountCode: "PLATFORM_OPERATIONS_VIRTUAL",
    currency: CurrencyCode.VIRTUAL,
    accountType:
      LedgerAccountType.PLATFORM_OPERATIONS_VIRTUAL,
    allowsNegative: false,
  },
  {
    accountCode: "ROUNDING_ADJUSTMENTS_VIRTUAL",
    currency: CurrencyCode.VIRTUAL,
    accountType:
      LedgerAccountType.ROUNDING_ADJUSTMENTS_VIRTUAL,
    allowsNegative: false,
  },
  {
    accountCode: "GUARANTEE_FUND_AVAILABLE",
    currency: CurrencyCode.VIRTUAL,
    accountType:
      LedgerAccountType.GUARANTEE_FUND_AVAILABLE,
    allowsNegative: false,
  },
  {
    accountCode: "FUTURE_PRIZE_FUND",
    currency: CurrencyCode.VIRTUAL,
    accountType:
      LedgerAccountType.FUTURE_PRIZE_FUND,
    allowsNegative: false,
  },
] as const;

export type PlatformLedgerAccountCode =
  | (typeof GLOBAL_ACCOUNT_DEFINITIONS)[number]["accountCode"]
  | `ACCUMULATION_POOL_${ProductCode}`;

export type PlatformLedgerAccountRecord = {
  id: string;
  account_code: string;
  currency: CurrencyCode;
  account_type: LedgerAccountType;
  allows_negative: boolean;
};

function assertExistingAccountMatches(
  existing: PlatformLedgerAccountRecord,
  definition: LedgerAccountDefinition,
): void {
  if (existing.currency !== definition.currency) {
    throw new Error(
      `La cuenta ${definition.accountCode} existe con moneda incorrecta: ${existing.currency}.`,
    );
  }

  if (existing.account_type !== definition.accountType) {
    throw new Error(
      `La cuenta ${definition.accountCode} existe con tipo incorrecto: ${existing.account_type}.`,
    );
  }

  if (
    existing.allows_negative !==
    definition.allowsNegative
  ) {
    throw new Error(
      `La cuenta ${definition.accountCode} tiene allows_negative incorrecto.`,
    );
  }
}

async function ensureLedgerAccount(
  prisma: PrismaClient,
  definition: LedgerAccountDefinition,
): Promise<PlatformLedgerAccountRecord> {
  const existing =
    await prisma.ledgerAccounts.findUnique({
      where: {
        account_code: definition.accountCode,
      },
    });

  if (existing) {
    if (
      existing.wallet_id !== null ||
      existing.user_id !== null ||
      existing.draw_event_id !== null ||
      existing.user_draw_id !== null
    ) {
      throw new Error(
        `La cuenta global ${definition.accountCode} no debe tener propietario.`,
      );
    }

    assertExistingAccountMatches(
      existing,
      definition,
    );

    if (!existing.is_active) {
      throw new Error(
        `La cuenta global ${definition.accountCode} está inactiva. No se reactiva automáticamente.`,
      );
    }

    return existing;
  }

  return prisma.ledgerAccounts.create({
    data: {
      id: generateUuidV7(),
      account_code: definition.accountCode,
      currency: definition.currency,
      account_type: definition.accountType,

      wallet_id: null,
      user_id: null,
      draw_event_id: null,
      user_draw_id: null,

      allows_negative:
        definition.allowsNegative,
      is_active: true,
    },
  });
}

export async function seedLedgerAccounts(
  prisma: PrismaClient,
  products: Map<ProductCode, ProductRecord>,
) {
  console.info(
    "[seed:ledger-accounts] Iniciando...",
  );

  const accounts = new Map<
    PlatformLedgerAccountCode,
    PlatformLedgerAccountRecord
  >();

  for (
    const definition
    of GLOBAL_ACCOUNT_DEFINITIONS
  ) {
    const account = await ensureLedgerAccount(
      prisma,
      definition,
    );

    accounts.set(
      definition.accountCode,
      account,
    );
  }

  for (
    const productCode
    of products.keys()
  ) {
    const accountCode =
      `ACCUMULATION_POOL_${productCode}` as const;

    const account = await ensureLedgerAccount(
      prisma,
      {
        accountCode,
        currency: CurrencyCode.VIRTUAL,
        accountType:
          LedgerAccountType.ACCUMULATION_POOL_PRODUCT,
        allowsNegative: false,
      },
    );

    accounts.set(accountCode, account);
  }

  console.info(
    `[seed:ledger-accounts] ${accounts.size} cuentas técnicas verificadas.`,
  );

  return accounts;
}
