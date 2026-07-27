/**
 * @rule LOT-PRZ-004
 * @test TST-PRZ-004
 * @tables event_financial_configs, guarantee_fund_reservations (suite API/PG posterior)
 * @level UNIT-MONEY
 */
import assert from 'node:assert/strict';
import test from 'node:test';

import {
  evaluateInitialPrizeCoverage,
  money,
  MONEY_POLICY_CODES,
  recommendInitialPrizeX5,
} from '../../index.js';

test('[LOT-PRZ-004] recomienda cinco veces el precio del boleto', () => {
  assert.equal(
    recommendInitialPrizeX5(money('VIRTUAL', 200n)).minor,
    1_000n,
  );
});

test('[LOT-PRZ-004] informa cobertura y faltante sin usar decimales', () => {
  const result = evaluateInitialPrizeCoverage({
    ticketPrice: money('VIRTUAL', 200n),
    configuredInitialPrize: money('VIRTUAL', 1_500n),
    availableGuarantee: money('VIRTUAL', 1_200n),
  });

  assert.equal(result.recommendedInitialPrize.minor, 1_000n);
  assert.equal(result.covered, false);
  assert.equal(result.shortfall.minor, 300n);
  assert.equal(result.policyCode, MONEY_POLICY_CODES.INITIAL_PRIZE_X5);
});
