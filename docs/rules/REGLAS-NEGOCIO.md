---
title: "Reglas de Negocio del Dominio — Lotería Binaria"
version: "1.4.0"
status: "APROBADO Y CONGELADO — baseline funcional final para implementación v1"
author: "Cristhian Herrera Nieto"
date: "2026-07-26"
repository: "Herrera2005/loteria-binaria"
---

# REGLAS DE NEGOCIO DEL DOMINIO — LOTERÍA BINARIA

**Versión:** 1.4.0  
**Estado:** **APROBADO Y CONGELADO.** Baseline funcional final de la versión 1 del proyecto. El backend, PostgreSQL, workers, web y móvil deben implementarlo sin reinterpretaciones.  
**Fecha:** 26 de julio de 2026  
**Ruta objetivo en el repositorio:** `docs/REGLAS-NEGOCIO.md`

> [!WARNING]
> En la fase académica, los saldos, recargas, conversiones, retiros y premios son simulados. Este documento no autoriza una operación con dinero real ni sustituye análisis legal, regulatorio, de seguridad o de juego responsable.

## 0. Propósito

Este documento convierte las decisiones funcionales del proyecto en reglas verificables para **backend, PostgreSQL, workers, web y aplicación móvil**. Su objetivo es impedir que una regla exista únicamente en el frontend o dependa de `localStorage`, JavaScript del navegador, la hora del dispositivo o una suposición del programador.

Cada regla contiene:

- **Identificador estable** para código, migraciones, pruebas, incidencias y auditoría.
- **Descripción normativa** del comportamiento obligatorio.
- **Responsable técnico** que debe hacerla cumplir.
- **Validación mínima** recomendada.
- **Prueba obligatoria** para demostrarla.
- **Resultado esperado** observable.
- **Origen** para distinguir reglas documentadas, decisiones posteriores e inferencias de integridad.

## 0.1 Autoridad, alcance y precedencia

La jerarquía documental queda así:

1. `Documento Maestro de Reglas del Sistema Lotería Binaria v1.0` y adendas aprobadas, incluido `ADR-ORG-001`.
2. Este documento, `REGLAS-NEGOCIO.md` v1.4.0, como catálogo normativo consolidado.
3. `ESTADOS-Y-TRANSICIONES.md`, `FLUJOS-FINANCIEROS.md`, `MATRIZ-DE-PERMISOS.md` y `DICCIONARIO-DE-DATOS.md`, cada uno con autoridad dentro de su materia y sin capacidad de contradecir las reglas.
4. `PLAN-TECNICO.md` v1.1.0, para arquitectura, fases y controles de construcción.
5. OpenAPI, `schema.prisma` y migraciones como contratos ejecutables.
6. Código y pruebas como implementación verificable.
7. README como guía operativa y descripción del repositorio.

El Documento Maestro v1.0 ubicó los sorteos privados creados por usuarios como funcionalidad futura. `ADR-ORG-001` funciona como adenda de alcance aprobada para esta baseline e incorpora el módulo al mismo producto **como un contexto de dominio independiente**, sin convertirlo en parte de las reglas Octal, Decimal o Hexadecimal.

Esta versión no contiene decisiones funcionales abiertas. Una necesidad futura que no esté definida aquí queda fuera de la baseline v1 y no puede resolverse mediante una suposición en Prisma, SQL o código.

## 0.2 Convenciones

- **DEBE / NO DEBE:** obligatorio o prohibido.
- **Backend:** API y servicios de aplicación/dominio.
- **Worker:** procesos asíncronos y programados.
- **Base de datos:** PostgreSQL, restricciones, transacciones, triggers o procedimientos justificados.
- **REAL / VIRTUAL:** unidades independientes expresadas internamente en centavos enteros.
- **Prueba de concurrencia:** dos o más procesos reales contra PostgreSQL, no una simulación puramente local.

## 0.3 Estado del repositorio verificado

Al congelar este documento, el repositorio público está en la versión `0.1.0`, con monorepo `pnpm`/Turborepo, aplicaciones `api`, `worker`, `web` y `mobile`, PostgreSQL/Redis mediante Compose y un `schema.prisma` todavía sin modelos de dominio. Por tanto, este es el momento correcto para aprobar las reglas antes de crear tablas y migraciones.

## 0.4 Separación de contextos de dominio

| Contexto | Incluye | No debe heredar automáticamente |
|---|---|---|
| **Lotería oficial** | Octal, Decimal, Hexadecimal, eventos oficiales, combinaciones exclusivas, límite 20 %, fondos, acumulados, resultado verificable y boletos. | Reglas de códigos, expulsión, productos físicos o adjudicación de sorteos de usuario. |
| **Sorteos creados por usuarios** | Organizador contextual, rango de números, participación VIRTUAL, comisión 5 %, códigos privados, anuncios, historial, expulsiones y reclamos. | Premio creciente, acumulado 50/25/15/10, fondo de garantía oficial, commit-reveal o límite 20 %, salvo aprobación expresa. |

Comparten usuarios, autenticación, saldo VIRTUAL, libro contable, auditoría e infraestructura. Deben usar entidades, estados y servicios separados para impedir que una regla de un contexto afecte al otro por accidente.

## 0.5 Catálogo de reglas

## 1. Gobierno, autoridad y principios transversales

| Identificador | Descripción | Responsable | Validación | Prueba | Resultado esperado | Origen |
|---|---|---|---|---|---|---|
| LOT-GOV-001 | Toda regla sensible de identidad, permisos, dinero, tiempo, compra, resultado, premio, reclamo o expulsión debe decidirse en el backend; la interfaz solo solicita y presenta. | Backend | Guardias de autorización y servicios de dominio obligatorios; prohibición de confiar en campos calculados por cliente. | Alterar rol, saldo, hora o estado desde web/móvil y enviar la petición. | La API ignora los datos manipulados y responde con el estado autoritativo o un error de dominio. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-GOV-002 | PostgreSQL y el libro contable constituyen la fuente de verdad. Redis, cachés, WebSocket, frontend y almacenamiento local solo contienen datos derivados o efímeros. | Backend, base de datos y worker | Lecturas críticas desde PostgreSQL; reconciliación de proyecciones; Redis no puede confirmar efectos financieros. | Vaciar Redis y reiniciar API/worker después de operaciones confirmadas. | Saldos, boletos, solicitudes, resultados y pagos permanecen íntegros y reconstruibles. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-GOV-003 | Las operaciones críticas deben ser atómicas e idempotentes: repetir la misma orden no puede duplicar compras, conversiones, reembolsos, premios ni reclamos. | Backend y base de datos | Transacción SQL, clave de idempotencia, hash del cuerpo y restricciones UNIQUE. | Enviar la misma petición en paralelo y repetirla después de un timeout. | Existe un único efecto económico y todas las respuestas posteriores refieren al mismo resultado. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-GOV-004 | Los registros históricos confirmados no se reescriben destructivamente. Las correcciones financieras o administrativas se realizan mediante operaciones compensatorias y auditoría. | Backend, base de datos y administración | Bloqueo de UPDATE/DELETE lógico o permisos restringidos; eventos compensatorios. | Intentar editar un asiento confirmado, boleto pagado o resultado fijado. | La modificación directa se rechaza; solo se permite una corrección trazable separada. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-GOV-005 | Toda fecha sensible usa hora oficial del servidor/base de datos, se almacena en UTC y se presenta en America/Guayaquil. | Backend, worker y base de datos | timestamptz, clock_timestamp()/NOW() y validación temporal en servidor. | Cambiar la hora del dispositivo durante una reserva o cierre. | La expiración y el cierre no cambian por la hora local manipulada. | Plan Técnico v1.0 |
| LOT-GOV-006 | Los montos se almacenan como enteros en centavos reales o centésimas virtuales; se prohíben float y double en cálculos monetarios. | Backend y base de datos | BIGINT/Decimal seguro, tipos monetarios compartidos y reglas de lint. | Procesar muchas operaciones con fracciones y comparar libro contra proyección. | No aparecen errores acumulativos de punto flotante y el balance exacto se conserva. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-GOV-007 | Las reglas utilizadas por un evento deben quedar vinculadas a una versión inmutable. Una modificación crea una nueva versión y no altera eventos históricos. | Backend, base de datos y administración | FK obligatoria a rule_version; bloqueo de versiones usadas. | Modificar una versión ligada a boletos y consultar un evento anterior. | La edición se rechaza o crea una versión nueva; el evento histórico conserva la original. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-GOV-008 | Durante la fase académica, recargas, saldos, conversiones, retiros y premios son simulados y no representan dinero real ni un servicio de lotería autorizado. | Documentación, backend y despliegue | Bandera de entorno, proveedor simulado y advertencia visible; ausencia de integración productiva. | Ejecutar el entorno local y revisar flujos de pago/retiro. | El sistema identifica el modo simulado y no procesa tarjetas ni retiros reales. | README oficial y Maestro v1.0 |

## 2. Identidad, roles y permisos

| Identificador | Descripción | Responsable | Validación | Prueba | Resultado esperado | Origen |
|---|---|---|---|---|---|---|
| LOT-IAM-001 | El sistema reconoce Cliente, Vendedor y Administrador como roles globales. Organizador es una capacidad contextual asociada a un sorteo creado por usuario y puede asumirla cualquier cuenta registrada y activa autorizada. | Backend y base de datos | RBAC para roles globales; relación organizer_user_id por sorteo de usuario, sin crear privilegios globales de Organizador. | Crear un sorteo de usuario con una cuenta activa sin rol global adicional. | La cuenta queda como organizadora de ese sorteo sin recibir privilegios de Administrador. | Maestro v1.0 + decisión aprobada posterior |
| LOT-IAM-002 | Un usuario puede tener varios roles globales, pero cada sesión mantiene un modo activo y los permisos se evalúan contra rol, modo, recurso y estado. | Backend | Sesión con active_mode y políticas por endpoint/recurso. | Iniciar como Vendedor y llamar un endpoint de compra de boletos. | La compra se rechaza aunque la cuenta también tenga operaciones de wallet. | Maestro v1.0 |
| LOT-IAM-003 | El Cliente activo puede consultar eventos, comprar boletos oficiales, gestionar wallets, solicitar virtual, convertir virtual a real, transferir virtual y consultar historial. | Backend | Matriz de permisos y pruebas de autorización. | Ejecutar cada operación con Cliente activo y luego suspendido. | El activo opera dentro de reglas; el suspendido recibe rechazo sin efectos. | Maestro v1.0 |
| LOT-IAM-004 | El Vendedor no puede comprar boletos ni participar en sorteos oficiales desde modo Vendedor o Cliente financiero. | Backend y base de datos | Política de autorización y restricción de propietario en purchase_order/ticket. | Intentar comprar con una sesión de Vendedor. | La API responde FORBIDDEN y no crea reserva, orden, asiento ni boleto. | Maestro v1.0 |
| LOT-IAM-005 | El Administrador solo puede ejecutar acciones incluidas en sus permisos; gestionar fondos, cancelar eventos, intervenir reclamos y operar resultados exige permisos reforzados y auditoría. | Backend y seguridad | RBAC granular, MFA recomendado y audit_event obligatorio. | Administrador sin permiso intenta aportar fondos o resolver reclamo. | La acción se rechaza y se registra el intento de seguridad cuando corresponda. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-IAM-006 | La navegación directa a una URL o la manipulación de componentes no concede permisos ni cambia el modo activo. | Backend | Guardias en todos los endpoints sensibles. | Abrir manualmente una ruta administrativa con sesión de Cliente. | No se expone información ni se ejecuta la acción. | Maestro v1.0 |
| LOT-IAM-007 | Correo, documento y nombre de usuario deben ser únicos; la cuenta debe aceptar términos versionados y cumplir mayoría de edad. | Backend y base de datos | UNIQUE, validadores, terms_acceptance y fecha de nacimiento. | Registrar dos cuentas con el mismo documento o sin aceptación. | Solo la primera válida se crea; las demás se rechazan con error específico. | Maestro v1.0 |
| LOT-IAM-008 | Los estados de cuenta son PENDIENTE_VERIFICACION, ACTIVO, SUSPENDIDO, BLOQUEADO y DESACTIVADO; solo ACTIVO puede iniciar nuevas operaciones de negocio. | Backend y base de datos | Enum/check de estado y guardia común. | Intentar comprar, convertir o crear sorteo con cada estado. | Solo ACTIVO puede comenzar la operación; el historial sigue consultable según permisos. | Maestro v1.0 |
| LOT-IAM-009 | Una cuenta con historial financiero, boletos, sorteos, códigos o reclamos no se elimina físicamente; se desactiva o anonimiza conforme a la política de retención. | Backend y base de datos | Soft delete/estado y FKs restrictivas. | Solicitar eliminación de un usuario con asientos y boletos. | Los registros históricos permanecen íntegros y la cuenta deja de operar. | Maestro v1.0 + derivada de trazabilidad |

## 3. Wallets, dinero y libro contable

| Identificador | Descripción | Responsable | Validación | Prueba | Resultado esperado | Origen |
|---|---|---|---|---|---|---|
| LOT-FIN-001 | En la lotería oficial, cada usuario dispone de wallets separadas por unidad REAL y VIRTUAL donde corresponda; las unidades nunca se suman ni compensan entre sí. | Backend y base de datos | wallet.currency, cuentas contables por unidad y balance independiente. | Intentar balancear un débito REAL con un crédito VIRTUAL. | La transacción contable se rechaza. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-FIN-002 | Boletos, premios, devoluciones, acumulados, fondos y obligaciones de sorteos oficiales se expresan únicamente en saldo VIRTUAL. | Backend y base de datos | Validación de currency en entidades y cuentas relacionadas. | Crear boleto o premio en REAL. | La operación se rechaza antes de generar asientos. | Maestro v1.0 |
| LOT-FIN-003 | El saldo REAL se usa para recargas, reservas de solicitudes, ingresos de vendedores, conversión virtual a real y retiros; no se transfiere libremente entre usuarios. | Backend | Casos de uso permitidos y política de transferencia. | Intentar una transferencia REAL directa entre clientes. | La API la rechaza y sugiere el flujo permitido sin mover saldo. | Maestro v1.0 |
| LOT-FIN-004 | Los sorteos creados por usuarios operan solo con saldo VIRTUAL dentro del módulo; no crean una segunda pareja de wallets REAL/VIRTUAL. | Backend y base de datos | Todas las cuentas del módulo user-draw usan currency=VIRTUAL y el ledger global. | Intentar pagar participación de sorteo de usuario con REAL. | La operación se rechaza sin reservar ni mover saldo. | Decisión aprobada posterior + integración con modelo monetario |
| LOT-FIN-005 | Cada operación financiera genera una transacción de doble entrada y la suma de débitos debe igualar la suma de créditos por unidad monetaria. | Backend y base de datos | Trigger/procedimiento de cierre o validación diferida ledger_balanced. | Insertar una transacción desbalanceada. | No puede confirmarse. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-FIN-006 | Los saldos visibles son proyecciones del libro y deben distinguir disponible, reservado, pendiente, bloqueado y en retiro. | Backend y base de datos | wallet_balance_projection derivada y reconciliación periódica. | Dañar intencionalmente una proyección y ejecutar reconciliación. | La proyección se corrige desde el libro sin crear un nuevo movimiento. | Plan Técnico v1.0 |
| LOT-FIN-007 | Los saldos disponibles no pueden quedar negativos, salvo cuentas técnicas expresamente autorizadas y auditadas. | Base de datos y backend | CHECK/lock de cuenta y validación transaccional. | Ejecutar dos débitos simultáneos que superan el disponible. | Solo uno se confirma o ambos se rechazan; nunca queda saldo no autorizado negativo. | Plan Técnico v1.0 |
| LOT-FIN-008 | La recarga académica de saldo REAL es simulada y no cobra comisión de negocio. | Backend | Proveedor SIMULATED y cálculo amount_credited=amount_paid. | Simular recarga de 100,00. | Se acreditan 100,00 REAL y comisión 0,00. | Maestro v1.0 |
| LOT-FIN-009 | La conversión de VIRTUAL a REAL cobra una comisión de 10 % sin importar el origen válido del virtual. | Backend y base de datos | Cálculo entero versionado y asientos separados de principal/comisión. | Convertir 500,00 VIRTUAL. | Se debitan 500,00 VIRTUAL, se acreditan 450,00 REAL y 50,00 se registran como comisión. | Maestro v1.0 |
| LOT-FIN-010 | Después de convertir VIRTUAL a REAL, el retiro no cobra una segunda comisión de negocio en la primera versión; cualquier costo futuro externo debe informarse y versionarse. | Backend | Regla de withdrawal sin fee interno y configuración versionada de proveedor futuro. | Solicitar retiro de REAL ya convertido. | El retiro no descuenta otra comisión de negocio. | Maestro v1.0 |
| LOT-FIN-011 | Las transferencias internas permitidas son de saldo VIRTUAL entre clientes activos; no se permiten auto-transferencias. | Backend y base de datos | Validación sender_id != recipient_id, estados activos y transacción atómica. | Transferir a sí mismo y transferir a otro Cliente activo. | La primera se rechaza; la segunda crea movimientos simétricos y comprobante. | Maestro v1.0 |
| LOT-FIN-012 | Toda compra, venta, conversión, transferencia, premio, devolución, reembolso, comisión, fondo y aporte administrativo debe enlazarse a su transacción y asientos contables. | Backend y base de datos | FK ledger_transaction_id obligatoria en operaciones confirmadas. | Confirmar cada tipo de operación y buscar su evidencia contable. | Cada operación tiene asientos balanceados y correlación trazable. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-FIN-013 | Los repartos porcentuales se calculan exclusivamente en minor units mediante **método de mayores residuos**: se aplican pisos enteros y las unidades restantes se asignan por prioridad determinista. Para VIRTUAL→REAL se prioriza el neto del usuario sobre la comisión; para sorteos de usuarios, el escrow sobre la comisión; para crecimiento oficial, el premio sobre operación; y para 50/25/15/10 la prioridad de desempate es acumulado, garantía, premios futuros y operación. Las compras mayoristas del Vendedor se realizan en incrementos de 1,00 VIRTUAL para conservar exactamente la relación 0,90 REAL→1,00 VIRTUAL. | Backend y base de datos | Función monetaria compartida, código de política versionado, suma exacta de componentes, registro del residuo y CHECK de incremento mayorista. | Probar importes de 0,01 a 10,00, empates de residuos, reparto 50/25/15/10 y una compra mayorista no múltiplo de 1,00. | Ninguna minor unit se crea, desaparece o asigna de forma ambigua; los repartos suman exactamente el monto base y la orden mayorista inválida se rechaza. | Decisión final de congelamiento v1.4.0 |

## 4. Vendedores y solicitudes Cliente–Vendedor

| Identificador | Descripción | Responsable | Validación | Prueba | Resultado esperado | Origen |
|---|---|---|---|---|---|---|
| LOT-VND-001 | El Vendedor compra 1,00 VIRTUAL por cada 0,90 REAL mediante una orden mayorista confirmada. | Backend y base de datos | Tasa versionada 90/100, transacción contable y lote de inventario. | Comprar 100,00 VIRTUAL con saldo suficiente. | Se debitan 90,00 REAL y se acreditan 100,00 VIRTUAL una sola vez. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-VND-002 | La compra mayorista genera inventario y ganancia potencial, no ganancia realizada. La ganancia se realiza cuando el vendedor entrega virtual a un cliente y recibe real 1:1. | Backend | Cálculo separado de capital, inventario, margen potencial y ventas realizadas. | Comprar inventario y revisar métricas antes y después de una venta. | Antes de vender la ganancia realizada es 0; después refleja 0,10 por cada 1,00 vendido. | Maestro v1.0 |
| LOT-VND-003 | Un Cliente no convierte REAL a VIRTUAL de forma directa; crea una solicitud y el monto REAL queda reservado. | Backend y base de datos | Caso de uso conversion_request, reserva contable y estado PENDIENTE. | Crear solicitud con saldo suficiente e insuficiente. | La válida reserva exactamente el monto; la insuficiente no crea solicitud ni reserva. | Maestro v1.0 |
| LOT-VND-004 | Solo ven una solicitud los vendedores activos con saldo VIRTUAL disponible suficiente y sin relación bloqueada con el solicitante. | Backend | Consulta filtrada por estado, saldo y related_account_flags. | Comparar visibilidad para vendedor solvente, insolvente, inactivo y relacionado. | Solo el vendedor solvente, activo y no relacionado la recibe. | Maestro v1.0 |
| LOT-VND-005 | El primer vendedor que toma una solicitud obtiene una asignación atómica; los demás no pueden tomarla. | Backend y base de datos | SELECT FOR UPDATE y UNIQUE de asignación activa. | Dos vendedores toman simultáneamente la misma solicitud. | Solo uno recibe la asignación; el otro obtiene no disponible. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-VND-006 | La asignación no reinicia el plazo total de cinco minutos contado desde la creación de la solicitud. | Backend y worker | expires_at inmutable calculado al crear. | Tomar la solicitud a los 4 minutos 50 segundos. | Solo quedan 10 segundos; no se extiende el vencimiento. | Maestro v1.0 |
| LOT-VND-007 | La confirmación por vendedor intercambia en una sola transacción: VIRTUAL vendedor→cliente y REAL reservado cliente→vendedor. | Backend y base de datos | Lock de solicitud y cuentas, asientos balanceados y estado COMPLETADA_POR_VENDEDOR. | Forzar error después del primer asiento. | Toda la operación revierte; no queda transferencia parcial. | Maestro v1.0 |
| LOT-VND-008 | Si el vendedor cancela o abandona antes del vencimiento, se libera su asignación, la solicitud vuelve a PENDIENTE y el REAL del cliente sigue reservado. | Backend y worker | Transición de estado controlada y evento de historial. | Cancelar una asignación vigente. | Otro vendedor puede tomarla y el saldo del cliente continúa reservado. | Maestro v1.0 |
| LOT-VND-009 | Si nadie completa la solicitud dentro de cinco minutos, el worker intenta completarla desde la wallet general de conversión. | Worker, backend y base de datos | Job persistente por expires_at, idempotencia y lock de solicitud. | Dejar vencer una solicitud sin vendedor. | Se acredita VIRTUAL al cliente, REAL a plataforma y estado COMPLETADA_POR_PLATAFORMA. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-VND-010 | Una carrera entre confirmación del vendedor y fallback de plataforma solo puede producir una finalización. Si no hay liquidez general, se libera el REAL y se marca FALLIDA_POR_LIQUIDEZ. | Backend, worker y base de datos | UNIQUE de finalización, lock y transición terminal exclusiva. | Ejecutar ambos procesos simultáneamente y luego simular wallet general insuficiente. | En la carrera solo uno confirma; en falta de liquidez no queda saldo bloqueado y se genera alerta. | Maestro v1.0 y Plan Técnico v1.0 |

## 5. Eventos oficiales, combinaciones, reservas y boletos

| Identificador | Descripción | Responsable | Validación | Prueba | Resultado esperado | Origen |
|---|---|---|---|---|---|---|
| LOT-EVT-001 | Una combinación completa no puede repetirse dentro del mismo evento, aunque sí puede existir en eventos diferentes. | Backend y base de datos | UNIQUE(draw_event_id, normalized_key) y lock transaccional. | Dos compras simultáneas de la misma combinación en un evento y otra compra en evento diferente. | En el mismo evento solo una confirma; en el otro evento puede venderse. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-EVT-002 | La lotería oficial incluye productos Octal, Decimal y Hexadecimal. | Backend y base de datos | Catálogo lottery_products y versiones de reglas activas. | Crear evento con producto inexistente. | Solo se aceptan productos registrados y compatibles. | Maestro v1.0 |
| LOT-EVT-003 | Octal usa valores 0–7 y exige exactamente 4 distintos; Decimal usa 0–9 y exige 5 distintos; Hexadecimal usa 0–9 y A–F y exige 6 distintos. | Backend y base de datos | Validación de universo, cardinalidad, mayúsculas y no repetición. | Enviar selecciones cortas, largas, repetidas y fuera de universo. | Todas se rechazan; solo la selección exacta y única es válida. | Maestro v1.0 |
| LOT-EVT-004 | El orden no distingue combinaciones. Toda selección se normaliza con un orden canónico antes de reservar, comparar o guardar. | Backend y base de datos | normalized_key determinista y UNIQUE por evento. | Comprar 7-4-2-0 y luego 0-2-4-7 en el mismo evento. | Ambas producen la misma clave; solo una puede confirmarse. | Maestro v1.0 |
| LOT-EVT-005 | Cada evento mantiene un catálogo de combinaciones con estados DISPONIBLE, RESERVADA, VENDIDA o BLOQUEADA. | Backend y base de datos | Enum/check y máquina de estados. | Intentar pasar de VENDIDA a DISPONIBLE sin reembolso/corrección autorizada. | La transición inválida se rechaza y queda auditada. | Maestro v1.0 |
| LOT-EVT-006 | La sección de compra debe mostrar todos los eventos activos y comprables por tipo, no únicamente el siguiente cronológicamente. | Backend y web/móvil | Consulta paginada por producto, estado y ventana de ventas. | Crear varios eventos activos del mismo producto. | Todos aparecen ordenados y cada uno conserva su propia apertura/cierre. | Maestro v1.0 |
| LOT-EVT-007 | Un evento publicado de la lotería oficial no se edita. Precio, reglas, fechas, premio y combinación de parámetros quedan inmutables; solo puede cancelarse conforme a permisos y estado. | Backend y base de datos | Bloqueo de UPDATE para estados PUBLICADO, VENTAS_ABIERTAS, VENTAS_CERRADAS, CONGELADO, RESULTADO_FIJADO, PREMIOS_CALCULADOS, INFORME_PUBLICADO, FINALIZADO o CANCELADO; comando de cancelación separado. No depender del orden ordinal de un enum. | Intentar cambiar precio y fecha después de publicar. | La edición se rechaza y el evento permanece sin cambios. | Maestro v1.0 + decisión final del proyecto |
| LOT-EVT-008 | Los cambios en plantillas/autogeneradores solo afectan eventos futuros no publicados y sin ventas. | Backend y base de datos | Versionado de plantilla y filtro de elegibilidad. | Modificar plantilla con eventos ya publicados. | Los publicados no cambian; solo los futuros elegibles usan la nueva versión. | Maestro v1.0 |
| LOT-EVT-009 | No se publica un evento sin cobertura suficiente en el fondo de garantía. | Backend y base de datos | Reserva de garantía obligatoria y bloqueo de publicación. | Publicar con cobertura insuficiente. | La publicación falla y no se abren ventas. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-EVT-010 | Las ventas cierran exactamente diez minutos antes de la hora oficial del sorteo. | Backend y worker | sales_close_at derivado/versionado y validación contra hora servidor. | Confirmar compra un segundo antes y un segundo después del cierre. | La primera puede confirmar si cumple todo; la segunda se rechaza. | Maestro v1.0 |
| LOT-EVT-011 | Una combinación añadida al carrito se reserva hasta cinco minutos. `expires_at = MIN(reserved_at + 5 minutos, sales_close_at)`. Si no se confirma antes de ese instante, vuelve a `DISPONIBLE` únicamente cuando el evento todavía acepta ventas; al cierre se invalida para compra. | Backend, worker y base de datos | `expires_at`, job de expiración, transición idempotente y guarda de cierre. | Reservar con más de cinco minutos restantes, reservar a menos de cinco minutos del cierre y confirmar antes/después de `expires_at`. | La primera dura cinco minutos; la segunda termina en el cierre; una orden vencida o posterior al cierre no compra y no prolonga ventas. | Maestro v1.0 + coherencia temporal |
| LOT-EVT-012 | Durante el primer 80 % de la ventana de ventas, cada Cliente puede acumular como máximo 20 % de las combinaciones totales del evento. | Backend | floor(total_combinations*0.20) y conteo de pagadas + reservas activas. | Alcanzar el límite y tratar de reservar una combinación adicional. | La reserva adicional se rechaza hasta la liberación o expiración de reservas. | Maestro v1.0 |
| LOT-EVT-013 | El instante de liberación se calcula al 80 % de la preventa y se redondea: minutos 00–14 a :00, 15–45 a :30 y 46–59 a la siguiente :00. El resultado se limita al intervalo `[sales_open_at, sales_close_at]`; si el redondeo coincide con el cierre, el límite deja de aplicar en ese instante, pero las ventas ya están cerradas y no se prolongan. | Backend | Función pura versionada, clamp temporal y pruebas de frontera. | Calcular para 16:05, 16:22, 16:45 y 16:46; además probar ventanas cortas cuyo redondeo cae después del cierre. | Produce 16:00, 16:30, 16:30 y 17:00 cuando están dentro de la ventana; nunca adelanta apertura ni extiende el cierre. | Maestro v1.0 + cierre de caso límite |
| LOT-EVT-014 | Después de la liberación desaparece el límite porcentual, pero permanecen saldo, disponibilidad, reserva, cierre, antifraude e idempotencia. | Backend | Política condicional por release_at. | Comprar más del 20 % después de release_at con saldo y combinaciones disponibles. | La compra puede continuar sin omitir las demás validaciones. | Maestro v1.0 |
| LOT-EVT-015 | El Cliente puede comprar mediante combinación aleatoria completa, lista compatible con selección parcial, completar al azar o selección completa. | Backend y web/móvil | DTO por modo y generador que solo usa combinaciones DISPONIBLES. | Probar los cuatro modos con restricciones parciales. | Cada modo devuelve/reserva combinaciones válidas y distintas. | Maestro v1.0 |
| LOT-EVT-016 | La confirmación de compra debe bloquear evento, reserva, combinación y wallet; debitar VIRTUAL, crear boleto y marcar VENDIDA en una sola transacción. | Backend y base de datos | SELECT FOR UPDATE, transacción SQL y FKs. | Provocar fallo al crear el boleto después del débito. | Todo revierte: no hay débito, boleto ni combinación vendida parcial. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-EVT-017 | Un boleto pagado es inmutable y no admite devolución voluntaria. Solo procede reembolso por cancelación, cobro duplicado, error interno, boleto no creado o corrección autorizada. | Backend y base de datos | Máquina de estados y comando de reembolso con motivo. | Solicitar devolución por arrepentimiento y luego simular cancelación. | La primera se rechaza; la cancelación genera reembolso trazable. | Maestro v1.0 |
| LOT-EVT-018 | La cancelación de un evento elegible mantiene el evento como CANCELADO y devuelve íntegramente en VIRTUAL el precio pagado de todos los boletos afectados. | Backend, worker y base de datos | Orden de reembolso idempotente por evento+boleto y estado terminal. | Cancelar un evento con múltiples boletos y reintentar el job. | Cada boleto recibe un único reembolso completo y el historial se conserva. | Maestro v1.0 y decisión final del proyecto |
| LOT-EVT-019 | Un evento oficial puede cancelarse por un Administrador autorizado mientras el resultado no haya sido fijado. Si las ventas ya cerraron o existe snapshot, la cancelación debe invalidar el proceso pendiente de forma trazable y reembolsar; después de fijar el resultado no procede cancelación ordinaria. | Backend, worker y base de datos | Guardia result_not_fixed, lock del evento, cancelación idempotente e invalidación auditada de jobs/snapshot pendientes. | Cerrar ventas sin generar resultado, cancelar y luego intentar cancelar después de fijar resultado. | La primera cancelación puede completarse con reembolsos; la segunda se rechaza. | Maestro v1.0; corrige conflicto con interpretación técnica anterior |
| LOT-EVT-020 | Toda transición de estado de evento, combinación, reserva, orden y boleto debe conservar actor/proceso, motivo y fecha oficial. | Backend y base de datos | Tablas de status_history y correlation_id. | Completar ciclo publicación→venta→cierre→resultado. | Existe una secuencia histórica completa y ordenada. | Plan Técnico v1.0 |

## 6. Premios, fondos, resultados e informes

| Identificador | Descripción | Responsable | Validación | Prueba | Resultado esperado | Origen |
|---|---|---|---|---|---|---|
| LOT-PRZ-001 | Gana el premio mayor el boleto vendido cuya combinación coincida exactamente con el resultado; por unicidad existe como máximo un ganador exacto. | Backend y base de datos | Evaluación por normalized_key y UNIQUE de combinación vendida. | Evaluar un evento con y sin combinación ganadora vendida. | Se identifica cero o un ganador mayor. | Maestro v1.0 |
| LOT-PRZ-002 | Todo boleto que acierte exactamente todos menos un valor recibe una devolución igual al precio base pagado, acreditada como VIRTUAL. | Backend | Motor de evaluación por distancia y award_category única. | Evaluar boletos a distancia 1, 0 y 2. | Solo distancia 1 recibe la devolución secundaria. | Maestro v1.0 |
| LOT-PRZ-003 | El premio mayor se compone de premio inicial garantizado, crecimiento por ventas y acumulado extraordinario. | Backend y base de datos | Campos separados y suma derivada. | Agregar ventas y acumulado a un evento. | La interfaz y el informe muestran componentes y total coherentes. | Maestro v1.0 |
| LOT-PRZ-004 | El multiplicador inicial recomendado es cinco veces el precio del boleto y solo puede publicarse con cobertura suficiente. | Backend y administración | Simulador económico y reserva de garantía. | Configurar un premio inicial superior a la cobertura. | El semáforo es rojo y la publicación se bloquea. | Maestro v1.0 |
| LOT-PRZ-005 | El crecimiento equivale al 90 % del excedente elegible y no puede superar el techo financiado del evento; el 10 % restante cubre operación, reserva y redondeo. Durante la ventana en que el evento todavía puede cancelarse, crecimiento y recuperación de garantía son proyecciones respaldadas por `DRAW_SALES_FUND`: el saldo bruto de ventas no se distribuye irrevocablemente. Los traspasos contables de liquidación se ejecutan solo después de fijar el resultado. | Backend y base de datos | Cálculo versionado con enteros, proyección reconciliable y guarda de liquidación posterior a `RESULTADO_FIJADO`. | Simular ventas por debajo/encima del techo, mostrar crecimiento, cancelar antes del resultado y liquidar después del resultado. | El crecimiento nunca es negativo ni excede el techo; una cancelación conserva fondos suficientes para devolver el 100 % y la liquidación posterior no duplica asignaciones. | Maestro v1.0 + integridad de cancelación |
| LOT-PRZ-006 | El premio publicado y acreditado usa redondeo a cuartos: 0,00–0,12→0,00; 0,13–0,37→0,25; 0,38–0,62→0,50; 0,63–0,87→0,75; 0,88–0,99→siguiente entero. | Backend | Función de redondeo versionada y conservación del valor exacto. | Probar todos los límites y valores adyacentes. | Cada valor produce el cuarto correcto y conserva el exacto en auditoría. | Maestro v1.0 |
| LOT-PRZ-007 | El fondo general de garantía mantiene reservas independientes por evento y el mismo saldo no puede cubrir dos obligaciones. | Backend y base de datos | Locks de fondo y guarantee_fund_reservations. | Publicar simultáneamente dos eventos que exceden el disponible conjunto. | Solo se reservan eventos cubiertos; no hay doble uso del saldo. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-PRZ-008 | El mínimo requerido del fondo es fondo base de emergencia más obligaciones reservadas; si se incumple, se suspende la publicación automática. | Backend, worker y administración | Cálculo de mínimo y guardia de autogenerador. | Reducir el fondo por debajo del mínimo. | No se publican nuevos eventos y se genera alerta. | Maestro v1.0 |
| LOT-PRZ-009 | Si no hay ganador y se alcanzó la meta mínima, el premio no entregado se distribuye 50 % acumulado, 25 % garantía, 15 % premios futuros y 10 % operación. | Backend y base de datos | Regla versionada y asientos por destino. | Liquidar un evento elegible sin ganador. | La suma distribuida coincide con el total y cada fondo recibe su porcentaje. | Maestro v1.0 |
| LOT-PRZ-010 | Si no se alcanzó la meta mínima, no se genera el acumulado del 50 %; primero se pagan devoluciones, se repone garantía y se cubren obligaciones. | Backend | Motor económico con escenarios y orden de prelación. | Liquidar evento de baja venta sin ganador. | No se crea acumulado indebido y se respetan obligaciones prioritarias. | Maestro v1.0 |
| LOT-PRZ-011 | El acumulado se asigna al siguiente evento cronológico elegible del mismo producto; si el receptor se cancela, vuelve al pool del producto. | Backend y worker | FK/transferencia idempotente y pool por producto. | Asignar acumulado y cancelar el receptor. | El monto retorna íntegro al pool y no se duplica. | Maestro v1.0 |
| LOT-PRZ-012 | La semilla secreta se genera criptográficamente y se publica un commitment antes del cierre, sin revelar la semilla. | Backend y worker | CSPRNG, cifrado en reposo y SHA-256. | Verificar commitment antes y después de revelar la semilla. | Coincide al revelar y no permite conocer el resultado anticipadamente. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-PRZ-013 | Al cerrar ventas se congela determinísticamente el conjunto de boletos y se calcula un snapshot_hash. | Worker y base de datos | Orden estable, snapshot persistente y hash SHA-256. | Recalcular el hash con el mismo conjunto y con un boleto alterado. | El mismo conjunto produce el mismo hash; la alteración produce otro. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-PRZ-014 | El resultado se genera una sola vez desde la semilla final, usa selección sin reemplazo, se valida y queda inmutable. | Worker, backend y base de datos | UNIQUE(draw_event_id), validación de universo/cardinalidad y transacción. | Ejecutar draw-generate varias veces y en paralelo. | Existe un único resultado válido e idéntico para todos los reintentos. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-PRZ-015 | La animación solo revela el resultado ya fijado y puede omitirse; recargar o cambiar dispositivo nunca genera otro resultado. | Web/móvil y backend | Endpoint de resultado inmutable; animación local. | Reproducir, omitir y recargar la animación. | Siempre se muestran los mismos valores oficiales. | Maestro v1.0 |
| LOT-PRZ-016 | Premios y devoluciones se acreditan automáticamente en VIRTUAL al publicarse el informe, con clave única evento+boleto+categoría. | Worker, backend y base de datos | award_payment_order idempotente y UNIQUE. | Publicar informe, interrumpir proceso y reintentar. | Cada premio se acredita exactamente una vez. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-PRZ-017 | Si el asiento del premio existe pero la proyección no se actualizó, se repara la proyección y nunca se crea un segundo premio. | Worker y base de datos | Reconciliación por ledger_transaction_id. | Simular fallo entre libro y proyección. | El saldo visible se corrige sin nueva transacción económica. | Maestro v1.0 |
| LOT-PRZ-018 | El informe público contiene resultado, cifras agregadas, distribución, hashes y estado, pero no identidad, contacto, documento ni wallet de ganadores. | Backend y reporting | DTO público con allowlist y pruebas de fuga de datos. | Generar informe con ganador real y revisar JSON/HTML/PDF. | No aparece ningún dato personal y los hashes son verificables. | Maestro v1.0 y Plan Técnico v1.0 |

## 7. Sorteos creados por usuarios, códigos, expulsiones y reclamos

| Identificador | Descripción | Responsable | Validación | Prueba | Resultado esperado | Origen |
|---|---|---|---|---|---|---|
| LOT-ORG-001 | Cualquier usuario registrado y ACTIVO puede crear un sorteo de usuario y se convierte en Organizador contextual de ese sorteo. | Backend y base de datos | owner/organizer_user_id obligatorio y guardia de estado. | Crear sorteo con cuenta activa y suspendida. | La activa puede crear; la suspendida no. | Decisión aprobada posterior |
| LOT-ORG-002 | Un sorteo de usuario puede ser PÚBLICO o PRIVADO. El público aparece en listados; el privado solo es accesible mediante mecanismo autorizado. | Backend | visibility enum y filtros de consulta. | Consultar ambos sin credenciales/código. | El público aparece; el privado no revela datos protegidos. | Decisión aprobada posterior |
| LOT-ORG-003 | El Organizador define como mínimo premio o producto, rango inicial de números, precio de participación, visibilidad, apertura y cierre. El resultado se determina por el servidor entre participaciones pagadas y activas conforme a LOT-ORG-022. Puede publicar anuncios internos para participantes. | Backend | DTO versionado, validaciones obligatorias y FK a política de resultado. | Crear sorteo sin un dato obligatorio y crear otro válido sin anuncios. | La creación incompleta se rechaza; el sorteo válido se crea sin exigir anuncios. | Decisión aprobada posterior + resolución PEND-ORG-001 |
| LOT-ORG-004 | El rango de números de un sorteo de usuario puede ampliarse; la ampliación no puede reasignar, invalidar ni modificar números ya reclamados o pagados. | Backend y base de datos | Comando expand_range y UNIQUE(draw_id, number_key). | Ampliar rango con participantes existentes y tratar de reutilizar un número ocupado. | La expansión añade solo nuevos números; el ocupado permanece intacto. | Decisión aprobada posterior + derivada de integridad |
| LOT-ORG-006 | La plataforma separa 5 % de cada participación confirmada en una cuenta de **comisión retenida y reversible**; el 95 % restante se acredita a una cuenta de custodia VIRTUAL del sorteo. Ninguno de los dos importes se considera liquidado mientras pueda corresponder reembolso. | Backend y base de datos | Asientos separados: comisión retenida 5 % y escrow 95 %; política de `LOT-FIN-013`; restricciones por moneda y estado. | Confirmar una participación de 100,00 VIRTUAL y luego cancelar antes de la liquidación. | Se registran 5,00 retenidos y 95,00 en custodia; al cancelar, ambos componentes se revierten una sola vez y el pagador recupera 100,00. | Decisión aprobada posterior + resolución PEND-ORG-009 y PEND-ORG-010 |
| LOT-ORG-007 | Los anuncios de un sorteo de usuario solo son visibles para participantes vinculados y administradores autorizados. | Backend | Política por membership/participation. | Consultar anuncios como usuario externo. | La API no devuelve el contenido. | Decisión aprobada posterior |
| LOT-ORG-008 | El Organizador puede cancelar su sorteo antes de fijar el resultado. La cancelación conserva el historial, devuelve íntegramente en VIRTUAL cada participación pagada y revierte proporcionalmente la comisión de plataforma; si la causa es un fallo de la plataforma, esta absorbe cualquier diferencia. | Backend, worker y base de datos | Reembolsos y reversos idempotentes por participación; estado CANCELADO; asientos compensatorios enlazados. | Cancelar con varias participaciones y reintentar el job. | Cada participante recibe un único reembolso total; escrow y comisión quedan revertidos o compensados de forma balanceada. | Decisión aprobada posterior + resolución PEND-ORG-010 |
| LOT-ORG-009 | Un sorteo de usuario, participación, número, código, pago, salida, expulsión o reclamo no se elimina físicamente cuando tiene historial. | Backend y base de datos | Soft delete/estado y FKs restrictivas. | Intentar borrar un sorteo con participantes. | La eliminación se rechaza; solo puede cambiar a estado histórico permitido. | Decisión aprobada posterior + trazabilidad |
| LOT-ORG-010 | Los códigos privados no dependen de que el destinatario tenga una cuenta creada al momento de emitirse. | Backend y base de datos | claimed_by_user_id nullable hasta reclamación. | Crear código sin usuario destinatario y reclamarlo luego de registrarse. | El código se crea y posteriormente queda asociado al reclamante válido. | Decisión aprobada posterior |
| LOT-ORG-011 | Cada código privado se vincula inicialmente al sorteo, a uno o varios números, al **precio total del código**, al Organizador, al estado de pago, a la fecha de creación y al estado de uso. Un grupo de números no multiplica silenciosamente el precio ni la comisión. | Backend y base de datos | Campos obligatorios, relación código↔números, precio total único y checks de consistencia. | Crear código sin sorteo/precio, con números repetidos o interpretar el precio total como precio por cada número. | La operación inválida se rechaza y el código conserva un único importe económico para todo su grupo. | Decisión aprobada posterior + normalización económica |
| LOT-ORG-012 | El código puede incluir un comentario opcional del Organizador, pero el comentario no reserva identidad ni impide que otra cuenta autorizada lo reclame. | Backend | Campo note no vinculante y política de claim independiente. | Emitir “para Juan” y reclamar con otra cuenta válida. | La reclamación depende del código y sus reglas, no del texto del comentario. | Decisión aprobada posterior |
| LOT-ORG-013 | Un código privado es de un solo uso y su reclamación debe ser atómica. | Backend y base de datos | UNIQUE(code_id) de claim, lock de fila y estado CLAIMED. | Dos cuentas reclaman simultáneamente el mismo código. | Solo una queda asociada; la otra recibe código ya utilizado. | Decisión aprobada posterior |
| LOT-ORG-014 | Al reclamar un código se registra la cuenta, fecha, dispositivo/correlación y todas las asignaciones de número. La reclamación crea una única participación económica con una o varias asignaciones. Si el código ya está `PAGADO`, la participación hereda el precio total y referencia la misma operación contable sin volver a debitar; si está `PENDIENTE`, permanece no elegible hasta confirmar el pago antes del cierre. | Backend y auditoría | Registro de reclamación inmutable, tabla participación↔números, enlace al pago original y evento contable únicamente cuando aún corresponda cobrar. | Reclamar códigos de uno y varios números, pagados y pendientes; repetir la reclamación y revisar ledger/snapshot. | No hay doble cobro ni multiplicación del precio; cada número activo genera una entrada elegible separada en el snapshot. | Decisión aprobada posterior + integridad contable |
| LOT-ORG-015 | El acceso privado puede realizarse mediante código con secreto de un solo uso o invitación. Todo código tiene `expires_at`, no puede vencer después del cierre y su secreto se almacena mediante hash. Un código pendiente reserva sus números hasta expirar; al expirar se liberan atómicamente. | Backend, worker y seguridad | Hash del secreto, consumo único, `expires_at <= sales_close_at`, job de expiración y lock de números. | Reutilizar un código, reclamarlo después de expirar y ejecutar dos expiraciones concurrentes. | La reutilización y el uso tardío se rechazan; los números se liberan una sola vez. | Decisión aprobada posterior + resolución PEND-ORG-006 |
| LOT-ORG-016 | El Organizador debe ver el historial completo de movimientos de su sorteo: código usado, cuenta reclamante, cambios de número, compras adicionales, devoluciones, salidas, expulsiones y reclamos. | Backend y base de datos | Timeline derivada de eventos inmutables y permisos por organizer_user_id. | Ejecutar cada movimiento y consultar historial. | Todos aparecen en orden con actor, fecha y referencia. | Decisión aprobada posterior |
| LOT-ORG-017 | Un participante puede cambiar una de sus asignaciones de número únicamente antes del cierre y hacia un número disponible. No existe un máximo comercial global de cambios; se aplican límites técnicos y antifraude. Las compras adicionales crean nuevas participaciones económicas hasta el cierre y cada asignación debe ser atómica. | Backend y base de datos | Guardia `now < sales_close_at`, UNIQUE parcial por sorteo+número activo, locks y rate limit. | Cambiar después del cierre, cambiar a número ocupado, cambiar un número dentro de una participación grupal y comprar adicional un segundo antes/después del cierre. | Solo operaciones anteriores al cierre y con números disponibles se confirman; todo cambio conserva asignación anterior y nueva sin alterar el precio total histórico. | Decisión aprobada posterior + resolución PEND-ORG-004 |
| LOT-ORG-018 | El Organizador puede expulsar a un participante solo antes del cierre y con motivo obligatorio. Si existe participación pagada, se realiza reembolso íntegro, se revierte la comisión proporcional y se libera el número; después del cierre solo un Administrador puede aplicar una medida mediante resolución de reclamo. La expulsión conserva todo el historial y el derecho a reclamar. | Backend, worker y base de datos | Guardia temporal, motivo obligatorio, reembolso idempotente, liberación atómica y audit_event. | Expulsar antes y después del cierre a un participante pagado. | Antes del cierre se reembolsa y libera una sola vez; después del cierre la acción directa se rechaza. | Decisión aprobada posterior + resolución PEND-ORG-003 |
| LOT-ORG-019 | Un participante puede abandonar antes del cierre. Si su participación está pendiente o no pagada, se cancela y libera el número; si está pagada, el abandono es definitivo, no genera reembolso automático y el número permanece activo y elegible para evitar manipulación del sorteo. Después del cierre no se permite abandonar. El historial siempre permanece visible. | Backend y base de datos | Máquina de estados según pago y hora, advertencia/confirmación explícita y evento de historial. | Abandonar una participación pendiente, una pagada y otra después del cierre. | La pendiente libera el número; la pagada conserva número y elegibilidad sin reembolso; la posterior al cierre se rechaza. | Decisión aprobada posterior + resolución PEND-ORG-003 |
| LOT-ORG-020 | Un participante puede presentar un reclamo sobre acceso, pago, número, devolución, salida, expulsión, resultado, premio o entrega dentro de 7 días calendario desde el hecho reclamado o desde la fecha límite de entrega. El Organizador puede responder y aportar evidencia, pero solo un Administrador autorizado resuelve. | Backend y administración | Validación de plazo, claim ligado a sorteo/participación, evidencia y permisos. | Crear reclamo dentro y fuera del plazo y tratar de resolverlo como Organizador. | El reclamo oportuno se admite; el tardío se rechaza salvo reapertura administrativa motivada; el Organizador no puede resolver. | Decisión aprobada posterior + resolución PEND-ORG-005 |
| LOT-ORG-021 | Los reclamos usan estados PRESENTADO, EN_REVISION, ESPERANDO_EVIDENCIA, RESUELTO, RECHAZADO, APELADO y CERRADO. La resolución conserva decisión, motivo, evidencia, actor, fechas y compensaciones. La apelación puede presentarse dentro de 3 días calendario; la revisión administrativa tiene objetivo de 5 días hábiles, sin alterar automáticamente derechos por incumplimiento del SLA. | Backend, base de datos y auditoría | Máquina de estados, plazos, decisión inmutable y ledger compensation enlazada. | Resolver, apelar dentro/fuera de plazo y consultar el historial completo. | Solo transiciones y apelaciones válidas se aceptan; nunca se pierde ni reescribe el historial original. | Decisión aprobada posterior + resolución PEND-ORG-005 |
| LOT-ORG-022 | El ganador se determina exclusivamente en el servidor mediante aleatoriedad criptográficamente segura entre **asignaciones de número** pertenecientes a participaciones `PAGADO` y con elegibilidad `ACTIVA` al cierre. Una participación grupal aporta una entrada por cada asignación activa. Antes de generar el resultado se congela un snapshot ordenado y se publica su hash; el resultado se fija una sola vez y es inmutable. La evidencia pública permite verificar la integridad del snapshot y del resultado, pero este módulo no hereda el protocolo commit-reveal de la lotería oficial ni afirma verificabilidad independiente de la entropía. | Backend, worker y base de datos | Snapshot determinista de asignaciones, CSPRNG, UNIQUE(draw_id), hashes públicos, versión de algoritmo, job/correlación e idempotencia. | Reintentar la generación, usar una participación con varios números, alterar el conjunto después del cierre y verificar hashes/alcance de la evidencia. | Existe un único número ganador perteneciente al snapshot; cada número elegible tiene una entrada; los reintentos devuelven el mismo resultado y cualquier alteración del conjunto/resultado se detecta sin confundirlo con commit-reveal oficial. | Resolución PEND-ORG-001 + soporte de códigos grupales |
| LOT-ORG-023 | La plataforma no custodia físicamente premios o productos en el MVP. Antes de publicar, el Organizador debe declarar el premio y aportar evidencia suficiente de existencia o disponibilidad. Tras el resultado, registra entrega; el ganador confirma recepción o abre reclamo. Si se acredita incumplimiento del Organizador, el Administrador puede ordenar reembolso total a participantes desde el escrow y bloquear la liquidación. | Backend, administración y auditoría | Evidencia versionada, estados de entrega, confirmación del ganador y hold del escrow. | Publicar sin evidencia, confirmar entrega y simular incumplimiento con reclamo aceptado. | Sin evidencia no se publica; la entrega queda trazada; el incumplimiento impide liquidar y habilita compensación. | Resolución PEND-ORG-002 |
| LOT-ORG-024 | Tras el primer pago confirmado quedan inmutables premio/producto, precio, visibilidad, reglas de adjudicación, apertura, cierre y rango ya publicado. Solo se permiten anuncios y ampliación del rango antes del cierre, sin modificar números existentes ni condiciones de participaciones previas. | Backend y base de datos | Guardia `has_confirmed_payment`, lista blanca de campos modificables y comando separado de ampliación. | Intentar cambiar precio, premio, visibilidad, cierre y luego publicar un anuncio/ampliar rango. | Los cambios económicos o estructurales se rechazan; anuncio y ampliación válida pueden confirmarse. | Resolución PEND-ORG-008 |
| LOT-ORG-025 | El 95 % en custodia se liquida al Organizador únicamente cuando el resultado está fijado y la entrega fue confirmada por el ganador, o cuando un Administrador autoriza la liquidación tras resolver una disputa. En esa misma liquidación, el 5 % retenido se devenga a plataforma. Antes de ello ningún componente puede tratarse como saldo disponible definitivo. `LIBERADA` es terminal: una compensación financiera ordenada después de la liquidación no reabre ni sobregira el escrow; se paga desde una cuenta de compensación de plataforma y cualquier recuperación frente al Organizador se tramita como operación administrativa separada, nunca creando saldo negativo no autorizado. | Backend, base de datos y administración | Cuenta escrow por sorteo, cuenta de comisión retenida, estados de hold/release, orden de liquidación idempotente, cuenta de compensación y permiso reforzado. | Intentar retirar antes de entrega, liberar tras confirmación, repetir la orden y ordenar una compensación después de `LIBERADA`. | El retiro anticipado se rechaza; la liquidación ocurre una sola vez; una compensación posterior no modifica el escrow liquidado y acredita al afectado mediante operación separada y balanceada. | Resolución PEND-ORG-009 y PEND-ORG-010 + integridad contable |
| LOT-ORG-026 | La verificación automática con cédula ecuatoriana queda formalmente fuera del MVP por requerir definición legal, proveedor, seguridad y retención de datos. El MVP usa verificación de correo/teléfono y controles antifraude; el esquema puede reservar un estado genérico de verificación, pero no almacenar imágenes ni validaciones de cédula sin una ADR futura. | Arquitectura, backend y seguridad | Feature flag deshabilitada, ausencia de campos/documentos sensibles obligatorios y ADR previa para activación. | Intentar activar el flujo de cédula en MVP. | El flujo no está disponible y no se recopilan datos adicionales de identidad. | Exclusión formal PEND-ORG-007 |

> **ID reservado:** `LOT-ORG-005` no se reutiliza. La decisión de inmutabilidad quedó finalmente aprobada y formalizada como `LOT-ORG-024`, conservando el hueco para mantener trazabilidad histórica.

## 8. Auditoría, seguridad, workers, migraciones y pruebas

| Identificador | Descripción | Responsable | Validación | Prueba | Resultado esperado | Origen |
|---|---|---|---|---|---|---|
| LOT-AUD-001 | Toda acción financiera, administrativa, de seguridad, resultado, código, expulsión y reclamo debe registrar auditoría con actor/proceso, modo, recurso, motivo, correlation_id y fecha. | Backend y base de datos | audit_events obligatorio en casos de uso críticos. | Ejecutar operaciones críticas y buscar auditoría por correlation_id. | Cada operación posee un evento correlacionado suficiente para reconstrucción. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-AUD-002 | Cuando corresponda, la auditoría conserva valores antes/después, IP aproximada y dispositivo, evitando contraseñas, tokens, CVV, semillas secretas no reveladas y datos sensibles innecesarios. | Backend y seguridad | Allowlist/redacción de campos y pruebas de logs. | Enviar secretos en una petición fallida y revisar logs. | Los secretos no aparecen; los metadatos necesarios sí. | Maestro v1.0 y Plan Técnico v1.0 |
| LOT-AUD-003 | Los cambios de rol, estado, permisos, fondos, eventos, resultados y decisiones de reclamos requieren motivo explícito. | Backend y administración | DTO reason obligatorio y check no vacío. | Ejecutar acción administrativa sin motivo. | La API rechaza la acción. | Plan Técnico v1.0 |
| LOT-AUD-004 | Los procesos asíncronos críticos deben ser persistentes, reintentables e idempotentes; reiniciar el worker no puede perder expiraciones, sorteos, reembolsos ni pagos. | Worker, Redis y PostgreSQL | scheduled_jobs/job_runs, BullMQ y estado persistido. | Reiniciar worker durante un job. | El job continúa o reintenta sin duplicar efectos. | Plan Técnico v1.0 |
| LOT-AUD-005 | Redis puede apoyar colas, rate limiting, caché y locks auxiliares, pero la exclusión definitiva depende de transacciones y restricciones PostgreSQL. | Backend, worker y base de datos | Locks SQL/UNIQUE en operaciones críticas. | Eliminar lock Redis durante compras simultáneas. | La base sigue impidiendo doble venta o doble pago. | Plan Técnico v1.0 |
| LOT-AUD-006 | Los endpoints sensibles aplican rate limiting por IP, usuario, dispositivo y tipo de operación, con controles reforzados en login, códigos, compra y conversiones. | Backend y seguridad | Rate limiter y security_events. | Enviar ráfagas sobre login y claim de código. | Las solicitudes abusivas se limitan sin ejecutar efectos múltiples. | Plan Técnico v1.0 |
| LOT-AUD-007 | Las migraciones se versionan, no se editan después de aplicarse y los cambios financieros incluyen estrategia de avance seguro o compensación. | Base de datos y Git | Prisma migrations inmutables, revisión de PR y CI. | Modificar una migración aplicada y ejecutar CI. | La revisión/CI lo detecta y exige una nueva migración. | Plan Técnico v1.0 |
| LOT-AUD-008 | Cada regla de este documento debe tener al menos una prueba automatizada; concurrencia, idempotencia, dinero y estados terminales requieren pruebas de integración con PostgreSQL real. | Equipo de desarrollo y QA | Matriz regla→test y pipeline CI. | Ejecutar verificador de cobertura de trazabilidad. | Ninguna regla crítica queda sin test asociado. | Plan Técnico v1.0 + objetivo de esta fase |
| LOT-AUD-009 | Antes de comenzar el SQL de un módulo, sus decisiones abiertas deben estar resueltas o declaradas explícitamente fuera de alcance; el esquema no debe inventar reglas. | Arquitectura, producto y base de datos | Checklist de congelamiento y ADR/versión documental. | Intentar modelar un campo cuyo comportamiento no está definido. | Se bloquea la migración hasta aprobar la decisión o excluir el flujo. | Principio de no deformación |


## 8.1 Acta de revisión y aprobación de reglas `LOT-*`

**Fecha de revisión:** 26 de julio de 2026  
**Versiones previas:** 1.2.0 y 1.3.0; baseline final cerrada en v1.4.0  
**Universo documental:** 113 identificadores `LOT-*`: 112 reglas activas y 1 ID reservado (`LOT-ORG-005`).  

### Resultado

- **112 reglas activas aprobadas plenamente** para convertirse en contratos de backend, restricciones de PostgreSQL, workers y pruebas.
- Las 9 reglas que estuvieron condicionadas permanecen **aprobadas plenamente** tras la resolución formal de `PEND-ORG-001` a `PEND-ORG-010`.
- **Ninguna regla `LOT-*` fue rechazada.** Las antiguas condiciones quedaron cerradas mediante `ADR-ORG-001`.
- `LOT-ORG-005` permanece reservado y no cuenta como regla activa.

### Correcciones realizadas durante la aprobación

1. `LOT-IAM-001`: Organizador se define como **capacidad contextual**, no como rol global.
2. `LOT-EVT-007`: la inmutabilidad usa una lista explícita de estados y no una comparación ordinal como `status >= PUBLICADO`.
3. `LOT-ORG-003`: los anuncios internos son opcionales; no bloquean la creación del sorteo.
4. `LOT-FIN-013`: se resolvió la política de minor units y residuos porcentuales; deja de existir el último bloqueo económico transversal.

### Alcance de la aprobación

La baseline v1.4.0 permite continuar los documentos de estados, permisos, flujos financieros y diccionario de datos tanto del núcleo oficial como de `user_draws`. La verificación automática con cédula permanece excluida del MVP.

## 9. Registro formal de resolución de `PEND-ORG-*`

Las decisiones que bloqueaban el SQL del módulo de sorteos creados por usuarios quedan cerradas mediante `ADR-ORG-001`. Nueve se resuelven para el MVP y una se excluye formalmente.

| ID | Estado | Decisión aprobada | Reglas resultantes |
|---|---|---|---|
| PEND-ORG-001 | RESUELTA | Resultado generado por el servidor con CSPRNG entre participaciones pagadas y activas; snapshot y hash público; resultado único e inmutable. | LOT-ORG-003, LOT-ORG-022 |
| PEND-ORG-002 | RESUELTA | La plataforma no custodia el objeto físico; exige evidencia antes de publicar, registra entrega y retiene escrow hasta confirmación o resolución administrativa. | LOT-ORG-023, LOT-ORG-025 |
| PEND-ORG-003 | RESUELTA | Expulsión pagada antes del cierre: reembolso total y liberación. Abandono pagado: sin reembolso, número permanece elegible. Después del cierre no se permiten acciones ordinarias. | LOT-ORG-018, LOT-ORG-019 |
| PEND-ORG-004 | RESUELTA | Cambios y compras adicionales solo antes del cierre; cambios únicamente a números disponibles; sin máximo comercial global, con controles técnicos. | LOT-ORG-017 |
| PEND-ORG-005 | RESUELTA | Reclamo dentro de 7 días; apelación dentro de 3 días; estados oficiales y objetivo administrativo de 5 días hábiles. | LOT-ORG-020, LOT-ORG-021 |
| PEND-ORG-006 | RESUELTA | Código de un uso con expiración obligatoria no posterior al cierre; reserva número hasta uso o expiración; liberación idempotente. | LOT-ORG-015 |
| PEND-ORG-007 | EXCLUIDA DEL MVP | No se implementa verificación automática con cédula ecuatoriana hasta contar con ADR legal/técnica, proveedor y política de datos. | LOT-ORG-026 |
| PEND-ORG-008 | RESUELTA | Primer pago congela condiciones económicas y estructurales. Solo anuncios y ampliación válida del rango permanecen permitidos antes del cierre. | LOT-ORG-024 |
| PEND-ORG-009 | RESUELTA | El 95 % queda en escrow VIRTUAL y se libera tras resultado y entrega confirmada o resolución administrativa. | LOT-ORG-006, LOT-ORG-025 |
| PEND-ORG-010 | RESUELTA | Cancelación, expulsión reembolsable o corrección imputable al Organizador revierten comisión proporcional; fallos de plataforma son absorbidos por la plataforma; el participante recibe el 100 %. | LOT-ORG-008, LOT-ORG-018 |

> **Autorización:** el módulo `user_draws` queda habilitado para diseñar su máquina de estados, flujos contables, permisos, diccionario de datos y SQL. La verificación con cédula continúa fuera del alcance y no debe modelarse como requisito operativo del MVP.

## 10. Trazabilidad obligatoria

Cada implementación debe mantener una matriz con estas columnas:

```text
rule_id | módulo | endpoint/job | servicio | tabla/restricción | prueba | estado
```

Ejemplo:

```text
LOT-EVT-001 | combinations | POST /api/v1/purchases/confirm | PurchaseService |
UNIQUE(draw_event_id, normalized_key) | purchase.same-combination.concurrent.spec.ts | PENDIENTE
```

Una regla solo se considera implementada cuando:

1. Existe validación en la capa adecuada.
2. Existe restricción de base de datos cuando la integridad lo exige.
3. Existe prueba automatizada.
4. La prueba demuestra el resultado esperado.
5. El código y la migración referencian el identificador de la regla.

## 11. Política de cambios

- No editar silenciosamente una regla ya usada por migraciones o eventos.
- Todo cambio crea una nueva versión de este documento y registra motivo, impacto, responsable y reglas afectadas.
- Un cambio económico o de estados exige revisar migraciones, OpenAPI, workers, matriz de permisos, modelo de amenazas y pruebas.
- Las reglas no se simplifican para adaptar el código; se corrige la arquitectura.

## 12. Checklist de aprobación antes del SQL

- [x] Revisar y aprobar todas las reglas `LOT-*` — aprobación inicial en v1.2.0 y cierre completo en v1.4.0 con 112 reglas activas plenamente aprobadas.
- [x] Resolver o excluir formalmente `PEND-ORG-001` a `PEND-ORG-010` — 9 resueltas y 1 excluida del MVP mediante `ADR-ORG-001`.
- [x] Crear y aprobar `docs/ESTADOS-Y-TRANSICIONES.md` usando los identificadores de este documento.
- [x] Crear y aprobar `docs/FLUJOS-FINANCIEROS.md` y verificar doble entrada por cada operación.
- [x] Crear y aprobar `docs/MATRIZ-DE-PERMISOS.md` para rol, modo y recurso.
- [x] Crear y aprobar `docs/DICCIONARIO-DE-DATOS.md` antes del `schema.prisma` final.
- [ ] Crear la matriz regla→prueba.
- [ ] Aprobar la primera migración antes de ejecutarla.

## 13. Resumen cuantitativo

- **Reglas activas congeladas:** 112
- **GOV:** 8 reglas — Gobierno, autoridad y principios transversales
- **IAM:** 9 reglas — Identidad, roles y permisos
- **FIN:** 13 reglas — Wallets, dinero y libro contable
- **VND:** 10 reglas — Vendedores y solicitudes Cliente–Vendedor
- **EVT:** 20 reglas — Eventos oficiales, combinaciones, reservas y boletos
- **PRZ:** 18 reglas — Premios, fondos, resultados e informes
- **ORG:** 25 reglas — Sorteos creados por usuarios, códigos, expulsiones y reclamos
- **AUD:** 9 reglas — Auditoría, seguridad, workers, migraciones y pruebas
- **Decisiones abiertas del módulo de organizadores:** 0

## 14. Declaración de congelamiento de la baseline v1

- No existen decisiones funcionales o económicas abiertas para comenzar `schema.prisma`, migraciones y backend.
- `LOT-ORG-005` es únicamente un identificador reservado; no representa una función pendiente.
- `LOT-ORG-026` excluye formalmente la verificación automática con cédula del MVP.
- Las decisiones de proveedor, despliegue, retención o particionado que no cambien estas reglas pueden definirse durante implementación técnica.
- Cualquier comportamiento que contradiga o amplíe esta baseline pertenece a una versión futura del producto y no puede introducirse silenciosamente en la versión 1.

> **Baseline congelada:** toda implementación v1 debe demostrar trazabilidad desde cada efecto crítico hasta una regla `LOT-*` activa.
