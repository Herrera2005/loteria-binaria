---
title: "Plan Técnico de Creación de Lotería Binaria"
subtitle: "Base de datos, backend, web, aplicación móvil, seguridad, pruebas y despliegue"
author: "Cristhian Herrera Nieto"
date: "20 de julio de 2026"
version: "1.0"
---

# PLAN TÉCNICO DE CREACIÓN DE LOTERÍA BINARIA

**Versión:** 1.0  
**Estado:** Plan integral aprobado para ejecución por fases  
**Documento normativo asociado:** Documento Maestro de Reglas del Sistema Lotería Binaria v1.0  
**Autor académico:** Cristhian Herrera Nieto  
**Fecha:** 20 de julio de 2026


# CONTROL DEL DOCUMENTO


## Identificación y autoridad

| Campo | Definición |
| --- | --- |
| Nombre oficial | Plan Técnico de Creación por Fases del Sistema Lotería Binaria |
| Versión | 1.0 |
| Estado | Base técnica aprobada para diseño detallado, implementación y control del proyecto |
| Documento funcional superior | Documento Maestro de Reglas del Sistema Lotería Binaria v1.0 |
| Ámbito | Base de datos, backend/API, procesos asíncronos, plataforma web, aplicación móvil, seguridad, pruebas, infraestructura, despliegue y operación |
| Referencia histórica | El frontend HTML/CSS/JavaScript/JSON existente se usa solo como referencia visual y de navegación |
| Propietario académico | Cristhian Herrera Nieto |
| Fecha de emisión | 20 de julio de 2026 |

Este documento convierte las reglas funcionales y económicas de Lotería Binaria en un plan técnico ejecutable. No reemplaza el Documento Maestro de Reglas: lo complementa. Si existiera una contradicción, prevalece la versión vigente del Documento Maestro de Reglas y debe emitirse una actualización formal de este plan.

> **Decisión obligatoria:** Ninguna fase de implementación puede alterar reglas de negocio para facilitar el código. Si una regla resulta difícil de implementar, se mejora el diseño técnico; no se deforma la regla.


## Objetivos del informe

- Definir una arquitectura única que sirva a la plataforma web y a la aplicación móvil.
- Establecer el orden correcto de construcción para evitar retrabajos y errores financieros.
- Detallar los módulos de base de datos, backend, web, móvil, infraestructura y seguridad.
- Definir entregables, criterios de aceptación, dependencias y pruebas para cada fase.
- Conservar todas las reglas críticas del sistema como requisitos verificables.
- Servir como referencia cuando el proyecto cambie de conversación, herramienta o integrante.
- Permitir relacionar el desarrollo con los temas de la asignatura: cliente, servidor, APIs, diseño adaptable y móvil multiplataforma.


## Normas de interpretación

| Término | Significado técnico |
| --- | --- |
| DEBE | Requisito obligatorio para considerar correcta la implementación. |
| NO DEBE | Comportamiento prohibido. |
| PUEDE | Alternativa permitida que no rompe la arquitectura. |
| RECOMENDADO | Decisión preferida; cualquier reemplazo exige justificación técnica. |
| FUENTE DE VERDAD | Componente autoritativo del que se deriva el estado oficial. |
| IDEMPOTENTE | Repetir una petición produce el mismo resultado sin duplicar efectos. |
| INMUTABLE | Registro que no se actualiza destructivamente después de quedar confirmado. |


# CONTENIDO GENERAL

1. 1. Estado de preparación y enfoque de construcción
1. 2. Decisiones técnicas obligatorias
1. 3. Arquitectura objetivo
1. 4. Estructura del repositorio y gobierno del código
1. 5. Entornos, configuración y secretos
1. 6. Diseño de base de datos
1. 7. Libro contable, wallets y fondos
1. 8. Arquitectura del backend y API
1. 9. Procesos asíncronos, colas y tiempo del servidor
1. 10. Motor de lotería, combinaciones y compras
1. 11. Motor económico, premios y acumulados
1. 12. Resultado verificable, evaluación e informes
1. 13. Plataforma web
1. 14. Aplicación móvil
1. 15. Seguridad, privacidad y antifraude
1. 16. Pruebas y aseguramiento de calidad
1. 17. Infraestructura, despliegue y operación
1. 18. Plan de creación por fases
1. 19. Cronograma y estrategia de versiones
1. 20. Riesgos y mitigaciones
1. 21. Trazabilidad con reglas y asignatura
1. 22. Criterios globales de aceptación
1. Anexos: tablas, endpoints, eventos, estados, variables, listas de verificación y pseudocódigo.


# 1. ESTADO DE PREPARACIÓN Y ENFOQUE DE CONSTRUCCIÓN


## 1.1 Veredicto de viabilidad

El sistema completo es técnicamente realizable. La idea funcional es coherente y puede implementarse con tecnologías web y móviles modernas, siempre que se respete la separación entre interfaz, API, base de datos, procesos asíncronos y libro contable. La complejidad principal no está en dibujar pantallas, sino en mantener consistencia bajo concurrencia, evitar doble venta o doble pago, garantizar solvencia y conservar trazabilidad.

| Área | Preparación | Acción antes de programar |
| --- | --- | --- |
| Reglas de negocio | Completas y formalizadas | Mantener versionadas y convertirlas en pruebas. |
| Arquitectura objetivo | Definida | Crear monorepo, estándares y decisiones de arquitectura. |
| Base de datos | Modelo de alto nivel definido | Diseñar esquema físico, restricciones, índices y migraciones. |
| Backend | Módulos identificados | Definir contratos, errores, seguridad y transacciones. |
| Web | Flujos y paneles definidos | Diseñar componentes, navegación y consumo de API. |
| Móvil | Alcance inicial definido | Diseñar navegación, almacenamiento seguro y flujos reutilizados. |
| Infraestructura | Objetivo definido | Automatizar entornos, CI/CD, backups y observabilidad. |
| Pruebas | Casos críticos identificados | Convertirlos en una estrategia automatizada. |


## 1.2 Tratamiento del proyecto frontend anterior

- Se conserva para observar identidad visual, menú lateral, tarjetas, paneles, formularios y textos explicativos.
- No se migra su lógica de localStorage, JSON, sesiones, temporizadores, saldos ni resultados.
- No se copia código financiero o de seguridad desde el prototipo.
- Se puede reutilizar contenido gráfico, nomenclatura y decisiones de experiencia que no contradigan el Documento Maestro.
- El nuevo sistema se crea en un repositorio separado o en una rama raíz nueva, sin intentar convertir el prototipo archivo por archivo.


## 1.3 Estrategia general

La construcción debe avanzar de adentro hacia afuera: primero reglas y datos; luego backend transaccional; después interfaces web; finalmente aplicación móvil y endurecimiento. La web y el móvil no implementan reglas financieras por separado: consumen una API común.

```text
Reglas versionadas
      ↓
Modelo de datos + restricciones
      ↓
Servicios de dominio y transacciones
      ↓
API versionada
      ↓
Web y aplicación móvil
      ↓
Pruebas, seguridad, despliegue y operación
```


# 2. DECISIONES TÉCNICAS OBLIGATORIAS


## 2.1 Stack principal

| Capa | Tecnología recomendada | Responsabilidad |
| --- | --- | --- |
| Web | Next.js + React + TypeScript | Landing, autenticación, paneles de Cliente, Vendedor y Administrador, resultados públicos. |
| Móvil | React Native + Expo + TypeScript | Aplicación Android/iOS para Cliente y Vendedor; administración completa permanece en web inicialmente. |
| API | NestJS + TypeScript | Reglas, autenticación, permisos, transacciones, validaciones y contratos. |
| Trabajadores | NestJS standalone + BullMQ | Autogeneración, expiraciones, conversiones automáticas, sorteos, premios, reportes y reconciliación. |
| Base de datos | PostgreSQL | Fuente de verdad relacional, restricciones, transacciones y datos históricos. |
| ORM | Prisma | Migraciones, acceso tipado y transacciones; SQL directo permitido en operaciones críticas justificadas. |
| Memoria/colas | Redis | Colas, bloqueos auxiliares, caché, rate limiting y datos efímeros; nunca reemplaza PostgreSQL. |
| Archivos | Almacenamiento S3 compatible | Boletines, comprobantes, exportaciones y archivos generados. |
| Infraestructura | Docker + CI/CD | Entornos reproducibles, pruebas y despliegues controlados. |

> **Nota técnica:** Las versiones exactas de cada framework se fijarán al iniciar la implementación, usando versiones estables compatibles y un archivo lock. El plan no depende de una versión menor concreta.


## 2.2 Principios obligatorios

- TypeScript estricto en web, móvil, API y paquetes compartidos.
- PostgreSQL es la fuente de verdad; Redis solo conserva datos temporales o derivados.
- Todo dinero se almacena como enteros en centavos o centésimas de unidad virtual.
- Las unidades REAL y VIRTUAL nunca se mezclan en una misma suma sin una operación explícita de conversión.
- Los saldos se derivan de un libro contable de doble entrada y pueden materializarse como proyección para rendimiento.
- Las operaciones críticas utilizan transacciones de base de datos y claves de idempotencia.
- Los eventos publicados y los resultados fijados son inmutables; las correcciones se registran como nuevas operaciones compensatorias.
- El backend valida hora, rol, modo activo, saldo, estado, reglas y disponibilidad.
- La web y el móvil no pueden crear resultados, aumentar saldos ni decidir premios.
- Cada cambio de esquema se realiza mediante migración versionada y revisable.


## 2.3 Unidades monetarias

| Unidad | Uso | Representación |
| --- | --- | --- |
| REAL | Recargas, solicitudes, ingresos de vendedores, conversiones y retiros | BIGINT en centavos reales |
| VIRTUAL | Boletos, premios, devoluciones, acumulados, fondos y transferencias | BIGINT en centésimas virtuales |

> **Decisión obligatoria:** El sorteo y toda su economía se calculan en saldo virtual. El saldo real existe para entrada, salida, intercambio y lógica de comisión.


# 3. ARQUITECTURA OBJETIVO


## 3.1 Vista lógica

```text
[ Navegador / Next.js ]        [ React Native / Expo ]
            │ HTTPS / WebSocket / SSE │
            └──────────────┬───────────┘
                           ▼
                    [ API NestJS ]
       ┌──────────────┬────┴────┬──────────────┐
       ▼              ▼         ▼              ▼
 [ PostgreSQL ]   [ Redis ] [ Object Storage ] [ Worker/Queues ]
       │                                      │
       └────────────── fuente de verdad ──────┘
```


## 3.2 Componentes

| Componente | Responsabilidad | No debe hacer |
| --- | --- | --- |
| Next.js | Renderizado web, formularios, accesibilidad, paneles, consumo API | Modificar saldos o validar de forma definitiva una compra. |
| Expo/React Native | Experiencia móvil, almacenamiento seguro, cámara/QR opcional, navegación | Guardar tokens sensibles en almacenamiento inseguro o operar sin confirmar con API. |
| API NestJS | Autorización, reglas, transacciones, contratos, validaciones | Depender del estado del navegador para decidir. |
| Worker | Tareas programadas y reintentables | Crear efectos financieros sin idempotencia. |
| PostgreSQL | Integridad, historial, contabilidad, estados | Confiar solo en validaciones de aplicación. |
| Redis | Reserva auxiliar, colas, locks, caché | Ser fuente única de combinaciones vendidas o saldos. |
| Storage | Archivos de reportes y comprobantes | Guardar secretos o datos de tarjeta. |


## 3.3 Arquitectura interna del backend

Cada módulo debe seguir una separación clara entre transporte, aplicación, dominio e infraestructura. NestJS puede organizarlo mediante módulos, controladores, servicios de aplicación, políticas, repositorios e integraciones.

```text
module/
├── controllers/        # HTTP y WebSocket
├── dto/                # Entrada/salida y validación
├── application/        # Casos de uso y orquestación
├── domain/             # Entidades, reglas, políticas y errores
├── infrastructure/     # Prisma, Redis, storage, proveedores
├── jobs/               # Tareas asíncronas
└── tests/              # Unitarias e integración
```


## 3.4 Comunicación y consistencia

- HTTP REST para operaciones de negocio y consultas paginadas.
- WebSocket o SSE para actualizaciones de eventos, premio, solicitudes y estado del sorteo.
- Patrón Outbox para publicar eventos de dominio solo después de confirmar la transacción de PostgreSQL.
- Patrón Inbox o deduplicación para consumidores que puedan recibir mensajes repetidos.
- Reintentos con retroceso exponencial para tareas temporales.
- Cola de errores o estado de intervención manual para operaciones que agoten reintentos.


# 4. ESTRUCTURA DEL REPOSITORIO Y GOBIERNO DEL CÓDIGO


## 4.1 Monorepo recomendado

```text
loteria-binaria/
├── apps/
│   ├── api/                 # NestJS HTTP/WebSocket
│   ├── worker/              # NestJS jobs y BullMQ
│   ├── web/                 # Next.js
│   └── mobile/              # Expo React Native
├── packages/
│   ├── contracts/           # DTO públicos, tipos y esquemas
│   ├── validation/          # Esquemas compartidos sin reglas sensibles
│   ├── game-engine/         # Matemática pura de combinaciones
│   ├── money/               # Tipos y utilidades monetarias
│   ├── api-client/          # Cliente tipado para web/móvil
│   ├── ui-tokens/           # Colores, tipografía y espaciado
│   ├── eslint-config/
│   ├── tsconfig/
│   └── test-utils/
├── prisma/
│   ├── schema.prisma
│   ├── migrations/
│   └── seed/
├── infrastructure/
│   ├── docker/
│   ├── reverse-proxy/
│   ├── monitoring/
│   └── deployment/
├── docs/
│   ├── rules/
│   ├── architecture/
│   ├── api/
│   ├── database/
│   ├── security/
│   ├── testing/
│   └── operations/
├── scripts/
├── .github/workflows/
├── pnpm-workspace.yaml
├── turbo.json
└── README.md
```


## 4.2 Estrategia de ramas y revisiones

| Elemento | Regla |
| --- | --- |
| Rama principal | main siempre desplegable; protegida contra pushes directos. |
| Integración | develop opcional; para equipo pequeño puede usarse trunk-based con ramas cortas. |
| Ramas | feature/, fix/, docs/, refactor/, security/. |
| Pull request | Debe incluir descripción, riesgos, pruebas y migraciones. |
| Commits | Mensajes convencionales: feat, fix, docs, test, refactor, chore. |
| Revisión | Cambios financieros, permisos, sorteos y migraciones requieren revisión reforzada. |


## 4.3 Estándares de código

- ESLint, Prettier y TypeScript strict ejecutados en CI.
- Nombres en inglés para código y base de datos; interfaz y documentación funcional en español.
- No usar números mágicos: porcentajes, tiempos, estados y límites provienen de versiones o configuración.
- Errores de dominio tipados, no textos dispersos.
- Pruebas junto a los módulos o en carpetas claramente separadas.
- Cobertura de pruebas no sustituye calidad; se exige cobertura alta en motores económicos y de sorteos.
- Todo endpoint sensible debe declarar permiso, idempotencia, auditoría y transacción esperada.


# 5. ENTORNOS, CONFIGURACIÓN Y SECRETOS


## 5.1 Entornos

| Entorno | Objetivo | Datos |
| --- | --- | --- |
| local | Desarrollo individual con Docker Compose | Datos ficticios y reiniciables. |
| test | Pruebas automáticas aisladas | Base efímera por suite o pipeline. |
| development | Integración compartida | Datos de prueba controlados. |
| staging | Ensayo casi idéntico a producción | Datos sintéticos; integraciones sandbox. |
| production | Usuarios y operaciones oficiales | Datos protegidos, backups y auditoría. |


## 5.2 Variables y secretos

- Las variables no sensibles pueden existir en archivos .env de ejemplo.
- Contraseñas, claves de firma, secretos de hash, credenciales de base, storage y proveedores se guardan en un gestor de secretos.
- Nunca se suben secretos reales al repositorio.
- Las claves se rotan y las versiones antiguas se conservan solo mientras sean necesarias para validar datos históricos.
- Los tokens de acceso usan claves separadas de las semillas o compromisos de sorteos.
- La semilla secreta de un evento se cifra en reposo hasta su revelación.


## 5.3 Configuración versionada

Los parámetros de negocio no deben depender de variables de entorno cuando forman parte de una versión histórica. Por ejemplo, cantidad de números, comisión, porcentaje de crecimiento y regla de devolución pertenecen a una versión de reglas almacenada en base de datos. Las variables de entorno controlan infraestructura, no el reglamento.


# 6. DISEÑO DE BASE DE DATOS


## 6.1 Objetivos

- Impedir inconsistencias aunque exista un error en el backend.
- Conservar historial financiero y de eventos.
- Soportar concurrencia en compras, solicitudes y premios.
- Permitir reconstruir saldos y verificar resultados.
- Facilitar consultas de paneles sin sacrificar integridad.
- Diferenciar claramente datos de configuración, transacción y proyección.


## 6.2 Convenciones físicas

| Convención | Decisión |
| --- | --- |
| Nombres | snake_case en tablas, columnas, índices y restricciones. |
| Identificadores | UUID generados por la aplicación; IDs públicos separados cuando se requiera formato legible. |
| Fechas | timestamptz en UTC; presentación en zona de Ecuador. |
| Montos | bigint en centavos/centésimas; nunca float o double. |
| Estados | Enums controlados o tablas de referencia; historial en tablas de eventos de estado. |
| Borrado | No borrar operaciones financieras, tickets, resultados ni eventos; usar estado y auditoría. |
| Versionado | rule_version_id obligatorio en eventos y boletos. |
| Auditoría | created_at, updated_at cuando proceda; actor y correlation_id en acciones críticas. |


## 6.3 Dominios y tablas

| Dominio | Tabla | Responsabilidad |
| --- | --- | --- |
| Identidad | users | Cuenta principal, estado y credenciales de referencia. |
| Identidad | user_profiles | Datos personales y contacto. |
| Identidad | roles | Cliente, Vendedor, Administrador y permisos extensibles. |
| Identidad | permissions | Acciones autorizables. |
| Identidad | user_roles | Roles asignados y vigencia. |
| Identidad | role_permissions | Permisos por rol. |
| Identidad | sessions | Sesiones activas, modo y dispositivo. |
| Identidad | refresh_tokens | Tokens rotables almacenados mediante hash. |
| Identidad | devices | Dispositivos y metadatos de seguridad. |
| Identidad | login_attempts | Intentos y bloqueos. |
| Identidad | password_resets | Recuperación de contraseña. |
| Identidad | verification_tokens | Verificación de correo/teléfono. |
| Identidad | terms_versions | Versiones de términos y privacidad. |
| Identidad | terms_acceptances | Aceptación trazable. |
| Finanzas | wallets | Wallet por usuario y unidad REAL/VIRTUAL. |
| Finanzas | ledger_accounts | Cuentas contables de usuarios, eventos y plataforma. |
| Finanzas | ledger_transactions | Cabecera de operación financiera. |
| Finanzas | ledger_entries | Débitos y créditos balanceados. |
| Finanzas | wallet_balance_projections | Saldo materializado derivado del libro. |
| Finanzas | idempotency_keys | Deduplicación de comandos y respuestas. |
| Finanzas | real_topups | Recargas simuladas o confirmadas por proveedor. |
| Finanzas | payment_provider_events | Webhooks y eventos externos deduplicados. |
| Finanzas | virtual_to_real_conversions | Conversión con comisión del 10%. |
| Finanzas | withdrawal_requests | Solicitud y estado de retiro real. |
| Finanzas | virtual_transfers | Transferencias internas entre usuarios permitidos. |
| Vendedores | vendor_profiles | Estado, métricas y configuración del vendedor. |
| Vendedores | vendor_inventory_batches | Lotes virtuales adquiridos a costo 0,90. |
| Vendedores | vendor_purchase_orders | Compra mayorista de saldo virtual. |
| Vendedores | conversion_requests | Solicitud de Cliente para real→virtual. |
| Vendedores | conversion_assignments | Asignación atómica a vendedor. |
| Vendedores | conversion_request_events | Historial de estados y acciones. |
| Vendedores | vendor_sales | Venta realizada y costo del inventario. |
| Vendedores | related_account_flags | Vínculos y alertas antifraude. |
| Lotería | lottery_products | Octal, Decimal y Hexadecimal. |
| Lotería | rule_versions | Reglas inmutables por producto. |
| Lotería | prize_rule_versions | Premio mayor, devolución y política económica. |
| Lotería | event_templates | Autogenerador por producto. |
| Lotería | template_schedules | Horarios, días, frecuencia y anticipación. |
| Lotería | draw_events | Evento concreto de sorteo. |
| Lotería | draw_event_status_history | Historial de estados. |
| Lotería | event_financial_configs | Precio, premio inicial, techo, meta mínima y redondeo. |
| Lotería | event_combinations | Catálogo único disponible/reservado/vendido. |
| Lotería | combination_numbers | Valores normalizados cuando se requiera búsqueda relacional. |
| Compra | purchase_sessions | Sesión de compra y caducidad. |
| Compra | shopping_carts | Carrito activo. |
| Compra | cart_items | Combinaciones añadidas. |
| Compra | combination_reservations | Reserva de cinco minutos. |
| Compra | purchase_orders | Orden de compra idempotente. |
| Compra | tickets | Boleto pagado e inmutable. |
| Compra | ticket_numbers | Números/símbolos seleccionados. |
| Compra | ticket_status_history | Historial del boleto. |
| Fondos | guarantee_fund | Metadatos del fondo general. |
| Fondos | guarantee_fund_reservations | Cobertura bloqueada por evento. |
| Fondos | future_prize_fund | Fondo de premios futuros. |
| Fondos | accumulation_pools | Acumulados pendientes por producto. |
| Fondos | accumulation_transfers | Transferencia a evento receptor. |
| Fondos | fund_movements | Motivo y relación con asientos contables. |
| Resultado | draw_commitments | Commitment, semilla cifrada y versión. |
| Resultado | draw_snapshots | Hash del conjunto congelado de boletos. |
| Resultado | draw_results | Resultado inmutable y timestamps. |
| Resultado | draw_result_numbers | Números ganadores y orden visual. |
| Resultado | ticket_evaluations | Aciertos y categoría por boleto. |
| Resultado | prize_awards | Premios y devoluciones calculados. |
| Resultado | award_payment_orders | Acreditación idempotente al publicar informe. |
| Resultado | result_reports | Informe, estado, hash y archivo. |
| Sistema | outbox_events | Eventos de dominio pendientes de publicación. |
| Sistema | inbox_events | Mensajes consumidos y deduplicados. |
| Sistema | scheduled_jobs | Trabajos persistentes programados. |
| Sistema | job_runs | Intentos, resultados y errores. |
| Sistema | audit_events | Auditoría administrativa y de seguridad. |
| Sistema | security_events | Alertas, patrones y bloqueos. |
| Sistema | notifications | Mensajes opcionales al usuario. |
| Sistema | system_settings | Configuración operativa no histórica. |


## 6.4 Restricciones críticas

| Restricción | Clave/condición | Objetivo |
| --- | --- | --- |
| uq_event_combination | draw_event_id + normalized_key | Impide vender o crear dos veces la misma combinación. |
| uq_ticket_event_combination | draw_event_id + normalized_key | Defensa adicional en boletos pagados. |
| uq_prize_payment | draw_event_id + ticket_id + award_category | Impide premio duplicado. |
| uq_conversion_completion | conversion_request_id | Solo un vendedor o la plataforma completa la solicitud. |
| uq_result_event | draw_event_id | Un único resultado fijado por evento. |
| uq_template_slot | template_id + scheduled_at | Evita autogenerar el mismo evento dos veces. |
| ledger_balanced | Suma de débitos = suma de créditos por transacción y unidad | Evita creación o desaparición contable. |
| ticket_rule_match | ticket.rule_version_id = event.rule_version_id | Evita boleto ligado a reglas incorrectas. |
| valid_reservation | expires_at > created_at y estado permitido | Reserva temporal coherente. |
| nonnegative_projection | Saldos disponibles no negativos salvo cuentas autorizadas | Evita sobregiro accidental. |


## 6.5 Índices recomendados

- draw_events(product_id, status, sales_open_at, sales_close_at).
- event_combinations(draw_event_id, status, normalized_key).
- combination_numbers(draw_event_id, value, combination_id) para búsqueda parcial.
- tickets(user_id, purchased_at desc), tickets(draw_event_id, status).
- conversion_requests(status, expires_at), conversion_requests(client_id, created_at desc).
- ledger_entries(account_id, created_at), ledger_transactions(correlation_id).
- audit_events(actor_user_id, created_at), audit_events(resource_type, resource_id).
- scheduled_jobs(status, run_at), outbox_events(status, created_at).


## 6.6 Migraciones y datos iniciales

- Cada migración debe ejecutarse automáticamente en desarrollo y de forma controlada en producción.
- No editar migraciones ya aplicadas; crear una nueva migración compensatoria.
- Los seeds crean roles, permisos, productos, cuentas de plataforma, parámetros base y usuarios de demostración solo fuera de producción.
- Toda migración financiera incluye plan de rollback o estrategia de avance seguro.
- Cambios que bloqueen tablas grandes se prueban primero con volumen simulado.


# 7. LIBRO CONTABLE, WALLETS Y FONDOS


## 7.1 Modelo de doble entrada

Cada operación financiera crea una transacción con al menos dos asientos. Para cada unidad monetaria, la suma de débitos debe igualar la suma de créditos. Los saldos visibles son proyecciones del libro y pueden reconstruirse.

```text
Transacción: compra de boleto por 1,00 virtual
Débito   Wallet virtual del Cliente        100
Crédito  Fondo virtual del evento          100
Balance                                      0
```


## 7.2 Cuentas mínimas de plataforma

| Cuenta | Unidad | Uso |
| --- | --- | --- |
| PLATFORM_REAL_CASH | REAL | Real recibido por recargas y conversiones automáticas. |
| PLATFORM_VIRTUAL_ISSUANCE | VIRTUAL | Emisión y control del virtual. |
| GENERAL_CONVERSION_WALLET | VIRTUAL | Respaldo de solicitudes no atendidas en cinco minutos. |
| CONVERSION_FEES | VIRTUAL/REAL | Comisión del 10% registrada sin mezclar unidades. |
| GUARANTEE_FUND | VIRTUAL | Cobertura general y reservas por evento. |
| FUTURE_PRIZE_FUND | VIRTUAL | 15% destinado a premios futuros. |
| ACCUMULATION_POOL_OCTAL | VIRTUAL | Acumulados pendientes Octales. |
| ACCUMULATION_POOL_DECIMAL | VIRTUAL | Acumulados pendientes Decimales. |
| ACCUMULATION_POOL_HEX | VIRTUAL | Acumulados pendientes Hexadecimales. |
| PLATFORM_OPERATIONS | VIRTUAL/REAL | Margen y costos operativos por unidad. |
| ROUNDING_ADJUSTMENTS | VIRTUAL | Diferencias de redondeo. |


## 7.3 Operaciones contables obligatorias

| Operación | Flujo | Regla |
| --- | --- | --- |
| Recarga real | Proveedor/entrada → wallet REAL del usuario | Sin comisión de negocio. |
| Compra mayorista vendedor | REAL vendedor → plataforma; emisión VIRTUAL → vendedor | Costo 0,90 por 1,00. |
| Solicitud por vendedor | REAL reservado Cliente → Vendedor; VIRTUAL Vendedor → Cliente | Ganancia realizada 0,10. |
| Solicitud por plataforma | REAL reservado Cliente → plataforma; VIRTUAL general → Cliente | Se completa a los cinco minutos. |
| Virtual a real | VIRTUAL usuario → plataforma; REAL plataforma → usuario | 10% de comisión. |
| Compra de boleto | VIRTUAL Cliente → fondo del evento | Boleto y combinación se confirman en la misma operación. |
| Premio/devolución | Obligación del evento/fondo → VIRTUAL Cliente | Al publicar informe. |
| Cancelación | Fondo del evento → wallets VIRTUAL de compradores | Reembolso íntegro. |
| Acumulado | Premio no entregado → pool del producto → evento receptor | Solo si se cumple meta mínima. |


## 7.4 Proyección de saldo

- La API puede mantener una tabla de saldo materializado para consultas rápidas.
- La escritura principal ocurre en el libro; la proyección se actualiza en la misma transacción o mediante un proceso idempotente.
- Una tarea de reconciliación compara proyección y suma del libro.
- Si el movimiento existe pero la proyección no se actualizó, se corrige la proyección; no se crea otra transacción.
- Los paneles deben distinguir disponible, reservado, pendiente, bloqueado y en retiro.


## 7.5 Fondo general de garantía

El fondo es general, pero cada evento reserva una parte antes de publicarse. La cobertura reservada no puede utilizarse en otro evento. El saldo mínimo requerido es la suma del fondo base de emergencia más todas las obligaciones reservadas.

```text
mínimo_requerido = fondo_base_emergencia + Σ(reservas_eventos_activos)
saldo_disponible = saldo_total - Σ(reservas_eventos_activos)
```

- Si el fondo cae bajo el mínimo, se transfieren primero ganancias disponibles del sistema.
- Administradores autorizados pueden aportar fondos con motivo y auditoría.
- Se suspende la publicación automática de eventos sin cobertura.
- Eventos futuros sin ventas se cancelan o no se publican; se regeneran cuando se restablece cobertura.
- Las ventas de cada evento recuperan primero el adelanto de garantía antes de incrementar el premio.


# 8. ARQUITECTURA DEL BACKEND Y API


## 8.1 Módulos

| Módulo | Responsabilidad |
| --- | --- |
| auth | Registro, login, refresh, logout, recuperación y modo activo. |
| users | Perfil, estado, roles, dispositivos y términos. |
| authorization | RBAC, políticas por recurso y permisos administrativos. |
| wallets | Consultas de saldos y proyecciones. |
| ledger | Transacciones, asientos, reconciliación e idempotencia. |
| topups | Recargas reales simuladas o externas. |
| conversions | Virtual→real, comisión y retiros. |
| transfers | Transferencia virtual entre usuarios permitidos. |
| vendors | Perfil, inventario, compra mayorista, métricas y ganancias. |
| conversion-requests | Solicitudes, asignación, confirmación y fallback a cinco minutos. |
| lottery-products | Productos y versiones de reglas. |
| event-templates | Autogenerador, horarios y anticipación. |
| draw-events | Estados, ventas, cancelaciones y publicación. |
| combinations | Catálogo, normalización, búsquedas parciales y disponibilidad. |
| purchase-sessions | Sesiones, carritos y temporizadores. |
| reservations | Reserva de cinco minutos y liberación. |
| tickets | Compra, comprobantes, filtros e historial. |
| prize-engine | Premio inicial, crecimiento, techo, devolución y meta mínima. |
| funds | Garantía, acumulados, premios futuros y operaciones. |
| draw-engine | Commit-reveal, snapshot, resultado y validación. |
| evaluations | Comparación de boletos y categorías. |
| reports | Boletín público, archivo y publicación. |
| notifications | Avisos no críticos y preferencias. |
| audit | Auditoría administrativa y técnica. |
| risk | Rate limit, cuentas relacionadas y alertas. |
| health | Estado de base, Redis, workers y storage. |


## 8.2 Contratos y validación

- Todos los endpoints usan DTO de entrada y salida explícitos.
- Los esquemas compartidos pueden publicarse en packages/contracts, pero el backend conserva la validación definitiva.
- Los errores usan código estable, mensaje legible, correlation_id y detalles no sensibles.
- La API se versiona como /api/v1.
- OpenAPI se genera automáticamente y se revisa como parte de CI.
- Las fechas se transmiten en ISO 8601 con zona; los montos se transmiten como enteros o cadenas decimales seguras, no floats.


## 8.3 Modelo de error

```text
{
  "status": 409,
  "code": "COMBINATION_NOT_AVAILABLE",
  "message": "La combinación ya no está disponible.",
  "correlationId": "...",
  "details": {
    "eventId": "...",
    "replacementAllowed": true
  }
}
```


## 8.4 Autenticación y sesiones

- Contraseñas con hash robusto y salt; nunca se almacenan ni devuelven en texto.
- Access token de vida corta y refresh token rotatorio.
- Web: refresh token en cookie HttpOnly, Secure y SameSite apropiado.
- Móvil: refresh token en almacenamiento seguro del sistema.
- Tokens de refresh almacenados mediante hash y revocables por dispositivo.
- Administradores con autenticación reforzada y recomendación de MFA.
- La sesión guarda modo activo; cada endpoint comprueba permiso y modo.


## 8.5 Idempotencia

Los comandos financieros y críticos aceptan una clave de idempotencia. La API guarda la clave, el hash del cuerpo y la respuesta. Repetir la misma clave con otro cuerpo se rechaza.

| Operación | Clave sugerida |
| --- | --- |
| Compra de boleto | user_id + client_request_id |
| Conversión virtual→real | user_id + conversion_request_uuid |
| Confirmación vendedor | conversion_request_id + vendor_id |
| Fallback plataforma | conversion_request_id + PLATFORM |
| Acreditación de premio | event_id + ticket_id + category |
| Recarga externa | provider + provider_event_id |
| Cancelación/reembolso | event_id + ticket_id + REFUND |


## 8.6 Transacciones y bloqueos

- Compra: bloquear combinación, validar reserva, débito, boleto y cambio a VENDIDA en una sola transacción.
- Solicitud: bloquear fila de solicitud; solo un vendedor o plataforma puede completar.
- Resultado: bloquear evento; verificar que no exista resultado; fijar una sola vez.
- Premio: restricción única y transacción contable.
- Fondo: bloquear reserva y cuentas relacionadas al asignar cobertura.
- Usar SELECT FOR UPDATE, restricciones únicas y nivel de aislamiento adecuado; no confiar solo en locks Redis.


# 9. PROCESOS ASÍNCRONOS, COLAS Y TIEMPO DEL SERVIDOR


## 9.1 Trabajos principales

| Trabajo | Función |
| --- | --- |
| event-template-expand | Genera eventos futuros sin duplicados. |
| event-open-sales | Abre ventas en la fecha oficial. |
| purchase-session-expire | Cierra sesiones caducadas. |
| reservation-expire | Libera combinaciones tras cinco minutos. |
| conversion-request-expire-or-fallback | Completa con plataforma al cumplirse cinco minutos. |
| event-close-sales | Cierra diez minutos antes del sorteo. |
| event-freeze | Resuelve reservas y crea snapshot de boletos. |
| draw-generate | Genera y fija resultado verificable. |
| ticket-evaluate | Calcula ganador y devoluciones. |
| report-publish | Publica boletín en la hora oficial. |
| award-credit | Acredita premios idempotentes. |
| no-winner-distribution | Distribuye 50/25/15/10 cuando corresponde. |
| accumulation-attach | Añade acumulado a evento receptor. |
| ledger-reconcile | Verifica asientos y proyecciones. |
| fund-reconcile | Comprueba mínimo y reservas. |
| report-render | Genera PDF/imagen/JSON del boletín. |
| notification-dispatch | Envía avisos opcionales. |


## 9.2 Reglas de ejecución

- Cada trabajo posee job_id único, correlation_id, número de intento y estado persistido.
- Reintentos automáticos para errores temporales; errores de regla no se reintentan ciegamente.
- Los trabajos financieros son idempotentes y verifican si el efecto ya existe.
- La hora del servidor y la base de datos son la autoridad; los contadores del cliente son informativos.
- Las tareas críticas no dependen de que una página esté abierta.
- El reinicio del worker no pierde trabajos persistentes.


## 9.3 Reloj y zona horaria

- Guardar en UTC y mostrar en America/Guayaquil.
- Sincronizar servidores mediante un servicio horario confiable.
- Registrar fecha programada y fecha real de cada transición.
- No usar Date.now del dispositivo para autorizar compras.
- Los tests deben congelar el tiempo y probar bordes exactos.


# 10. MOTOR DE LOTERÍA, COMBINACIONES Y COMPRAS


## 10.1 Reglas matemáticas

| Producto | Universo | Selección exacta | Combinaciones |
| --- | --- | --- | --- |
| Octal | 0–7 | 4 números únicos | 70 |
| Decimal | 0–9 | 5 números únicos | 252 |
| Hexadecimal | 0–9 y A–F | 6 símbolos únicos | 8 008 |


## 10.2 Normalización

El orden no distingue combinaciones. La clave se crea validando, normalizando letras a mayúsculas, eliminando repetidos, ordenando según el universo y uniendo con un separador estable.

```text
Entrada: ["F", "2", "A", "0", "9", "4"]
Normalizada: ["0", "2", "4", "9", "A", "F"]
Clave: 0-2-4-9-A-F
```


## 10.3 Catálogo por evento

- Al crear el evento se generan todas sus combinaciones.
- Cada registro inicia DISPONIBLE.
- La búsqueda parcial filtra combinaciones DISPONIBLES que contengan todos los valores fijados.
- La compra rápida elige aleatoriamente entre coincidencias disponibles.
- El catálogo permite contar disponibilidad real, declarar AGOTADO y evitar repetición.


## 10.4 Formas de compra

| Modo | Entrada del Cliente | Respuesta del sistema |
| --- | --- | --- |
| Aleatoria completa | Ningún número | Reserva una combinación disponible aleatoria. |
| Lista compatible | Algunos números | Devuelve opciones paginadas que contienen los valores. |
| Completar al azar | Algunos números | Completa faltantes y reserva una opción disponible. |
| Verificación completa | Cantidad exacta | Normaliza, verifica y reserva si está disponible. |
| Múltiples boletos | Cantidad y condiciones | Genera/reserva opciones distintas respetando límites. |


## 10.5 Límite dinámico

```text
límite_inicial = floor(combinaciones_totales × 0.20)
instante_base = apertura + 0.80 × (cierre - apertura)
instante_liberación = redondear_a_00_o_30(instante_base)
```

| Minuto calculado | Redondeo |
| --- | --- |
| 00–14 | Baja a :00 |
| 15–45 | Se fija en :30 |
| 46–59 | Sube a la siguiente :00 |

- Antes de la liberación se cuentan boletos pagados más reservas activas del Cliente.
- Después de la liberación desaparece el límite porcentual, no las validaciones técnicas.
- No existe límite diario general entre eventos.
- Puede existir un tamaño técnico de carrito para evitar reservar miles de combinaciones en una sola operación.


## 10.6 Sesión y reserva

| Fase | Sesión máxima | Contador |
| --- | --- | --- |
| Fase inicial | mínimo de 25 minutos o 10% de la ventana | Oculto al inicio; visible al quedar 5 min. |
| Último 20% | 10 minutos | Visible. |
| 30 minutos o menos al cierre | 5 minutos | Visible. |
| Regla superior | Nunca supera el tiempo restante al cierre | El backend rechaza fuera de hora. |

> **Decisión obligatoria:** La reserva de cada combinación dura exactamente cinco minutos desde que se añade al carrito, independientemente de que la sesión sea más larga.


## 10.7 Flujo transaccional

```text
1. Autenticar y autorizar modo Cliente.
2. Bloquear/validar evento y hora.
3. Validar límite dinámico.
4. Validar reserva vigente y propiedad.
5. Bloquear combinación.
6. Verificar saldo virtual.
7. Crear transacción contable de compra.
8. Crear boleto y números.
9. Marcar combinación VENDIDA.
10. Confirmar y emitir comprobante.

Todo ocurre o nada ocurre.
```


# 11. MOTOR ECONÓMICO, PREMIOS Y ACUMULADOS


## 11.1 Componentes del premio

```text
premio_total_actual =
    premio_inicial_garantizado
  + crecimiento_por_ventas
  + acumulado_extraordinario
```

- El multiplicador inicial sugerido es cinco veces el precio del boleto y puede configurarse con cobertura.
- El acumulado extraordinario ya está financiado y se muestra separado.
- El techo limita el componente financiado por ventas del evento, no el acumulado heredado.


## 11.2 Excedente y crecimiento

```text
excedente_elegible =
    ventas_confirmadas
  - premio_inicial_pendiente_de_recuperar
  - reserva_de_devoluciones
  - recuperación_de_garantía
  - reservas_y_costos_aplicables

crecimiento = max(0, excedente_elegible × 0.90)
premio_financiado_evento = min(premio_inicial + crecimiento, techo)
```


## 11.3 Techo recomendado

El panel administrativo debe calcular en ambos sentidos: precio mínimo para un premio/techo ingresado, y premio/techo sostenible para un precio ingresado. Debe mostrar escenarios conservador, esperado y agotado, además de fondo adicional requerido.

| Semáforo | Interpretación | Acción |
| --- | --- | --- |
| Verde | Cubierto en escenario conservador | Puede publicarse. |
| Amarillo | Depende de meta mínima o garantía | Revisar y reservar cobertura. |
| Rojo | Insolvente con cobertura actual | Bloquear publicación. |


## 11.4 Devolución

Todo boleto que acierte todos menos uno recibe el precio base pagado como saldo virtual. La obligación se calcula sobre boletos vendidos y se reserva antes de destinar excedente al crecimiento. No es una devolución voluntaria del boleto, sino un premio secundario.

| Producto | Máximo matemático de combinaciones a un acierto |
| --- | --- |
| Octal | 4 × (8−4) = 16 |
| Decimal | 5 × (10−5) = 25 |
| Hexadecimal | 6 × (16−6) = 60 |


## 11.5 Redondeo

| Parte decimal exacta | Premio publicado/acreditado |
| --- | --- |
| 0,00–0,12 | 0,00 |
| 0,13–0,37 | 0,25 |
| 0,38–0,62 | 0,50 |
| 0,63–0,87 | 0,75 |
| 0,88–0,99 | Siguiente dólar |

- El valor exacto se conserva para auditoría.
- El premio anunciado y acreditado deben coincidir.
- La diferencia hacia arriba usa el margen operativo del 10%.
- La diferencia hacia abajo pasa al fondo de garantía.


## 11.6 Evento sin ganador

| Condición | Distribución |
| --- | --- |
| Meta mínima alcanzada | 50% acumulado; 25% garantía; 15% premios futuros; 10% operación. |
| Meta mínima no alcanzada | No genera 50% acumulado; paga devoluciones, repone garantía y cubre obligaciones. |

El acumulado se añade al siguiente evento cronológico del mismo producto que aún no haya generado resultado, aunque ya esté publicado o en venta. Solo aumenta el premio y se registra como acumulado extraordinario. Si el receptor se cancela, vuelve al pool del producto.


# 12. RESULTADO VERIFICABLE, EVALUACIÓN E INFORMES


## 12.1 Cierre y congelación

- Las ventas cierran exactamente diez minutos antes de la hora del sorteo.
- Se rechazan nuevas reservas y confirmaciones.
- Se resuelven transacciones en curso según la hora de confirmación del servidor.
- Se congela la lista de boletos activos y se calcula un hash determinista.
- El evento pasa a un estado que impide cancelación y edición.


## 12.2 Compromiso y revelación

```text
Antes del cierre:
commitment = SHA-256(secret_seed + event_id + rule_version + close_at)

Al cerrar:
snapshot_hash = SHA-256(serialización_determinista_de_boletos)
final_seed = SHA-256(secret_seed + event_id + rule_version + close_at + snapshot_hash)

La semilla final alimenta un generador determinista que selecciona sin reemplazo.
```

- La semilla secreta se genera con un generador criptográfico seguro.
- El commitment se publica antes de conocer el resultado final.
- El resultado candidato se valida antes de fijarse.
- Una vez fijado, nunca se regenera.
- Después se revelan semilla y hashes necesarios para verificación pública.


## 12.3 Animación

- El resultado completo existe antes de la animación.
- Se revela un número cada tres a cinco segundos.
- El usuario puede saltar la animación y ver el resultado completo.
- Recargar puede volver a reproducir la animación, pero conserva el mismo resultado.
- El cliente puede recibir el resultado en una sola respuesta y animarlo localmente, reduciendo llamadas.


## 12.4 Evaluación y acreditación

```text
RESULTADO_FIJADO
  → EVALUACIÓN_DE_BOLETOS
  → ÓRDENES_DE_PREMIO
  → INFORME_PREPARADO
  → INFORME_PUBLICADO
  → ACREDITACIONES_CONFIRMADAS
  → EVENTO_FINALIZADO
```

Los premios y devoluciones se acreditan como saldo virtual al publicarse el informe. La clave única evento+boleto+categoría impide pagos dobles. Si el asiento existe pero el saldo materializado no se actualizó, se repara la proyección y no se crea otro premio.


## 12.5 Boletín público

| Debe mostrar | No debe mostrar |
| --- | --- |
| Producto, ID, fecha, hora, números ganadores, precio, premio inicial, crecimiento, acumulado, premio total, cantidad de ganadores, devoluciones, total pagado, próximo acumulado, hash y estado. | Nombre, usuario, correo, documento, teléfono, wallet o datos personales del ganador. |

El informe se genera en JSON como fuente estructurada y puede renderizarse a HTML, PDF e imagen. El archivo se almacena con hash y versión de plantilla.


# 13. PLATAFORMA WEB


## 13.1 Arquitectura frontend

- Next.js con App Router y TypeScript.
- Componentes por dominio, no una página monolítica por rol.
- Server Components para contenido público y consultas iniciales cuando aporte rendimiento.
- Client Components para formularios, selección, carrito y tiempo real.
- Cliente API tipado compartido con móvil.
- Manejo de estado remoto mediante una librería de consultas; estado local solo para interfaz.
- Diseño responsive y accesible desde el inicio.


## 13.2 Áreas públicas

| Ruta funcional | Contenido |
| --- | --- |
| Inicio | Descripción, productos, funcionamiento, seguridad, premios actuales y acceso. |
| Eventos públicos | Listado por Octal, Decimal y Hexadecimal. |
| Resultados | Boletines, filtros y verificación. |
| Verificar resultado | Commitment, semilla, snapshot y reproducción de verificación. |
| Reglas y transparencia | Reglamento, comisiones, fondos y política de cancelación. |
| Autenticación | Login, registro, recuperación y verificación. |


## 13.3 Panel Cliente

| Vista | Contenido |
| --- | --- |
| Resumen | Saldos, próximos eventos, boletos activos y premios recientes. |
| Jugar | Selector por producto y tarjetas de todos los eventos comprables. |
| Evento | Premio, techo, disponibilidad, tabla de números y formas de compra. |
| Carrito | Reservas, expiración, precio total y confirmación. |
| Boletos | Filtros por fecha, producto, evento y estado. |
| Resultados | Animación, boletín y comprobación. |
| Wallet | Real, virtual, reservado, movimientos y recargas. |
| Solicitar virtual | Solicitud real→virtual y progreso de cinco minutos. |
| Convertir a real | Comisión del 10% y confirmación. |
| Transferir | Envío virtual a otros clientes. |
| Perfil y seguridad | Datos, contraseña, dispositivos y sesiones. |


## 13.4 Panel Vendedor

| Vista | Contenido |
| --- | --- |
| Resumen | Real, virtual, reservado, capital, inventario y ganancia realizada. |
| Comprar virtual | Compra mayorista 0,90→1,00. |
| Solicitudes disponibles | Solo solicitudes compatibles con saldo y políticas. |
| Solicitud en proceso | Temporizador absoluto, confirmar o cancelar. |
| Historial de ventas | Costo, ingreso y ganancia por operación. |
| Conversiones y retiros | Virtual→real con 10%, real y retiros. |
| Movimientos | Libro filtrado y comprobantes. |
| Perfil | Datos, seguridad y modo activo. |


## 13.5 Panel Administrador

| Módulo | Contenido |
| --- | --- |
| Dashboard | Usuarios, eventos, ventas, fondos, colas, alertas y salud. |
| Usuarios y roles | Activar, suspender, asignar rol y revisar alertas. |
| Productos y versiones | Reglas versionadas; no editar versiones usadas. |
| Autogeneradores | Horarios, frecuencia, anticipación y multiplicador. |
| Eventos | Borradores, publicados, ventas, cancelación y estados. |
| Simulador económico | Precio, premio, techo, meta, escenarios y cobertura. |
| Fondos | Garantía, reservas, acumulados, premios futuros y aportes. |
| Sorteo | Commitment, snapshot, resultado, validación e informe. |
| Solicitudes | Estado, fallback, liquidez y anomalías. |
| Finanzas | Libro, conciliación, ajustes y reportes. |
| Auditoría y riesgo | Acciones, intentos, cuentas relacionadas y bloqueos. |
| Configuración operativa | Parámetros no históricos, plantillas y límites técnicos. |


## 13.6 Requisitos UX

- La navegación principal del Cliente debe priorizar Inicio, Jugar, Boletos, Wallet y Perfil.
- Mostrar hora oficial y cierre en cada evento.
- Mostrar límite actual, compras del usuario y hora de liberación.
- Mostrar reservas con contador de cinco minutos.
- No usar notificaciones como único mecanismo de estado; toda información debe estar disponible dentro de la app.
- Mensajes de error específicos con acciones de recuperación.
- Teclado, lector de pantalla, contraste y tamaños táctiles adecuados.


# 14. APLICACIÓN MÓVIL


## 14.1 Alcance inicial

La primera aplicación móvil cubre Cliente y Vendedor. La administración completa permanece en web por seguridad y complejidad, aunque pueden existir vistas de consulta administrativa en una fase futura.


## 14.2 Navegación Cliente

```text
Tabs inferiores:
Inicio | Jugar | Boletos | Wallet | Perfil

Flujos modales/pila:
Evento → Selección → Opciones → Carrito → Confirmación → Boleto
Wallet → Solicitud real/virtual → Estado
Boletos → Detalle → Resultado/boletín
```


## 14.3 Navegación Vendedor

```text
Tabs inferiores:
Resumen | Solicitudes | Inventario | Movimientos | Perfil

Flujos:
Solicitud → Tomar → Confirmar/Cancelar
Inventario → Comprar virtual
Wallet → Convertir/Retirar
```


## 14.4 Almacenamiento y seguridad móvil

- Tokens sensibles en SecureStore/Keychain/Keystore.
- No guardar saldos, roles o boletos como fuente de verdad.
- Caché local solo para mejorar lectura; se invalida contra API.
- Bloqueo biométrico opcional para abrir la aplicación, no como sustituto de autenticación del servidor.
- Protección contra screenshots en pantallas sensibles opcional según plataforma.
- Deep links validados; nunca ejecutar operaciones financieras solo por abrir un enlace.


## 14.5 Operación con conectividad limitada

| Situación | Comportamiento |
| --- | --- |
| Sin conexión al navegar | Mostrar caché marcada como desactualizada y bloquear acciones sensibles. |
| Se pierde conexión durante compra | Consultar estado de la idempotency key al reconectar. |
| Se pierde conexión durante solicitud | La tarea del servidor continúa; la app recupera estado. |
| Se pierde conexión durante animación | Al reconectar, recuperar el resultado inmutable y reproducir/saltar. |
| Pago ambiguo | Mostrar procesando y consultar backend; no repetir automáticamente con nueva clave. |


## 14.6 Notificaciones

Las notificaciones push son complementarias. Pueden avisar solicitud completada, evento próximo, resultado publicado o premio acreditado. Ninguna operación depende de recibir una notificación; el estado siempre se consulta en la aplicación.


# 15. SEGURIDAD, PRIVACIDAD Y ANTIFRAUDE


## 15.1 Modelo de amenazas

| Amenaza | Control principal |
| --- | --- |
| Manipular rol o modo | Validación backend por permiso y sesión. |
| Modificar saldo local | No aceptar saldo enviado por el cliente; libro contable autoritativo. |
| Comprar combinación vendida | Reserva, lock de fila y restricción única. |
| Doble clic o reintento | Idempotency key y respuesta persistida. |
| Confirmación simultánea vendedor/plataforma | Lock y unicidad por solicitud. |
| Cambiar hora del dispositivo | Hora del servidor. |
| Modificar resultado | Commit-reveal, hash, inmutabilidad y auditoría. |
| Pagar premio dos veces | Clave única evento+boleto+categoría. |
| Vendedor atiende cuenta propia | Políticas de relación y bloqueo. |
| Automatización masiva | Rate limiting, tamaño de carrito, riesgo y desafío progresivo. |
| Acceso a datos personales | Permisos, minimización, cifrado y auditoría. |
| Robo de token | Rotación, revocación, cookies seguras y almacenamiento móvil seguro. |


## 15.2 Controles de aplicación

- Validación de entrada y salida.
- Protección CSRF para flujos web basados en cookies.
- CORS restrictivo.
- Cabeceras de seguridad y política de contenido.
- Rate limit por IP, usuario, dispositivo y operación.
- Bloqueo progresivo de login y detección de credenciales repetidas.
- MFA recomendado/obligatorio para administradores de fondos y cancelación.
- Cifrado en tránsito y cifrado de secretos o semillas en reposo.
- No registrar contraseñas, tokens, documentos completos ni datos de tarjeta.
- Validar archivos y limitar tamaño/tipo.


## 15.3 Auditoría

Toda acción crítica registra actor, modo, permiso, recurso, valores antes/después cuando corresponda, motivo, IP aproximada, dispositivo, correlation_id y fecha. La auditoría no es una bitácora visible de clics del Cliente; es un registro técnico de operaciones importantes.

| Acción auditada | Datos mínimos |
| --- | --- |
| Cambio de rol/estado | Actor, usuario afectado, antes, después, motivo. |
| Aporte o uso de fondos | Cuenta, monto, origen, destino, saldo antes/después. |
| Publicación/cancelación de evento | Evento, regla, motivo, boletos y cobertura. |
| Resultado | Commitment, snapshot, semilla, hashes y validaciones. |
| Reintento financiero manual | Transacción original, evidencia y resultado. |
| Acceso administrativo sensible | Actor, módulo, filtros y exportación. |


## 15.4 Privacidad

- Recoger solo datos necesarios para identidad, seguridad y operación.
- Separar información pública de datos personales.
- El boletín nunca revela identidad del ganador.
- Definir retención y anonimización para datos que puedan eliminarse legalmente.
- Los registros financieros y de auditoría se conservan según necesidad normativa y académica.
- Exportaciones administrativas deben estar protegidas y registradas.


# 16. PRUEBAS Y ASEGURAMIENTO DE CALIDAD


## 16.1 Pirámide de pruebas

| Nivel | Herramienta sugerida | Cobertura |
| --- | --- | --- |
| Unitarias | Jest/Vitest | Reglas puras, dinero, combinaciones, estados y permisos. |
| Propiedad | fast-check o equivalente | Invariantes matemáticos y contables. |
| Integración | Jest + PostgreSQL/Redis de prueba | Repositorios, transacciones, locks y jobs. |
| Contrato | OpenAPI + cliente generado | Compatibilidad API/web/móvil. |
| E2E web | Playwright | Flujos por rol y responsive. |
| E2E móvil | Maestro o Detox | Login, compra, solicitud y wallet. |
| Carga | k6 | Eventos concurridos, compra y resultados. |
| Seguridad | SAST, DAST y escaneo de dependencias | Vulnerabilidades y configuración. |


## 16.2 Invariantes obligatorios

- Nunca hay dos boletos con la misma combinación en un evento.
- La suma de asientos por unidad es cero.
- Un saldo disponible no cae bajo cero en cuentas de usuario.
- Una solicitud se completa una sola vez.
- Un evento tiene como máximo un resultado.
- Un boleto recibe como máximo un premio por categoría.
- El premio acreditado coincide con el boletín.
- El acumulado no se descuenta dos veces.
- El mismo fondo no se reserva simultáneamente para dos eventos.
- Ninguna compra se confirma después del cierre del servidor.


## 16.3 Casos de concurrencia

| Caso | Resultado esperado |
| --- | --- |
| Dos clientes reservan la misma combinación | Solo una reserva se confirma. |
| Dos carritos del mismo cliente superan 20% | La suma de pagados+reservas se valida bajo lock. |
| Vendedor confirma al minuto 5 exacto | Vendedor o plataforma gana una única transición. |
| Evento cierra mientras se compra | Solo órdenes confirmadas antes del cierre continúan. |
| Dos workers generan resultado | La restricción única deja uno; el otro termina sin efecto. |
| Dos procesos acreditan premio | La clave única evita duplicación. |
| Aporte y reserva de fondo simultáneos | Saldo disponible coherente mediante lock. |


## 16.4 Matriz de dispositivos

- Web: Chrome, Edge, Firefox y Safari actuales; escritorio y móvil.
- Resoluciones: 360 px, 390 px, 768 px, 1024 px, 1366 px y superiores.
- Android: versión mínima definida al iniciar Expo, más dos versiones recientes representativas.
- iOS: versión mínima compatible y dispositivos con notch/isla dinámica.
- Pruebas de accesibilidad con teclado, lector de pantalla y contraste.


## 16.5 Puertas de calidad

- No merge si fallan lint, tipos o pruebas críticas.
- No despliegue si existen migraciones incompatibles o vulnerabilidades críticas conocidas.
- No publicar evento si el simulador de cobertura está rojo.
- No liberar versión si fallan compra concurrente, idempotencia o reconciliación.
- Cada fase termina con evidencia y criterios de aceptación firmados.


# 17. INFRAESTRUCTURA, DESPLIEGUE Y OPERACIÓN


## 17.1 Contenedores

- API, worker y web se empaquetan en imágenes separadas.
- PostgreSQL, Redis y storage pueden ejecutarse en Docker Compose local.
- Las imágenes usan usuario no root, dependencias mínimas y healthchecks.
- La configuración se inyecta por entorno.
- Las migraciones se ejecutan como tarea controlada antes de activar una versión.


## 17.2 CI/CD

```text
Pull request:
  instalar → lint → tipos → unitarias → integración → build → seguridad

main:
  construir imágenes → publicar artefactos → desplegar staging → E2E

release aprobada:
  backup → migración → despliegue gradual → smoke tests → monitoreo
```


## 17.3 Estrategia de despliegue

- Despliegue gradual o blue/green cuando la infraestructura lo permita.
- API compatible hacia atrás durante la actualización de web y móvil.
- Migraciones expandir-contratar: primero agregar, luego migrar datos, finalmente retirar.
- Rollback de aplicación separado del rollback de datos.
- Feature flags para activar módulos sin publicar cambios incompletos.


## 17.4 Backups y recuperación

| Elemento | Política inicial recomendada |
| --- | --- |
| PostgreSQL | Backups automáticos, retención diaria y prueba periódica de restauración. |
| Archivos de informes | Versionado/retención en object storage. |
| Redis | No depender de Redis para reconstruir estado oficial; persistencia solo para colas. |
| Secretos | Backup cifrado y rotación controlada. |
| RPO/RTO | Definir objetivos para entorno académico y producción antes de lanzamiento. |


## 17.5 Observabilidad

- Logs JSON con correlation_id, event_id, user_id anonimizado y job_id.
- Métricas: latencia, errores, compras, reservas, colas, fondo, reconciliación y resultados.
- Trazas distribuidas API→DB→cola→worker.
- Alertas por fondo bajo mínimo, cola atrasada, conciliación fallida, resultado retrasado y error de pago.
- Dashboard operativo separado del dashboard comercial.


## 17.6 Runbooks

| Incidente | Procedimiento mínimo |
| --- | --- |
| Base de datos no disponible | Poner API en modo degradado, bloquear escrituras, restaurar y reconciliar. |
| Redis no disponible | No perder fuente de verdad; pausar trabajos y recuperar colas. |
| Worker retrasado | Escalar worker, revisar jobs vencidos y ejecutar idempotentemente. |
| Resultado no publicado | Verificar resultado fijado, reanudar evaluación/reporte; nunca regenerar. |
| Premio no proyectado | Verificar libro y reparar proyección. |
| Fondo bajo mínimo | Bloquear publicaciones, reponer y revisar reservas. |


# 18. PLAN DE CREACIÓN POR FASES

Las fases están ordenadas por dependencia. No debe iniciarse una interfaz completa antes de que sus contratos y reglas críticas estén probados en backend. Algunas tareas visuales pueden avanzar en paralelo con datos simulados, pero no se consideran terminadas hasta integrarse con la API.


## FASE 0 — Gobierno, alcance y diseño ejecutable

**Objetivo:** Convertir reglas en artefactos técnicos aprobados antes de programar.


### Actividades

- Congelar Documento Maestro de Reglas v1.0 y este Plan Técnico v1.0.
- Crear glosario de datos, estados, permisos y códigos de error.
- Documentar decisiones de arquitectura (ADR) para stack, monorepo, dinero, ledger, idempotencia y commit-reveal.
- Diseñar diagramas C4: contexto, contenedores y componentes.
- Diseñar diagramas de secuencia de compra, solicitud, sorteo, cancelación y premio.
- Crear matriz de trazabilidad regla→módulo→tabla→endpoint→prueba.
- Definir alcance de MVP académico y alcance completo.


### Entregables

- Documento de arquitectura
- Diagramas
- Matriz de permisos
- Catálogo inicial de errores
- Backlog priorizado


### Criterios de salida

- Todas las reglas críticas tienen dueño técnico y prueba prevista.
- No quedan contradicciones entre moneda, fondos, premios y vendedores.


## FASE 1 — Monorepo, calidad y entorno local

**Objetivo:** Crear una base reproducible para todos los proyectos.


### Actividades

- Inicializar pnpm workspaces y Turborepo.
- Crear apps api, worker, web y mobile.
- Crear packages compartidos.
- Configurar TypeScript strict, ESLint, Prettier y hooks de commit.
- Configurar Docker Compose con PostgreSQL, Redis y storage local.
- Configurar variables de ejemplo y gestor de secretos para entornos.
- Crear CI inicial con lint, tipos, pruebas y build.
- Crear healthcheck básico y documentación de arranque.


### Entregables

- Repositorio ejecutable
- Docker Compose
- CI verde
- README de desarrollo


### Criterios de salida

- Un nuevo desarrollador puede levantar todo con instrucciones reproducibles.
- Los cuatro proyectos compilan.


## FASE 2 — Base de datos y libro contable

**Objetivo:** Implementar el núcleo de integridad antes de exponer operaciones.


### Actividades

- Diseñar schema Prisma y SQL complementario.
- Crear tablas de identidad, roles, sesiones y términos.
- Crear ledger_accounts, ledger_transactions, ledger_entries y proyecciones.
- Crear cuentas de plataforma y fondos.
- Crear restricciones de balance y unidades.
- Implementar migraciones y seeds.
- Implementar repositorios y pruebas de transacciones.
- Crear reconciliación de saldo y reportes de discrepancia.


### Entregables

- Modelo físico v1
- Migraciones
- Seeds
- Pruebas del ledger
- Diagrama ER


### Criterios de salida

- Toda transacción de prueba balancea.
- Puede reconstruirse un saldo desde asientos.
- No se permiten montos float.


## FASE 3 — Backend base, autenticación y autorización

**Objetivo:** Crear la API segura y los contratos comunes.


### Actividades

- Configurar NestJS, validación global, OpenAPI y modelo de error.
- Implementar registro, verificación, login, refresh rotatorio y logout.
- Implementar roles, permisos, modo activo y políticas por recurso.
- Implementar recuperación de contraseña y dispositivos.
- Implementar auditoría y correlation_id.
- Implementar idempotency_keys reutilizable.
- Configurar rate limiting y cabeceras de seguridad.
- Crear cliente API tipado.


### Entregables

- API auth v1
- OpenAPI
- Matriz de permisos ejecutable
- Pruebas E2E de sesión


### Criterios de salida

- Un Vendedor no puede comprar boletos aunque cambie la URL.
- Un token revocado no funciona.
- Los permisos se prueban automáticamente.


## FASE 4 — Wallets, recargas, conversiones y retiros

**Objetivo:** Implementar las operaciones monetarias generales.


### Actividades

- Crear wallets REAL y VIRTUAL por usuario.
- Implementar recarga real simulada sin comisión.
- Implementar transferencia virtual entre clientes y prohibición de autoenvío.
- Implementar virtual→real con comisión del 10%.
- Implementar solicitud de retiro real.
- Implementar saldos disponible/reservado/pendiente.
- Agregar idempotencia y reconciliación.
- Crear panel administrativo de movimientos base.


### Entregables

- API wallets
- Libro contable operativo
- Simulador de recarga
- Pruebas de comisión


### Criterios de salida

- No hay doble conversión.
- El 10% se registra correctamente.
- La recarga acredita exactamente el monto.


## FASE 5 — Vendedores y solicitudes real→virtual

**Objetivo:** Implementar el mercado controlado entre Cliente, Vendedor y plataforma.


### Actividades

- Crear perfil de Vendedor e inventario por lotes.
- Implementar compra mayorista 0,90→1,00.
- Crear solicitudes con reserva de saldo real.
- Filtrar visibilidad por saldo y relación antifraude.
- Implementar asignación atómica.
- Implementar confirmación/cancelación sin reiniciar plazo.
- Crear job de fallback exacto a cinco minutos.
- Separar ganancia potencial y realizada.
- Implementar wallet general de conversión y alerta de liquidez.


### Entregables

- API vendedor
- Worker fallback
- Métricas de inventario/ganancia
- Pruebas de carrera


### Criterios de salida

- Vendedor y plataforma no completan dos veces.
- La solicitud libera real si falla por liquidez.
- El vendedor no atiende su propia cuenta.


## FASE 6 — Productos, versiones, autogenerador y eventos

**Objetivo:** Crear la estructura completa de sorteos y calendario.


### Actividades

- Crear productos Octal, Decimal y Hexadecimal.
- Crear versiones inmutables de reglas y premios.
- Crear plantillas del autogenerador con días, horas, frecuencia, anticipación y cierre.
- Implementar expansión de eventos futuros sin duplicados.
- Implementar estados y transiciones por hora del servidor.
- Implementar publicación y tarjetas de eventos.
- Implementar cobertura de fondo antes de publicar.
- Implementar cancelación previa a resultado y reembolso.


### Entregables

- API de productos/eventos
- Autogenerador
- Máquina de estados
- Pruebas temporales


### Criterios de salida

- Puede haber varios eventos del mismo tipo en un día.
- Una plantilla no altera eventos con ventas.
- No se publica sin cobertura.


## FASE 7 — Combinaciones, sesiones, reservas y boletos

**Objetivo:** Implementar la compra única y concurrente.


### Actividades

- Generar catálogos 70/252/8008 al crear evento.
- Implementar normalización e índices.
- Implementar búsqueda parcial paginada.
- Implementar aleatoria completa y completar al azar.
- Implementar límite 20% y liberación al 80% redondeado.
- Implementar sesiones dinámicas y reserva de cinco minutos.
- Implementar carrito de múltiples boletos.
- Implementar compra transaccional y comprobante.
- Implementar filtros y estados de boletos.


### Entregables

- API de disponibilidad/compra
- Motor de combinaciones
- Pruebas de concurrencia


### Criterios de salida

- La misma combinación nunca se vende dos veces.
- El límite incluye reservas activas.
- Comprar fuera del cierre es imposible.


## FASE 8 — Motor económico, fondos y simulador administrativo

**Objetivo:** Automatizar premio inicial, crecimiento, techo, meta y reservas.


### Actividades

- Implementar fórmulas de excedente y crecimiento 90%.
- Implementar premio inicial configurable y techo sostenible.
- Implementar responsabilidad de devoluciones.
- Implementar redondeo y cuenta de ajustes.
- Implementar fondo general y reservas por evento.
- Implementar meta mínima de capital.
- Implementar simulador conservador/esperado/agotado.
- Implementar semáforo y bloqueo de publicación insolvente.
- Implementar acumulados y fondos futuros.


### Entregables

- Motor económico probado
- Simulador admin
- Reportes de fondos


### Criterios de salida

- Todas las fórmulas tienen pruebas con valores frontera.
- El acumulado no consume techo ni se descuenta doble.
- El fondo no se sobrerreserva.


## FASE 9 — Sorteo verificable, premios e informes

**Objetivo:** Ejecutar y liquidar eventos de forma reproducible.


### Actividades

- Implementar generación de semilla, compromiso y cifrado.
- Implementar snapshot y hash de boletos.
- Implementar generador determinista sin reemplazo.
- Validar y fijar resultado inmutable.
- Implementar evaluación de ganador y devoluciones.
- Implementar órdenes de premio idempotentes.
- Implementar distribución sin ganador 50/25/15/10 condicionada.
- Implementar acumulado a evento publicado elegible.
- Generar boletín JSON/HTML/PDF/imagen sin identidad.
- Publicar informe y acreditar premios coordinadamente.


### Entregables

- Motor de sorteo
- Verificador público
- Boletín
- Pruebas de recuperación


### Criterios de salida

- Reiniciar durante animación no cambia resultado.
- Informe y premio coinciden.
- No existe doble pago.


## FASE 10 — Plataforma web completa

**Objetivo:** Construir la experiencia pública y los tres paneles.


### Actividades

- Crear design system y tokens visuales.
- Implementar landing, reglas, resultados y verificador.
- Implementar autenticación y selección de modo.
- Implementar panel Cliente y compra completa.
- Implementar panel Vendedor y solicitudes en tiempo real.
- Implementar panel Administrador y simulador.
- Implementar accesibilidad, responsive y errores.
- Implementar WebSocket/SSE y fallback.
- Realizar E2E web y auditoría de accesibilidad.


### Entregables

- Web funcional
- Design system
- E2E por rol
- Evidencia responsive


### Criterios de salida

- Todos los flujos principales funcionan sin datos simulados.
- La web no permite acciones por ocultamiento solamente.


## FASE 11 — Aplicación móvil Cliente/Vendedor

**Objetivo:** Llevar los flujos principales al teléfono sin duplicar reglas.


### Actividades

- Crear navegación, temas y cliente API.
- Implementar login, modo y almacenamiento seguro.
- Implementar Jugar, selección, carrito y boletos.
- Implementar Wallet, solicitudes y conversiones.
- Implementar panel Vendedor, inventario y solicitudes.
- Implementar resultado animado y boletines.
- Implementar manejo de red, estados ambiguos y reintentos.
- Agregar notificaciones opcionales.
- Realizar E2E móvil y pruebas de dispositivos.


### Entregables

- App Android de prueba
- Proyecto iOS preparado
- E2E móvil


### Criterios de salida

- La pérdida de red no duplica compras.
- No hay datos sensibles en almacenamiento inseguro.


## FASE 12 — Endurecimiento, rendimiento y producción

**Objetivo:** Preparar el sistema para operar de forma controlada.


### Actividades

- Ejecutar pruebas de carga y carreras.
- Revisar seguridad, dependencias y configuración.
- Configurar observabilidad, alertas y runbooks.
- Configurar backups y prueba de restauración.
- Configurar staging y despliegue gradual.
- Realizar UAT con escenarios completos.
- Crear política de versiones y rollback.
- Documentar operación, soporte y mantenimiento.


### Entregables

- Release candidate
- Informe de seguridad
- Runbooks
- Plan de recuperación


### Criterios de salida

- Se cumplen criterios globales.
- Existe evidencia de restauración.
- No quedan fallos críticos abiertos.


## FASE 13 — Entrega académica y continuidad

**Objetivo:** Relacionar el producto con la asignatura y conservar documentación.


### Actividades

- Documentar HTML/CSS, responsive y componentes.
- Documentar programación cliente, AJAX/API y tiempo real.
- Documentar backend, seguridad, estado y despliegue.
- Documentar REST y comunicación cliente-servidor.
- Preparar diagramas, videos, manuales y evidencias.
- Exportar OpenAPI, ERD, matriz de pruebas y capturas.
- Actualizar Documento Maestro y Plan Técnico con los cambios aprobados.


### Entregables

- Informe académico
- Manual técnico
- Manual de usuario
- Repositorio documentado


### Criterios de salida

- El proyecto demuestra los temas de la asignatura.
- Otra persona puede continuar el proyecto con los documentos.


# 19. CRONOGRAMA Y ESTRATEGIA DE VERSIONES


## 19.1 Estimación de esfuerzo

La duración real depende de experiencia, alcance académico y cantidad de integrantes. Las siguientes cifras son rangos de planificación, no promesas.

| Modalidad | MVP integrado | Sistema completo |
| --- | --- | --- |
| Una persona a tiempo parcial | 16–22 semanas | 32–48 semanas |
| Dos o tres integrantes | 12–16 semanas | 20–32 semanas |
| Equipo con experiencia y dedicación alta | 8–12 semanas | 16–24 semanas |


## 19.2 Versiones sugeridas

| Versión | Alcance |
| --- | --- |
| 0.1 Fundamentos | Monorepo, base, auth, roles y documentación. |
| 0.2 Finanzas | Wallets, ledger, recarga, conversión y retiros. |
| 0.3 Vendedores | Inventario, solicitudes y fallback. |
| 0.4 Sorteos base | Productos, eventos, combinaciones y compra. |
| 0.5 Economía | Premio, techo, fondos y simulador. |
| 0.6 Resultados | Commit-reveal, evaluación e informes. |
| 0.7 Web Beta | Paneles web integrados. |
| 0.8 Mobile Beta | Cliente/Vendedor móvil. |
| 0.9 Release Candidate | Carga, seguridad y observabilidad. |
| 1.0 Sistema completo | Criterios globales y documentación aprobados. |


## 19.3 MVP académico recomendado

Para una materia, el MVP debe demostrar todo el ciclo principal sin fingir seguridad: autenticación, API REST, PostgreSQL, web responsive, aplicación móvil, un flujo de Vendedor, al menos un producto de lotería completamente funcional y arquitectura preparada para los tres. No obstante, el esquema y las reglas deben soportar Octal, Decimal y Hexadecimal desde el inicio para evitar rediseño.


# 20. RIESGOS Y MITIGACIONES

| Riesgo | Probabilidad | Impacto | Mitigación |
| --- | --- | --- | --- |
| Sobrecargar el alcance | Alta | Alta | Entregar por versiones; no intentar web, móvil y economía avanzada al mismo tiempo. |
| Error contable | Media | Crítica | Libro doble, transacciones, reconciliación y pruebas de propiedad. |
| Doble venta | Media | Crítica | Restricción única, lock de fila y pruebas de concurrencia. |
| Doble premio | Baja | Crítica | Idempotencia y clave única. |
| Fondo insuficiente | Media | Alta | Reserva antes de publicar y bloqueo automático. |
| Evento programado duplicado | Media | Media | Clave única plantilla+fecha. |
| Pérdida de trabajo de cola | Media | Alta | Colas persistentes, job_runs y reintentos. |
| Cambios de reglas tardíos | Alta | Alta | Versionado y control de cambios. |
| Dependencia de frontend antiguo | Alta | Media | Usarlo solo como referencia visual. |
| Tokens o datos expuestos | Media | Crítica | Secure cookies/Store, logs sanitizados y revisión. |
| Aplicación móvil duplica lógica | Media | Alta | API central y paquetes compartidos. |
| Fallo de despliegue/migración | Media | Alta | Staging, backup, expand-contract y rollback. |
| Rendimiento en eventos concurridos | Media | Alta | Índices, cache, load tests y escalado de workers. |
| Alucinación o pérdida de contexto | Alta | Media | Usar Documento Maestro, Plan Técnico y ADR como fuentes versionadas. |


# 21. TRAZABILIDAD CON REGLAS Y ASIGNATURA


## 21.1 Reglas críticas y componentes

| Regla | Datos | Backend | Interfaz | Prueba clave |
| --- | --- | --- | --- | --- |
| Combinación única | event_combinations, reservations, tickets | Combinations/Purchases | Web/Móvil Jugar | Concurrencia |
| 20%/80% | purchase_sessions, reservations | PurchasePolicy | Límite y contador | Tiempo frontera |
| 5 min solicitud | conversion_requests | ConversionRequests Worker | Estado solicitud | Carrera vendedor/plataforma |
| 0,90 vendedor | vendor_inventory_batches, ledger | VendorPurchases | Comprar virtual | Ganancia realizada |
| 10% virtual→real | conversions, ledger | Conversions | Convertir | Redondeo/comisión |
| Premio 90% | event_financial_configs, funds | PrizeEngine | Simulador | Escenarios |
| Acumulado 50/25/15/10 | accumulation/funds | NoWinnerDistribution | Informe/admin | Meta mínima |
| Resultado inmutable | commitments, results | DrawEngine | Animación/verificador | Reinicio/duplicado |
| Premio automático | prize_awards, payment_orders | Awards | Wallet/boletín | Idempotencia |
| Cancelación | event status, refunds | EventCancellation | Motivo/reembolso | Antes/después resultado |


## 21.2 Alineación con la asignatura

| Unidad | Aplicación en el proyecto |
| --- | --- |
| Estructura y estilo web | HTML semántico generado por Next.js, CSS, formularios, cajas, efectos y validación. |
| Diseño web adaptable | Design system responsive, mejora progresiva y componentes accesibles. |
| Programación web cliente | DOM/React, eventos, TypeScript, AJAX/API, WebSocket y arquitectura cliente-servidor. |
| Móviles multiplataforma | React Native/Expo, metodología iterativa, navegación, almacenamiento seguro y nube. |
| Programación servidor | NestJS, arquitectura modular/MVC, seguridad, estado, sesiones y despliegue. |
| Servicios web | REST, OpenAPI, DTO, comunicación web/móvil/API y operaciones HTTP. |


# 22. CRITERIOS GLOBALES DE ACEPTACIÓN

- La web y el móvil consumen la misma API y no duplican reglas de negocio.
- PostgreSQL y el libro contable son la fuente de verdad.
- Los tres productos aceptan exactamente sus cantidades y universos.
- No puede venderse una combinación repetida dentro de un evento.
- La selección manual, parcial, aleatoria y rápida funciona.
- El límite 20% y su liberación temporal se cumplen con hora del servidor.
- La reserva dura cinco minutos y se libera de forma segura.
- Las ventas cierran diez minutos antes del sorteo.
- El premio inicial, crecimiento, techo, devolución, redondeo y fondos coinciden con las fórmulas.
- Los eventos sin ganador aplican la política correcta según meta mínima.
- Los vendedores compran a 0,90, reciben 1,00 al vender y no obtienen beneficio por ciclo artificial.
- La plataforma completa solicitudes a los cinco minutos sin doble ejecución.
- El resultado se genera una vez, es verificable e inmutable.
- La animación puede saltarse y no genera llamadas por cada número.
- El informe no expone identidad y coincide con la acreditación.
- Un evento con resultado no puede cancelarse ni editarse.
- Un evento cancelado reembolsa íntegramente y conserva auditoría.
- Las pruebas de concurrencia, idempotencia, seguridad y recuperación pasan.
- Existen backups, observabilidad, runbooks y documentación.
- El sistema demuestra los contenidos de la asignatura.


## 22.1 Definición de terminado para una historia

| Aspecto | Requisito |
| --- | --- |
| Funcional | Cumple regla y criterios de aceptación. |
| Datos | Migración, restricción e índice revisados. |
| API | Contrato, validación, permisos y errores documentados. |
| Finanzas | Transacción, idempotencia y auditoría cuando aplica. |
| Pruebas | Unitarias, integración y E2E necesarias. |
| Seguridad | Amenazas revisadas; no expone datos. |
| UX | Responsive, accesible y con estados de carga/error. |
| Operación | Logs, métricas y runbook si es crítico. |
| Documentación | Documento/ADR/OpenAPI actualizado. |


# 23. CONTROL DE CAMBIOS Y CONTINUIDAD


## 23.1 Jerarquía documental

| Orden | Documento | Autoridad |
| --- | --- | --- |
| 1 | Documento Maestro de Reglas | Define qué debe hacer el sistema. |
| 2 | Plan Técnico de Creación | Define cómo y en qué orden construirlo. |
| 3 | ADR | Justifica decisiones técnicas específicas. |
| 4 | OpenAPI y esquema de datos | Contratos ejecutables. |
| 5 | Código y pruebas | Implementación verificable. |


## 23.2 Procedimiento de cambio

- Registrar solicitud, motivo y regla afectada.
- Analizar impacto en datos, API, web, móvil, economía, seguridad y pruebas.
- Actualizar primero el Documento Maestro si cambia negocio.
- Actualizar este plan y ADR si cambia arquitectura.
- Crear migración o estrategia de compatibilidad.
- Agregar pruebas de regresión.
- Versionar y comunicar el cambio.


## 23.3 Regla para futuras conversaciones o herramientas

> **Decisión obligatoria:** Antes de generar código, entregar el Documento Maestro de Reglas y este Plan Técnico como contexto. Cualquier propuesta que contradiga estos documentos debe señalarse como cambio, no incorporarse silenciosamente.


# ANEXO A. CATÁLOGO DE ENDPOINTS PROPUESTO

| Método | Ruta | Función |
| --- | --- | --- |
| POST | /api/v1/auth/register | Registrar Cliente. |
| POST | /api/v1/auth/login | Iniciar sesión. |
| POST | /api/v1/auth/refresh | Rotar token. |
| POST | /api/v1/auth/logout | Cerrar sesión actual. |
| POST | /api/v1/auth/mode | Cambiar modo activo autorizado. |
| GET | /api/v1/users/me | Perfil y roles. |
| GET | /api/v1/wallets | Saldos REAL/VIRTUAL. |
| GET | /api/v1/wallets/movements | Movimientos paginados. |
| POST | /api/v1/topups | Crear recarga real. |
| POST | /api/v1/conversions/virtual-to-real | Convertir con 10%. |
| POST | /api/v1/transfers/virtual | Transferir virtual. |
| POST | /api/v1/withdrawals | Solicitar retiro. |
| POST | /api/v1/conversion-requests | Crear solicitud real→virtual. |
| GET | /api/v1/conversion-requests/me | Estado del Cliente. |
| GET | /api/v1/vendor/requests | Solicitudes visibles. |
| POST | /api/v1/vendor/requests/{id}/assign | Tomar solicitud. |
| POST | /api/v1/vendor/requests/{id}/confirm | Completar por Vendedor. |
| POST | /api/v1/vendor/requests/{id}/cancel | Liberar asignación. |
| POST | /api/v1/vendor/inventory/purchases | Comprar virtual 0,90. |
| GET | /api/v1/lottery/products | Listar productos. |
| GET | /api/v1/events | Eventos por tipo/estado. |
| GET | /api/v1/events/{id} | Detalle y economía pública. |
| GET | /api/v1/events/{id}/availability | Conteos y búsqueda parcial. |
| POST | /api/v1/events/{id}/purchase-sessions | Crear sesión. |
| POST | /api/v1/events/{id}/reservations/random | Reserva aleatoria. |
| POST | /api/v1/events/{id}/reservations/partial | Completar selección. |
| POST | /api/v1/events/{id}/reservations/exact | Reservar combinación exacta. |
| POST | /api/v1/purchase-orders | Confirmar carrito. |
| GET | /api/v1/tickets | Boletos del usuario. |
| GET | /api/v1/tickets/{id} | Detalle. |
| GET | /api/v1/public/results | Boletines públicos. |
| GET | /api/v1/public/results/{eventId} | Resultado e informe. |
| GET | /api/v1/public/results/{eventId}/verification | Datos commit-reveal. |
| GET | /api/v1/admin/users | Usuarios y filtros. |
| PATCH | /api/v1/admin/users/{id}/status | Estado de cuenta. |
| POST | /api/v1/admin/users/{id}/roles | Asignar rol. |
| GET | /api/v1/admin/rule-versions | Versiones. |
| POST | /api/v1/admin/rule-versions | Crear versión. |
| GET | /api/v1/admin/event-templates | Plantillas. |
| POST | /api/v1/admin/event-templates | Crear autogenerador. |
| PATCH | /api/v1/admin/event-templates/{id} | Editar futuro. |
| GET | /api/v1/admin/events | Gestionar eventos. |
| POST | /api/v1/admin/events/{id}/cancel | Cancelar con motivo. |
| POST | /api/v1/admin/events/simulate | Simular economía. |
| GET | /api/v1/admin/funds | Saldos y reservas. |
| POST | /api/v1/admin/funds/guarantee/contributions | Aporte administrativo. |
| GET | /api/v1/admin/audit | Auditoría. |
| GET | /api/v1/admin/jobs | Trabajos y fallos. |
| GET | /api/v1/health | Salud pública mínima. |


# ANEXO B. EVENTOS DE DOMINIO Y MENSAJES

| Evento | Origen | Consumidores/efecto |
| --- | --- | --- |
| UserRegistered | auth | Crear wallets, enviar verificación. |
| RealTopupConfirmed | topups | Acreditar REAL. |
| VendorVirtualPurchased | vendors | Actualizar inventario y métricas. |
| ConversionRequestCreated | conversion-requests | Programar fallback a 5 min. |
| ConversionRequestAssigned | conversion-requests | Actualizar vistas en tiempo real. |
| ConversionRequestCompleted | conversion-requests | Cancelar fallback y registrar venta. |
| EventGenerated | events | Generar combinaciones y reservar cobertura. |
| EventSalesOpened | events | Publicar estado. |
| CombinationReserved | reservations | Programar expiración. |
| TicketPurchased | tickets | Actualizar ventas y premio. |
| PurchaseLimitReleased | events | Actualizar interfaz. |
| EventSalesClosed | events | Congelar compras. |
| DrawResultFixed | draw-engine | Evaluar boletos. |
| ReportPublished | reports | Acreditar órdenes y avisar. |
| PrizeCredited | awards | Actualizar wallet. |
| NoWinnerDistributionCompleted | funds | Transferir fondos/acumulado. |
| EventCancelled | events | Crear reembolsos. |


# ANEXO C. MÁQUINAS DE ESTADO


## C.1 Evento

```text
BORRADOR
  → PROGRAMADO
  → PUBLICADO / VENTAS_ABIERTAS
  → AGOTADO (opcional)
  → VENTAS_CERRADAS
  → CONGELADO
  → RESULTADO_FIJADO
  → PREMIOS_CALCULADOS
  → INFORME_PUBLICADO
  → FINALIZADO

Antes de RESULTADO_FIJADO:
  → CANCELADO
```


## C.2 Combinación y reserva

```text
DISPONIBLE → RESERVADA → VENDIDA
RESERVADA → DISPONIBLE (expiración/cancelación)
DISPONIBLE/RESERVADA → BLOQUEADA (operación administrativa justificada)
```


## C.3 Solicitud real→virtual

```text
PENDIENTE → ASIGNADA/EN_PROCESO → COMPLETADA_POR_VENDEDOR
PENDIENTE/EN_PROCESO → COMPLETADA_POR_PLATAFORMA (a los 5 min)
EN_PROCESO → PENDIENTE (cancelación antes del plazo)
PENDIENTE/EN_PROCESO → FALLIDA_POR_LIQUIDEZ
```


## C.4 Premio

```text
CALCULADO → PREPARADO → ACREDITANDO → ACREDITADO
                                  -> ERROR_REINTENTABLE
                                  -> REVISIÓN_MANUAL
```


# ANEXO D. VARIABLES Y PARÁMETROS

| Categoría | Parámetro | Ubicación correcta |
| --- | --- | --- |
| Regla histórica | Cantidad 4/5/6, universo, devolución, 90%, 10% | rule_versions / prize_rule_versions |
| Evento | Precio, premio inicial, techo, fechas, meta | event_financial_configs / draw_events |
| Plantilla | Frecuencia, anticipación, cierre, multiplicador sugerido | event_templates |
| Operativo | Tamaño técnico de carrito, rate limit, reintentos | system_settings/configuración |
| Infraestructura | URLs, credenciales, claves, storage | Variables/gestor de secretos |
| Fondos | Fondo base mínimo, saldos y reservas | Ledger + guarantee_fund |


# ANEXO E. PSEUDOCÓDIGO CRÍTICO


## E.1 Compra

```text
BEGIN TRANSACTION
  assert idempotency_key not conflicting
  lock event
  assert server_time within sales window
  lock user purchase counters
  assert dynamic limit
  lock reservation and combination
  assert reservation owner and not expired
  assert virtual balance sufficient
  create balanced ledger transaction
  create immutable ticket
  update combination to SOLD
  mark reservation consumed
  store idempotent response
COMMIT
```


## E.2 Fallback de solicitud

```text
BEGIN TRANSACTION
  lock conversion_request
  if already completed: return success_without_effect
  assert now >= created_at + 5 minutes
  assert general conversion wallet has liquidity
  consume reserved REAL from client
  credit REAL to platform
  debit VIRTUAL from general wallet
  credit VIRTUAL to client
  mark COMPLETED_BY_PLATFORM
COMMIT
```


## E.3 Premio y redondeo

```text
exact = calculate_prize_in_cents()
public = round_to_quarter_policy(exact)
adjustment = public - exact

if adjustment > 0:
  debit operational_margin
else if adjustment < 0:
  credit guarantee_fund(abs(adjustment))

persist exact, public and adjustment
```


## E.4 Evento sin ganador

```text
if exact_winning_combination_was_sold:
  credit winner and refunds
else:
  pay refunds
  if event_met_minimum_capital:
    distribute final_major_prize:
      50% accumulation pool
      25% guarantee fund
      15% future prize fund
      10% operations
  else:
    restore guarantees and obligations first
    do not create 50% accumulation
```


# ANEXO F. LISTA DE VERIFICACIÓN ANTES DE COMENZAR CÓDIGO

- Documento Maestro y Plan Técnico guardados en docs/.
- Alcance de primera entrega aprobado.
- Stack y monorepo aprobados.
- Diagrama ER preliminar revisado.
- Matriz de permisos aprobada.
- Estados y transiciones aprobados.
- Fórmulas económicas convertidas en casos de prueba.
- Cuentas contables y fondos definidos.
- Política de idempotencia definida.
- Protocolo commit-reveal revisado.
- Entornos y secretos planificados.
- Backlog de Fase 1 creado.
- Criterios de salida de la fase entendidos.


# ANEXO G. PUNTOS PARAMETRIZABLES SIN CAMBIAR LA IDEA

| Parámetro | Regla de control |
| --- | --- |
| Frecuencia y horarios | Configurables por plantilla; no alteran eventos con ventas. |
| Anticipación de publicación | Configurable por producto/plantilla. |
| Multiplicador inicial | Configurable con cobertura; sugerido 5. |
| Techo | Editable antes de venta y sujeto a solvencia. |
| Tamaño técnico de carrito | Operativo; no es límite diario. |
| Duración visual por número | 3–5 segundos; no modifica resultado. |
| Uso del fondo de premios futuros | Requiere permiso, motivo y auditoría. |
| Número de días futuros autogenerados | Operativo y ajustable. |
| Canales de notificación | Opcionales. |


# CONCLUSIÓN

Este Plan Técnico establece una ruta completa y coherente para construir Lotería Binaria sin depender del prototipo anterior ni improvisar reglas durante la programación. La arquitectura propuesta permite que la base de datos, el backend, la web y la aplicación móvil evolucionen de manera coordinada, con especial atención a integridad financiera, concurrencia, solvencia, verificación de resultados y recuperación ante fallos.

El orden correcto es: documentación ejecutable, fundamentos, base de datos y libro contable, autenticación, wallets, vendedores, eventos, combinaciones, economía, resultados, web, móvil y endurecimiento. Saltar directamente a las pantallas produciría retrabajo y riesgos. Seguir las fases, entregables y criterios de salida permite construir un proyecto académico sólido y, al mismo tiempo, una base extensible para un sistema mayor.

> **Decisión obligatoria:** Este documento debe conservarse junto con el Documento Maestro de Reglas y entregarse como referencia antes de solicitar nuevas tablas, endpoints, código, pantallas o cambios de arquitectura.
