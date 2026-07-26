# ADR-ORG-001 — Resolución del módulo de sorteos creados por usuarios

**Estado:** APROBADO  
**Fecha:** 26 de julio de 2026  
**Proyecto:** Lotería Binaria  
**Afecta:** `user_draws`, wallet VIRTUAL, ledger, códigos privados, participaciones, resultados, entregas, expulsiones y reclamos  
**Decisiones cerradas:** `PEND-ORG-001` a `PEND-ORG-010`

## 1. Contexto

El Documento Maestro v1.0 definió el núcleo de lotería oficial y dejó los sorteos creados por usuarios como funcionalidad futura. Decisiones posteriores incorporaron este módulo al proyecto, pero quedaron diez puntos sin cerrar. Conforme a `LOT-AUD-009`, el SQL no puede inventar dichas reglas.

Este ADR resuelve nueve decisiones y excluye formalmente una del MVP.

## 2. Decisiones

### PEND-ORG-001 — Ganador

**Estado:** RESUELTA.

El servidor selecciona un único ganador mediante un generador criptográficamente seguro entre los números que, al cierre, tengan participación `PAGADA` y `ACTIVA`.

Antes de seleccionar:

1. Se cierra la venta y se rechazan cambios.
2. Se genera una lista determinista de participaciones elegibles.
3. Se almacena el snapshot y se publica su hash.
4. El worker genera y fija el resultado una sola vez.
5. Se publica número ganador, hash y datos de verificación sin exponer información personal.

El Organizador no puede elegir, editar ni regenerar el ganador.

### PEND-ORG-002 — Premio físico o producto

**Estado:** RESUELTA.

La plataforma no custodia físicamente productos en el MVP. El Organizador es responsable de existencia, legalidad, descripción y entrega.

Antes de publicar debe registrar:

- Descripción exacta.
- Condición y cantidad.
- Evidencia de existencia o disponibilidad.
- Método y fecha límite de entrega.
- Costes de entrega y quién los asume.

Después del resultado:

- El Organizador registra evidencia de entrega.
- El ganador confirma recepción o abre reclamo.
- El escrow no se libera mientras exista disputa.
- Si el Administrador acredita incumplimiento, puede ordenar reembolso completo a participantes desde el escrow y suspender al Organizador.

### PEND-ORG-003 — Abandono y expulsión

**Estado:** RESUELTA.

- Participación pendiente/no pagada que abandona: se cancela y libera el número.
- Participación pagada que abandona antes del cierre: no recibe reembolso automático; el número permanece activo y elegible.
- Expulsión antes del cierre de participación pagada: requiere motivo, devuelve 100 %, revierte comisión proporcional y libera el número.
- Después del cierre no se permite abandono ni expulsión ordinaria. Cualquier medida requiere reclamo y decisión administrativa.
- En todos los casos se conserva historial y derecho a reclamar.

### PEND-ORG-004 — Cambios y compras adicionales

**Estado:** RESUELTA.

- Solo antes del cierre oficial.
- Un cambio solo puede apuntar a un número disponible.
- La operación conserva número anterior, nuevo, actor, fecha y motivo.
- No existe máximo comercial global de cambios o compras adicionales en el MVP.
- Se aplican límites técnicos, rate limiting, saldo suficiente, disponibilidad e idempotencia.
- Después del cierre cualquier cambio se rechaza.

### PEND-ORG-005 — Reclamos

**Estado:** RESUELTA.

Estados:

`PRESENTADO → EN_REVISION ↔ ESPERANDO_EVIDENCIA → RESUELTO|RECHAZADO → APELADO → CERRADO`

Reglas:

- Plazo ordinario: 7 días calendario desde el hecho o desde la fecha límite de entrega.
- Evidencia adicional: plazo definido por el Administrador, normalmente hasta 3 días.
- Apelación: 3 días calendario desde la resolución.
- Objetivo de primera resolución: 5 días hábiles.
- El Organizador responde y aporta evidencia; no resuelve.
- Solo un Administrador con permiso resuelve o cierra.
- Una reapertura fuera de plazo exige motivo administrativo y auditoría.

### PEND-ORG-006 — Códigos privados

**Estado:** RESUELTA.

- Todo código tiene secreto de un solo uso almacenado mediante hash.
- `expires_at` es obligatorio y nunca posterior al cierre.
- El código reserva su número o grupo desde la emisión.
- Al reclamar se consume atómicamente.
- Al expirar sin reclamación, los números pendientes se liberan una sola vez.
- Un código pagado debe reclamarse antes del cierre para ser elegible. Si no se reclama, se excluye del snapshot y se reembolsa a la cuenta que financió el código.
- Los códigos no se eliminan; conservan estado e historial.

### PEND-ORG-007 — Cédula ecuatoriana

**Estado:** EXCLUIDA DEL MVP.

No se implementa verificación automática ni se almacenan imágenes de cédula en el MVP. Se mantienen:

- Correo y teléfono verificados.
- Documento declarado según las reglas generales de cuenta.
- Detección de cuentas relacionadas.
- Rate limiting y revisión administrativa.

Su incorporación futura exige ADR independiente, análisis jurídico y de privacidad, proveedor o procedimiento de validación, cifrado, retención, acceso, eliminación y respuesta a incidentes.

### PEND-ORG-008 — Inmutabilidad

**Estado:** RESUELTA.

Desde el primer pago confirmado quedan congelados:

- Precio.
- Premio o producto.
- Visibilidad.
- Reglas de adjudicación.
- Apertura y cierre.
- Rango ya publicado.

Después del primer pago solo se permiten:

- Anuncios internos.
- Ampliación del rango antes del cierre, sin afectar números previos.

Cualquier otro cambio requiere cancelar y crear un sorteo nuevo.

### PEND-ORG-009 — Custodia del 95 %

**Estado:** RESUELTA.

Por cada pago:

- 5 % → cuenta de comisión de plataforma.
- 95 % → cuenta escrow VIRTUAL exclusiva del sorteo.

El escrow no es saldo disponible del Organizador. Se libera una sola vez cuando:

1. El resultado está fijado.
2. La entrega fue confirmada por el ganador; o
3. Un Administrador autoriza la liquidación tras resolver una disputa.

Reembolsos, compensaciones y costes aprobados se descuentan antes de la liberación.

### PEND-ORG-010 — Comisión en reembolsos

**Estado:** RESUELTA.

- Cancelación del Organizador: se revierte la comisión y cada participante recibe 100 %.
- Expulsión reembolsable antes del cierre: se revierte la comisión proporcional.
- Incumplimiento del Organizador confirmado por reclamo: se revierte la comisión relacionada con los reembolsos.
- Error de plataforma: el participante recibe 100 % y la plataforma absorbe cualquier diferencia.
- Abandono voluntario pagado: no hay reembolso ni reversión.
- Operación exitosa: la comisión queda devengada.

## 3. Consecuencias técnicas

El diseño debe incluir, como mínimo:

- Cuentas escrow VIRTUAL por sorteo.
- Snapshot de participaciones elegibles.
- Resultado único e inmutable.
- Hash público.
- Evidencias de premio y entrega.
- Estados de entrega y liquidación.
- Códigos con expiración y reservas.
- Historial de abandono/expulsión.
- Reclamos y apelaciones.
- Asientos compensatorios y reverso de comisión.
- Feature flag de verificación de identidad avanzada desactivada.

## 4. Alternativas descartadas

- **Ganador manual por Organizador:** descartado por riesgo de manipulación.
- **Liquidación inmediata del 95 %:** descartada porque impide reembolsos y reduce protección.
- **Comisión no reembolsable en cancelaciones imputables al Organizador:** descartada porque impediría devolver el 100 % sin cargar la pérdida al participante.
- **Verificación automática de cédula en MVP:** descartada por alcance, privacidad y falta de proveedor/proceso aprobado.
- **Editar condiciones después del primer pago:** descartado por afectar consentimiento y expectativas de participantes.

## 5. Criterio de aceptación

`PEND-ORG-001` a `PEND-ORG-010` se consideran cerradas cuando:

- Este ADR está versionado.
- `REGLAS-NEGOCIO.md` v1.3.0 contiene las reglas resultantes.
- Estados, permisos, flujos financieros y diccionario de datos referencian estas decisiones.
- Las pruebas de cada regla están incluidas en la matriz regla→prueba.
