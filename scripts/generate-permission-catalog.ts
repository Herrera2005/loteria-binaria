import { readFile, writeFile } from "node:fs/promises";
import { resolve } from "node:path";

const MATRIX_PATH = resolve(
  "docs/rules/MATRIZ-DE-PERMISOS.md",
);

const OUTPUT_PATH = resolve(
  "prisma/seed/catalogs/permission-definitions.generated.ts",
);

const EXPECTED_PERMISSION_COUNT = 133;

function unwrapCode(value: string): string {
  const trimmed = value.trim();

  return trimmed.startsWith("`") && trimmed.endsWith("`")
    ? trimmed.slice(1, -1)
    : trimmed;
}

function determineDefaultRoles(
  permissionId: string,
  permissionKey: string,
  roleCell: string,
): readonly string[] {
  const roles: string[] = [];

  if (roleCell.includes("CLIENTE")) {
    roles.push("CLIENTE");
  }

  if (roleCell.includes("VENDEDOR")) {
    roles.push("VENDEDOR");
  }

  const requiresDirectAdminGrant =
    permissionId.startsWith("PERM-ADM-") ||
    permissionId.startsWith("PERM-MOD-") ||
    permissionKey === "wallet.projection.repair";

  if (
    roleCell.includes("ADMINISTRADOR") &&
    !requiresDirectAdminGrant
  ) {
    roles.push("ADMINISTRADOR");
  }

  return roles;
}

function determineSensitivity(
  permissionKey: string,
): boolean {
  return !(
    permissionKey.startsWith("public.") ||
    permissionKey === "official.availability.read" ||
    permissionKey === "official.result.animation"
  );
}

function quoted(value: string): string {
  return JSON.stringify(value);
}

async function main(): Promise<void> {
  const markdown = await readFile(MATRIX_PATH, "utf8");

  const definitions = markdown
    .split(/\r?\n/u)
    .filter((line) => line.startsWith("| `PERM-"))
    .map((line) => {
      const cells = line
        .trim()
        .replace(/^\|/u, "")
        .replace(/\|$/u, "")
        .split("|")
        .map((cell) => cell.trim());

      if (cells.length !== 8) {
        throw new Error(
          `Fila de permisos inválida: ${line}`,
        );
      }

      const permissionId = unwrapCode(cells[0]);
      const permissionKey = unwrapCode(cells[1]);
      const description = cells[2].replaceAll(
        "<br>",
        " / ",
      );
      const roleCell = cells[3];
      const segments = permissionKey.split(".");
      const action = segments.pop();

      if (!action || segments.length === 0) {
        throw new Error(
          `Clave de permiso inválida: ${permissionKey}`,
        );
      }

      return {
        permissionId,
        permissionKey,
        resourceType: segments.join("."),
        action,
        description,
        isSensitive:
          determineSensitivity(permissionKey),
        defaultRoles: determineDefaultRoles(
          permissionId,
          permissionKey,
          roleCell,
        ),
      };
    });

  if (
    definitions.length !==
    EXPECTED_PERMISSION_COUNT
  ) {
    throw new Error(
      `Se esperaban ${EXPECTED_PERMISSION_COUNT} permisos y se encontraron ${definitions.length}.`,
    );
  }

  const uniqueKeys = new Set(
    definitions.map(
      (definition) => definition.permissionKey,
    ),
  );

  if (uniqueKeys.size !== definitions.length) {
    throw new Error(
      "La matriz contiene permission_key duplicados.",
    );
  }

  const lines: string[] = [
    'import type { RoleCode } from "./roles.seed";',
    "",
    "export interface PermissionSeedDefinition {",
    "  permissionId: string;",
    "  permissionKey: string;",
    "  resourceType: string;",
    "  action: string;",
    "  description: string;",
    "  isSensitive: boolean;",
    "  defaultRoles: readonly RoleCode[];",
    "}",
    "",
    "/**",
    " * Archivo generado desde docs/rules/MATRIZ-DE-PERMISOS.md v1.1.0.",
    " * No se interpreta Markdown durante db:seed.",
    " */",
    "export const PERMISSION_DEFINITIONS = [",
  ];

  for (const definition of definitions) {
    lines.push("  {");
    lines.push(
      `    permissionId: ${quoted(definition.permissionId)},`,
    );
    lines.push(
      `    permissionKey: ${quoted(definition.permissionKey)},`,
    );
    lines.push(
      `    resourceType: ${quoted(definition.resourceType)},`,
    );
    lines.push(
      `    action: ${quoted(definition.action)},`,
    );
    lines.push(
      `    description: ${quoted(definition.description)},`,
    );
    lines.push(
      `    isSensitive: ${definition.isSensitive},`,
    );
    lines.push(
      `    defaultRoles: [${definition.defaultRoles.map(quoted).join(", ")}],`,
    );
    lines.push("  },");
  }

  lines.push(
    "] as const satisfies readonly PermissionSeedDefinition[];",
    "",
    "export const EXPECTED_PERMISSION_COUNT = 133;",
    "",
    "export const EXPECTED_DEFAULT_ROLE_PERMISSION_COUNTS: Readonly<Record<RoleCode, number>> = {",
    "  CLIENTE: 54,",
    "  VENDEDOR: 47,",
    "  ADMINISTRADOR: 47,",
    "};",
    "",
  );

  await writeFile(
    OUTPUT_PATH,
    `${lines.join("\n")}\n`,
    "utf8",
  );

  console.info(
    `[permissions] ${definitions.length} permisos escritos en ${OUTPUT_PATH}.`,
  );
}

main().catch((error: unknown) => {
  console.error(error);
  process.exitCode = 1;
});
