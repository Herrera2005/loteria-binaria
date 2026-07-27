# @loteria-binaria/money

Aritmética monetaria pura y exacta para Lotería Binaria.

## Responsabilidad

- representar `REAL` y `VIRTUAL` como unidades incompatibles;
- usar exclusivamente `bigint` en minor units;
- impedir montos negativos y overflow de `BIGINT` de PostgreSQL;
- sumar, restar, comparar y multiplicar por enteros de forma segura;
- validar puntos básicos;
- repartir mediante mayores residuos y prioridades deterministas;
- aplicar las políticas 90/10, 95/5 y 50/25/15/10;
- redondear premios públicos a cuartos;
- validar el incremento mayorista de 100 minor units;
- realizar cálculos puros de composición, recomendación y crecimiento de premio.

## Prohibiciones

Este paquete no puede importar NestJS, Prisma, Redis, HTTP, sesiones, variables de
entorno ni repositorios. Tampoco debe escribir asientos contables: solo calcula
valores que posteriormente serán persistidos de forma transaccional por la API o
el worker.

## Unidades

```ts
money('REAL', 100n);    // 1,00 REAL
money('VIRTUAL', 100n); // 1,00 VIRTUAL
```

`number` está prohibido:

```ts
money('REAL', 100); // error de TypeScript y error en runtime si se evade el tipo
```

## Políticas implementadas

| Función | Regla |
|---|---|
| `convertVirtualToReal90_10` | `LOT-FIN-009` |
| `allocateByLargestRemainder` / `allocateBasisPoints` | `LOT-FIN-013` |
| `splitUserDraw95_5` | `LOT-ORG-006` |
| `splitOfficialGrowth90_10` | `LOT-PRZ-005` |
| `roundPublicPrizeToQuarter` | `LOT-PRZ-006` |
| `splitNoWinner50_25_15_10` | `LOT-PRZ-009` |
| `recommendInitialPrizeX5` | `LOT-PRZ-004` |
| `calculateVendorWholesalePurchase` | `LOT-VND-001` |

## Ejecución

```bash
pnpm --filter @loteria-binaria/money typecheck
pnpm --filter @loteria-binaria/money lint
pnpm --filter @loteria-binaria/money test
pnpm --filter @loteria-binaria/money build
```
