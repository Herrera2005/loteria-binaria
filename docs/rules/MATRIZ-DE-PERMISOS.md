---
title: "Matriz de Permisos por Rol, Modo y Recurso — Lotería Binaria"
version: "1.1.0"
status: "APROBADO Y CONGELADO — baseline de autorización para implementación v1"
author: "Cristhian Herrera Nieto"
date: "2026-07-26"
repository: "Herrera2005/loteria-binaria"
normative_rules: "REGLAS-NEGOCIO.md v1.4.0"
state_model: "ESTADOS-Y-TRANSICIONES.md v1.1.0"
financial_model: "FLUJOS-FINANCIEROS.md v1.1.0"
---

# MATRIZ DE PERMISOS POR ROL, MODO Y RECURSO — LOTERÍA BINARIA

**Versión:** 1.1.0  
**Estado:** **APROBADO Y CONGELADO** para implementación v1.  
**Ruta objetivo:** `docs/MATRIZ-DE-PERMISOS.md`  
**Reglas base:** `docs/REGLAS-NEGOCIO.md` v1.4.0  
**Estados base:** `docs/ESTADOS-Y-TRANSICIONES.md` v1.1.0  
**Flujos base:** `docs/FLUJOS-FINANCIEROS.md` v1.1.0

## 0. Propósito

Este documento define quién puede solicitar cada operación y bajo qué combinación de:

```text
rol global + modo activo + permiso + relación con el recurso
+ estado del recurso + estado de cuenta + reglas contextuales
```

La matriz no concede permisos a la interfaz. Web y mobile pueden ocultar acciones para mejorar la experiencia, pero la API debe evaluar nuevamente todas las condiciones.

Referencias: `LOT-GOV-001`, `LOT-IAM-002`, `LOT-IAM-005`, `LOT-IAM-006`.

## 0.0 Autoridad documental

1. Documento Maestro v1.0 y adendas aprobadas, incluido `ADR-ORG-001`.
2. `REGLAS-NEGOCIO.md` v1.4.0.
3. Contratos especializados aprobados: `ESTADOS-Y-TRANSICIONES.md`, `FLUJOS-FINANCIEROS.md`, esta matriz y `DICCIONARIO-DE-DATOS.md`, cada uno dentro de su materia.
4. `PLAN-TECNICO.md` v1.1.0.
5. OpenAPI, `schema.prisma` y migraciones.
6. Código y pruebas.
7. README como guía operativa.

## 0.1 Principio de autorización

Una operación se permite únicamente cuando todas las condiciones son verdaderas:

```text
ALLOW =
  sesión/autenticación válida
  AND cuenta habilitada para la operación
  AND modo compatible con los roles
  AND permiso efectivo
  AND relación válida con el recurso
  AND transición/estado permitido
  AND reglas de tiempo, saldo, antifraude e idempotencia
  AND ausencia de una prohibición explícita
```

Una sola condición falsa produce denegación sin efectos financieros ni cambios parciales.

## 0.2 Precedencia de denegación

Las prohibiciones explícitas prevalecen sobre los permisos generales:

1. Estado de cuenta no habilitado.
2. Modo incompatible.
3. Prohibición por rol.
4. Permiso no asignado.
5. Recurso ajeno o relación insuficiente.
6. Estado/transición no permitidos.
7. Hora, saldo, cobertura o disponibilidad inválidos.
8. Riesgo, cuenta relacionada o rate limit.
9. Conflicto de idempotencia o concurrencia.

Ejemplo: una cuenta que posee `CLIENTE` y `VENDEDOR` no puede usar el rol Cliente para comprar boletos oficiales. La prohibición del Vendedor sobre participación oficial prevalece.  
Referencias: `LOT-IAM-002`, `LOT-IAM-004`.

## 0.3 Roles globales

| Rol | Naturaleza | Alcance |
|---|---|---|
| `CLIENTE` | Global | Participación en lotería oficial, wallets y autoservicio. |
| `VENDEDOR` | Global | Inventario mayorista, solicitudes Cliente→Vendedor y wallet. |
| `ADMINISTRADOR` | Global | Administración según permisos granulares; no es acceso universal implícito. |

`ORGANIZADOR` no es rol global. Es una relación contextual `organizer_user_id` sobre cada sorteo creado por usuario.  
Referencia: `LOT-IAM-001`.

## 0.4 Modos activos

| Modo | Quién puede activarlo | Operaciones principales | Prohibiciones |
|---|---|---|---|
| `CLIENTE` | Cuenta con rol Cliente y elegible para participación oficial | Wallet, lotería oficial, sorteos de usuario | No administración ni operaciones de Vendedor. |
| `CLIENTE_FINANCIERO` | Vendedor o Administrador | Consulta de wallet, recargas, conversiones, retiros y sorteos de usuario | No compra de boletos oficiales ni transferencias voluntarias entre clientes. |
| `VENDEDOR` | Vendedor; Administrador solo con perfil de Vendedor activo | Inventario, solicitudes y finanzas del Vendedor | No lotería oficial; el autoservicio de sorteos de usuario requiere cambiar a `CLIENTE_FINANCIERO`. |
| `ADMINISTRADOR` | Administrador | Operaciones administrativas con permiso granular | No operaciones personales por privilegio; debe cambiar a modo financiero cuando corresponda. |
| `SYSTEM` | Identidad técnica de worker | Jobs persistentes autorizados | Es un **contexto técnico**, no un valor permitido en `sessions.active_mode`; no usa sesión humana ni permisos generales. |

La compatibilidad de modos se deriva de `LOT-IAM-001` a `LOT-IAM-006` y de la selección de modo definida en el Documento Maestro.

## 0.5 Regla especial de participación oficial

Para comprar boletos oficiales deben cumplirse simultáneamente:

- rol `CLIENTE`;
- modo `CLIENTE`;
- cuenta `ACTIVO`;
- la cuenta no posee rol `VENDEDOR` ni `ADMINISTRADOR`;
- evento y compra cumplen todas las reglas.

Esto evita que una asignación adicional del rol Cliente permita a un Vendedor o Administrador participar en la lotería oficial.  
Referencia: `LOT-IAM-004`.

## 0.6 Autoservicio de sorteos creados por usuarios

Cualquier cuenta global `CLIENTE`, `VENDEDOR` o `ADMINISTRADOR`, si está `ACTIVO`, puede crear o participar en sorteos de usuarios:

- Cliente: modo `CLIENTE`.
- Vendedor o Administrador: modo `CLIENTE_FINANCIERO`.

El modo `ADMINISTRADOR` se reserva para moderación. Un Administrador que además sea Organizador debe cambiar a su modo financiero para administrar su propio sorteo; no debe mezclar el privilegio administrativo con la propiedad contextual.

Referencias: `LOT-ORG-001`, `LOT-FIN-004`, `LOT-IAM-002`.

## 0.7 Relaciones con recursos

| Relación | Significado |
|---|---|
| `PUBLIC` | El recurso está autorizado para consulta pública. |
| `SELF` | El recurso pertenece directamente al usuario autenticado. |
| `OWNER_OF_TICKET` | El usuario es propietario del boleto. |
| `SELF_VENDOR_PROFILE` | El perfil de Vendedor pertenece al sujeto. |
| `ELIGIBLE_VENDOR` | Vendedor activo, solvente y no relacionado con el Cliente. |
| `ASSIGNED_VENDOR` | Existe asignación activa a ese Vendedor. |
| `ORGANIZER_OF` | `user_draw.organizer_user_id = subject.user_id`. |
| `PARTICIPANT_OF` | Existe participación vinculada al sujeto. |
| `OWNER_OF_PARTICIPATION` | La participación concreta pertenece al sujeto. |
| `WINNER_OF` | El resultado identifica una participación elegible del sujeto. |
| `CLAIMANT` | El sujeto creó el reclamo. |
| `ADMIN_SCOPE` | El sujeto posee el permiso administrativo requerido. |
| `SYSTEM_JOB` | La identidad técnica ejecuta el trabajo lógico autorizado. |

## 0.8 Permisos efectivos

Los permisos administrativos no se deducen solo del nombre `ADMINISTRADOR`. Deben resolverse desde PostgreSQL y quedar disponibles para la guardia de autorización.

El modelo mínimo del Plan Técnico incluye `roles`, `permissions`, `user_roles` y `role_permissions`. Las concesiones granulares se representan mediante `user_permission_grants`, según `DICCIONARIO-DE-DATOS.md`. Esta matriz no autoriza privilegios ocultos ni convierte `ADMINISTRADOR` en superusuario.

## 0.9 Algoritmo de autorización

```text
1. Autenticar sesión o identidad técnica.
2. Cargar cuenta, roles, permisos y modo desde PostgreSQL.
3. Validar compatibilidad rol↔modo.
4. Aplicar prohibiciones explícitas.
5. Cargar recurso autoritativo.
6. Evaluar relación sujeto↔recurso.
7. Evaluar estado y transición.
8. Evaluar hora, saldo, cobertura, disponibilidad y riesgo.
9. Aplicar rate limit e idempotencia.
10. Autorizar el caso de uso.
11. Registrar auditoría cuando sea crítico.
```

No debe aceptarse `role`, `mode`, `owner_id`, `organizer_id`, `balance` o `status` enviados por el cliente como autoridad.

---

# 1. Compatibilidad rol–modo

| Roles efectivos de la cuenta | `CLIENTE` | `CLIENTE_FINANCIERO` | `VENDEDOR` | `ADMINISTRADOR` |
|---|---:|---:|---:|---:|
| Solo `CLIENTE` | Sí | No | No | No |
| Solo `VENDEDOR` | No | Sí | Sí | No |
| Solo `ADMINISTRADOR` | No | Sí | Sí, con perfil Vendedor activo | Sí |
| `CLIENTE` + `VENDEDOR` | No para lotería oficial | Sí | Sí | No |
| `CLIENTE` + `ADMINISTRADOR` | No para lotería oficial | Sí | Sí, con perfil Vendedor activo | Sí |
| `VENDEDOR` + `ADMINISTRADOR` | No | Sí | Sí | Sí |
| Los tres roles | No para lotería oficial | Sí | Sí | Sí |

> **Deny override:** la presencia de `VENDEDOR` o `ADMINISTRADOR` impide participar en lotería oficial, aunque la cuenta también posea `CLIENTE`.

---

# 2. Matriz principal de permisos

Leyenda:

- **Rol:** rol global requerido.
- **Modo:** modo activo requerido.
- **Relación:** vínculo obligatorio con el recurso.
- **Guardas:** estado, transición y condiciones adicionales.
- **Reglas:** identificadores normativos.

## 2.1 Público y autenticación

| ID | Clave | Acción | Rol | Modo | Relación | Guardas principales | Reglas |
|---|---|---|---|---|---|---|---|
| `PERM-PUB-001` | `public.landing.read` | Consultar landing y contenido institucional | PÚBLICO | N/A | PUBLIC | Contenido publicado y no sensible | `LOT-GOV-001` |
| `PERM-PUB-002` | `public.official-events.list` | Listar eventos oficiales visibles | PÚBLICO | N/A | PUBLIC | Solo campos públicos; filtros por estado/visibilidad | `LOT-EVT-006`, `LOT-PRZ-018` |
| `PERM-PUB-003` | `public.official-events.read` | Consultar detalle público de evento oficial | PÚBLICO | N/A | PUBLIC | No exponer datos privados ni internos de fondos | `LOT-EVT-006`, `LOT-PRZ-018` |
| `PERM-PUB-004` | `public.results.list` | Listar informes públicos | PÚBLICO | N/A | PUBLIC | Solo informes PUBLICADO | `LOT-PRZ-018` |
| `PERM-PUB-005` | `public.results.read` | Consultar resultado e informe público | PÚBLICO | N/A | PUBLIC | Resultado fijado/informe publicado; allowlist pública | `LOT-PRZ-014`, `LOT-PRZ-018` |
| `PERM-PUB-006` | `public.results.verify` | Consultar commitment, snapshot y verificación | PÚBLICO | N/A | PUBLIC | Solo evidencia revelable; nunca semilla secreta previa | `LOT-PRZ-012`, `LOT-PRZ-013`, `LOT-PRZ-014` |
| `PERM-PUB-007` | `public.user-draws.list` | Listar sorteos de usuario públicos | PÚBLICO | N/A | PUBLIC | visibility=PÚBLICO y estado visible | `LOT-ORG-002` |
| `PERM-PUB-008` | `public.user-draws.read` | Consultar ficha pública de sorteo de usuario | PÚBLICO | N/A | PUBLIC | Sin anuncios internos, códigos, participantes ni evidencia privada | `LOT-ORG-002`, `LOT-ORG-007` |
| `PERM-AUTH-001` | `auth.register` | Registrar una cuenta | PÚBLICO | N/A | NONE | Datos válidos, mayoría de edad, términos y unicidad | `LOT-IAM-007` |
| `PERM-AUTH-002` | `auth.login` | Iniciar sesión | PÚBLICO | N/A | NONE | Credenciales válidas; cuenta `ACTIVO`; controles de fuerza bruta | `LOT-IAM-008`, `LOT-AUD-006` |
| `PERM-AUTH-003` | `auth.refresh` | Rotar credencial de sesión | AUTENTICADO | N/A | SELF_SESSION | Refresh válido, no revocado y dispositivo autorizado | `LOT-IAM-002`, `LOT-AUD-006` |
| `PERM-AUTH-004` | `auth.logout` | Cerrar sesión actual | AUTENTICADO | CUALQUIER MODO | SELF_SESSION | Sesión abierta | `LOT-IAM-002` |
| `PERM-AUTH-005` | `auth.password-recovery` | Solicitar/restablecer contraseña | PÚBLICO/AUTENTICADO | N/A | SELF_IDENTITY | Token vigente; rate limit | `LOT-IAM-007`, `LOT-AUD-006` |

## 2.2 Identidad y sesión propia

| ID | Clave | Acción | Rol | Modo | Relación | Guardas principales | Reglas |
|---|---|---|---|---|---|---|---|
| `PERM-SELF-001` | `profile.self.read` | Consultar perfil propio | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CUALQUIER MODO AUTORIZADO | SELF | Sesión válida; datos minimizados | `LOT-IAM-002`, `LOT-IAM-006` |
| `PERM-SELF-002` | `profile.self.update` | Actualizar datos personales permitidos | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CUALQUIER MODO AUTORIZADO | SELF | Cuenta ACTIVO; no modificar roles/estado/documento único sin flujo | `LOT-IAM-007`, `LOT-IAM-008` |
| `PERM-SELF-003` | `security.password.change` | Cambiar contraseña propia | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CUALQUIER MODO AUTORIZADO | SELF | Cuenta ACTIVO; credencial actual o desafío reforzado | `LOT-IAM-008`, `LOT-AUD-006` |
| `PERM-SELF-004` | `sessions.self.list` | Listar sesiones y dispositivos propios | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CUALQUIER MODO AUTORIZADO | SELF | Sesión válida | `LOT-IAM-002` |
| `PERM-SELF-005` | `sessions.self.revoke` | Revocar otra sesión propia | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CUALQUIER MODO AUTORIZADO | SELF | No requiere acceso al recurso de otro usuario | `LOT-IAM-002`, `LOT-IAM-006` |
| `PERM-SELF-006` | `sessions.mode.change` | Cambiar modo activo | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CUALQUIER MODO AUTORIZADO | SELF_SESSION | Modo destino compatible con roles y perfil contextual | `LOT-IAM-001`, `LOT-IAM-002`, `LOT-IAM-006` |
| `PERM-SELF-007` | `terms.self.accept` | Aceptar versión de términos | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CUALQUIER MODO AUTORIZADO | SELF | Versión vigente; aceptación inmutable | `LOT-IAM-007` |
| `PERM-SELF-008` | `history.self.read` | Consultar historial propio permitido | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CUALQUIER MODO AUTORIZADO | SELF | Incluso sin nuevas operaciones; sujeto a autenticación y privacidad | `LOT-IAM-008`, `LOT-IAM-009` |

## 2.3 Wallets y operaciones financieras

| ID | Clave | Acción | Rol | Modo | Relación | Guardas principales | Reglas |
|---|---|---|---|---|---|---|---|
| `PERM-FIN-001` | `wallet.self.read` | Consultar wallets y componentes de saldo propios | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO<br>VENDEDOR | SELF_WALLET | Cuenta ACTIVO para operar; lectura según sesión | `LOT-FIN-001`, `LOT-FIN-006`, `LOT-IAM-008` |
| `PERM-FIN-002` | `wallet.self.movements.read` | Consultar movimientos propios | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO<br>VENDEDOR | SELF_LEDGER | Paginación; no exponer cuentas ajenas | `LOT-FIN-005`, `LOT-FIN-012` |
| `PERM-FIN-003` | `topup.self.create` | Crear recarga REAL simulada | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO<br>VENDEDOR | SELF_WALLET | Cuenta ACTIVO; proveedor simulado; idempotencia | `LOT-FIN-008`, `LOT-GOV-008`, `LOT-FIN-012` |
| `PERM-FIN-004` | `conversion.self.virtual-to-real` | Convertir VIRTUAL a REAL | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO<br>VENDEDOR | SELF_WALLET | Cuenta ACTIVO; saldo suficiente; 10 %; idempotencia | `LOT-FIN-009`, `LOT-FIN-012`, `LOT-FIN-013` |
| `PERM-FIN-005` | `withdrawal.self.create` | Solicitar retiro REAL simulado | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO<br>VENDEDOR | SELF_WALLET | Cuenta ACTIVO; REAL disponible; sin segunda comisión | `LOT-FIN-010`, `LOT-GOV-008` |
| `PERM-FIN-006` | `withdrawal.self.read` | Consultar retiros propios | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO<br>VENDEDOR | SELF | Solo solicitudes propias | `LOT-FIN-010`, `LOT-IAM-006` |
| `PERM-FIN-007` | `transfer.virtual.create` | Transferir VIRTUAL | CLIENTE | CLIENTE | SELF_TO_ELIGIBLE_RECIPIENT | Emisor y destinatario con rol Cliente y cuenta `ACTIVO`; no autoenvío; saldo suficiente; idempotencia | `LOT-IAM-003`, `LOT-FIN-011`, `LOT-FIN-012` |
| `PERM-FIN-008` | `conversion-request.client.create` | Crear solicitud REAL→VIRTUAL | CLIENTE | CLIENTE | SELF | Cuenta ACTIVO; REAL suficiente; reserva exacta | `LOT-VND-003`, `LOT-IAM-003` |
| `PERM-FIN-009` | `conversion-request.client.read` | Consultar solicitudes propias | CLIENTE | CLIENTE | SELF | Solo solicitudes del cliente | `LOT-VND-003`, `LOT-VND-010` |
| `PERM-FIN-010` | `wallet.projection.repair` | Reparar proyección desde ledger | SYSTEM<br>ADMINISTRADOR | SYSTEM<br>ADMINISTRADOR | SYSTEM_JOB<br>ADMIN_SCOPE | Admin requiere permiso reforzado; nunca crea segundo movimiento | `LOT-PRZ-017`, `LOT-AUD-004` |

## 2.4 Vendedor y solicitudes

| ID | Clave | Acción | Rol | Modo | Relación | Guardas principales | Reglas |
|---|---|---|---|---|---|---|---|
| `PERM-VND-001` | `vendor.dashboard.read` | Consultar resumen, capital, inventario y ganancias propias | VENDEDOR<br>ADMINISTRADOR | VENDEDOR | SELF_VENDOR_PROFILE | Perfil de Vendedor ACTIVO | `LOT-VND-002`, `LOT-IAM-002` |
| `PERM-VND-002` | `vendor.inventory.read` | Consultar inventario y lotes propios | VENDEDOR<br>ADMINISTRADOR | VENDEDOR | SELF_VENDOR_PROFILE | Perfil de Vendedor ACTIVO | `LOT-VND-001`, `LOT-VND-002` |
| `PERM-VND-003` | `vendor.inventory.purchase` | Comprar VIRTUAL a 0,90 REAL por 1,00 VIRTUAL | VENDEDOR<br>ADMINISTRADOR | VENDEDOR | SELF_VENDOR_PROFILE | Cuenta/perfil ACTIVO; REAL suficiente; importe múltiplo de 1,00 VIRTUAL; idempotencia | `LOT-VND-001`, `LOT-VND-002`, `LOT-FIN-013` |
| `PERM-VND-004` | `vendor.requests.list` | Listar solicitudes compatibles | VENDEDOR<br>ADMINISTRADOR | VENDEDOR | ELIGIBLE_VENDOR | Saldo suficiente; no cuenta propia/relacionada; solicitud PENDIENTE | `LOT-VND-004` |
| `PERM-VND-005` | `vendor.requests.assign` | Tomar solicitud | VENDEDOR<br>ADMINISTRADOR | VENDEDOR | ELIGIBLE_VENDOR | Asignación atómica; solicitud PENDIENTE; no relacionada | `LOT-VND-004`, `LOT-VND-005`, `LOT-VND-006` |
| `PERM-VND-006` | `vendor.requests.confirm` | Confirmar solicitud asignada | VENDEDOR<br>ADMINISTRADOR | VENDEDOR | ASSIGNED_VENDOR | EN_PROCESO; antes de finalización; saldo VIRTUAL suficiente | `LOT-VND-006`, `LOT-VND-007`, `LOT-VND-010` |
| `PERM-VND-007` | `vendor.requests.cancel` | Cancelar/liberar asignación propia | VENDEDOR<br>ADMINISTRADOR | VENDEDOR | ASSIGNED_VENDOR | EN_PROCESO y antes del vencimiento | `LOT-VND-008` |
| `PERM-VND-008` | `vendor.sales.read` | Consultar ventas y ganancia realizada propias | VENDEDOR<br>ADMINISTRADOR | VENDEDOR | SELF_VENDOR_PROFILE | Solo operaciones propias | `LOT-VND-002`, `LOT-VND-007` |

## 2.5 Cliente en lotería oficial

| ID | Clave | Acción | Rol | Modo | Relación | Guardas principales | Reglas |
|---|---|---|---|---|---|---|---|
| `PERM-OFF-001` | `official.availability.read` | Consultar disponibilidad y combinaciones compatibles | CLIENTE | CLIENTE | PUBLIC_EVENT | Evento PUBLICADO/VENTAS_ABIERTAS; datos públicos/derivados | `LOT-EVT-005`, `LOT-EVT-006`, `LOT-EVT-015` |
| `PERM-OFF-002` | `official.purchase-session.create` | Crear sesión de compra oficial | CLIENTE | CLIENTE | SELF_IN_EVENT | Cuenta ACTIVO; rol efectivo exclusivamente elegible para participar; evento VENTAS_ABIERTAS; hora, límite, saldo y disponibilidad | `LOT-IAM-003`, `LOT-IAM-004`, `LOT-EVT-010`, `LOT-EVT-012` |
| `PERM-OFF-003` | `official.reservation.random` | Reservar combinación aleatoria | CLIENTE | CLIENTE | SELF_IN_EVENT | Cuenta ACTIVO; rol efectivo exclusivamente elegible para participar; evento VENTAS_ABIERTAS; hora, límite, saldo y disponibilidad | `LOT-EVT-011`, `LOT-EVT-012`, `LOT-EVT-015` |
| `PERM-OFF-004` | `official.reservation.partial` | Reservar/completar selección parcial | CLIENTE | CLIENTE | SELF_IN_EVENT | Cuenta ACTIVO; rol efectivo exclusivamente elegible para participar; evento VENTAS_ABIERTAS; hora, límite, saldo y disponibilidad | `LOT-EVT-003`, `LOT-EVT-004`, `LOT-EVT-011`, `LOT-EVT-015` |
| `PERM-OFF-005` | `official.reservation.exact` | Reservar selección exacta | CLIENTE | CLIENTE | SELF_IN_EVENT | Cuenta ACTIVO; rol efectivo exclusivamente elegible para participar; evento VENTAS_ABIERTAS; hora, límite, saldo y disponibilidad | `LOT-EVT-001`, `LOT-EVT-003`, `LOT-EVT-004`, `LOT-EVT-011` |
| `PERM-OFF-006` | `official.cart.read` | Consultar carrito propio | CLIENTE | CLIENTE | SELF | Sesión/carrito propio | `LOT-EVT-011`, `LOT-EVT-020` |
| `PERM-OFF-007` | `official.cart.release-item` | Liberar reserva propia del carrito | CLIENTE | CLIENTE | SELF_RESERVATION | Reserva ACTIVA y propia | `LOT-EVT-011`, `LOT-EVT-020` |
| `PERM-OFF-008` | `official.purchase.confirm` | Confirmar orden de compra | CLIENTE | CLIENTE | SELF_ORDER | Cuenta ACTIVO; rol efectivo exclusivamente elegible para participar; evento VENTAS_ABIERTAS; hora, límite, saldo y disponibilidad; reserva ACTIVA y propia; idempotencia | `LOT-EVT-001`, `LOT-EVT-012`, `LOT-EVT-014`, `LOT-EVT-016` |
| `PERM-OFF-009` | `official.tickets.list` | Listar boletos propios | CLIENTE | CLIENTE | SELF | Filtros permitidos; no exponer boletos ajenos | `LOT-IAM-003`, `LOT-EVT-017` |
| `PERM-OFF-010` | `official.tickets.read` | Consultar boleto propio | CLIENTE | CLIENTE | OWNER_OF_TICKET | Boleto propio; comprobante verificable | `LOT-EVT-017`, `LOT-IAM-006` |
| `PERM-OFF-011` | `official.ticket.refund-request` | Solicitar revisión de cobro/error | CLIENTE | CLIENTE | OWNER_OF_TICKET | No es devolución voluntaria; causa autorizada | `LOT-EVT-017` |
| `PERM-OFF-012` | `official.result.animation` | Reproducir/saltar animación | CLIENTE | CLIENTE | PUBLIC_RESULT | Resultado ya fijado; efecto solo visual | `LOT-PRZ-015` |

## 2.6 Administración de plataforma y lotería oficial

| ID | Clave | Acción | Rol | Modo | Relación | Guardas principales | Reglas |
|---|---|---|---|---|---|---|---|
| `PERM-ADM-001` | `admin.users.read` | Consultar usuarios y perfiles administrativos | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso `admin.users.read`; minimización y auditoría | `LOT-IAM-005`, `LOT-AUD-001`, `LOT-AUD-002` |
| `PERM-ADM-002` | `admin.users.status.manage` | Suspender, bloquear, activar o desactivar cuenta | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso reforzado; transición válida; motivo | `LOT-IAM-005`, `LOT-IAM-008`, `LOT-IAM-009`, `LOT-AUD-003` |
| `PERM-ADM-003` | `admin.users.roles.manage` | Asignar o retirar roles globales | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso reforzado; motivo; no autoelevar sin autorización | `LOT-IAM-001`, `LOT-IAM-005`, `LOT-AUD-003` |
| `PERM-ADM-004` | `admin.permissions.read` | Consultar permisos y asignaciones | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso administrativo | `LOT-IAM-005` |
| `PERM-ADM-005` | `admin.permissions.manage` | Modificar asignaciones de permisos | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso reforzado; motivo; auditoría | `LOT-IAM-005`, `LOT-AUD-003` |
| `PERM-ADM-006` | `admin.rule-versions.read` | Consultar versiones de reglas | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Lectura administrativa | `LOT-GOV-007` |
| `PERM-ADM-007` | `admin.rule-versions.create` | Crear nueva versión de reglas | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | No editar versión usada; revisión reforzada | `LOT-GOV-007`, `LOT-IAM-005` |
| `PERM-ADM-008` | `admin.templates.read` | Consultar plantillas/autogeneradores | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso administrativo | `LOT-EVT-008` |
| `PERM-ADM-009` | `admin.templates.create` | Crear plantilla/autogenerador | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Configuración válida; motivo/cambio documentado | `LOT-EVT-008`, `LOT-GOV-007` |
| `PERM-ADM-010` | `admin.templates.update` | Modificar plantilla futura | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Solo afecta eventos futuros no publicados y sin ventas | `LOT-EVT-008` |
| `PERM-ADM-011` | `admin.templates.activate` | Activar, pausar o retirar plantilla | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Transición válida; cobertura controla publicación | `LOT-EVT-008`, `LOT-PRZ-008` |
| `PERM-ADM-012` | `admin.events.read` | Consultar eventos y datos internos | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso administrativo; privacidad | `LOT-IAM-005`, `LOT-EVT-020` |
| `PERM-ADM-013` | `admin.events.create` | Crear evento oficial en borrador | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Producto, versión y configuración válidos | `LOT-EVT-002`, `LOT-EVT-003`, `LOT-GOV-007` |
| `PERM-ADM-014` | `admin.events.publish` | Publicar evento oficial | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso reforzado; cobertura RESERVADA; evento elegible | `LOT-EVT-007`, `LOT-EVT-009`, `LOT-PRZ-007` |
| `PERM-ADM-015` | `admin.events.cancel` | Cancelar evento oficial | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso reforzado; resultado no fijado; motivo; reembolso total | `LOT-EVT-018`, `LOT-EVT-019`, `LOT-AUD-003` |
| `PERM-ADM-016` | `admin.economy.simulate` | Ejecutar simulador económico | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Solo cálculo; no mueve fondos | `LOT-PRZ-003`, `LOT-PRZ-004`, `LOT-PRZ-005` |
| `PERM-ADM-017` | `admin.funds.read` | Consultar fondos y reservas | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso sensible de lectura | `LOT-PRZ-007`, `LOT-PRZ-008` |
| `PERM-ADM-018` | `admin.funds.contribute` | Aportar al fondo de garantía | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso reforzado; fuente autorizada; motivo; doble entrada | `LOT-PRZ-007`, `LOT-PRZ-008`, `LOT-IAM-005`, `LOT-AUD-003` |
| `PERM-ADM-019` | `admin.funds.future-prize.use` | Usar fondo de premios futuros | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso reforzado; evento beneficiado y motivo | `LOT-PRZ-010`, `LOT-IAM-005` |
| `PERM-ADM-020` | `admin.results.read` | Consultar commitments, snapshots, evaluación y estado interno | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | No revelar semilla antes de tiempo | `LOT-PRZ-012`, `LOT-PRZ-013`, `LOT-AUD-002` |
| `PERM-ADM-021` | `admin.results.retry-process` | Solicitar reintento de proceso de resultado/informe | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso reforzado; el worker ejecuta; resultado inexistente o efecto incompleto | `LOT-PRZ-014`, `LOT-PRZ-016`, `LOT-AUD-004` |
| `PERM-ADM-022` | `admin.reconciliation.run` | Solicitar reconciliación de ledger/fondos | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso reforzado; worker idempotente | `LOT-PRZ-017`, `LOT-AUD-004` |
| `PERM-ADM-023` | `admin.audit.read` | Consultar auditoría | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso sensible; filtros y propósito | `LOT-AUD-001`, `LOT-AUD-002` |
| `PERM-ADM-024` | `admin.audit.export` | Exportar auditoría | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso reforzado; exportación auditada y protegida | `LOT-AUD-001`, `LOT-AUD-002` |
| `PERM-ADM-025` | `admin.security-events.read` | Consultar alertas de seguridad/riesgo | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso de seguridad | `LOT-AUD-006` |
| `PERM-ADM-026` | `admin.jobs.read` | Consultar trabajos y errores | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso operativo | `LOT-AUD-004` |
| `PERM-ADM-027` | `admin.jobs.retry` | Reintentar trabajo agotado | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso reforzado; misma clave lógica; motivo | `LOT-AUD-004`, `LOT-GOV-003` |
| `PERM-ADM-028` | `admin.settings.manage` | Gestionar configuración operativa no histórica | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | No modificar reglas históricas; motivo y auditoría | `LOT-GOV-007`, `LOT-AUD-003` |
| `PERM-ADM-029` | `admin.platform-liquidity.fund` | Fondear caja REAL o wallet general VIRTUAL | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso reforzado; fuente autorizada; monto, motivo, doble entrada y auditoría | `LOT-FIN-005`, `LOT-FIN-007`, `LOT-FIN-012`, `LOT-VND-009`, `LOT-AUD-003` |

## 2.7 Sorteos creados por usuarios — autoservicio

| ID | Clave | Acción | Rol | Modo | Relación | Guardas principales | Reglas |
|---|---|---|---|---|---|---|---|
| `PERM-ORG-001` | `user-draws.create` | Crear sorteo de usuario | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | SELF_BECOMES_ORGANIZER | Cuenta ACTIVO; datos mínimos válidos | `LOT-ORG-001`, `LOT-ORG-003`, `LOT-IAM-008` |
| `PERM-ORG-002` | `user-draws.own.read` | Consultar sorteo propio con datos internos | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | ORGANIZER_OF | Sorteo propio | `LOT-ORG-001`, `LOT-ORG-016` |
| `PERM-ORG-003` | `user-draws.draft.update` | Editar sorteo propio en borrador | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | ORGANIZER_OF | Estado BORRADOR; antes del primer pago | `LOT-ORG-003`, `LOT-ORG-024` |
| `PERM-ORG-004` | `user-draws.publish` | Publicar sorteo propio | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | ORGANIZER_OF | BORRADOR; evidencia de premio; configuración válida | `LOT-ORG-003`, `LOT-ORG-023` |
| `PERM-ORG-005` | `user-draws.range.expand` | Ampliar rango | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | ORGANIZER_OF | Antes del cierre; solo números nuevos; no altera existentes | `LOT-ORG-004`, `LOT-ORG-024` |
| `PERM-ORG-006` | `user-draws.announcements.create` | Publicar anuncio interno | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | ORGANIZER_OF | Sorteo no terminal; contenido permitido | `LOT-ORG-003`, `LOT-ORG-007` |
| `PERM-ORG-007` | `user-draws.timeline.read` | Consultar historial completo del sorteo propio | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | ORGANIZER_OF | Solo Organizador del recurso | `LOT-ORG-016` |
| `PERM-ORG-008` | `user-draws.cancel` | Cancelar sorteo propio | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | ORGANIZER_OF | Antes de RESULTADO_FIJADO; motivo; reembolsos idempotentes | `LOT-ORG-008`, `LOT-ORG-009` |
| `PERM-ORG-009` | `user-draws.codes.issue` | Emitir código privado | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | ORGANIZER_OF | Sorteo PRIVADO; número disponible; expires_at≤cierre | `LOT-ORG-010`, `LOT-ORG-011`, `LOT-ORG-012`, `LOT-ORG-015` |
| `PERM-ORG-010` | `user-draws.codes.read` | Consultar códigos propios e historial | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | ORGANIZER_OF | No revelar secreto en claro; datos del sorteo propio | `LOT-ORG-011`, `LOT-ORG-014`, `LOT-ORG-016` |
| `PERM-ORG-011` | `user-draws.code.claim` | Reclamar código privado | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | VALID_CODE_HOLDER | Cuenta ACTIVO; código EMITIDO, vigente y de un uso | `LOT-ORG-010`, `LOT-ORG-013`, `LOT-ORG-014`, `LOT-ORG-015` |
| `PERM-ORG-012` | `user-draws.participation.buy` | Comprar participación | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | SELF_IN_ACCESSIBLE_DRAW | Cuenta ACTIVO; sorteo accesible/abierto; VIRTUAL suficiente; número disponible | `LOT-FIN-004`, `LOT-FIN-013`, `LOT-ORG-006`, `LOT-ORG-017` |
| `PERM-ORG-013` | `user-draws.participation.buy-additional` | Comprar participación adicional | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | PARTICIPANT_OF | Antes del cierre; número disponible; idempotencia | `LOT-ORG-017` |
| `PERM-ORG-014` | `user-draws.participation.change-number` | Cambiar número propio | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | OWNER_OF_PARTICIPATION | Antes del cierre; nuevo número disponible | `LOT-ORG-017` |
| `PERM-ORG-015` | `user-draws.participation.abandon` | Abandonar participación propia | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | OWNER_OF_PARTICIPATION | Antes del cierre; efectos dependen del pago; confirmación explícita | `LOT-ORG-019` |
| `PERM-ORG-016` | `user-draws.announcements.read` | Consultar anuncios internos | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | PARTICIPANT_OF<br>ORGANIZER_OF | Participación vinculada o propietario | `LOT-ORG-007` |
| `PERM-ORG-017` | `user-draws.participants.expel` | Expulsar participante | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | ORGANIZER_OF | Antes del cierre; motivo; reembolso y liberación cuando pagado | `LOT-ORG-018`, `LOT-AUD-003` |
| `PERM-ORG-018` | `user-draws.claim.create` | Presentar reclamo | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | PARTICIPANT_OF<br>AFFECTED_USER | Dentro de 7 días o reapertura administrativa posterior | `LOT-ORG-020` |
| `PERM-ORG-019` | `user-draws.claim.read-own` | Consultar reclamo propio | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | CLAIMANT<br>ORGANIZER_OF_RELATED_DRAW | El Organizador ve reclamos del sorteo; el reclamante el suyo | `LOT-ORG-016`, `LOT-ORG-020` |
| `PERM-ORG-020` | `user-draws.claim.respond` | Responder y aportar evidencia como Organizador | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | ORGANIZER_OF_RELATED_DRAW | Reclamo EN_REVISION/ESPERANDO_EVIDENCIA; no resuelve | `LOT-ORG-020`, `LOT-ORG-021` |
| `PERM-ORG-021` | `user-draws.claim.appeal` | Apelar resolución propia | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | CLAIMANT | RESUELTO/RECHAZADO; dentro de 3 días | `LOT-ORG-021` |
| `PERM-ORG-022` | `user-draws.delivery.register` | Registrar evidencia de entrega | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | ORGANIZER_OF | RESULTADO_FIJADO/ENTREGA_PENDIENTE; evidencia válida | `LOT-ORG-023` |
| `PERM-ORG-023` | `user-draws.delivery.confirm` | Confirmar recepción del premio | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | WINNER_OF | Entrega registrada; ganador autenticado | `LOT-ORG-023`, `LOT-ORG-025` |
| `PERM-ORG-024` | `user-draws.delivery.dispute` | Abrir reclamo por entrega | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | WINNER_OF | Dentro del plazo; entrega pendiente/registrada | `LOT-ORG-020`, `LOT-ORG-023` |
| `PERM-ORG-025` | `user-draws.escrow.read` | Consultar estado agregado del escrow propio | CLIENTE<br>VENDEDOR<br>ADMINISTRADOR | CLIENTE<br>CLIENTE_FINANCIERO | ORGANIZER_OF | Lectura; no permite usar saldo retenido | `LOT-ORG-006`, `LOT-ORG-025` |

## 2.8 Sorteos creados por usuarios — moderación

| ID | Clave | Acción | Rol | Modo | Relación | Guardas principales | Reglas |
|---|---|---|---|---|---|---|---|
| `PERM-MOD-001` | `admin.user-draws.read-all` | Consultar sorteos de usuario y datos de moderación | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso de moderación; datos según necesidad | `LOT-IAM-005`, `LOT-ORG-009` |
| `PERM-MOD-002` | `admin.user-draws.evidence.read` | Consultar evidencia de premio/entrega | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso sensible; auditoría | `LOT-ORG-023`, `LOT-AUD-002` |
| `PERM-MOD-003` | `admin.user-draws.claim.admit` | Admitir reclamo | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso de reclamos; plazo o reapertura motivada | `LOT-ORG-020`, `LOT-ORG-021` |
| `PERM-MOD-004` | `admin.user-draws.claim.request-evidence` | Solicitar evidencia | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Reclamo EN_REVISION; plazo indicado | `LOT-ORG-021` |
| `PERM-MOD-005` | `admin.user-draws.claim.resolve` | Resolver o rechazar reclamo | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso reforzado; motivo, evidencia y compensaciones | `LOT-IAM-005`, `LOT-ORG-020`, `LOT-ORG-021`, `LOT-AUD-003` |
| `PERM-MOD-006` | `admin.user-draws.claim.reopen` | Reabrir reclamo fuera de plazo | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso reforzado; motivo administrativo | `LOT-ORG-020`, `LOT-ORG-021`, `LOT-AUD-003` |
| `PERM-MOD-007` | `admin.user-draws.claim.close` | Cerrar reclamo firme | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Resolución firme y compensaciones completadas | `LOT-ORG-021` |
| `PERM-MOD-008` | `admin.user-draws.escrow.hold` | Mantener/bloquear escrow por disputa | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso reforzado; reclamo vinculado; motivo | `LOT-ORG-023`, `LOT-ORG-025` |
| `PERM-MOD-009` | `admin.user-draws.escrow.release` | Autorizar liberación del 95 % | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso reforzado; resultado y entrega/resolución válidos | `LOT-IAM-005`, `LOT-ORG-025` |
| `PERM-MOD-010` | `admin.user-draws.refund.order` | Ordenar reembolso por incumplimiento | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Reclamo resuelto; doble entrada; idempotencia | `LOT-ORG-023`, `LOT-ORG-025` |
| `PERM-MOD-011` | `admin.user-draws.breach.confirm` | Confirmar incumplimiento del Organizador | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Permiso reforzado; evidencia; motivo | `LOT-ORG-020`, `LOT-ORG-023`, `LOT-AUD-003` |
| `PERM-MOD-012` | `admin.user-draws.post-close-measure` | Aplicar medida posterior al cierre mediante reclamo | ADMINISTRADOR | ADMINISTRADOR | ADMIN_SCOPE | Solo resolución formal; no expulsión directa ordinaria | `LOT-ORG-018`, `LOT-ORG-020`, `LOT-ORG-021` |

## 2.9 Worker y procesos técnicos

| ID | Clave | Acción | Rol | Modo | Relación | Guardas principales | Reglas |
|---|---|---|---|---|---|---|---|
| `PERM-SYS-001` | `system.reservations.expire` | Expirar reservas oficiales | SYSTEM | SYSTEM | SYSTEM_JOB | Hora oficial≥expires_at; idempotencia | `LOT-EVT-011`, `LOT-AUD-004` |
| `PERM-SYS-002` | `system.conversion-request.fallback` | Completar/fallar solicitud al minuto cinco | SYSTEM | SYSTEM | SYSTEM_JOB | Lock; finalización única; liquidez | `LOT-VND-009`, `LOT-VND-010`, `LOT-AUD-004` |
| `PERM-SYS-003` | `system.events.open-sales` | Abrir ventas oficiales | SYSTEM | SYSTEM | SYSTEM_JOB | Hora oficial; evento PUBLICADO | `LOT-GOV-005`, `LOT-EVT-010` |
| `PERM-SYS-004` | `system.events.close-sales` | Cerrar ventas oficiales | SYSTEM | SYSTEM | SYSTEM_JOB | Hora oficial=sorteo−10 min | `LOT-EVT-010`, `LOT-AUD-004` |
| `PERM-SYS-005` | `system.events.freeze` | Congelar boletos y snapshot | SYSTEM | SYSTEM | SYSTEM_JOB | VENTAS_CERRADAS; reservas resueltas | `LOT-PRZ-013`, `LOT-AUD-004` |
| `PERM-SYS-006` | `system.results.generate` | Generar resultado oficial | SYSTEM | SYSTEM | SYSTEM_JOB | Commitment/snapshot válidos; UNIQUE(evento) | `LOT-PRZ-012`, `LOT-PRZ-013`, `LOT-PRZ-014` |
| `PERM-SYS-007` | `system.tickets.evaluate` | Evaluar boletos | SYSTEM | SYSTEM | SYSTEM_JOB | Resultado fijado; idempotencia | `LOT-PRZ-001`, `LOT-PRZ-002` |
| `PERM-SYS-008` | `system.reports.publish` | Publicar informe oficial | SYSTEM | SYSTEM | SYSTEM_JOB | Evaluación completa; allowlist pública | `LOT-PRZ-016`, `LOT-PRZ-018` |
| `PERM-SYS-009` | `system.awards.credit` | Acreditar premios/devoluciones | SYSTEM | SYSTEM | SYSTEM_JOB | Informe publicado; clave única | `LOT-PRZ-016`, `LOT-PRZ-017` |
| `PERM-SYS-010` | `system.refunds.execute` | Ejecutar reembolsos oficiales/de usuario | SYSTEM | SYSTEM | SYSTEM_JOB | Orden autorizada; idempotencia; doble entrada | `LOT-EVT-018`, `LOT-ORG-008`, `LOT-AUD-004` |
| `PERM-SYS-011` | `system.funds.distribute` | Distribuir evento sin ganador | SYSTEM | SYSTEM | SYSTEM_JOB | Meta evaluada; orden de prelación | `LOT-PRZ-009`, `LOT-PRZ-010`, `LOT-PRZ-011` |
| `PERM-SYS-012` | `system.user-draws.codes.expire` | Expirar códigos privados | SYSTEM | SYSTEM | SYSTEM_JOB | expires_at/cierre; liberar una vez; reembolsar si pagado no reclamado | `LOT-ORG-015`, `LOT-AUD-004` |
| `PERM-SYS-013` | `system.user-draws.freeze` | Congelar snapshot de participaciones | SYSTEM | SYSTEM | SYSTEM_JOB | Sorteo cerrado; PAGADO+ACTIVA | `LOT-ORG-022` |
| `PERM-SYS-014` | `system.user-draws.result.generate` | Generar ganador de sorteo de usuario | SYSTEM | SYSTEM | SYSTEM_JOB | CSPRNG; snapshot; resultado único | `LOT-ORG-022` |
| `PERM-SYS-015` | `system.user-draws.escrow.settle` | Ejecutar liberación/reembolso de escrow | SYSTEM | SYSTEM | SYSTEM_JOB | Orden autorizada; idempotencia; doble entrada | `LOT-ORG-023`, `LOT-ORG-025` |
| `PERM-SYS-016` | `system.ledger.reconcile` | Reconciliar ledger y proyecciones | SYSTEM | SYSTEM | SYSTEM_JOB | Ledger autoritativo; no crear efectos económicos | `LOT-GOV-002`, `LOT-PRZ-017`, `LOT-AUD-004` |

# 3. Denegaciones obligatorias

| Código | Intento | Resultado |
|---|---|---|
| `DENY-001` | Vendedor o Administrador intenta comprar boleto oficial en cualquier modo. | `403 PERMISSION_DENIED`; no crea sesión, reserva, orden, asiento ni boleto. |
| `DENY-002` | Cliente intenta tomar solicitud de Vendedor. | `403`; no crea asignación. |
| `DENY-003` | Vendedor usa modo `CLIENTE_FINANCIERO` para comprar boleto oficial. | `403`; el modo financiero no habilita juego oficial. |
| `DENY-004` | Administrador sin permiso granular ejecuta una acción administrativa. | `403`; la condición de Administrador no sustituye el permiso. |
| `DENY-005` | Administrador usa modo administrativo para operar su wallet personal o sorteo propio. | `409/403`; debe cambiar al modo financiero apropiado. |
| `DENY-006` | Organizador intenta resolver su propio reclamo o liberar escrow. | `403`; solo Administrador autorizado resuelve/autoriza. |
| `DENY-007` | Participante externo consulta anuncios internos. | `404` o `403` según política antifiltración; no devuelve contenido. |
| `DENY-008` | Usuario no participante consulta sorteo privado sin código/invitación. | No se revela información protegida. |
| `DENY-009` | Organizador edita precio, premio, fechas o reglas después del primer pago. | `409 INVALID_STATE_TRANSITION`. |
| `DENY-010` | Organizador expulsa después del cierre. | `409`; solo medida administrativa mediante reclamo. |
| `DENY-011` | Participante abandona después del cierre. | `409 OPERATION_WINDOW_CLOSED`. |
| `DENY-012` | Organizador intenta usar el 95 % retenido antes de liquidación. | `403/409`; escrow no es saldo disponible. |
| `DENY-013` | Usuario reclama un código vencido o ya usado. | `409 RESOURCE_NOT_AVAILABLE`. |
| `DENY-014` | Cliente solicita devolución voluntaria de boleto. | `422/409`; solo causas autorizadas. |
| `DENY-015` | Administrador intenta editar un resultado o asiento confirmado. | Rechazo; solo operación compensatoria o reintento idempotente. |
| `DENY-016` | Cuenta suspendida, bloqueada o desactivada inicia operación nueva. | Rechazo sin efectos; solo acceso histórico según política. |
| `DENY-017` | Frontend envía otro `owner_id`, `organizer_id`, rol, modo, saldo o estado. | La API ignora/rechaza el dato no autoritativo. |
| `DENY-018` | Worker ejecuta un job no registrado para su tipo de identidad. | Rechazo y evento de seguridad. |

# 4. Matriz de acceso por recurso sensible

## 4.1 Wallet y ledger

| Sujeto | Propia | Ajena | Agregada de plataforma |
|---|---:|---:|---:|
| Cliente/Vendedor/Admin en modo financiero | Lectura y operaciones permitidas por matriz | No | No |
| Vendedor en modo Vendedor | Lectura propia y operaciones de Vendedor | No | No |
| Administrador con `admin.funds.read` | No por privilegio personal | Solo vista administrativa autorizada y minimizada | Sí, según permiso |
| Worker | Solo cuentas necesarias para el job | Solo dentro de transacción autorizada | Sí, según job |

Un Administrador no puede “entrar” en la wallet de un usuario como si fuera el propietario. Las intervenciones usan casos administrativos auditados y no reutilizan endpoints de autoservicio.

## 4.2 Evento oficial

| Acción | Público | Cliente elegible | Vendedor/Admin | Admin con permiso | Worker |
|---|---:|---:|---:|---:|---:|
| Ver tarjeta/detalle público | Sí | Sí | Sí | Sí | N/A |
| Consultar disponibilidad | Sí/limitada | Sí | Sí/lectura | Sí | N/A |
| Reservar/comprar | No | Sí, modo Cliente | No | No | No |
| Crear/publicar/cancelar | No | No | No | Sí | Solo transiciones horarias/jobs |
| Fijar resultado | No | No | No | No directamente | Sí |
| Ver informe público | Sí | Sí | Sí | Sí | N/A |

## 4.3 Sorteo creado por usuario

| Acción | Externo | Participante | Organizador | Admin autorizado | Worker |
|---|---:|---:|---:|---:|---:|
| Ver sorteo público | Sí | Sí | Sí | Sí | N/A |
| Ver sorteo privado | No, salvo flujo de acceso | Sí | Sí | Sí | N/A |
| Ver anuncios | No | Sí | Sí | Sí | N/A |
| Comprar/cambiar/abandonar | No | Sí, recurso propio | No sobre otro | No por privilegio | Jobs solo expiración |
| Emitir códigos/anuncios/ampliar | No | No | Sí | No por privilegio | Expira códigos |
| Expulsar antes del cierre | No | No | Sí, con motivo | No como sustituto ordinario | Ejecuta reembolso autorizado |
| Resolver reclamo | No | No | No | Sí | Ejecuta compensación |
| Liberar escrow | No | No | No | Autoriza | Ejecuta |
| Confirmar entrega | No | Solo ganador | Registra evidencia | Resuelve disputa | N/A |

# 5. Auditoría por tipo de permiso

| Clase | Auditoría mínima |
|---|---|
| Consulta pública | Métricas técnicas; no necesariamente `audit_event` por lectura ordinaria. |
| Lectura propia | Acceso de sesión y seguridad; auditoría reforzada solo en datos sensibles. |
| Operación financiera | Actor, modo, recurso, antes/después, ledger, idempotency key y `correlation_id`. |
| Acción de Vendedor | Vendedor, solicitud, asignación, saldo y resultado. |
| Acción de Organizador | Organizador, sorteo, participante/código, motivo y estado. |
| Acción administrativa | Actor, permiso efectivo, modo, motivo, recurso y resultado. |
| Job | Tipo de job, intento, estado, `correlation_id`, efecto existente o creado. |
| Exportación | Actor, filtros, propósito, archivo/hash y fecha. |

Referencias: `LOT-AUD-001`, `LOT-AUD-002`, `LOT-AUD-003`.

# 6. Pruebas obligatorias de autorización

## 6.1 Rol y modo

- Cliente en modo Cliente compra boleto: permitido si cumple reglas.
- Vendedor en modo Vendedor compra boleto: denegado.
- Vendedor en modo Cliente financiero compra boleto: denegado.
- Administrador en modo Administrador opera wallet propia: denegado; debe cambiar modo.
- Administrador sin permiso cancela evento: denegado.
- Administrador con permiso y motivo cancela antes del resultado: permitido.
- Cuenta con Cliente+Vendedor intenta jugar: denegado por `deny override`.

## 6.2 Recurso

- Usuario A consulta boleto de B: denegado.
- Vendedor no asignado confirma solicitud: denegado.
- Organizador A modifica sorteo de B: denegado.
- Participante externo lee anuncios: denegado.
- Participante cambia únicamente su número: permitido antes del cierre.
- Ganador confirma entrega propia: permitido.
- Participante no ganador confirma entrega: denegado.

## 6.3 Estado

- Editar evento oficial PUBLICADO: denegado.
- Cancelar evento antes de resultado: permitido con permiso.
- Cancelar después de resultado: denegado.
- Expulsar participante antes/después del cierre: permitido/denegado según regla.
- Reclamar código EMITIDO/EXPIRADO/RECLAMADO: permitido/denegado/denegado.
- Liberar escrow antes/después de entrega o resolución: denegado/permitido.

## 6.4 Manipulación del cliente

- Cambiar `active_mode` dentro del JSON sin usar el comando de sesión: denegado.
- Enviar `organizer_user_id` de otra cuenta: ignorado/rechazado.
- Enviar saldo mayor: no afecta validación.
- Navegar a URL administrativa: no revela datos ni ejecuta operación.
- Repetir una orden permitida con la misma idempotency key: mismo efecto.
- Repetirla con cuerpo distinto: conflicto.

# 7. Persistencia recomendada

El diseño posterior debe soportar, como mínimo:

- `roles`
- `permissions`
- `user_roles`
- `role_permissions`
- `sessions.active_mode`
- `vendor_profiles`
- relaciones de propiedad (`user_id`, `organizer_user_id`, `participant_user_id`)
- `claimant_user_id`
- asignaciones de Vendedor
- estados y fechas del recurso
- auditoría del permiso efectivo

La autorización de recurso no debe depender de nombres de rutas ni de que un botón esté oculto.

## 7.1 Contexto de autorización recomendado

Cada caso de uso debería recibir un objeto interno similar a:

```ts
type AuthorizationContext = {
  userId: string;
  accountStatus: string;
  roles: string[];
  activeMode: string;
  permissions: string[];
  sessionId: string;
  deviceId?: string;
  correlationId: string;
};
```

El frontend nunca construye este objeto como autoridad; la API lo deriva de la sesión y PostgreSQL.

## 7.2 Resultado de autorización

```ts
type AuthorizationDecision = {
  allowed: boolean;
  permissionKey: string;
  reasonCode?: string;
  resourceRelation?: string;
  guardsChecked: string[];
};
```

La respuesta pública no debe revelar reglas internas que faciliten evasión de controles.

# 8. Validación del documento

- Identificadores de permisos únicos.
- Claves de permisos únicas.
- Todas las referencias `LOT-*` existen en `REGLAS-NEGOCIO.md` v1.4.0.
- Se distingue rol global, modo activo y relación contextual.
- Organizador no se convierte en rol global.
- Administrador no obtiene acceso universal implícito.
- Vendedor y Administrador no pueden participar en lotería oficial.
- Los sorteos de usuario pueden usarse por cualquier cuenta activa mediante modo financiero.
- Los jobs se autorizan mediante identidad técnica y tipo de trabajo.

# 9. Criterios de aprobación documental

- [x] Se aprueba la compatibilidad rol–modo.
- [x] Se aprueba el `deny override` para Vendedor/Administrador en lotería oficial.
- [x] Se aprueba que Organizador sea relación contextual.
- [x] Se aprueba que Vendedor/Admin usen `CLIENTE_FINANCIERO` en sorteos de usuario.
- [x] Se aprueba que modo Administrador no permita operaciones personales.
- [x] Se aprueba el catálogo de claves de permiso.
- [x] Se aprueban los permisos administrativos reforzados.
- [x] Se aprueban relaciones de recurso y guardas.
- [x] Se aprueba que el worker use permisos técnicos limitados.
- [x] Cada permiso queda asociado a pruebas de rol, modo, recurso y estado.

## 9.1 Gate de implementación

- [ ] OpenAPI documenta el permiso requerido por endpoint y las pruebas E2E verifican cada denegación crítica.
- [x] `DICCIONARIO-DE-DATOS.md` implementa roles, permisos, modos y relaciones.

# 10. Decisión de salida

Con esta matriz aprobada queda permitido:

- crear guardias y decoradores de autorización;
- definir permisos y seeds;
- documentar permisos en OpenAPI;
- diseñar índices y FKs de propiedad;
- crear pruebas E2E por rol, modo y recurso;
- traducir la matriz aprobada a OpenAPI, guardias, seeds y pruebas.

No queda permitido:

- asumir que Administrador equivale a superusuario;
- autorizar por frontend;
- ignorar el modo activo;
- omitir la relación con el recurso;
- permitir acciones por conocer un UUID;
- usar una ruta administrativa como prueba de permiso;
- ejecutar jobs con credenciales humanas.

> **Decisión obligatoria:** una operación solo existe para un sujeto cuando su fila de permiso y todas sus guardas se cumplen.


# 11. Declaración de congelamiento

Las claves `PERM-*`, la compatibilidad rol–modo, las relaciones de recurso y las denegaciones prevalentes constituyen la baseline final de autorización v1.

Un endpoint nuevo no queda autorizado por existir. Debe reutilizar una clave aprobada o requerir una nueva versión documental antes de implementarse.
