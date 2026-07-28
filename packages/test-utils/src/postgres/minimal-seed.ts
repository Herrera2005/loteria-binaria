import type { ClientBase } from 'pg';

import { TEST_BASELINE_DATE, TEST_IDS } from './fixtures';

export interface MinimalSeedResult {
  readonly productIds: {
    readonly octal: string;
  };
}

/**
 * Inserta los datos mínimos compartidos por las pruebas PostgreSQL.
 *
 * Esta función:
 * - Recibe una conexión ya abierta.
 * - No crea conexiones globales.
 * - No ejecuta migraciones.
 * - No inserta usuarios demo.
 * - No crea wallets ni cuentas ledger.
 * - Es idempotente.
 */
export async function seedMinimalCatalogs(
  client: ClientBase,
): Promise<MinimalSeedResult> {
  await client.query(
    `
      INSERT INTO lottery_products (
        id,
        code,
        name,
        description,
        is_active,
        created_at,
        updated_at
      )
      VALUES (
        $1::uuid,
        $2,
        $3,
        $4,
        $5,
        $6::timestamptz,
        $6::timestamptz
      )
      ON CONFLICT (code)
      DO UPDATE SET
        name = EXCLUDED.name,
        description = EXCLUDED.description,
        is_active = EXCLUDED.is_active,
        updated_at = EXCLUDED.updated_at
    `,
    [
      TEST_IDS.products.octal,
      'OCTAL',
      'Octal Test',
      'Producto mínimo exclusivo para pruebas PostgreSQL',
      true,
      TEST_BASELINE_DATE.toISOString(),
    ],
  );

  return {
    productIds: {
      octal: TEST_IDS.products.octal,
    },
  };
}