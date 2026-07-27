import { spawnSync } from 'node:child_process';
import { existsSync, readdirSync, rmSync } from 'node:fs';
import { createRequire } from 'node:module';
import { join, resolve } from 'node:path';
import process from 'node:process';

const require = createRequire(import.meta.url);
const packageRoot = resolve(import.meta.dirname, '..');
const testOutputDirectory = join(packageRoot, '.test-dist');

function findTestFiles(directory) {
  if (!existsSync(directory)) {
    return [];
  }

  const files = [];

  for (const entry of readdirSync(directory, { withFileTypes: true })) {
    const absolutePath = join(directory, entry.name);

    if (entry.isDirectory()) {
      files.push(...findTestFiles(absolutePath));
      continue;
    }

    if (
      entry.isFile() &&
      (entry.name.endsWith('.spec.js') ||
        entry.name.endsWith('.test.js'))
    ) {
      files.push(absolutePath);
    }
  }

  return files.sort();
}

rmSync(testOutputDirectory, {
  recursive: true,
  force: true,
});

let typescriptCompiler;

try {
  typescriptCompiler = require.resolve('typescript/bin/tsc');
} catch (error) {
  console.error(
    'No fue posible localizar el compilador local de TypeScript.',
    error,
  );
  process.exit(1);
}

const compilation = spawnSync(
  process.execPath,
  [
    typescriptCompiler,
    '-p',
    'tsconfig.test.json',
  ],
  {
    cwd: packageRoot,
    stdio: 'inherit',
  },
);

if (compilation.error) {
  console.error(
    'No fue posible ejecutar TypeScript:',
    compilation.error,
  );
  process.exit(1);
}

if (compilation.status !== 0) {
  process.exit(compilation.status ?? 1);
}

const testFiles = findTestFiles(testOutputDirectory);

if (testFiles.length === 0) {
  console.error(
    'No se encontraron pruebas compiladas en .test-dist.',
  );
  process.exit(1);
}

const testExecution = spawnSync(
  process.execPath,
  [
    '--test',
    ...testFiles,
  ],
  {
    cwd: packageRoot,
    stdio: 'inherit',
  },
);

if (testExecution.error) {
  console.error(
    'No fue posible iniciar el ejecutor de pruebas:',
    testExecution.error,
  );
  process.exit(1);
}

process.exit(testExecution.status ?? 1);
