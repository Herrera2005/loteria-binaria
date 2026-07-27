import { MoneyDomainError } from './errors.js';
import type { BasisPoints, MinorAmount } from './types.js';

export const POSTGRES_BIGINT_MAX = 9_223_372_036_854_775_807n;
export const BASIS_POINTS_SCALE = 10_000n;

export function minorAmount(value: bigint): MinorAmount {
  if (typeof value !== 'bigint' || value < 0n) {
    throw new MoneyDomainError(
      'INVALID_MINOR_AMOUNT',
      'El monto debe ser un bigint no negativo expresado en minor units.',
      { receivedType: typeof value },
    );
  }

  if (value > POSTGRES_BIGINT_MAX) {
    throw new MoneyDomainError(
      'MONEY_OVERFLOW',
      'El monto excede el máximo admitido por BIGINT de PostgreSQL.',
      { maximum: POSTGRES_BIGINT_MAX.toString(), received: value.toString() },
    );
  }

  return value as MinorAmount;
}

export function basisPoints(value: bigint): BasisPoints {
  if (
    typeof value !== 'bigint' ||
    value < 0n ||
    value > BASIS_POINTS_SCALE
  ) {
    throw new MoneyDomainError(
      'INVALID_BASIS_POINTS',
      'Los puntos básicos deben ser un bigint entre 0 y 10 000.',
      { receivedType: typeof value },
    );
  }

  return value as BasisPoints;
}

export function addMinorAmounts(
  left: MinorAmount,
  right: MinorAmount,
): MinorAmount {
  return minorAmount(minorAmount(left) + minorAmount(right));
}

export function subtractMinorAmounts(
  left: MinorAmount,
  right: MinorAmount,
): MinorAmount {
  const safeLeft = minorAmount(left);
  const safeRight = minorAmount(right);

  if (safeRight > safeLeft) {
    throw new MoneyDomainError(
      'INSUFFICIENT_AMOUNT',
      'La resta produciría un monto negativo.',
      { left: safeLeft.toString(), right: safeRight.toString() },
    );
  }

  return minorAmount(safeLeft - safeRight);
}

export function compareMinorAmounts(
  left: MinorAmount,
  right: MinorAmount,
): -1 | 0 | 1 {
  const safeLeft = minorAmount(left);
  const safeRight = minorAmount(right);

  if (safeLeft < safeRight) return -1;
  if (safeLeft > safeRight) return 1;
  return 0;
}

export function multiplyMinorAmountByInteger(
  value: MinorAmount,
  multiplier: bigint,
): MinorAmount {
  if (typeof multiplier !== 'bigint' || multiplier < 0n) {
    throw new MoneyDomainError(
      'INVALID_MINOR_AMOUNT',
      'El multiplicador monetario debe ser un bigint no negativo.',
      { receivedType: typeof multiplier },
    );
  }

  return minorAmount(minorAmount(value) * multiplier);
}
