import { getGameDefinition } from './definitions.js';
import { GameEngineError } from './errors.js';
import type {
  OfficialGame,
  SelectionValidation,
  SelectionValidationIssue,
} from './types.js';

const SEPARATORS = /[\s,;:_|/-]+/u;

function freezeSymbols(symbols: string[]): readonly string[] {
  return Object.freeze(symbols);
}

function normalizeInputSymbol(symbol: unknown): string {
  if (typeof symbol !== 'string') {
    throw new GameEngineError(
      'INVALID_SELECTION_INPUT',
      'Cada símbolo debe ser una cadena.',
      { receivedType: typeof symbol },
    );
  }

  return symbol.trim().toUpperCase();
}

export function parseSelection(
  selection: string | readonly string[],
): readonly string[] {
  if (typeof selection === 'string') {
    const compact = selection.trim().toUpperCase();
    if (compact.length === 0) {
      return Object.freeze([]);
    }

    if (SEPARATORS.test(compact)) {
      return freezeSymbols(
        compact
          .split(SEPARATORS)
          .filter((symbol) => symbol.length > 0),
      );
    }

    return freezeSymbols([...compact]);
  }

  if (!Array.isArray(selection)) {
    throw new GameEngineError(
      'INVALID_SELECTION_INPUT',
      'La selección debe ser texto o una lista de símbolos.',
      { receivedType: typeof selection },
    );
  }

  return freezeSymbols(selection.map(normalizeInputSymbol));
}

export function hasUniqueSymbols(
  selection: string | readonly string[],
): boolean {
  const symbols = parseSelection(selection);
  return new Set(symbols).size === symbols.length;
}

export function validateOfficialSelection(
  game: OfficialGame,
  selection: string | readonly string[],
): SelectionValidation {
  const definition = getGameDefinition(game);
  const symbols = parseSelection(selection);
  const issues: SelectionValidationIssue[] = [];

  if (symbols.length !== definition.selectionCount) {
    issues.push(
      Object.freeze({
        code: 'WRONG_COUNT',
        message: `Se requieren exactamente ${definition.selectionCount} símbolos.`,
      }),
    );
  }

  if (new Set(symbols).size !== symbols.length) {
    issues.push(
      Object.freeze({
        code: 'DUPLICATE_SYMBOL',
        message: 'Los símbolos no pueden repetirse.',
      }),
    );
  }

  const universe = new Set(definition.universe);
  for (const symbol of symbols) {
    if (!universe.has(symbol)) {
      issues.push(
        Object.freeze({
          code: 'SYMBOL_OUT_OF_UNIVERSE',
          message: `El símbolo ${symbol || '(vacío)'} no pertenece al universo ${game}.`,
          symbol,
        }),
      );
    }
  }

  if (issues.length > 0) {
    return Object.freeze({
      valid: false,
      symbols,
      issues: Object.freeze(issues),
    });
  }

  return Object.freeze({
    valid: true,
    symbols,
  });
}

export function assertValidOfficialSelection(
  game: OfficialGame,
  selection: string | readonly string[],
): readonly string[] {
  const validation = validateOfficialSelection(game, selection);

  if (!validation.valid) {
    const codes = validation.issues.map((issue) => issue.code).join(', ');
    throw new GameEngineError(
      'INVALID_SELECTION',
      `Selección inválida para ${game}: ${codes}.`,
      { issues: validation.issues },
    );
  }

  return validation.symbols;
}

function canonicalOrder(game: OfficialGame): ReadonlyMap<string, number> {
  const definition = getGameDefinition(game);
  return new Map(
    definition.universe.map((symbol, index) => [symbol, index]),
  );
}

export function normalizeOfficialSelection(
  game: OfficialGame,
  selection: string | readonly string[],
): readonly string[] {
  const symbols = assertValidOfficialSelection(game, selection);
  const order = canonicalOrder(game);

  return freezeSymbols(
    [...symbols].sort(
      (left, right) =>
        (order.get(left) ?? Number.MAX_SAFE_INTEGER) -
        (order.get(right) ?? Number.MAX_SAFE_INTEGER),
    ),
  );
}

export function createNormalizedKey(
  game: OfficialGame,
  selection: string | readonly string[],
): string {
  return normalizeOfficialSelection(game, selection).join('');
}

export function validatePartialSelection(
  game: OfficialGame,
  selection: string | readonly string[],
): readonly string[] {
  const definition = getGameDefinition(game);
  const symbols = parseSelection(selection);
  const universe = new Set(definition.universe);

  if (
    symbols.length > definition.selectionCount ||
    new Set(symbols).size !== symbols.length ||
    symbols.some((symbol) => !universe.has(symbol))
  ) {
    throw new GameEngineError(
      'INVALID_PARTIAL_SELECTION',
      `La selección parcial no es compatible con ${game}.`,
      { symbols },
    );
  }

  const order = canonicalOrder(game);
  return freezeSymbols(
    [...symbols].sort(
      (left, right) =>
        (order.get(left) ?? Number.MAX_SAFE_INTEGER) -
        (order.get(right) ?? Number.MAX_SAFE_INTEGER),
    ),
  );
}
