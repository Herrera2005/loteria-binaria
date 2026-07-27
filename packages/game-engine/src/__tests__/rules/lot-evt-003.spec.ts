/**
 * @rule LOT-EVT-003
 * @test TST-EVT-003
 * @tables rule_versions, combination_numbers (suite PG posterior)
 * @level UNIT-GAME
 */
import assert from 'node:assert/strict';
import test from 'node:test';

import {
  GameEngineError,
  validateOfficialSelection,
} from '../../index.js';

const validCases = [
  ['OCTAL', '0247'],
  ['DECIMAL', '02479'],
  ['HEXADECIMAL', '09abef'],
] as const;

for (const [game, selection] of validCases) {
  test(`[LOT-EVT-003] ${game} acepta ${selection}`, () => {
    const validation = validateOfficialSelection(game, selection);
    assert.equal(validation.valid, true);
    if (validation.valid && game === 'HEXADECIMAL') {
      assert.deepEqual(validation.symbols, ['0', '9', 'A', 'B', 'E', 'F']);
    }
  });
}

test('[LOT-EVT-003] rechaza selecciones cortas y largas', () => {
  for (const selection of ['027', '01234']) {
    const validation = validateOfficialSelection('OCTAL', selection);
    assert.equal(validation.valid, false);
    if (!validation.valid) {
      assert.ok(validation.issues.some((issue) => issue.code === 'WRONG_COUNT'));
    }
  }
});

test('[LOT-EVT-003] rechaza símbolos repetidos', () => {
  const validation = validateOfficialSelection('DECIMAL', '00123');
  assert.equal(validation.valid, false);
  if (!validation.valid) {
    assert.ok(
      validation.issues.some((issue) => issue.code === 'DUPLICATE_SYMBOL'),
    );
  }
});

test('[LOT-EVT-003] rechaza símbolos fuera del universo', () => {
  const validation = validateOfficialSelection('HEXADECIMAL', '0123GZ');
  assert.equal(validation.valid, false);
  if (!validation.valid) {
    assert.ok(
      validation.issues.some(
        (issue) => issue.code === 'SYMBOL_OUT_OF_UNIVERSE',
      ),
    );
  }
});

test('[LOT-EVT-003] rechaza un juego desconocido en runtime', () => {
  assert.throws(
    () =>
      validateOfficialSelection(
        'BINARY' as unknown as 'OCTAL',
        '0123',
      ),
    (error: unknown) =>
      error instanceof GameEngineError && error.code === 'UNKNOWN_GAME',
  );
});
