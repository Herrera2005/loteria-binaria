import type { PrismaClient } from "../../../apps/api/src/generated/prisma/client";

import { generateUuidV7 } from "../helpers/generate-uuid-v7";
import {
  EXPECTED_PERMISSION_COUNT,
  PERMISSION_DEFINITIONS,
} from "./permission-definitions.generated";

const LEGACY_PROVISIONAL_PERMISSION_KEYS = [
  "users.self.read",
  "users.self.update",
  "wallets.self.read",
  "draws.public.read",
] as const;

async function removeLegacyProvisionalPermissions(
  prisma: PrismaClient,
): Promise<void> {
  const legacyPermissions = await prisma.permissions.findMany({
    where: {
      permission_key: {
        in: [...LEGACY_PROVISIONAL_PERMISSION_KEYS],
      },
    },
    select: {
      id: true,
      permission_key: true,
    },
  });

  if (legacyPermissions.length === 0) {
    return;
  }

  const legacyIds = legacyPermissions.map(
    (permission) => permission.id,
  );

  const directGrantCount =
    await prisma.userPermissionGrants.count({
      where: {
        permission_id: {
          in: legacyIds,
        },
      },
    });

  if (directGrantCount > 0) {
    throw new Error(
      "No se pueden retirar los permisos provisionales porque existen concesiones directas que los referencian.",
    );
  }

  await prisma.$transaction(async (tx) => {
    await tx.rolePermissions.deleteMany({
      where: {
        permission_id: {
          in: legacyIds,
        },
      },
    });

    await tx.permissions.deleteMany({
      where: {
        id: {
          in: legacyIds,
        },
      },
    });
  });

  console.info(
    `[seed:permissions] ${legacyPermissions.length} permisos provisionales retirados.`,
  );
}

export async function seedPermissions(
  prisma: PrismaClient,
) {
  console.info("[seed:permissions] Iniciando...");

  if (
    PERMISSION_DEFINITIONS.length !==
    EXPECTED_PERMISSION_COUNT
  ) {
    throw new Error(
      `Se esperaban ${EXPECTED_PERMISSION_COUNT} permisos y se encontraron ${PERMISSION_DEFINITIONS.length}.`,
    );
  }

  const permissionKeys = PERMISSION_DEFINITIONS.map(
    (permission) => permission.permissionKey,
  );

  if (
    new Set(permissionKeys).size !==
    permissionKeys.length
  ) {
    throw new Error(
      "Existen permission_key duplicados en el catálogo.",
    );
  }

  await removeLegacyProvisionalPermissions(prisma);

  const permissions = new Map<
    string,
    Awaited<ReturnType<typeof prisma.permissions.upsert>>
  >();

  for (const definition of PERMISSION_DEFINITIONS) {
    const permission = await prisma.permissions.upsert({
      where: {
        permission_key: definition.permissionKey,
      },
      create: {
        id: generateUuidV7(),
        permission_key: definition.permissionKey,
        resource_type: definition.resourceType,
        action: definition.action,
        description: definition.description,
        is_sensitive: definition.isSensitive,
        is_active: true,
      },
      update: {
        resource_type: definition.resourceType,
        action: definition.action,
        description: definition.description,
        is_sensitive: definition.isSensitive,
        is_active: true,
      },
    });

    permissions.set(
      definition.permissionKey,
      permission,
    );
  }

  console.info(
    `[seed:permissions] ${permissions.size} permisos normativos verificados.`,
  );

  return permissions;
}
