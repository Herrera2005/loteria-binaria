/**
 * @rule LOT-PRZ-002
 * @test TST-PRZ-002
 * @tables ticket_evaluations, prize_awards (suite PG posterior)
 * @level UNIT-GAME
 */
import assert from 'node:assert/strict';
import test from 'node:test';

import { compareOfficialResult } from '../../index.js';

test('[LOT-PRZ-002] distancia 1 recibe clasificación near match', () => {
  const comparison = compareOfficialResult('OCTAL', '0124', '0123');

  assert.equal(comparison.exactMatch, false);
  assert.equal(comparison.nearMatch, true);
  assert.equal(comparison.matches, 3);
  assert.equal(comparison.distance, 1);
});

test('[LOT-PRZ-002] distancia 0 es exacta, no near match', () => {
  const comparison = compareOfficialResult('OCTAL', '3210', '0123');

  assert.equal(comparison.exactMatch, true);
  assert.equal(comparison.nearMatch, false);
  assert.equal(comparison.distance, 0);
});

test('[LOT-PRZ-002] distancia 2 no recibe devolución secundaria', () => {
  const comparison = compareOfficialResult('OCTAL', '0145', '0123');

  assert.equal(comparison.exactMatch, false);
  assert.equal(comparison.nearMatch, false);
  assert.equal(comparison.distance, 2);
});
