import { GameEngineError } from './errors.js';
import type { LimitReleaseCalculation } from './types.js';

const MINUTE_MS = 60_000;
const HOUR_MS = 60 * MINUTE_MS;

function assertValidDate(date: Date, label: string): void {
  if (!(date instanceof Date) || !Number.isFinite(date.getTime())) {
    throw new GameEngineError(
      'INVALID_WINDOW',
      `${label} no es una fecha válida.`,
    );
  }
}

function cloneDate(date: Date): Date {
  return new Date(date.getTime());
}

export function roundLimitReleaseCandidate(candidate: Date): Date {
  assertValidDate(candidate, 'candidate');

  const rounded = cloneDate(candidate);
  const minute = rounded.getUTCMinutes();
  rounded.setUTCSeconds(0, 0);

  if (minute <= 14) {
    rounded.setUTCMinutes(0);
  } else if (minute <= 45) {
    rounded.setUTCMinutes(30);
  } else {
    rounded.setUTCHours(rounded.getUTCHours() + 1, 0, 0, 0);
  }

  return rounded;
}

export function calculateRawEightyPercentInstant(
  salesOpenAt: Date,
  salesCloseAt: Date,
): Date {
  assertValidDate(salesOpenAt, 'salesOpenAt');
  assertValidDate(salesCloseAt, 'salesCloseAt');

  const open = salesOpenAt.getTime();
  const close = salesCloseAt.getTime();

  if (close <= open) {
    throw new GameEngineError(
      'INVALID_WINDOW',
      'salesCloseAt debe ser posterior a salesOpenAt.',
      { open, close },
    );
  }

  const duration = BigInt(close - open);
  const raw = BigInt(open) + (duration * 80n) / 100n;
  return new Date(Number(raw));
}

export function calculateLimitRelease(
  salesOpenAt: Date,
  salesCloseAt: Date,
): LimitReleaseCalculation {
  const rawEightyPercentAt = calculateRawEightyPercentInstant(
    salesOpenAt,
    salesCloseAt,
  );
  const roundedCandidateAt = roundLimitReleaseCandidate(
    rawEightyPercentAt,
  );
  const open = salesOpenAt.getTime();
  const close = salesCloseAt.getTime();
  const releaseAt = new Date(
    Math.min(close, Math.max(open, roundedCandidateAt.getTime())),
  );

  return Object.freeze({
    rawEightyPercentAt,
    roundedCandidateAt,
    releaseAt,
  });
}

export function calculateLimitReleaseAt(
  salesOpenAt: Date,
  salesCloseAt: Date,
): Date {
  return calculateLimitRelease(salesOpenAt, salesCloseAt).releaseAt;
}

export function isTwentyPercentLimitActive(
  now: Date,
  limitReleaseAt: Date,
): boolean {
  assertValidDate(now, 'now');
  assertValidDate(limitReleaseAt, 'limitReleaseAt');
  return now.getTime() < limitReleaseAt.getTime();
}

export const TIME_CONSTANTS = Object.freeze({
  MINUTE_MS,
  HOUR_MS,
});
