import { MONEY_POLICY_CODES } from './policies.js';
import { money } from './money.js';
import type { Money } from './types.js';

export interface PublicPrizeRounding {
  readonly exact: Money<'VIRTUAL'>;
  readonly publicAmount: Money<'VIRTUAL'>;
  /** Puede ser negativo cuando el redondeo público disminuye el valor exacto. */
  readonly adjustmentMinor: bigint;
  readonly policyCode: typeof MONEY_POLICY_CODES.PUBLIC_PRIZE_QUARTER_ROUNDING;
}

export function roundPublicPrizeToQuarter(
  exact: Money<'VIRTUAL'>,
): PublicPrizeRounding {
  const whole = exact.minor / 100n;
  const cents = exact.minor % 100n;

  let roundedCents: bigint;
  if (cents <= 12n) {
    roundedCents = 0n;
  } else if (cents <= 37n) {
    roundedCents = 25n;
  } else if (cents <= 62n) {
    roundedCents = 50n;
  } else if (cents <= 87n) {
    roundedCents = 75n;
  } else {
    roundedCents = 100n;
  }

  const roundedMinor = whole * 100n + roundedCents;

  return Object.freeze({
    exact,
    publicAmount: money('VIRTUAL', roundedMinor),
    adjustmentMinor: roundedMinor - exact.minor,
    policyCode: MONEY_POLICY_CODES.PUBLIC_PRIZE_QUARTER_ROUNDING,
  });
}
