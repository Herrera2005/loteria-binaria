/**
 * @rule LOT-EVT-004
 * @test TST-EVT-004
 * @tables event_combinations.normalized_key (suite PG posterior)
 * @level UNIT-GAME
 */
import assert from 'node:assert/strict';
import test from 'node:test';

import {
  createNormalizedKey,
  normalizeOfficialSelection,
} from '../../index.js';

test('[LOT-EVT-004] órdenes diferentes producen la misma clave', () => {
  assert.equal(
    createNormalizedKey('OCTAL', '7-4-2-0'),
    createNormalizedKey('OCTAL', '0-2-4-7'),
  );
  assert.equal(createNormalizedKey('OCTAL', '7-4-2-0'), '0247');
});

test('[LOT-EVT-004] hexadecimal normaliza mayúsculas y orden canónico', () => {
  assert.deepEqual(
    normalizeOfficialSelection('HEXADECIMAL', 'f-a-9-0-e-b'),
    ['0', '9', 'A', 'B', 'E', 'F'],
  );
});

test('[LOT-EVT-004] acepta separadores permitidos sin alterar la clave', () => {
  const expected = createNormalizedKey('DECIMAL', '0-2-4-7-9');

  for (const candidate of [
    '0 2 4 7 9',
    '0,2,4,7,9',
    '0;2;4;7;9',
    '0/2/4/7/9',
    '02479',
  ]) {
    assert.equal(createNormalizedKey('DECIMAL', candidate), expected);
  }
});
