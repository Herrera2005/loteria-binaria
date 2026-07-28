import {
  createIsolatedPostgresDatabase,
  type IsolatedPostgresDatabase,
} from '@loteria-binaria/test-utils';

describe('PostgreSQL isolated database harness', () => {
  let database: IsolatedPostgresDatabase;

  beforeAll(async () => {
    database = await createIsolatedPostgresDatabase({
      suiteName: 'database-harness',
    });
  });

  afterAll(async () => {
    await database.drop();
  });

  it('crea una base aislada y aplica las migraciones', async () => {
    const result = await database.query<{
      current_database: string;
    }>('SELECT current_database()');

    expect(result.rows).toHaveLength(1);
    expect(result.rows[0]?.current_database).toBe(database.name);

    expect(database.name).toMatch(/^lb_test_/u);
  });

  it('contiene el historial de migraciones de Prisma', async () => {
    const result = await database.query<{
      migration_count: string;
    }>(
      `
        SELECT COUNT(*)::text AS migration_count
        FROM "_prisma_migrations"
        WHERE finished_at IS NOT NULL
          AND rolled_back_at IS NULL
      `,
    );

    expect(BigInt(result.rows[0]?.migration_count ?? '0')).toBeGreaterThan(0n);
  });

  it('puede abrir dos conexiones independientes', async () => {
    const clientA = database.createClient({
      application_name: 'database-harness-a',
    });

    const clientB = database.createClient({
      application_name: 'database-harness-b',
    });

    await Promise.all([clientA.connect(), clientB.connect()]);

    try {
      const [resultA, resultB] = await Promise.all([
        clientA.query<{ backend_pid: number }>(
          'SELECT pg_backend_pid() AS backend_pid',
        ),
        clientB.query<{ backend_pid: number }>(
          'SELECT pg_backend_pid() AS backend_pid',
        ),
      ]);

      expect(resultA.rows[0]?.backend_pid).not.toBe(
        resultB.rows[0]?.backend_pid,
      );
    } finally {
      await Promise.allSettled([clientA.end(), clientB.end()]);
    }
  });
});
