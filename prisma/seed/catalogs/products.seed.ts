import type { PrismaClient } from "../../../apps/api/src/generated/prisma/client";

import { generateUuidV7 } from "../helpers/generate-uuid-v7";

const PRODUCT_DEFINITIONS = [
  {
    code: "OCTAL",
    name: "Lotería Octal",
    description:
      "Producto de lotería basado en símbolos del 0 al 7.",
  },
  {
    code: "DECIMAL",
    name: "Lotería Decimal",
    description:
      "Producto de lotería basado en símbolos del 0 al 9.",
  },
  {
    code: "HEXADECIMAL",
    name: "Lotería Hexadecimal",
    description:
      "Producto de lotería basado en símbolos del 0 al 9 y letras de la A a la F.",
  },
] as const;

export type ProductCode =
  (typeof PRODUCT_DEFINITIONS)[number]["code"];

export async function seedProducts(
  prisma: PrismaClient,
) {
  console.info("[seed:products] Iniciando...");

  const products = new Map<
    ProductCode,
    Awaited<
      ReturnType<
        typeof prisma.lotteryProducts.upsert
      >
    >
  >();

  for (const definition of PRODUCT_DEFINITIONS) {
    const product =
      await prisma.lotteryProducts.upsert({
        where: {
          code: definition.code,
        },

        create: {
          id: generateUuidV7(),
          code: definition.code,
          name: definition.name,
          description: definition.description,
          is_active: true,
        },

        update: {
          name: definition.name,
          description: definition.description,
          is_active: true,
        },
      });

    products.set(definition.code, product);
  }

  console.info(
    `[seed:products] ${products.size} productos verificados.`,
  );

  return products;
}
