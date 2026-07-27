import {
  createNormalizedKey,
  normalizeOfficialSelection,
  validatePartialSelection,
} from './selection.js';
import type { OfficialGame } from './types.js';

function candidateContainsPartial(
  candidateSymbols: readonly string[],
  partialSymbols: readonly string[],
): boolean {
  const candidateSet = new Set(candidateSymbols);
  return partialSymbols.every((symbol) => candidateSet.has(symbol));
}

export function matchesPartialSelection(
  game: OfficialGame,
  candidate: string | readonly string[],
  partial: string | readonly string[],
): boolean {
  const candidateSymbols = normalizeOfficialSelection(game, candidate);
  const partialSymbols = validatePartialSelection(game, partial);
  return candidateContainsPartial(candidateSymbols, partialSymbols);
}

export function filterByPartialSelection(
  game: OfficialGame,
  candidates: readonly (string | readonly string[])[],
  partial: string | readonly string[],
): readonly (readonly string[])[] {
  const partialSymbols = validatePartialSelection(game, partial);
  const seen = new Set<string>();
  const matches: (readonly string[])[] = [];

  for (const candidate of candidates) {
    const normalized = normalizeOfficialSelection(game, candidate);
    if (!candidateContainsPartial(normalized, partialSymbols)) {
      continue;
    }

    const key = createNormalizedKey(game, normalized);
    if (seen.has(key)) {
      continue;
    }

    seen.add(key);
    matches.push(normalized);
  }

  return Object.freeze(matches);
}
