import {
  createNormalizedKey,
  normalizeOfficialSelection,
} from './selection.js';
import type { OfficialGame, ResultComparison } from './types.js';

export function compareOfficialResult(
  game: OfficialGame,
  ticket: string | readonly string[],
  result: string | readonly string[],
): ResultComparison {
  const ticketSymbols = normalizeOfficialSelection(game, ticket);
  const resultSymbols = normalizeOfficialSelection(game, result);
  const resultSet = new Set(resultSymbols);
  const matches = ticketSymbols.filter((symbol) => resultSet.has(symbol)).length;
  const distance = ticketSymbols.length - matches;

  return Object.freeze({
    exactMatch:
      createNormalizedKey(game, ticketSymbols) ===
      createNormalizedKey(game, resultSymbols),
    nearMatch: distance === 1,
    matches,
    distance,
  });
}
