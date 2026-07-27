/**
 * @rule LOT-PRZ-006
 * @test TST-PRZ-006
 * @tables prize_awards(exact, public, adjustment) (suite PG posterior)
 * @level UNIT-PROPERTY
 */
import assert from 'node:assert/strict';
import test from 'node:test';

import { money, roundPublicPrizeToQuarter } from '../../index.js';

const cases = [
  [100n, 100n],
  [112n, 100n],
  [113n, 125n],
  [137n, 125n],
  [138n, 150n],
  [162n, 150n],
  [163n, 175n],
  [187n, 175n],
  [188n, 200n],
  [199n, 200n],
] as const;

for (const [input, expected] of cases) {
  test(`[LOT-PRZ-006] frontera ${input} -> ${expected}`, () => {
    const result = roundPublicPrizeToQuarter(money('VIRTUAL', input));

    assert.equal(result.exact.minor, input);
    assert.equal(result.publicAmount.minor, expected);
    assert.equal(
      result.exact.minor + result.adjustmentMinor,
      result.publicAmount.minor,
    );
  });
}

test('[LOT-PRZ-006] todos los centavos 00-99 caen en el cuarto normativo', () => {
  for (let cents = 0n; cents <= 99n; cents += 1n) {
    const result = roundPublicPrizeToQuarter(
      money('VIRTUAL', 10_000n + cents),
    );
    const roundedCents = result.publicAmount.minor % 100n;

    assert.ok(
      [0n, 25n, 50n, 75n].includes(roundedCents) ||
        result.publicAmount.minor === 10_100n,
    );
  }
});
