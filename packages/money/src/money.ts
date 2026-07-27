import {
  addMinorAmounts,
  compareMinorAmounts,
  minorAmount,
  multiplyMinorAmountByInteger,
  subtractMinorAmounts,
} from './amount.js';
import { MoneyDomainError } from './errors.js';
import { CURRENCIES, type Currency, type Money } from './types.js';

const CURRENCY_SET = new Set<string>(CURRENCIES);

export function isCurrency(value: unknown): value is Currency {
  return typeof value === 'string' && CURRENCY_SET.has(value);
}

export function assertCurrency(value: unknown): asserts value is Currency {
  if (!isCurrency(value)) {
    throw new MoneyDomainError(
      'INVALID_CURRENCY',
      'La moneda debe ser REAL o VIRTUAL.',
      { received: value },
    );
  }
}

export function money<C extends Currency>(
  currency: C,
  minor: bigint,
): Money<C> {
  assertCurrency(currency);

  return Object.freeze({
    currency,
    minor: minorAmount(minor),
  });
}

export function zeroMoney<C extends Currency>(currency: C): Money<C> {
  return money(currency, 0n);
}

export function assertSameCurrency(
  left: Money,
  right: Money,
): void {
  if (left.currency !== right.currency) {
    throw new MoneyDomainError(
      'CURRENCY_MISMATCH',
      `No se puede operar ${left.currency} con ${right.currency}.`,
      { leftCurrency: left.currency, rightCurrency: right.currency },
    );
  }
}

export function addMoney<C extends Currency>(
  left: Money<C>,
  right: Money<NoInfer<C>>,
): Money<C> {
  assertSameCurrency(left, right);
  return money(left.currency, addMinorAmounts(left.minor, right.minor));
}

export function subtractMoney<C extends Currency>(
  left: Money<C>,
  right: Money<NoInfer<C>>,
): Money<C> {
  assertSameCurrency(left, right);
  return money(left.currency, subtractMinorAmounts(left.minor, right.minor));
}

export function compareMoney<C extends Currency>(
  left: Money<C>,
  right: Money<NoInfer<C>>,
): -1 | 0 | 1 {
  assertSameCurrency(left, right);
  return compareMinorAmounts(left.minor, right.minor);
}

export function multiplyMoneyByInteger<C extends Currency>(
  value: Money<C>,
  multiplier: bigint,
): Money<C> {
  return money(
    value.currency,
    multiplyMinorAmountByInteger(value.minor, multiplier),
  );
}
