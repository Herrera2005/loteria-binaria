import 'dotenv/config';

import { Client } from 'pg';

import { applyMinimalTestSeed } from './apply-minimal-test-seed';
import { TEST_IDS } from './fixtures';

async function main(): Promise<void> {
  const databaseUrl = process.env.TEST_DATABASE_URL;

  if (!databaseUrl) {
    throw new Error('TEST_DATABASE_URL no está definida.');
  }

  await applyMinimalTestSeed(databaseUrl);

  const client = new Client({
    connectionString: databaseUrl,
  });

  await client.connect();

  try {
    const result = await client.query<{
      id: string;
      code: string;
      name: string;
      description: string | null;
      is_active: boolean;
    }>(
      `
        SELECT
          id,
          code,
          name,
          description,
          is_active
        FROM lottery_products
        WHERE code = $1
      `,
      ['OCTAL'],
    );

    if (result.rows.length !== 1) {
      throw new Error(
        `Se esperaba exactamente un producto OCTAL, pero se encontraron ${result.rows.length}.`,
      );
    }

    const product = result.rows[0];

    if (!product) {
      throw new Error('No se encontró el producto OCTAL.');
    }

    if (product.id !== TEST_IDS.products.octal) {
      throw new Error(
        `El UUID de OCTAL no coincide. Recibido: ${product.id}`,
      );
    }

    if (product.name !== 'Octal Test') {
      throw new Error(
        `El nombre de OCTAL es incorrecto: ${product.name}`,
      );
    }

    if (!product.is_active) {
      throw new Error('El producto OCTAL debería estar activo.');
    }

    console.log('✅ Seed mínimo aplicado correctamente');
    console.table(result.rows);
  } finally {
    await client.end();
  }
}

main().catch((error: unknown) => {
  console.error('❌ Verificación fallida');
  console.error(error);
  process.exitCode = 1;
});
