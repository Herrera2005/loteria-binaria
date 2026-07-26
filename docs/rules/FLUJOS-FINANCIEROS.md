---
title: "Flujos Financieros y Verificación de Doble Entrada — Lotería Binaria"
version: "1.1.0"
status: "APROBADO Y CONGELADO — baseline financiera para implementación v1"
author: "Cristhian Herrera Nieto"
date: "2026-07-26"
repository: "Herrera2005/loteria-binaria"
normative_rules: "REGLAS-NEGOCIO.md v1.4.0"
state_model: "ESTADOS-Y-TRANSICIONES.md v1.1.0"
architecture_decision: "ADR-ORG-001"
---

# FLUJOS FINANCIEROS Y VERIFICACIÓN DE DOBLE ENTRADA — LOTERÍA BINARIA

**Versión:** 1.1.0  
**Estado:** **APROBADO Y CONGELADO** para implementación v1.  
**Ruta objetivo:** `docs/FLUJOS-FINANCIEROS.md`  
**Reglas base:** `docs/REGLAS-NEGOCIO.md` v1.4.0  
**Estados base:** `docs/ESTADOS-Y-TRANSICIONES.md` v1.1.0  
**ADR aplicable:** `ADR-ORG-001`

> [!WARNING]
> En la fase académica, las recargas, saldos, conversiones, retiros, premios y movimientos son simulados. Este documento define integridad interna y trazabilidad; no convierte el proyecto en una plataforma autorizada para operar dinero, pagos, apuestas o premios reales.

## 0. Propósito

Este documento congela los flujos financieros que deberá implementar el backend y verifica que cada operación posea doble entrada balanceada por unidad monetaria.

Objetivos:

- Evitar creación o desaparición silenciosa de REAL o VIRTUAL.
- Separar completamente ambas unidades.
- Definir cuentas fuente y destino para cada operación.
- Relacionar estado, ledger, idempotencia y auditoría.
- Impedir doble cobro, doble conversión, doble premio y doble reembolso.
- Identificar operaciones que no deben generar asientos.
- Servir como base de `DICCIONARIO-DE-DATOS.md`, Prisma, SQL y pruebas de integración.

Referencias transversales: `LOT-FIN-001`, `LOT-FIN-005`, `LOT-FIN-006`, `LOT-FIN-007`, `LOT-FIN-012`, `LOT-GOV-002`, `LOT-GOV-003`, `LOT-GOV-004`.

## 0.1 Autoridad documental

Precedencia:

1. Documento Maestro v1.0 y adendas aprobadas, incluido `ADR-ORG-001`.
2. `REGLAS-NEGOCIO.md` v1.4.0.
3. Contratos especializados aprobados: `ESTADOS-Y-TRANSICIONES.md`, este documento, `MATRIZ-DE-PERMISOS.md` y `DICCIONARIO-DE-DATOS.md`, cada uno dentro de su materia.
4. `PLAN-TECNICO.md` v1.1.0.
5. OpenAPI, `schema.prisma` y migraciones.
6. Código y pruebas.
7. README como guía operativa.

Si una fórmula, tarifa, redondeo o fuente de fondos no está respaldada por los documentos anteriores, no debe inventarse dentro de SQL.

## 0.2 Convención contable del subledger

El proyecto usa un **subledger operativo de transferencias**, siguiendo el ejemplo del Plan Técnico:

```text
Débito   = cuenta fuente del valor
Crédito  = cuenta destino del valor
```

Todos los importes de `ledger_entries` son positivos. El lado (`DEBIT` o `CREDIT`) determina el sentido.

Este convenio garantiza conservación de saldos dentro del sistema, pero no sustituye la contabilidad societaria, fiscal o bancaria de una empresa. Una integración futura con contabilidad externa deberá mapear estas cuentas mediante un ADR separado sin reescribir el historial operativo.

## 0.3 Invariante de doble entrada

Para cada `ledger_transaction` y para cada unidad:

```text
Σ(DEBIT.amount_minor WHERE currency = X)
=
Σ(CREDIT.amount_minor WHERE currency = X)
```

Reglas:

- REAL se balancea solo con REAL.
- VIRTUAL se balancea solo con VIRTUAL.
- Una operación puede contener ambos grupos, pero cada grupo debe cerrar en cero.
- Cada grupo monetario tiene al menos dos asientos.
- `amount_minor` es `BIGINT`, positivo y representa centavos/centésimas.
- Una transacción desbalanceada no puede pasar a `CONTABILIZADA`.
- Un asiento confirmado no se edita.
- Un reverso crea otra transacción enlazada mediante `reversal_of_transaction_id`.

## 0.4 Ejemplo multimoneda correcto

Compra mayorista de 100,00 VIRTUAL:

```text
Grupo REAL
  Débito   USER_REAL_AVAILABLE       90,00
  Crédito  PLATFORM_REAL_CASH    90,00

Grupo VIRTUAL
  Débito   PLATFORM_VIRTUAL_ISSUANCE  100,00
  Crédito  USER_VIRTUAL_AVAILABLE   100,00
```

No existe un asiento que debite REAL y acredite VIRTUAL. La relación 0,90→1,00 pertenece a la operación de dominio, no al balance de una sola moneda.

## 0.5 Datos mínimos por transacción

| Campo | Regla |
|---|---|
| `id` | UUID inmutable. |
| `transaction_type` | Tipo estable de operación. |
| `status` | `CONTABILIZADA`, `PARCIALMENTE_REVERSADA` o `REVERSADA` según la máquina FIN-LED. |
| `correlation_id` | Une comando, estados, ledger, worker y auditoría. |
| `idempotency_key_id` | Obligatorio en comandos críticos. |
| `business_reference_type/id` | Solicitud, boleto, evento, premio, participación, código, reclamo, etc. |
| `rule_version_id` | Obligatorio cuando tarifa o fórmula es histórica. |
| `reversal_of_transaction_id` | Solo para compensaciones. |
| `created_at` | Hora oficial del servidor. |
| `metadata` | Desglose de tarifa y cálculos, sin secretos. |

## 0.6 Datos mínimos por asiento

| Campo | Regla |
|---|---|
| `ledger_transaction_id` | FK obligatoria. |
| `account_id` | Cuenta de la misma unidad del asiento. |
| `currency` | `REAL` o `VIRTUAL`. |
| `side` | `DEBIT` o `CREDIT`. |
| `amount_minor` | `BIGINT > 0`. |
| `sequence` | Orden determinista dentro de la transacción. |
| `memo_code` | Motivo normalizado. |

---

# 1. Catálogo lógico de cuentas

Los nombres son plantillas de dominio, no nombres SQL definitivos.

## 1.1 Usuarios

| Cuenta lógica | Unidad | Uso |
|---|---|---|
| `USER_REAL_AVAILABLE` | REAL | Disponible del usuario. |
| `USER_REAL_RESERVED_CONVERSION` | REAL | REAL reservado para solicitud Cliente→Vendedor. |
| `USER_REAL_IN_WITHDRAWAL` | REAL | REAL bloqueado en retiro. |
| `USER_VIRTUAL_AVAILABLE` | VIRTUAL | Saldo VIRTUAL global del usuario. En cada flujo se identifica el propietario contextual: Cliente, Vendedor, emisor, destinatario, participante, financiador, ganador u Organizador. |

## 1.2 Plataforma

| Cuenta lógica | Unidad | Uso |
|---|---|---|
| `PLATFORM_REAL_CASH` | REAL | REAL controlado por la plataforma en el subledger. |
| `SIMULATED_TOPUP_SOURCE_REAL` | REAL | Fuente técnica de recargas académicas. |
| `SIMULATED_PAYOUT_CLEARING_REAL` | REAL | Destino técnico de retiros simulados. |
| `PLATFORM_VIRTUAL_ISSUANCE` | VIRTUAL | Fuente técnica de emisión VIRTUAL. |
| `PLATFORM_VIRTUAL_REDEMPTION` | VIRTUAL | Principal VIRTUAL retirado en conversiones. |
| `GENERAL_CONVERSION_WALLET` | VIRTUAL | Respaldo de solicitudes no atendidas. |
| `CONVERSION_FEES_VIRTUAL` | VIRTUAL | Comisión del 10 % de conversión. |
| `PLATFORM_OPERATIONS_VIRTUAL` | VIRTUAL | Operación/margen en VIRTUAL. |
| `ROUNDING_ADJUSTMENTS_VIRTUAL` | VIRTUAL | Cuenta neutral para diferencias de redondeo público a cuartos. |
| `USER_DRAW_COMMISSION_HELD` | VIRTUAL | Comisión del 5 % retenida mientras aún puede revertirse. |

## 1.3 Lotería oficial y fondos

| Cuenta lógica | Unidad | Uso |
|---|---|---|
| `DRAW_SALES_FUND` | VIRTUAL | Ventas confirmadas del evento. |
| `DRAW_PRIZE_RESERVE` | VIRTUAL | Premio inicial, crecimiento y apoyos financiados. |
| `AWARD_PAYABLE` | VIRTUAL | Obligación preparada para boleto/categoría. |
| `DRAW_UNAWARDED_MAJOR_PRIZE` | VIRTUAL | Premio mayor no entregado. |
| `DRAW_ACCUMULATION_EXTRA` | VIRTUAL | Acumulado heredado asignado al evento. |
| `GUARANTEE_FUND_AVAILABLE` | VIRTUAL | Fondo general disponible. |
| `GUARANTEE_FUND_RESERVED_EVENT` | VIRTUAL | Cobertura bloqueada por evento. |
| `FUTURE_PRIZE_FUND` | VIRTUAL | Fondo de premios futuros. |
| `ACCUMULATION_POOL_PRODUCT` | VIRTUAL | Pool Octal, Decimal o Hexadecimal. |

## 1.4 Sorteos creados por usuarios

| Cuenta lógica | Unidad | Uso |
|---|---|---|
| `USER_DRAW_ESCROW` | VIRTUAL | 95 % retenido por sorteo. |
| `USER_DRAW_COMMISSION_HELD` | VIRTUAL | La misma cuenta canónica definida en plataforma; mantiene el 5 % retenido hasta devengo o reverso. |

Las wallets del participante, financiador y Organizador usan la cuenta canónica `USER_VIRTUAL_AVAILABLE` con propietarios distintos.

## 1.5 Cuentas técnicas y autorización de sobregiro

Las cuentas de usuario y fondos disponibles no pueden quedar negativas.

En el MVP académico, `allows_negative = TRUE` se limita a las fuentes técnicas:

- `SIMULATED_TOPUP_SOURCE_REAL`;
- `PLATFORM_VIRTUAL_ISSUANCE`.

Las demás cuentas, incluidas `PLATFORM_REAL_CASH`, `GENERAL_CONVERSION_WALLET`, fondos, escrow, wallets de usuario y `ROUNDING_ADJUSTMENTS_VIRTUAL`, no pueden quedar negativas.

Toda cuenta técnica autorizada exige:

- tipo de cuenta explícito;
- límite o política documentada;
- auditoría;
- reconciliación;
- prohibición de uso desde endpoints generales.

Una futura cuenta fuente de proveedor o tesorería requiere ADR y migración; no se habilita cambiando una fila manualmente.

Referencia: `LOT-FIN-007`.

---

# 2. Reglas de cálculo

## 2.1 Conversión VIRTUAL→REAL

```text
[net_virtual_equivalent, fee_virtual] =
  largest_remainder_split(amount_virtual, [9000, 1000], priority=[NET, FEE])

net_real = net_virtual_equivalent
```

La función trabaja en minor units, conserva el cálculo y aplica la prioridad de `LOT-FIN-013`.

## 2.2 Compra mayorista

```text
require virtual_amount_minor % 100 = 0
real_cost_minor = virtual_amount_minor * 90 / 100
virtual_credit_minor = virtual_amount_minor
```

## 2.3 Participación de sorteo de usuario

```text
[escrow_virtual, commission_virtual] =
  largest_remainder_split(price_virtual, [9500, 500], priority=[ESCROW, COMMISSION])
```

## 2.4 Distribución sin ganador

```text
[accumulation, guarantee, future_prize, operations] =
  largest_remainder_split(base_minor, [5000, 2500, 1500, 1000],
                          priority=[ACCUMULATION, GUARANTEE, FUTURE_PRIZE, OPERATIONS])
```

## 2.5 Momento de liquidación de ventas oficiales

Mientras un evento pueda cancelarse ordinariamente —hasta antes de `RESULTADO_FIJADO`— el importe bruto de cada boleto permanece contablemente en `DRAW_SALES_FUND`.

- El premio creciente, la recuperación de garantía y la porción operativa se muestran como proyecciones verificables.
- FF-EVT-002, FF-EVT-003 y FF-EVT-004 solo se contabilizan después de fijar el resultado y antes de preparar obligaciones finales.
- Una cancelación anterior al resultado usa `DRAW_SALES_FUND`, que debe conservar exactamente la suma de precios pagados no reembolsados.
- Una diferencia entre ventas y fondo del evento es una anomalía de reconciliación y bloquea la cancelación automática hasta reparación; no autoriza reducir el reembolso.

Referencias: `LOT-EVT-018`, `LOT-EVT-019`, `LOT-PRZ-005`, `LOT-FIN-012`.

## 2.6 Política final de minor units y residuos

La baseline v1 usa `LOT-FIN-013`.

### Método general

Para un monto entero `base_minor` y porcentajes que suman 100 %:

1. Calcular la cuota exacta racional de cada componente.
2. Asignar a cada componente su parte entera inferior.
3. Calcular las minor units todavía no asignadas.
4. Entregarlas una por una a los componentes con mayor residuo fraccionario.
5. Resolver empates mediante la prioridad congelada de la operación.
6. Guardar `base_minor`, tasas, partes enteras, residuos, prioridad y resultado.

### Prioridades

| Operación | Componentes | Prioridad de desempate |
|---|---|---|
| Conversión VIRTUAL→REAL | 90 % neto / 10 % comisión | Neto del usuario → comisión |
| Sorteo de usuario | 95 % escrow / 5 % comisión | Escrow → comisión |
| Crecimiento oficial | 90 % premio / 10 % operación | Premio → operación |
| Evento sin ganador | 50/25/15/10 | Acumulado → garantía → premios futuros → operación |

### Compra mayorista

El Vendedor compra en incrementos de `1,00 VIRTUAL` (`100` minor units). Así, cada bloque acredita exactamente `1,00 VIRTUAL` y debita exactamente `0,90 REAL`. Una orden que no respete el incremento se rechaza antes del ledger.

### Redondeo público de premios

El redondeo a cuartos continúa regido por `LOT-PRZ-006`. Las diferencias positivas o negativas se mueven contra `ROUNDING_ADJUSTMENTS_VIRTUAL`, no se pierden ni se incorporan silenciosamente a otro fondo.

Esta política elimina el último bloqueo económico transversal del diseño SQL.

---

# 3. Flujos verificados

## FF-SYS-001 — Fondeo controlado de liquidez de plataforma
**Reglas:** `LOT-FIN-005`, `LOT-FIN-007`, `LOT-FIN-012`, `LOT-VND-009`, `LOT-GOV-008`  
**Estado/transición:** `Apertura de entorno o aporte de liquidez autorizado`  
**Disparador de ejemplo:** En el entorno académico se fondean 1.000,00 REAL de caja operativa y 1.000,00 VIRTUAL de respaldo de conversiones.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| REAL | DEBIT | `SIMULATED_TOPUP_SOURCE_REAL` | 1.000,00 |
| REAL | CREDIT | `PLATFORM_REAL_CASH` | 1.000,00 |
| VIRTUAL | DEBIT | `PLATFORM_VIRTUAL_ISSUANCE` | 1.000,00 |
| VIRTUAL | CREDIT | `GENERAL_CONVERSION_WALLET` | 1.000,00 |

**Verificación:**

- REAL: débitos 1.000,00 = créditos 1.000,00; diferencia **0,00**.
- VIRTUAL: débitos 1.000,00 = créditos 1.000,00; diferencia **0,00**.

**Nota:** No se insertan saldos iniciales directamente en proyecciones. Cada fondeo usa un ledger, permiso reforzado o seed de entorno no productivo, motivo y auditoría. En producción las cuentas fuente deben sustituirse por tesorería/proveedor autorizado.

## FF-REAL-001 — Recarga académica de saldo REAL
**Reglas:** `LOT-FIN-008`, `LOT-FIN-012`  
**Estado/transición:** `FIN-TOP: CREADA → CONFIRMADA_SIMULADA`  
**Disparador de ejemplo:** El simulador confirma una recarga de 100,00 REAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| REAL | DEBIT | `SIMULATED_TOPUP_SOURCE_REAL` | 100,00 |
| REAL | CREDIT | `USER_REAL_AVAILABLE` | 100,00 |

**Verificación:**

- REAL: débitos 100,00 = créditos 100,00; diferencia **0,00**.

**Nota:** No existe comisión. En una integración real, la cuenta fuente se sustituye por la cuenta de clearing/proveedor aprobada.

## FF-VND-REQ-001 — Reserva de REAL al crear solicitud Cliente→Vendedor
**Reglas:** `LOT-VND-003`, `LOT-FIN-006`, `LOT-FIN-012`  
**Estado/transición:** `TR-VND-REQ-001`  
**Disparador de ejemplo:** El Cliente crea una solicitud por 100,00 REAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| REAL | DEBIT | `USER_REAL_AVAILABLE` | 100,00 |
| REAL | CREDIT | `USER_REAL_RESERVED_CONVERSION` | 100,00 |

**Verificación:**

- REAL: débitos 100,00 = créditos 100,00; diferencia **0,00**.

**Nota:** No acredita VIRTUAL todavía. La reserva permanece hasta finalización o liberación.

## FF-VND-REQ-002 — Liberación de REAL reservado
**Reglas:** `LOT-VND-008`, `LOT-VND-010`, `LOT-FIN-012`  
**Estado/transición:** `TR-VND-REQ-003 o TR-VND-REQ-006`  
**Disparador de ejemplo:** La solicitud se cancela/libera o falla por liquidez.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| REAL | DEBIT | `USER_REAL_RESERVED_CONVERSION` | 100,00 |
| REAL | CREDIT | `USER_REAL_AVAILABLE` | 100,00 |

**Verificación:**

- REAL: débitos 100,00 = créditos 100,00; diferencia **0,00**.

**Nota:** La cancelación de una asignación no libera el REAL si la solicitud vuelve a PENDIENTE; este flujo se usa cuando la solicitud termina sin conversión.

## FF-VND-PO-001 — Compra mayorista del Vendedor 0,90 REAL → 1,00 VIRTUAL
**Reglas:** `LOT-VND-001`, `LOT-VND-002`, `LOT-FIN-005`, `LOT-FIN-012`, `LOT-FIN-013`  
**Estado/transición:** `VND-PO: PROCESANDO → CONFIRMADA`  
**Disparador de ejemplo:** El Vendedor compra 100,00 VIRTUAL por 90,00 REAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| REAL | DEBIT | `USER_REAL_AVAILABLE` | 90,00 |
| REAL | CREDIT | `PLATFORM_REAL_CASH` | 90,00 |
| VIRTUAL | DEBIT | `PLATFORM_VIRTUAL_ISSUANCE` | 100,00 |
| VIRTUAL | CREDIT | `USER_VIRTUAL_AVAILABLE` | 100,00 |

**Verificación:**

- REAL: débitos 90,00 = créditos 90,00; diferencia **0,00**.
- VIRTUAL: débitos 100,00 = créditos 100,00; diferencia **0,00**.

**Nota:** REAL y VIRTUAL se balancean por separado. El lote registra coste 90,00 REAL y cantidad 100,00 VIRTUAL; la ganancia aún es potencial.

## FF-VND-REQ-003 — Solicitud completada por Vendedor
**Reglas:** `LOT-VND-007`, `LOT-VND-010`, `LOT-FIN-012`  
**Estado/transición:** `TR-VND-REQ-004`  
**Disparador de ejemplo:** El Vendedor atiende una solicitud de 100,00.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| REAL | DEBIT | `USER_REAL_RESERVED_CONVERSION` | 100,00 |
| REAL | CREDIT | `USER_REAL_AVAILABLE` | 100,00 |
| VIRTUAL | DEBIT | `USER_VIRTUAL_AVAILABLE` | 100,00 |
| VIRTUAL | CREDIT | `USER_VIRTUAL_AVAILABLE` | 100,00 |

**Verificación:**

- REAL: débitos 100,00 = créditos 100,00; diferencia **0,00**.
- VIRTUAL: débitos 100,00 = créditos 100,00; diferencia **0,00**.

**Nota:** La finalización, la venta del inventario y ambos pares de asientos se confirman en una sola transacción. Las cuentas `USER_*` pertenecen a usuarios distintos según el rol indicado por el flujo.

## FF-VND-REQ-004 — Solicitud completada por la plataforma a los cinco minutos
**Reglas:** `LOT-VND-009`, `LOT-VND-010`, `LOT-FIN-012`  
**Estado/transición:** `TR-VND-REQ-005`  
**Disparador de ejemplo:** El fallback completa una solicitud de 100,00.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| REAL | DEBIT | `USER_REAL_RESERVED_CONVERSION` | 100,00 |
| REAL | CREDIT | `PLATFORM_REAL_CASH` | 100,00 |
| VIRTUAL | DEBIT | `GENERAL_CONVERSION_WALLET` | 100,00 |
| VIRTUAL | CREDIT | `USER_VIRTUAL_AVAILABLE` | 100,00 |

**Verificación:**

- REAL: débitos 100,00 = créditos 100,00; diferencia **0,00**.
- VIRTUAL: débitos 100,00 = créditos 100,00; diferencia **0,00**.

**Nota:** La restricción de finalización única impide que el Vendedor y la plataforma ejecuten ambos efectos.

## FF-CON-001 — Conversión VIRTUAL→REAL con comisión del 10 %
**Reglas:** `LOT-FIN-009`, `LOT-FIN-012`, `LOT-FIN-013`  
**Estado/transición:** `FIN-CON: PROCESANDO → COMPLETADA`  
**Disparador de ejemplo:** El usuario convierte 500,00 VIRTUAL y recibe 450,00 REAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `USER_VIRTUAL_AVAILABLE` | 500,00 |
| VIRTUAL | CREDIT | `PLATFORM_VIRTUAL_REDEMPTION` | 450,00 |
| VIRTUAL | CREDIT | `CONVERSION_FEES_VIRTUAL` | 50,00 |
| REAL | DEBIT | `PLATFORM_REAL_CASH` | 450,00 |
| REAL | CREDIT | `USER_REAL_AVAILABLE` | 450,00 |

**Verificación:**

- VIRTUAL: débitos 500,00 = créditos 500,00; diferencia **0,00**.
- REAL: débitos 450,00 = créditos 450,00; diferencia **0,00**.

**Nota:** Los 50,00 de comisión se registran en VIRTUAL. La emisión del REAL se balancea independientemente con PLATFORM_REAL_CASH.

## FF-WDR-001 — Reserva de REAL para retiro
**Reglas:** `LOT-FIN-006`, `LOT-FIN-010`, `LOT-FIN-012`  
**Estado/transición:** `FIN-WDR: SOLICITADO → EN_REVISION`  
**Disparador de ejemplo:** El usuario solicita retirar 450,00 REAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| REAL | DEBIT | `USER_REAL_AVAILABLE` | 450,00 |
| REAL | CREDIT | `USER_REAL_IN_WITHDRAWAL` | 450,00 |

**Verificación:**

- REAL: débitos 450,00 = créditos 450,00; diferencia **0,00**.

**Nota:** No cobra una segunda comisión.

## FF-WDR-002 — Rechazo de retiro y liberación
**Reglas:** `LOT-FIN-010`, `LOT-FIN-012`  
**Estado/transición:** `FIN-WDR: EN_REVISION → RECHAZADO`  
**Disparador de ejemplo:** El retiro de 450,00 REAL es rechazado.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| REAL | DEBIT | `USER_REAL_IN_WITHDRAWAL` | 450,00 |
| REAL | CREDIT | `USER_REAL_AVAILABLE` | 450,00 |

**Verificación:**

- REAL: débitos 450,00 = créditos 450,00; diferencia **0,00**.

**Nota:** La operación compensa la reserva; no crea ingresos ni comisiones.

## FF-WDR-003 — Retiro REAL completado en simulación
**Reglas:** `LOT-FIN-010`, `LOT-FIN-012`  
**Estado/transición:** `FIN-WDR: APROBADO → COMPLETADO_SIMULADO`  
**Disparador de ejemplo:** El simulador marca como entregados 450,00 REAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| REAL | DEBIT | `USER_REAL_IN_WITHDRAWAL` | 450,00 |
| REAL | CREDIT | `SIMULATED_PAYOUT_CLEARING_REAL` | 450,00 |

**Verificación:**

- REAL: débitos 450,00 = créditos 450,00; diferencia **0,00**.

**Nota:** No representa una transferencia bancaria real. Un proveedor real requerirá cuentas de clearing y conciliación propias.

## FF-TRF-001 — Transferencia VIRTUAL entre Clientes
**Reglas:** `LOT-FIN-011`, `LOT-FIN-012`  
**Estado/transición:** `FIN-TRF: PROCESANDO → COMPLETADA`  
**Disparador de ejemplo:** Un Cliente transfiere 25,00 VIRTUAL a otro.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `USER_VIRTUAL_AVAILABLE` | 25,00 |
| VIRTUAL | CREDIT | `USER_VIRTUAL_AVAILABLE` | 25,00 |

**Verificación:**

- VIRTUAL: débitos 25,00 = créditos 25,00; diferencia **0,00**.

**Nota:** La auto-transferencia se rechaza antes de crear el ledger. Ambos asientos usan el tipo `USER_VIRTUAL_AVAILABLE`, pero con `account_id` de propietarios distintos.

## FF-FND-001 — Reserva de fondo de garantía para evento
**Reglas:** `LOT-PRZ-007`, `LOT-PRZ-008`, `LOT-FIN-012`  
**Estado/transición:** `PRZ-FND: PENDIENTE → RESERVADA`  
**Disparador de ejemplo:** Se reservan 200,00 VIRTUAL para un evento.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `GUARANTEE_FUND_AVAILABLE` | 200,00 |
| VIRTUAL | CREDIT | `GUARANTEE_FUND_RESERVED_EVENT` | 200,00 |

**Verificación:**

- VIRTUAL: débitos 200,00 = créditos 200,00; diferencia **0,00**.

**Nota:** Evita que la misma cobertura respalde dos eventos.

## FF-FND-002 — Liberación de reserva de garantía
**Reglas:** `LOT-PRZ-007`, `LOT-FIN-012`  
**Estado/transición:** `PRZ-FND: RESERVADA → LIBERADA`  
**Disparador de ejemplo:** Se liberan 200,00 VIRTUAL no consumidos.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `GUARANTEE_FUND_RESERVED_EVENT` | 200,00 |
| VIRTUAL | CREDIT | `GUARANTEE_FUND_AVAILABLE` | 200,00 |

**Verificación:**

- VIRTUAL: débitos 200,00 = créditos 200,00; diferencia **0,00**.

**Nota:** No es ingreso; solo cambia el componente disponible/reservado.

## FF-FND-003 — Consumo de garantía para financiar obligación del evento
**Reglas:** `LOT-PRZ-004`, `LOT-PRZ-007`, `LOT-FIN-012`  
**Estado/transición:** `PRZ-FND: RESERVADA → CONSUMIDA`  
**Disparador de ejemplo:** Se usan 50,00 VIRTUAL reservados para la obligación del evento.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `GUARANTEE_FUND_RESERVED_EVENT` | 50,00 |
| VIRTUAL | CREDIT | `DRAW_PRIZE_RESERVE` | 50,00 |

**Verificación:**

- VIRTUAL: débitos 50,00 = créditos 50,00; diferencia **0,00**.

**Nota:** La obligación queda identificada por evento y no puede financiar otro.

## FF-EVT-001 — Compra de boleto oficial
**Reglas:** `LOT-EVT-016`, `LOT-FIN-002`, `LOT-FIN-012`  
**Estado/transición:** `EVT-ORD: PROCESANDO → CONFIRMADA`  
**Disparador de ejemplo:** El Cliente compra un boleto de 1,00 VIRTUAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `USER_VIRTUAL_AVAILABLE` | 1,00 |
| VIRTUAL | CREDIT | `DRAW_SALES_FUND` | 1,00 |

**Verificación:**

- VIRTUAL: débitos 1,00 = créditos 1,00; diferencia **0,00**.

**Nota:** El boleto, la combinación VENDIDA, la reserva CONSUMIDA y el ledger se confirman juntos.

## FF-EVT-002 — Recuperación del adelanto de garantía con ventas
**Reglas:** `LOT-PRZ-005`, `LOT-PRZ-007`, `LOT-PRZ-010`, `LOT-FIN-012`  
**Estado/transición:** `Liquidación posterior a RESULTADO_FIJADO`  
**Disparador de ejemplo:** Las ventas recuperan 50,00 VIRTUAL adelantados por garantía.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `DRAW_SALES_FUND` | 50,00 |
| VIRTUAL | CREDIT | `GUARANTEE_FUND_AVAILABLE` | 50,00 |

**Verificación:**

- VIRTUAL: débitos 50,00 = créditos 50,00; diferencia **0,00**.

**Nota:** Se ejecuta antes de crear crecimiento cuando corresponde.

## FF-EVT-003 — Crecimiento del premio con el 90 % del excedente elegible
**Reglas:** `LOT-PRZ-003`, `LOT-PRZ-005`, `LOT-FIN-012`  
**Estado/transición:** `Liquidación posterior a RESULTADO_FIJADO`  
**Disparador de ejemplo:** Excedente elegible exacto de 100,00 VIRTUAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `DRAW_SALES_FUND` | 90,00 |
| VIRTUAL | CREDIT | `DRAW_PRIZE_RESERVE` | 90,00 |

**Verificación:**

- VIRTUAL: débitos 90,00 = créditos 90,00; diferencia **0,00**.

**Nota:** El ejemplo usa un monto divisible exactamente. La función de reparto debe trabajar con enteros y conservar el detalle del cálculo.

## FF-EVT-004 — Asignación del 10 % operativo del excedente
**Reglas:** `LOT-PRZ-005`, `LOT-FIN-012`  
**Estado/transición:** `Liquidación posterior a RESULTADO_FIJADO`  
**Disparador de ejemplo:** Mismo excedente elegible de 100,00 VIRTUAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `DRAW_SALES_FUND` | 10,00 |
| VIRTUAL | CREDIT | `PLATFORM_OPERATIONS_VIRTUAL` | 10,00 |

**Verificación:**

- VIRTUAL: débitos 10,00 = créditos 10,00; diferencia **0,00**.

**Nota:** FF-EVT-003 + FF-EVT-004 distribuyen exactamente el 100 % del excedente del ejemplo.

## FF-EVT-005 — Preparación y pago de reembolso íntegro por cancelación oficial
**Reglas:** `LOT-EVT-017`, `LOT-EVT-018`, `LOT-EVT-019`, `LOT-FIN-012`  
**Estado/transición:** `TR-EVT-011`  
**Disparador de ejemplo:** Se reembolsa un boleto de 1,00 VIRTUAL.

**Etapa A — Preparar la obligación**

| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `DRAW_SALES_FUND` | 1,00 |
| VIRTUAL | CREDIT | `AWARD_PAYABLE` | 1,00 |

**Etapa B — Acreditar al comprador**

| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `AWARD_PAYABLE` | 1,00 |
| VIRTUAL | CREDIT | `USER_VIRTUAL_AVAILABLE` | 1,00 |

**Verificación:**

- Etapa A: débitos 1,00 = créditos 1,00.
- Etapa B: débitos 1,00 = créditos 1,00.
- Diferencia final por etapa: **0,00**.

**Nota:** Antes de `RESULTADO_FIJADO`, `DRAW_SALES_FUND` debe conservar la suma íntegra de boletos pagados no reembolsados. Por tanto, una cancelación ordinaria se prepara exclusivamente desde ese fondo. Si la reconciliación detecta una diferencia, el proceso se detiene en revisión manual y la plataforma reconstituye el fondo mediante una compensación autorizada; nunca reduce el 100 % debido al Cliente.

## FF-PRZ-010 — Fondeo de la cuenta de ajustes de redondeo
**Reglas:** `LOT-PRZ-005`, `LOT-PRZ-006`, `LOT-FIN-012`  
**Estado/transición:** `Liquidación posterior a RESULTADO_FIJADO o reposición preventiva`  
**Disparador de ejemplo:** Se trasladan 1,00 VIRTUAL de la porción operativa a la cuenta neutral de ajustes.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `PLATFORM_OPERATIONS_VIRTUAL` | 1,00 |
| VIRTUAL | CREDIT | `ROUNDING_ADJUSTMENTS_VIRTUAL` | 1,00 |

**Verificación:**

- VIRTUAL: débitos 1,00 = créditos 1,00; diferencia **0,00**.

**Nota:** La cuenta de ajustes no puede quedar negativa. Los redondeos hacia abajo la reponen; cuando no alcanza para un redondeo hacia arriba, este flujo la fondea antes de preparar el premio. El fondeo no cambia el valor del premio ni crea VIRTUAL.

## FF-PRZ-001 — Preparación de premio exacto sin ajuste de redondeo
**Reglas:** `LOT-PRZ-003`, `LOT-PRZ-016`, `LOT-FIN-012`  
**Estado/transición:** `PRZ-AWD: CALCULADA → PREPARADA`  
**Disparador de ejemplo:** Premio exacto de 100,00 VIRTUAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `DRAW_PRIZE_RESERVE` | 100,00 |
| VIRTUAL | CREDIT | `AWARD_PAYABLE` | 100,00 |

**Verificación:**

- VIRTUAL: débitos 100,00 = créditos 100,00; diferencia **0,00**.

**Nota:** La cuenta payable queda ligada a evento, boleto y categoría.

## FF-PRZ-002 — Acreditación automática de premio o devolución
**Reglas:** `LOT-PRZ-002`, `LOT-PRZ-016`, `LOT-PRZ-017`, `LOT-FIN-012`  
**Estado/transición:** `PRZ-AWD: ACREDITANDO → ACREDITADA`  
**Disparador de ejemplo:** Se acredita una obligación de 100,00 VIRTUAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `AWARD_PAYABLE` | 100,00 |
| VIRTUAL | CREDIT | `USER_VIRTUAL_AVAILABLE` | 100,00 |

**Verificación:**

- VIRTUAL: débitos 100,00 = créditos 100,00; diferencia **0,00**.

**Nota:** La restricción evento+boleto+categoría impide una segunda acreditación.

## FF-PRZ-003 — Redondeo de premio hacia arriba
**Reglas:** `LOT-PRZ-006`, `LOT-PRZ-016`, `LOT-FIN-012`  
**Estado/transición:** `PRZ-AWD: CALCULADA → PREPARADA`  
**Disparador de ejemplo:** Valor exacto 10,13 VIRTUAL; valor público 10,25 VIRTUAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `DRAW_PRIZE_RESERVE` | 10,13 |
| VIRTUAL | DEBIT | `ROUNDING_ADJUSTMENTS_VIRTUAL` | 0,12 |
| VIRTUAL | CREDIT | `AWARD_PAYABLE` | 10,25 |

**Verificación:**

- VIRTUAL: débitos 10,25 = créditos 10,25; diferencia **0,00**.

**Nota:** La diferencia de 0,12 VIRTUAL se cubre desde la cuenta neutral de ajustes, previamente fondeada desde la porción operativa.

## FF-PRZ-004 — Redondeo de premio hacia abajo
**Reglas:** `LOT-PRZ-006`, `LOT-FIN-012`  
**Estado/transición:** `PRZ-AWD: CALCULADA → PREPARADA`  
**Disparador de ejemplo:** Valor exacto 10,37 VIRTUAL; valor público 10,25 VIRTUAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `DRAW_PRIZE_RESERVE` | 10,37 |
| VIRTUAL | CREDIT | `AWARD_PAYABLE` | 10,25 |
| VIRTUAL | CREDIT | `ROUNDING_ADJUSTMENTS_VIRTUAL` | 0,12 |

**Verificación:**

- VIRTUAL: débitos 10,37 = créditos 10,37; diferencia **0,00**.

**Nota:** La diferencia de 0,12 VIRTUAL se acredita a la cuenta neutral de ajustes para compensar futuros redondeos hacia arriba.

## FF-PRZ-005 — Distribución 50/25/15/10 sin ganador y con meta mínima
**Reglas:** `LOT-PRZ-009`, `LOT-FIN-012`, `LOT-FIN-013`  
**Estado/transición:** `NoWinnerDistributionCompleted`  
**Disparador de ejemplo:** Premio mayor no entregado de 100,00 VIRTUAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `DRAW_UNAWARDED_MAJOR_PRIZE` | 100,00 |
| VIRTUAL | CREDIT | `ACCUMULATION_POOL_PRODUCT` | 50,00 |
| VIRTUAL | CREDIT | `GUARANTEE_FUND_AVAILABLE` | 25,00 |
| VIRTUAL | CREDIT | `FUTURE_PRIZE_FUND` | 15,00 |
| VIRTUAL | CREDIT | `PLATFORM_OPERATIONS_VIRTUAL` | 10,00 |

**Verificación:**

- VIRTUAL: débitos 100,00 = créditos 100,00; diferencia **0,00**.

**Nota:** La suma de destinos es exactamente 100,00 VIRTUAL en el ejemplo.

## FF-PRZ-006 — Reposición de garantía en evento sin meta mínima
**Reglas:** `LOT-PRZ-010`, `LOT-FIN-012`  
**Estado/transición:** `Liquidación de baja venta`  
**Disparador de ejemplo:** El evento repone 50,00 VIRTUAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `DRAW_SALES_FUND` | 50,00 |
| VIRTUAL | CREDIT | `GUARANTEE_FUND_AVAILABLE` | 50,00 |

**Verificación:**

- VIRTUAL: débitos 50,00 = créditos 50,00; diferencia **0,00**.

**Nota:** Se realiza después de pagar devoluciones y antes de cualquier uso no prioritario.

## FF-PRZ-007 — Retorno de acumulado heredado si no se consolida
**Reglas:** `LOT-PRZ-010`, `LOT-PRZ-011`, `LOT-FIN-012`  
**Estado/transición:** `Transferencia de acumulado → DEVUELTA_AL_POOL`  
**Disparador de ejemplo:** Se devuelven 50,00 VIRTUAL al pool.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `DRAW_ACCUMULATION_EXTRA` | 50,00 |
| VIRTUAL | CREDIT | `ACCUMULATION_POOL_PRODUCT` | 50,00 |

**Verificación:**

- VIRTUAL: débitos 50,00 = créditos 50,00; diferencia **0,00**.

**Nota:** No se duplica ni se convierte en venta.

## FF-PRZ-008 — Asignación de acumulado al evento receptor
**Reglas:** `LOT-PRZ-011`, `LOT-FIN-012`  
**Estado/transición:** `Transferencia de acumulado: ASIGNADA → APLICADA`  
**Disparador de ejemplo:** El pool asigna 50,00 VIRTUAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `ACCUMULATION_POOL_PRODUCT` | 50,00 |
| VIRTUAL | CREDIT | `DRAW_ACCUMULATION_EXTRA` | 50,00 |

**Verificación:**

- VIRTUAL: débitos 50,00 = créditos 50,00; diferencia **0,00**.

**Nota:** Solo cambia el premio; no modifica precio ni reglas del evento.

## FF-PRZ-009 — Uso autorizado del fondo de premios futuros
**Reglas:** `LOT-PRZ-010`, `LOT-FIN-012`  
**Estado/transición:** `Aporte a evento autorizado`  
**Disparador de ejemplo:** Se asignan 20,00 VIRTUAL a un evento.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `FUTURE_PRIZE_FUND` | 20,00 |
| VIRTUAL | CREDIT | `DRAW_PRIZE_RESERVE` | 20,00 |

**Verificación:**

- VIRTUAL: débitos 20,00 = créditos 20,00; diferencia **0,00**.

**Nota:** Requiere permiso, motivo, evento beneficiado y auditoría.

## FF-FND-004 — Aporte administrativo al fondo de garantía
**Reglas:** `LOT-PRZ-007`, `LOT-PRZ-008`, `LOT-FIN-012`  
**Estado/transición:** `Contribución administrativa`  
**Disparador de ejemplo:** Un Administrador autorizado aporta 10,00 desde su wallet VIRTUAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `USER_VIRTUAL_AVAILABLE` | 10,00 |
| VIRTUAL | CREDIT | `GUARANTEE_FUND_AVAILABLE` | 10,00 |

**Verificación:**

- VIRTUAL: débitos 10,00 = créditos 10,00; diferencia **0,00**.

**Nota:** La cuenta debitada pertenece al aportante autorizado. Un aporte desde fondos de plataforma utiliza un flujo separado con permiso y motivo; nunca se ajusta el saldo directamente.

## FF-ORG-001 — Pago de participación en sorteo de usuario
**Reglas:** `LOT-FIN-004`, `LOT-FIN-013`, `LOT-ORG-006`, `LOT-ORG-025`  
**Estado/transición:** `ORG-PAR: PENDIENTE → PAGADO; ORG-ESC → RETENIDA`  
**Disparador de ejemplo:** Participación de 100,00 VIRTUAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `USER_VIRTUAL_AVAILABLE` | 100,00 |
| VIRTUAL | CREDIT | `USER_DRAW_COMMISSION_HELD` | 5,00 |
| VIRTUAL | CREDIT | `USER_DRAW_ESCROW` | 95,00 |

**Verificación:**

- VIRTUAL: débitos 100,00 = créditos 100,00; diferencia **0,00**.

**Nota:** El 95 % no es saldo disponible del Organizador. El ejemplo evita residuos de cálculo.

## FF-ORG-002 — Financiación de código privado pagado
**Reglas:** `LOT-FIN-013`, `LOT-ORG-010`, `LOT-ORG-015`, `LOT-ORG-025`  
**Estado/transición:** `ORG-COD pago: PENDIENTE → PAGADO`  
**Disparador de ejemplo:** El financiador paga un código de 100,00 VIRTUAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `USER_VIRTUAL_AVAILABLE` | 100,00 |
| VIRTUAL | CREDIT | `USER_DRAW_COMMISSION_HELD` | 5,00 |
| VIRTUAL | CREDIT | `USER_DRAW_ESCROW` | 95,00 |

**Verificación:**

- VIRTUAL: débitos 100,00 = créditos 100,00; diferencia **0,00**.

**Nota:** Hasta el reclamo, el beneficiario puede no estar identificado; el financiador sí queda trazado. El importe es el precio total del código aunque reserve varios números. Al reclamarse, una única participación económica hereda este ledger y crea una asignación por número sin un segundo cobro.

## FF-ORG-003 — Reembolso total por cancelación del Organizador
**Reglas:** `LOT-ORG-008`, `LOT-ORG-025`  
**Estado/transición:** `ORG-DRW → CANCELADO; ORG-ESC → REEMBOLSADA`  
**Disparador de ejemplo:** Se devuelve una participación de 100,00 VIRTUAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `USER_DRAW_ESCROW` | 95,00 |
| VIRTUAL | DEBIT | `USER_DRAW_COMMISSION_HELD` | 5,00 |
| VIRTUAL | CREDIT | `USER_VIRTUAL_AVAILABLE` | 100,00 |

**Verificación:**

- VIRTUAL: débitos 100,00 = créditos 100,00; diferencia **0,00**.

**Nota:** La comisión se revierte proporcionalmente; la cuenta `USER_VIRTUAL_AVAILABLE` acreditada pertenece al participante y recupera el 100 %.

## FF-ORG-004 — Reembolso total por expulsión antes del cierre
**Reglas:** `LOT-ORG-018`, `LOT-ORG-025`  
**Estado/transición:** `ORG-PAR: PAGADO → REEMBOLSADO; relación → EXPULSADO`  
**Disparador de ejemplo:** Se expulsa y reembolsa una participación de 100,00 VIRTUAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `USER_DRAW_ESCROW` | 95,00 |
| VIRTUAL | DEBIT | `USER_DRAW_COMMISSION_HELD` | 5,00 |
| VIRTUAL | CREDIT | `USER_VIRTUAL_AVAILABLE` | 100,00 |

**Verificación:**

- VIRTUAL: débitos 100,00 = créditos 100,00; diferencia **0,00**.

**Nota:** Después del cierre no se permite esta acción directa.

## FF-ORG-005 — Reembolso de código pagado no reclamado al cierre
**Reglas:** `LOT-ORG-015`, `LOT-ORG-025`  
**Estado/transición:** `ORG-COD: EMITIDO → EXPIRADO; pago → REEMBOLSADO`  
**Disparador de ejemplo:** Código financiado por 100,00 VIRTUAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `USER_DRAW_ESCROW` | 95,00 |
| VIRTUAL | DEBIT | `USER_DRAW_COMMISSION_HELD` | 5,00 |
| VIRTUAL | CREDIT | `USER_VIRTUAL_AVAILABLE` | 100,00 |

**Verificación:**

- VIRTUAL: débitos 100,00 = créditos 100,00; diferencia **0,00**.

**Nota:** El reembolso vuelve a la cuenta `USER_VIRTUAL_AVAILABLE` de quien financió el código.

## FF-ORG-006 — Devengo de comisión tras operación exitosa
**Reglas:** `LOT-ORG-006`, `LOT-ORG-025`  
**Estado/transición:** `ORG-DRW → FINALIZADO`  
**Disparador de ejemplo:** Se devengan 5,00 VIRTUAL retenidos.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `USER_DRAW_COMMISSION_HELD` | 5,00 |
| VIRTUAL | CREDIT | `PLATFORM_OPERATIONS_VIRTUAL` | 5,00 |

**Verificación:**

- VIRTUAL: débitos 5,00 = créditos 5,00; diferencia **0,00**.

**Nota:** No debe devengarse de forma irreversible mientras todavía pueda corresponder reembolso.

## FF-ORG-007 — Liberación del 95 % al Organizador
**Reglas:** `LOT-ORG-023`, `LOT-ORG-025`  
**Estado/transición:** `ORG-ESC: LIBERANDO → LIBERADA`  
**Disparador de ejemplo:** Se liberan 95,00 VIRTUAL tras resultado y entrega.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `USER_DRAW_ESCROW` | 95,00 |
| VIRTUAL | CREDIT | `USER_VIRTUAL_AVAILABLE` | 95,00 |

**Verificación:**

- VIRTUAL: débitos 95,00 = créditos 95,00; diferencia **0,00**.

**Nota:** Solo ocurre una vez y después de deducir reembolsos o compensaciones aprobadas. La cuenta acreditada es la wallet VIRTUAL global del Organizador.

## FF-ORG-008 — Compensación posterior a liquidación o por error de plataforma
**Reglas:** `LOT-ORG-008`, `LOT-ORG-020`, `LOT-ORG-021`, `LOT-ORG-023`, `LOT-ORG-025`  
**Estado/transición:** `ORG-CLM: resolución con compensación; ORG-ESC permanece LIBERADA cuando ya fue liquidada`  
**Disparador de ejemplo:** Debe compensarse 100,00 VIRTUAL después de que el escrow ya fue liquidado, o la plataforma debe absorber íntegramente un error.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `PLATFORM_OPERATIONS_VIRTUAL` | 100,00 |
| VIRTUAL | CREDIT | `USER_VIRTUAL_AVAILABLE` | 100,00 |

**Verificación:**

- VIRTUAL: débitos 100,00 = créditos 100,00; diferencia **0,00**.

**Nota:** `LIBERADA` no se reabre y `USER_DRAW_ESCROW` no puede quedar negativo. La compensación inmediata al afectado se registra contra plataforma; cualquier recuperación frente al Organizador exige una operación administrativa separada, autorizada y balanceada. Si el escrow y la comisión todavía están retenidos, se usan FF-ORG-003/004/005.

## FF-REV-001 — Reverso compensatorio genérico
**Reglas:** `LOT-GOV-004`, `LOT-FIN-005`, `LOT-FIN-012`  
**Estado/transición:** `FIN-LED: CONTABILIZADA → REVERSADA`  
**Disparador de ejemplo:** Se revierte una transferencia original de 25,00 VIRTUAL.
| Unidad | Lado | Cuenta | Importe |
|---|---|---|---:|
| VIRTUAL | DEBIT | `ORIGINAL_CREDIT_ACCOUNT` | 25,00 |
| VIRTUAL | CREDIT | `ORIGINAL_DEBIT_ACCOUNT` | 25,00 |

**Verificación:**

- VIRTUAL: débitos 25,00 = créditos 25,00; diferencia **0,00**.

**Nota:** No se edita la transacción original. La compensación usa un nuevo ledger_transaction_id y reversal_of_transaction_id.

# 4. Operaciones que no generan asientos por sí solas

| Operación | Resultado financiero |
|---|---|
| Login, cambio de modo y autorización | Ningún asiento. |
| Vendedor toma o libera una asignación, mientras la solicitud sigue PENDIENTE | Ningún asiento adicional; el REAL continúa reservado. |
| Reserva de combinación oficial | Reserva la combinación, no el dinero; ningún asiento hasta confirmar compra. |
| Expiración/liberación de combinación | Ningún asiento si no existió cobro. |
| Generación de commitment, snapshot, resultado o hash | Ningún asiento. |
| Animación del resultado | Ningún asiento. |
| Reparación de `wallet_balance_projection` | Ningún asiento nuevo; se recalcula desde el ledger. |
| Reintento idempotente cuyo efecto ya existe | Ningún asiento nuevo. |
| Cambio de número en sorteo de usuario con el mismo precio | Ningún asiento; solo cambia asignación e historial. |
| Reclamo de código privado ya pagado | Ningún asiento nuevo; la participación referencia el pago original y evita doble débito. |
| Abandono voluntario de participación pagada | Ningún reembolso ni asiento; el número permanece elegible. |
| Presentación o revisión de reclamo | Ningún asiento hasta una resolución con compensación. |
| Registro de evidencia de entrega | Ningún asiento hasta liberación del escrow. |
| Ampliación del rango o anuncios | Ningún asiento. |

Crear asientos para estas operaciones produciría saldos falsos o duplicados.

# 5. Secuencias financieras completas

## 5.1 Ciclo Cliente→Vendedor

```text
1. FF-REAL-001          Recarga REAL simulada.
2. FF-VND-REQ-001       REAL disponible → REAL reservado.
3. Asignación           Sin ledger.
4a. FF-VND-REQ-003      Completa Vendedor.
4b. FF-VND-REQ-004      Completa plataforma.
4c. FF-VND-REQ-002      Falla final y libera REAL.
```

Solo uno de 4a, 4b o 4c puede ocurrir.

## 5.2 Ciclo del Vendedor

```text
1. FF-VND-PO-001        Compra inventario 0,90→1,00.
2. FF-VND-REQ-003       Vende VIRTUAL y recibe REAL 1:1.
3. Métrica derivada     Ganancia realizada = REAL recibido − coste de lote consumido.
```

La ganancia potencial o realizada no se crea mediante un asiento adicional: se deriva de lotes y ventas. Crear un “crédito de ganancia” duplicaría el valor.

## 5.3 Compra y premio oficial

```text
1. FF-FND-001/003       Cobertura del evento.
2. FF-EVT-001           Compra del boleto.
3. FF-EVT-002           Recuperación de garantía.
4. FF-EVT-003/004       Crecimiento 90 % y operación 10 %.
5. FF-PRZ-001/003/004   Preparación del payable.
6. FF-PRZ-002           Acreditación automática.
```

## 5.4 Cancelación oficial

```text
1. Bloquear evento y órdenes.
2. Invalidar jobs/snapshot de forma auditada.
3. Calcular precio pagado por boleto.
4. Ejecutar FF-EVT-005 una sola vez por boleto.
5. Devolver acumulado mediante FF-PRZ-007 si corresponde.
6. Liberar cobertura no consumida mediante FF-FND-002.
```

## 5.5 Evento sin ganador

Con meta mínima:

```text
1. Pagar devoluciones mediante FF-PRZ-001/002.
2. Distribuir premio mayor mediante FF-PRZ-005.
3. Asignar acumulado mediante FF-PRZ-008 cuando exista receptor.
```

Sin meta mínima:

```text
1. Pagar devoluciones.
2. Reponer garantía mediante FF-PRZ-006.
3. Cubrir obligaciones.
4. Devolver acumulado heredado mediante FF-PRZ-007.
5. Enviar remanente al fondo de garantía.
6. Solo si el fondo está completo, usar el fondo de premios futuros.
```

No se ejecuta FF-PRZ-005.

## 5.6 Sorteo creado por usuario exitoso

```text
1. FF-ORG-001/002       Pago: 5 % retenido + 95 % escrow.
2. Resultado y entrega  Sin ledger.
3. FF-ORG-007           Liberación del 95 % al Organizador.
4. FF-ORG-006           Devengo de la comisión.
```

## 5.7 Cancelación, expulsión o código no reclamado

Mientras la comisión siga retenida:

```text
FF-ORG-003, FF-ORG-004 o FF-ORG-005
```

Si la comisión ya fue devengada o el error pertenece a la plataforma:

```text
FF-ORG-008
```

El participante o financiador recibe siempre el 100 % cuando la regla exige reembolso completo.

# 6. Reversos y correcciones

## 6.1 Prohibición de edición

No se permite:

```sql
UPDATE ledger_entries SET amount_minor = ...;
DELETE FROM ledger_entries WHERE ...;
```

sobre asientos contabilizados.

## 6.2 Reverso compensatorio

La corrección crea:

- nueva `ledger_transaction`;
- mismos importes;
- lados y cuentas invertidos;
- `reversal_of_transaction_id`;
- motivo;
- actor;
- `correlation_id`;
- auditoría.

FF-REV-001 muestra el patrón.

## 6.3 Reverso parcial

Un reverso parcial es permitido solo si la regla admite compensación parcial. Debe:

- referenciar la operación original mediante `reversal_of_transaction_id` y cada línea mediante `reversal_of_entry_id`;
- impedir que el total acumulado de reversos por asiento supere el monto original;
- mantener la operación original como `PARCIALMENTE_REVERSADA` hasta compensarla por completo;
- mantener balance por unidad;
- conservar el resto de la operación original.

# 7. Idempotencia y unicidad

| Operación | Clave lógica mínima |
|---|---|
| Recarga | proveedor/simulador + evento externo. |
| Compra mayorista | Vendedor + client_request_id. |
| Solicitud por Vendedor | conversion_request_id + vendor_id. |
| Fallback | conversion_request_id + `PLATFORM`. |
| Conversión VIRTUAL→REAL | user_id + request_uuid. |
| Transferencia | sender_id + request_uuid. |
| Compra de boleto | user_id + purchase_order_uuid. |
| Reembolso oficial | event_id + ticket_id + `REFUND`. |
| Premio | event_id + ticket_id + award_category. |
| Participación de usuario | user_draw_id + payer + purchase_uuid. |
| Reembolso de participación | participation_id + reason_category. |
| Liberación de escrow | user_draw_id + `ESCROW_RELEASE`. |
| Devengo de comisión | user_draw_id + `COMMISSION_EARNED`. |

Una misma clave con un cuerpo diferente se rechaza.

# 8. Controles SQL obligatorios

## 8.1 Restricciones de asiento

```text
amount_minor > 0
currency = ledger_account.currency
side IN (DEBIT, CREDIT)
sequence UNIQUE por transacción
```

## 8.2 Balance diferido

Al finalizar la transacción SQL:

```text
GROUP BY ledger_transaction_id, currency
HAVING SUM(DEBIT) <> SUM(CREDIT)
```

debe producir cero filas.

La validación debe ser diferida o ejecutarse mediante procedimiento de contabilización para permitir insertar varios asientos antes del chequeo final.

## 8.3 Inmutabilidad

- `ledger_entries` append-only.
- `ledger_transactions.status` no regresa a borrador.
- Reversos mediante FK a original.
- Trigger o permisos de base de datos bloquean actualización/destrucción no autorizada.

## 8.4 No negatividad

Antes de contabilizar una salida de cuenta disponible:

1. bloquear la cuenta/proyección;
2. recalcular disponible autoritativo;
3. validar saldo;
4. insertar asientos;
5. actualizar proyección en la misma transacción o mediante proceso idempotente.

Redis no sustituye el lock ni la restricción de PostgreSQL.

# 9. Reconciliación

## 9.1 Proyección

```text
projected_balance(account)
=
Σ créditos contabilizados
− Σ débitos contabilizados
```

según el convenio operativo de este documento.

## 9.2 Proceso

`ledger-reconcile` debe:

- leer asientos contabilizados;
- recalcular cada componente;
- comparar con `wallet_balance_projections`;
- corregir solo la proyección;
- registrar discrepancia, causa y reparación;
- no crear otra transacción económica.

## 9.3 Invariantes globales

- REAL emitido/acreditado = REAL absorbido, reservado, disponible, retirado o en clearing conforme a cuentas técnicas.
- VIRTUAL emitido = VIRTUAL en wallets, fondos, escrow, comisiones, redención y cuentas técnicas.
- Ninguna operación mezcla el balance de REAL con VIRTUAL.
- Ningún efecto terminal se contabiliza dos veces.
- Todos los fondos y escrows se reconstruyen desde asientos.

# 10. Pruebas obligatorias

## 10.1 Propiedad contable

Generar operaciones aleatorias válidas y comprobar:

```text
para toda transacción y moneda:
débitos = créditos
```

## 10.2 Concurrencia

- Dos débitos que superan saldo: máximo uno confirma.
- Vendedor y plataforma compiten: una finalización y un par de ledgers.
- Dos compras de la misma combinación: un cobro.
- Dos premios: una acreditación.
- Dos reembolsos: uno.
- Dos liberaciones de escrow: una.

## 10.3 Fallos intermedios

Inyectar error después de cada paso de:

- compra mayorista;
- solicitud por Vendedor;
- fallback;
- compra de boleto;
- premio;
- reembolso;
- liberación de escrow.

Resultado esperado: todo revierte o el reintento detecta el efecto existente.

## 10.4 Rounding y porcentajes

Probar:

- límites del redondeo público a cuartos;
- 10 %, 5 %, 90 %, 50/25/15/10;
- cantidades exactas;
- cantidades con residuo;
- rechazo o resolución versionada del residuo;
- suma final igual al monto base.

# 11. Resultado de la verificación automática

La siguiente tabla fue generada a partir de los ejemplos de este documento.
| Flujo | Unidad | Débitos | Créditos | Diferencia | Resultado |
|---|---|---:|---:|---:|---|
| `FF-SYS-001` | REAL | 1.000,00 | 1.000,00 | 0,00 | BALANCEADO |
| `FF-SYS-001` | VIRTUAL | 1.000,00 | 1.000,00 | 0,00 | BALANCEADO |
| `FF-REAL-001` | REAL | 100,00 | 100,00 | 0,00 | BALANCEADO |
| `FF-VND-REQ-001` | REAL | 100,00 | 100,00 | 0,00 | BALANCEADO |
| `FF-VND-REQ-002` | REAL | 100,00 | 100,00 | 0,00 | BALANCEADO |
| `FF-VND-PO-001` | REAL | 90,00 | 90,00 | 0,00 | BALANCEADO |
| `FF-VND-PO-001` | VIRTUAL | 100,00 | 100,00 | 0,00 | BALANCEADO |
| `FF-VND-REQ-003` | REAL | 100,00 | 100,00 | 0,00 | BALANCEADO |
| `FF-VND-REQ-003` | VIRTUAL | 100,00 | 100,00 | 0,00 | BALANCEADO |
| `FF-VND-REQ-004` | REAL | 100,00 | 100,00 | 0,00 | BALANCEADO |
| `FF-VND-REQ-004` | VIRTUAL | 100,00 | 100,00 | 0,00 | BALANCEADO |
| `FF-CON-001` | VIRTUAL | 500,00 | 500,00 | 0,00 | BALANCEADO |
| `FF-CON-001` | REAL | 450,00 | 450,00 | 0,00 | BALANCEADO |
| `FF-WDR-001` | REAL | 450,00 | 450,00 | 0,00 | BALANCEADO |
| `FF-WDR-002` | REAL | 450,00 | 450,00 | 0,00 | BALANCEADO |
| `FF-WDR-003` | REAL | 450,00 | 450,00 | 0,00 | BALANCEADO |
| `FF-TRF-001` | VIRTUAL | 25,00 | 25,00 | 0,00 | BALANCEADO |
| `FF-FND-001` | VIRTUAL | 200,00 | 200,00 | 0,00 | BALANCEADO |
| `FF-FND-002` | VIRTUAL | 200,00 | 200,00 | 0,00 | BALANCEADO |
| `FF-FND-003` | VIRTUAL | 50,00 | 50,00 | 0,00 | BALANCEADO |
| `FF-EVT-001` | VIRTUAL | 1,00 | 1,00 | 0,00 | BALANCEADO |
| `FF-EVT-002` | VIRTUAL | 50,00 | 50,00 | 0,00 | BALANCEADO |
| `FF-EVT-003` | VIRTUAL | 90,00 | 90,00 | 0,00 | BALANCEADO |
| `FF-EVT-004` | VIRTUAL | 10,00 | 10,00 | 0,00 | BALANCEADO |
| `FF-EVT-005` | VIRTUAL | 1,00 | 1,00 | 0,00 | BALANCEADO |
| `FF-PRZ-010` | VIRTUAL | 1,00 | 1,00 | 0,00 | BALANCEADO |
| `FF-PRZ-001` | VIRTUAL | 100,00 | 100,00 | 0,00 | BALANCEADO |
| `FF-PRZ-002` | VIRTUAL | 100,00 | 100,00 | 0,00 | BALANCEADO |
| `FF-PRZ-003` | VIRTUAL | 10,25 | 10,25 | 0,00 | BALANCEADO |
| `FF-PRZ-004` | VIRTUAL | 10,37 | 10,37 | 0,00 | BALANCEADO |
| `FF-PRZ-005` | VIRTUAL | 100,00 | 100,00 | 0,00 | BALANCEADO |
| `FF-PRZ-006` | VIRTUAL | 50,00 | 50,00 | 0,00 | BALANCEADO |
| `FF-PRZ-007` | VIRTUAL | 50,00 | 50,00 | 0,00 | BALANCEADO |
| `FF-PRZ-008` | VIRTUAL | 50,00 | 50,00 | 0,00 | BALANCEADO |
| `FF-PRZ-009` | VIRTUAL | 20,00 | 20,00 | 0,00 | BALANCEADO |
| `FF-FND-004` | VIRTUAL | 10,00 | 10,00 | 0,00 | BALANCEADO |
| `FF-ORG-001` | VIRTUAL | 100,00 | 100,00 | 0,00 | BALANCEADO |
| `FF-ORG-002` | VIRTUAL | 100,00 | 100,00 | 0,00 | BALANCEADO |
| `FF-ORG-003` | VIRTUAL | 100,00 | 100,00 | 0,00 | BALANCEADO |
| `FF-ORG-004` | VIRTUAL | 100,00 | 100,00 | 0,00 | BALANCEADO |
| `FF-ORG-005` | VIRTUAL | 100,00 | 100,00 | 0,00 | BALANCEADO |
| `FF-ORG-006` | VIRTUAL | 5,00 | 5,00 | 0,00 | BALANCEADO |
| `FF-ORG-007` | VIRTUAL | 95,00 | 95,00 | 0,00 | BALANCEADO |
| `FF-ORG-008` | VIRTUAL | 100,00 | 100,00 | 0,00 | BALANCEADO |
| `FF-REV-001` | VIRTUAL | 25,00 | 25,00 | 0,00 | BALANCEADO |

## 11.1 Resumen

- Plantillas financieras verificadas: **40**.
- Grupos monetarios verificados: **45**.
- Grupos REAL desbalanceados: **0**.
- Grupos VIRTUAL desbalanceados: **0**.
- Diferencia acumulada: **0,00** en cada unidad.

La verificación numérica confirma los ejemplos; las pruebas de integración deberán confirmar además locks, idempotencia, estados, FKs y restricciones.

# 12. Política monetaria final para importes arbitrarios

La política de residuos quedó aprobada en `LOT-FIN-013` y se aplica a toda división porcentual en minor units:

1. Calcular cada cuota racional sobre el monto base.
2. Asignar primero la parte entera inferior de cada cuota.
3. Distribuir las minor units restantes mediante el método de mayores residuos.
4. Resolver empates con la prioridad determinista definida para cada operación.
5. Guardar monto base, tasas, partes enteras, residuos, prioridad, resultado y código de política.
6. Verificar que la suma de componentes sea exactamente igual al monto base.

Prioridades congeladas:

- VIRTUAL→REAL: neto del usuario antes que comisión.
- Sorteos de usuario 95/5: escrow antes que comisión retenida.
- Crecimiento 90/10: premio antes que operación.
- Distribución 50/25/15/10: acumulado, garantía, premios futuros y operación.

La compra mayorista no usa reparto aproximado: solo admite incrementos de `1,00 VIRTUAL`, por lo que cada bloque cuesta exactamente `0,90 REAL`. No queda un bloqueo económico para importes arbitrarios en los repartos aprobados.

# 13. Criterios de aprobación documental

- [x] Se aprueba el convenio DEBIT=fuente y CREDIT=destino del subledger.
- [x] Se aprueba el catálogo lógico de cuentas.
- [x] Cada operación confirmada tiene `ledger_transaction_id`.
- [x] REAL y VIRTUAL balancean por separado.
- [x] Se aprueban las cuentas técnicas autorizadas.
- [x] Se aprueba el momento de devengo de la comisión del 5 %.
- [x] Se aprueba que el abandono pagado no genere asiento.
- [x] Se aprueba el patrón de reembolso íntegro del 100 %.
- [x] Se aprueba el patrón de reverso compensatorio.
- [x] Se aprueba la política de mayores residuos de `LOT-FIN-013`.
- [x] Las 40 plantillas de ejemplo permanecen balanceadas.
- [x] `DICCIONARIO-DE-DATOS.md` referencia estas cuentas y flujos.

## 13.1 Gate de implementación

- [ ] Prisma/SQL y la migración complementaria impiden contabilizar una transacción desbalanceada.

# 14. Decisión de salida

Con este documento aprobado queda permitido:

- definir tablas `ledger_accounts`, `ledger_transactions`, `ledger_entries`;
- diseñar cuentas por usuario, evento, fondo y sorteo;
- implementar proyecciones;
- crear restricciones de balance;
- preparar seeds de cuentas técnicas;
- crear pruebas de propiedad y concurrencia.

No queda permitido:

- usar `float` o `double`;
- mezclar unidades;
- modificar asientos contabilizados;
- ajustar saldos sin ledger;
- crear comisión o residuo sin regla versionada;
- duplicar una operación durante un reintento.

> **Decisión obligatoria:** toda operación financiera del SQL debe corresponder a un flujo aprobado de este documento o a una nueva versión formal.


# 15. Declaración de congelamiento

Los tipos de transacción, cuentas lógicas, políticas de reparto, prioridades de residuos y patrones de reverso de esta versión son la baseline financiera final de la versión 1.

Una operación financiera nueva requiere primero una regla `LOT-*` y una nueva versión de este documento. No puede agregarse únicamente como código, seed, trigger o movimiento manual.
