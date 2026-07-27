import type { PrismaClient } from "../../../apps/api/src/generated/prisma/client";

import { BASELINE_SEED_DATE } from "../constants";
import type { RoleCode } from "./roles.seed";
import { generateUuidV7 } from "../helpers/generate-uuid-v7";

const ROLE_PERMISSION_MAP: Record<
  RoleCode,
  readonly string[]
> = {
  CLIENTE: [
    "users.self.read",
    "users.self.update",
    "wallets.self.read",
    "draws.public.read",
  ],

  VENDEDOR: [
    "users.self.read",
    "users.self.update",
    "wallets.self.read",
    "draws.public.read",
  ],

  ADMINISTRADOR: [
    "users.self.read",
    "users.self.update",
    "wallets.self.read",
    "draws.public.read",
  ],
};

type RoleRecord = {
  id: string;
};

type PermissionRecord = {
  id: string;
};

export async function seedRolePermissions(
  prisma: PrismaClient,
  roles: Map<RoleCode, RoleRecord>,
  permissions: Map<string, PermissionRecord>,
): Promise<void> {
  console.info("[seed:role-permissions] Iniciando...");

  let relationCount = 0;

  for (const [roleCode, permissionKeys] of Object.entries(
    ROLE_PERMISSION_MAP,
  ) as [RoleCode, readonly string[]][]) {
    const role = roles.get(roleCode);

    if (!role) {
      throw new Error(
        `No se encontró el rol ${roleCode}.`,
      );
    }

    for (const permissionKey of permissionKeys) {
      const permission = permissions.get(permissionKey);

      if (!permission) {
        throw new Error(
          `No se encontró el permiso ${permissionKey}.`,
        );
      }

      await prisma.rolePermissions.upsert({
        where: {
          role_id_permission_id: {
            role_id: role.id,
            permission_id: permission.id,
          },
        },

        create: {
          id: generateUuidV7(),
          role_id: role.id,
          permission_id: permission.id,
          granted_by_user_id: null,
          granted_at: BASELINE_SEED_DATE,
        },

        update: {},
      });

      relationCount++;
    }
  }

  console.info(
    `[seed:role-permissions] ${relationCount} relaciones verificadas.`,
  );
}