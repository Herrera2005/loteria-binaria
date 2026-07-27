import { prisma } from "./client";

import { seedPermissions } from "./catalogs/permissions.seed";
import { seedProducts } from "./catalogs/products.seed";
import { seedRolePermissions } from "./catalogs/role-permissions.seed";
import { seedRoles } from "./catalogs/roles.seed";
import { seedRuleVersions } from "./catalogs/rule-versions.seed";

import {
  seedLedgerAccounts,
} from "./platform/ledger-accounts.seed";

import {
  seedFunds,
} from "./platform/funds.seed";

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

  const products =
    await seedProducts(prisma);

  await seedRuleVersions(
    prisma,
    products,
  );

  const platformAccounts =
    await seedLedgerAccounts(
      prisma,
      products,
    );

  await seedFunds(
    prisma,
    products,
    platformAccounts,
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