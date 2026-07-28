import { spawn } from 'node:child_process';
import { resolve } from 'node:path';

import { findRepositoryRoot } from './repository-root';

export interface ApplyMigrationsOptions {
  readonly databaseUrl: string;
  readonly repositoryRoot?: string;
}

export async function applyMigrations(
  options: ApplyMigrationsOptions,
): Promise<void> {
  const repositoryRoot =
    options.repositoryRoot ?? findRepositoryRoot();

  const schemaPath = resolve(
    repositoryRoot,
    'prisma',
    'schema.prisma',
  );

  await runCommand(
    'pnpm',
    [
      'exec',
      'prisma',
      'migrate',
      'deploy',
      '--schema',
      schemaPath,
    ],
    repositoryRoot,
    {
      ...process.env,
      NODE_ENV: 'test',
      DATABASE_URL: options.databaseUrl,
    },
  );
}

function runCommand(
  command: string,
  argumentsList: readonly string[],
  workingDirectory: string,
  environment: NodeJS.ProcessEnv,
): Promise<void> {
  return new Promise((resolvePromise, rejectPromise) => {
    const child = spawn(command, [...argumentsList], {
      cwd: workingDirectory,
      env: environment,
      stdio: ['ignore', 'pipe', 'pipe'],
      shell: false,
    });

    let standardOutput = '';
    let standardError = '';

    child.stdout.on('data', (chunk: Buffer) => {
      standardOutput += chunk.toString();
    });

    child.stderr.on('data', (chunk: Buffer) => {
      standardError += chunk.toString();
    });

    child.once('error', (error) => {
      rejectPromise(
        new Error(
          `No se pudo iniciar ${command}: ${error.message}`,
        ),
      );
    });

    child.once('close', (exitCode) => {
      if (exitCode === 0) {
        resolvePromise();
        return;
      }

      rejectPromise(
        new Error(
          [
            `Falló la aplicación de migraciones con código ${String(exitCode)}.`,
            standardOutput.trim(),
            standardError.trim(),
          ]
            .filter(Boolean)
            .join('\n'),
        ),
      );
    });
  });
}