import { GameEngineError } from './errors.js';
import { filterByPartialSelection } from './partial-search.js';
import {
  createNormalizedKey,
  normalizeOfficialSelection,
} from './selection.js';
import type { ResolveSelectionModeInput } from './types.js';

function uniqueAvailableSelections(
  input: ResolveSelectionModeInput,
): readonly (readonly string[])[] {
  const seen = new Set<string>();
  const selections: (readonly string[])[] = [];

  for (const candidate of input.availableSelections) {
    const normalized = normalizeOfficialSelection(input.game, candidate);
    const key = createNormalizedKey(input.game, normalized);
    if (!seen.has(key)) {
      seen.add(key);
      selections.push(normalized);
    }
  }

  return Object.freeze(selections);
}

function pickByIndex(
  selections: readonly (readonly string[])[],
  randomIndex: number,
): readonly (readonly string[])[] {
  if (
    !Number.isSafeInteger(randomIndex) ||
    randomIndex < 0 ||
    randomIndex >= selections.length
  ) {
    throw new GameEngineError(
      'INVALID_RANDOM_INDEX',
      'El índice debe ser un entero seguro dentro de las opciones disponibles.',
      { randomIndex, availableCount: selections.length },
    );
  }

  const selected = selections[randomIndex];
  if (selected === undefined) {
    throw new GameEngineError(
      'INVALID_RANDOM_INDEX',
      'El índice no identifica una combinación disponible.',
    );
  }

  return Object.freeze([selected]);
}

export function resolveSelectionMode(
  input: ResolveSelectionModeInput,
): readonly (readonly string[])[] {
  const available = uniqueAvailableSelections(input);

  switch (input.mode) {
    case 'RANDOM_COMPLETE':
      return pickByIndex(available, input.randomIndex);

    case 'PARTIAL_LIST':
      return filterByPartialSelection(
        input.game,
        available,
        input.partialSymbols,
      );

    case 'PARTIAL_RANDOM_COMPLETE': {
      const candidates = filterByPartialSelection(
        input.game,
        available,
        input.partialSymbols,
      );
      return pickByIndex(candidates, input.randomIndex);
    }

    case 'COMPLETE': {
      const requestedKey = createNormalizedKey(
        input.game,
        input.requestedSelection,
      );

      return Object.freeze(
        available.filter(
          (candidate) =>
            createNormalizedKey(input.game, candidate) === requestedKey,
        ),
      );
    }
  }
}
