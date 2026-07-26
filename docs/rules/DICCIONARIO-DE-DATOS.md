---
title: "Diccionario de Datos Lógico y Físico — Lotería Binaria"
version: "1.1.0"
status: "APROBADO Y CONGELADO — contrato de datos previo al schema.prisma v1"
author: "Cristhian Herrera Nieto"
date: "2026-07-26"
repository: "Herrera2005/loteria-binaria"
normative_rules: "REGLAS-NEGOCIO.md v1.4.0"
state_model: "ESTADOS-Y-TRANSICIONES.md v1.1.0"
financial_model: "FLUJOS-FINANCIEROS.md v1.1.0"
permission_model: "MATRIZ-DE-PERMISOS.md v1.1.0"
---

# DICCIONARIO DE DATOS — LOTERÍA BINARIA

**Versión:** 1.1.0  
**Estado:** **APROBADO Y CONGELADO** como contrato previo al `schema.prisma` v1.  
**Ruta objetivo:** `docs/DICCIONARIO-DE-DATOS.md`

> [!WARNING]
> En la fase académica, recargas, saldos, conversiones, retiros y premios son simulados. Este documento define integridad interna, no autoriza operaciones reales ni sustituye controles legales, regulatorios, financieros o de proveedores.

## 0. Propósito

Este documento traduce las reglas `LOT-*`, las máquinas de estados, los flujos de doble entrada y la matriz de permisos a entidades, campos, claves y restricciones antes de escribir Prisma.

Objetivos:

- Cubrir todas las tablas exigidas en la sección 6.3 del Plan Técnico.
- Añadir únicamente entidades derivadas necesarias para las reglas aprobadas.
- Separar lotería oficial y sorteos creados por usuarios.
- Impedir que Prisma invente estados, relaciones o fuentes de saldo.
- Identificar controles que requieren SQL PostgreSQL complementario.
- Servir de contrato para migraciones, seeds, repositorios y pruebas.

No es todavía una migración ni un `schema.prisma`.

## 0.1 Autoridad y fuentes

1. Documento Maestro v1.0 y adendas aprobadas, incluido `ADR-ORG-001`.
2. `REGLAS-NEGOCIO.md` v1.4.0.
3. Contratos especializados aprobados: `ESTADOS-Y-TRANSICIONES.md`, `FLUJOS-FINANCIEROS.md`, `MATRIZ-DE-PERMISOS.md` y este diccionario, cada uno dentro de su materia.
4. `PLAN-TECNICO.md` v1.1.0.
5. OpenAPI, `schema.prisma` y migraciones.
6. Código y pruebas.
7. README como guía operativa.

No existen decisiones funcionales abiertas para diseñar el esquema v1. La verificación automática con cédula está excluida formalmente, no pendiente.

## 0.2 Convenciones

| Elemento | Convención |
|---|---|
| Tablas/columnas | `snake_case`; tablas en plural. |
| PK | `id UUID`, generado por la aplicación. |
| FK | `<entidad>_id`; relación explícita. |
| IDs públicos | `public_id`, separado de PK cuando se expone. |
| Fechas | `TIMESTAMPTZ` UTC; visualización America/Guayaquil. |
| Dinero | `BIGINT` en centavos/centésimas; sufijo `_minor`. |
| Porcentajes | Puntos básicos `_bps` o numerador/denominador históricos. |
| Hash | Sufijo `_hash`; nunca secretos en texto. |
| Estado | Enum lógico o `TEXT` con `CHECK`; nunca texto libre. |
| JSONB | Metadata/snapshots; no sustituye FKs críticas. |
| Borrado | Estado/fecha lógica; no borrar historia financiera. |

## 0.3 Tipos PostgreSQL y Prisma

| Lógico | PostgreSQL | Prisma aproximado |
|---|---|---|
| UUID | `uuid` | `String @db.Uuid` |
| Dinero | `bigint` | `BigInt` |
| Fecha/hora | `timestamptz` | `DateTime @db.Timestamptz(6)` |
| Fecha | `date` | `DateTime @db.Date` |
| JSON | `jsonb` | `Json` |
| Binario cifrado | `bytea` | `Bytes` |
| Correo/usuario | `citext` | `String` + migración SQL |
| Texto corto | `varchar(n)` | `String @db.VarChar(n)` |

## 0.4 Columnas comunes

Tablas mutables:

```text
id UUID PK
created_at TIMESTAMPTZ NOT NULL
updated_at TIMESTAMPTZ NOT NULL
```

Tablas append-only omiten `updated_at`. Las fechas sensibles proceden del servidor/base.

## 0.5 Límites explícitos

- La baseline usa UUID v7 generado por la aplicación y almacenado como `uuid`; la biblioteca concreta es una decisión de implementación.
- Retención exacta de logs, tokens, auditoría y archivos se fija mediante política operativa/legal sin cambiar el dominio.
- La verificación automática con cédula ecuatoriana queda fuera del MVP.
- La política de minor units y residuos está cerrada por `LOT-FIN-013`.
- Un proveedor real de pagos/retiros queda fuera del MVP académico.

# 1. Enumeraciones lógicas

## `account_status`

```text
PENDIENTE_VERIFICACION | ACTIVO | SUSPENDIDO | BLOQUEADO | DESACTIVADO
```

## `active_mode`

```text
CLIENTE | CLIENTE_FINANCIERO | VENDEDOR | ADMINISTRADOR
```

## `actor_type`

```text
USER | ADMIN | WORKER | SYSTEM
```

## `session_status`

```text
ABIERTA | EXPIRADA | REVOCADA | CERRADA
```

## `verification_channel`

```text
EMAIL | PHONE
```

## `verification_purpose`

```text
ACCOUNT_VERIFICATION | CHANGE_CONTACT | PASSWORD_RECOVERY
```

## `currency_code`

```text
REAL | VIRTUAL
```

## `wallet_status`

```text
ACTIVE | BLOCKED | CLOSED
```

## `idempotency_status`

```text
PROCESSING | COMPLETED | FAILED
```

## `ledger_transaction_status`

```text
CONTABILIZADA | PARCIALMENTE_REVERSADA | REVERSADA
```

## `ledger_side`

```text
DEBIT | CREDIT
```

## `ledger_account_type`

```text
USER_REAL_AVAILABLE | USER_REAL_RESERVED_CONVERSION | USER_REAL_IN_WITHDRAWAL | USER_VIRTUAL_AVAILABLE | PLATFORM_REAL_CASH | SIMULATED_TOPUP_SOURCE_REAL | SIMULATED_PAYOUT_CLEARING_REAL | PLATFORM_VIRTUAL_ISSUANCE | PLATFORM_VIRTUAL_REDEMPTION | GENERAL_CONVERSION_WALLET | CONVERSION_FEES_VIRTUAL | PLATFORM_OPERATIONS_VIRTUAL | ROUNDING_ADJUSTMENTS_VIRTUAL | DRAW_SALES_FUND | DRAW_PRIZE_RESERVE | AWARD_PAYABLE | DRAW_UNAWARDED_MAJOR_PRIZE | DRAW_ACCUMULATION_EXTRA | GUARANTEE_FUND_AVAILABLE | GUARANTEE_FUND_RESERVED_EVENT | FUTURE_PRIZE_FUND | ACCUMULATION_POOL_PRODUCT | USER_DRAW_ESCROW | USER_DRAW_COMMISSION_HELD
```

## `topup_status`

```text
CREADA | CONFIRMADA_SIMULADA | FALLIDA
```

## `financial_process_status`

```text
CREADA | PROCESANDO | COMPLETADA | RECHAZADA | ERROR_REINTENTABLE | REVISION_MANUAL
```

## `withdrawal_status`

```text
SOLICITADO | EN_REVISION | APROBADO | COMPLETADO_SIMULADO | RECHAZADO | ERROR_REINTENTABLE | REVISION_MANUAL
```

## `vendor_profile_status`

```text
PENDING | ACTIVE | SUSPENDED | CLOSED
```

## `vendor_order_status`

```text
CREADA | PROCESANDO | CONFIRMADA | RECHAZADA | FALLIDA
```

## `inventory_batch_status`

```text
ACTIVE | DEPLETED | REVERSED
```

## `conversion_request_status`

```text
PENDIENTE | EN_PROCESO | COMPLETADA_POR_VENDEDOR | COMPLETADA_POR_PLATAFORMA | FALLIDA_POR_LIQUIDEZ
```

## `conversion_assignment_status`

```text
ACTIVA | LIBERADA | CONSUMIDA | CERRADA_SIN_EFECTO
```

## `risk_flag_status`

```text
OPEN | CONFIRMED | DISMISSED | RESOLVED
```

## `lottery_product_code`

```text
OCTAL | DECIMAL | HEXADECIMAL
```

## `version_status`

```text
DRAFT | PUBLISHED | RETIRED
```

## `template_status`

```text
BORRADOR | ACTIVA | PAUSADA | INACTIVA
```

## `draw_event_status`

```text
BORRADOR | PROGRAMADO | PUBLICADO | VENTAS_ABIERTAS | VENTAS_CERRADAS | CONGELADO | RESULTADO_FIJADO | PREMIOS_CALCULADOS | INFORME_PUBLICADO | FINALIZADO | CANCELADO
```

## `combination_status`

```text
DISPONIBLE | RESERVADA | VENDIDA | BLOQUEADA
```

## `purchase_session_status`

```text
ACTIVA | COMPLETADA | EXPIRADA | CERRADA_POR_EVENTO
```

## `cart_status`

```text
ABIERTO | CONFIRMADO | EXPIRADO | CANCELADO | INVALIDADO_POR_EVENTO
```

## `reservation_status`

```text
ACTIVA | CONSUMIDA | EXPIRADA | LIBERADA | INVALIDADA_POR_CIERRE | INVALIDADA_POR_CANCELACION
```

## `purchase_order_status`

```text
PENDIENTE | PROCESANDO | CONFIRMADA | RECHAZADA | ERROR_REINTENTABLE | REVISION_MANUAL
```

## `ticket_ownership_status`

```text
ACTIVO | REEMBOLSADO | ANULADO_POR_CORRECCION
```

## `ticket_evaluation_status`

```text
PENDIENTE_RESULTADO | NO_PREMIADO | DEVOLUCION | GANADOR_MAYOR
```

## `ticket_credit_status`

```text
NO_APLICA | PENDIENTE | ACREDITANDO | ACREDITADO | ERROR_REINTENTABLE | REVISION_MANUAL
```

## `fund_reservation_status`

```text
PENDIENTE | RESERVADA | CONSUMIDA | LIBERADA | CANCELADA
```

## `accumulation_transfer_status`

```text
PENDIENTE_ASIGNACION | ASIGNADA | APLICADA | DEVUELTA_AL_POOL | CANCELADA
```

## `commitment_status`

```text
GENERADO_SECRETO | PUBLICADO | REVELADO | INVALIDADO_POR_CANCELACION
```

## `snapshot_status`

```text
PENDIENTE | GENERADO | INVALIDADO_POR_CANCELACION
```

## `award_category`

```text
MAIN_PRIZE | NEAR_MATCH_REFUND | EVENT_REFUND | ADMIN_COMPENSATION
```

## `award_payment_status`

```text
CALCULADA | PREPARADA | ACREDITANDO | ACREDITADA | ERROR_REINTENTABLE | REVISION_MANUAL
```

## `report_status`

```text
PENDIENTE | PREPARADO | PUBLICADO | SUPERSEDED | ERROR_REINTENTABLE | REVISION_MANUAL
```

## `user_draw_visibility`

```text
PUBLICO | PRIVADO
```

## `user_draw_status`

```text
BORRADOR | PUBLICADO | VENTAS_ABIERTAS | VENTAS_CERRADAS | CONGELADO | RESULTADO_FIJADO | ENTREGA_PENDIENTE | FINALIZADO | CANCELADO | CERRADO_POR_INCUMPLIMIENTO
```

## `number_assignment_status`

```text
RESERVADA | ASIGNADA | LIBERADA | BLOQUEADA
```

## `number_change_status`

```text
SOLICITADA | CONFIRMADA | RECHAZADA
```

## `participation_payment_status`

```text
PENDIENTE | PAGADO | REEMBOLSANDO | REEMBOLSADO | FALLIDO
```

## `participation_relation_status`

```text
ACTIVO | ABANDONO_REGISTRADO | EXPULSADO
```

## `participation_eligibility_status`

```text
NO_ELEGIBLE | ACTIVA | EXCLUIDA
```

## `participation_number_status`

```text
ACTIVA | REEMPLAZADA | LIBERADA
```

## `code_use_status`

```text
EMITIDO | RECLAMADO | EXPIRADO
```

## `code_payment_status`

```text
PENDIENTE | PAGADO | REEMBOLSADO | FALLIDO
```

## `code_reservation_status`

```text
ACTIVA | CONSUMIDA | LIBERADA
```

## `invitation_status`

```text
PENDING | ACCEPTED | DECLINED | EXPIRED | REVOKED
```

## `delivery_status`

```text
PENDIENTE | REGISTRADA_POR_ORGANIZADOR | CONFIRMADA_POR_GANADOR | EN_RECLAMO | INCUMPLIMIENTO_CONFIRMADO | CERRADA
```

## `user_draw_claim_type`

```text
ACCESS | PAYMENT | NUMBER | REFUND | EXIT | EXPULSION | RESULT | PRIZE | DELIVERY
```

## `claim_status`

```text
PRESENTADO | EN_REVISION | ESPERANDO_EVIDENCIA | RESUELTO | RECHAZADO | APELADO | CERRADO
```

## `escrow_status`

```text
RETENIDA | LIBERABLE | EN_DISPUTA | LIBERANDO | LIBERADA | REEMBOLSO_ORDENADO | REEMBOLSANDO | REEMBOLSADA
```

## `stored_object_status`

```text
PENDING | AVAILABLE | QUARANTINED | DELETED
```

## `outbox_status`

```text
PENDING | PUBLISHED | FAILED | DEAD_LETTER
```

## `inbox_status`

```text
RECEIVED | PROCESSED | FAILED
```

## `job_status`

```text
PROGRAMADO | EJECUTANDO | COMPLETADO | ESPERANDO_REINTENTO | REVISION_MANUAL | CANCELADO | SIN_EFECTO_IDEMPOTENTE
```

## `security_severity`

```text
LOW | MEDIUM | HIGH | CRITICAL
```

## `notification_status`

```text
PENDING | SENT | FAILED | READ | CANCELLED
```

# 2. Cobertura general

| Dominio | Cantidad de tablas |
|---|---:|
| Compra oficial | 8 |
| Finanzas | 11 |
| Fondos | 6 |
| Identidad | 15 |
| Lotería oficial | 11 |
| Resultado oficial | 9 |
| Sistema | 10 |
| Sorteos de usuarios | 22 |
| Vendedores | 9 |
| **Total** | **101** |

| Tabla | Dominio | Fuente | Propósito |
|---|---|---|---|
| `cart_items` | Compra oficial | Plan 6.3 | Reservas dentro del carrito. |
| `combination_reservations` | Compra oficial | Plan 6.3 | Reserva exclusiva de hasta cinco minutos, limitada por el cierre. |
| `purchase_orders` | Compra oficial | Plan 6.3 | Orden idempotente que confirma boletos. |
| `purchase_sessions` | Compra oficial | Plan 6.3 | Sesión temporal de compra. |
| `shopping_carts` | Compra oficial | Plan 6.3 | Carrito asociado a la sesión. |
| `ticket_numbers` | Compra oficial | Plan 6.3 | Símbolos del boleto. |
| `ticket_status_history` | Compra oficial | Plan 6.3 | Historial multidimensional de propiedad, evaluación y crédito. |
| `tickets` | Compra oficial | Plan 6.3 | Boleto pagado e inmutable. |
| `idempotency_keys` | Finanzas | Plan 6.3 | Deduplicación de comandos y respuesta persistida. |
| `ledger_accounts` | Finanzas | Plan 6.3 | Cuentas del subledger para usuarios, plataforma, eventos, fondos y escrow. |
| `ledger_entries` | Finanzas | Plan 6.3 | Débitos y créditos. |
| `ledger_transactions` | Finanzas | Plan 6.3 | Cabecera inmutable de operación financiera. |
| `payment_provider_events` | Finanzas | Plan 6.3 | Eventos externos deduplicados y sanitizados. |
| `real_topups` | Finanzas | Plan 6.3 | Recargas REAL simuladas o futuras. |
| `virtual_to_real_conversions` | Finanzas | Plan 6.3 | Conversión VIRTUAL→REAL con 10 %. |
| `virtual_transfers` | Finanzas | Plan 6.3 | Transferencias VIRTUAL entre clientes. |
| `wallet_balance_projections` | Finanzas | Plan 6.3 | Proyección reconstruible de saldo. |
| `wallets` | Finanzas | Plan 6.3 | Wallet por usuario y unidad; no guarda el saldo autoritativo. |
| `withdrawal_requests` | Finanzas | Plan 6.3 | Retiros REAL simulados. |
| `accumulation_pools` | Fondos | Plan 6.3 | Pool por producto. |
| `accumulation_transfers` | Fondos | Plan 6.3 | Asignación y retorno de acumulado. |
| `fund_movements` | Fondos | Plan 6.3 | Trazabilidad semántica de movimientos. |
| `future_prize_fund` | Fondos | Plan 6.3 | Fondo VIRTUAL para premios futuros. |
| `guarantee_fund` | Fondos | Plan 6.3 | Metadatos del fondo general. |
| `guarantee_fund_reservations` | Fondos | Plan 6.3 | Cobertura bloqueada por evento. |
| `devices` | Identidad | Plan 6.3 | Dispositivos conocidos y metadatos de seguridad. |
| `login_attempts` | Identidad | Plan 6.3 | Intentos de autenticación y señales de abuso. |
| `password_resets` | Identidad | Plan 6.3 | Recuperación de contraseña de un uso. |
| `permissions` | Identidad | Plan 6.3 | Catálogo estable de acciones autorizables. |
| `refresh_tokens` | Identidad | Plan 6.3 | Tokens rotatorios almacenados mediante hash. |
| `role_permissions` | Identidad | Plan 6.3 | Permisos predeterminados por rol. |
| `roles` | Identidad | Plan 6.3 | Catálogo de roles globales. |
| `sessions` | Identidad | Plan 6.3 | Sesiones activas y modo. |
| `terms_acceptances` | Identidad | Plan 6.3 | Aceptación trazable de una versión. |
| `terms_versions` | Identidad | Plan 6.3 | Versiones inmutables de términos y privacidad. |
| `user_permission_grants` | Identidad | Derivada de matriz | Concesiones granulares directas para administradores. |
| `user_profiles` | Identidad | Plan 6.3 | Datos personales y contacto separados de credenciales. |
| `user_roles` | Identidad | Plan 6.3 | Roles asignados con vigencia y revocación. |
| `users` | Identidad | Plan 6.3 | Cuenta principal, credenciales de referencia y estado. |
| `verification_tokens` | Identidad | Plan 6.3 | Verificación de correo/teléfono. |
| `combination_numbers` | Lotería oficial | Plan 6.3 | Símbolos de la combinación para búsqueda parcial. |
| `draw_event_status_history` | Lotería oficial | Plan 6.3 | Historial append-only del evento. |
| `draw_events` | Lotería oficial | Plan 6.3 | Evento oficial concreto. |
| `event_combinations` | Lotería oficial | Plan 6.3 | Catálogo único de combinaciones. |
| `event_financial_configs` | Lotería oficial | Plan 6.3 | Configuración económica congelada por evento. |
| `event_financial_projections` | Lotería oficial | Derivada | Proyección reconstruible de ventas y premio. |
| `event_templates` | Lotería oficial | Plan 6.3 | Autogeneradores de eventos. |
| `lottery_products` | Lotería oficial | Plan 6.3 | Productos Octal, Decimal y Hexadecimal. |
| `prize_rule_versions` | Lotería oficial | Plan 6.3 | Reglas económicas inmutables. |
| `rule_versions` | Lotería oficial | Plan 6.3 | Reglas matemáticas históricas por producto. |
| `template_schedules` | Lotería oficial | Plan 6.3 | Horarios, días y recurrencias. |
| `award_payment_orders` | Resultado oficial | Plan 6.3 | Orden idempotente de acreditación. |
| `draw_commitments` | Resultado oficial | Plan 6.3 | Commitment y semilla cifrada. |
| `draw_result_numbers` | Resultado oficial | Plan 6.3 | Símbolos ganadores y orden visual. |
| `draw_results` | Resultado oficial | Plan 6.3 | Resultado único e inmutable. |
| `draw_snapshot_tickets` | Resultado oficial | Derivada | Contenido relacional del snapshot. |
| `draw_snapshots` | Resultado oficial | Plan 6.3 | Snapshot de boletos elegibles. |
| `prize_awards` | Resultado oficial | Plan 6.3 | Obligación calculada por boleto y categoría. |
| `result_reports` | Resultado oficial | Plan 6.3 | Boletín público estructurado. |
| `ticket_evaluations` | Resultado oficial | Plan 6.3 | Evaluación inmutable por boleto. |
| `audit_events` | Sistema | Plan 6.3 | Auditoría administrativa, financiera y de seguridad. |
| `inbox_events` | Sistema | Plan 6.3 | Deduplicación de mensajes consumidos. |
| `job_runs` | Sistema | Plan 6.3 | Intentos de ejecución. |
| `notification_preferences` | Sistema | Derivada | Preferencias por usuario, tipo y canal. |
| `notifications` | Sistema | Plan 6.3 | Avisos opcionales. |
| `outbox_events` | Sistema | Plan 6.3 | Eventos de dominio posteriores al commit. |
| `scheduled_jobs` | Sistema | Plan 6.3 | Trabajos persistentes. |
| `security_events` | Sistema | Plan 6.3 | Alertas y patrones de riesgo. |
| `stored_objects` | Sistema | Derivada de arquitectura | Metadatos de archivos S3 compatibles. |
| `system_settings` | Sistema | Plan 6.3 | Configuración operativa no histórica. |
| `user_draw_access_code_events` | Sorteos de usuarios | Derivada | Historial de uso, pago y reserva del código. |
| `user_draw_access_code_numbers` | Sorteos de usuarios | Derivada | Números reservados por un código. |
| `user_draw_access_codes` | Sorteos de usuarios | ADR-ORG-001 | Código privado de un uso. |
| `user_draw_announcements` | Sorteos de usuarios | Derivada | Anuncios internos. |
| `user_draw_claim_events` | Sorteos de usuarios | Derivada | Historial del reclamo. |
| `user_draw_claim_evidence` | Sorteos de usuarios | Derivada | Evidencia de reclamo. |
| `user_draw_claims` | Sorteos de usuarios | ADR-ORG-001 | Reclamo administrativo. |
| `user_draw_delivery_records` | Sorteos de usuarios | ADR-ORG-001 | Evidencia y confirmación de entrega. |
| `user_draw_escrow_events` | Sorteos de usuarios | Derivada | Historial del escrow. |
| `user_draw_escrows` | Sorteos de usuarios | ADR-ORG-001 | Control del 95 % y comisión 5 % retenida. |
| `user_draw_invitations` | Sorteos de usuarios | Derivada | Invitaciones privadas alternativas al código. |
| `user_draw_number_changes` | Sorteos de usuarios | ADR-ORG-001 | Cambio atómico de número. |
| `user_draw_numbers` | Sorteos de usuarios | Derivada | Números del rango y asignación. |
| `user_draw_participation_events` | Sorteos de usuarios | Derivada | Historial de pago, relación, elegibilidad y número. |
| `user_draw_participations` | Sorteos de usuarios | ADR-ORG-001 | Participación con estados separados. |
| `user_draw_participation_numbers` | Sorteos de usuarios | Derivada de códigos grupales | Asignaciones de uno o varios números a una participación económica. |
| `user_draw_prize_evidence` | Sorteos de usuarios | ADR-ORG-001 | Evidencia de existencia/disponibilidad del premio. |
| `user_draw_results` | Sorteos de usuarios | ADR-ORG-001 | Ganador único generado por CSPRNG. |
| `user_draw_snapshot_entries` | Sorteos de usuarios | Derivada | Contenido del snapshot. |
| `user_draw_snapshots` | Sorteos de usuarios | ADR-ORG-001 | Snapshot de participaciones PAGADO+ACTIVA. |
| `user_draw_status_history` | Sorteos de usuarios | Derivada | Historial del sorteo de usuario. |
| `user_draws` | Sorteos de usuarios | ADR-ORG-001 | Sorteo creado por un Organizador contextual. |
| `conversion_assignments` | Vendedores | Plan 6.3 | Asignación atómica a Vendedor. |
| `conversion_request_events` | Vendedores | Plan 6.3 | Historial de estados de solicitud. |
| `conversion_requests` | Vendedores | Plan 6.3 | Solicitud REAL→VIRTUAL con reserva y fallback. |
| `related_account_flags` | Vendedores | Plan 6.3 | Vínculos y alertas antifraude. |
| `vendor_inventory_batches` | Vendedores | Plan 6.3 | Lotes VIRTUAL con coste histórico. |
| `vendor_profiles` | Vendedores | Plan 6.3 | Estado y habilitación del Vendedor. |
| `vendor_purchase_orders` | Vendedores | Plan 6.3 | Compra mayorista 0,90 REAL→1,00 VIRTUAL. |
| `vendor_sale_batch_allocations` | Vendedores | Derivada | Consumo de lotes para coste y ganancia realizada. |
| `vendor_sales` | Vendedores | Plan 6.3 | Venta realizada y ganancia verificable. |

# 3. Definición de tablas

# Compra oficial

## `cart_items`

**Propósito:** Reservas dentro del carrito.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-EVT-011`, `LOT-EVT-016`  

**Campos mínimos**

- `id:UUID PK`
- `shopping_cart_id:UUID FK shopping_carts`
- `reservation_id:UUID FK combination_reservations UQ`
- `combination_id:UUID FK event_combinations`
- `unit_price_virtual_minor:BIGINT`
- `added_at:TIMESTAMPTZ`
- `created_at`

**Restricciones mínimas**

- UNIQUE(cart,combination)

## `combination_reservations`

**Propósito:** Reserva exclusiva de hasta cinco minutos, limitada por el cierre.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-EVT-011`, `LOT-EVT-012`, `LOT-EVT-014`  

**Campos mínimos**

- `id:UUID PK`
- `combination_id:UUID FK event_combinations`
- `draw_event_id:UUID FK draw_events`
- `user_id:UUID FK users`
- `purchase_session_id:UUID FK purchase_sessions`
- `status:reservation_status`
- `reserved_at:TIMESTAMPTZ`
- `expires_at:TIMESTAMPTZ`
- `consumed_at:TIMESTAMPTZ?`
- `released_at:TIMESTAMPTZ?`
- `created_at`

**Restricciones mínimas**

- Una ACTIVA por combinación
- expires_at=reserved_at+5min sin superar cierre
- Cuenta para 20%
- `draw_event_id` y `user_id` coinciden con combinación y sesión mediante integridad compuesta

## `purchase_orders`

**Propósito:** Orden idempotente que confirma boletos.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-EVT-012`, `LOT-EVT-014`, `LOT-EVT-016`  

**Campos mínimos**

- `id:UUID PK`
- `public_id:VARCHAR(40) UQ`
- `user_id:UUID FK users`
- `draw_event_id:UUID FK draw_events`
- `shopping_cart_id:UUID FK shopping_carts UQ`
- `status:purchase_order_status`
- `ticket_count:INTEGER`
- `total_virtual_minor:BIGINT`
- `ledger_transaction_id:UUID? FK ledger_transactions UQ`
- `idempotency_key_id:UUID FK idempotency_keys`
- `confirmed_at:TIMESTAMPTZ?`
- `rejection_code:VARCHAR(80)?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Confirmada exige ledger y tickets
- Total suma tickets

## `purchase_sessions`

**Propósito:** Sesión temporal de compra.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-EVT-010`, `LOT-EVT-012`, `LOT-EVT-015`  

**Campos mínimos**

- `id:UUID PK`
- `user_id:UUID FK users`
- `draw_event_id:UUID FK draw_events`
- `status:purchase_session_status`
- `expires_at:TIMESTAMPTZ`
- `completed_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- expires_at<=event.close

## `shopping_carts`

**Propósito:** Carrito asociado a la sesión.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-EVT-011`, `LOT-EVT-015`  

**Campos mínimos**

- `id:UUID PK`
- `purchase_session_id:UUID FK purchase_sessions UQ`
- `user_id:UUID FK users`
- `draw_event_id:UUID FK draw_events`
- `status:cart_status`
- `expires_at:TIMESTAMPTZ`
- `confirmed_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Usuario y evento coinciden con sesión

## `ticket_numbers`

**Propósito:** Símbolos del boleto.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-EVT-002`, `LOT-EVT-003`  

**Campos mínimos**

- `id:UUID PK`
- `ticket_id:UUID FK tickets`
- `symbol:VARCHAR(2)`
- `sort_order:SMALLINT`
- `created_at`

**Restricciones mínimas**

- UNIQUE(ticket,symbol)
- UNIQUE(ticket,sort_order)

## `ticket_status_history`

**Propósito:** Historial multidimensional de propiedad, evaluación y crédito.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-EVT-017`, `LOT-EVT-020`, `LOT-PRZ-017`  

**Campos mínimos**

- `id:UUID PK`
- `ticket_id:UUID FK tickets`
- `dimension:VARCHAR(30)`
- `from_status:VARCHAR(50)?`
- `to_status:VARCHAR(50)`
- `transition_code:VARCHAR(80)`
- `actor_type:actor_type`
- `actor_user_id:UUID? FK users`
- `reason:TEXT?`
- `correlation_id:UUID`
- `occurred_at:TIMESTAMPTZ`
- `created_at`

**Restricciones mínimas**

- Append-only

## `tickets`

**Propósito:** Boleto pagado e inmutable.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-EVT-001`, `LOT-EVT-016`, `LOT-EVT-017`, `LOT-EVT-020`  

**Campos mínimos**

- `id:UUID PK`
- `public_id:VARCHAR(50) UQ`
- `purchase_order_id:UUID FK purchase_orders`
- `user_id:UUID FK users`
- `draw_event_id:UUID FK draw_events`
- `combination_id:UUID FK event_combinations UQ`
- `rule_version_id:UUID FK rule_versions`
- `normalized_key:VARCHAR(80)`
- `price_virtual_minor:BIGINT`
- `ownership_status:ticket_ownership_status`
- `evaluation_status:ticket_evaluation_status`
- `credit_status:ticket_credit_status`
- `purchase_ledger_transaction_id:UUID FK ledger_transactions`
- `purchased_at:TIMESTAMPTZ`
- `created_at`

**Restricciones mínimas**

- UNIQUE(event,normalized_key)
- rule_version coincide con evento
- usuario, evento y combinación coinciden con la orden y sus relaciones mediante integridad compuesta
- No DELETE

# Finanzas

## `idempotency_keys`

**Propósito:** Deduplicación de comandos y respuesta persistida.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-GOV-003`, `LOT-FIN-012`  

**Campos mínimos**

- `id:UUID PK`
- `subject_user_id:UUID? FK users`
- `scope:VARCHAR(120)`
- `key_value:VARCHAR(200)`
- `request_hash:VARCHAR(128)`
- `status:idempotency_status`
- `response_status:INTEGER?`
- `response_body:JSONB?`
- `resource_type:VARCHAR(80)?`
- `resource_id:UUID?`
- `locked_at:TIMESTAMPTZ?`
- `expires_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- `UNIQUE NULLS NOT DISTINCT(subject_user_id,scope,key_value)` en PostgreSQL 16, para deduplicar también comandos `SYSTEM`
- Misma clave+cuerpo distinto se rechaza

## `ledger_accounts`

**Propósito:** Cuentas del subledger para usuarios, plataforma, eventos, fondos y escrow.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-FIN-005`, `LOT-FIN-006`, `LOT-FIN-007`  

**Campos mínimos**

- `id:UUID PK`
- `account_code:VARCHAR(120) UQ`
- `currency:currency_code`
- `account_type:ledger_account_type`
- `wallet_id:UUID? FK wallets`
- `user_id:UUID? FK users`
- `draw_event_id:UUID? FK draw_events`
- `user_draw_id:UUID? FK user_draws`
- `allows_negative:BOOLEAN`
- `is_active:BOOLEAN`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Moneda inmutable
- `account_type` debe corresponder al catálogo financiero congelado en `FLUJOS-FINANCIEROS.md`
- El ámbito se expresa mediante wallet, usuario, evento oficial o sorteo de usuario; los fondos apuntan a su cuenta desde sus propias tablas para evitar FKs circulares
- En el MVP académico, `allows_negative=TRUE` solo para `SIMULATED_TOPUP_SOURCE_REAL` y `PLATFORM_VIRTUAL_ISSUANCE`; todas las demás cuentas deben permanecer no negativas
- No borrar con asientos

## `ledger_entries`

**Propósito:** Débitos y créditos.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-FIN-005`, `LOT-GOV-006`  

**Campos mínimos**

- `id:UUID PK`
- `ledger_transaction_id:UUID FK ledger_transactions`
- `account_id:UUID FK ledger_accounts`
- `reversal_of_entry_id:UUID? FK ledger_entries`
- `currency:currency_code`
- `side:ledger_side`
- `amount_minor:BIGINT`
- `sequence:SMALLINT`
- `memo_code:VARCHAR(100)`
- `created_at`

**Restricciones mínimas**

- amount_minor>0
- currency=account.currency
- UNIQUE(transaction,sequence)
- `reversal_of_entry_id` solo se usa en compensaciones y debe apuntar a un asiento de igual moneda
- La suma de asientos compensatorios vinculados a una entrada original no puede superar `amount_minor`

## `ledger_transactions`

**Propósito:** Cabecera inmutable de operación financiera.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-FIN-005`, `LOT-FIN-012`, `LOT-GOV-004`  

**Campos mínimos**

- `id:UUID PK`
- `transaction_type:VARCHAR(100)`
- `status:ledger_transaction_status`
- `correlation_id:UUID`
- `idempotency_key_id:UUID? FK idempotency_keys`
- `reversal_of_transaction_id:UUID? FK ledger_transactions`
- `business_reference_type:VARCHAR(80)`
- `business_reference_id:UUID`
- `rule_version_id:UUID? FK rule_versions`
- `description:TEXT?`
- `calculation_snapshot:JSONB?`
- `posted_at:TIMESTAMPTZ`
- `created_at`

**Restricciones mínimas**

- Balance por moneda
- Reverso mediante nueva transacción
- `calculation_snapshot` conserva tasas, residuos, prioridad y política cuando existe reparto
- Sin edición destructiva

## `payment_provider_events`

**Propósito:** Eventos externos deduplicados y sanitizados.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-GOV-003`, `LOT-AUD-002`  

**Campos mínimos**

- `id:UUID PK`
- `provider:VARCHAR(50)`
- `external_event_id:VARCHAR(180)`
- `event_type:VARCHAR(100)`
- `payload_hash:VARCHAR(128)`
- `sanitized_payload:JSONB?`
- `received_at:TIMESTAMPTZ`
- `processed_at:TIMESTAMPTZ?`
- `processing_error:TEXT?`
- `created_at`

**Restricciones mínimas**

- UNIQUE(provider,external_event_id)
- Sin datos de tarjeta

## `real_topups`

**Propósito:** Recargas REAL simuladas o futuras.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-FIN-008`, `LOT-GOV-008`  

**Campos mínimos**

- `id:UUID PK`
- `user_id:UUID FK users`
- `wallet_id:UUID FK wallets`
- `provider_type:VARCHAR(40)`
- `provider_reference:VARCHAR(150)?`
- `amount_real_minor:BIGINT`
- `status:topup_status`
- `ledger_transaction_id:UUID? FK ledger_transactions UQ`
- `idempotency_key_id:UUID FK idempotency_keys`
- `confirmed_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Monto>0
- Ledger obligatorio al confirmar
- SIMULATED en MVP

## `virtual_to_real_conversions`

**Propósito:** Conversión VIRTUAL→REAL con 10 %.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-FIN-009`, `LOT-FIN-012`, `LOT-FIN-013`  

**Campos mínimos**

- `id:UUID PK`
- `user_id:UUID FK users`
- `virtual_wallet_id:UUID FK wallets`
- `real_wallet_id:UUID FK wallets`
- `gross_virtual_minor:BIGINT`
- `fee_virtual_minor:BIGINT`
- `net_real_minor:BIGINT`
- `fee_rate_bps:INTEGER`
- `allocation_policy_code:VARCHAR(60)`
- `calculation_snapshot:JSONB`
- `status:financial_process_status`
- `ledger_transaction_id:UUID? FK ledger_transactions UQ`
- `idempotency_key_id:UUID FK idempotency_keys`
- `completed_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- gross=fee+net según `LOT-FIN-013`
- El cálculo conserva cuotas, residuos y prioridad
- Balances REAL/VIRTUAL separados

## `virtual_transfers`

**Propósito:** Transferencias VIRTUAL entre clientes.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-FIN-011`, `LOT-FIN-012`  

**Campos mínimos**

- `id:UUID PK`
- `sender_user_id:UUID FK users`
- `recipient_user_id:UUID FK users`
- `amount_virtual_minor:BIGINT`
- `status:financial_process_status`
- `ledger_transaction_id:UUID? FK ledger_transactions UQ`
- `idempotency_key_id:UUID FK idempotency_keys`
- `completed_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- sender<>recipient
- Monto>0
- Ambos activos

## `wallet_balance_projections`

**Propósito:** Proyección reconstruible de saldo.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-FIN-006`, `LOT-FIN-007`  

**Campos mínimos**

- `id:UUID PK`
- `wallet_id:UUID FK wallets UQ`
- `available_minor:BIGINT`
- `reserved_minor:BIGINT`
- `pending_minor:BIGINT`
- `blocked_minor:BIGINT`
- `in_withdrawal_minor:BIGINT`
- `ledger_version:BIGINT`
- `calculated_at:TIMESTAMPTZ`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- No es fuente de verdad
- Componentes no negativos salvo cuenta técnica

## `wallets`

**Propósito:** Wallet por usuario y unidad; no guarda el saldo autoritativo.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-FIN-001`, `LOT-FIN-004`, `LOT-FIN-006`  

**Campos mínimos**

- `id:UUID PK`
- `user_id:UUID FK users`
- `currency:currency_code`
- `status:wallet_status`
- `closed_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- UNIQUE(user_id,currency)

## `withdrawal_requests`

**Propósito:** Retiros REAL simulados.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-FIN-010`, `LOT-GOV-008`  

**Campos mínimos**

- `id:UUID PK`
- `user_id:UUID FK users`
- `real_wallet_id:UUID FK wallets`
- `amount_real_minor:BIGINT`
- `status:withdrawal_status`
- `reserve_ledger_transaction_id:UUID? FK ledger_transactions UQ`
- `settlement_ledger_transaction_id:UUID? FK ledger_transactions UQ`
- `provider_reference:VARCHAR(150)?`
- `reviewed_by_user_id:UUID? FK users`
- `review_reason:TEXT?`
- `completed_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Monto>0
- Sin segunda comisión en v1

# Fondos

## `accumulation_pools`

**Propósito:** Pool por producto.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-PRZ-009`, `LOT-PRZ-011`  

**Campos mínimos**

- `id:UUID PK`
- `lottery_product_id:UUID FK lottery_products UQ`
- `ledger_account_id:UUID FK ledger_accounts UQ`
- `is_active:BOOLEAN`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Uno por producto

## `accumulation_transfers`

**Propósito:** Asignación y retorno de acumulado.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-PRZ-009`, `LOT-PRZ-011`  

**Campos mínimos**

- `id:UUID PK`
- `accumulation_pool_id:UUID FK accumulation_pools`
- `source_draw_event_id:UUID FK draw_events`
- `target_draw_event_id:UUID? FK draw_events`
- `amount_virtual_minor:BIGINT`
- `status:accumulation_transfer_status`
- `assign_ledger_transaction_id:UUID? FK ledger_transactions UQ`
- `return_ledger_transaction_id:UUID? FK ledger_transactions UQ`
- `assigned_at:TIMESTAMPTZ?`
- `applied_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Origen/destino mismo producto
- No doble asignación

## `fund_movements`

**Propósito:** Trazabilidad semántica de movimientos.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-FIN-012`, `LOT-PRZ-007`, `LOT-PRZ-009`  

**Campos mínimos**

- `id:UUID PK`
- `fund_type:VARCHAR(50)`
- `fund_reference_id:UUID`
- `movement_type:VARCHAR(80)`
- `amount_virtual_minor:BIGINT`
- `ledger_transaction_id:UUID FK ledger_transactions UQ`
- `draw_event_id:UUID? FK draw_events`
- `actor_user_id:UUID? FK users`
- `reason:TEXT`
- `created_at`

**Restricciones mínimas**

- No sustituye ledger
- Monto>0

## `future_prize_fund`

**Propósito:** Fondo VIRTUAL para premios futuros.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-PRZ-009`, `LOT-PRZ-010`  

**Campos mínimos**

- `id:UUID PK`
- `code:VARCHAR(50) UQ`
- `ledger_account_id:UUID FK ledger_accounts UQ`
- `is_active:BOOLEAN`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Solo movimientos con permiso y motivo

## `guarantee_fund`

**Propósito:** Metadatos del fondo general.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-PRZ-007`, `LOT-PRZ-008`  

**Campos mínimos**

- `id:UUID PK`
- `code:VARCHAR(50) UQ`
- `currency:currency_code`
- `ledger_account_id:UUID FK ledger_accounts UQ`
- `base_emergency_minor:BIGINT`
- `is_active:BOOLEAN`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- currency=VIRTUAL
- Un fondo general activo

## `guarantee_fund_reservations`

**Propósito:** Cobertura bloqueada por evento.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-PRZ-007`, `LOT-PRZ-008`  

**Campos mínimos**

- `id:UUID PK`
- `guarantee_fund_id:UUID FK guarantee_fund`
- `draw_event_id:UUID FK draw_events UQ`
- `reserved_ledger_account_id:UUID FK ledger_accounts UQ`
- `amount_virtual_minor:BIGINT`
- `status:fund_reservation_status`
- `reservation_ledger_transaction_id:UUID? FK ledger_transactions UQ`
- `settlement_ledger_transaction_id:UUID? FK ledger_transactions UQ`
- `reserved_at:TIMESTAMPTZ?`
- `settled_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Una reserva por evento
- Monto>0

# Identidad

## `devices`

**Propósito:** Dispositivos conocidos y metadatos de seguridad.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-IAM-002`, `LOT-AUD-006`  

**Campos mínimos**

- `id:UUID PK`
- `user_id:UUID FK users`
- `device_public_id:VARCHAR(100)`
- `platform:VARCHAR(30)`
- `display_name:VARCHAR(120)?`
- `trusted_at:TIMESTAMPTZ?`
- `last_seen_at:TIMESTAMPTZ?`
- `revoked_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- UNIQUE(user_id,device_public_id)

## `login_attempts`

**Propósito:** Intentos de autenticación y señales de abuso.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-IAM-008`, `LOT-AUD-006`  

**Campos mínimos**

- `id:UUID PK`
- `user_id:UUID? FK users`
- `identifier_hash:VARCHAR(128)`
- `ip_hash:VARCHAR(128)?`
- `device_id:UUID? FK devices`
- `succeeded:BOOLEAN`
- `failure_code:VARCHAR(80)?`
- `occurred_at:TIMESTAMPTZ`
- `created_at`

**Restricciones mínimas**

- No guardar credencial ingresada

## `password_resets`

**Propósito:** Recuperación de contraseña de un uso.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-IAM-007`, `LOT-AUD-006`  

**Campos mínimos**

- `id:UUID PK`
- `user_id:UUID FK users`
- `token_hash:VARCHAR(255) UQ`
- `expires_at:TIMESTAMPTZ`
- `used_at:TIMESTAMPTZ?`
- `requested_ip_hash:VARCHAR(128)?`
- `created_at`

**Restricciones mínimas**

- Un solo consumo
- Token nunca en claro

## `permissions`

**Propósito:** Catálogo estable de acciones autorizables.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-IAM-005`, `LOT-IAM-006`  

**Campos mínimos**

- `id:UUID PK`
- `permission_key:VARCHAR(150) UQ`
- `resource_type:VARCHAR(80)`
- `action:VARCHAR(80)`
- `description:TEXT`
- `is_sensitive:BOOLEAN`
- `is_active:BOOLEAN`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Las claves provienen de MATRIZ-DE-PERMISOS.md

## `refresh_tokens`

**Propósito:** Tokens rotatorios almacenados mediante hash.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-IAM-002`, `LOT-AUD-006`  

**Campos mínimos**

- `id:UUID PK`
- `session_id:UUID FK sessions`
- `token_hash:VARCHAR(255) UQ`
- `family_id:UUID`
- `rotated_from_id:UUID? FK refresh_tokens`
- `expires_at:TIMESTAMPTZ`
- `used_at:TIMESTAMPTZ?`
- `revoked_at:TIMESTAMPTZ?`
- `created_at`

**Restricciones mínimas**

- Un token usado no vuelve a ser válido

## `role_permissions`

**Propósito:** Permisos predeterminados por rol.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-IAM-005`  

**Campos mínimos**

- `id:UUID PK`
- `role_id:UUID FK roles`
- `permission_id:UUID FK permissions`
- `granted_by_user_id:UUID? FK users`
- `granted_at:TIMESTAMPTZ`
- `created_at`

**Restricciones mínimas**

- UNIQUE(role_id,permission_id)

## `roles`

**Propósito:** Catálogo de roles globales.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-IAM-001`  

**Campos mínimos**

- `id:UUID PK`
- `code:VARCHAR(40) UQ`
- `name:VARCHAR(100)`
- `description:TEXT?`
- `is_system:BOOLEAN`
- `is_active:BOOLEAN`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- CLIENTE, VENDEDOR y ADMINISTRADOR
- ORGANIZADOR no es rol global

## `sessions`

**Propósito:** Sesiones activas y modo.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-IAM-002`, `LOT-IAM-006`  

**Campos mínimos**

- `id:UUID PK`
- `user_id:UUID FK users`
- `device_id:UUID? FK devices`
- `status:session_status`
- `active_mode:active_mode`
- `ip_hash:VARCHAR(128)?`
- `user_agent_hash:VARCHAR(128)?`
- `last_seen_at:TIMESTAMPTZ?`
- `expires_at:TIMESTAMPTZ`
- `revoked_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Modo compatible con roles
- Hora del servidor

## `terms_acceptances`

**Propósito:** Aceptación trazable de una versión.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-IAM-007`  

**Campos mínimos**

- `id:UUID PK`
- `user_id:UUID FK users`
- `terms_version_id:UUID FK terms_versions`
- `session_id:UUID? FK sessions`
- `accepted_at:TIMESTAMPTZ`
- `ip_hash:VARCHAR(128)?`
- `created_at`

**Restricciones mínimas**

- UNIQUE(user_id,terms_version_id)

## `terms_versions`

**Propósito:** Versiones inmutables de términos y privacidad.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-IAM-007`, `LOT-GOV-004`  

**Campos mínimos**

- `id:UUID PK`
- `document_type:VARCHAR(40)`
- `version:VARCHAR(30)`
- `content_hash:VARCHAR(128)`
- `stored_object_id:UUID? FK stored_objects`
- `effective_at:TIMESTAMPTZ`
- `retired_at:TIMESTAMPTZ?`
- `created_at`

**Restricciones mínimas**

- UNIQUE(document_type,version)
- No editar versión aceptada

## `user_permission_grants`

**Propósito:** Concesiones granulares directas para administradores.  
**Fuente:** Derivada de matriz  
**Reglas:** `LOT-IAM-005`, `LOT-AUD-003`  

**Campos mínimos**

- `id:UUID PK`
- `user_id:UUID FK users`
- `permission_id:UUID FK permissions`
- `granted_by_user_id:UUID FK users`
- `valid_from:TIMESTAMPTZ`
- `valid_until:TIMESTAMPTZ?`
- `revoked_at:TIMESTAMPTZ?`
- `reason:TEXT`
- `created_at`

**Restricciones mínimas**

- Una concesión activa por usuario+permiso
- Motivo obligatorio

## `user_profiles`

**Propósito:** Datos personales y contacto separados de credenciales.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-IAM-007`, `LOT-AUD-002`  

**Campos mínimos**

- `id:UUID PK`
- `user_id:UUID FK users UQ`
- `first_name:VARCHAR(100)`
- `last_name:VARCHAR(100)`
- `document_type:VARCHAR(30)`
- `document_number_hash:VARCHAR(128) UQ`
- `document_number_encrypted:BYTEA`
- `birth_date:DATE`
- `phone_e164:VARCHAR(20)? UQ`
- `address_text:TEXT?`
- `country_code:CHAR(2)`
- `timezone:VARCHAR(64)`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Mayoría de edad
- Documento único mediante hash normalizado
- Valor cifrado y nunca expuesto públicamente

## `user_roles`

**Propósito:** Roles asignados con vigencia y revocación.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-IAM-001`, `LOT-IAM-002`, `LOT-IAM-005`  

**Campos mínimos**

- `id:UUID PK`
- `user_id:UUID FK users`
- `role_id:UUID FK roles`
- `assigned_by_user_id:UUID? FK users`
- `valid_from:TIMESTAMPTZ`
- `valid_until:TIMESTAMPTZ?`
- `revoked_at:TIMESTAMPTZ?`
- `reason:TEXT?`
- `created_at`

**Restricciones mínimas**

- Una asignación activa por usuario+rol
- valid_until > valid_from

## `users`

**Propósito:** Cuenta principal, credenciales de referencia y estado.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-IAM-007`, `LOT-IAM-008`, `LOT-IAM-009`  

**Campos mínimos**

- `id:UUID PK`
- `public_id:VARCHAR(32) UQ`
- `email:CITEXT UQ`
- `username:CITEXT UQ`
- `password_hash:TEXT`
- `status:account_status`
- `email_verified_at:TIMESTAMPTZ?`
- `phone_verified_at:TIMESTAMPTZ?`
- `deactivated_at:TIMESTAMPTZ?`
- `created_at:TIMESTAMPTZ`
- `updated_at:TIMESTAMPTZ`

**Restricciones mínimas**

- No DELETE físico con historial
- Solo ACTIVO inicia operaciones

## `verification_tokens`

**Propósito:** Verificación de correo/teléfono.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-IAM-007`  

**Campos mínimos**

- `id:UUID PK`
- `user_id:UUID FK users`
- `channel:verification_channel`
- `purpose:verification_purpose`
- `target_hash:VARCHAR(255)`
- `token_hash:VARCHAR(255) UQ`
- `expires_at:TIMESTAMPTZ`
- `consumed_at:TIMESTAMPTZ?`
- `created_at`

**Restricciones mínimas**

- Un solo consumo

# Lotería oficial

## `combination_numbers`

**Propósito:** Símbolos de la combinación para búsqueda parcial.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-EVT-002`, `LOT-EVT-003`, `LOT-EVT-015`  

**Campos mínimos**

- `id:UUID PK`
- `combination_id:UUID FK event_combinations`
- `draw_event_id:UUID FK draw_events`
- `symbol:VARCHAR(2)`
- `sort_order:SMALLINT`
- `created_at`

**Restricciones mínimas**

- UNIQUE(combination,symbol)
- UNIQUE(combination,sort_order)

## `draw_event_status_history`

**Propósito:** Historial append-only del evento.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-EVT-020`, `LOT-AUD-001`  

**Campos mínimos**

- `id:UUID PK`
- `draw_event_id:UUID FK draw_events`
- `from_status:draw_event_status?`
- `to_status:draw_event_status`
- `transition_code:VARCHAR(80)`
- `actor_type:actor_type`
- `actor_user_id:UUID? FK users`
- `reason:TEXT?`
- `correlation_id:UUID`
- `occurred_at:TIMESTAMPTZ`
- `created_at`

**Restricciones mínimas**

- Append-only

## `draw_events`

**Propósito:** Evento oficial concreto.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-EVT-006`, `LOT-EVT-007`, `LOT-EVT-008`, `LOT-EVT-010`, `LOT-EVT-018`, `LOT-EVT-019`  

**Campos mínimos**

- `id:UUID PK`
- `public_id:VARCHAR(40) UQ`
- `lottery_product_id:UUID FK lottery_products`
- `rule_version_id:UUID FK rule_versions`
- `prize_rule_version_id:UUID FK prize_rule_versions`
- `event_template_id:UUID? FK event_templates`
- `scheduled_slot_at:TIMESTAMPTZ?`
- `status:draw_event_status`
- `sales_open_at:TIMESTAMPTZ`
- `sales_close_at:TIMESTAMPTZ`
- `draw_at:TIMESTAMPTZ`
- `limit_release_at:TIMESTAMPTZ`
- `published_at:TIMESTAMPTZ?`
- `cancelled_at:TIMESTAMPTZ?`
- `cancel_reason:TEXT?`
- `finalized_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- UNIQUE(template,slot) cuando aplica
- open<close<draw
- `sales_open_at <= limit_release_at <= sales_close_at`; el clamp no altera el cierre
- Publicado no editable

## `event_combinations`

**Propósito:** Catálogo único de combinaciones.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-EVT-001`, `LOT-EVT-003`, `LOT-EVT-005`  

**Campos mínimos**

- `id:UUID PK`
- `draw_event_id:UUID FK draw_events`
- `normalized_key:VARCHAR(80)`
- `status:combination_status`
- `blocked_reason:TEXT?`
- `blocked_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- UNIQUE(event,normalized_key)
- `RESERVADA` exige una reserva `ACTIVA`; `VENDIDA` exige un boleto confirmado; ambas relaciones se mantienen atómicamente

## `event_financial_configs`

**Propósito:** Configuración económica congelada por evento.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-EVT-007`, `LOT-PRZ-003`, `LOT-PRZ-004`, `LOT-PRZ-006`  

**Campos mínimos**

- `id:UUID PK`
- `draw_event_id:UUID FK draw_events UQ`
- `ticket_price_virtual_minor:BIGINT`
- `initial_major_prize_virtual_minor:BIGINT`
- `major_prize_ceiling_virtual_minor:BIGINT`
- `minimum_capital_virtual_minor:BIGINT`
- `guarantee_required_virtual_minor:BIGINT`
- `rounding_policy_snapshot:JSONB`
- `frozen_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Montos VIRTUAL>=0
- No editar tras publicación

## `event_financial_projections`

**Propósito:** Proyección reconstruible de ventas y premio.  
**Fuente:** Derivada  
**Reglas:** `LOT-PRZ-003`, `LOT-PRZ-005`  

**Campos mínimos**

- `id:UUID PK`
- `draw_event_id:UUID FK draw_events UQ`
- `sales_virtual_minor:BIGINT`
- `refund_liability_virtual_minor:BIGINT`
- `guarantee_recovery_pending_minor:BIGINT`
- `growth_virtual_minor:BIGINT`
- `accumulation_extra_virtual_minor:BIGINT`
- `current_major_prize_virtual_minor:BIGINT`
- `ledger_version:BIGINT`
- `calculated_at:TIMESTAMPTZ`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- No es fuente contable
- Durante la fase cancelable, crecimiento y recuperación son proyecciones; `DRAW_SALES_FUND` conserva el bruto hasta la liquidación posterior a `RESULTADO_FIJADO`

## `event_templates`

**Propósito:** Autogeneradores de eventos.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-EVT-008`, `LOT-GOV-007`  

**Campos mínimos**

- `id:UUID PK`
- `lottery_product_id:UUID FK lottery_products`
- `rule_version_id:UUID FK rule_versions`
- `prize_rule_version_id:UUID FK prize_rule_versions`
- `name:VARCHAR(120)`
- `status:template_status`
- `future_generation_days:INTEGER`
- `publication_lead_seconds:INTEGER`
- `created_by_user_id:UUID FK users`
- `retired_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- No altera eventos con ventas

## `lottery_products`

**Propósito:** Productos Octal, Decimal y Hexadecimal.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-EVT-002`  

**Campos mínimos**

- `id:UUID PK`
- `code:lottery_product_code UQ`
- `name:VARCHAR(100)`
- `description:TEXT?`
- `is_active:BOOLEAN`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Solo productos aprobados

## `prize_rule_versions`

**Propósito:** Reglas económicas inmutables.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-PRZ-003`, `LOT-PRZ-005`, `LOT-PRZ-006`, `LOT-PRZ-009`  

**Campos mínimos**

- `id:UUID PK`
- `rule_version_id:UUID FK rule_versions`
- `version:INTEGER`
- `status:version_status`
- `initial_prize_multiplier_bps:INTEGER`
- `growth_share_bps:INTEGER`
- `operations_share_bps:INTEGER`
- `no_winner_accumulation_bps:INTEGER`
- `no_winner_guarantee_bps:INTEGER`
- `no_winner_future_prize_bps:INTEGER`
- `no_winner_operations_bps:INTEGER`
- `rounding_policy:JSONB`
- `allocation_policy_code:VARCHAR(60)`
- `content_hash:VARCHAR(128)`
- `published_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- UNIQUE(rule_version,version)
- Porcentajes suman 10000 cuando aplican
- `allocation_policy_code` referencia la política de mayores residuos de `LOT-FIN-013`
- Versión usada inmutable

## `rule_versions`

**Propósito:** Reglas matemáticas históricas por producto.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-GOV-007`, `LOT-EVT-002`, `LOT-EVT-003`, `LOT-EVT-012`  

**Campos mínimos**

- `id:UUID PK`
- `lottery_product_id:UUID FK lottery_products`
- `version:INTEGER`
- `status:version_status`
- `selection_count:SMALLINT`
- `universe_symbols:JSONB`
- `total_combinations:INTEGER`
- `order_matters:BOOLEAN`
- `unique_symbols_required:BOOLEAN`
- `purchase_limit_bps:INTEGER`
- `limit_release_fraction_bps:INTEGER`
- `reservation_seconds:INTEGER`
- `close_before_draw_seconds:INTEGER`
- `published_at:TIMESTAMPTZ?`
- `content_hash:VARCHAR(128)`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- UNIQUE(product,version)
- Versión usada inmutable
- Valores 70/252/8008 coherentes

## `template_schedules`

**Propósito:** Horarios, días y recurrencias.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-EVT-008`, `LOT-GOV-005`  

**Campos mínimos**

- `id:UUID PK`
- `event_template_id:UUID FK event_templates`
- `weekday:SMALLINT?`
- `local_time:TIME?`
- `interval_seconds:INTEGER?`
- `effective_from:DATE`
- `effective_until:DATE?`
- `is_active:BOOLEAN`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Calendario o intervalo válido

# Resultado oficial

## `award_payment_orders`

**Propósito:** Orden idempotente de acreditación.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-PRZ-016`, `LOT-PRZ-017`  

**Campos mínimos**

- `id:UUID PK`
- `prize_award_id:UUID FK prize_awards UQ`
- `status:award_payment_status`
- `ledger_transaction_id:UUID? FK ledger_transactions UQ`
- `idempotency_key_id:UUID FK idempotency_keys`
- `attempt_count:INTEGER`
- `credited_at:TIMESTAMPTZ?`
- `last_error:TEXT?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Una por award
- ACREDITADA terminal

## `draw_commitments`

**Propósito:** Commitment y semilla cifrada.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-PRZ-012`, `LOT-AUD-002`  

**Campos mínimos**

- `id:UUID PK`
- `draw_event_id:UUID FK draw_events UQ`
- `status:commitment_status`
- `algorithm_version:VARCHAR(50)`
- `commitment_hash:VARCHAR(128) UQ`
- `encrypted_secret_seed:BYTEA`
- `encryption_key_version:VARCHAR(50)`
- `published_at:TIMESTAMPTZ?`
- `revealed_seed:TEXT?`
- `revealed_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Una por evento
- No revelar antes

## `draw_result_numbers`

**Propósito:** Símbolos ganadores y orden visual.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-PRZ-014`, `LOT-PRZ-015`  

**Campos mínimos**

- `id:UUID PK`
- `draw_result_id:UUID FK draw_results`
- `symbol:VARCHAR(2)`
- `display_order:SMALLINT`
- `created_at`

**Restricciones mínimas**

- UNIQUE(result,symbol)
- UNIQUE(result,order)

## `draw_results`

**Propósito:** Resultado único e inmutable.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-PRZ-014`, `LOT-PRZ-015`  

**Campos mínimos**

- `id:UUID PK`
- `draw_event_id:UUID FK draw_events UQ`
- `draw_commitment_id:UUID FK draw_commitments UQ`
- `draw_snapshot_id:UUID FK draw_snapshots UQ`
- `algorithm_version:VARCHAR(50)`
- `final_seed_hash:VARCHAR(128)`
- `result_hash:VARCHAR(128) UQ`
- `fixed_at:TIMESTAMPTZ`
- `fixed_by_job_run_id:UUID? FK job_runs`
- `created_at`

**Restricciones mínimas**

- Un resultado por evento
- Sin UPDATE/DELETE

## `draw_snapshot_tickets`

**Propósito:** Contenido relacional del snapshot.  
**Fuente:** Derivada  
**Reglas:** `LOT-PRZ-013`  

**Campos mínimos**

- `id:UUID PK`
- `draw_snapshot_id:UUID FK draw_snapshots`
- `ticket_id:UUID FK tickets`
- `sequence:INTEGER`
- `ticket_hash:VARCHAR(128)`
- `created_at`

**Restricciones mínimas**

- UNIQUE(snapshot,ticket)
- UNIQUE(snapshot,sequence)

## `draw_snapshots`

**Propósito:** Snapshot de boletos elegibles.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-PRZ-013`  

**Campos mínimos**

- `id:UUID PK`
- `draw_event_id:UUID FK draw_events UQ`
- `status:snapshot_status`
- `snapshot_hash:VARCHAR(128)? UQ`
- `ticket_count:INTEGER`
- `serialization_version:VARCHAR(40)`
- `generated_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Inmutable después de GENERADO

## `prize_awards`

**Propósito:** Obligación calculada por boleto y categoría.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-PRZ-002`, `LOT-PRZ-006`, `LOT-PRZ-016`  

**Campos mínimos**

- `id:UUID PK`
- `draw_event_id:UUID FK draw_events`
- `ticket_id:UUID FK tickets`
- `ticket_evaluation_id:UUID? FK ticket_evaluations`
- `award_category:award_category`
- `exact_virtual_minor:BIGINT`
- `public_virtual_minor:BIGINT`
- `rounding_adjustment_minor:BIGINT`
- `calculated_at:TIMESTAMPTZ`
- `created_at`

**Restricciones mínimas**

- UNIQUE(event,ticket,category)

## `result_reports`

**Propósito:** Boletín público estructurado.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-PRZ-016`, `LOT-PRZ-018`  

**Campos mínimos**

- `id:UUID PK`
- `draw_event_id:UUID FK draw_events`
- `draw_result_id:UUID FK draw_results`
- `status:report_status`
- `report_version:INTEGER`
- `supersedes_report_id:UUID? FK result_reports`
- `public_payload:JSONB`
- `report_hash:VARCHAR(128) UQ`
- `json_object_id:UUID? FK stored_objects`
- `pdf_object_id:UUID? FK stored_objects`
- `image_object_id:UUID? FK stored_objects`
- `published_at:TIMESTAMPTZ?`
- `superseded_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- `UNIQUE(draw_event_id,report_version)`
- Un único `PUBLICADO` vigente por evento mediante índice parcial
- Una versión nueva referencia la anterior mediante `supersedes_report_id`; la anterior pasa a `SUPERSEDED` sin borrarse
- Republicar no vuelve a acreditar premios existentes; cualquier diferencia financiera exige una compensación contable previa
- Sin identidad
- Coincide con premios

## `ticket_evaluations`

**Propósito:** Evaluación inmutable por boleto.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-PRZ-001`, `LOT-PRZ-002`  

**Campos mínimos**

- `id:UUID PK`
- `draw_event_id:UUID FK draw_events`
- `ticket_id:UUID FK tickets UQ`
- `draw_result_id:UUID FK draw_results`
- `match_count:SMALLINT`
- `evaluation_category:ticket_evaluation_status`
- `evaluation_hash:VARCHAR(128)`
- `evaluated_at:TIMESTAMPTZ`
- `created_at`

**Restricciones mínimas**

- UNIQUE(event,ticket)

# Sistema

## `audit_events`

**Propósito:** Auditoría administrativa, financiera y de seguridad.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-AUD-001`, `LOT-AUD-002`, `LOT-AUD-003`  

**Campos mínimos**

- `id:UUID PK`
- `actor_type:actor_type`
- `actor_user_id:UUID? FK users`
- `session_id:UUID? FK sessions`
- `active_mode:active_mode?`
- `permission_key:VARCHAR(150)?`
- `action:VARCHAR(120)`
- `resource_type:VARCHAR(80)`
- `resource_id:UUID?`
- `before_data:JSONB?`
- `after_data:JSONB?`
- `reason:TEXT?`
- `correlation_id:UUID`
- `ip_hash:VARCHAR(128)?`
- `occurred_at:TIMESTAMPTZ`
- `created_at`

**Restricciones mínimas**

- Append-only
- Sin secretos

## `inbox_events`

**Propósito:** Deduplicación de mensajes consumidos.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-GOV-003`, `LOT-AUD-004`  

**Campos mínimos**

- `id:UUID PK`
- `consumer_name:VARCHAR(100)`
- `message_id:VARCHAR(180)`
- `event_type:VARCHAR(120)`
- `payload_hash:VARCHAR(128)`
- `status:inbox_status`
- `received_at:TIMESTAMPTZ`
- `processed_at:TIMESTAMPTZ?`
- `last_error:TEXT?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- UNIQUE(consumer,message_id)

## `job_runs`

**Propósito:** Intentos de ejecución.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-AUD-004`  

**Campos mínimos**

- `id:UUID PK`
- `scheduled_job_id:UUID FK scheduled_jobs`
- `attempt_number:INTEGER`
- `status:job_status`
- `worker_instance:VARCHAR(120)?`
- `started_at:TIMESTAMPTZ`
- `finished_at:TIMESTAMPTZ?`
- `result_payload:JSONB?`
- `error_code:VARCHAR(100)?`
- `error_detail:TEXT?`
- `created_at`

**Restricciones mínimas**

- UNIQUE(job,attempt)

## `notification_preferences`

**Propósito:** Preferencias por usuario, tipo y canal.  
**Fuente:** Derivada  
**Reglas:** `LOT-GOV-002`  

**Campos mínimos**

- `id:UUID PK`
- `user_id:UUID FK users`
- `notification_type:VARCHAR(100)`
- `channel:VARCHAR(30)`
- `is_enabled:BOOLEAN`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- UNIQUE(user,type,channel)

## `notifications`

**Propósito:** Avisos opcionales.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-GOV-002`  

**Campos mínimos**

- `id:UUID PK`
- `user_id:UUID FK users`
- `channel:VARCHAR(30)`
- `notification_type:VARCHAR(100)`
- `status:notification_status`
- `title:VARCHAR(180)`
- `body:TEXT`
- `resource_type:VARCHAR(80)?`
- `resource_id:UUID?`
- `scheduled_at:TIMESTAMPTZ`
- `sent_at:TIMESTAMPTZ?`
- `read_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Nunca fuente de estado

## `outbox_events`

**Propósito:** Eventos de dominio posteriores al commit.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-GOV-003`, `LOT-AUD-004`  

**Campos mínimos**

- `id:UUID PK`
- `aggregate_type:VARCHAR(80)`
- `aggregate_id:UUID`
- `event_type:VARCHAR(120)`
- `event_version:INTEGER`
- `payload:JSONB`
- `status:outbox_status`
- `correlation_id:UUID`
- `available_at:TIMESTAMPTZ`
- `published_at:TIMESTAMPTZ?`
- `attempt_count:INTEGER`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Publicar solo tras commit

## `scheduled_jobs`

**Propósito:** Trabajos persistentes.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-AUD-004`  

**Campos mínimos**

- `id:UUID PK`
- `job_key:VARCHAR(180) UQ`
- `job_type:VARCHAR(120)`
- `resource_type:VARCHAR(80)`
- `resource_id:UUID`
- `status:job_status`
- `run_at:TIMESTAMPTZ`
- `payload:JSONB`
- `max_attempts:INTEGER`
- `attempt_count:INTEGER`
- `correlation_id:UUID`
- `last_error:TEXT?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Clave lógica única
- Hora servidor

## `security_events`

**Propósito:** Alertas y patrones de riesgo.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-AUD-006`  

**Campos mínimos**

- `id:UUID PK`
- `event_type:VARCHAR(100)`
- `severity:security_severity`
- `user_id:UUID? FK users`
- `session_id:UUID? FK sessions`
- `resource_type:VARCHAR(80)?`
- `resource_id:UUID?`
- `details:JSONB`
- `detected_at:TIMESTAMPTZ`
- `resolved_at:TIMESTAMPTZ?`
- `resolved_by_user_id:UUID? FK users`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Datos minimizados

## `stored_objects`

**Propósito:** Metadatos de archivos S3 compatibles.  
**Fuente:** Derivada de arquitectura  
**Reglas:** `LOT-AUD-002`  

**Campos mínimos**

- `id:UUID PK`
- `bucket:VARCHAR(100)`
- `object_key:VARCHAR(500)`
- `content_type:VARCHAR(120)`
- `size_bytes:BIGINT`
- `sha256:VARCHAR(128)`
- `status:stored_object_status`
- `encryption_key_version:VARCHAR(50)?`
- `uploaded_by_user_id:UUID? FK users`
- `available_at:TIMESTAMPTZ?`
- `deleted_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- UNIQUE(bucket,object_key)
- No secretos/datos de tarjeta

## `system_settings`

**Propósito:** Configuración operativa no histórica.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-GOV-007`, `LOT-AUD-003`  

**Campos mínimos**

- `id:UUID PK`
- `setting_key:VARCHAR(150) UQ`
- `value_json:JSONB`
- `value_type:VARCHAR(30)`
- `is_sensitive:BOOLEAN`
- `updated_by_user_id:UUID? FK users`
- `description:TEXT?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- No reglas históricas
- No secretos reales

# Sorteos de usuarios

## `user_draw_access_code_events`

**Propósito:** Historial de uso, pago y reserva del código.  
**Fuente:** Derivada  
**Reglas:** `LOT-ORG-014`, `LOT-AUD-001`  

**Campos mínimos**

- `id:UUID PK`
- `access_code_id:UUID FK user_draw_access_codes`
- `dimension:VARCHAR(30)`
- `from_status:VARCHAR(40)?`
- `to_status:VARCHAR(40)`
- `actor_type:actor_type`
- `actor_user_id:UUID? FK users`
- `correlation_id:UUID`
- `occurred_at:TIMESTAMPTZ`
- `created_at`

**Restricciones mínimas**

- Append-only

## `user_draw_access_code_numbers`

**Propósito:** Números reservados por un código.  
**Fuente:** Derivada  
**Reglas:** `LOT-ORG-011`, `LOT-ORG-015`  

**Campos mínimos**

- `id:UUID PK`
- `access_code_id:UUID FK user_draw_access_codes`
- `number_id:UUID FK user_draw_numbers`
- `created_at`

**Restricciones mínimas**

- UNIQUE(code,number)
- Un número no tiene dos reservas activas

## `user_draw_access_codes`

**Propósito:** Código privado de un uso.  
**Fuente:** ADR-ORG-001  
**Reglas:** `LOT-ORG-010`, `LOT-ORG-011`, `LOT-ORG-012`, `LOT-ORG-013`, `LOT-ORG-014`, `LOT-ORG-015`  

**Campos mínimos**

- `id:UUID PK`
- `user_draw_id:UUID FK user_draws`
- `code_public_id:VARCHAR(50) UQ`
- `secret_hash:VARCHAR(255) UQ`
- `use_status:code_use_status`
- `payment_status:code_payment_status`
- `reservation_status:code_reservation_status`
- `price_virtual_minor:BIGINT`
- `funder_user_id:UUID? FK users`
- `claimed_by_user_id:UUID? FK users`
- `optional_comment:TEXT?`
- `expires_at:TIMESTAMPTZ`
- `claimed_at:TIMESTAMPTZ?`
- `payment_ledger_transaction_id:UUID? FK ledger_transactions UQ`
- `refund_ledger_transaction_id:UUID? FK ledger_transactions UQ`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- expires_at<=close
- `price_virtual_minor` es total para todos los números vinculados
- Un solo reclamo
- Al reclamar, los números se copian a `user_draw_participation_numbers` sin duplicar el pago
- Secreto no en claro

## `user_draw_announcements`

**Propósito:** Anuncios internos.  
**Fuente:** Derivada  
**Reglas:** `LOT-ORG-007`  

**Campos mínimos**

- `id:UUID PK`
- `user_draw_id:UUID FK user_draws`
- `author_user_id:UUID FK users`
- `title:VARCHAR(160)`
- `body:TEXT`
- `published_at:TIMESTAMPTZ`
- `removed_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Solo Organizador crea
- Solo participantes/Organizador leen

## `user_draw_claim_events`

**Propósito:** Historial del reclamo.  
**Fuente:** Derivada  
**Reglas:** `LOT-ORG-021`, `LOT-AUD-001`  

**Campos mínimos**

- `id:UUID PK`
- `claim_id:UUID FK user_draw_claims`
- `from_status:claim_status?`
- `to_status:claim_status`
- `actor_user_id:UUID? FK users`
- `actor_type:actor_type`
- `reason:TEXT?`
- `evidence_deadline_at:TIMESTAMPTZ?`
- `correlation_id:UUID`
- `occurred_at:TIMESTAMPTZ`
- `created_at`

**Restricciones mínimas**

- Append-only

## `user_draw_claim_evidence`

**Propósito:** Evidencia de reclamo.  
**Fuente:** Derivada  
**Reglas:** `LOT-ORG-020`, `LOT-ORG-021`  

**Campos mínimos**

- `id:UUID PK`
- `claim_id:UUID FK user_draw_claims`
- `submitted_by_user_id:UUID FK users`
- `stored_object_id:UUID? FK stored_objects`
- `description:TEXT?`
- `submitted_at:TIMESTAMPTZ`
- `created_at`

**Restricciones mínimas**

- Acceso restringido

## `user_draw_claims`

**Propósito:** Reclamo administrativo.  
**Fuente:** ADR-ORG-001  
**Reglas:** `LOT-ORG-020`, `LOT-ORG-021`  

**Campos mínimos**

- `id:UUID PK`
- `public_id:VARCHAR(40) UQ`
- `user_draw_id:UUID FK user_draws`
- `claimant_user_id:UUID FK users`
- `participation_id:UUID? FK user_draw_participations`
- `claim_type:user_draw_claim_type`
- `status:claim_status`
- `description:TEXT`
- `event_occurred_at:TIMESTAMPTZ`
- `filed_at:TIMESTAMPTZ`
- `appeal_deadline_at:TIMESTAMPTZ?`
- `resolved_by_user_id:UUID? FK users`
- `resolution_code:VARCHAR(80)?`
- `resolution_reason:TEXT?`
- `compensation_ledger_transaction_id:UUID? FK ledger_transactions UQ`
- `resolved_at:TIMESTAMPTZ?`
- `closed_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Organizador no resuelve
- Plazos 7/3 días salvo reapertura

## `user_draw_delivery_records`

**Propósito:** Evidencia y confirmación de entrega.  
**Fuente:** ADR-ORG-001  
**Reglas:** `LOT-ORG-023`  

**Campos mínimos**

- `id:UUID PK`
- `user_draw_id:UUID FK user_draws UQ`
- `winner_user_id:UUID FK users`
- `status:delivery_status`
- `delivery_method:VARCHAR(80)`
- `delivery_deadline_at:TIMESTAMPTZ`
- `organizer_notes:TEXT?`
- `delivery_evidence_object_id:UUID? FK stored_objects`
- `registered_at:TIMESTAMPTZ?`
- `confirmed_at:TIMESTAMPTZ?`
- `closed_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Ganador coincide con resultado
- Plataforma no custodia objeto

## `user_draw_escrow_events`

**Propósito:** Historial del escrow.  
**Fuente:** Derivada  
**Reglas:** `LOT-ORG-025`, `LOT-AUD-001`  

**Campos mínimos**

- `id:UUID PK`
- `user_draw_escrow_id:UUID FK user_draw_escrows`
- `from_status:escrow_status?`
- `to_status:escrow_status`
- `actor_type:actor_type`
- `actor_user_id:UUID? FK users`
- `reason:TEXT?`
- `ledger_transaction_id:UUID? FK ledger_transactions`
- `correlation_id:UUID`
- `occurred_at:TIMESTAMPTZ`
- `created_at`

**Restricciones mínimas**

- Append-only

## `user_draw_escrows`

**Propósito:** Control del 95 % y comisión 5 % retenida.  
**Fuente:** ADR-ORG-001  
**Reglas:** `LOT-ORG-006`, `LOT-ORG-008`, `LOT-ORG-023`, `LOT-ORG-025`  

**Campos mínimos**

- `id:UUID PK`
- `user_draw_id:UUID FK user_draws UQ`
- `status:escrow_status`
- `escrow_ledger_account_id:UUID FK ledger_accounts UQ`
- `commission_held_account_id:UUID FK ledger_accounts UQ`
- `gross_paid_virtual_minor:BIGINT`
- `commission_held_virtual_minor:BIGINT`
- `escrow_virtual_minor:BIGINT`
- `released_virtual_minor:BIGINT`
- `refunded_virtual_minor:BIGINT`
- `release_ledger_transaction_id:UUID? FK ledger_transactions UQ`
- `settled_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Proyección desde ledger
- No disponible antes de liberación
- `LIBERADA` y `REEMBOLSADA` son terminales; una compensación posterior se enlaza al reclamo y no reabre el escrow

## `user_draw_invitations`

**Propósito:** Invitaciones privadas alternativas al código.  
**Fuente:** Derivada  
**Reglas:** `LOT-ORG-010`  

**Campos mínimos**

- `id:UUID PK`
- `user_draw_id:UUID FK user_draws`
- `invited_user_id:UUID? FK users`
- `target_contact_hash:VARCHAR(255)?`
- `token_hash:VARCHAR(255) UQ`
- `status:invitation_status`
- `expires_at:TIMESTAMPTZ`
- `accepted_by_user_id:UUID? FK users`
- `accepted_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Un solo uso
- No concede privilegios globales

## `user_draw_number_changes`

**Propósito:** Cambio atómico de número.  
**Fuente:** ADR-ORG-001  
**Reglas:** `LOT-ORG-017`  

**Campos mínimos**

- `id:UUID PK`
- `participation_id:UUID FK user_draw_participations`
- `old_participation_number_id:UUID FK user_draw_participation_numbers`
- `new_number_id:UUID FK user_draw_numbers`
- `requested_by_user_id:UUID FK users`
- `status:number_change_status`
- `reason:TEXT?`
- `changed_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- La asignación anterior pertenece a la participación y está `ACTIVA`
- El número nuevo es diferente y está disponible
- Solo antes del cierre
- Confirmar marca la anterior `REEMPLAZADA` y crea una nueva asignación `ACTIVA` atómicamente

## `user_draw_numbers`

**Propósito:** Números del rango y asignación.  
**Fuente:** Derivada  
**Reglas:** `LOT-ORG-004`, `LOT-ORG-011`, `LOT-ORG-017`  

**Campos mínimos**

- `id:UUID PK`
- `user_draw_id:UUID FK user_draws`
- `number_value:INTEGER`
- `assignment_status:number_assignment_status`
- `blocked_reason:TEXT?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- UNIQUE(draw,number)
- Número dentro del rango
- `assignment_status` se actualiza bajo lock de esta fila; el propietario actual se deriva de participaciones o reservas de código, evitando una FK circular

## `user_draw_participation_events`

**Propósito:** Historial de pago, relación, elegibilidad y número.  
**Fuente:** Derivada  
**Reglas:** `LOT-ORG-016`, `LOT-ORG-018`, `LOT-ORG-019`  

**Campos mínimos**

- `id:UUID PK`
- `participation_id:UUID FK user_draw_participations`
- `dimension:VARCHAR(30)`
- `from_status:VARCHAR(50)?`
- `to_status:VARCHAR(50)`
- `actor_type:actor_type`
- `actor_user_id:UUID? FK users`
- `reason:TEXT?`
- `correlation_id:UUID`
- `occurred_at:TIMESTAMPTZ`
- `created_at`

**Restricciones mínimas**

- Append-only

## `user_draw_participations`

**Propósito:** Unidad económica de compra o reclamación con estados separados; puede poseer una o varias asignaciones de número.  
**Fuente:** ADR-ORG-001  
**Reglas:** `LOT-ORG-006`, `LOT-ORG-017`, `LOT-ORG-018`, `LOT-ORG-019`, `LOT-ORG-022`  

**Campos mínimos**

- `id:UUID PK`
- `user_draw_id:UUID FK user_draws`
- `participant_user_id:UUID FK users`
- `access_code_id:UUID? FK user_draw_access_codes`
- `payment_status:participation_payment_status`
- `relation_status:participation_relation_status`
- `eligibility_status:participation_eligibility_status`
- `price_virtual_minor:BIGINT`
- `payment_ledger_transaction_id:UUID? FK ledger_transactions UQ`
- `refund_ledger_transaction_id:UUID? FK ledger_transactions UQ`
- `paid_at:TIMESTAMPTZ?`
- `abandoned_at:TIMESTAMPTZ?`
- `expelled_at:TIMESTAMPTZ?`
- `expulsion_reason:TEXT?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- `price_virtual_minor` es el precio total de la participación económica, incluso cuando proviene de un código con varios números
- `PAGADO` exige ledger
- Cuando proviene de un código ya pagado, `payment_ledger_transaction_id` referencia la misma transacción del código y no crea otro débito
- Las asignaciones activas se almacenan en `user_draw_participation_numbers`
- Abandono pagado conserva elegibilidad y asignaciones activas

## `user_draw_participation_numbers`

**Propósito:** Asignar uno o varios números a una participación económica sin duplicar su precio ni su pago.  
**Fuente:** Derivada de `LOT-ORG-011`, `LOT-ORG-014`, `LOT-ORG-017` y `LOT-ORG-022`  
**Reglas:** `LOT-ORG-011`, `LOT-ORG-014`, `LOT-ORG-017`, `LOT-ORG-022`  

**Campos mínimos**

- `id:UUID PK`
- `participation_id:UUID FK user_draw_participations`
- `number_id:UUID FK user_draw_numbers`
- `status:participation_number_status`
- `assigned_at:TIMESTAMPTZ`
- `replaced_at:TIMESTAMPTZ?`
- `released_at:TIMESTAMPTZ?`
- `reason:TEXT?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- `UNIQUE(participation_id,number_id)`
- Un único registro `ACTIVA` por `number_id` mediante índice parcial
- Una compra directa crea normalmente una asignación; un código grupal puede crear varias
- El precio y el ledger permanecen en la participación y no se multiplican por cada asignación
- `REEMPLAZADA` y `LIBERADA` no vuelven a `ACTIVA`; un cambio crea una asignación nueva

## `user_draw_prize_evidence`

**Propósito:** Evidencia de existencia/disponibilidad del premio.  
**Fuente:** ADR-ORG-001  
**Reglas:** `LOT-ORG-023`  

**Campos mínimos**

- `id:UUID PK`
- `user_draw_id:UUID FK user_draws`
- `evidence_type:VARCHAR(50)`
- `stored_object_id:UUID? FK stored_objects`
- `description:TEXT?`
- `submitted_by_user_id:UUID FK users`
- `verified_by_user_id:UUID? FK users`
- `verified_at:TIMESTAMPTZ?`
- `is_valid:BOOLEAN?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Evidencia suficiente antes de publicar

## `user_draw_results`

**Propósito:** Ganador único generado por CSPRNG.  
**Fuente:** ADR-ORG-001  
**Reglas:** `LOT-ORG-022`  

**Campos mínimos**

- `id:UUID PK`
- `user_draw_id:UUID FK user_draws UQ`
- `user_draw_snapshot_id:UUID FK user_draw_snapshots UQ`
- `winning_snapshot_entry_id:UUID FK user_draw_snapshot_entries UQ`
- `winning_participation_id:UUID FK user_draw_participations`
- `winning_number_value:INTEGER`
- `algorithm_version:VARCHAR(50)`
- `verification_payload:JSONB` — allowlist con hashes, versión de algoritmo, job y correlación; no representa commit-reveal
- `result_hash:VARCHAR(128) UQ`
- `fixed_at:TIMESTAMPTZ`
- `fixed_by_job_run_id:UUID? FK job_runs`
- `created_at`

**Restricciones mínimas**

- `winning_snapshot_entry_id` pertenece al snapshot del sorteo
- `winning_participation_id` y `winning_number_value` coinciden con la entrada ganadora
- Sin regeneración
- La evidencia verifica integridad del conjunto/resultado; no afirma verificabilidad independiente de la entropía

## `user_draw_snapshot_entries`

**Propósito:** Contenido del snapshot.  
**Fuente:** Derivada  
**Reglas:** `LOT-ORG-022`  

**Campos mínimos**

- `id:UUID PK`
- `user_draw_snapshot_id:UUID FK user_draw_snapshots`
- `participation_number_id:UUID FK user_draw_participation_numbers`
- `number_value:INTEGER`
- `sequence:INTEGER`
- `entry_hash:VARCHAR(128)`
- `created_at`

**Restricciones mínimas**

- UNIQUE(snapshot,participation_number)
- UNIQUE(snapshot,sequence)
- Solo incluye asignaciones `ACTIVA` de participaciones `PAGADO` y con elegibilidad `ACTIVA`

## `user_draw_snapshots`

**Propósito:** Snapshot de participaciones PAGADO+ACTIVA.  
**Fuente:** ADR-ORG-001  
**Reglas:** `LOT-ORG-022`  

**Campos mínimos**

- `id:UUID PK`
- `user_draw_id:UUID FK user_draws UQ`
- `snapshot_hash:VARCHAR(128) UQ`
- `entry_count:INTEGER`
- `serialization_version:VARCHAR(40)`
- `generated_at:TIMESTAMPTZ`
- `created_at`

**Restricciones mínimas**

- Uno final por sorteo
- Inmutable

## `user_draw_status_history`

**Propósito:** Historial del sorteo de usuario.  
**Fuente:** Derivada  
**Reglas:** `LOT-ORG-009`, `LOT-AUD-001`  

**Campos mínimos**

- `id:UUID PK`
- `user_draw_id:UUID FK user_draws`
- `from_status:user_draw_status?`
- `to_status:user_draw_status`
- `transition_code:VARCHAR(80)`
- `actor_type:actor_type`
- `actor_user_id:UUID? FK users`
- `reason:TEXT?`
- `correlation_id:UUID`
- `occurred_at:TIMESTAMPTZ`
- `created_at`

**Restricciones mínimas**

- Append-only

## `user_draws`

**Propósito:** Sorteo creado por un Organizador contextual.  
**Fuente:** ADR-ORG-001  
**Reglas:** `LOT-FIN-013`, `LOT-ORG-001`, `LOT-ORG-002`, `LOT-ORG-003`, `LOT-ORG-004`, `LOT-ORG-024`  

**Campos mínimos**

- `id:UUID PK`
- `public_id:VARCHAR(40) UQ`
- `organizer_user_id:UUID FK users`
- `visibility:user_draw_visibility`
- `status:user_draw_status`
- `title:VARCHAR(160)`
- `description:TEXT?`
- `prize_description:TEXT`
- `price_virtual_minor:BIGINT`
- `platform_commission_bps:INTEGER`
- `allocation_policy_code:VARCHAR(60)`
- `range_start:INTEGER`
- `range_end:INTEGER`
- `sales_open_at:TIMESTAMPTZ`
- `sales_close_at:TIMESTAMPTZ`
- `first_payment_at:TIMESTAMPTZ?`
- `published_at:TIMESTAMPTZ?`
- `cancelled_at:TIMESTAMPTZ?`
- `finalized_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- range_start<=range_end
- Precio>0
- Comisión y política quedan congeladas desde publicación/primer pago
- Inmutabilidad tras primer pago

# Vendedores

## `conversion_assignments`

**Propósito:** Asignación atómica a Vendedor.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-VND-005`, `LOT-VND-006`, `LOT-VND-008`, `LOT-VND-010`  

**Campos mínimos**

- `id:UUID PK`
- `conversion_request_id:UUID FK conversion_requests`
- `vendor_user_id:UUID FK users`
- `status:conversion_assignment_status`
- `assigned_at:TIMESTAMPTZ`
- `released_at:TIMESTAMPTZ?`
- `consumed_at:TIMESTAMPTZ?`
- `created_at`

**Restricciones mínimas**

- Una ACTIVA por solicitud
- No extiende plazo

## `conversion_request_events`

**Propósito:** Historial de estados de solicitud.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-VND-010`, `LOT-AUD-001`  

**Campos mínimos**

- `id:UUID PK`
- `conversion_request_id:UUID FK conversion_requests`
- `from_status:conversion_request_status?`
- `to_status:conversion_request_status`
- `transition_code:VARCHAR(80)`
- `actor_type:actor_type`
- `actor_user_id:UUID? FK users`
- `reason_code:VARCHAR(80)?`
- `correlation_id:UUID`
- `occurred_at:TIMESTAMPTZ`
- `created_at`

**Restricciones mínimas**

- Append-only

## `conversion_requests`

**Propósito:** Solicitud REAL→VIRTUAL con reserva y fallback.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-VND-003`, `LOT-VND-009`, `LOT-VND-010`  

**Campos mínimos**

- `id:UUID PK`
- `client_user_id:UUID FK users`
- `amount_real_minor:BIGINT`
- `amount_virtual_minor:BIGINT`
- `status:conversion_request_status`
- `expires_at:TIMESTAMPTZ`
- `real_reservation_ledger_transaction_id:UUID FK ledger_transactions UQ`
- `completion_ledger_transaction_id:UUID? FK ledger_transactions UQ`
- `completed_by_vendor_user_id:UUID? FK users`
- `completed_at:TIMESTAMPTZ?`
- `idempotency_key_id:UUID FK idempotency_keys`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- Finalización única
- 1:1
- expires_at=created_at+5min

## `related_account_flags`

**Propósito:** Vínculos y alertas antifraude.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-VND-004`, `LOT-AUD-006`  

**Campos mínimos**

- `id:UUID PK`
- `user_a_id:UUID FK users`
- `user_b_id:UUID FK users`
- `flag_type:VARCHAR(80)`
- `status:risk_flag_status`
- `risk_score:INTEGER?`
- `evidence:JSONB?`
- `detected_at:TIMESTAMPTZ`
- `resolved_by_user_id:UUID? FK users`
- `resolved_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- user_a<>user_b
- Par normalizado

## `vendor_inventory_batches`

**Propósito:** Lotes VIRTUAL con coste histórico.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-VND-001`, `LOT-VND-002`, `LOT-FIN-013`  

**Campos mínimos**

- `id:UUID PK`
- `vendor_user_id:UUID FK users`
- `purchase_order_id:UUID FK vendor_purchase_orders UQ`
- `virtual_acquired_minor:BIGINT`
- `virtual_remaining_minor:BIGINT`
- `real_cost_minor:BIGINT`
- `status:inventory_batch_status`
- `acquired_at:TIMESTAMPTZ`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- 0<=remaining<=acquired

## `vendor_profiles`

**Propósito:** Estado y habilitación del Vendedor.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-IAM-004`, `LOT-VND-001`  

**Campos mínimos**

- `id:UUID PK`
- `user_id:UUID FK users UQ`
- `status:vendor_profile_status`
- `approved_by_user_id:UUID? FK users`
- `approved_at:TIMESTAMPTZ?`
- `suspended_at:TIMESTAMPTZ?`
- `suspension_reason:TEXT?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- ACTIVE requerido para operar

## `vendor_purchase_orders`

**Propósito:** Compra mayorista 0,90 REAL→1,00 VIRTUAL.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-VND-001`, `LOT-VND-002`  

**Campos mínimos**

- `id:UUID PK`
- `vendor_user_id:UUID FK users`
- `requested_virtual_minor:BIGINT`
- `real_cost_minor:BIGINT`
- `unit_cost_numerator:INTEGER`
- `unit_cost_denominator:INTEGER`
- `status:vendor_order_status`
- `ledger_transaction_id:UUID? FK ledger_transactions UQ`
- `idempotency_key_id:UUID FK idempotency_keys`
- `confirmed_at:TIMESTAMPTZ?`
- `created_at`
- `updated_at`

**Restricciones mínimas**

- `requested_virtual_minor > 0`
- `requested_virtual_minor % 100 = 0` en MVP
- `real_cost_minor = requested_virtual_minor * 90 / 100` exacto

## `vendor_sale_batch_allocations`

**Propósito:** Consumo de lotes para coste y ganancia realizada.  
**Fuente:** Derivada  
**Reglas:** `LOT-VND-002`  

**Campos mínimos**

- `id:UUID PK`
- `vendor_sale_id:UUID FK vendor_sales`
- `inventory_batch_id:UUID FK vendor_inventory_batches`
- `virtual_amount_minor:BIGINT`
- `allocated_real_cost_minor:BIGINT`
- `created_at`

**Restricciones mínimas**

- UNIQUE(sale,batch)
- Suma coincide con venta

## `vendor_sales`

**Propósito:** Venta realizada y ganancia verificable.  
**Fuente:** Plan 6.3  
**Reglas:** `LOT-VND-002`, `LOT-VND-007`  

**Campos mínimos**

- `id:UUID PK`
- `conversion_request_id:UUID FK conversion_requests UQ`
- `vendor_user_id:UUID FK users`
- `virtual_sold_minor:BIGINT`
- `real_received_minor:BIGINT`
- `allocated_real_cost_minor:BIGINT`
- `realized_profit_minor:BIGINT`
- `ledger_transaction_id:UUID FK ledger_transactions UQ`
- `sold_at:TIMESTAMPTZ`
- `created_at`

**Restricciones mínimas**

- profit=received-cost

# 4. Relaciones troncales

```text
users
 ├─ user_profiles
 ├─ user_roles ─ roles
 │               └─ role_permissions ─ permissions
 ├─ user_permission_grants ─ permissions
 ├─ sessions ─ refresh_tokens
 ├─ wallets ─ ledger_accounts ─ ledger_entries ─ ledger_transactions
 ├─ vendor_profiles ─ vendor_purchase_orders ─ vendor_inventory_batches
 ├─ conversion_requests ─ conversion_assignments ─ vendor_sales
 ├─ purchase_orders ─ tickets ─ ticket_evaluations ─ prize_awards
 └─ user_draws
      ├─ user_draw_numbers
      ├─ user_draw_participations ─ user_draw_participation_numbers ─ user_draw_numbers
      ├─ user_draw_access_codes ─ user_draw_access_code_numbers
      ├─ user_draw_snapshots ─ user_draw_results
      ├─ user_draw_claims
      ├─ user_draw_delivery_records
      └─ user_draw_escrows
```

# 5. Controles que requieren SQL además de Prisma

## 5.1 Balance diferido del ledger

Por cada `ledger_transaction_id` y `currency`:

```text
SUM(DEBIT.amount_minor) = SUM(CREDIT.amount_minor)
```

Prisma no expresa esta garantía completa. Se requiere procedimiento de contabilización o trigger diferido.

## 5.2 Inmutabilidad

Bloquear actualización o borrado destructivo en:

- asientos y transacciones contabilizadas;
- boletos pagados;
- resultados y snapshots;
- versiones de reglas usadas;
- informes publicados;
- historial y auditoría;
- resultados de sorteos creados por usuarios.

Las correcciones usan transacciones compensatorias.

## 5.3 Índices parciales

Migración SQL obligatoria para:

```text
Una conversion_assignment ACTIVA por solicitud.
Una combination_reservation ACTIVA por combinación.
Un user_role activo por usuario+rol.
Un user_permission_grant activo por usuario+permiso.
```

## 5.4 Checks temporales

```text
draw_event.sales_open_at < sales_close_at < draw_at
combination_reservation.expires_at <= draw_event.sales_close_at
user_draw_access_code.expires_at <= user_draw.sales_close_at
valid_until > valid_from
```

## 5.5 Unicidad crítica

- Combinación por evento.
- Boleto por evento+combinación.
- Resultado por evento.
- Premio por evento+boleto+categoría.
- Snapshot final por evento/sorteo.
- Finalización única por solicitud.
- Número único por sorteo de usuario.
- Una única ocupación activa por `user_draw_numbers.id`: no puede existir simultáneamente una reserva activa de código y una asignación activa de participación. Se controla bloqueando la fila del número y mediante procedimiento/trigger transversal.
- Código de un uso.
- Liquidación terminal única del escrow.

## 5.6 CITEXT y extensiones

Correo y username requieren extensión `citext` o índices funcionales equivalentes. Debe incluirse en la migración inicial.

## 5.7 Integridad contextual de identificadores redundantes

Las columnas redundantes de usuario, evento o sorteo se conservan para índices y consultas, pero no pueden divergir de su relación principal. Prisma no expresa todas estas igualdades; la migración debe usar claves compuestas o triggers diferidos.

Controles mínimos:

- `combination_numbers.(combination_id,draw_event_id)` coincide con `event_combinations.(id,draw_event_id)`.
- `shopping_carts.(purchase_session_id,user_id,draw_event_id)` coincide con `purchase_sessions`.
- `combination_reservations` pertenece al mismo `draw_event_id` que combinación y sesión, y al mismo `user_id` que la sesión.
- `cart_items` relaciona una reserva, combinación y carrito del mismo usuario/evento.
- `purchase_orders` pertenece al mismo usuario/evento/carrito.
- `tickets` coincide con orden, combinación, evento, usuario y `rule_version_id`.
- `user_draw_numbers`, códigos, participaciones y asignaciones pertenecen al mismo `user_draw_id`.
- `user_draw_participation_numbers` solo une una participación y un número del mismo sorteo.
- Las entradas de snapshot y el resultado pertenecen al snapshot/sorteo correspondiente.
- `user_draw_escrows`, entrega y reclamos pertenecen al mismo sorteo de usuario.

Además:

```text
event_combinations.status = RESERVADA  ⇔ existe una reservation ACTIVA
event_combinations.status = VENDIDA   ⇔ existe un ticket confirmado
```

Las transiciones que cambien reserva, combinación, orden o boleto deben mantener esas condiciones en la misma transacción.

# 6. Índices mínimos recomendados

| Tabla | Índice |
|---|---|
| `draw_events` | `(lottery_product_id,status,sales_open_at,sales_close_at)` |
| `event_combinations` | `(draw_event_id,status,normalized_key)` |
| `combination_numbers` | `(draw_event_id,symbol,combination_id)` |
| `combination_reservations` | `(user_id,draw_event_id,status)`, `(expires_at)` |
| `tickets` | `(user_id,purchased_at DESC)`, `(draw_event_id,evaluation_status)` |
| `conversion_requests` | `(status,expires_at)`, `(client_user_id,created_at DESC)` |
| `conversion_assignments` | `(vendor_user_id,status)` |
| `ledger_entries` | `(account_id,created_at)`, `(ledger_transaction_id)` |
| `ledger_transactions` | `(business_reference_type,business_reference_id)`, `(correlation_id)` |
| `scheduled_jobs` | `(status,run_at)` |
| `outbox_events` | `(status,available_at)` |
| `audit_events` | `(actor_user_id,occurred_at)`, `(resource_type,resource_id)` |
| `user_draws` | `(visibility,status,sales_open_at)` |
| `user_draw_participations` | `(user_draw_id,payment_status,eligibility_status)` |
| `user_draw_access_codes` | `(user_draw_id,use_status,expires_at)` |
| `user_draw_claims` | `(user_draw_id,status)` |

# 7. Vistas y proyecciones

| Vista | Fuente | Propósito |
|---|---|---|
| `v_wallet_balances` | Ledger | Disponible, reservado, pendiente, bloqueado y retiro. |
| `v_ledger_trial_balance` | Asientos | Balance por transacción y moneda. |
| `v_vendor_inventory` | Lotes/asignaciones | Inventario y coste restante. |
| `v_vendor_realized_profit` | Ventas/lotes | Ganancia realizada. |
| `v_event_availability` | Combinaciones/reservas | Disponible, reservada, vendida y agotado derivado. |
| `v_client_event_limit` | Tickets/reservas | Consumo del 20 %. |
| `v_event_financial_position` | Ledger/config | Ventas, obligaciones y premio. |
| `v_public_result_reports` | Informes | Allowlist pública. |
| `v_user_draw_participant_history` | Participaciones/asignaciones/códigos/reclamos | Historial completo. |
| `v_user_draw_escrow_position` | Ledger/escrow | 95 %, comisión, liberado y reembolsado. |

# 8. Seeds mínimos

## Roles globales

```text
CLIENTE
VENDEDOR
ADMINISTRADOR
```

No crear `ORGANIZADOR`.

## Productos oficiales

| Código | Selección | Universo | Combinaciones |
|---|---:|---|---:|
| OCTAL | 4 | 0–7 | 70 |
| DECIMAL | 5 | 0–9 | 252 |
| HEXADECIMAL | 6 | 0–9,A–F | 8 008 |

## Permisos

Las claves proceden de `MATRIZ-DE-PERMISOS.md`; no se codifican como columnas booleanas de `users`.

## Cuentas técnicas

Los seeds solo crean cuentas aprobadas en `FLUJOS-FINANCIEROS.md`, entre ellas:

```text
SIMULATED_TOPUP_SOURCE_REAL
SIMULATED_PAYOUT_CLEARING_REAL
PLATFORM_REAL_CASH
PLATFORM_VIRTUAL_ISSUANCE
PLATFORM_VIRTUAL_REDEMPTION
GENERAL_CONVERSION_WALLET
CONVERSION_FEES_VIRTUAL
PLATFORM_OPERATIONS_VIRTUAL
ROUNDING_ADJUSTMENTS_VIRTUAL
GUARANTEE_FUND_AVAILABLE
FUTURE_PRIZE_FUND
ACCUMULATION_POOL_{PRODUCT}
```

# 9. Privacidad y retención

| Dato | Control |
|---|---|
| Password/token | Solo hash; nunca log. |
| Documento/contacto | Acceso mínimo y protección; no público. |
| Cédula automática | Excluida del MVP. |
| Ledger/boletos/resultados | Conservación histórica. |
| Auditoría | Append-only. |
| Evidencia | Acceso restringido y hash de archivo. |
| Informe público | Allowlist sin identidad. |
| Payload de proveedor | Sanitizado; sin tarjeta. |

# 10. Decisiones cerradas y parámetros de implementación

## 10.1 Política monetaria cerrada

La política de residuos está resuelta por `LOT-FIN-013`:

- método de mayores residuos para repartos que suman 100 %;
- prioridades deterministas por operación;
- registro del cálculo en el agregado y/o `ledger_transactions.calculation_snapshot`;
- compras mayoristas en incrementos de `1,00 VIRTUAL`;
- redondeo público de premios contra `ROUNDING_ADJUSTMENTS_VIRTUAL`.

No queda un bloqueo económico para crear Prisma o SQL.

## 10.2 Parámetros técnicos no funcionales

Estas decisiones pueden concretarse durante implementación porque no cambian las reglas del dominio:

- UUID v7 generado por la aplicación; Prisma lo representa como UUID.
- Formato de `public_id` por prefijo y codificación no secuencial.
- Retención exacta de tokens, logs y archivos.
- Proveedor S3 compatible.
- MFA administrativo.
- Integraciones reales fuera del MVP.
- Particionado futuro según volumen.

Su elección debe documentarse en ADR cuando afecte seguridad, operación o compatibilidad, pero no reabre la lógica de negocio.

# 11. Orden recomendado para Prisma

1. Enums.
2. Identidad, roles, permisos, sesiones y términos.
3. Wallets, idempotencia y ledger.
4. Sistema básico: objetos, jobs, outbox y auditoría.
5. Vendedores y solicitudes.
6. Productos, versiones, plantillas y eventos.
7. Combinaciones, reservas, órdenes y boletos.
8. Fondos.
9. Resultados, premios e informes.
10. Sorteos creados por usuarios.
11. SQL complementario.
12. Seeds.
13. Pruebas de integridad/concurrencia.

# 12. Verificación automática

- Tablas de la baseline física final: **101**.
- Tablas documentadas: **101**.
- Tablas provenientes del Plan base v1.0: **73**.
- Extensiones aprobadas e incorporadas al Plan v1.1.0: **28**.
- Referencias FK analizadas: **236**.
- Reglas LOT distintas verificadas: **100**.
- Tablas duplicadas: **0**.
- Campos duplicados por tabla: **0**.
- FKs hacia tablas desconocidas: **0**.
- Reglas LOT desconocidas: **0**.
- Tablas obligatorias omitidas: **0**.

# 13. Criterios de aprobación documental

- [x] Se aprueban dominios y nombres de tabla.
- [x] Se aprueban enums y estados.
- [x] Se aprueba RBAC global + permisos granulares.
- [x] Se aprueba Organizador como relación contextual.
- [x] Se aprueban cuentas, ledger y proyecciones.
- [x] Se aprueban combinaciones, reservas, órdenes y boletos.
- [x] Se aprueban dimensiones separadas de ticket y participación.
- [x] Se aprueban códigos, reclamos, entrega y escrow.
- [x] Se aprueba `stored_objects`.
- [x] Se aprueban checks, triggers e índices parciales.
- [x] Se aprueba `LOT-FIN-013` y se elimina el bloqueo por residuos.

## 13.1 Gates de implementación

- [ ] El `schema.prisma` conserva nombres y relaciones.
- [ ] Las migraciones se validan contra reglas, estados, flujos y permisos.

# 14. Decisión de salida

Con este diccionario aprobado queda permitido:

- escribir `prisma/schema.prisma`;
- crear la migración inicial;
- añadir SQL complementario;
- crear seeds;
- generar ERD;
- implementar repositorios y pruebas.

No queda permitido:

- eliminar tablas del Plan sin decisión formal;
- guardar saldos como fuente de verdad;
- sustituir relaciones críticas con JSONB;
- inventar estados;
- incorporar cédula automática;
- aceptar ledger desbalanceado;
- editar historia confirmada.

> **Decisión obligatoria:** el `schema.prisma` debe traducir este documento, no reinterpretarlo.


# 15. Declaración de congelamiento

Los nombres de tabla, relaciones, estados, fuentes de verdad y restricciones descritos aquí constituyen el contrato de datos final de la versión 1.

Prisma puede cambiar el orden de declaración o los nombres internos de relaciones, pero no puede eliminar entidades, convertir proyecciones en fuente de verdad, debilitar unicidades ni sustituir historial por borrado destructivo.
