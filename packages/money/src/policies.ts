import { basisPoints } from './amount.js';
import { allocateBasisPoints } from './allocation.js';
import { MoneyDomainError } from './errors.js';
import {
  addMoney,
  compareMoney,
  money,
  multiplyMoneyByInteger,
  subtractMoney,
  zeroMoney,
} from './money.js';
import type { MinorAmount, Money } from './types.js';

export const MONEY_POLICY_CODES = Object.freeze({
  VIRTUAL_TO_REAL_90_10: 'LOT-FIN-009:v1',
  USER_DRAW_95_5: 'LOT-ORG-006:v1',
  OFFICIAL_GROWTH_90_10: 'LOT-PRZ-005:v1',
  NO_WINNER_50_25_15_10: 'LOT-PRZ-009:v1',
  PUBLIC_PRIZE_QUARTER_ROUNDING: 'LOT-PRZ-006:v1',
  INITIAL_PRIZE_X5: 'LOT-PRZ-004:v1',
  VENDOR_WHOLESALE_90_100: 'LOT-VND-001:v1',
} as const);

function findAmount<K extends string>(
  key: K,
  allocations: readonly {
    readonly key: K;
    readonly amount: MinorAmount;
  }[],
): MinorAmount {
  const allocation = allocations.find((candidate) => candidate.key === key);
  if (allocation === undefined) {
    throw new MoneyDomainError(
      'INVALID_ALLOCATION',
      `Asignación ausente: ${key}`,
    );
  }
  return allocation.amount;
}

export function convertVirtualToReal90_10(
  source: Money<'VIRTUAL'>,
): {
  readonly source: Money<'VIRTUAL'>;
  readonly net: Money<'REAL'>;
  readonly commission: Money<'VIRTUAL'>;
  readonly policyCode: typeof MONEY_POLICY_CODES.VIRTUAL_TO_REAL_90_10;
} {
  const allocations = allocateBasisPoints(source.minor, [
    { key: 'NET', basisPoints: basisPoints(9_000n), priority: 1 },
    {
      key: 'COMMISSION',
      basisPoints: basisPoints(1_000n),
      priority: 2,
    },
  ]);

  return Object.freeze({
    source,
    net: money('REAL', findAmount('NET', allocations)),
    commission: money('VIRTUAL', findAmount('COMMISSION', allocations)),
    policyCode: MONEY_POLICY_CODES.VIRTUAL_TO_REAL_90_10,
  });
}

export function splitUserDraw95_5(
  source: Money<'VIRTUAL'>,
): {
  readonly source: Money<'VIRTUAL'>;
  readonly escrow: Money<'VIRTUAL'>;
  readonly retainedCommission: Money<'VIRTUAL'>;
  readonly policyCode: typeof MONEY_POLICY_CODES.USER_DRAW_95_5;
} {
  const allocations = allocateBasisPoints(source.minor, [
    { key: 'ESCROW', basisPoints: basisPoints(9_500n), priority: 1 },
    {
      key: 'RETAINED_COMMISSION',
      basisPoints: basisPoints(500n),
      priority: 2,
    },
  ]);

  return Object.freeze({
    source,
    escrow: money('VIRTUAL', findAmount('ESCROW', allocations)),
    retainedCommission: money(
      'VIRTUAL',
      findAmount('RETAINED_COMMISSION', allocations),
    ),
    policyCode: MONEY_POLICY_CODES.USER_DRAW_95_5,
  });
}

export function splitOfficialGrowth90_10(
  source: Money<'VIRTUAL'>,
): {
  readonly source: Money<'VIRTUAL'>;
  readonly prize: Money<'VIRTUAL'>;
  readonly operations: Money<'VIRTUAL'>;
  readonly policyCode: typeof MONEY_POLICY_CODES.OFFICIAL_GROWTH_90_10;
} {
  const allocations = allocateBasisPoints(source.minor, [
    { key: 'PRIZE', basisPoints: basisPoints(9_000n), priority: 1 },
    {
      key: 'OPERATIONS',
      basisPoints: basisPoints(1_000n),
      priority: 2,
    },
  ]);

  return Object.freeze({
    source,
    prize: money('VIRTUAL', findAmount('PRIZE', allocations)),
    operations: money('VIRTUAL', findAmount('OPERATIONS', allocations)),
    policyCode: MONEY_POLICY_CODES.OFFICIAL_GROWTH_90_10,
  });
}

export function calculateOfficialPrizeGrowth(input: {
  readonly eligibleExcess: Money<'VIRTUAL'>;
  readonly currentGrowth: Money<'VIRTUAL'>;
  readonly financedCeiling: Money<'VIRTUAL'>;
}): {
  readonly projectedGrowth: Money<'VIRTUAL'>;
  readonly growthIncrement: Money<'VIRTUAL'>;
  readonly operationsShare: Money<'VIRTUAL'>;
  readonly unappliedPrizeShare: Money<'VIRTUAL'>;
  readonly reachedCeiling: boolean;
  readonly policyCode: typeof MONEY_POLICY_CODES.OFFICIAL_GROWTH_90_10;
} {
  if (compareMoney(input.currentGrowth, input.financedCeiling) === 1) {
    throw new MoneyDomainError(
      'INVALID_PRIZE_CONFIGURATION',
      'El crecimiento actual no puede superar el techo financiado.',
    );
  }

  const split = splitOfficialGrowth90_10(input.eligibleExcess);
  const remainingCapacity = subtractMoney(
    input.financedCeiling,
    input.currentGrowth,
  );
  const increment =
    compareMoney(split.prize, remainingCapacity) === 1
      ? remainingCapacity
      : split.prize;
  const projectedGrowth = addMoney(input.currentGrowth, increment);
  const unappliedPrizeShare = subtractMoney(split.prize, increment);

  return Object.freeze({
    projectedGrowth,
    growthIncrement: increment,
    operationsShare: split.operations,
    unappliedPrizeShare,
    reachedCeiling:
      compareMoney(projectedGrowth, input.financedCeiling) === 0,
    policyCode: MONEY_POLICY_CODES.OFFICIAL_GROWTH_90_10,
  });
}

export function splitNoWinner50_25_15_10(
  source: Money<'VIRTUAL'>,
): {
  readonly source: Money<'VIRTUAL'>;
  readonly accumulation: Money<'VIRTUAL'>;
  readonly guarantee: Money<'VIRTUAL'>;
  readonly futurePrizes: Money<'VIRTUAL'>;
  readonly operations: Money<'VIRTUAL'>;
  readonly policyCode: typeof MONEY_POLICY_CODES.NO_WINNER_50_25_15_10;
} {
  const allocations = allocateBasisPoints(source.minor, [
    {
      key: 'ACCUMULATION',
      basisPoints: basisPoints(5_000n),
      priority: 1,
    },
    {
      key: 'GUARANTEE',
      basisPoints: basisPoints(2_500n),
      priority: 2,
    },
    {
      key: 'FUTURE_PRIZES',
      basisPoints: basisPoints(1_500n),
      priority: 3,
    },
    {
      key: 'OPERATIONS',
      basisPoints: basisPoints(1_000n),
      priority: 4,
    },
  ]);

  return Object.freeze({
    source,
    accumulation: money('VIRTUAL', findAmount('ACCUMULATION', allocations)),
    guarantee: money('VIRTUAL', findAmount('GUARANTEE', allocations)),
    futurePrizes: money('VIRTUAL', findAmount('FUTURE_PRIZES', allocations)),
    operations: money('VIRTUAL', findAmount('OPERATIONS', allocations)),
    policyCode: MONEY_POLICY_CODES.NO_WINNER_50_25_15_10,
  });
}

export function composeMajorPrize(input: {
  readonly guaranteedInitial: Money<'VIRTUAL'>;
  readonly salesGrowth: Money<'VIRTUAL'>;
  readonly extraordinaryAccumulation: Money<'VIRTUAL'>;
}): {
  readonly total: Money<'VIRTUAL'>;
  readonly guaranteedInitial: Money<'VIRTUAL'>;
  readonly salesGrowth: Money<'VIRTUAL'>;
  readonly extraordinaryAccumulation: Money<'VIRTUAL'>;
} {
  return Object.freeze({
    ...input,
    total: addMoney(
      addMoney(input.guaranteedInitial, input.salesGrowth),
      input.extraordinaryAccumulation,
    ),
  });
}

export function recommendInitialPrizeX5(
  ticketPrice: Money<'VIRTUAL'>,
): Money<'VIRTUAL'> {
  return multiplyMoneyByInteger(ticketPrice, 5n);
}

export function evaluateInitialPrizeCoverage(input: {
  readonly ticketPrice: Money<'VIRTUAL'>;
  readonly configuredInitialPrize?: Money<'VIRTUAL'>;
  readonly availableGuarantee: Money<'VIRTUAL'>;
}): {
  readonly recommendedInitialPrize: Money<'VIRTUAL'>;
  readonly configuredInitialPrize: Money<'VIRTUAL'>;
  readonly covered: boolean;
  readonly shortfall: Money<'VIRTUAL'>;
  readonly policyCode: typeof MONEY_POLICY_CODES.INITIAL_PRIZE_X5;
} {
  const recommendedInitialPrize = recommendInitialPrizeX5(input.ticketPrice);
  const configuredInitialPrize =
    input.configuredInitialPrize ?? recommendedInitialPrize;
  const covered =
    compareMoney(input.availableGuarantee, configuredInitialPrize) >= 0;

  return Object.freeze({
    recommendedInitialPrize,
    configuredInitialPrize,
    covered,
    shortfall: covered
      ? zeroMoney('VIRTUAL')
      : subtractMoney(configuredInitialPrize, input.availableGuarantee),
    policyCode: MONEY_POLICY_CODES.INITIAL_PRIZE_X5,
  });
}
