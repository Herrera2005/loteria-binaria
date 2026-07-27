/**
 * @rule LOT-GOV-006
 * @test TST-GOV-006
 * @tables BIGINT *_minor (comprobación de esquema en suite PG posterior)
 * @level UNIT-PROPERTY
 */
import assert from 'node:assert/strict';
import test from 'node:test';

import {
  addMoney,
  money,
  MoneyDomainError,
  POSTGRES_BIGINT_MAX,
  subtractMoney,
} from '../../index.js';

test('[LOT-GOV-006] conserva precisión exacta en operaciones repetidas', () => {
  let balance = money('VIRTUAL', 0n);

  for (let index = 0; index < 100_000; index += 1) {
    balance = addMoney(balance, money('VIRTUAL', 1n));
  }

  assert.equal(balance.minor, 100_000n);

  for (let index = 0; index < 100_000; index += 1) {
    balance = subtractMoney(balance, money('VIRTUAL', 1n));
  }

  assert.equal(balance.minor, 0n);
});

test('[LOT-GOV-006] rechaza number incluso ante llamada no tipada', () => {
  assert.throws(
    () => money('REAL', 100 as unknown as bigint),
    (error: unknown) =>
      error instanceof MoneyDomainError &&
      error.code === 'INVALID_MINOR_AMOUNT',
  );
});

test('[LOT-GOV-006] rechaza montos negativos y overflow BIGINT', () => {
  assert.throws(
    () => money('REAL', -1n),
    (error: unknown) =>
      error instanceof MoneyDomainError &&
      error.code === 'INVALID_MINOR_AMOUNT',
  );

  assert.throws(
    () => money('REAL', POSTGRES_BIGINT_MAX + 1n),
    (error: unknown) =>
      error instanceof MoneyDomainError && error.code === 'MONEY_OVERFLOW',
  );
});

test('[LOT-GOV-006] la suma detecta overflow y la resta evita negativos', () => {
  assert.throws(
    () =>
      addMoney(
        money('REAL', POSTGRES_BIGINT_MAX),
        money('REAL', 1n),
      ),
    (error: unknown) =>
      error instanceof MoneyDomainError && error.code === 'MONEY_OVERFLOW',
  );

  assert.throws(
    () => subtractMoney(money('REAL', 1n), money('REAL', 2n)),
    (error: unknown) =>
      error instanceof MoneyDomainError &&
      error.code === 'INSUFFICIENT_AMOUNT',
  );
});
