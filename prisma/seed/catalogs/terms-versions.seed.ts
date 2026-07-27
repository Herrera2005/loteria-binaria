import { readFile } from "node:fs/promises";
import { resolve } from "node:path";

import type { PrismaClient } from "../../../apps/api/src/generated/prisma/client";

import { BASELINE_SEED_DATE } from "../constants";
import { generateUuidV7 } from "../helpers/generate-uuid-v7";
import { createCanonicalHash } from "../helpers/canonical-hash";

interface TermsDefinition {
  documentType: string;
  version: string;
  filePath: string;
}

const TERMS_DEFINITIONS: readonly TermsDefinition[] = [
  {
    documentType: "TERMS_AND_CONDITIONS",
    version: "1.0.0",
    filePath: "docs/legal/TERMS-v1.0.0.md",
  },
  {
    documentType: "PRIVACY_POLICY",
    version: "1.0.0",
    filePath: "docs/legal/PRIVACY-v1.0.0.md",
  },
];

async function readCanonicalDocument(
  relativePath: string,
): Promise<string> {
  const absolutePath = resolve(
    process.cwd(),
    relativePath,
  );

  const content = await readFile(
    absolutePath,
    "utf8",
  );

  /*
   * Normaliza únicamente finales de línea.
   *
   * No elimina espacios, títulos ni contenido porque
   * cualquier cambio material debe modificar el hash.
   */
  return content.replace(/\r\n/g, "\n");
}

export async function seedTermsVersions(
  prisma: PrismaClient,
): Promise<void> {
  console.info(
    "[seed:terms-versions] Iniciando...",
  );

  let verifiedCount = 0;

  for (const definition of TERMS_DEFINITIONS) {
    const content =
      await readCanonicalDocument(
        definition.filePath,
      );

    const contentHash =
      createCanonicalHash({
        document_type:
          definition.documentType,
        version: definition.version,
        content,
      });

    const existing =
      await prisma.termsVersions.findUnique({
        where: {
          document_type_version: {
            document_type:
              definition.documentType,
            version: definition.version,
          },
        },
      });

    if (!existing) {
      await prisma.termsVersions.create({
        data: {
          id: generateUuidV7(),
          document_type:
            definition.documentType,
          version: definition.version,
          content_hash: contentHash,
          stored_object_id: null,
          effective_at:
            BASELINE_SEED_DATE,
          retired_at: null,
        },
      });

      verifiedCount++;
      continue;
    }

    if (
      existing.content_hash !== contentHash
    ) {
      throw new Error(
        `El documento ${definition.documentType} ` +
          `versión ${definition.version} existe con contenido diferente. ` +
          "No se puede sobrescribir; crea una versión nueva.",
      );
    }

    if (
      existing.effective_at.getTime() !==
      BASELINE_SEED_DATE.getTime()
    ) {
      throw new Error(
        `El documento ${definition.documentType} ` +
          `versión ${definition.version} tiene una fecha efectiva diferente.`,
      );
    }

    if (existing.retired_at !== null) {
      throw new Error(
        `El documento ${definition.documentType} ` +
          `versión ${definition.version} está retirado.`,
      );
    }

    verifiedCount++;
  }

  console.info(
    `[seed:terms-versions] ${verifiedCount} versiones legales verificadas.`,
  );
}
