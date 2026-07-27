/**
 * @rule LOT-EVT-013
 * @test TST-EVT-013
 * @tables draw_events.limit_release_at (suite PG posterior)
 * @level UNIT-GAME
 */
import assert from 'node:assert/strict';
import test from 'node:test';

import {
  calculateLimitRelease,
  calculateLimitReleaseAt,
  isTwentyPercentLimitActive,
  roundLimitReleaseCandidate,
} from '../../index.js';

const iso = (hour: number, minute: number, second = 0) =>
  new Date(Date.UTC(2026, 6, 26, hour, minute, second, 0));

const boundaryCases = [
  [5, 0],
  [14, 0],
  [15, 30],
  [22, 30],
  [45, 30],
  [46, 60],
  [59, 60],
] as const;

for (const [minute, expectedMinute] of boundaryCases) {
  test(`[LOT-EVT-013] 16:${String(minute).padStart(2, '0')} redondea correctamente`, () => {
    const rounded = roundLimitReleaseCandidate(iso(16, minute));
    const expected =
      expectedMinute === 60 ? iso(17, 0) : iso(16, expectedMinute);

    assert.equal(rounded.toISOString(), expected.toISOString());
  });
}

test('[LOT-EVT-013] calcula 80 %, redondea y expone trazabilidad', () => {
  const calculation = calculateLimitRelease(iso(10, 0), iso(18, 0));

  assert.equal(calculation.rawEightyPercentAt.toISOString(), iso(16, 24).toISOString());
  assert.equal(calculation.roundedCandidateAt.toISOString(), iso(16, 30).toISOString());
  assert.equal(calculation.releaseAt.toISOString(), iso(16, 30).toISOString());
});

test('[LOT-EVT-013] una ventana corta nunca se extiende tras el cierre', () => {
  const open = iso(16, 40);
  const close = iso(16, 50);
  const release = calculateLimitReleaseAt(open, close);

  assert.equal(release.toISOString(), close.toISOString());
});

test('[LOT-EVT-013] el clamp nunca adelanta la apertura', () => {
  const open = iso(16, 40);
  const close = iso(16, 41);
  const release = calculateLimitReleaseAt(open, close);

  assert.equal(release.toISOString(), open.toISOString());
});

test('[LOT-EVT-013] el límite deja de estar activo exactamente en release_at', () => {
  const release = iso(16, 30);

  assert.equal(isTwentyPercentLimitActive(iso(16, 29, 59), release), true);
  assert.equal(isTwentyPercentLimitActive(release, release), false);
});
