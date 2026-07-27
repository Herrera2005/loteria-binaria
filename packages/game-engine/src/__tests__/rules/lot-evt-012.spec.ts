/**
 * @rule LOT-EVT-012
 * @test TST-EVT-012 (componente matemático)
 * @tables draw_events, paid tickets + active reservations (suite API/PG posterior)
 * @level UNIT-GAME
 */
import assert from 'node:assert/strict';
import test from 'node:test';

import {
  calculateGameTwentyPercentLimit,
  calculateTwentyPercentLimit,
} from '../../index.js';

test('[LOT-EVT-012] el límite usa floor del 20 %', () => {
  assert.equal(calculateGameTwentyPercentLimit('OCTAL'), 14n);
  assert.equal(calculateGameTwentyPercentLimit('DECIMAL'), 50n);
  assert.equal(calculateGameTwentyPercentLimit('HEXADECIMAL'), 1_601n);
  assert.equal(calculateTwentyPercentLimit(9n), 1n);
});
