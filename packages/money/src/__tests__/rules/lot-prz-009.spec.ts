/**
 * @rule LOT-PRZ-009
 * @test TST-PRZ-009
 * @tables accumulation_pools, guarantee/future funds, ledger (suite WORKER-PG posterior)
 * @level UNIT-MONEY
 */
import assert from 'node:assert/strict';
import test from 'node:test';

import {
  money,
  MONEY_POLICY_CODES,
  splitNoWinner50_25_15_10,
} from '../../index.js';

test('[LOT-PRZ-009] distribuye 50/25/15/10 y conserva el total', () => {
  const result = splitNoWinner50_25_15_10(
    money('VIRTUAL', 100_000n),
  );

  assert.equal(result.accumulation.minor, 50_000n);
  assert.equal(result.guarantee.minor, 25_000n);
  assert.equal(result.futurePrizes.minor, 15_000n);
  assert.equal(result.operations.minor, 10_000n);
  assert.equal(
    result.accumulation.minor +
      result.guarantee.minor +
      result.futurePrizes.minor +
      result.operations.minor,
    result.source.minor,
  );
  assert.equal(
    result.policyCode,
    MONEY_POLICY_CODES.NO_WINNER_50_25_15_10,
  );
});
