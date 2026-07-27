
import {
  Prisma,
  VersionStatus,
  type PrismaClient,
} from "../../../apps/api/src/generated/prisma/client";
import type { ProductCode } from "./products.seed";

import { createCanonicalHash } from "../helpers/canonical-hash";
import { generateUuidV7 } from "../helpers/generate-uuid-v7";

type ProductRecord = {
  id: string;
};

const BASELINE_PUBLISHED_AT =
  new Date("2026-07-26T00:00:00.000Z");

const RULE_DEFINITIONS = {
  OCTAL: {
    selectionCount: 4,
    universeSymbols: [
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
    ],
    totalCombinations: 70,
  },

  DECIMAL: {
    selectionCount: 5,
    universeSymbols: [
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
    ],
    totalCombinations: 252,
  },

  HEXADECIMAL: {
    selectionCount: 6,
    universeSymbols: [
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
    ],
    totalCombinations: 8008,
  },
} as const;

const PRIZE_RULE_DEFINITION = {
  initialPrizeMultiplierBps: 50_000,

  growthShareBps: 9_000,
  operationsShareBps: 1_000,

  noWinnerAccumulationBps: 5_000,
  noWinnerGuaranteeBps: 2_500,
  noWinnerFuturePrizeBps: 1_500,
  noWinnerOperationsBps: 1_000,

  roundingPolicy: {
    type: "QUARTER_DOLLAR_PUBLIC_ROUNDING",
    intervals: [
      {
        minimumCents: 0,
        maximumCents: 12,
        roundedCents: 0,
      },
      {
        minimumCents: 13,
        maximumCents: 37,
        roundedCents: 25,
      },
      {
        minimumCents: 38,
        maximumCents: 62,
        roundedCents: 50,
      },
      {
        minimumCents: 63,
        maximumCents: 87,
        roundedCents: 75,
      },
      {
        minimumCents: 88,
        maximumCents: 99,
        roundedCents: 100,
      },
    ],
  },

  allocationPolicyCode: "LARGEST_REMAINDER_V1",
} as const;

export async function seedRuleVersions(
  prisma: PrismaClient,
  products: Map<ProductCode, ProductRecord>,
) {
  console.info("[seed:rule-versions] Iniciando...");

  let mathematicalRules = 0;
  let prizeRules = 0;

  for (const [
    productCode,
    definition,
  ] of Object.entries(
    RULE_DEFINITIONS,
  ) as [
    ProductCode,
    (typeof RULE_DEFINITIONS)[ProductCode],
  ][]) {
    const product = products.get(productCode);

    if (!product) {
      throw new Error(
        `No se encontró el producto ${productCode}.`,
      );
    }

    const mathematicalPayload = {
      version: 1,
      status: VersionStatus.PUBLISHED,

      selection_count: definition.selectionCount,

      universe_symbols: [
        ...definition.universeSymbols,
      ] as Prisma.InputJsonValue,

      total_combinations: definition.totalCombinations,

      order_matters: false,
      unique_symbols_required: true,

      purchase_limit_bps: 2_000,
      limit_release_fraction_bps: 8_000,

      reservation_seconds: 300,
      close_before_draw_seconds: 600,

      published_at: BASELINE_PUBLISHED_AT,
    } satisfies Omit<
      Prisma.RuleVersionsUncheckedCreateInput,
      | "id"
      | "lottery_product_id"
      | "content_hash"
    >;

    const mathematicalHash =
      createCanonicalHash({
        ...mathematicalPayload,
        published_at:
          BASELINE_PUBLISHED_AT.toISOString(),
      });

    const existingRule =
      await prisma.ruleVersions.findUnique({
        where: {
          lottery_product_id_version: {
            lottery_product_id: product.id,
            version: 1,
          },
        },
      });

    let ruleVersionId: string;

    if (!existingRule) {
      const createdRule =
        await prisma.ruleVersions.create({
          data: {
            id: generateUuidV7(),
            lottery_product_id: product.id,
            ...mathematicalPayload,
            content_hash: mathematicalHash,
          },
        });

      ruleVersionId = createdRule.id;
    } else {
      if (
        existingRule.content_hash !==
        mathematicalHash
      ) {
        throw new Error(
          `La versión matemática 1 de ${productCode} existe con contenido diferente. Debe crearse una nueva versión.`,
        );
      }

      ruleVersionId = existingRule.id;
    }

    mathematicalRules++;

    const roundingPolicy =
      JSON.parse(
        JSON.stringify(
          PRIZE_RULE_DEFINITION.roundingPolicy,
        ),
      ) as Prisma.InputJsonValue;

    const prizePayload = {
      version: 1,
      status: VersionStatus.PUBLISHED,

      initial_prize_multiplier_bps:
        PRIZE_RULE_DEFINITION
          .initialPrizeMultiplierBps,

      growth_share_bps:
        PRIZE_RULE_DEFINITION
          .growthShareBps,

      operations_share_bps:
        PRIZE_RULE_DEFINITION
          .operationsShareBps,

      no_winner_accumulation_bps:
        PRIZE_RULE_DEFINITION
          .noWinnerAccumulationBps,

      no_winner_guarantee_bps:
        PRIZE_RULE_DEFINITION
          .noWinnerGuaranteeBps,

      no_winner_future_prize_bps:
        PRIZE_RULE_DEFINITION
          .noWinnerFuturePrizeBps,

      no_winner_operations_bps:
        PRIZE_RULE_DEFINITION
          .noWinnerOperationsBps,

      rounding_policy: roundingPolicy,

      allocation_policy_code:
        PRIZE_RULE_DEFINITION
          .allocationPolicyCode,

      published_at: BASELINE_PUBLISHED_AT,
    } satisfies Omit<
      Prisma.PrizeRuleVersionsUncheckedCreateInput,
      | "id"
      | "rule_version_id"
      | "content_hash"
    >;

    const prizeHash =
      createCanonicalHash({
        ...prizePayload,
        published_at:
          BASELINE_PUBLISHED_AT.toISOString(),
      });

    const existingPrizeRule =
      await prisma.prizeRuleVersions.findUnique({
        where: {
          rule_version_id_version: {
            rule_version_id: ruleVersionId,
            version: 1,
          },
        },
      });

    if (!existingPrizeRule) {
      await prisma.prizeRuleVersions.create({
        data: {
          id: generateUuidV7(),
          rule_version_id: ruleVersionId,
          ...prizePayload,
          content_hash: prizeHash,
        },
      });
    } else if (
      existingPrizeRule.content_hash !==
      prizeHash
    ) {
      throw new Error(
        `La versión económica 1 de ${productCode} existe con contenido diferente. Debe crearse una nueva versión.`,
      );
    }

    prizeRules++;
  }

  console.info(
    `[seed:rule-versions] ${mathematicalRules} versiones matemáticas verificadas.`,
  );

  console.info(
    `[seed:rule-versions] ${prizeRules} versiones económicas verificadas.`,
  );
}
