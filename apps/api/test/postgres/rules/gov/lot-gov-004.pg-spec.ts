import {
  createIsolatedPostgresDatabase,
  expectPostgreSqlError,
  TEST_BASELINE_DATE,
  TEST_IDS,
  type IsolatedPostgresDatabase,
} from '@loteria-binaria/test-utils';

/**
 * @rule LOT-GOV-004
 * @test TST-GOV-004
 * @level PG-INTEGRATION
 * @tables ledger_accounts, ledger_transactions, ledger_entries
 *
 * Demuestra que los registros contables no se corrigen modificando
 * o eliminando el historial. Toda corrección debe registrarse mediante
 * una nueva transacción de reverso.
 */
describe('LOT-GOV-004 — Inmutabilidad del libro contable', () => {
  let database: IsolatedPostgresDatabase;

  const originalAmountMinor = 10_000n;

  beforeAll(async () => {
    database = await createIsolatedPostgresDatabase({
      suiteName: 'lot-gov-004',
    });

    await createLedgerAccounts();
    await createOriginalTransaction();
  });

  afterAll(async () => {
    await database.drop();
  });

  it('rechaza modificar un asiento contable existente', async () => {
    const error = await expectPostgreSqlError(
      database.query(
        `
          UPDATE ledger_entries
          SET amount_minor = $2
          WHERE id = $1
        `,
        [TEST_IDS.ledgerEntries.immutabilityOriginalDebit, 9_999n],
      ),
      '55000',
    );

    expect(error.message).toContain('inmutable');

    const result = await database.query<{
      amount_minor: string;
    }>(
      `
        SELECT amount_minor::text AS amount_minor
        FROM ledger_entries
        WHERE id = $1
      `,
      [TEST_IDS.ledgerEntries.immutabilityOriginalDebit],
    );

    expect(result.rows[0]?.amount_minor).toBe(originalAmountMinor.toString());
  });

  it('rechaza eliminar un asiento contable existente', async () => {
    const error = await expectPostgreSqlError(
      database.query(
        `
          DELETE FROM ledger_entries
          WHERE id = $1
        `,
        [TEST_IDS.ledgerEntries.immutabilityOriginalDebit],
      ),
      '55000',
    );

    expect(error.message).toContain('inmutable');

    const result = await database.query<{
      entry_count: string;
    }>(
      `
        SELECT COUNT(*)::text AS entry_count
        FROM ledger_entries
        WHERE ledger_transaction_id = $1
      `,
      [TEST_IDS.ledgerTransactions.immutabilityOriginal],
    );

    expect(result.rows[0]?.entry_count).toBe('2');
  });

  it('rechaza modificar los datos base de una transacción ledger', async () => {
    const error = await expectPostgreSqlError(
      database.query(
        `
          UPDATE ledger_transactions
          SET description = 'Descripción manipulada'
          WHERE id = $1
        `,
        [TEST_IDS.ledgerTransactions.immutabilityOriginal],
      ),
      '55000',
    );

    expect(error.message).toContain('Solo puede avanzar el estado');

    const result = await database.query<{
      description: string | null;
    }>(
      `
        SELECT description
        FROM ledger_transactions
        WHERE id = $1
      `,
      [TEST_IDS.ledgerTransactions.immutabilityOriginal],
    );

    expect(result.rows[0]?.description).toBe(
      'Operación original para probar inmutabilidad',
    );
  });

  it('rechaza eliminar una transacción ledger', async () => {
    const error = await expectPostgreSqlError(
      database.query(
        `
          DELETE FROM ledger_transactions
          WHERE id = $1
        `,
        [TEST_IDS.ledgerTransactions.immutabilityOriginal],
      ),
      '55000',
    );

    expect(error.message).toContain('Las transacciones ledger no se eliminan');

    const result = await database.query<{
      transaction_count: string;
    }>(
      `
        SELECT COUNT(*)::text AS transaction_count
        FROM ledger_transactions
        WHERE id = $1
      `,
      [TEST_IDS.ledgerTransactions.immutabilityOriginal],
    );

    expect(result.rows[0]?.transaction_count).toBe('1');
  });

  it('corrige la operación mediante una transacción de reverso', async () => {
    const originalBefore = await database.query<{
      transaction_type: string;
      business_reference_type: string;
      business_reference_id: string;
      description: string | null;
      posted_at: Date;
    }>(
      `
        SELECT
          transaction_type,
          business_reference_type,
          business_reference_id::text AS business_reference_id,
          description,
          posted_at
        FROM ledger_transactions
        WHERE id = $1
      `,
      [TEST_IDS.ledgerTransactions.immutabilityOriginal],
    );

    const client = database.createClient();

    await client.connect();

    try {
      await client.query('BEGIN');

      await client.query(
        `
      INSERT INTO ledger_transactions (
        id,
        transaction_type,
        status,
        correlation_id,
        idempotency_key_id,
        reversal_of_transaction_id,
        business_reference_type,
        business_reference_id,
        rule_version_id,
        description,
        calculation_snapshot,
        posted_at,
        created_at
      )
      VALUES (
        $1,
        'TEST_IMMUTABILITY_REVERSAL',
        'CONTABILIZADA',
        $2,
        NULL,
        $3,
        'TEST_CASE',
        $4,
        NULL,
        'Reverso completo para LOT-GOV-004',
        '{"rule":"LOT-GOV-004","operation":"reversal"}'::jsonb,
        $5,
        $5
      )
    `,
        [
          TEST_IDS.ledgerTransactions.immutabilityReversal,
          '00000000-0000-4000-8000-000000000604',
          TEST_IDS.ledgerTransactions.immutabilityOriginal,
          '00000000-0000-4000-8000-000000000704',
          TEST_BASELINE_DATE,
        ],
      );

      await client.query(
        `
      INSERT INTO ledger_entries (
        id,
        ledger_transaction_id,
        account_id,
        reversal_of_entry_id,
        currency,
        side,
        amount_minor,
        sequence,
        memo_code,
        created_at
      )
      VALUES
      (
        $1,
        $2,
        $3,
        $4,
        'VIRTUAL',
        'CREDIT',
        $5,
        0,
        'LOT_GOV_004_REVERSAL_DEBIT',
        $6
      ),
      (
        $7,
        $2,
        $8,
        $9,
        'VIRTUAL',
        'DEBIT',
        $5,
        1,
        'LOT_GOV_004_REVERSAL_CREDIT',
        $6
      )
    `,
        [
          TEST_IDS.ledgerEntries.immutabilityReversalDebit,
          TEST_IDS.ledgerTransactions.immutabilityReversal,
          TEST_IDS.ledgerAccounts.immutabilityDebit,
          TEST_IDS.ledgerEntries.immutabilityOriginalDebit,
          originalAmountMinor,
          TEST_BASELINE_DATE,
          TEST_IDS.ledgerEntries.immutabilityReversalCredit,
          TEST_IDS.ledgerAccounts.immutabilityCredit,
          TEST_IDS.ledgerEntries.immutabilityOriginalCredit,
        ],
      );

      await client.query(
        `
      UPDATE ledger_transactions
      SET status = 'REVERSADA'
      WHERE id = $1
    `,
        [TEST_IDS.ledgerTransactions.immutabilityOriginal],
      );

      await client.query('COMMIT');
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      await client.end();
    }

    const originalAfter = await database.query<{
      transaction_type: string;
      status: string;
      business_reference_type: string;
      business_reference_id: string;
      description: string | null;
      posted_at: Date;
    }>(
      `
        SELECT
          transaction_type,
          status::text AS status,
          business_reference_type,
          business_reference_id::text AS business_reference_id,
          description,
          posted_at
        FROM ledger_transactions
        WHERE id = $1
      `,
      [TEST_IDS.ledgerTransactions.immutabilityOriginal],
    );

    expect(originalAfter.rows[0]).toMatchObject({
      transaction_type: originalBefore.rows[0]?.transaction_type,
      status: 'REVERSADA',
      business_reference_type: originalBefore.rows[0]?.business_reference_type,
      business_reference_id: originalBefore.rows[0]?.business_reference_id,
      description: originalBefore.rows[0]?.description,
    });

    expect(originalAfter.rows[0]?.posted_at.toISOString()).toBe(
      originalBefore.rows[0]?.posted_at.toISOString(),
    );

    const reversal = await database.query<{
      reversal_of_transaction_id: string | null;
      entry_count: string;
      debit_minor: string;
      credit_minor: string;
    }>(
      `
        SELECT
          transaction.reversal_of_transaction_id::text
            AS reversal_of_transaction_id,
          COUNT(entry.id)::text AS entry_count,
          COALESCE(
            SUM(entry.amount_minor)
              FILTER (WHERE entry.side = 'DEBIT'),
            0
          )::text AS debit_minor,
          COALESCE(
            SUM(entry.amount_minor)
              FILTER (WHERE entry.side = 'CREDIT'),
            0
          )::text AS credit_minor
        FROM ledger_transactions transaction
        JOIN ledger_entries entry
          ON entry.ledger_transaction_id = transaction.id
        WHERE transaction.id = $1
        GROUP BY transaction.reversal_of_transaction_id
      `,
      [TEST_IDS.ledgerTransactions.immutabilityReversal],
    );

    expect(reversal.rows[0]).toEqual({
      reversal_of_transaction_id:
        TEST_IDS.ledgerTransactions.immutabilityOriginal,
      entry_count: '2',
      debit_minor: originalAmountMinor.toString(),
      credit_minor: originalAmountMinor.toString(),
    });

    const balances = await database.query<{
      account_id: string;
      balance_minor: string;
    }>(
      `
        SELECT
          account_id::text AS account_id,
          SUM(
            CASE
              WHEN side = 'CREDIT' THEN amount_minor
              ELSE -amount_minor
            END
          )::text AS balance_minor
        FROM ledger_entries
        WHERE account_id IN ($1, $2)
        GROUP BY account_id
        ORDER BY account_id
      `,
      [
        TEST_IDS.ledgerAccounts.immutabilityDebit,
        TEST_IDS.ledgerAccounts.immutabilityCredit,
      ],
    );

    expect(balances.rows).toEqual([
      {
        account_id: TEST_IDS.ledgerAccounts.immutabilityDebit,
        balance_minor: '0',
      },
      {
        account_id: TEST_IDS.ledgerAccounts.immutabilityCredit,
        balance_minor: '0',
      },
    ]);
  });

  async function createLedgerAccounts(): Promise<void> {
    await database.query(
      `
        INSERT INTO ledger_accounts (
          id,
          account_code,
          currency,
          account_type,
          wallet_id,
          user_id,
          draw_event_id,
          user_draw_id,
          allows_negative,
          is_active,
          created_at,
          updated_at
        )
        VALUES
        (
          $1,
          'TEST_LOT_GOV_004_ISSUANCE',
          'VIRTUAL',
          'PLATFORM_VIRTUAL_ISSUANCE',
          NULL,
          NULL,
          NULL,
          NULL,
          TRUE,
          TRUE,
          $3,
          $3
        ),
        (
          $2,
          'TEST_LOT_GOV_004_REDEMPTION',
          'VIRTUAL',
          'PLATFORM_VIRTUAL_REDEMPTION',
          NULL,
          NULL,
          NULL,
          NULL,
          FALSE,
          TRUE,
          $3,
          $3
        )
      `,
      [
        TEST_IDS.ledgerAccounts.immutabilityDebit,
        TEST_IDS.ledgerAccounts.immutabilityCredit,
        TEST_BASELINE_DATE,
      ],
    );
  }

  async function createOriginalTransaction(): Promise<void> {
    const client = database.createClient();

    await client.connect();

    try {
      await client.query('BEGIN');

      await client.query(
        `
        INSERT INTO ledger_transactions (
          id,
          transaction_type,
          status,
          correlation_id,
          idempotency_key_id,
          reversal_of_transaction_id,
          business_reference_type,
          business_reference_id,
          rule_version_id,
          description,
          calculation_snapshot,
          posted_at,
          created_at
        )
        VALUES (
          $1,
          'TEST_IMMUTABILITY_ORIGINAL',
          'CONTABILIZADA',
          $2,
          NULL,
          NULL,
          'TEST_CASE',
          $3,
          NULL,
          'Operación original para probar inmutabilidad',
          '{"rule":"LOT-GOV-004","operation":"original"}'::jsonb,
          $4,
          $4
        )
      `,
        [
          TEST_IDS.ledgerTransactions.immutabilityOriginal,
          '00000000-0000-4000-8000-000000000601',
          '00000000-0000-4000-8000-000000000701',
          TEST_BASELINE_DATE,
        ],
      );

      await client.query(
        `
        INSERT INTO ledger_entries (
          id,
          ledger_transaction_id,
          account_id,
          reversal_of_entry_id,
          currency,
          side,
          amount_minor,
          sequence,
          memo_code,
          created_at
        )
        VALUES
        (
          $1,
          $2,
          $3,
          NULL,
          'VIRTUAL',
          'DEBIT',
          $4,
          0,
          'LOT_GOV_004_ORIGINAL_DEBIT',
          $5
        ),
        (
          $6,
          $2,
          $7,
          NULL,
          'VIRTUAL',
          'CREDIT',
          $4,
          1,
          'LOT_GOV_004_ORIGINAL_CREDIT',
          $5
        )
      `,
        [
          TEST_IDS.ledgerEntries.immutabilityOriginalDebit,
          TEST_IDS.ledgerTransactions.immutabilityOriginal,
          TEST_IDS.ledgerAccounts.immutabilityDebit,
          originalAmountMinor,
          TEST_BASELINE_DATE,
          TEST_IDS.ledgerEntries.immutabilityOriginalCredit,
          TEST_IDS.ledgerAccounts.immutabilityCredit,
        ],
      );

      await client.query('COMMIT');
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      await client.end();
    }
  }
});
