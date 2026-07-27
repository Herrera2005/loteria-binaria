/**
 * @rule LOT-FIN-013
 * @test TST-FIN-013
 * @tables policy_versions, ledger_entries (suite PG posterior)
 * @level UNIT-PROPERTY
 */
import assert from 'node:assert/strict';
import test from 'node:test';

import {
  allocateBasisPoints,
  basisPoints,
  minorAmount,
  money,
  MoneyDomainError,
  splitNoWinner50_25_15_10,
  splitOfficialGrowth90_10,
  splitUserDraw95_5,
} from '../../index.js';

test('[LOT-FIN-013] todos los repartos conservan importes de 0,01 a 10,00', () => {
  for (let minor = 1n; minor <= 1_000n; minor += 1n) {
    const source = money('VIRTUAL', minor);

    const growth = splitOfficialGrowth90_10(source);
    assert.equal(growth.prize.minor + growth.operations.minor, minor);

    const userDraw = splitUserDraw95_5(source);
    assert.equal(
      userDraw.escrow.minor + userDraw.retainedCommission.minor,
      minor,
    );

    const noWinner = splitNoWinner50_25_15_10(source);
    assert.equal(
      noWinner.accumulation.minor +
        noWinner.guarantee.minor +
        noWinner.futurePrizes.minor +
        noWinner.operations.minor,
      minor,
    );
  }
});

test('[LOT-FIN-013] los empates usan prioridades deterministas', () => {
  const source = money('VIRTUAL', 1n);

  const growth = splitOfficialGrowth90_10(source);
  assert.deepEqual(
    [growth.prize.minor, growth.operations.minor],
    [1n, 0n],
  );

  const userDraw = splitUserDraw95_5(source);
  assert.deepEqual(
    [userDraw.escrow.minor, userDraw.retainedCommission.minor],
    [1n, 0n],
  );

  const noWinner = splitNoWinner50_25_15_10(source);
  assert.deepEqual(
    [
      noWinner.accumulation.minor,
      noWinner.guarantee.minor,
      noWinner.futurePrizes.minor,
      noWinner.operations.minor,
    ],
    [1n, 0n, 0n, 0n],
  );
});

test('[LOT-FIN-013] exige exactamente 10 000 puntos básicos', () => {
  assert.throws(
    () =>
      allocateBasisPoints(minorAmount(100n), [
        { key: 'A', basisPoints: basisPoints(5_000n), priority: 1 },
        { key: 'B', basisPoints: basisPoints(4_999n), priority: 2 },
      ]),
    (error: unknown) =>
      error instanceof MoneyDomainError &&
      error.code === 'INVALID_ALLOCATION',
  );
});

test('[LOT-FIN-013] rechaza claves, prioridades y pesos inválidos', () => {
  assert.throws(
    () =>
      allocateBasisPoints(minorAmount(100n), [
        { key: 'A', basisPoints: basisPoints(5_000n), priority: 1 },
        { key: 'A', basisPoints: basisPoints(5_000n), priority: 2 },
      ]),
    MoneyDomainError,
  );

  assert.throws(
    () =>
      allocateBasisPoints(minorAmount(100n), [
        { key: 'A', basisPoints: basisPoints(5_000n), priority: 1 },
        { key: 'B', basisPoints: basisPoints(5_000n), priority: 1 },
      ]),
    MoneyDomainError,
  );
});
