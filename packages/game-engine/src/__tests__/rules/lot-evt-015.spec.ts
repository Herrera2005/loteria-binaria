/**
 * @rule LOT-EVT-015
 * @test TST-EVT-015
 * @tables event_combinations DISPONIBLE (suite API posterior)
 * @level UNIT-GAME
 */
import assert from 'node:assert/strict';
import test from 'node:test';

import { GameEngineError, resolveSelectionMode } from '../../index.js';

const available = [
  '0123',
  '0124',
  '0247',
  '1357',
  '7-4-2-0',
] as const;

test('[LOT-EVT-015] aleatoria completa usa un índice inyectado', () => {
  const result = resolveSelectionMode({
    game: 'OCTAL',
    mode: 'RANDOM_COMPLETE',
    availableSelections: available,
    randomIndex: 2,
  });

  assert.deepEqual(result, [['0', '2', '4', '7']]);
});

test('[LOT-EVT-015] lista compatible elimina duplicados normalizados', () => {
  const result = resolveSelectionMode({
    game: 'OCTAL',
    mode: 'PARTIAL_LIST',
    availableSelections: available,
    partialSymbols: '2-0',
  });

  assert.deepEqual(result, [
    ['0', '1', '2', '3'],
    ['0', '1', '2', '4'],
    ['0', '2', '4', '7'],
  ]);
});

test('[LOT-EVT-015] completar al azar filtra antes de elegir', () => {
  const result = resolveSelectionMode({
    game: 'OCTAL',
    mode: 'PARTIAL_RANDOM_COMPLETE',
    availableSelections: available,
    partialSymbols: '1-3',
    randomIndex: 1,
  });

  assert.deepEqual(result, [['1', '3', '5', '7']]);
});

test('[LOT-EVT-015] selección completa localiza la clave normalizada', () => {
  const result = resolveSelectionMode({
    game: 'OCTAL',
    mode: 'COMPLETE',
    availableSelections: available,
    requestedSelection: '7-4-2-0',
  });

  assert.deepEqual(result, [['0', '2', '4', '7']]);
});

test('[LOT-EVT-015] rechaza índice inexistente y no genera azar internamente', () => {
  assert.throws(
    () =>
      resolveSelectionMode({
        game: 'OCTAL',
        mode: 'RANDOM_COMPLETE',
        availableSelections: available,
        randomIndex: 99,
      }),
    (error: unknown) =>
      error instanceof GameEngineError &&
      error.code === 'INVALID_RANDOM_INDEX',
  );
});
