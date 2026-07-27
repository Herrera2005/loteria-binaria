/**
 * @rule LOT-PRZ-005
 * @test TST-PRZ-005
 * @tables event_financial_projections, fund_movements (suite PG posterior)
 * @level UNIT-MONEY
 */
import assert from 'node:assert/strict';
import test from 'node:test';

import {
  calculateOfficialPrizeGrowth,
  money,
  splitOfficialGrowth90_10,
} from '../../index.js';

test('[LOT-PRZ-005] distribuye excedente elegible 90/10', () => {
  const result = splitOfficialGrowth90_10(money('VIRTUAL', 10_000n));

  assert.equal(result.prize.minor, 9_000n);
  assert.equal(result.operations.minor, 1_000n);
});

test('[LOT-PRZ-005] el crecimiento nunca supera el techo financiado', () => {
  const result = calculateOfficialPrizeGrowth({
    eligibleExcess: money('VIRTUAL', 10_000n),
    currentGrowth: money('VIRTUAL', 4_000n),
    financedCeiling: money('VIRTUAL', 10_000n),
  });

  assert.equal(result.growthIncrement.minor, 6_000n);
  assert.equal(result.projectedGrowth.minor, 10_000n);
  assert.equal(result.operationsShare.minor, 1_000n);
  assert.equal(result.unappliedPrizeShare.minor, 3_000n);
  assert.equal(result.reachedCeiling, true);
});
