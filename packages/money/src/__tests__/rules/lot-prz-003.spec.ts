/**
 * @rule LOT-PRZ-003
 * @test TST-PRZ-003
 * @tables event_financial_configs/projections (suite PG posterior)
 * @level UNIT-MONEY
 */
import assert from 'node:assert/strict';
import test from 'node:test';

import { composeMajorPrize, money } from '../../index.js';

test('[LOT-PRZ-003] compone premio inicial, crecimiento y acumulado', () => {
  const result = composeMajorPrize({
    guaranteedInitial: money('VIRTUAL', 10_000n),
    salesGrowth: money('VIRTUAL', 2_500n),
    extraordinaryAccumulation: money('VIRTUAL', 1_250n),
  });

  assert.equal(result.guaranteedInitial.minor, 10_000n);
  assert.equal(result.salesGrowth.minor, 2_500n);
  assert.equal(result.extraordinaryAccumulation.minor, 1_250n);
  assert.equal(result.total.minor, 13_750n);
});
