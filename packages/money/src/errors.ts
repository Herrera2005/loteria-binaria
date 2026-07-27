export type MoneyErrorCode =
  | 'INVALID_CURRENCY'
  | 'INVALID_MINOR_AMOUNT'
  | 'MONEY_OVERFLOW'
  | 'CURRENCY_MISMATCH'
  | 'INSUFFICIENT_AMOUNT'
  | 'INVALID_BASIS_POINTS'
  | 'INVALID_ALLOCATION'
  | 'INVALID_WHOLESALE_INCREMENT'
  | 'INVALID_PRIZE_CONFIGURATION';

export class MoneyDomainError extends Error {
  public constructor(
    public readonly code: MoneyErrorCode,
    message: string,
    public readonly details?: Readonly<Record<string, unknown>>,
  ) {
    super(message);
    this.name = 'MoneyDomainError';
    Object.setPrototypeOf(this, new.target.prototype);
  }
}
