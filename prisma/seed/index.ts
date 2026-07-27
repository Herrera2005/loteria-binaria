import { prisma } from "./client";

import { seedRoles } from "./catalogs/roles.seed";
import { seedPermissions } from "./catalogs/permissions.seed";
import { seedRolePermissions } from "./catalogs/role-permissions.seed";

async function main(): Promise<void> {
  console.info("[seed] Iniciando seed...");

  const roles = await seedRoles(prisma);

  const permissions =
    await seedPermissions(prisma);

  await seedRolePermissions(
    prisma,
    roles,
    permissions,
  );

  console.info(
    "[seed] Seed inicial completado correctamente.",
  );
}

main()
  .catch((error: unknown) => {
    console.error("[seed] Error:", error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });