import { existsSync } from 'node:fs';
import { dirname, parse, resolve } from 'node:path';

const ROOT_MARKER = 'pnpm-workspace.yaml';

export function findRepositoryRoot(
  startingDirectory = process.cwd(),
): string {
  let currentDirectory = resolve(startingDirectory);
  const filesystemRoot = parse(currentDirectory).root;

  while (true) {
    if (existsSync(resolve(currentDirectory, ROOT_MARKER))) {
      return currentDirectory;
    }

    if (currentDirectory === filesystemRoot) {
      throw new Error(
        `No se encontró ${ROOT_MARKER} desde ${startingDirectory}.`,
      );
    }

    currentDirectory = dirname(currentDirectory);
  }
}