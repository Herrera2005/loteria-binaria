import type { PrismaClient } from "../../../apps/api/src/generated/prisma/client";

import { generateUuidV7 } from "../helpers/generate-uuid-v7";

const ROLE_DEFINITIONS = [
  {
    code: "CLIENTE",
    name: "Cliente",
    description:
      "Usuario que participa en sorteos y utiliza las funciones financieras permitidas.",
  },
  {
    code: "VENDEDOR",
    name: "Vendedor",
    description:
      "Usuario autorizado para atender conversiones y operar como vendedor.",
  },
  {
    code: "ADMINISTRADOR",
    name: "Administrador",
    description:
      "Usuario con acceso administrativo controlado mediante permisos.",
  },
] as const;

export type RoleCode =
  (typeof ROLE_DEFINITIONS)[number]["code"];

export async function seedRoles(prisma: PrismaClient) {
  console.info("[seed:roles] Iniciando...");

  const roles = new Map<
    RoleCode,
    Awaited<ReturnType<typeof prisma.roles.upsert>>
  >();

  for (const definition of ROLE_DEFINITIONS) {
    const role = await prisma.roles.upsert({
      where: {
        code: definition.code,
      },

      create: {
        id: generateUuidV7(),
        code: definition.code,
        name: definition.name,
        description: definition.description,
        is_system: true,
        is_active: true,
      },

      update: {
        name: definition.name,
        description: definition.description,
        is_system: true,
        is_active: true,
      },
    });

    roles.set(definition.code, role);
  }

  console.info(
    `[seed:roles] ${roles.size} roles verificados.`,
  );

  return roles;
}