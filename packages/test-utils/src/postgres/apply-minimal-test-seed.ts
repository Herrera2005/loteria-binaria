import { Client } from 'pg';

import { seedMinimalCatalogs } from './minimal-seed';

function assertTestDatabaseUrl(databaseUrl: string): void {
  const parsedUrl = new URL(databaseUrl);
  const databaseName = parsedUrl.pathname.replace(/^\//, '');

  if (process.env.NODE_ENV !== 'test') {
    throw new Error(
      'applyMinimalTestSeed solo puede ejecutarse con NODE_ENV=test.',
    );
  }

  if (!databaseName.toLowerCase().includes('test')) {
    throw new Error(
      `La base "${databaseName}" no parece ser una base de pruebas.`,
    );
  }
}

export async function applyMinimalTestSeed(
  databaseUrl: string,
): Promise<void> {
  assertTestDatabaseUrl(databaseUrl);

  const client = new Client({
    connectionString: databaseUrl,
  });

  let connected = false;
  let transactionStarted = false;

  try {
    await client.connect();
    connected = true;

    await client.query('BEGIN');
    transactionStarted = true;

    await seedMinimalCatalogs(client);

    await client.query('COMMIT');
    transactionStarted = false;
  } catch (error) {
    if (connected && transactionStarted) {
      await client.query('ROLLBACK').catch(() => undefined);
    }

    throw error;
  } finally {
    if (connected) {
      await client.end();
    }
  }
}