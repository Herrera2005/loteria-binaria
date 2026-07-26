---
title: "Documento Maestro de Reglas del Sistema Lotería Binaria"
subtitle: "Especificación funcional, económica, operativa, de seguridad y arquitectura"
author: "Proyecto académico de Cristhian Herrera Nieto"
date: "19 de julio de 2026"
lang: es-EC
---

# CONTROL DEL DOCUMENTO

## Identificación

| Campo | Valor |
|---|---|
| Nombre oficial | Documento Maestro de Reglas del Sistema Lotería Binaria |
| Versión | 1.0 |
| Estado | Base funcional aprobada para diseño técnico |
| Fecha de emisión | 19 de julio de 2026 |
| Propietario funcional | Proyecto Lotería Binaria |
| Autor académico | Cristhian Herrera Nieto |
| Alcance | Plataforma web, API central, base de datos y aplicación móvil |
| Documento reemplazado | Prompts, reglas y supuestos del frontend demostrativo anterior, salvo las reglas expresamente conservadas en este documento |

## Propósito y carácter normativo

Este documento constituye la **fuente principal de verdad funcional** del proyecto Lotería Binaria. Su objetivo es reunir, ordenar y formalizar todas las decisiones alcanzadas sobre el sistema, evitando que en futuras etapas se pierdan reglas, se mezclen versiones antiguas o se inventen comportamientos incompatibles.

Cuando exista una contradicción entre este documento y el frontend demostrativo anterior, prevalece este documento. El proyecto HTML, CSS, JavaScript, JSON y `localStorage` existente se conserva únicamente como **referencia visual, de navegación y de presentación académica**. No se considera arquitectura final, base de datos, mecanismo de seguridad ni fuente de verdad.

Las palabras **DEBE**, **NO DEBE**, **PUEDE**, **RECOMENDADO** y **OPCIONAL** se utilizan con sentido normativo:

- **DEBE:** requisito obligatorio.
- **NO DEBE:** prohibición obligatoria.
- **PUEDE:** comportamiento permitido.
- **RECOMENDADO:** decisión preferida que puede parametrizarse sin romper el modelo.
- **OPCIONAL:** funcionalidad no necesaria para la primera versión.

## Principio de no deformación

Las futuras implementaciones, refactorizaciones, migraciones tecnológicas y aplicaciones móviles deben respetar las reglas funcionales aquí descritas. Cualquier cambio sustancial debe producir una nueva versión del documento, con fecha, motivo, impacto y responsable.

# 1. RESUMEN EJECUTIVO

Lotería Binaria es una plataforma de sorteos digitales inspirada en conceptos de lotería combinatoria y en el modelo económico de premios crecientes del bingo electrónico. La plataforma utiliza tres universos numéricos:

1. Lotería Octal.
2. Lotería Decimal.
3. Lotería Hexadecimal.

Cada evento vende combinaciones únicas. Una combinación comprada por una persona no puede ser comprada por otra dentro del mismo evento. Los clientes pueden elegir todos sus números, elegir una parte y solicitar alternativas compatibles, completar su selección aleatoriamente o recibir una combinación completamente aleatoria.

El premio mayor comienza con un valor inicial garantizado, crece con las ventas confirmadas y se detiene en un techo configurado. El sistema calcula un techo sostenible recomendado para evitar pérdidas. Los eventos utilizan dinero virtual como unidad de juego; el dinero real se utiliza para recargas, conversiones, solicitudes de clientes a vendedores y retiros.

Los vendedores compran saldo virtual a razón de 0,90 unidades reales por 1,00 unidad virtual. Cuando atienden una solicitud de un cliente, entregan virtual y reciben real a valor 1:1, obteniendo una ganancia realizada de 0,10 por cada unidad vendida. Si nadie completa una solicitud en cinco minutos, la plataforma la atiende automáticamente desde una wallet general de conversión.

Los resultados se generan una sola vez en el servidor, se validan, se guardan de forma inmutable y se comprometen mediante hashes verificables. La animación únicamente revela números ya determinados. Los premios y devoluciones se acreditan automáticamente en saldo virtual al publicarse el informe de resultados.

# 2. OBJETIVOS DEL SISTEMA

## 2.1 Objetivo general

Construir una plataforma robusta, trazable y multiplataforma que permita crear, vender, ejecutar y liquidar sorteos digitales Octales, Decimales y Hexadecimales, administrando usuarios, vendedores, wallets, combinaciones únicas, resultados, premios, acumulados y fondos de seguridad desde una API central.

## 2.2 Objetivos específicos

- Permitir el registro y autenticación real de usuarios.
- Gestionar roles de Cliente, Vendedor y Administrador.
- Administrar saldos reales y virtuales mediante un libro contable.
- Permitir solicitudes de conversión real a virtual atendidas por vendedores o por la plataforma.
- Crear eventos manuales o automáticos con reglas versionadas.
- Mostrar varios eventos disponibles simultáneamente por cada tipo de lotería.
- Evitar la venta duplicada de una combinación dentro de un evento.
- Aplicar límites de compra dinámicos según el tiempo transcurrido.
- Calcular premios crecientes, techo sostenible, devoluciones y reservas.
- Generar resultados seguros, inmutables y públicamente verificables.
- Acreditar premios automáticamente.
- Generar boletines públicos sin exponer identidad de ganadores.
- Preparar una arquitectura común para web y aplicación móvil.

# 3. ALCANCE Y EXCLUSIONES

## 3.1 Incluido en la versión objetivo

- Landing page pública.
- Registro, autenticación y recuperación de acceso.
- Gestión de perfiles y roles.
- Panel de Cliente.
- Panel de Vendedor.
- Panel de Administrador.
- Wallet real y wallet virtual.
- Recarga simulada de saldo real con tarjeta.
- Compra mayorista de virtual para vendedores.
- Solicitudes cliente-vendedor.
- Conversión automática por la plataforma a los cinco minutos.
- Conversión virtual a real con comisión del 10%.
- Transferencias virtuales permitidas entre clientes.
- Gestión de productos Octal, Decimal y Hexadecimal.
- Autogeneración y publicación anticipada de eventos.
- Compra manual, parcial y aleatoria de combinaciones.
- Reservas de combinaciones.
- Límites dinámicos de compra.
- Premio inicial, crecimiento, techo, acumulados y fondos.
- Resultado seguro, animación e informe público.
- Cancelaciones y reembolsos automáticos.
- Auditoría técnica interna.
- API central consumida por web y móvil.

## 3.2 No incluido como requisito inicial

- Revancha como producto adicional.
- Copia exacta del Pozo Millonario o de marcas de Lotería Nacional.
- Cartones tradicionales de bingo de 90 bolas.
- Devolución voluntaria de boletos comprados.
- Bitácora visible para que el cliente observe cada clic o sección visitada.
- Dependencia de notificaciones para que una función sea usable.
- Uso de archivos JSON o `localStorage` como fuente de verdad.
- Almacenamiento directo de datos de tarjetas.

## 3.3 Funcionalidades futuras posibles

- Revancha para eventos con suficiente universo combinatorio.
- Promociones y bonos.
- Referidos.
- Eventos especiales.
- Sorteos privados creados por usuarios, sujeto a reglamento separado.
- Integración con proveedor real de pagos.
- Integración con una fuente externa de aleatoriedad pública.

# 4. PRINCIPIOS RECTORES

1. **Autoridad del servidor:** toda operación sensible se valida en backend.
2. **Fuente única de verdad:** PostgreSQL y el libro contable son la referencia oficial.
3. **Inmutabilidad histórica:** un boleto pagado, un resultado confirmado y un evento con ventas no se alteran silenciosamente.
4. **No doble venta:** una combinación solo puede venderse una vez por evento.
5. **No doble pago:** toda acreditación utiliza idempotencia.
6. **Solvencia:** no se publica un evento sin cobertura suficiente.
7. **Transparencia:** el usuario puede conocer reglas, precio, premio, cierre y resultado.
8. **Privacidad:** el informe público no identifica a los ganadores.
9. **Trazabilidad:** toda operación financiera y administrativa crítica deja auditoría.
10. **Separación de responsabilidades:** web y móvil presentan; la API decide.
11. **Versionado de reglas:** los cambios futuros no modifican eventos históricos.
12. **Recuperación ante fallos:** reinicios o desconexiones no generan resultados, pagos o compras duplicadas.

# 5. GLOSARIO OFICIAL

| Término | Definición |
|---|---|
| Cliente | Usuario autorizado para comprar boletos y participar en sorteos. |
| Vendedor | Usuario que adquiere virtual a precio mayorista y atiende solicitudes de clientes. No participa en sorteos. |
| Administrador | Usuario autorizado para gestionar productos, eventos, usuarios, fondos, resultados e informes. |
| Cliente financiero | Modo disponible para vendedor o administrador que permite operaciones de wallet, pero no compra de boletos. |
| Saldo real | Unidad respaldada por recarga o intercambio, convertible en retiro. |
| Saldo virtual | Unidad usada para boletos, premios, devoluciones y transferencias internas. |
| Producto | Definición general Octal, Decimal o Hexadecimal. |
| Versión de reglas | Configuración inmutable que determina universo, cantidad de selección, premios y comportamiento. |
| Evento | Instancia concreta de un sorteo con fechas, precio, premio y combinaciones. |
| Combinación | Conjunto normalizado de números o símbolos únicos. |
| Boleto | Comprobante de propiedad de una combinación vendida en un evento. |
| Reserva | Bloqueo temporal de una combinación durante una compra. |
| Premio inicial | Valor garantizado con el que comienza un evento. |
| Crecimiento por ventas | Incremento del premio financiado por el excedente elegible del evento. |
| Techo | Máximo permitido para el crecimiento financiado por las ventas del evento. |
| Acumulado extraordinario | Valor heredado y ya financiado que se añade a otro evento del mismo tipo. |
| Devolución | Premio secundario igual al precio base del boleto por acertar todos menos un número. |
| Fondo de garantía | Fondo general que cubre obligaciones iniciales, diferencias y emergencias. |
| Fondo de premios futuros | Fondo destinado a promociones, eventos especiales o refuerzo de premios. |
| Wallet general de conversión | Cuenta de la plataforma que completa solicitudes no atendidas por vendedores. |
| Meta mínima de capital | Recaudación necesaria para cubrir obligaciones y evitar deuda del evento. |
| Informe de resultados | Boletín público emitido después de cada evento. |
| Hash | Huella criptográfica usada para verificar integridad. |
| Idempotencia | Garantía de que repetir una petición no repite el efecto económico. |

# 6. USUARIOS, ROLES Y MODOS DE ACCESO

## 6.1 Roles principales

### Cliente

Puede:

- Comprar boletos.
- Consultar eventos.
- Administrar wallets.
- Crear solicitudes real a virtual.
- Convertir virtual a real.
- Transferir virtual a otros clientes.
- Consultar boletos, resultados y movimientos.

### Vendedor

Puede:

- Comprar saldo virtual a precio mayorista.
- Consultar solicitudes compatibles con su saldo.
- Tomar y confirmar solicitudes.
- Administrar su saldo real y virtual.
- Consultar capital, inventario, ventas y ganancias.
- Convertir virtual a real con la comisión general.

No puede:

- Comprar boletos.
- Participar en sorteos.
- Atender solicitudes propias.
- Atender solicitudes de cuentas relacionadas.
- Transferirse dinero a sí mismo.

### Administrador

Puede, según permisos:

- Gestionar usuarios y roles.
- Gestionar productos y versiones de reglas.
- Configurar autogeneradores.
- Crear, publicar o cancelar eventos.
- Gestionar fondos.
- Supervisar solicitudes y movimientos.
- Publicar informes.
- Consultar auditoría y estadísticas.

## 6.2 Selección de modo después del login

- Un Cliente entra directamente al panel de Cliente.
- Un Vendedor elige entre Vendedor y Cliente financiero.
- Un Administrador elige entre Administrador, Vendedor y Cliente financiero.

El modo Cliente financiero permite wallet, movimientos, conversiones y transferencias permitidas, pero **no permite comprar boletos**. La simple navegación hacia una URL no concede permiso; el backend valida rol y modo activo en cada operación.

## 6.3 Roles múltiples

Un usuario puede poseer varios roles, pero cada sesión mantiene un modo activo. El cambio de modo debe quedar registrado y no debe elevar permisos sin autorización.

# 7. REGISTRO, IDENTIDAD Y AUTENTICACIÓN

## 7.1 Datos de registro

El registro debe solicitar:

- Nombres.
- Apellidos.
- Cédula o documento.
- Fecha de nacimiento.
- Correo electrónico.
- Teléfono.
- Nombre de usuario.
- Contraseña.
- Confirmación de contraseña.
- Aceptación de términos y privacidad.

## 7.2 Validaciones

- Campos obligatorios.
- Correo válido y único.
- Documento único.
- Usuario único.
- Teléfono validable.
- Contraseñas iguales y con política de seguridad.
- Mayoría de edad.
- Términos aceptados y versionados.

## 7.3 Estados de cuenta

- `PENDIENTE_VERIFICACION`
- `ACTIVO`
- `SUSPENDIDO`
- `BLOQUEADO`
- `DESACTIVADO`

No se elimina físicamente una cuenta con historial financiero. Se desactiva o anonimiza según normativa y política de retención.

## 7.4 Seguridad de autenticación

- Contraseñas almacenadas con hash seguro.
- Tokens de acceso de corta duración.
- Tokens de renovación revocables.
- Cierre de sesiones por dispositivo.
- Protección contra fuerza bruta.
- Registro de intentos anómalos.
- Recuperación de contraseña segura.
- Autenticación reforzada para acciones administrativas críticas.

# 8. MODELO MONETARIO

## 8.1 Unidad principal de los sorteos

Todos los precios de boletos, premios, devoluciones, fondos, acumulados y obligaciones de eventos se expresan en **saldo virtual**.

## 8.2 Uso del saldo real

El saldo real se utiliza para:

- Recargas con tarjeta.
- Reservar fondos en solicitudes.
- Pagar virtual a vendedores.
- Recibir real por parte de vendedores.
- Convertir virtual a real.
- Retirar saldo real.

## 8.3 Respaldo y contabilidad

Aunque el juego se exprese en virtual, la plataforma debe conocer la obligación real asociada a la posibilidad de conversión. El sistema debe separar:

- Real de usuarios.
- Virtual de usuarios.
- Virtual emitido.
- Reservas de conversión.
- Fondos de eventos.
- Fondo de garantía.
- Fondo acumulado.
- Fondo de premios futuros.
- Operación y plataforma.
- Comisiones.

## 8.4 Precisión

Todo dinero se guarda internamente en centavos enteros. No se usan flotantes binarios para saldos.

# 9. RECARGA DE SALDO REAL CON TARJETA

## 9.1 Disponibilidad

Todos los tipos de usuario pueden simular una recarga de saldo real mediante tarjeta.

## 9.2 Comisión

La recarga no cobra comisión:

```text
Monto pagado: 100,00 reales
Saldo acreditado: 100,00 reales
Comisión: 0,00
```

## 9.3 Seguridad

- La versión académica simula el proveedor.
- Una versión real no almacena directamente número completo, CVV ni datos sensibles.
- La acreditación real solo ocurre después de confirmación válida del proveedor.
- Los reintentos usan idempotencia.

# 10. CONVERSIÓN REAL A VIRTUAL MEDIANTE SOLICITUDES

## 10.1 Regla principal

Un Cliente no convierte real a virtual de forma directa e inmediata. Debe crear una solicitud que primero puede ser atendida por un Vendedor. La plataforma es el mecanismo de respaldo si nadie la completa en cinco minutos.

## 10.2 Creación

1. El Cliente indica el monto.
2. El sistema verifica saldo real suficiente.
3. El monto real queda reservado.
4. Se crea la solicitud con hora oficial del servidor.
5. La solicitud entra en `PENDIENTE`.

## 10.3 Visibilidad

Solo pueden verla vendedores que:

- Estén activos.
- Tengan saldo virtual disponible suficiente.
- No sean el solicitante.
- No pertenezcan a una cuenta relacionada bloqueada por política antifraude.

## 10.4 Asignación

- El primer vendedor que la toma obtiene una asignación atómica.
- La solicitud pasa a `ASIGNADA` o `EN_PROCESO`.
- Los demás vendedores reciben estado no disponible.
- La asignación no reinicia el plazo de cinco minutos.

## 10.5 Confirmación por vendedor

En una transacción indivisible:

```text
virtual_vendedor -= monto
virtual_cliente += monto
real_reservado_cliente -= monto
real_vendedor += monto
```

Además:

- Se crean movimientos contables.
- Se registra la ganancia realizada del vendedor.
- La solicitud queda `COMPLETADA_POR_VENDEDOR`.

## 10.6 Cancelación o abandono por vendedor

- Se elimina la asignación.
- La solicitud vuelve a `PENDIENTE` si aún queda tiempo.
- El saldo real del cliente continúa reservado.
- Un vendedor que cancela repetidamente puede activar controles antifraude.

## 10.7 Conversión automática a los cinco minutos

Si la solicitud no fue completada por un vendedor dentro de cinco minutos desde su creación:

1. Un trabajo del servidor intenta completar la solicitud.
2. La wallet general entrega el virtual.
3. El real reservado se acredita a la cuenta real de la plataforma.
4. La solicitud queda `COMPLETADA_POR_PLATAFORMA`.

Si un vendedor confirma simultáneamente, una restricción e idempotencia permiten que solo un proceso complete la operación.

## 10.8 Falla de la conversión automática

Si la wallet general no tiene liquidez suficiente:

- La solicitud no puede quedar indefinidamente bloqueada.
- Se marca `FALLIDA_POR_LIQUIDEZ`.
- Se libera el saldo real reservado al Cliente.
- Se registra una alerta operativa.

# 11. MODELO ECONÓMICO DEL VENDEDOR

## 11.1 Compra mayorista

El Vendedor compra virtual a la plataforma:

```text
0,90 real → 1,00 virtual
```

Ejemplo:

```text
Paga: 90,00 reales
Recibe: 100,00 virtuales
Margen potencial: 10,00 reales
```

## 11.2 Ganancia potencial y realizada

La compra de virtual no representa una ganancia realizada. Deben mostrarse por separado:

- Capital invertido.
- Inventario virtual.
- Ganancia potencial.
- Ventas completadas.
- Ganancia realizada.

Cuando vende 1,00 virtual en una solicitud y recibe 1,00 real:

```text
Ingreso real: 1,00
Costo del virtual: 0,90
Ganancia realizada: 0,10
```

## 11.3 Prevención de ciclos artificiales

Si el Vendedor convierte su virtual directamente a real:

```text
1,00 virtual - 10% = 0,90 real
```

Recupera lo invertido y no obtiene ganancia. Además, no puede atender sus propias solicitudes ni las de cuentas relacionadas.

# 12. CONVERSIÓN VIRTUAL A REAL Y RETIRO

## 12.1 Comisión

Toda conversión de virtual a real cobra 10%, sin importar el origen del virtual.

Aplica a virtual proveniente de:

- Premios.
- Devoluciones.
- Transferencias.
- Solicitudes.
- Compra mayorista.
- Acreditaciones internas válidas.

## 12.2 Ejemplo

```text
Virtual convertido: 500,00
Comisión 10%: 50,00
Real acreditado: 450,00
```

## 12.3 Límites

No existe un límite comercial general de conversión. Sí se mantienen controles técnicos y antifraude, como idempotencia, verificación de saldo, prevención de automatización abusiva y revisión de operaciones anómalas.

## 12.4 Retiro

Una vez convertido a real, el usuario puede solicitar retiro. No se cobra una segunda comisión de negocio en la primera versión, salvo costos futuros de un proveedor externo claramente informados.

# 13. TRANSFERENCIAS ENTRE USUARIOS

- Los clientes pueden enviar saldo virtual a otros clientes.
- No se permiten transferencias a sí mismo.
- El destinatario debe existir y estar activo.
- La transferencia debe ser atómica.
- Debe existir comprobante y movimiento para ambas partes.
- El saldo real no se transfiere libremente entre usuarios; el flujo real-virtual se maneja mediante solicitudes.

# 14. PRODUCTOS DE LOTERÍA Y REGLAS MATEMÁTICAS

## 14.1 Lotería Octal

- Universo: 0, 1, 2, 3, 4, 5, 6, 7.
- Selección exacta: 4 números únicos.
- Orden: irrelevante.
- Combinaciones totales: `C(8,4) = 70`.

## 14.2 Lotería Decimal

- Universo: 0 a 9.
- Selección exacta: 5 números únicos.
- Orden: irrelevante.
- Combinaciones totales: `C(10,5) = 252`.

## 14.3 Lotería Hexadecimal

- Universo: 0 a 9 y A, B, C, D, E, F.
- Selección exacta: 6 símbolos únicos.
- Orden: irrelevante.
- Combinaciones totales: `C(16,6) = 8 008`.

## 14.4 Normalización

Las combinaciones se ordenan con un criterio canónico antes de guardarse. Por ejemplo:

```text
7, 4, 2, 0 → 0-2-4-7
```

Las permutaciones del mismo conjunto no son combinaciones diferentes.

## 14.5 Unicidad por evento

Una combinación completa puede venderse una sola vez dentro del mismo evento. Puede volver a venderse en otro evento distinto.

# 15. VERSIONES DE REGLAS

Cada producto debe tener versiones inmutables que definan:

- Universo permitido.
- Cantidad exacta.
- Orden relevante o irrelevante.
- Repetición permitida o no.
- Regla de premio mayor.
- Regla de devolución.
- Porcentaje de crecimiento.
- Política de acumulación.
- Cierre de ventas.
- Límites de compra.
- Redondeo.

Un evento queda asociado para siempre a una versión. Modificar una versión crea otra; no altera eventos históricos.

# 16. AUTOGENERADOR Y PROGRAMACIÓN DE EVENTOS

## 16.1 Objetivo

Permitir varios eventos en un mismo día, especialmente para Octal y Decimal, sin que el Administrador cree cada uno manualmente.

## 16.2 Parámetros configurables

- Tipo de lotería.
- Versión de reglas.
- Días habilitados.
- Primera hora.
- Última hora.
- Frecuencia en horas o días.
- Número de días futuros a generar.
- Horas o días de anticipación para publicación.
- Cierre de ventas, fijado normalmente 10 minutos antes.
- Precio del boleto.
- Multiplicador del premio inicial.
- Porcentaje de crecimiento.
- Techo.
- Meta mínima de capital.
- Estado activo o inactivo.

## 16.3 Prevención de duplicados

No pueden existir dos eventos del mismo producto, versión y hora oficial con el mismo identificador lógico.

## 16.4 Cambios en plantillas

Los cambios afectan únicamente eventos futuros que todavía no estén publicados ni tengan ventas. No modifican eventos históricos o activos.

## 16.5 Cobertura

El autogenerador no publica nuevos eventos si el fondo de garantía no puede reservar la cobertura requerida.

# 17. VISIBILIDAD Y ORGANIZACIÓN DE EVENTOS PARA EL CLIENTE

## 17.1 Navegación por tipo

La sección Comprar boletos debe mostrar primero:

- Octal.
- Decimal.
- Hexadecimal.

Al seleccionar un tipo se muestran todos los eventos activos y comprables, no solamente el más próximo.

## 17.2 Publicación anticipada

Un evento puede mostrarse días u horas antes de que termine el evento anterior. Cada evento tiene su propia apertura y cierre.

## 17.3 Datos mínimos de la tarjeta

- ID y nombre.
- Tipo.
- Fecha y hora del sorteo.
- Cierre de ventas.
- Precio.
- Premio inicial.
- Premio actual.
- Acumulado extraordinario.
- Máximo público o techo.
- Combinaciones disponibles.
- Porcentaje vendido.
- Estado.

## 17.4 Visible pero no comprable

Un evento puede estar publicado como próximo, pero las compras solo se habilitan cuando llega su apertura.

# 18. FORMAS DE SELECCIONAR UNA COMBINACIÓN

## 18.1 Sin números seleccionados

El usuario puede solicitar una o varias combinaciones aleatorias disponibles.

## 18.2 Selección parcial y listado

El usuario elige algunos números. El backend devuelve combinaciones disponibles que contengan todos los seleccionados. La respuesta debe paginarse.

## 18.3 Selección parcial y compra rápida

El usuario fija algunos números y el backend completa aleatoriamente los faltantes, eligiendo una combinación disponible.

## 18.4 Selección completa

El usuario selecciona la cantidad exacta. El sistema valida y reserva si está disponible.

## 18.5 Compra de múltiples boletos

El carrito puede contener varias combinaciones diferentes. Cada combinación debe validarse y reservarse individualmente. Si una caduca, las demás no tienen que perderse.

# 19. CATÁLOGO DE COMBINACIONES

Debido a que los universos actuales producen 70, 252 y 8 008 combinaciones, se recomienda generar el catálogo completo por evento.

Cada combinación maneja:

- Identificador.
- Evento.
- Clave normalizada.
- Estado.
- Usuario que la reserva.
- Expiración.
- Boleto asociado.

Estados:

- `DISPONIBLE`
- `RESERVADA`
- `VENDIDA`
- `BLOQUEADA`

La base de datos impone unicidad sobre `evento + clave_normalizada`.

# 20. LÍMITE DINÁMICO DE COMPRA

## 20.1 Fase limitada

Durante el primer 80% de la ventana efectiva de ventas, cada Cliente puede adquirir acumulativamente como máximo 20% de las combinaciones totales del evento.

Fórmula:

```text
limite_cliente = floor(combinaciones_totales × 0,20)
```

Resultados:

| Producto | Total | Límite inicial |
|---|---:|---:|
| Octal | 70 | 14 |
| Decimal | 252 | 50 |
| Hexadecimal | 8 008 | 1 601 |

Se consideran boletos pagados más reservas activas.

## 20.2 Liberación

Al comenzar el último 20% de la ventana de ventas, desaparece el límite porcentual por Cliente.

## 20.3 Cálculo temporal

```text
instante_base = apertura + 80% × (cierre - apertura)
```

El resultado se redondea a la media hora u hora completa más cercana:

- Minutos 00–14: baja a `:00`.
- Minutos 15–45: se fija en `:30`.
- Minutos 46–59: sube a la siguiente `:00`.

Ejemplos:

```text
16:05 → 16:00
16:22 → 16:30
16:45 → 16:30
16:46 → 17:00
```

## 20.4 Controles que permanecen

Aunque se elimine el límite porcentual, continúan:

- Saldo suficiente.
- Disponibilidad real.
- Reserva válida.
- Controles antifraude.
- Límite técnico por carrito o lote de petición.
- Prevención de doble compra.

No existe un límite diario general acumulando todos los eventos.

# 21. SESIONES DE COMPRA Y RESERVAS

## 21.1 Cierre de ventas

Las ventas cierran exactamente 10 minutos antes de la hora oficial del sorteo.

## 21.2 Duración de sesión

### Fase inicial

Duración predeterminada:

```text
mínimo(25 minutos, 10% de la ventana de ventas)
```

No se muestra contador desde el inicio; puede mostrarse en los últimos cinco minutos.

### Último 20% de la ventana

Máximo 10 minutos, con contador visible.

### Cuando faltan 30 minutos o menos para el cierre

Máximo 5 minutos, con contador visible.

### Regla superior

```text
tiempo_efectivo = mínimo(duración_de_fase, tiempo_hasta_cierre)
```

Una sesión jamás extiende las ventas.

## 21.3 Reserva de combinación

Una combinación añadida al carrito se reserva durante cinco minutos.

Al expirar:

- Regresa a `DISPONIBLE`.
- Deja de contar para el límite.
- No puede confirmarse.
- La interfaz solicita reemplazarla.

## 21.4 Autoridad temporal

La hora del servidor es la única autoridad. Cambiar la hora del dispositivo o alterar JavaScript no modifica una expiración.

# 22. PROCESO TRANSACCIONAL DE COMPRA

1. Autenticar al Cliente.
2. Verificar modo autorizado.
3. Verificar cuenta activa.
4. Verificar evento y versión.
5. Verificar apertura y cierre.
6. Verificar límite aplicable.
7. Verificar combinación disponible.
8. Crear reserva.
9. Revisar precio y carrito.
10. Confirmar mediante clave idempotente.
11. Debitar saldo virtual.
12. Marcar combinación como vendida.
13. Crear boleto.
14. Crear asientos contables.
15. Actualizar ventas y premio.
16. Entregar comprobante.

Los pasos financieros finales ocurren en una transacción. Si falla cualquier paso, no se confirma una compra parcial.

# 23. BOLETOS

## 23.1 Datos mínimos

- ID interno.
- Número público o serie.
- Evento.
- Versión de reglas.
- Propietario.
- Combinación normalizada.
- Precio pagado.
- Fecha del servidor.
- Estado.
- Código verificable o QR.
- Evaluación.
- Premio asignado.

## 23.2 Visualización

En la gestión del Cliente, los números se muestran ordenados, aunque la animación del resultado los revele en otro orden.

## 23.3 Compra definitiva

Una compra confirmada no puede devolverse voluntariamente.

Solo se reembolsa por:

- Cancelación del evento.
- Cobro duplicado.
- Error interno.
- Boleto no creado después de un cobro.
- Corrección administrativa justificada.

## 23.4 Filtros

- Antigüedad.
- Tipo.
- Evento.
- Pendiente de sorteo.
- No premiado.
- Devolución acreditada.
- Premio mayor acreditado.
- Reembolsado.

# 24. REGLAS DE PREMIO

## 24.1 Premio mayor

Gana la combinación vendida que coincida exactamente con todos los números del resultado. El orden no importa.

Debido a la exclusividad, existe como máximo un boleto ganador exacto.

## 24.2 Devolución

Todo boleto que acierte exactamente todos menos un número recibe un valor igual al precio base pagado.

- Se acredita como saldo virtual.
- Se paga automáticamente.
- Se paga aunque no haya ganador mayor.
- Se registra como premio secundario, no como cancelación.

## 24.3 Responsabilidad matemática máxima

Para universo `n` y selección `k`, el número máximo de combinaciones a distancia de un número es:

```text
k × (n-k)
```

| Producto | n | k | Máximo teórico de devoluciones |
|---|---:|---:|---:|
| Octal | 8 | 4 | 16 |
| Decimal | 10 | 5 | 25 |
| Hexadecimal | 16 | 6 | 60 |

El sistema puede recalcular la responsabilidad real usando únicamente boletos vendidos, pero nunca debe reservar menos que el peor caso aplicable a esos boletos.

# 25. PREMIO INICIAL, CRECIMIENTO Y TECHO

## 25.1 Premio inicial

Valor sugerido:

```text
premio_inicial = precio_boleto × 5
```

El multiplicador es configurable en el autogenerador, sujeto a cobertura.

## 25.2 Composición pública

```text
Premio mayor total =
Premio inicial garantizado
+ Crecimiento por ventas del evento
+ Acumulado extraordinario heredado
```

Cada componente se muestra separado en administración. El acumulado puede mostrarse públicamente como incremento extraordinario.

## 25.3 Excedente elegible

```text
excedente_elegible =
ventas_confirmadas
- premio_inicial_pendiente_de_recuperar
- reserva_de_devoluciones
- recuperación_del_fondo_de_garantía
- reservas_y_costos_aplicables
```

## 25.4 Crecimiento

```text
crecimiento = máximo(0, excedente_elegible × 0,90)
```

El 10% restante constituye margen operativo, reserva y cobertura de ajustes de redondeo.

## 25.5 Premio financiado por el evento

```text
premio_financiado_evento = premio_inicial + crecimiento
```

## 25.6 Techo

```text
premio_financiado_evento ≤ techo_configurado
```

El acumulado extraordinario no consume nuevamente el techo porque ya está financiado.

## 25.7 Recomendación automática

Si el Administrador ingresa premio o techo, el sistema recomienda precio mínimo. Si ingresa precio, recomienda techo sostenible.

Debe mostrar:

- Venta máxima.
- Venta esperada.
- Punto de equilibrio.
- Meta mínima de capital.
- Responsabilidad de devoluciones.
- Techo sostenible.
- Fondo adicional requerido.
- Escenarios conservador, esperado y agotado.
- Semáforo verde, amarillo o rojo.

## 25.8 Modificación por Administrador

Puede reducir el techo. Puede aumentarlo únicamente si el fondo de garantía reserva la diferencia. Un evento insolvente no puede publicarse aceptando solo una advertencia.

# 26. REDONDEO MONETARIO

## 26.1 Regla

La parte decimal se redondea así:

- 0,00–0,12 → 0,00.
- 0,13–0,37 → 0,25.
- 0,38–0,62 → 0,50.
- 0,63–0,87 → 0,75.
- 0,88–0,99 → siguiente dólar.

## 26.2 Consistencia

El premio público y el premio acreditado deben ser iguales.

## 26.3 Ajustes

- Redondeo hacia arriba: se cubre con el margen operativo del 10%.
- Redondeo hacia abajo: la diferencia se transfiere al fondo de garantía.

El valor exacto previo al redondeo se conserva en auditoría.

# 27. FONDO GENERAL DE GARANTÍA

## 27.1 Propósito

- Cubrir premio inicial.
- Cubrir devoluciones.
- Cubrir eventos de baja venta.
- Cubrir diferencias de redondeo.
- Cubrir reembolsos o fallos extraordinarios.

## 27.2 Estructura

Existe un fondo general con reservas independientes por evento.

```text
saldo_disponible = saldo_total - sumatoria_reservas_eventos
```

El mismo saldo no puede respaldar dos eventos.

## 27.3 Mínimo obligatorio

```text
mínimo_requerido = fondo_base_emergencia + obligaciones_reservadas
```

Cada evento reserva:

- Premio inicial.
- Responsabilidad de devoluciones.
- Ajustes potenciales.
- Reserva técnica.

## 27.4 Reposición

Si el fondo baja:

1. Se utilizan ganancias disponibles del sistema.
2. Administradores autorizados pueden aportar dinero.
3. Se suspende la publicación automática.
4. Eventos próximos sin ventas se cancelan o no se publican.
5. El Administrador genera nuevamente los eventos al restablecerse la cobertura.

## 27.5 Recuperación por ventas

Las primeras ventas devuelven al fondo lo adelantado antes de crear crecimiento del premio.

## 27.6 Aportes administrativos

Requieren:

- Permiso.
- Monto.
- Motivo.
- Origen.
- Saldo antes y después.
- Auditoría.

# 28. META MÍNIMA DE CAPITAL

Un evento alcanza su meta mínima cuando puede:

1. Pagar devoluciones.
2. Reponer lo adelantado por garantía.
3. Cubrir costos y ajustes.
4. Mantener financiado el premio mayor que promete.
5. Terminar sin deuda neta.

La fórmula exacta se parametriza por versión, pero debe derivarse de obligaciones reales, no de un porcentaje arbitrario.

# 29. EVENTO SIN GANADOR Y ACUMULACIÓN

## 29.1 Resultado no vendido

El resultado se genera entre todas las combinaciones posibles, no únicamente entre las vendidas. Si la combinación exacta no fue vendida, no hay ganador mayor.

## 29.2 Si alcanzó la meta mínima

El premio mayor no entregado se distribuye:

- 50% al siguiente evento del mismo tipo.
- 25% al fondo de garantía.
- 15% al fondo de premios futuros.
- 10% a operación y plataforma.

## 29.3 Si no alcanzó la meta mínima

No se genera el acumulado del 50%.

Orden:

1. Pagar devoluciones.
2. Reponer garantía.
3. Cubrir obligaciones y ajustes.
4. El acumulado heredado, si existía, vuelve íntegro al fondo acumulado.
5. El remanente actual fortalece el fondo de garantía.
6. Si el fondo está completo, el remanente puede ir a premios futuros.

## 29.4 Evento receptor

El acumulado se añade al siguiente evento cronológico del mismo tipo que todavía no haya generado resultado, aunque ya esté publicado o en venta.

- Solo puede aumentar el premio.
- Nunca modifica precio ni reglas.
- Se muestra como acumulado extraordinario.
- Si no existe evento elegible, queda pendiente.

## 29.5 Cancelación del receptor

El acumulado heredado vuelve al fondo acumulado del mismo tipo.

# 30. FONDO DE PREMIOS FUTUROS

Recibe 15% del premio no entregado en eventos elegibles.

Puede usarse para:

- Incrementar premios iniciales.
- Eventos especiales.
- Promociones controladas.
- Apoyar eventos de baja participación.

Todo uso requiere permiso, motivo, evento beneficiado y auditoría. No puede cubrir retiros personales ni mezclarse con gastos no autorizados.

# 31. CIERRE Y CONGELACIÓN DEL EVENTO

Diez minutos antes del sorteo:

1. Se cierran ventas.
2. Se rechazan nuevas reservas.
3. Se resuelven reservas vigentes según su hora límite.
4. Se congela el conjunto de boletos vendidos.
5. Se genera un hash del snapshot.
6. Se prepara el resultado.

Una sesión abierta no puede confirmar después del cierre.

# 32. PROTOCOLO DE RESULTADO VERIFICABLE

## 32.1 Preparación

Antes del cierre, el servidor genera una semilla criptográfica secreta con un generador seguro y publica el compromiso:

```text
commitment = SHA-256(semilla_secreta + evento + versión + cierre)
```

## 32.2 Snapshot

Al cerrar ventas:

- Se ordenan de forma determinista los boletos válidos.
- Se calcula `hash_snapshot_boletos`.

## 32.3 Semilla final

```text
semilla_final = SHA-256(
  semilla_secreta
  + evento_id
  + versión_reglas
  + fecha_cierre
  + hash_snapshot_boletos
)
```

## 32.4 Generación

La semilla final alimenta un generador determinista seguro que selecciona sin reemplazo:

- 4 números Octales.
- 5 números Decimales.
- 6 símbolos Hexadecimales.

## 32.5 Validación previa a fijación

- Cantidad exacta.
- Valores dentro del universo.
- Sin repetidos.
- Versión correcta.
- Evento cerrado.
- Resultado no existente.

## 32.6 Inmutabilidad

Una vez guardado:

- No se edita.
- No se regenera.
- Se puede recuperar después de una falla.
- Se publica semilla, compromiso, hashes y datos necesarios para verificar.

# 33. ANIMACIÓN DEL SORTEO

- El resultado completo ya existe antes de la animación.
- Se muestra en círculos o espacios grandes.
- Se revela un valor cada 3 a 5 segundos.
- El usuario puede pulsar “Saltar animación”.
- Recargar puede reproducir nuevamente la animación, pero no cambia el resultado.
- La secuencia visual no altera que el orden sea irrelevante.
- Solo se revelan 4, 5 o 6 valores según el producto.

# 34. EVALUACIÓN DE BOLETOS

Después de fijar el resultado:

1. Se comparan boletos activos.
2. Se identifica ganador exacto si existe.
3. Se identifican devoluciones.
4. Se calculan obligaciones.
5. Se crean órdenes de acreditación idempotentes.
6. Se prepara el boletín.

La evaluación ocurre aunque nadie esté conectado.

# 35. PUBLICACIÓN Y ACREDITACIÓN DE PREMIOS

## 35.1 Momento

Los premios y devoluciones se acreditan al publicarse el informe.

## 35.2 Forma

Se acreditan automáticamente como saldo virtual. El ganador no debe reclamar ni verificar manualmente.

## 35.3 Idempotencia

Clave única recomendada:

```text
evento + boleto + categoría
```

La base impide pagos duplicados.

## 35.4 Falla entre movimiento y wallet

El libro contable es fuente de verdad. Si existe la transacción pero una proyección de saldo no se actualizó:

1. Verificar transacción.
2. Verificar asientos.
3. Verificar saldo materializado.
4. Reintentar solo la proyección o parte faltante.
5. Nunca crear un segundo premio.

# 36. INFORME PÚBLICO DE RESULTADOS

Debe generarse después de cada evento, con estilo visual similar a un boletín de lotería, sin copiar marcas ajenas.

Debe incluir:

- Nombre de Lotería Binaria.
- Tipo de producto.
- ID y número del evento.
- Fecha y hora.
- Números ganadores.
- Precio del boleto.
- Premio inicial.
- Crecimiento por ventas.
- Acumulado extraordinario.
- Premio mayor total.
- Indicación de si hubo ganador.
- Cantidad de ganadores mayores.
- Cantidad de devoluciones.
- Monto total de devoluciones.
- Boletos vendidos.
- Recaudación.
- Distribución por no ganador, si aplica.
- Nuevo acumulado.
- Hashes y código de verificación.
- Estado de pagos.

No debe mostrar:

- Nombre.
- Cédula.
- Correo.
- Teléfono.
- Usuario.

Puede indicar únicamente que existió ganador y la cantidad. El detalle personal solo aparece en la cuenta autenticada del propietario.

# 37. CANCELACIÓN DE EVENTOS

## 37.1 Condición

Un evento puede cancelarse únicamente antes de generar el resultado.

## 37.2 Inmutabilidad comercial

Un evento publicado y en venta no puede editarse. Puede continuar o cancelarse.

## 37.3 Autoridad

Solo Administradores autorizados pueden cancelar.

## 37.4 Motivo

El motivo es obligatorio y se muestra a quienes compraron boletos.

## 37.5 Reembolso

- Se devuelve el total pagado por cada boleto.
- Se devuelve al mismo tipo de saldo usado.
- Se anulan obligaciones del evento.
- Se crean movimientos idempotentes.

## 37.6 Acumulado

El acumulado heredado vuelve al fondo acumulado del mismo tipo.

## 37.7 Conservación

El evento queda `CANCELADO`; nunca se elimina físicamente.

# 38. ESTADOS OFICIALES

## 38.1 Evento

- `BORRADOR`
- `PROGRAMADO`
- `PUBLICADO`
- `VENTAS_ABIERTAS`
- `AGOTADO`
- `VENTAS_CERRADAS`
- `RESULTADO_GENERADO`
- `REVELANDO`
- `PAGOS_EN_PROCESO`
- `INFORME_PUBLICADO`
- `FINALIZADO`
- `CANCELADO`

La liberación del límite puede ser estado calculado, no persistido.

## 38.2 Combinación

- `DISPONIBLE`
- `RESERVADA`
- `VENDIDA`
- `BLOQUEADA`

## 38.3 Boleto

- `RESERVADO`
- `PAGADO`
- `ACTIVO`
- `NO_PREMIADO`
- `DEVOLUCION`
- `PREMIO_MAYOR`
- `PREMIO_ACREDITADO`
- `REEMBOLSADO`
- `ANULADO`

## 38.4 Solicitud

- `PENDIENTE`
- `ASIGNADA`
- `EN_PROCESO`
- `COMPLETADA_POR_VENDEDOR`
- `COMPLETADA_POR_PLATAFORMA`
- `CANCELADA`
- `FALLIDA_POR_LIQUIDEZ`

## 38.5 Operación financiera

- `PENDIENTE`
- `CONFIRMADA`
- `REINTENTANDO`
- `FALLIDA`
- `REVERSADA`
- `EN_REVISION`

# 39. FUNCIONES DEL CLIENTE

- Resumen de cuenta.
- Consulta de tipos y eventos.
- Compra de combinaciones.
- Compra rápida.
- Carrito y reservas.
- Boletos comprados.
- Resultados.
- Wallet real y virtual.
- Recarga real.
- Solicitudes real a virtual.
- Conversión virtual a real.
- Transferencias virtuales.
- Movimientos.
- Perfil y seguridad.

# 40. FUNCIONES DEL VENDEDOR

- Resumen de capital e inventario.
- Recarga de real.
- Compra mayorista de virtual.
- Solicitudes disponibles.
- Solicitudes asignadas.
- Confirmación y cancelación.
- Movimientos.
- Ganancia potencial y realizada.
- Conversión virtual a real.
- Retiros.
- Perfil y seguridad.

No muestra compra ni gestión de boletos.

# 41. FUNCIONES DEL ADMINISTRADOR

- Dashboard general.
- Usuarios y roles.
- Productos y versiones.
- Autogeneradores.
- Calendario de eventos.
- Análisis económico.
- Publicación y cancelación.
- Fondos y reservas.
- Solicitudes y conversiones.
- Resultados e informes.
- Finanzas globales.
- Auditoría.
- Estadísticas.

Acciones sensibles exigen permisos, motivo y autenticación reforzada.

# 42. MATRIZ RESUMIDA DE PERMISOS

| Operación | Cliente | Vendedor | Admin |
|---|---:|---:|---:|
| Comprar boleto | Sí | No | No, salvo cuenta Cliente independiente autorizada |
| Consultar eventos | Sí | Sí | Sí |
| Recargar real | Sí | Sí | Sí |
| Crear solicitud | Sí | No | Solo en modo financiero permitido |
| Atender solicitud | No | Sí | Solo en modo Vendedor |
| Comprar virtual a 0,90 | No | Sí | Solo en modo Vendedor |
| Convertir virtual a real | Sí | Sí | Sí |
| Crear evento | No | No | Sí |
| Cancelar evento | No | No | Con permiso |
| Gestionar fondos | No | No | Con permiso especial |
| Publicar informe | No | No | Automático o Admin autorizado |
| Ver auditoría | No | No | Con permiso |

# 43. SEGURIDAD Y ANTIFRAUDE

## 43.1 Reglas de negocio

- Vendedor no compra boletos.
- Vendedor no atiende solicitudes propias.
- No transferencias a sí mismo.
- No combinación duplicada.
- No compra después del cierre.
- No devolución voluntaria.
- No resultado editable.
- No evento insolvente.

## 43.2 Controles técnicos

- RBAC en backend.
- Restricciones de base.
- Transacciones.
- Bloqueos de fila.
- Idempotencia.
- Rate limiting.
- Validación DTO.
- Cifrado en tránsito.
- Secretos fuera del código.
- Registro de dispositivos.
- Prevención de inyección.
- Protección CSRF donde corresponda.
- Auditoría de cambios.

## 43.3 Cuentas relacionadas

El sistema puede detectar relaciones por identidad, dispositivo, medio de pago o señales de riesgo. No se debe bloquear automáticamente sin trazabilidad, pero sí impedir ciclos evidentes y enviar a revisión.

# 44. LIBRO CONTABLE

Los saldos no se modifican como números aislados. Cada operación crea una transacción y asientos.

Ejemplos:

### Compra de boleto

```text
Débito: wallet virtual del Cliente
Crédito: fondo del evento
```

### Solicitud completada por Vendedor

```text
Débito virtual: Vendedor
Crédito virtual: Cliente
Débito real reservado: Cliente
Crédito real: Vendedor
```

### Premio

```text
Débito: obligación de premios del evento
Crédito: wallet virtual del ganador
```

El saldo visible debe poder reconstruirse a partir del libro.

# 45. AUDITORÍA TÉCNICA

No se requiere una bitácora visible de clics para el Cliente. Sí se requiere auditoría interna para:

- Login y cambios de rol.
- Cambios administrativos.
- Creación y cancelación de eventos.
- Reservas de garantía.
- Resultados.
- Publicación de informes.
- Acreditaciones.
- Reversiones.
- Aportes a fondos.
- Bloqueos y seguridad.

Cada registro incluye actor, fecha del servidor, acción, recurso, estado anterior, estado nuevo y motivo cuando corresponda.

# 46. MANEJO DE FALLOS

## 46.1 Dos usuarios compran la misma combinación

La base confirma solo una. La otra operación recibe indisponibilidad y no se cobra.

## 46.2 Doble clic

La misma clave idempotente devuelve el resultado previo.

## 46.3 Pago confirmado sin boleto

Un conciliador crea el boleto si la reserva seguía válida o revierte el cobro.

## 46.4 Boleto creado sin débito

La transacción se revierte o completa de forma controlada; no queda activo sin pago.

## 46.5 Reinicio del servidor

Los trabajos retoman estados persistidos. No se depende de pestañas abiertas.

## 46.6 Falla durante animación

Se recupera el mismo resultado y se permite saltar.

## 46.7 Informe publicado con saldo no proyectado

Se verifica el libro y se reintenta la proyección, sin crear un segundo premio.

## 46.8 Resultado candidato inválido

Se descarta antes de fijarlo. Una vez fijado no se reemplaza.

# 47. ARQUITECTURA TÉCNICA OBJETIVO

## 47.1 Web

Next.js, React y TypeScript.

## 47.2 Móvil

React Native con Expo y TypeScript.

## 47.3 API

NestJS sobre Node.js y TypeScript.

## 47.4 Datos

PostgreSQL como fuente principal y Prisma como ORM inicial.

## 47.5 Infraestructura auxiliar

- Redis para caché, locks y reservas rápidas.
- BullMQ o cola equivalente para tareas.
- Docker para desarrollo y despliegue.
- Almacenamiento de objetos para informes.

## 47.6 Regla de autoridad

Web y móvil nunca calculan saldos, premios o resultados como autoridad. Consumen la API.

# 48. ESTRUCTURA RECOMENDADA DEL REPOSITORIO

```text
loteria-binaria/
├── apps/
│   ├── web/
│   ├── mobile/
│   └── api/
├── packages/
│   ├── shared-types/
│   ├── validation/
│   ├── game-rules/
│   ├── api-client/
│   └── ui/
├── database/
├── docs/
├── infrastructure/
└── README.md
```

# 49. MÓDULOS DEL BACKEND

- `auth`
- `users`
- `roles`
- `wallets`
- `ledger`
- `payments`
- `vendors`
- `conversion-requests`
- `lottery-products`
- `rule-versions`
- `event-schedules`
- `draw-events`
- `combinations`
- `reservations`
- `tickets`
- `draw-results`
- `prizes`
- `guarantee-fund`
- `future-prize-fund`
- `accumulations`
- `reports`
- `audit`
- `security`
- `jobs`

# 50. MODELO DE DATOS DE ALTO NIVEL

Entidades principales:

- Usuario.
- Rol.
- Permiso.
- Sesión.
- Wallet.
- Cuenta contable.
- Transacción.
- Asiento.
- Perfil de Vendedor.
- Solicitud.
- Producto.
- Versión de reglas.
- Plantilla de eventos.
- Evento.
- Combinación de evento.
- Reserva.
- Boleto.
- Resultado.
- Número de resultado.
- Evaluación.
- Premio.
- Fondo.
- Reserva de fondo.
- Acumulado.
- Informe.
- Evento de auditoría.

Restricciones indispensables:

- Usuario, correo y documento únicos.
- Evento + combinación normalizada únicos.
- Una combinación vendida tiene un solo boleto.
- Una clave idempotente es única.
- Un evento tiene un solo resultado final.
- Un boleto pertenece al producto y evento correctos.

# 51. PRINCIPIOS DE API

- REST versionada.
- DTOs únicos y compartidos.
- Validación del lado servidor.
- Errores estructurados.
- Paginación.
- Idempotency-Key en escrituras financieras.
- Autorización por permiso.
- Fecha del servidor en respuestas sensibles.
- WebSocket o eventos para premio y animación, sin convertirlos en fuente de verdad.

# 52. REQUISITOS NO FUNCIONALES

## 52.1 Disponibilidad

Las operaciones financieras deben tolerar reinicios y reintentos.

## 52.2 Rendimiento

La consulta de eventos y combinaciones debe responder de forma paginada y eficiente.

## 52.3 Concurrencia

Debe soportar intentos simultáneos de compra y toma de solicitudes.

## 52.4 Accesibilidad

- Navegación por teclado.
- Contraste suficiente.
- Etiquetas en formularios.
- Estados no dependientes solo de color.

## 52.5 Responsive

Web funcional en móvil, tablet y escritorio. La aplicación móvil mantiene la misma lógica mediante API.

## 52.6 Observabilidad

- Logs estructurados.
- Métricas.
- Alertas.
- Trazas para operaciones críticas.
- Panel de trabajos fallidos.

# 53. PRUEBAS OBLIGATORIAS

## 53.1 Reglas matemáticas

- Octal rechaza 8.
- Decimal rechaza A.
- Hexadecimal acepta F.
- No repetidos.
- Cantidad exacta.
- Permutaciones equivalentes.

## 53.2 Compra

- Dos compradores por una combinación.
- Reserva expirada.
- Límite del 20%.
- Liberación al 80%.
- Cierre durante compra.
- Doble clic.

## 53.3 Economía

- Premio inicial.
- Crecimiento 90%.
- Techo.
- Redondeo.
- Fondo insuficiente.
- Evento sin ganador con meta.
- Evento sin ganador sin meta.
- Acumulado a evento publicado.

## 53.4 Solicitudes

- Dos vendedores toman la misma.
- Cancelación.
- Confirmación al segundo 299.
- Conversión automática al minuto 5.
- Carrera entre vendedor y plataforma.
- Wallet general sin liquidez.

## 53.5 Resultados

- Hash verificable.
- Resultado único.
- Falla de animación.
- Cálculo de devoluciones.
- Publicación y pagos idempotentes.

## 53.6 Seguridad

- Cliente accede a Admin.
- Vendedor intenta comprar.
- Manipulación de reloj.
- Token revocado.
- Solicitud propia.

# 54. EXPERIENCIA DE USUARIO

## 54.1 Cliente móvil

Navegación sugerida:

```text
Inicio | Jugar | Boletos | Wallet | Perfil
```

## 54.2 Estados claros

La interfaz debe explicar:

- Cuánto puede comprar.
- Cuándo se libera el límite.
- Cuánto dura la reserva.
- Cuándo cierran ventas.
- Qué parte del premio es acumulada.
- Qué comisión aplica al convertir.

## 54.3 Mensajes

No usar mensajes genéricos cuando se conoce la causa. Ejemplos:

- “La combinación fue comprada por otra persona”.
- “La reserva venció”.
- “Las ventas cerraron a las 19:50”.
- “Has alcanzado 14 de 14 boletos durante la fase limitada”.

# 55. REGLAS REEMPLAZADAS DEL PROTOTIPO ANTERIOR

| Regla anterior | Regla vigente |
|---|---|
| Comisión 5% por tarjeta | Recarga sin comisión |
| Comisión 15% virtual a real | Comisión 10% |
| Conversión directa real a virtual | Solicitud y respaldo automático a los 5 minutos |
| Temporizador de solicitud 2 minutos | Plazo absoluto de 5 minutos |
| Crecimiento del premio 75% | 90% del excedente elegible |
| Número guardado como cadena | Colección única y normalizada |
| Repetición permitida | Números sin repetición |
| Combinaciones compartidas | Exclusivas por evento |
| Solo evento próximo | Todos los eventos activos por tipo |
| Un evento próximo por producto | Múltiples eventos simultáneos |
| Ganancia del Vendedor al comprar virtual | Ganancia potencial; se realiza al vender |
| JSON/localStorage | API y PostgreSQL |
| Resultado con Math.random() | Generación criptográfica verificable |
| Evento editable en venta | Solo cancelable |
| Bitácora visible de navegación | Excluida; auditoría técnica interna |

# 56. CRITERIOS DE ACEPTACIÓN GLOBAL

El sistema se considera funcionalmente conforme cuando:

- Ninguna combinación se vende dos veces.
- Ninguna operación financiera se duplica.
- Ningún evento se publica sin cobertura.
- Las reglas históricas permanecen inmutables.
- El límite dinámico se calcula con hora del servidor.
- Los resultados son verificables.
- Los premios se acreditan automáticamente.
- El informe no revela identidad.
- Web y móvil producen el mismo resultado al usar la API.
- Los saldos pueden reconstruirse desde el libro contable.
- Un reinicio no pierde solicitudes, reservas, eventos o premios.

# 57. ALINEACIÓN CON LA ASIGNATURA

El proyecto permite demostrar:

- HTML semántico y CSS.
- Diseño adaptable y mejora progresiva.
- React, DOM, eventos y estado del cliente.
- AJAX y comunicación en tiempo real.
- Arquitectura cliente-servidor.
- Desarrollo móvil multiplataforma.
- Programación del servidor.
- MVC y arquitectura modular.
- Seguridad web.
- APIs REST.
- Despliegue en producción.

# 58. CONCLUSIÓN

Lotería Binaria queda definida como una plataforma de sorteos digitales con tres productos matemáticamente diferenciados, combinaciones únicas, premios dinámicos, fondos de protección, vendedores con margen controlado, resultados verificables y acreditación automática.

La idea es coherente y técnicamente realizable. Este documento es suficiente como base para producir, en orden:

1. Modelo contable definitivo.
2. Diagramas de estados.
3. Modelo entidad-relación.
4. Contratos de API.
5. Matriz detallada de permisos.
6. Plan de pruebas.
7. Plan de creación por fases.
8. Implementación del backend.
9. Aplicación web.
10. Aplicación móvil.

Toda nueva decisión deberá compararse contra este documento para evitar contradicciones o pérdida de contexto.

# ANEXO A. EJEMPLO ECONÓMICO RESUMIDO

Supóngase un evento Decimal:

```text
Combinaciones: 252
Precio: 2,00 virtuales
Premio inicial: 10,00
Devoluciones reservadas: 50,00
Reserva técnica: 20,00
Techo financiado por evento: 300,00
Acumulado heredado: 100,00
```

Con 150 boletos vendidos:

```text
Ventas: 300,00
Menos premio inicial pendiente: 10,00
Menos devoluciones: 50,00
Menos reserva: 20,00
Excedente: 220,00
90% crecimiento: 198,00
Premio financiado: 208,00
Más acumulado: 100,00
Premio total: 308,00
```

El techo de 300,00 limita únicamente el componente financiado, por lo que 208,00 es válido y el acumulado se añade aparte.

# ANEXO B. EJEMPLO DE COMPRA

1. Cliente elige Hexadecimal.
2. Selecciona evento HEX-0081.
3. Fija `A` y `F`.
4. Solicita completar al azar.
5. Backend devuelve `1-3-7-A-C-F`.
6. Se reserva cinco minutos.
7. El Cliente confirma.
8. Se debita virtual.
9. Se crea boleto.
10. La combinación queda vendida.

# ANEXO C. EJEMPLO DE SOLICITUD

```text
Monto: 50 real → 50 virtual
Creada: 14:00:00
Expira para respaldo: 14:05:00
```

- A las 14:02 un Vendedor la toma.
- A las 14:04 confirma.
- Recibe 50 reales y entrega 50 virtuales.

Si no confirma antes de 14:05, la plataforma intenta completarla. Solo un proceso puede ganar.

# ANEXO D. DECISIONES QUE PERMANECEN PARAMETRIZABLES

No constituyen lagunas conceptuales; se definirán durante diseño técnico:

- Horarios concretos de eventos.
- Frecuencia exacta por producto.
- Número de días futuros a generar.
- Fondo base mínimo inicial.
- Reserva técnica por producto.
- Máximo técnico de elementos por carrito.
- Proveedor de pagos real.
- Duración exacta de animación dentro del rango 3–5 segundos.
- Políticas de alerta y revisión de riesgo.

# ANEXO E. REGLA DE CONTROL DE CAMBIOS

Todo cambio futuro debe registrar:

- Número de versión.
- Fecha.
- Regla anterior.
- Regla nueva.
- Motivo.
- Impacto en base de datos.
- Impacto en API.
- Impacto en web y móvil.
- Tratamiento de eventos existentes.
- Responsable de aprobación.

