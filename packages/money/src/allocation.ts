import {
  BASIS_POINTS_SCALE,
  basisPoints,
  minorAmount,
} from './amount.js';
import { MoneyDomainError } from './errors.js';
import type {
  AllocationPart,
  AllocationResult,
  BasisPoints,
  MinorAmount,
} from './types.js';

function freezeAllocation<K extends string>(
  allocation: AllocationResult<K>,
): AllocationResult<K> {
  return Object.freeze(allocation);
}

export function allocateByLargestRemainder<K extends string>(
  total: MinorAmount,
  parts: readonly AllocationPart<K>[],
): readonly AllocationResult<K>[] {
  const safeTotal = minorAmount(total);

  if (parts.length === 0) {
    throw new MoneyDomainError(
      'INVALID_ALLOCATION',
      'La distribución debe contener al menos una parte.',
    );
  }

  const keys = new Set<string>();
  const priorities = new Set<number>();
  let totalWeight = 0n;

  for (const part of parts) {
    if (
      typeof part.key !== 'string' ||
      part.key.trim().length === 0 ||
      keys.has(part.key)
    ) {
      throw new MoneyDomainError(
        'INVALID_ALLOCATION',
        'Cada parte debe tener una clave no vacía y única.',
      );
    }

    if (
      !Number.isSafeInteger(part.priority) ||
      part.priority < 0 ||
      priorities.has(part.priority)
    ) {
      throw new MoneyDomainError(
        'INVALID_ALLOCATION',
        'Cada prioridad debe ser un entero seguro, no negativo y único.',
      );
    }

    if (typeof part.weight !== 'bigint' || part.weight < 0n) {
      throw new MoneyDomainError(
        'INVALID_ALLOCATION',
        'Los pesos deben ser bigint no negativos.',
      );
    }

    keys.add(part.key);
    priorities.add(part.priority);
    totalWeight += part.weight;
  }

  if (totalWeight <= 0n) {
    throw new MoneyDomainError(
      'INVALID_ALLOCATION',
      'La suma de pesos debe ser mayor que cero.',
    );
  }

  const provisional = parts.map((part, index) => {
    const numerator = safeTotal * part.weight;
    const floor = numerator / totalWeight;
    const remainder = numerator % totalWeight;

    return {
      key: part.key,
      amount: floor,
      remainder,
      priority: part.priority,
      index,
    };
  });

  const allocated = provisional.reduce(
    (sum, item) => sum + item.amount,
    0n,
  );
  let unitsLeft = safeTotal - allocated;

  const ranked = [...provisional].sort((left, right) => {
    if (left.remainder !== right.remainder) {
      return left.remainder > right.remainder ? -1 : 1;
    }

    if (left.priority !== right.priority) {
      return left.priority - right.priority;
    }

    return left.index - right.index;
  });

  const bonuses = new Map<K, bigint>();
  for (const item of ranked) {
    bonuses.set(item.key, 0n);
  }

  let cursor = 0;
  while (unitsLeft > 0n) {
    const target = ranked[cursor];
    if (target === undefined) {
      throw new MoneyDomainError(
        'INVALID_ALLOCATION',
        'No fue posible asignar todas las unidades residuales.',
      );
    }

    bonuses.set(target.key, (bonuses.get(target.key) ?? 0n) + 1n);
    unitsLeft -= 1n;
    cursor += 1;
  }

  const results = provisional.map((item) =>
    freezeAllocation({
      key: item.key,
      amount: minorAmount(item.amount + (bonuses.get(item.key) ?? 0n)),
      remainder: item.remainder,
      priority: item.priority,
    }),
  );

  return Object.freeze(results);
}

export function allocateBasisPoints<K extends string>(
  total: MinorAmount,
  parts: readonly {
    readonly key: K;
    readonly basisPoints: BasisPoints;
    readonly priority: number;
  }[],
): readonly AllocationResult<K>[] {
  const validatedParts = parts.map((part) => ({
    key: part.key,
    weight: basisPoints(part.basisPoints),
    priority: part.priority,
  }));

  const sum = validatedParts.reduce(
    (current, part) => current + part.weight,
    0n,
  );

  if (sum !== BASIS_POINTS_SCALE) {
    throw new MoneyDomainError(
      'INVALID_ALLOCATION',
      'Una distribución por puntos básicos debe sumar exactamente 10 000.',
      { sum: sum.toString() },
    );
  }

  return allocateByLargestRemainder(total, validatedParts);
}
