import assert from 'node:assert/strict';
import test from 'node:test';

import {
  combinationsCount,
  countPossibleCombinations,
  generatePossibleCombinations,
} from '../../index.js';

test('combinaciones oficiales producen C(8,4), C(10,5) y C(16,6)', () => {
  assert.equal(countPossibleCombinations('OCTAL'), 70n);
  assert.equal(countPossibleCombinations('DECIMAL'), 252n);
  assert.equal(countPossibleCombinations('HEXADECIMAL'), 8_008n);
});

test('generador produce todas las combinaciones canónicas sin repetición', () => {
  const combinations = generatePossibleCombinations('OCTAL');
  const keys = combinations.map((combination) => combination.join(''));

  assert.equal(combinations.length, 70);
  assert.equal(new Set(keys).size, 70);
  assert.equal(keys[0], '0123');
  assert.equal(keys.at(-1), '4567');
});

test('C(n,k) maneja fronteras matemáticas', () => {
  assert.equal(combinationsCount(0n, 0n), 1n);
  assert.equal(combinationsCount(5n, 0n), 1n);
  assert.equal(combinationsCount(5n, 5n), 1n);
  assert.equal(combinationsCount(5n, 6n), 0n);
  assert.equal(combinationsCount(-1n, 0n), 0n);
});
