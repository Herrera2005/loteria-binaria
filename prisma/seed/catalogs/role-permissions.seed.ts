import type { PrismaClient } from "../../../apps/api/src/generated/prisma/client";

import { BASELINE_SEED_DATE } from "../constants";
import { generateUuidV7 } from "../helpers/generate-uuid-v7";
import {
  EXPECTED_DEFAULT_ROLE_PERMISSION_COUNTS,
  PERMISSION_DEFINITIONS,
} from "./permission-definitions.generated";
import type { RoleCode } from "./roles.seed";

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
  console.info(
    "[seed:role-permissions] Iniciando...",
  );

  const expectedPairs = PERMISSION_DEFINITIONS.flatMap(
    (definition) =>
      definition.defaultRoles.map((roleCode) => ({
        roleCode,
        permissionKey: definition.permissionKey,
      })),
  );

  const actualCounts: Record<RoleCode, number> = {
    CLIENTE: 0,
    VENDEDOR: 0,
    ADMINISTRADOR: 0,
  };

  for (const pair of expectedPairs) {
    actualCounts[pair.roleCode]++;
  }

  for (const roleCode of Object.keys(
    EXPECTED_DEFAULT_ROLE_PERMISSION_COUNTS,
  ) as RoleCode[]) {
    const expected =
      EXPECTED_DEFAULT_ROLE_PERMISSION_COUNTS[roleCode];
    const actual = actualCounts[roleCode];

    if (actual !== expected) {
      throw new Error(
        `El rol ${roleCode} esperaba ${expected} permisos predeterminados y recibió ${actual}.`,
      );
    }
  }

  for (const { roleCode, permissionKey } of expectedPairs) {
    const role = roles.get(roleCode);
    const permission = permissions.get(permissionKey);

    if (!role) {
      throw new Error(
        `No se encontró el rol ${roleCode}.`,
      );
    }

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
  }

  // Elimina únicamente relaciones predeterminadas que ya no forman parte
  // de la baseline generada. No toca concesiones directas de administradores.
  for (const [roleCode, role] of roles) {
    const expectedPermissionIds = expectedPairs
      .filter((pair) => pair.roleCode === roleCode)
      .map((pair) => permissions.get(pair.permissionKey)?.id)
      .filter((id): id is string => Boolean(id));

    await prisma.rolePermissions.deleteMany({
      where: {
        role_id: role.id,
        permission_id: {
          notIn: expectedPermissionIds,
        },
        granted_by_user_id: null,
      },
    });
  }

  console.info(
    `[seed:role-permissions] ${expectedPairs.length} relaciones normativas verificadas.`,
  );
}
