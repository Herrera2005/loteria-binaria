---
title: "Matriz Regla → Prueba — Lotería Binaria"
version: "1.0.0"
status: "APROBADA COMO ESPECIFICACIÓN; IMPLEMENTACIÓN Y EJECUCIÓN PENDIENTES"
author: "Cristhian Herrera Nieto"
date: "2026-07-26"
repository: "Herrera2005/loteria-binaria"
normative_rules: "REGLAS-NEGOCIO.md v1.4.0"
state_model: "ESTADOS-Y-TRANSICIONES.md v1.1.0"
financial_model: "FLUJOS-FINANCIEROS.md v1.1.0"
permission_model: "MATRIZ-DE-PERMISOS.md v1.1.0"
data_dictionary: "DICCIONARIO-DE-DATOS.md v1.1.0"
database_target: "PostgreSQL 16"
---

# MATRIZ REGLA → PRUEBA — LOTERÍA BINARIA

**Versión:** 1.0.0  
**Estado documental:** **APROBADA**  
**Estado de implementación:** **PENDIENTE**  
**Ruta objetivo:** `docs/MATRIZ-REGLA-PRUEBA.md`  
**Archivo procesable:** `docs/MATRIZ-REGLA-PRUEBA.csv`

> [!WARNING]
> La matriz especifica pruebas obligatorias, pero no afirma que las pruebas ya estén programadas o ejecutadas. Una regla pasa a `IMPLEMENTADA` únicamente cuando existe código, migración/restricción cuando aplica y prueba automatizada aprobada contra la infraestructura correspondiente.

## 0. Propósito

Esta matriz cumple `LOT-AUD-008` y enlaza cada una de las **112 reglas activas** con:

```text
regla
→ prueba primaria
→ módulo
→ comando, consulta o job
→ servicio lógico
→ tabla/restricción PostgreSQL
→ nivel de prueba
→ escenario normativo
→ resultado esperado
→ estado de implementación
```

`LOT-ORG-005` no aparece porque es un identificador reservado y no una regla activa. `LOT-ORG-026` sí aparece mediante una prueba negativa que demuestra que la verificación automática con cédula no existe en el MVP.

## 0.1 Autoridad

La columna **Escenario mínimo** conserva la prueba definida por `REGLAS-NEGOCIO.md`. Los nombres de servicios, comandos, jobs y archivos son el diseño técnico aprobado por esta matriz para organizar la implementación; los URL HTTP definitivos se documentarán posteriormente en OpenAPI sin cambiar el propósito de la prueba.

## 0.2 Estados

| Estado | Significado |
|---|---|
| `DISEÑADA` | La prueba tiene regla, escenario, resultado, capa y destino definidos. |
| `PENDIENTE_IMPLEMENTACION` | El archivo/caso todavía no existe o no ha sido aprobado. |
| `IMPLEMENTADA` | La prueba existe y referencia su `LOT-*`. |
| `EJECUTADA_OK` | Pasó en CI contra el entorno exigido. |
| `BLOQUEADA` | Falta migración, endpoint, job o decisión técnica no funcional. |

El archivo nace con las 112 especificaciones en `DISEÑADA / PENDIENTE_IMPLEMENTACION`.

# 1. Estrategia de pruebas para PostgreSQL

## 1.1 Regla de infraestructura

Las pruebas marcadas con `PG`, `PG-INTEGRATION` o `PG-CONCURRENCY` deben ejecutarse contra **PostgreSQL real**. No se aceptan SQLite, bases en memoria ni mocks para demostrar:

- claves `UNIQUE`;
- FKs y `CHECK`;
- índices parciales;
- triggers diferidos;
- transacciones y rollback;
- `SELECT ... FOR UPDATE`;
- niveles de aislamiento;
- concurrencia;
- inmutabilidad;
- doble entrada;
- idempotencia;
- hora oficial.

## 1.2 Entorno de suite

Cada ejecución deberá:

1. Crear una base o esquema aislado.
2. Aplicar todas las migraciones desde cero.
3. Ejecutar seeds mínimos deterministas.
4. Abrir conexiones PostgreSQL independientes para pruebas concurrentes.
5. Confirmar el estado persistido después de `COMMIT` y después de reinicios.
6. Limpiar el entorno sin reutilizar estado entre casos.
7. Guardar `correlation_id`, `idempotency_key` y referencias del ledger en los reportes de fallo.

## 1.3 Niveles

| Código | Objetivo |
|---|---|
| `UNIT-MONEY` / `UNIT-PROPERTY` | Fórmulas enteras, tasas, residuos y propiedades matemáticas. |
| `UNIT-GAME` | Combinaciones, normalización, búsqueda y tiempo puro. |
| `PG-INTEGRATION` | FKs, checks, triggers, transacciones, vistas y persistencia. |
| `PG-CONCURRENCY` | Dos o más conexiones reales compitiendo por el mismo recurso. |
| `API-E2E` | Autenticación, autorización, DTO, caso de uso y efecto persistido. |
| `WORKER-PG` | Job persistente, reintento, reinicio e idempotencia con PostgreSQL. |
| `SECURITY-E2E` | Manipulación, privacidad, rate limit y redacción. |
| `CI-MIGRATION` | Integridad y repetibilidad de migraciones. |
| `CI-TRACEABILITY` | Cobertura automática regla→prueba. |
| `SCHEMA` / `CONFIG-E2E` | Estructura o configuración sin operación financiera real. |

## 1.4 Convención obligatoria en el test

Cada caso debe incluir el identificador exacto:

```ts
describe("[LOT-EVT-001] unicidad de combinación por evento", () => {
  it("confirma una sola compra bajo concurrencia real", async () => {
    // ...
  });
});
```

Metadatos mínimos del archivo:

```text
@rule LOT-...
@test TST-...
@tables ...
@level ...
```

# 2. Estructura prevista

```text
apps/api/test/rules/
apps/api/test/postgres/rules/
apps/api/test/postgres/concurrency/
apps/api/test/security/rules/
apps/worker/test/rules/
packages/money/src/__tests__/rules/
packages/game-engine/src/__tests__/rules/
scripts/tests/rules/
```

La ubicación exacta puede ajustarse durante la configuración del repositorio, pero el `rule_id`, `test_id`, escenario y resultado no pueden perderse.

# 3. Resumen de cobertura

| Dominio | Reglas | Pruebas primarias |
|---|---:|---:|
| `GOV` | 8 | 8 |
| `IAM` | 9 | 9 |
| `FIN` | 13 | 13 |
| `VND` | 10 | 10 |
| `EVT` | 20 | 20 |
| `PRZ` | 18 | 18 |
| `ORG` | 25 | 25 |
| `AUD` | 9 | 9 |
| **Total** | **112** | **112** |

- Prioridad `P0`: **108**.
- Prioridad `P1`: **4**.
- Reglas sin prueba primaria: **0**.
- IDs de prueba duplicados: **0**.
- Rutas de prueba duplicadas: **0**.
- Estado inicial de ejecución: **112 pendientes de implementación**.

# 4. Matriz canónica

> Las tablas se dividen por dominio para mantener legibilidad. `PostgreSQL/control` señala el objeto o garantía que deberá comprobarse cuando exista la migración.

## 4.1 `GOV`

| Regla / test | Pri. | Módulo | Entrada / servicio | PostgreSQL / control | Nivel / archivo | Escenario mínimo | Resultado esperado | Estado |
|---|---:|---|---|---|---|---|---|---|
| `LOT-GOV-001`<br>`TST-GOV-001` | P0 | platform / authorization | **Todos los comandos y consultas sensibles**<br>AuthorizationPolicy + servicios de dominio | sessions, roles, permissions y lectura autoritativa del recurso; el body no controla role, mode, balance ni status | `API-E2E + PG`<br>`apps/api/test/postgres/rules/gov/lot-gov-001.pg-spec.ts` | Alterar rol, saldo, hora o estado desde web/móvil y enviar la petición. | La API ignora los datos manipulados y responde con el estado autoritativo o un error de dominio. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-GOV-002`<br>`TST-GOV-002` | P0 | platform / persistence | **Reinicio API/worker + reconciliación**<br>LedgerReconciliationService | ledger_transactions, ledger_entries, wallet_balance_projections, tickets, draw_results, scheduled_jobs | `WORKER-PG + RESILIENCIA`<br>`apps/worker/test/rules/gov/lot-gov-002.e2e-spec.ts` | Vaciar Redis y reiniciar API/worker después de operaciones confirmadas. | Saldos, boletos, solicitudes, resultados y pagos permanecen íntegros y reconstruibles. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-GOV-003`<br>`TST-GOV-003` | P0 | platform / idempotency | **Repetición paralela de comando crítico**<br>IdempotencyService | idempotency_keys, request_hash, UNIQUE de efectos de negocio y transacción SQL | `PG-CONCURRENCY + API-E2E`<br>`apps/api/test/postgres/concurrency/lot-gov-003.pg-spec.ts` | Enviar la misma petición en paralelo y repetirla después de un timeout. | Existe un único efecto económico y todas las respuestas posteriores refieren al mismo resultado. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-GOV-004`<br>`TST-GOV-004` | P0 | platform / history | **UPDATE/DELETE directo + comando compensatorio**<br>ImmutabilityPolicy | triggers/permisos sobre ledger, tickets, snapshots, results, reports y audit_events | `PG-INTEGRATION`<br>`apps/api/test/postgres/rules/gov/lot-gov-004.pg-spec.ts` | Intentar editar un asiento confirmado, boleto pagado o resultado fijado. | La modificación directa se rechaza; solo se permite una corrección trazable separada. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-GOV-005`<br>`TST-GOV-005` | P0 | platform / time | **Comandos con reloj del dispositivo manipulado**<br>ServerClockPolicy | TIMESTAMPTZ, NOW()/clock_timestamp(), checks de apertura/cierre/expiración | `API-E2E + PG`<br>`apps/api/test/postgres/rules/gov/lot-gov-005.pg-spec.ts` | Cambiar la hora del dispositivo durante una reserva o cierre. | La expiración y el cierre no cambian por la hora local manipulada. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-GOV-006`<br>`TST-GOV-006` | P0 | packages/money | **Suite de precisión monetaria**<br>MoneyValue + LedgerMath | BIGINT para *_minor; inspección del esquema sin float/double | `UNIT-PROPERTY + SCHEMA`<br>`packages/money/src/__tests__/rules/lot-gov-006.spec.ts` | Procesar muchas operaciones con fracciones y comparar libro contra proyección. | No aparecen errores acumulativos de punto flotante y el balance exacto se conserva. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-GOV-007`<br>`TST-GOV-007` | P0 | lottery-rules | **Actualizar versión ya utilizada**<br>RuleVersionService | rule_versions, prize_rule_versions y FKs históricas desde eventos/boletos | `PG-INTEGRATION`<br>`apps/api/test/postgres/rules/gov/lot-gov-007.pg-spec.ts` | Modificar una versión ligada a boletos y consultar un evento anterior. | La edición se rechaza o crea una versión nueva; el evento histórico conserva la original. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-GOV-008`<br>`TST-GOV-008` | P1 | platform / environment | **Arranque en entorno académico y flujos simulados**<br>EnvironmentPolicy | system_settings/provider_type=SIMULATED; ausencia de credenciales o entidades de tarjeta | `CONFIG-E2E`<br>`scripts/tests/rules/lot-gov-008.spec.mjs` | Ejecutar el entorno local y revisar flujos de pago/retiro. | El sistema identifica el modo simulado y no procesa tarjetas ni retiros reales. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |

## 4.2 `IAM`

| Regla / test | Pri. | Módulo | Entrada / servicio | PostgreSQL / control | Nivel / archivo | Escenario mínimo | Resultado esperado | Estado |
|---|---:|---|---|---|---|---|---|---|
| `LOT-IAM-001`<br>`TST-IAM-001` | P0 | identity + user-draws | **Command: CreateUserDraw**<br>UserDrawCreationService | roles sin ORGANIZADOR; user_draws.organizer_user_id FK users | `API-E2E + PG`<br>`apps/api/test/postgres/rules/iam/lot-iam-001.pg-spec.ts` | Crear un sorteo de usuario con una cuenta activa sin rol global adicional. | La cuenta queda como organizadora de ese sorteo sin recibir privilegios de Administrador. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-IAM-002`<br>`TST-IAM-002` | P0 | auth / authorization | **Command: ChangeActiveMode + comando protegido**<br>SessionModeService + AuthorizationService | sessions.active_mode, user_roles, role_permissions, user_permission_grants | `API-E2E + PG`<br>`apps/api/test/postgres/rules/iam/lot-iam-002.pg-spec.ts` | Iniciar como Vendedor y llamar un endpoint de compra de boletos. | La compra se rechaza aunque la cuenta también tenga operaciones de wallet. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-IAM-003`<br>`TST-IAM-003` | P0 | client | **Suite de operaciones de Cliente por estado**<br>ClientAuthorizationPolicy | users.status, wallets, conversion_requests, purchase_orders, virtual_transfers | `API-E2E`<br>`apps/api/test/rules/iam/lot-iam-003.e2e-spec.ts` | Ejecutar cada operación con Cliente activo y luego suspendido. | El activo opera dentro de reglas; el suspendido recibe rechazo sin efectos. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-IAM-004`<br>`TST-IAM-004` | P0 | official-purchases | **Command: ConfirmOfficialPurchase con Vendedor**<br>OfficialParticipationPolicy | restricción de autorización antes de combination_reservations, purchase_orders, ledger y tickets | `API-E2E + PG`<br>`apps/api/test/postgres/rules/iam/lot-iam-004.pg-spec.ts` | Intentar comprar con una sesión de Vendedor. | La API responde FORBIDDEN y no crea reserva, orden, asiento ni boleto. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-IAM-005`<br>`TST-IAM-005` | P0 | admin / authorization | **Comandos administrativos reforzados**<br>AdminAuthorizationService | permissions, role_permissions, user_permission_grants, audit_events, security_events | `API-E2E + PG`<br>`apps/api/test/postgres/rules/iam/lot-iam-005.pg-spec.ts` | Administrador sin permiso intenta aportar fondos o resolver reclamo. | La acción se rechaza y se registra el intento de seguridad cuando corresponda. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-IAM-006`<br>`TST-IAM-006` | P0 | auth / routing | **Acceso directo a contrato administrativo**<br>GlobalAuthorizationGuard | sin cambios en recursos; sessions.active_mode permanece autoritativo | `SECURITY-E2E`<br>`apps/api/test/security/rules/lot-iam-006.e2e-spec.ts` | Abrir manualmente una ruta administrativa con sesión de Cliente. | No se expone información ni se ejecuta la acción. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-IAM-007`<br>`TST-IAM-007` | P0 | identity | **Command: RegisterUser**<br>RegistrationService | users(email,username), user_profiles(document_hash), terms_versions, terms_acceptances; UNIQUE y mayoría de edad | `API-E2E + PG`<br>`apps/api/test/postgres/rules/iam/lot-iam-007.pg-spec.ts` | Registrar dos cuentas con el mismo documento o sin aceptación. | Solo la primera válida se crea; las demás se rechazan con error específico. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-IAM-008`<br>`TST-IAM-008` | P0 | identity | **Operaciones nuevas con cada account_status**<br>AccountStatePolicy | users.status CHECK/enum y guardia común | `API-E2E + PG`<br>`apps/api/test/postgres/rules/iam/lot-iam-008.pg-spec.ts` | Intentar comprar, convertir o crear sorteo con cada estado. | Solo ACTIVO puede comenzar la operación; el historial sigue consultable según permisos. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-IAM-009`<br>`TST-IAM-009` | P0 | identity / retention | **Command: DeactivateOrAnonymizeUser**<br>AccountRetentionService | users.status/deactivated_at; FKs RESTRICT; ledger/tickets/user_draws/claims conservados | `PG-INTEGRATION`<br>`apps/api/test/postgres/rules/iam/lot-iam-009.pg-spec.ts` | Solicitar eliminación de un usuario con asientos y boletos. | Los registros históricos permanecen íntegros y la cuenta deja de operar. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |

## 4.3 `FIN`

| Regla / test | Pri. | Módulo | Entrada / servicio | PostgreSQL / control | Nivel / archivo | Escenario mínimo | Resultado esperado | Estado |
|---|---:|---|---|---|---|---|---|---|
| `LOT-FIN-001`<br>`TST-FIN-001` | P0 | ledger | **PostLedgerTransaction con monedas cruzadas**<br>LedgerPostingService | wallets.currency, ledger_accounts.currency, ledger_entries.currency y trigger de balance por unidad | `PG-INTEGRATION`<br>`apps/api/test/postgres/rules/fin/lot-fin-001.pg-spec.ts` | Intentar balancear un débito REAL con un crédito VIRTUAL. | La transacción contable se rechaza. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-FIN-002`<br>`TST-FIN-002` | P0 | official-finance | **Crear boleto/premio con cuenta REAL**<br>OfficialCurrencyPolicy | event_financial_configs, tickets, prize_awards y ledger_accounts deben usar VIRTUAL | `API-E2E + PG`<br>`apps/api/test/postgres/rules/fin/lot-fin-002.pg-spec.ts` | Crear boleto o premio en REAL. | La operación se rechaza antes de generar asientos. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-FIN-003`<br>`TST-FIN-003` | P0 | transfers | **Command: TransferRealBetweenUsers**<br>TransferPolicy | no existe flujo de virtual_transfers con REAL; ledger no se crea | `API-E2E`<br>`apps/api/test/rules/fin/lot-fin-003.e2e-spec.ts` | Intentar una transferencia REAL directa entre clientes. | La API la rechaza y sugiere el flujo permitido sin mover saldo. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-FIN-004`<br>`TST-FIN-004` | P0 | user-draw-finance | **Command: BuyUserDrawParticipation usando REAL**<br>UserDrawPaymentService | user_draw_participations, user_draw_escrows y cuentas ledger solo VIRTUAL | `API-E2E + PG`<br>`apps/api/test/postgres/rules/fin/lot-fin-004.pg-spec.ts` | Intentar pagar participación de sorteo de usuario con REAL. | La operación se rechaza sin reservar ni mover saldo. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-FIN-005`<br>`TST-FIN-005` | P0 | ledger | **Insertar/cerrar transacción desbalanceada**<br>LedgerPostingService | trigger/procedimiento diferido ledger_balanced por ledger_transaction_id y currency | `PG-INTEGRATION`<br>`apps/api/test/postgres/rules/fin/lot-fin-005.pg-spec.ts` | Insertar una transacción desbalanceada. | No puede confirmarse. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-FIN-006`<br>`TST-FIN-006` | P0 | wallets | **Job: ledger-reconcile**<br>WalletReconciliationService | wallet_balance_projections reconstruidas desde ledger_entries sin nueva transacción | `WORKER-PG`<br>`apps/worker/test/rules/fin/lot-fin-006.e2e-spec.ts` | Dañar intencionalmente una proyección y ejecutar reconciliación. | La proyección se corrige desde el libro sin crear un nuevo movimiento. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-FIN-007`<br>`TST-FIN-007` | P0 | ledger / balances | **Dos débitos concurrentes sobre el mismo disponible**<br>BalanceGuard | locks PostgreSQL, proyección/cuentas y validación de saldo; no negativos no autorizados | `PG-CONCURRENCY`<br>`apps/api/test/postgres/concurrency/lot-fin-007.pg-spec.ts` | Ejecutar dos débitos simultáneos que superan el disponible. | Solo uno se confirma o ambos se rechazan; nunca queda saldo no autorizado negativo. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-FIN-008`<br>`TST-FIN-008` | P0 | topups | **Command: ConfirmSimulatedTopup**<br>TopupService | real_topups, idempotency_keys, ledger_transaction y asientos REAL 1:1 | `API-E2E + PG`<br>`apps/api/test/postgres/rules/fin/lot-fin-008.pg-spec.ts` | Simular recarga de 100,00. | Se acreditan 100,00 REAL y comisión 0,00. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-FIN-009`<br>`TST-FIN-009` | P0 | conversions | **Command: ConvertVirtualToReal**<br>VirtualToRealConversionService | virtual_to_real_conversions, fee_rate_bps, ledger REAL/VIRTUAL y cuentas de comisión | `UNIT-MONEY + PG`<br>`packages/money/src/__tests__/rules/lot-fin-009.spec.ts` | Convertir 500,00 VIRTUAL. | Se debitan 500,00 VIRTUAL, se acreditan 450,00 REAL y 50,00 se registran como comisión. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-FIN-010`<br>`TST-FIN-010` | P0 | withdrawals | **Command: Request/CompleteWithdrawal**<br>WithdrawalService | withdrawal_requests y ledger sin segundo asiento de comisión | `API-E2E + PG`<br>`apps/api/test/postgres/rules/fin/lot-fin-010.pg-spec.ts` | Solicitar retiro de REAL ya convertido. | El retiro no descuenta otra comisión de negocio. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-FIN-011`<br>`TST-FIN-011` | P0 | transfers | **Command: TransferVirtual**<br>VirtualTransferService | virtual_transfers, usuarios activos, sender<>recipient y ledger VIRTUAL | `API-E2E + PG`<br>`apps/api/test/postgres/rules/fin/lot-fin-011.pg-spec.ts` | Transferir a sí mismo y transferir a otro Cliente activo. | La primera se rechaza; la segunda crea movimientos simétricos y comprobante. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-FIN-012`<br>`TST-FIN-012` | P0 | ledger / traceability | **Suite de operaciones financieras confirmadas**<br>FinancialTraceabilityService | FK ledger_transaction_id/idempotency/correlation en cada agregado financiero | `PG-INTEGRATION`<br>`apps/api/test/postgres/rules/fin/lot-fin-012.pg-spec.ts` | Confirmar cada tipo de operación y buscar su evidencia contable. | Cada operación tiene asientos balanceados y correlación trazable. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-FIN-013`<br>`TST-FIN-013` | P0 | packages/money | **Suite property-based de reparto de minor units**<br>LargestRemainderAllocator | tasas versionadas y montos *_minor; compra mayorista en múltiplos de 100 minor units VIRTUAL | `UNIT-PROPERTY + PG`<br>`packages/money/src/__tests__/rules/lot-fin-013.spec.ts` | Probar importes de 0,01 a 10,00, empates de residuos, reparto 50/25/15/10 y una compra mayorista no múltiplo de 1,00. | Ninguna minor unit se crea, desaparece o asigna de forma ambigua; los repartos suman exactamente el monto base y la orden mayorista inválida se rechaza. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |

## 4.4 `VND`

| Regla / test | Pri. | Módulo | Entrada / servicio | PostgreSQL / control | Nivel / archivo | Escenario mínimo | Resultado esperado | Estado |
|---|---:|---|---|---|---|---|---|---|
| `LOT-VND-001`<br>`TST-VND-001` | P0 | vendors / inventory | **Command: PurchaseVendorInventory**<br>VendorInventoryPurchaseService | vendor_purchase_orders, vendor_inventory_batches, ledger y tasa 90/100 | `API-E2E + PG`<br>`apps/api/test/postgres/rules/vnd/lot-vnd-001.pg-spec.ts` | Comprar 100,00 VIRTUAL con saldo suficiente. | Se debitan 90,00 REAL y se acreditan 100,00 VIRTUAL una sola vez. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-VND-002`<br>`TST-VND-002` | P0 | vendors / profitability | **Query: VendorMetrics antes/después de venta**<br>VendorProfitService | vendor_inventory_batches, vendor_sales, vendor_sale_batch_allocations | `PG-INTEGRATION`<br>`apps/api/test/postgres/rules/vnd/lot-vnd-002.pg-spec.ts` | Comprar inventario y revisar métricas antes y después de una venta. | Antes de vender la ganancia realizada es 0; después refleja 0,10 por cada 1,00 vendido. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-VND-003`<br>`TST-VND-003` | P0 | conversion-requests | **Command: CreateConversionRequest**<br>ConversionRequestService | conversion_requests y reserva REAL en ledger; no crédito VIRTUAL inmediato | `API-E2E + PG`<br>`apps/api/test/postgres/rules/vnd/lot-vnd-003.pg-spec.ts` | Crear solicitud con saldo suficiente e insuficiente. | La válida reserva exactamente el monto; la insuficiente no crea solicitud ni reserva. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-VND-004`<br>`TST-VND-004` | P0 | conversion-requests | **Query: ListEligibleRequests**<br>ConversionRequestVisibilityPolicy | vendor_profiles, wallet projections, related_account_flags y estado PENDIENTE | `API-E2E + PG`<br>`apps/api/test/postgres/rules/vnd/lot-vnd-004.pg-spec.ts` | Comparar visibilidad para vendedor solvente, insolvente, inactivo y relacionado. | Solo el vendedor solvente, activo y no relacionado la recibe. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-VND-005`<br>`TST-VND-005` | P0 | conversion-requests | **Command: AssignRequest por dos vendedores**<br>ConversionAssignmentService | conversion_assignments con índice único parcial ACTIVA + SELECT FOR UPDATE | `PG-CONCURRENCY`<br>`apps/api/test/postgres/concurrency/lot-vnd-005.pg-spec.ts` | Dos vendedores toman simultáneamente la misma solicitud. | Solo uno recibe la asignación; el otro obtiene no disponible. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-VND-006`<br>`TST-VND-006` | P0 | conversion-requests | **Asignar a los 4m50s**<br>ConversionDeadlinePolicy | conversion_requests.expires_at inmutable; assignment no modifica deadline | `API-E2E + PG`<br>`apps/api/test/postgres/rules/vnd/lot-vnd-006.pg-spec.ts` | Tomar la solicitud a los 4 minutos 50 segundos. | Solo quedan 10 segundos; no se extiende el vencimiento. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-VND-007`<br>`TST-VND-007` | P0 | conversion-requests | **Command: CompleteByVendor con fallo inyectado**<br>VendorConversionCompletionService | request, wallets/cuentas, ledger, vendor_sales y allocations en una transacción | `PG-INTEGRATION`<br>`apps/api/test/postgres/rules/vnd/lot-vnd-007.pg-spec.ts` | Forzar error después del primer asiento. | Toda la operación revierte; no queda transferencia parcial. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-VND-008`<br>`TST-VND-008` | P0 | conversion-requests | **Command: ReleaseVendorAssignment**<br>ConversionAssignmentService | conversion_assignments, conversion_request_events y request vuelve a PENDIENTE sin liberar REAL | `API-E2E + PG`<br>`apps/api/test/postgres/rules/vnd/lot-vnd-008.pg-spec.ts` | Cancelar una asignación vigente. | Otro vendedor puede tomarla y el saldo del cliente continúa reservado. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-VND-009`<br>`TST-VND-009` | P0 | conversion-requests | **Job: conversion-request-expire-or-fallback**<br>ConversionFallbackJob | scheduled_jobs, conversion_requests, GENERAL_CONVERSION_WALLET y ledger | `WORKER-PG`<br>`apps/worker/test/rules/vnd/lot-vnd-009.e2e-spec.ts` | Dejar vencer una solicitud sin vendedor. | Se acredita VIRTUAL al cliente, REAL a plataforma y estado COMPLETADA_POR_PLATAFORMA. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-VND-010`<br>`TST-VND-010` | P0 | conversion-requests | **Carrera CompleteByVendor vs fallback + falta de liquidez**<br>ConversionFinalizationService | lock/estado terminal único, completion ledger UQ y liberación REAL por fallo | `PG-CONCURRENCY + WORKER`<br>`apps/worker/test/rules/vnd/lot-vnd-010.e2e-spec.ts` | Ejecutar ambos procesos simultáneamente y luego simular wallet general insuficiente. | En la carrera solo uno confirma; en falta de liquidez no queda saldo bloqueado y se genera alerta. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |

## 4.5 `EVT`

| Regla / test | Pri. | Módulo | Entrada / servicio | PostgreSQL / control | Nivel / archivo | Escenario mínimo | Resultado esperado | Estado |
|---|---:|---|---|---|---|---|---|---|
| `LOT-EVT-001`<br>`TST-EVT-001` | P0 | combinations / purchases | **Dos ConfirmOfficialPurchase para la misma combinación**<br>PurchaseConfirmationService | UNIQUE(draw_event_id,normalized_key) en event_combinations y tickets | `PG-CONCURRENCY`<br>`apps/api/test/postgres/concurrency/lot-evt-001.pg-spec.ts` | Dos compras simultáneas de la misma combinación en un evento y otra compra en evento diferente. | En el mismo evento solo una confirma; en el otro evento puede venderse. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-EVT-002`<br>`TST-EVT-002` | P0 | lottery-products | **Command: CreateDrawEvent con producto inválido**<br>DrawEventCreationService | lottery_products y FK de draw_events/rule_versions | `API-E2E + PG`<br>`apps/api/test/postgres/rules/evt/lot-evt-002.pg-spec.ts` | Crear evento con producto inexistente. | Solo se aceptan productos registrados y compatibles. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-EVT-003`<br>`TST-EVT-003` | P0 | game-engine | **ValidateOfficialSelection**<br>OfficialCombinationValidator | rule_versions(selection_count,universe_symbols) y combination_numbers | `UNIT-GAME + PG`<br>`packages/game-engine/src/__tests__/rules/lot-evt-003.spec.ts` | Enviar selecciones cortas, largas, repetidas y fuera de universo. | Todas se rechazan; solo la selección exacta y única es válida. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-EVT-004`<br>`TST-EVT-004` | P0 | game-engine / combinations | **NormalizeAndReserveSelection**<br>CombinationNormalizer | normalized_key canónico + UNIQUE por evento | `UNIT-GAME + PG-CONCURRENCY`<br>`packages/game-engine/src/__tests__/rules/lot-evt-004.spec.ts` | Comprar 7-4-2-0 y luego 0-2-4-7 en el mismo evento. | Ambas producen la misma clave; solo una puede confirmarse. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-EVT-005`<br>`TST-EVT-005` | P0 | combinations | **Transición VENDIDA→DISPONIBLE no autorizada**<br>CombinationStateService | combination_status, history y trigger/guardia de transición | `PG-INTEGRATION`<br>`apps/api/test/postgres/rules/evt/lot-evt-005.pg-spec.ts` | Intentar pasar de VENDIDA a DISPONIBLE sin reembolso/corrección autorizada. | La transición inválida se rechaza y queda auditada. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-EVT-006`<br>`TST-EVT-006` | P1 | draw-events | **Query: ListPurchasableEvents**<br>DrawEventQueryService | draw_events por producto/estado/ventana e índice compuesto | `API-E2E + PG`<br>`apps/api/test/postgres/rules/evt/lot-evt-006.pg-spec.ts` | Crear varios eventos activos del mismo producto. | Todos aparecen ordenados y cada uno conserva su propia apertura/cierre. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-EVT-007`<br>`TST-EVT-007` | P0 | draw-events | **Command: UpdatePublishedDrawEvent**<br>DrawEventMutationPolicy | draw_events/event_financial_configs inmutables tras publicación | `API-E2E + PG`<br>`apps/api/test/postgres/rules/evt/lot-evt-007.pg-spec.ts` | Intentar cambiar precio y fecha después de publicar. | La edición se rechaza y el evento permanece sin cambios. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-EVT-008`<br>`TST-EVT-008` | P0 | event-templates | **Command: UpdateEventTemplate**<br>EventTemplateVersionService | event_templates/template_schedules; eventos publicados no se actualizan | `API-E2E + PG`<br>`apps/api/test/postgres/rules/evt/lot-evt-008.pg-spec.ts` | Modificar plantilla con eventos ya publicados. | Los publicados no cambian; solo los futuros elegibles usan la nueva versión. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-EVT-009`<br>`TST-EVT-009` | P0 | draw-events / funds | **Command: PublishDrawEvent sin cobertura**<br>DrawEventPublicationService | guarantee_fund_reservations y draw_events en una transacción | `API-E2E + PG`<br>`apps/api/test/postgres/rules/evt/lot-evt-009.pg-spec.ts` | Publicar con cobertura insuficiente. | La publicación falla y no se abren ventas. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-EVT-010`<br>`TST-EVT-010` | P0 | draw-events / purchases | **Confirmar un segundo antes/después del cierre**<br>OfficialSalesWindowPolicy | draw_events.sales_close_at y job event-close-sales | `API-E2E + WORKER-PG`<br>`apps/worker/test/rules/evt/lot-evt-010.e2e-spec.ts` | Confirmar compra un segundo antes y un segundo después del cierre. | La primera puede confirmar si cumple todo; la segunda se rechaza. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-EVT-011`<br>`TST-EVT-011` | P0 | reservations | **Reservar cerca del cierre y expirar**<br>CombinationReservationService | combination_reservations, índice único parcial ACTIVA y expires_at=min(+5m,cierre) | `PG-INTEGRATION + WORKER`<br>`apps/worker/test/rules/evt/lot-evt-011.e2e-spec.ts` | Reservar con más de cinco minutos restantes, reservar a menos de cinco minutos del cierre y confirmar antes/después de `expires_at`. | La primera dura cinco minutos; la segunda termina en el cierre; una orden vencida o posterior al cierre no compra y no prolonga ventas. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-EVT-012`<br>`TST-EVT-012` | P0 | purchases / limits | **Reservas concurrentes al límite 20 %**<br>ClientEventLimitPolicy | conteo bloqueado de tickets + reservas activas por user/event | `PG-CONCURRENCY`<br>`apps/api/test/postgres/concurrency/lot-evt-012.pg-spec.ts` | Alcanzar el límite y tratar de reservar una combinación adicional. | La reserva adicional se rechaza hasta la liberación o expiración de reservas. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-EVT-013`<br>`TST-EVT-013` | P0 | game-engine / time | **Calcular release_at en fronteras**<br>PurchaseLimitReleaseCalculator | draw_events.limit_release_at y función pura versionada | `UNIT-GAME + PG`<br>`packages/game-engine/src/__tests__/rules/lot-evt-013.spec.ts` | Calcular para 16:05, 16:22, 16:45 y 16:46; además probar ventanas cortas cuyo redondeo cae después del cierre. | Produce 16:00, 16:30, 16:30 y 17:00 cuando están dentro de la ventana; nunca adelanta apertura ni extiende el cierre. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-EVT-014`<br>`TST-EVT-014` | P0 | purchases / limits | **Comprar sobre 20 % después de release_at**<br>ClientEventLimitPolicy | draw_events.limit_release_at; siguen locks/saldo/disponibilidad/cierre | `API-E2E + PG`<br>`apps/api/test/postgres/rules/evt/lot-evt-014.pg-spec.ts` | Comprar más del 20 % después de release_at con saldo y combinaciones disponibles. | La compra puede continuar sin omitir las demás validaciones. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-EVT-015`<br>`TST-EVT-015` | P0 | game-engine / purchases | **Probar cuatro modos de selección**<br>PurchaseSelectionService | event_combinations DISPONIBLE y combination_numbers para filtros parciales | `UNIT-GAME + API-E2E`<br>`packages/game-engine/src/__tests__/rules/lot-evt-015.spec.ts` | Probar los cuatro modos con restricciones parciales. | Cada modo devuelve/reserva combinaciones válidas y distintas. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-EVT-016`<br>`TST-EVT-016` | P0 | purchases | **ConfirmOfficialPurchase con fallo tras débito**<br>PurchaseConfirmationService | evento, reserva, combinación, wallet, order, ticket y ledger en una transacción | `PG-INTEGRATION`<br>`apps/api/test/postgres/rules/evt/lot-evt-016.pg-spec.ts` | Provocar fallo al crear el boleto después del débito. | Todo revierte: no hay débito, boleto ni combinación vendida parcial. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-EVT-017`<br>`TST-EVT-017` | P0 | tickets | **Command: RequestTicketRefund por causas distintas**<br>TicketCorrectionService | tickets, ticket_status_history, refund ledger e idempotencia | `API-E2E + PG`<br>`apps/api/test/postgres/rules/evt/lot-evt-017.pg-spec.ts` | Solicitar devolución por arrepentimiento y luego simular cancelación. | La primera se rechaza; la cancelación genera reembolso trazable. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-EVT-018`<br>`TST-EVT-018` | P0 | draw-events / refunds | **Command/Job: CancelDrawEvent con compradores**<br>DrawEventCancellationService | draw_events CANCELADO, refunds por ticket, ledger y estados de boleto | `WORKER-PG + API-E2E`<br>`apps/worker/test/rules/evt/lot-evt-018.e2e-spec.ts` | Cancelar un evento con múltiples boletos y reintentar el job. | Cada boleto recibe un único reembolso completo y el historial se conserva. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-EVT-019`<br>`TST-EVT-019` | P0 | draw-events | **Cancelar antes/después de RESULTADO_FIJADO**<br>DrawEventCancellationPolicy | draw_events.status, draw_results UQ y guardia temporal | `API-E2E + PG`<br>`apps/api/test/postgres/rules/evt/lot-evt-019.pg-spec.ts` | Cerrar ventas sin generar resultado, cancelar y luego intentar cancelar después de fijar resultado. | La primera cancelación puede completarse con reembolsos; la segunda se rechaza. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-EVT-020`<br>`TST-EVT-020` | P0 | state-history | **Ejecutar transiciones de evento/compra**<br>StateTransitionRecorder | draw_event_status_history, ticket_status_history y demás historiales con actor/correlation | `PG-INTEGRATION`<br>`apps/api/test/postgres/rules/evt/lot-evt-020.pg-spec.ts` | Completar ciclo publicación→venta→cierre→resultado. | Existe una secuencia histórica completa y ordenada. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |

## 4.6 `PRZ`

| Regla / test | Pri. | Módulo | Entrada / servicio | PostgreSQL / control | Nivel / archivo | Escenario mínimo | Resultado esperado | Estado |
|---|---:|---|---|---|---|---|---|---|
| `LOT-PRZ-001`<br>`TST-PRZ-001` | P0 | evaluations | **Job: EvaluateTickets con coincidencia exacta**<br>TicketEvaluationService | draw_results, tickets, ticket_evaluations y prize_awards UQ | `WORKER-PG`<br>`apps/worker/test/rules/prz/lot-prz-001.e2e-spec.ts` | Evaluar un evento con y sin combinación ganadora vendida. | Se identifica cero o un ganador mayor. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-PRZ-002`<br>`TST-PRZ-002` | P0 | evaluations | **Evaluar aciertos n-1**<br>TicketEvaluationService | ticket_evaluations y prize_awards NEAR_MATCH_REFUND | `UNIT-GAME + PG`<br>`packages/game-engine/src/__tests__/rules/lot-prz-002.spec.ts` | Evaluar boletos a distancia 1, 0 y 2. | Solo distancia 1 recibe la devolución secundaria. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-PRZ-003`<br>`TST-PRZ-003` | P0 | prize-engine | **Calcular componentes de premio**<br>PrizeCompositionService | event_financial_configs/projections y accumulation_transfers | `UNIT-MONEY + PG`<br>`packages/money/src/__tests__/rules/lot-prz-003.spec.ts` | Agregar ventas y acumulado a un evento. | La interfaz y el informe muestran componentes y total coherentes. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-PRZ-004`<br>`TST-PRZ-004` | P0 | prize-engine / publication | **Recomendar x5 y publicar con/sin cobertura**<br>PrizeRecommendationService | event_financial_configs y guarantee_fund_reservations | `UNIT-MONEY + API-E2E`<br>`packages/money/src/__tests__/rules/lot-prz-004.spec.ts` | Configurar un premio inicial superior a la cobertura. | El semáforo es rojo y la publicación se bloquea. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-PRZ-005`<br>`TST-PRZ-005` | P0 | prize-engine | **Calcular 90/10 con techo**<br>PrizeGrowthService | event_financial_projections, fund_movements y ledger | `UNIT-MONEY + PG`<br>`packages/money/src/__tests__/rules/lot-prz-005.spec.ts` | Simular ventas por debajo/encima del techo, mostrar crecimiento, cancelar antes del resultado y liquidar después del resultado. | El crecimiento nunca es negativo ni excede el techo; una cancelación conserva fondos suficientes para devolver el 100 % y la liquidación posterior no duplica asignaciones. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-PRZ-006`<br>`TST-PRZ-006` | P0 | prize-engine | **Fronteras de redondeo a cuartos**<br>PrizeRoundingService | prize_awards(exact,public,adjustment) y ROUNDING_ADJUSTMENTS_VIRTUAL | `UNIT-PROPERTY + PG`<br>`packages/money/src/__tests__/rules/lot-prz-006.spec.ts` | Probar todos los límites y valores adyacentes. | Cada valor produce el cuarto correcto y conserva el exacto en auditoría. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-PRZ-007`<br>`TST-PRZ-007` | P0 | funds | **Dos eventos reservan la misma cobertura**<br>GuaranteeReservationService | guarantee_fund_reservations, ledger accounts y locks | `PG-CONCURRENCY`<br>`apps/api/test/postgres/concurrency/lot-prz-007.pg-spec.ts` | Publicar simultáneamente dos eventos que exceden el disponible conjunto. | Solo se reservan eventos cubiertos; no hay doble uso del saldo. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-PRZ-008`<br>`TST-PRZ-008` | P0 | funds | **Job: fund-reconcile bajo mínimo**<br>FundReconciliationJob | guarantee_fund, reservations, ledger y bloqueo de publicación | `WORKER-PG`<br>`apps/worker/test/rules/prz/lot-prz-008.e2e-spec.ts` | Reducir el fondo por debajo del mínimo. | No se publican nuevos eventos y se genera alerta. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-PRZ-009`<br>`TST-PRZ-009` | P0 | settlement | **Job: no-winner-distribution con meta**<br>NoWinnerDistributionService | accumulation_pools, guarantee/future funds, fund_movements y ledger 50/25/15/10 | `UNIT-MONEY + WORKER-PG`<br>`packages/money/src/__tests__/rules/lot-prz-009.spec.ts` | Liquidar un evento elegible sin ganador. | La suma distribuida coincide con el total y cada fondo recibe su porcentaje. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-PRZ-010`<br>`TST-PRZ-010` | P0 | settlement | **Liquidar evento sin meta mínima**<br>EventSettlementService | awards, guarantee recovery, operations y ledger con orden de prelación | `WORKER-PG`<br>`apps/worker/test/rules/prz/lot-prz-010.e2e-spec.ts` | Liquidar evento de baja venta sin ganador. | No se crea acumulado indebido y se respetan obligaciones prioritarias. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-PRZ-011`<br>`TST-PRZ-011` | P0 | accumulations | **Asignar al siguiente evento y cancelar receptor**<br>AccumulationService | accumulation_pools/transfers y eventos del mismo producto | `WORKER-PG`<br>`apps/worker/test/rules/prz/lot-prz-011.e2e-spec.ts` | Asignar acumulado y cancelar el receptor. | El monto retorna íntegro al pool y no se duplica. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-PRZ-012`<br>`TST-PRZ-012` | P0 | draw-engine / security | **Job: GenerateCommitment antes del cierre**<br>DrawCommitmentService | draw_commitments, encrypted_secret_seed, commitment_hash y key version | `SECURITY-PG`<br>`apps/api/test/security/rules/lot-prz-012.e2e-spec.ts` | Verificar commitment antes y después de revelar la semilla. | Coincide al revelar y no permite conocer el resultado anticipadamente. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-PRZ-013`<br>`TST-PRZ-013` | P0 | draw-engine | **Job: FreezeOfficialDraw**<br>DrawSnapshotService | draw_snapshots y draw_snapshot_tickets con hash determinista | `WORKER-PG`<br>`apps/worker/test/rules/prz/lot-prz-013.e2e-spec.ts` | Recalcular el hash con el mismo conjunto y con un boleto alterado. | El mismo conjunto produce el mismo hash; la alteración produce otro. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-PRZ-014`<br>`TST-PRZ-014` | P0 | draw-engine | **Dos Jobs GenerateOfficialResult**<br>OfficialDrawEngine | draw_results UQ(draw_event_id), draw_result_numbers e inmutabilidad | `PG-CONCURRENCY + WORKER`<br>`apps/worker/test/rules/prz/lot-prz-014.e2e-spec.ts` | Ejecutar draw-generate varias veces y en paralelo. | Existe un único resultado válido e idéntico para todos los reintentos. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-PRZ-015`<br>`TST-PRZ-015` | P1 | results / presentation | **Recargar/saltar animación en dos dispositivos**<br>ResultPresentationService | solo lectura de draw_results; no inserta otro resultado | `API-E2E`<br>`apps/api/test/rules/prz/lot-prz-015.e2e-spec.ts` | Reproducir, omitir y recargar la animación. | Siempre se muestran los mismos valores oficiales. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-PRZ-016`<br>`TST-PRZ-016` | P0 | awards | **Jobs concurrentes report-publish/award-credit**<br>AwardCreditService | result_reports, award_payment_orders UQ, ledger y estado de ticket | `PG-CONCURRENCY + WORKER`<br>`apps/worker/test/rules/prz/lot-prz-016.e2e-spec.ts` | Publicar informe, interrumpir proceso y reintentar. | Cada premio se acredita exactamente una vez. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-PRZ-017`<br>`TST-PRZ-017` | P0 | wallets / awards | **Ledger de premio existente y proyección dañada**<br>AwardProjectionRepairService | award_payment_orders, ledger y wallet_balance_projections | `WORKER-PG`<br>`apps/worker/test/rules/prz/lot-prz-017.e2e-spec.ts` | Simular fallo entre libro y proyección. | El saldo visible se corrige sin nueva transacción económica. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-PRZ-018`<br>`TST-PRZ-018` | P0 | reports | **Query: PublicResultReport**<br>ResultReportService | result_reports.public_payload allowlist y stored_objects; sin PII | `SECURITY-E2E + PG`<br>`apps/api/test/security/rules/lot-prz-018.e2e-spec.ts` | Generar informe con ganador real y revisar JSON/HTML/PDF. | No aparece ningún dato personal y los hashes son verificables. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |

## 4.7 `ORG`

| Regla / test | Pri. | Módulo | Entrada / servicio | PostgreSQL / control | Nivel / archivo | Escenario mínimo | Resultado esperado | Estado |
|---|---:|---|---|---|---|---|---|---|
| `LOT-ORG-001`<br>`TST-ORG-001` | P0 | user-draws | **Command: CreateUserDraw**<br>UserDrawCreationService | user_draws.organizer_user_id; roles globales sin ORGANIZADOR | `API-E2E + PG`<br>`apps/api/test/postgres/rules/org/lot-org-001.pg-spec.ts` | Crear sorteo con cuenta activa y suspendida. | La activa puede crear; la suspendida no. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-002`<br>`TST-ORG-002` | P0 | user-draws / access | **List/Read público, privado y con acceso**<br>UserDrawAccessPolicy | user_draws.visibility, access_codes e invitations | `API-E2E + PG`<br>`apps/api/test/postgres/rules/org/lot-org-002.pg-spec.ts` | Consultar ambos sin credenciales/código. | El público aparece; el privado no revela datos protegidos. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-003`<br>`TST-ORG-003` | P0 | user-draws | **Create/Publish con configuración válida/inválida**<br>UserDrawCreationService | user_draws, prize evidence y checks de rango/precio/fechas | `API-E2E + PG`<br>`apps/api/test/postgres/rules/org/lot-org-003.pg-spec.ts` | Crear sorteo sin un dato obligatorio y crear otro válido sin anuncios. | La creación incompleta se rechaza; el sorteo válido se crea sin exigir anuncios. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-004`<br>`TST-ORG-004` | P0 | user-draws / numbers | **Command: ExpandUserDrawRange concurrente**<br>UserDrawRangeService | user_draw_numbers UNIQUE(draw,number) y no mutación de existentes | `PG-CONCURRENCY`<br>`apps/api/test/postgres/concurrency/lot-org-004.pg-spec.ts` | Ampliar rango con participantes existentes y tratar de reutilizar un número ocupado. | La expansión añade solo nuevos números; el ocupado permanece intacto. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-006`<br>`TST-ORG-006` | P0 | user-draw-finance | **Command: BuyParticipation**<br>UserDrawParticipationPaymentService | user_draw_participations, user_draw_escrows, commission-held/escrow accounts y ledger 5/95 | `UNIT-MONEY + PG`<br>`packages/money/src/__tests__/rules/lot-org-006.spec.ts` | Confirmar una participación de 100,00 VIRTUAL y luego cancelar antes de la liquidación. | Se registran 5,00 retenidos y 95,00 en custodia; al cancelar, ambos componentes se revierten una sola vez y el pagador recupera 100,00. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-007`<br>`TST-ORG-007` | P0 | user-draws / announcements | **Query/CreateAnnouncement con distintos sujetos**<br>UserDrawAnnouncementPolicy | user_draw_announcements y relación participant/organizer/admin | `API-E2E`<br>`apps/api/test/rules/org/lot-org-007.e2e-spec.ts` | Consultar anuncios como usuario externo. | La API no devuelve el contenido. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-008`<br>`TST-ORG-008` | P0 | user-draws / cancellation | **Command/Job: CancelUserDraw**<br>UserDrawCancellationService | user_draws, participations, escrow/commission, refunds y ledger | `WORKER-PG + API-E2E`<br>`apps/worker/test/rules/org/lot-org-008.e2e-spec.ts` | Cancelar con varias participaciones y reintentar el job. | Cada participante recibe un único reembolso total; escrow y comisión quedan revertidos o compensados de forma balanceada. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-009`<br>`TST-ORG-009` | P0 | user-draws / retention | **Intentar DELETE de recursos con historia**<br>UserDrawRetentionPolicy | FK RESTRICT/soft status en draws, participations, numbers, codes, claims y ledger | `PG-INTEGRATION`<br>`apps/api/test/postgres/rules/org/lot-org-009.pg-spec.ts` | Intentar borrar un sorteo con participantes. | La eliminación se rechaza; solo puede cambiar a estado histórico permitido. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-010`<br>`TST-ORG-010` | P0 | user-draws / codes | **Command: IssueAccessCode sin cuenta destinataria**<br>AccessCodeIssueService | user_draw_access_codes permite claimed_by_user_id NULL; secret_hash | `API-E2E + PG`<br>`apps/api/test/postgres/rules/org/lot-org-010.pg-spec.ts` | Crear código sin usuario destinatario y reclamarlo luego de registrarse. | El código se crea y posteriormente queda asociado al reclamante válido. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-011`<br>`TST-ORG-011` | P0 | user-draws / codes | **Emitir código para uno y varios números**<br>AccessCodeIssueService | user_draw_access_codes.price_total_minor + user_draw_access_code_numbers + locks de numbers | `PG-INTEGRATION`<br>`apps/api/test/postgres/rules/org/lot-org-011.pg-spec.ts` | Crear código sin sorteo/precio, con números repetidos o interpretar el precio total como precio por cada número. | La operación inválida se rechaza y el código conserva un único importe económico para todo su grupo. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-012`<br>`TST-ORG-012` | P0 | user-draws / codes | **Reclamar código con comentario de otra persona**<br>AccessCodeClaimService | optional_comment no crea FK/identidad reservada | `API-E2E + PG`<br>`apps/api/test/postgres/rules/org/lot-org-012.pg-spec.ts` | Emitir “para Juan” y reclamar con otra cuenta válida. | La reclamación depende del código y sus reglas, no del texto del comentario. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-013`<br>`TST-ORG-013` | P0 | user-draws / codes | **Dos cuentas reclaman el mismo código**<br>AccessCodeClaimService | lock/estado RECLAMADO, unique claim y transacción | `PG-CONCURRENCY`<br>`apps/api/test/postgres/concurrency/lot-org-013.pg-spec.ts` | Dos cuentas reclaman simultáneamente el mismo código. | Solo una queda asociada; la otra recibe código ya utilizado. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-014`<br>`TST-ORG-014` | P0 | user-draws / codes | **Claim de código grupal**<br>AccessCodeClaimService | participations, user_draw_participation_numbers, code events y audit_events | `PG-INTEGRATION`<br>`apps/api/test/postgres/rules/org/lot-org-014.pg-spec.ts` | Reclamar códigos de uno y varios números, pagados y pendientes; repetir la reclamación y revisar ledger/snapshot. | No hay doble cobro ni multiplicación del precio; cada número activo genera una entrada elegible separada en el snapshot. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-015`<br>`TST-ORG-015` | P0 | user-draws / codes | **Reutilización, uso tardío y dos expiraciones**<br>AccessCodeExpiryJob | codes/status/expires_at, code_numbers y liberación idempotente | `PG-CONCURRENCY + WORKER`<br>`apps/worker/test/rules/org/lot-org-015.e2e-spec.ts` | Reutilizar un código, reclamarlo después de expirar y ejecutar dos expiraciones concurrentes. | La reutilización y el uso tardío se rechazan; los números se liberan una sola vez. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-016`<br>`TST-ORG-016` | P0 | user-draws / timeline | **Query: OrganizerTimeline tras todos los movimientos**<br>UserDrawTimelineService | event tables de codes, participations, number changes, claims, escrow y audit | `API-E2E + PG`<br>`apps/api/test/postgres/rules/org/lot-org-016.pg-spec.ts` | Ejecutar cada movimiento y consultar historial. | Todos aparecen en orden con actor, fecha y referencia. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-017`<br>`TST-ORG-017` | P0 | user-draws / participations | **ChangeNumber/BuyAdditional en fronteras**<br>ParticipationNumberService | user_draw_participation_numbers, user_draw_number_changes y user_draw_numbers | `PG-CONCURRENCY + API-E2E`<br>`apps/api/test/postgres/concurrency/lot-org-017.pg-spec.ts` | Cambiar después del cierre, cambiar a número ocupado, cambiar un número dentro de una participación grupal y comprar adicional un segundo antes/después del cierre. | Solo operaciones anteriores al cierre y con números disponibles se confirman; todo cambio conserva asignación anterior y nueva sin alterar el precio total histórico. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-018`<br>`TST-ORG-018` | P0 | user-draws / moderation | **Command: ExpelParticipant antes/después del cierre**<br>ParticipantExpulsionService | participations, numbers, refunds, escrow/commission events y audit | `API-E2E + PG`<br>`apps/api/test/postgres/rules/org/lot-org-018.pg-spec.ts` | Expulsar antes y después del cierre a un participante pagado. | Antes del cierre se reembolsa y libera una sola vez; después del cierre la acción directa se rechaza. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-019`<br>`TST-ORG-019` | P0 | user-draws / participations | **Command: AbandonParticipation por estado de pago**<br>ParticipationAbandonmentService | payment/relation/eligibility status, assignments y history | `API-E2E + PG`<br>`apps/api/test/postgres/rules/org/lot-org-019.pg-spec.ts` | Abandonar una participación pendiente, una pagada y otra después del cierre. | La pendiente libera el número; la pagada conserva número y elegibilidad sin reembolso; la posterior al cierre se rechaza. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-020`<br>`TST-ORG-020` | P0 | user-draws / claims | **Create/ResolveClaim en plazo y por actor**<br>UserDrawClaimService | user_draw_claims/evidence, permissions y fechas límite | `API-E2E + PG`<br>`apps/api/test/postgres/rules/org/lot-org-020.pg-spec.ts` | Crear reclamo dentro y fuera del plazo y tratar de resolverlo como Organizador. | El reclamo oportuno se admite; el tardío se rechaza salvo reapertura administrativa motivada; el Organizador no puede resolver. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-021`<br>`TST-ORG-021` | P0 | user-draws / claims | **Resolve/Appeal/CloseClaim**<br>ClaimWorkflowService | claim_status, user_draw_claim_events, decisión inmutable y compensación enlazada | `PG-INTEGRATION + API-E2E`<br>`apps/api/test/postgres/rules/org/lot-org-021.pg-spec.ts` | Resolver, apelar dentro/fuera de plazo y consultar el historial completo. | Solo transiciones y apelaciones válidas se aceptan; nunca se pierde ni reescribe el historial original. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-022`<br>`TST-ORG-022` | P0 | user-draws / result | **Dos jobs GenerateUserDrawResult + participación grupal**<br>UserDrawResultJob | user_draw_snapshots/entries, participation_numbers y user_draw_results UQ | `PG-CONCURRENCY + WORKER`<br>`apps/worker/test/rules/org/lot-org-022.e2e-spec.ts` | Reintentar la generación, usar una participación con varios números, alterar el conjunto después del cierre y verificar hashes/alcance de la evidencia. | Existe un único número ganador perteneciente al snapshot; cada número elegible tiene una entrada; los reintentos devuelven el mismo resultado y cualquier alteración del conjunto/resultado se detecta sin confundirlo con commit-reveal oficial. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-023`<br>`TST-ORG-023` | P0 | user-draws / delivery | **Publish sin evidencia; confirmar/incumplir entrega**<br>UserDrawDeliveryService | prize_evidence, delivery_records, claims y escrow hold | `API-E2E + PG`<br>`apps/api/test/postgres/rules/org/lot-org-023.pg-spec.ts` | Publicar sin evidencia, confirmar entrega y simular incumplimiento con reclamo aceptado. | Sin evidencia no se publica; la entrega queda trazada; el incumplimiento impide liquidar y habilita compensación. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-024`<br>`TST-ORG-024` | P0 | user-draws / immutability | **UpdateUserDraw tras first_payment_at**<br>UserDrawMutationPolicy | user_draws.first_payment_at y lista blanca; numbers previos inmutables | `API-E2E + PG`<br>`apps/api/test/postgres/rules/org/lot-org-024.pg-spec.ts` | Intentar cambiar precio, premio, visibilidad, cierre y luego publicar un anuncio/ampliar rango. | Los cambios económicos o estructurales se rechazan; anuncio y ampliación válida pueden confirmarse. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-025`<br>`TST-ORG-025` | P0 | user-draws / escrow | **ReleaseEscrow concurrente + compensación posterior**<br>UserDrawEscrowSettlementService | user_draw_escrows/events, ledger accounts, terminal LIBERADA y cuenta de compensación | `PG-CONCURRENCY + WORKER`<br>`apps/worker/test/rules/org/lot-org-025.e2e-spec.ts` | Intentar retirar antes de entrega, liberar tras confirmación, repetir la orden y ordenar una compensación después de `LIBERADA`. | El retiro anticipado se rechaza; la liquidación ocurre una sola vez; una compensación posterior no modifica el escrow liquidado y acredita al afectado mediante operación separada y balanceada. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-ORG-026`<br>`TST-ORG-026` | P1 | identity / excluded-feature | **Intentar iniciar verificación automática de cédula**<br>IdentityFeaturePolicy | ausencia de tablas/campos de imagen/validación de cédula; feature flag deshabilitada | `SCHEMA + API-E2E`<br>`scripts/tests/rules/lot-org-026.spec.mjs` | Intentar activar el flujo de cédula en MVP. | El flujo no está disponible y no se recopilan datos adicionales de identidad. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |

## 4.8 `AUD`

| Regla / test | Pri. | Módulo | Entrada / servicio | PostgreSQL / control | Nivel / archivo | Escenario mínimo | Resultado esperado | Estado |
|---|---:|---|---|---|---|---|---|---|
| `LOT-AUD-001`<br>`TST-AUD-001` | P0 | audit | **Operaciones críticas y búsqueda por correlation_id**<br>AuditService | audit_events con actor, mode, resource, reason, correlation_id y occurred_at | `API-E2E + PG`<br>`apps/api/test/postgres/rules/aud/lot-aud-001.pg-spec.ts` | Ejecutar operaciones críticas y buscar auditoría por correlation_id. | Cada operación posee un evento correlacionado suficiente para reconstrucción. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-AUD-002`<br>`TST-AUD-002` | P0 | audit / security | **Petición fallida con secretos**<br>AuditSanitizer | allowlist de audit_events/security_events y logs; no secretos | `SECURITY-E2E`<br>`apps/api/test/security/rules/lot-aud-002.e2e-spec.ts` | Enviar secretos en una petición fallida y revisar logs. | Los secretos no aparecen; los metadatos necesarios sí. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-AUD-003`<br>`TST-AUD-003` | P0 | admin | **Comando administrativo sin reason**<br>AdministrativeCommandGuard | reason NOT NULL/no vacío cuando aplica + audit_events | `API-E2E + PG`<br>`apps/api/test/postgres/rules/aud/lot-aud-003.pg-spec.ts` | Ejecutar acción administrativa sin motivo. | La API rechaza la acción. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-AUD-004`<br>`TST-AUD-004` | P0 | worker / jobs | **Reiniciar worker durante job crítico**<br>PersistentJobRunner | scheduled_jobs, job_runs, outbox/inbox e idempotencia del efecto | `WORKER-PG + RESILIENCIA`<br>`apps/worker/test/rules/aud/lot-aud-004.e2e-spec.ts` | Reiniciar worker durante un job. | El job continúa o reintenta sin duplicar efectos. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-AUD-005`<br>`TST-AUD-005` | P0 | concurrency | **Eliminar lock Redis durante compra**<br>PostgresConcurrencyGuard | UNIQUE, row locks y transacciones PostgreSQL sobre recurso crítico | `PG-CONCURRENCY`<br>`apps/api/test/postgres/concurrency/lot-aud-005.pg-spec.ts` | Eliminar lock Redis durante compras simultáneas. | La base sigue impidiendo doble venta o doble pago. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-AUD-006`<br>`TST-AUD-006` | P0 | security / rate-limit | **Ráfagas en login, code claim, purchase y conversion**<br>RateLimitService | security_events; ninguna fila de negocio duplicada | `SECURITY-E2E`<br>`apps/api/test/security/rules/lot-aud-006.e2e-spec.ts` | Enviar ráfagas sobre login y claim de código. | Las solicitudes abusivas se limitan sin ejecutar efectos múltiples. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-AUD-007`<br>`TST-AUD-007` | P0 | migrations / CI | **Alterar migración aplicada**<br>MigrationIntegrityCheck | prisma/migrations checksums + estrategia forward/compensatoria | `CI-MIGRATION`<br>`scripts/tests/rules/lot-aud-007.spec.mjs` | Modificar una migración aplicada y ejecutar CI. | La revisión/CI lo detecta y exige una nueva migración. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-AUD-008`<br>`TST-AUD-008` | P0 | traceability / CI | **Ejecutar verificador regla→prueba**<br>RuleTestTraceabilityCheck | MATRIZ-REGLA-PRUEBA.csv + metadatos @rule en tests | `CI-TRACEABILITY`<br>`scripts/tests/rules/lot-aud-008.spec.mjs` | Ejecutar verificador de cobertura de trazabilidad. | Ninguna regla crítica queda sin test asociado. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |
| `LOT-AUD-009`<br>`TST-AUD-009` | P0 | architecture / migrations | **Añadir campo/comportamiento sin regla o ADR**<br>SchemaGovernanceCheck | diff del diccionario/schema y checklist de decisiones abiertas | `CI-MIGRATION`<br>`scripts/tests/rules/lot-aud-009.spec.mjs` | Intentar modelar un campo cuyo comportamiento no está definido. | Se bloquea la migración hasta aprobar la decisión o excluir el flujo. | `DISEÑADA`<br>`PENDIENTE_IMPLEMENTACION` |

# 5. Suites bloqueantes antes de aprobar la primera migración

La matriz contiene pruebas que solo podrán ejecutarse después de crear el esquema. Sin embargo, la primera migración no debe aprobarse hasta que exista al menos la estructura de estas suites.

## 5.1 Esquema y tipos

- No existen columnas monetarias `float`, `real` o `double precision`.
- Todas las FKs nombradas apuntan a tablas existentes.
- Los estados aceptados coinciden con los documentos.
- No existe rol global `ORGANIZADOR`.
- No existen campos o archivos de cédula automática en el MVP.
- REAL y VIRTUAL se expresan mediante cuentas separadas.

## 5.2 Ledger

- La transacción desbalanceada no puede contabilizarse.
- Cada moneda balancea independientemente.
- Los asientos confirmados son inmutables.
- Un reverso crea otra transacción y soporta reverso parcial trazable.
- Las proyecciones se reconstruyen sin duplicar el movimiento.
- Las cuentas de usuario no quedan negativas.

## 5.3 Concurrencia

Con dos conexiones PostgreSQL reales:

- una combinación oficial solo se vende una vez;
- una reserva activa por combinación;
- una asignación activa por solicitud;
- una finalización Cliente–Vendedor/plataforma;
- una reclamación por código;
- una asignación activa por número;
- un resultado por evento/sorteo;
- una orden de premio/reembolso/liquidación;
- una reserva de garantía por obligación.

## 5.4 Tiempo y workers

- Reserva de combinación hasta cinco minutos sin superar cierre.
- Fallback de solicitud exactamente a cinco minutos.
- Cierre oficial diez minutos antes.
- Jobs sobreviven reinicio.
- Reintentar no duplica efectos.
- La hora del dispositivo no autoriza operaciones.

## 5.5 Inmutabilidad

- Eventos oficiales publicados no se editan.
- Primer pago congela el sorteo de usuario.
- Tickets, snapshots, resultados, informes publicados y auditoría no se destruyen.
- `LIBERADA` en escrow es terminal.
- Correcciones y compensaciones se registran por separado.

# 6. Verificador de trazabilidad en CI

El futuro verificador `scripts/verify-rule-test-traceability.mjs` debe:

1. Extraer reglas activas desde `REGLAS-NEGOCIO.md`.
2. Leer `MATRIZ-REGLA-PRUEBA.csv`.
3. Buscar cada `rule_id` en archivos de prueba.
4. Fallar cuando falte una regla, un test, un archivo o una ruta.
5. Fallar ante IDs duplicados.
6. Ignorar únicamente `LOT-ORG-005` por estar reservado.
7. Exigir que `LOT-ORG-026` tenga una prueba negativa.
8. Publicar cobertura por dominio.

Salida esperada antes de merge:

```text
Active rules: 112
Mapped primary tests: 112
Implemented tests: 112
Rules without test: 0
Duplicate rule mappings: 0
Status: PASS
```

# 7. Gate de implementación

Una fila solo cambia a `IMPLEMENTADA` cuando:

- el archivo existe;
- el título contiene `[LOT-*]`;
- la validación ocurre en la capa adecuada;
- la restricción SQL existe cuando corresponde;
- el test no usa mocks para probar una garantía PostgreSQL;
- el escenario y resultado coinciden con la regla;
- el test pasa individualmente y dentro de la suite.

Una regla solo cambia a `EJECUTADA_OK` cuando pasa en CI sobre una base creada desde todas las migraciones.

# 8. Orden de implementación recomendado

1. Tests de esquema, enums y FKs.
2. Ledger, tipos monetarios y residuos.
3. Identidad, roles, modos y permisos.
4. Vendedores y solicitudes.
5. Catálogo oficial, reservas y compra concurrente.
6. Fondos, resultado, premios e informes.
7. Sorteos creados por usuarios.
8. Workers, resiliencia, seguridad y migraciones.
9. Verificador global `LOT-AUD-008`.

# 9. Criterios de aprobación de la matriz

- [x] Las 112 reglas activas tienen un `TST-*`.
- [x] Cada `TST-*` tiene archivo previsto único.
- [x] Se conserva el escenario normativo de la regla.
- [x] Se conserva su resultado esperado.
- [x] Se identifica el servicio lógico.
- [x] Se identifica el control PostgreSQL cuando aplica.
- [x] Se distinguen unitarias, integración, concurrencia, worker, seguridad y CI.
- [x] `LOT-ORG-026` se prueba como exclusión del MVP.
- [x] La matriz es exportable mediante CSV.
- [ ] Programar los 112 casos.
- [ ] Ejecutarlos contra las migraciones.
- [ ] Marcar cada fila como `EJECUTADA_OK`.

# 10. Decisión de salida

Con esta matriz queda completado el diseño documental previo a PostgreSQL. El siguiente paso autorizado es traducir `DICCIONARIO-DE-DATOS.md` a `schema.prisma` y preparar la migración inicial junto con los controles SQL que permitan ejecutar estas pruebas.

> El esquema no se considera correcto porque Prisma compile; se considera correcto cuando las reglas que dependen de PostgreSQL pueden demostrarse mediante esta matriz.
