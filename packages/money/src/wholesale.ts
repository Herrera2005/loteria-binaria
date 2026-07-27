import { MoneyDomainError } from './errors.js';
import { money } from './money.js';
import { MONEY_POLICY_CODES } from './policies.js';
import type { Money } from './types.js';

export const WHOLESALE_VIRTUAL_INCREMENT_MINOR = 100n;
export const WHOLESALE_REAL_COST_PER_INCREMENT_MINOR = 90n;

export function assertWholesaleVirtualIncrement(
  amount: Money<'VIRTUAL'>,
): void {
  if (
    amount.minor === 0n ||
    amount.minor % WHOLESALE_VIRTUAL_INCREMENT_MINOR !== 0n
  ) {
    throw new MoneyDomainError(
      'INVALID_WHOLESALE_INCREMENT',
      'La compra mayorista debe ser un múltiplo positivo de 1,00 VIRTUAL (100 minor units).',
      { amountMinor: amount.minor.toString() },
    );
  }
}

export function calculateVendorWholesalePurchase(
  virtualAmount: Money<'VIRTUAL'>,
): {
  readonly virtualAmount: Money<'VIRTUAL'>;
  readonly realCost: Money<'REAL'>;
  readonly policyCode: typeof MONEY_POLICY_CODES.VENDOR_WHOLESALE_90_100;
} {
  assertWholesaleVirtualIncrement(virtualAmount);

  const increments =
    virtualAmount.minor / WHOLESALE_VIRTUAL_INCREMENT_MINOR;

  return Object.freeze({
    virtualAmount,
    realCost: money(
      'REAL',
      increments * WHOLESALE_REAL_COST_PER_INCREMENT_MINOR,
    ),
    policyCode: MONEY_POLICY_CODES.VENDOR_WHOLESALE_90_100,
  });
}
