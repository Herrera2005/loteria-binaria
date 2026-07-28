import { URL } from 'node:url';

const DEVELOPMENT_DATABASE_PORT = '5433';

const LOCAL_TEST_HOSTS = new Set([
  'localhost',
  '127.0.0.1',
  '::1',
]);

export interface TestDatabaseUrls {
  readonly adminUrl: string;
  readonly templateUrl: string;
}

function requireEnvironmentVariable(name: string): string {
  const value = process.env[name]?.trim();

  if (!value) {
    throw new Error(
      `La variable de entorno ${name} es obligatoria para las pruebas PostgreSQL.`,
    );
  }

  return value;
}

function parsePostgresUrl(value: string, variableName: string): URL {
  let parsedUrl: URL;

  try {
    parsedUrl = new URL(value);
  } catch {
    throw new Error(`${variableName} no contiene una URL válida.`);
  }

  if (
    parsedUrl.protocol !== 'postgresql:' &&
    parsedUrl.protocol !== 'postgres:'
  ) {
    throw new Error(
      `${variableName} debe utilizar el protocolo postgresql:// o postgres://.`,
    );
  }

  return parsedUrl;
}

function assertTestEnvironment(): void {
  if (process.env.NODE_ENV !== 'test') {
    throw new Error(
      'Las utilidades PostgreSQL solo pueden ejecutarse con NODE_ENV=test.',
    );
  }
}

function assertSafeTestUrl(value: string, variableName: string): URL {
  const parsedUrl = parsePostgresUrl(value, variableName);
  const databaseName = decodeURIComponent(
    parsedUrl.pathname.replace(/^\/+/, ''),
  ).toLowerCase();

  if (!LOCAL_TEST_HOSTS.has(parsedUrl.hostname)) {
    throw new Error(
      `${variableName} debe apuntar a PostgreSQL local, no a ${parsedUrl.hostname}.`,
    );
  }

  if (parsedUrl.port === DEVELOPMENT_DATABASE_PORT) {
    throw new Error(
      `${variableName} apunta al puerto 5433 de desarrollo. Las pruebas deben utilizar 5434.`,
    );
  }

  if (!databaseName.includes('test') && databaseName !== 'postgres') {
    throw new Error(
      `${variableName} debe apuntar a una base cuyo nombre contenga "test".`,
    );
  }

  return parsedUrl;
}

export function loadTestDatabaseUrls(): TestDatabaseUrls {
  assertTestEnvironment();

  const adminUrl = requireEnvironmentVariable(
    'TEST_DATABASE_ADMIN_URL',
  );

  const templateUrl = requireEnvironmentVariable(
    'TEST_DATABASE_URL',
  );

  const parsedAdminUrl = assertSafeTestUrl(
    adminUrl,
    'TEST_DATABASE_ADMIN_URL',
  );

  const parsedTemplateUrl = assertSafeTestUrl(
    templateUrl,
    'TEST_DATABASE_URL',
  );

  if (parsedAdminUrl.port !== parsedTemplateUrl.port) {
    throw new Error(
      'TEST_DATABASE_ADMIN_URL y TEST_DATABASE_URL deben utilizar el mismo puerto.',
    );
  }

  if (parsedAdminUrl.hostname !== parsedTemplateUrl.hostname) {
    throw new Error(
      'TEST_DATABASE_ADMIN_URL y TEST_DATABASE_URL deben utilizar el mismo servidor.',
    );
  }

  return {
    adminUrl,
    templateUrl,
  };
}

export function replaceDatabaseName(
  databaseUrl: string,
  databaseName: string,
): string {
  if (!/^[a-z][a-z0-9_]{0,62}$/u.test(databaseName)) {
    throw new Error(
      `Nombre de base de pruebas inválido: ${databaseName}`,
    );
  }

  if (!databaseName.includes('test')) {
    throw new Error(
      `La base aislada debe contener "test" en su nombre: ${databaseName}`,
    );
  }

  const parsedUrl = new URL(databaseUrl);
  parsedUrl.pathname = `/${databaseName}`;

  return parsedUrl.toString();
}