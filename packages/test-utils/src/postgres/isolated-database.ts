import { randomUUID } from 'node:crypto';

import {
  Client,
  type ClientConfig,
  type QueryResult,
  type QueryResultRow,
} from 'pg';

import {
  loadTestDatabaseUrls,
  replaceDatabaseName,
} from './database-url';

import { applyMigrations } from './migrate-database';

export interface CreateIsolatedDatabaseOptions {
  readonly suiteName: string;
  readonly migrate?: boolean;
}

export interface IsolatedPostgresDatabase {
  readonly name: string;
  readonly url: string;

  createClient(config?: Omit<ClientConfig, 'connectionString'>): Client;

  query<T extends QueryResultRow = QueryResultRow>(
    text: string,
    values?: readonly unknown[],
  ): Promise<QueryResult<T>>;

  drop(): Promise<void>;
}

function normalizeSuiteName(suiteName: string): string {
  const normalizedName = suiteName
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/gu, '_')
    .replace(/^_+|_+$/gu, '')
    .slice(0, 30);

  return normalizedName || 'suite';
}

function createDatabaseName(suiteName: string): string {
  const safeSuiteName = normalizeSuiteName(suiteName);
  const suffix = randomUUID().replaceAll('-', '').slice(0, 12);

  return `lb_test_${safeSuiteName}_${suffix}`;
}

function quoteIdentifier(identifier: string): string {
  if (!/^[a-z][a-z0-9_]{0,62}$/u.test(identifier)) {
    throw new Error(
      `No se puede utilizar el identificador PostgreSQL: ${identifier}`,
    );
  }

  return `"${identifier}"`;
}

export async function createIsolatedPostgresDatabase(
  options: CreateIsolatedDatabaseOptions,
): Promise<IsolatedPostgresDatabase> {
  const { adminUrl, templateUrl } = loadTestDatabaseUrls();
  const databaseName = createDatabaseName(options.suiteName);
  const databaseUrl = replaceDatabaseName(
    templateUrl,
    databaseName,
  );

  const adminClient = new Client({
    connectionString: adminUrl,
    application_name: 'loteria-binaria-test-admin',
  });

  await adminClient.connect();

  try {
    await adminClient.query(
      `CREATE DATABASE ${quoteIdentifier(databaseName)} TEMPLATE template0`,
    );
  } finally {
    await adminClient.end();
  }

  try {
    if (options.migrate !== false) {
      await applyMigrations({
        databaseUrl,
      });
    }
  } catch (error: unknown) {
    await dropDatabase(adminUrl, databaseName);
    throw error;
  }

  let dropped = false;

  return {
    name: databaseName,
    url: databaseUrl,

    createClient(
      config: Omit<ClientConfig, 'connectionString'> = {},
    ): Client {
      if (dropped) {
        throw new Error(
          `La base ${databaseName} ya fue eliminada.`,
        );
      }

      return new Client({
        ...config,
        connectionString: databaseUrl,
        application_name:
          config.application_name ??
          `loteria-binaria-${normalizeSuiteName(options.suiteName)}`,
      });
    },

    async query<T extends QueryResultRow = QueryResultRow>(
      text: string,
      values: readonly unknown[] = [],
    ): Promise<QueryResult<T>> {
      if (dropped) {
        throw new Error(
          `La base ${databaseName} ya fue eliminada.`,
        );
      }

      const client = new Client({
        connectionString: databaseUrl,
        application_name: 'loteria-binaria-test-query',
      });

      await client.connect();

      try {
        return await client.query<T>(
          text,
          [...values],
        );
      } finally {
        await client.end();
      }
    },

    async drop(): Promise<void> {
      if (dropped) {
        return;
      }

      await dropDatabase(adminUrl, databaseName);
      dropped = true;
    },
  };
}

async function dropDatabase(
  adminUrl: string,
  databaseName: string,
): Promise<void> {
  if (!databaseName.startsWith('lb_test_')) {
    throw new Error(
      `Se rechazó eliminar una base que no comienza con lb_test_: ${databaseName}`,
    );
  }

  const adminClient = new Client({
    connectionString: adminUrl,
    application_name: 'loteria-binaria-test-cleanup',
  });

  await adminClient.connect();

  try {
    await adminClient.query(
      `
        SELECT pg_terminate_backend(pid)
        FROM pg_stat_activity
        WHERE datname = $1
          AND pid <> pg_backend_pid()
      `,
      [databaseName],
    );

    await adminClient.query(
      `DROP DATABASE IF EXISTS ${quoteIdentifier(databaseName)}`,
    );
  } finally {
    await adminClient.end();
  }
}