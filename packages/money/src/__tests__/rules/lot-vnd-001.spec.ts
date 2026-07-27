/**
 * @rule LOT-VND-001
 * @test TST-VND-001 (componente matemático)
 * @tables vendor_purchase_orders, inventory_batches, ledger (suite API/PG posterior)
 * @level UNIT-MONEY
 */
import assert from 'node:assert/strict';
import test from 'node:test';

import {
  calculateVendorWholesalePurchase,
  money,
  MoneyDomainError,
} from '../../index.js';

test('[LOT-VND-001] conserva 0,90 REAL por 1,00 VIRTUAL', () => {
  const result = calculateVendorWholesalePurchase(
    money('VIRTUAL', 10_000n),
  );

  assert.equal(result.virtualAmount.minor, 10_000n);
  assert.equal(result.realCost.minor, 9_000n);
});

test('[LOT-VND-001] rechaza cero y valores no múltiplos de 100 minor units', () => {
  for (const invalid of [0n, 1n, 99n, 101n, 10_001n]) {
    assert.throws(
      () => calculateVendorWholesalePurchase(money('VIRTUAL', invalid)),
      (error: unknown) =>
        error instanceof MoneyDomainError &&
        error.code === 'INVALID_WHOLESALE_INCREMENT',
    );
  }
});
