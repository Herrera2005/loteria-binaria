import { getGameDefinition } from './definitions.js';
import { GameEngineError } from './errors.js';
import type { OfficialGame } from './types.js';

export function combinationsCount(n: bigint, k: bigint): bigint {
  if (typeof n !== 'bigint' || typeof k !== 'bigint') {
    throw new GameEngineError(
      'INVALID_COMBINATION_ARGUMENTS',
      'n y k deben ser bigint.',
    );
  }

  if (n < 0n || k < 0n || k > n) {
    return 0n;
  }

  const effectiveK = k > n - k ? n - k : k;
  let result = 1n;

  for (let index = 1n; index <= effectiveK; index += 1n) {
    result = (result * (n - effectiveK + index)) / index;
  }

  return result;
}

export function countPossibleCombinations(game: OfficialGame): bigint {
  const definition = getGameDefinition(game);
  return combinationsCount(
    BigInt(definition.universe.length),
    BigInt(definition.selectionCount),
  );
}

export function calculateTwentyPercentLimit(
  totalCombinations: bigint,
): bigint {
  if (typeof totalCombinations !== 'bigint' || totalCombinations < 0n) {
    throw new GameEngineError(
      'INVALID_COMBINATION_ARGUMENTS',
      'El total de combinaciones debe ser un bigint no negativo.',
    );
  }

  return (totalCombinations * 20n) / 100n;
}

export function calculateGameTwentyPercentLimit(
  game: OfficialGame,
): bigint {
  return calculateTwentyPercentLimit(countPossibleCombinations(game));
}

export function generatePossibleCombinations(
  game: OfficialGame,
): readonly (readonly string[])[] {
  const definition = getGameDefinition(game);
  const combinations: (readonly string[])[] = [];

  function visit(startIndex: number, current: string[]): void {
    if (current.length === definition.selectionCount) {
      combinations.push(Object.freeze([...current]));
      return;
    }

    const remainingNeeded = definition.selectionCount - current.length;
    const lastStart = definition.universe.length - remainingNeeded;

    for (let index = startIndex; index <= lastStart; index += 1) {
      const symbol = definition.universe[index];
      if (symbol === undefined) continue;
      current.push(symbol);
      visit(index + 1, current);
      current.pop();
    }
  }

  visit(0, []);
  return Object.freeze(combinations);
}
