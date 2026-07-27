# @loteria-binaria/game-engine

Motor matemático puro de la lotería oficial.

## Responsabilidad

- validar Octal, Decimal y Hexadecimal;
- normalizar símbolos y generar claves canónicas;
- verificar símbolos únicos;
- calcular y generar combinaciones posibles;
- comparar boletos y resultados;
- buscar combinaciones compatibles con selección parcial;
- resolver los cuatro modos de selección sin generar azar internamente;
- calcular el límite entero del 20 %;
- calcular, redondear y limitar el instante de liberación al 80 %.

## Prohibiciones

No puede importar Prisma, NestJS, Redis, HTTP, sesiones, `process.env`, relojes
globales ni generadores aleatorios. La API o el worker deben inyectar el instante
y el índice aleatorio seguro para mantener este paquete determinista y fácil de
probar.

## Totales oficiales

| Juego | Fórmula | Total | Límite 20 % |
|---|---:|---:|---:|
| Octal | `C(8,4)` | 70 | 14 |
| Decimal | `C(10,5)` | 252 | 50 |
| Hexadecimal | `C(16,6)` | 8 008 | 1 601 |

## Reglas principales

| Función | Regla |
|---|---|
| `validateOfficialSelection` | `LOT-EVT-003` |
| `normalizeOfficialSelection` / `createNormalizedKey` | `LOT-EVT-004` |
| `calculateGameTwentyPercentLimit` | `LOT-EVT-012` |
| `calculateLimitRelease` | `LOT-EVT-013` |
| `resolveSelectionMode` | `LOT-EVT-015` |
| `compareOfficialResult` | `LOT-PRZ-002` |

## Ejecución

```bash
pnpm --filter @loteria-binaria/game-engine typecheck
pnpm --filter @loteria-binaria/game-engine lint
pnpm --filter @loteria-binaria/game-engine test
pnpm --filter @loteria-binaria/game-engine build
```
