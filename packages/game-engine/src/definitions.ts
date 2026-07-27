import { GameEngineError } from './errors.js';
import {
  OFFICIAL_GAMES,
  type GameDefinition,
  type OfficialGame,
} from './types.js';

const OCTAL_SYMBOLS = Object.freeze([
  '0', '1', '2', '3', '4', '5', '6', '7',
]);

const DECIMAL_SYMBOLS = Object.freeze([
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
]);

const HEXADECIMAL_SYMBOLS = Object.freeze([
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
  'A', 'B', 'C', 'D', 'E', 'F',
]);

export const GAME_DEFINITIONS: Readonly<
  Record<OfficialGame, GameDefinition>
> = Object.freeze({
  OCTAL: Object.freeze({
    game: 'OCTAL',
    selectionCount: 4,
    universe: OCTAL_SYMBOLS,
  }),
  DECIMAL: Object.freeze({
    game: 'DECIMAL',
    selectionCount: 5,
    universe: DECIMAL_SYMBOLS,
  }),
  HEXADECIMAL: Object.freeze({
    game: 'HEXADECIMAL',
    selectionCount: 6,
    universe: HEXADECIMAL_SYMBOLS,
  }),
});

const OFFICIAL_GAME_SET = new Set<string>(OFFICIAL_GAMES);

export function isOfficialGame(value: unknown): value is OfficialGame {
  return typeof value === 'string' && OFFICIAL_GAME_SET.has(value);
}

export function assertOfficialGame(
  value: unknown,
): asserts value is OfficialGame {
  if (!isOfficialGame(value)) {
    throw new GameEngineError(
      'UNKNOWN_GAME',
      'El juego oficial debe ser OCTAL, DECIMAL o HEXADECIMAL.',
      { received: value },
    );
  }
}

export function getGameDefinition(game: OfficialGame): GameDefinition {
  assertOfficialGame(game);
  return GAME_DEFINITIONS[game];
}
