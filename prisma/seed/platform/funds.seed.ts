import {
  CurrencyCode,
  type PrismaClient,
} from "../../../apps/api/src/generated/prisma/client";

import type {
  ProductCode,
} from "../catalogs/products.seed";

import type {
  PlatformLedgerAccountCode,
  PlatformLedgerAccountRecord,
} from "./ledger-accounts.seed";

import { generateUuidV7 } from "../helpers/generate-uuid-v7";

type ProductRecord = {
  id: string;
};

const GUARANTEE_FUND_CODE =
  "GENERAL_GUARANTEE_FUND";

const FUTURE_PRIZE_FUND_CODE =
  "GENERAL_FUTURE_PRIZE_FUND";

/**
 * La Fase 3 crea la estructura del fondo, no dinero.
 *
 * El saldo real se obtiene de LedgerEntries.
 * Este campo representa el umbral operativo mínimo
 * configurado para el fondo.
 *
 * Se inicia en cero hasta que se apruebe un umbral
 * económico diferente.
 */
const GUARANTEE_BASE_EMERGENCY_MINOR = 0n;

function getRequiredAccount(
  accounts: Map<
    PlatformLedgerAccountCode,
    PlatformLedgerAccountRecord
  >,
  accountCode: PlatformLedgerAccountCode,
): PlatformLedgerAccountRecord {
  const account = accounts.get(accountCode);

  if (!account) {
    throw new Error(
      `No se encontró la cuenta técnica ${accountCode}.`,
    );
  }

  return account;
}

export async function seedFunds(
  prisma: PrismaClient,
  products: Map<ProductCode, ProductRecord>,
  accounts: Map<
    PlatformLedgerAccountCode,
    PlatformLedgerAccountRecord
  >,
): Promise<void> {
  console.info("[seed:funds] Iniciando...");

  const guaranteeAccount =
    getRequiredAccount(
      accounts,
      "GUARANTEE_FUND_AVAILABLE",
    );

  const futurePrizeAccount =
    getRequiredAccount(
      accounts,
      "FUTURE_PRIZE_FUND",
    );

  const existingGuaranteeFund =
    await prisma.guaranteeFund.findUnique({
      where: {
        code: GUARANTEE_FUND_CODE,
      },
    });

  if (!existingGuaranteeFund) {
    await prisma.guaranteeFund.create({
      data: {
        id: generateUuidV7(),
        code: GUARANTEE_FUND_CODE,
        currency: CurrencyCode.VIRTUAL,
        ledger_account_id: guaranteeAccount.id,
        base_emergency_minor:
          GUARANTEE_BASE_EMERGENCY_MINOR,
        is_active: true,
      },
    });
  } else {
    if (
      existingGuaranteeFund.currency !==
      CurrencyCode.VIRTUAL
    ) {
      throw new Error(
        `${GUARANTEE_FUND_CODE} tiene moneda incorrecta.`,
      );
    }

    if (
      existingGuaranteeFund.ledger_account_id !==
      guaranteeAccount.id
    ) {
      throw new Error(
        `${GUARANTEE_FUND_CODE} está asociado a una cuenta incorrecta.`,
      );
    }

    if (
      existingGuaranteeFund.base_emergency_minor !==
      GUARANTEE_BASE_EMERGENCY_MINOR
    ) {
      throw new Error(
        `${GUARANTEE_FUND_CODE} tiene un umbral diferente al definido por el seed.`,
      );
    }

    if (!existingGuaranteeFund.is_active) {
      throw new Error(
        `${GUARANTEE_FUND_CODE} está inactivo. No se reactiva automáticamente.`,
      );
    }
  }

  const existingFuturePrizeFund =
    await prisma.futurePrizeFund.findUnique({
      where: {
        code: FUTURE_PRIZE_FUND_CODE,
      },
    });

  if (!existingFuturePrizeFund) {
    await prisma.futurePrizeFund.create({
      data: {
        id: generateUuidV7(),
        code: FUTURE_PRIZE_FUND_CODE,
        ledger_account_id:
          futurePrizeAccount.id,
        is_active: true,
      },
    });
  } else {
    if (
      existingFuturePrizeFund.ledger_account_id !==
      futurePrizeAccount.id
    ) {
      throw new Error(
        `${FUTURE_PRIZE_FUND_CODE} está asociado a una cuenta contable incorrecta.`,
      );
    }

    if (!existingFuturePrizeFund.is_active) {
      throw new Error(
        `${FUTURE_PRIZE_FUND_CODE} está inactivo. No se reactiva automáticamente.`,
      );
    }
  }

  let poolCount = 0;

  for (
    const [productCode, product]
    of products
  ) {
    const accountCode =
      `ACCUMULATION_POOL_${productCode}` as const;

    const poolAccount =
      getRequiredAccount(
        accounts,
        accountCode,
      );

    const existingPool =
      await prisma.accumulationPools.findUnique({
        where: {
          lottery_product_id: product.id,
        },
      });

    if (!existingPool) {
      await prisma.accumulationPools.create({
        data: {
          id: generateUuidV7(),
          lottery_product_id: product.id,
          ledger_account_id:
            poolAccount.id,
          is_active: true,
        },
      });
    } else {
      if (
        existingPool.ledger_account_id !==
        poolAccount.id
      ) {
        throw new Error(
          `El pool de ${productCode} está asociado a una cuenta incorrecta.`,
        );
      }

      if (!existingPool.is_active) {
        throw new Error(
          `El pool de ${productCode} está inactivo. No se reactiva automáticamente.`,
        );
      }
    }

    poolCount++;
  }

  console.info(
    "[seed:funds] Fondo de garantía verificado.",
  );

  console.info(
    "[seed:funds] Fondo de premios futuros verificado.",
  );

  console.info(
    `[seed:funds] ${poolCount} pools por producto verificados.`,
  );
}
