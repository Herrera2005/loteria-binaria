export interface PostgreSqlError extends Error {
  readonly code?: string;
  readonly constraint?: string;
  readonly detail?: string;
  readonly table?: string;
  readonly schema?: string;
}

export function isPostgreSqlError(
  error: unknown,
): error is PostgreSqlError {
  return (
    error instanceof Error &&
    'code' in error &&
    typeof error.code === 'string'
  );
}

export function getPostgreSqlErrorCode(
  error: unknown,
): string | undefined {
  return isPostgreSqlError(error) ? error.code : undefined;
}

export async function expectPostgreSqlError(
  operation: Promise<unknown>,
  expectedSqlState: string,
): Promise<PostgreSqlError> {
  try {
    await operation;
  } catch (error: unknown) {
    if (!isPostgreSqlError(error)) {
      throw new Error(
        `Se esperaba un error PostgreSQL ${expectedSqlState}, pero se recibió otro tipo de error.`,
        {
          cause: error,
        },
      );
    }

    if (error.code !== expectedSqlState) {
      throw new Error(
        `Se esperaba SQLSTATE ${expectedSqlState}, pero PostgreSQL respondió ${error.code}.`,
        {
          cause: error,
        },
      );
    }

    return error;
  }

  throw new Error(
    `Se esperaba que PostgreSQL respondiera con SQLSTATE ${expectedSqlState}, pero la operación fue aceptada.`,
  );
}