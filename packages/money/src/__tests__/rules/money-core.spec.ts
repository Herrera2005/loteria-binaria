import assert from 'node:assert/strict';
import test from 'node:test';

import type { Money } from '../../index.js';
import {
  addMoney,
  compareMoney,
  money,
  MoneyDomainError,
  subtractMoney,
  zeroMoney,
} from '../../index.js';

test('money: suma, resta, comparación y cero conservan moneda', () => {
  const left = money('REAL', 300n);
  const right = money('REAL', 125n);

  assert.deepEqual(addMoney(left, right), { currency: 'REAL', minor: 425n });
  assert.deepEqual(subtractMoney(left, right), {
    currency: 'REAL',
    minor: 175n,
  });
  assert.equal(compareMoney(left, right), 1);
  assert.equal(compareMoney(right, left), -1);
  assert.equal(compareMoney(left, money('REAL', 300n)), 0);
  assert.deepEqual(zeroMoney('REAL'), { currency: 'REAL', minor: 0n });
});

test('money: rechaza mezcla de REAL y VIRTUAL en runtime', () => {
  assert.throws(
    () =>
      addMoney(
        money('REAL', 100n),
        money('VIRTUAL', 100n) as unknown as Money<'REAL'>,
      ),
    (error: unknown) =>
      error instanceof MoneyDomainError &&
      error.code === 'CURRENCY_MISMATCH',
  );
});
