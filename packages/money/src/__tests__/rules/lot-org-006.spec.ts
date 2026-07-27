/**
 * @rule LOT-ORG-006
 * @test TST-ORG-006 (componente matemático)
 * @tables user_draw_participations, escrow/commission ledger (suite PG posterior)
 * @level UNIT-MONEY
 */
import assert from 'node:assert/strict';
import test from 'node:test';

import { money, MONEY_POLICY_CODES, splitUserDraw95_5 } from '../../index.js';

test('[LOT-ORG-006] separa 95 % en escrow y 5 % en comisión retenida', () => {
  const result = splitUserDraw95_5(money('VIRTUAL', 10_000n));

  assert.equal(result.escrow.minor, 9_500n);
  assert.equal(result.retainedCommission.minor, 500n);
  assert.equal(
    result.escrow.minor + result.retainedCommission.minor,
    result.source.minor,
  );
  assert.equal(result.policyCode, MONEY_POLICY_CODES.USER_DRAW_95_5);
});
