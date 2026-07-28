/**
 * Identificadores deterministas para pruebas PostgreSQL.
 *
 * No deben generarse aleatoriamente porque las pruebas deben ser
 * reproducibles y fáciles de depurar.
 */
export const TEST_IDS = {
  products: {
    octal: '00000000-0000-4000-8000-000000000101',
    decimal: '00000000-0000-4000-8000-000000000102',
    hexadecimal: '00000000-0000-4000-8000-000000000103',
  },

  users: {
    clientA: '00000000-0000-4000-8000-000000000201',
    clientB: '00000000-0000-4000-8000-000000000202',
    sellerA: '00000000-0000-4000-8000-000000000203',
  },

  ledgerAccounts: {
    realAvailableA: '00000000-0000-4000-8000-000000000301',
    virtualAvailableA: '00000000-0000-4000-8000-000000000302',
    virtualAvailableB: '00000000-0000-4000-8000-000000000303',
    platformVirtual: '00000000-0000-4000-8000-000000000304',
    immutabilityDebit: '00000000-0000-4000-8000-000000000305',
    immutabilityCredit: '00000000-0000-4000-8000-000000000306',
  },

  ledgerTransactions: {
    initialCredit: '00000000-0000-4000-8000-000000000401',
    concurrentDebitA: '00000000-0000-4000-8000-000000000402',
    concurrentDebitB: '00000000-0000-4000-8000-000000000403',
    immutabilityOriginal: '00000000-0000-4000-8000-000000000404',
    immutabilityReversal: '00000000-0000-4000-8000-000000000405',
  },

  ledgerEntries: {
    immutabilityOriginalDebit:
      '00000000-0000-4000-8000-000000000501',
    immutabilityOriginalCredit:
      '00000000-0000-4000-8000-000000000502',
    immutabilityReversalDebit:
      '00000000-0000-4000-8000-000000000503',
    immutabilityReversalCredit:
      '00000000-0000-4000-8000-000000000504',
  },
} as const;

/**
 * Fecha fija para evitar que las pruebas dependan del reloj actual.
 */
export const TEST_BASELINE_DATE = new Date(
  '2026-07-26T00:00:00.000Z',
);
