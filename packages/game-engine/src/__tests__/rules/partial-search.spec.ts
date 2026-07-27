import assert from 'node:assert/strict';
import test from 'node:test';

import {
  filterByPartialSelection,
  GameEngineError,
  matchesPartialSelection,
} from '../../index.js';

test('búsqueda parcial compara conjuntos, no orden', () => {
  assert.equal(matchesPartialSelection('HEXADECIMAL', '09ABEF', 'F-0-A'), true);
  assert.equal(matchesPartialSelection('HEXADECIMAL', '09ABEF', 'F-1-A'), false);
});

test('búsqueda parcial retorna combinaciones normalizadas y únicas', () => {
  const result = filterByPartialSelection(
    'OCTAL',
    ['7420', '0247', '0123', '1357'],
    '0-2',
  );

  assert.deepEqual(result, [
    ['0', '2', '4', '7'],
    ['0', '1', '2', '3'],
  ]);
});

test('selección parcial rechaza repetidos y fuera de universo', () => {
  for (const partial of ['0-0', '0-8', '0-1-2-3-4']) {
    assert.throws(
      () => matchesPartialSelection('OCTAL', '0123', partial),
      (error: unknown) =>
        error instanceof GameEngineError &&
        error.code === 'INVALID_PARTIAL_SELECTION',
    );
  }
});
