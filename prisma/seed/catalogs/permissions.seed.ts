import type { PrismaClient } from "../../../apps/api/src/generated/prisma/client";

import { generateUuidV7 } from "../helpers/generate-uuid-v7";

export interface PermissionDefinition {
  permissionKey: string;
  resourceType: string;
  action: string;
  description: string;
  isSensitive: boolean;
}

const PERMISSION_DEFINITIONS: PermissionDefinition[] = [
  {
    permissionKey: "users.self.read",
    resourceType: "users",
    action: "read_self",
    description: "Consultar el perfil propio.",
    isSensitive: false,
  },
  {
    permissionKey: "users.self.update",
    resourceType: "users",
    action: "update_self",
    description: "Actualizar el perfil propio.",
    isSensitive: false,
  },
  {
    permissionKey: "wallets.self.read",
    resourceType: "wallets",
    action: "read_self",
    description: "Consultar las wallets propias.",
    isSensitive: false,
  },
  {
    permissionKey: "draws.public.read",
    resourceType: "draws",
    action: "read_public",
    description: "Consultar sorteos públicos.",
    isSensitive: false,
  },
];

export async function seedPermissions(
  prisma: PrismaClient,
) {
  console.info("[seed:permissions] Iniciando...");

  const permissionKeys = PERMISSION_DEFINITIONS.map(
    (permission) => permission.permissionKey,
  );

  const uniqueKeys = new Set(permissionKeys);

  if (uniqueKeys.size !== permissionKeys.length) {
    throw new Error(
      "Existen permission_key duplicados en el catálogo.",
    );
  }

  const permissions = new Map<
    string,
    Awaited<ReturnType<typeof prisma.permissions.upsert>>
  >();

  for (const definition of PERMISSION_DEFINITIONS) {
    const permission =
      await prisma.permissions.upsert({
        where: {
          permission_key:
            definition.permissionKey,
        },

        create: {
          id: generateUuidV7(),
          permission_key:
            definition.permissionKey,
          resource_type:
            definition.resourceType,
          action: definition.action,
          description:
            definition.description,
          is_sensitive:
            definition.isSensitive,
          is_active: true,
        },

        update: {
          resource_type:
            definition.resourceType,
          action: definition.action,
          description:
            definition.description,
          is_sensitive:
            definition.isSensitive,
          is_active: true,
        },
      });

    permissions.set(
      definition.permissionKey,
      permission,
    );
  }

  console.info(
    `[seed:permissions] ${permissions.size} permisos verificados.`,
  );

  return permissions;
}
