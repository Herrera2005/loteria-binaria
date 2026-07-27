/**
 * @rule LOT-FIN-009
 * @test TST-FIN-009
 * @tables virtual_to_real_conversions, ledger (suite PG posterior)
 * @level UNIT-MONEY
 */
import assert from 'node:assert/strict';
import test from 'node:test';

import {
  convertVirtualToReal90_10,
  money,
  MONEY_POLICY_CODES,
} from '../../index.js';

test('[LOT-FIN-009] 500,00 VIRTUAL produce 450,00 REAL y 50,00 de comisión', () => {
  const result = convertVirtualToReal90_10(money('VIRTUAL', 50_000n));

  assert.equal(result.source.minor, 50_000n);
  assert.equal(result.net.currency, 'REAL');
  assert.equal(result.net.minor, 45_000n);
  assert.equal(result.commission.currency, 'VIRTUAL');
  assert.equal(result.commission.minor, 5_000n);
  assert.equal(result.net.minor + result.commission.minor, result.source.minor);
  assert.equal(
    result.policyCode,
    MONEY_POLICY_CODES.VIRTUAL_TO_REAL_90_10,
  );
});

test('[LOT-FIN-009] una minor unit prioriza el neto del usuario', () => {
  const result = convertVirtualToReal90_10(money('VIRTUAL', 1n));

  assert.equal(result.net.minor, 1n);
  assert.equal(result.commission.minor, 0n);
});
