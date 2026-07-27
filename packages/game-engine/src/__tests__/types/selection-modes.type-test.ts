import { resolveSelectionMode } from '../../index.js';

resolveSelectionMode({
  game: 'OCTAL',
  mode: 'RANDOM_COMPLETE',
  availableSelections: ['0123'],
  randomIndex: 0,
});

// @ts-expect-error RANDOM_COMPLETE requiere randomIndex.
resolveSelectionMode({
  game: 'OCTAL',
  mode: 'RANDOM_COMPLETE',
  availableSelections: ['0123'],
});

// @ts-expect-error COMPLETE requiere requestedSelection.
resolveSelectionMode({
  game: 'OCTAL',
  mode: 'COMPLETE',
  availableSelections: ['0123'],
});
