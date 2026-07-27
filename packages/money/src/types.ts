declare const minorAmountBrand: unique symbol;
declare const basisPointsBrand: unique symbol;

export const CURRENCIES = ['REAL', 'VIRTUAL'] as const;
export type Currency = (typeof CURRENCIES)[number];

/** Entero no negativo expresado en la unidad mínima de la moneda. */
export type MinorAmount = bigint & {
  readonly [minorAmountBrand]: 'MinorAmount';
};

/** Tasa entre 0 y 10 000 puntos básicos. 10 000 = 100 %. */
export type BasisPoints = bigint & {
  readonly [basisPointsBrand]: 'BasisPoints';
};

export interface Money<C extends Currency = Currency> {
  readonly currency: C;
  readonly minor: MinorAmount;
}

export interface AllocationPart<K extends string = string> {
  readonly key: K;
  readonly weight: bigint;
  /** Menor número = mayor prioridad cuando existe empate de residuo. */
  readonly priority: number;
}

export interface AllocationResult<K extends string = string> {
  readonly key: K;
  readonly amount: MinorAmount;
  readonly remainder: bigint;
  readonly priority: number;
}
