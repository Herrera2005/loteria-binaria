# Lotería Binaria

Plataforma académica de sorteos digitales combinatorios con aplicaciones web y móvil, una API central, procesos asíncronos y persistencia transaccional.

> [!WARNING]
> **Estado académico y saldos simulados.** En la etapa inicial, las recargas, saldos reales, saldos virtuales, conversiones, retiros, premios y movimientos son datos ficticios de desarrollo. No representan dinero real, no están respaldados por un proveedor de pagos y no deben utilizarse para operar una lotería real. Una puesta en producción con dinero, tarjetas, retiros o premios reales exige revisión legal y regulatoria, seguridad profesional, auditoría, monitoreo, infraestructura redundante y proveedores autorizados.

## Contenido

- [Descripción](#descripción)
- [Estado actual](#estado-actual)
- [Baseline documental congelada](#baseline-documental-congelada)
- [Fuentes normativas](#fuentes-normativas)
- [Arquitectura](#arquitectura)
- [Estructura del repositorio](#estructura-del-repositorio)
- [Requisitos](#requisitos)
- [Instalación](#instalación)
- [Variables de entorno](#variables-de-entorno)
- [PostgreSQL y Redis](#postgresql-y-redis)
- [Migraciones y Prisma](#migraciones-y-prisma)
- [Inicio de las aplicaciones](#inicio-de-las-aplicaciones)
- [Pruebas y calidad](#pruebas-y-calidad)
- [Convenciones de Git](#convenciones-de-git)
- [Reglas técnicas obligatorias](#reglas-técnicas-obligatorias)
- [Solución de problemas](#solución-de-problemas)

## Descripción

**Lotería Binaria** es una plataforma de sorteos digitales que contempla tres productos:

- **Octal:** selección de 4 valores únicos dentro de `0–7`.
- **Decimal:** selección de 5 valores únicos dentro de `0–9`.
- **Hexadecimal:** selección de 6 valores únicos dentro de `0–9` y `A–F`.

El sistema objetivo administra usuarios con roles globales de **Cliente, Vendedor y Administrador**; wallets real y virtual; solicitudes de conversión; eventos; combinaciones únicas; reservas; boletos; resultados verificables; premios; fondos y auditoría.

Además, el mismo producto contempla un módulo separado de **sorteos creados por usuarios**. En ese módulo, cualquier cuenta registrada y activa puede actuar como **Organizador del sorteo que creó**. Organizador se trata como una capacidad contextual sobre un recurso, no como privilegio administrativo global.

Los dos contextos no deben mezclarse:

- **Lotería oficial:** productos Octal, Decimal y Hexadecimal, wallets REAL/VIRTUAL, fondos de garantía, premio creciente, acumulados, resultado verificable y boletos oficiales.
- **Sorteos creados por usuarios:** rango de números propio, premios o productos definidos por el Organizador, participación con saldo VIRTUAL, comisión de plataforma del 5 %, códigos privados, historial, expulsiones y reclamos.

Ambos módulos comparten autenticación, usuarios, libro contable, auditoría y API, pero no comparten automáticamente reglas de premios, estados, fondos ni método de selección del ganador.

La web y la aplicación móvil deben consumir la misma API. Las reglas financieras, de autorización, tiempo, disponibilidad, resultados y premios pertenecen al backend y nunca deben depender del navegador o del dispositivo.

### Reglas funcionales congeladas destacadas

- Conversión VIRTUAL→REAL: comisión del 10 %; el retiro posterior no cobra una segunda comisión de negocio.
- Compra mayorista del Vendedor: 0,90 REAL por cada 1,00 VIRTUAL.
- Solicitud Cliente→Vendedor: REAL reservado y fallback automático a los cinco minutos.
- Reserva de combinación oficial: hasta cinco minutos, sin superar el cierre de ventas.
- Compra oficial: límite del 20 % durante el primer 80 % de la ventana.
- Evento oficial publicado: inmutable; cancelación anterior al resultado con devolución total.
- Sorteo de usuario: 5 % de comisión retenida y 95 % en escrow hasta entrega o resolución.
- Resultados: únicos, inmutables, generados por servidor y verificables mediante hash.


## Estado actual

El repositorio se encuentra en una fase inicial de infraestructura y scaffolding:

- Monorepo con `pnpm` y Turborepo.
- API NestJS inicial.
- Worker NestJS inicial.
- Web Next.js inicial.
- Aplicación móvil Expo/React Native inicial.
- PostgreSQL y Redis configurados mediante Docker Compose.
- Prisma configurado, todavía pendiente del modelo físico definitivo y sus migraciones de dominio.

La presencia de una pantalla, endpoint o estructura inicial no significa que la regla de negocio correspondiente ya esté implementada o validada.

El módulo de sorteos creados por usuarios pertenece al alcance aprobado de Lotería Binaria como contexto independiente. `PEND-ORG-001` a `PEND-ORG-010` ya fueron resueltos o excluidos formalmente mediante `ADR-ORG-001`; no existen decisiones funcionales abiertas para comenzar el esquema Prisma y las migraciones v1.

## Baseline documental congelada

La versión 1 se implementa a partir de estos documentos aprobados:

| Documento | Versión | Materia |
| --- | ---: | --- |
| `docs/REGLAS-NEGOCIO.md` | 1.4.0 | Reglas `LOT-*`, pruebas esperadas y decisiones finales. |
| `docs/ESTADOS-Y-TRANSICIONES.md` | 1.1.0 | Máquinas de estado y transiciones válidas. |
| `docs/FLUJOS-FINANCIEROS.md` | 1.1.0 | Cuentas, doble entrada, tasas y residuos. |
| `docs/MATRIZ-DE-PERMISOS.md` | 1.1.0 | Rol, modo, recurso, guardas y denegaciones. |
| `docs/DICCIONARIO-DE-DATOS.md` | 1.1.0 | Tablas, campos, FKs, restricciones e índices. |
| `docs/PLAN-TECNICO.md` | 1.1.0 | Arquitectura, fases, seguridad, pruebas y despliegue. |
| `docs/DECISIONES-ARQUITECTURA/ADR-ORG-001-RESOLUCION-SORTEOS-USUARIOS.md` | Aprobado | Resolución del contexto `user_draws`. |

Estos documentos están congelados para la implementación v1. Prisma, SQL, API, web y mobile deben traducirlos, no reinterpretarlos. Las decisiones técnicas que no cambien la lógica —por ejemplo, proveedor S3 o particionado futuro— pueden documentarse mediante ADR.

## Fuentes normativas

La implementación debe respetar esta jerarquía:

1. Documento Maestro v1.0 y adendas aprobadas, incluido `ADR-ORG-001`.
2. `docs/REGLAS-NEGOCIO.md` v1.4.0.
3. Estados, flujos, permisos y diccionario de datos, cada uno dentro de su materia.
4. `docs/PLAN-TECNICO.md` v1.1.0.
5. OpenAPI, Prisma y migraciones.
6. Código y pruebas.
7. README como guía operativa.

Cuando exista una contradicción no resuelta, se detiene el cambio y se documenta la decisión antes de modificar SQL o código. Las reglas de negocio no deben deformarse para simplificar la implementación.

El frontend demostrativo anterior basado en HTML, CSS, JavaScript, JSON o `localStorage` solo puede usarse como referencia visual y de navegación. No es fuente de verdad financiera, de seguridad ni de datos.

## Arquitectura

```mermaid
flowchart TD
    WEB[Web\nNext.js + React + TypeScript]
    MOBILE[Mobile\nExpo + React Native + TypeScript]
    API[API central\nNestJS + TypeScript]
    WORKER[Worker\nNestJS + BullMQ]
    DB[(PostgreSQL\nFuente de verdad)]
    REDIS[(Redis\nColas, caché y datos temporales)]
    STORAGE[(Object Storage\nFase posterior)]

    WEB -->|HTTPS / REST / eventos| API
    MOBILE -->|HTTPS / REST / eventos| API
    API --> DB
    API --> REDIS
    WORKER --> DB
    WORKER --> REDIS
    API -.-> STORAGE
    WORKER -.-> STORAGE
```

### Componentes

| Componente | Tecnología | Responsabilidad |
| --- | --- | --- |
| `apps/api` | NestJS | Autenticación, permisos, validaciones, reglas, transacciones y contratos HTTP. |
| `apps/worker` | NestJS + BullMQ | Expiraciones, sorteos, acreditaciones, reconciliaciones y trabajos reintentables. |
| `apps/web` | Next.js | Landing, autenticación y paneles web. |
| `apps/mobile` | Expo + React Native | Aplicación Android/iOS. La primera entrega prioriza Cliente y Vendedor; las funciones de Organizador pueden incorporarse por fase sin cambiar la API ni las reglas congeladas. |
| PostgreSQL | PostgreSQL 16 | Fuente de verdad relacional, histórica y contable. |
| Redis | Redis 7 | Colas, caché, rate limiting, locks auxiliares y datos efímeros. |
| Prisma | Prisma | Acceso tipado, validación del esquema y migraciones versionadas. |
| Monorepo | pnpm + Turborepo | Dependencias, scripts y tareas coordinadas. |

> Redis nunca reemplaza a PostgreSQL. La web y el móvil nunca deben conectarse directamente a PostgreSQL o Redis.

## Estructura del repositorio

```text
loteria-binaria/
├── apps/
│   ├── api/                 # API NestJS
│   ├── worker/              # Procesos asíncronos
│   ├── web/                 # Aplicación Next.js
│   └── mobile/              # Aplicación Expo/React Native
├── prisma/
│   └── schema.prisma        # Esquema de base de datos
├── docs/
│   ├── REGLAS-NEGOCIO.md
│   ├── ESTADOS-Y-TRANSICIONES.md
│   ├── FLUJOS-FINANCIEROS.md
│   ├── MATRIZ-DE-PERMISOS.md
│   ├── DICCIONARIO-DE-DATOS.md
│   ├── PLAN-TECNICO.md
│   └── DECISIONES-ARQUITECTURA/
│       └── ADR-ORG-001-RESOLUCION-SORTEOS-USUARIOS.md
├── scripts/
│   └── doctor-local.sh      # Diagnóstico del entorno local
├── compose.yaml             # PostgreSQL y Redis
├── prisma.config.ts         # Configuración de Prisma
├── pnpm-workspace.yaml      # Workspaces del monorepo
├── turbo.json               # Tareas de Turborepo
├── package.json             # Scripts raíz y versiones base
└── README.md
```

La arquitectura objetivo también contempla `packages/`, `docs/`, `infrastructure/` y `.github/workflows/` conforme avance el proyecto.

## Requisitos

### Obligatorios

- Git.
- Node.js **24.18.0**.
- pnpm **10.33.4**.
- Docker Desktop con integración WSL 2, o Docker Engine en Linux.
- Docker Compose v2.

### Para desarrollo móvil

- Expo Go en un dispositivo compatible, o un emulador Android/iOS.
- Android Studio para emulador Android o compilaciones nativas.
- Xcode en macOS para iOS.
- Dispositivo y computadora en la misma red cuando se use Expo mediante LAN.

### Verificación rápida

```bash
git --version
node --version
pnpm --version
docker --version
docker compose version
```

La versión de Node debe coincidir con `.nvmrc`:

```bash
nvm install
nvm use
```

Cuando `pnpm` no esté instalado:

```bash
npm install --global pnpm@10.33.4
```

## Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/Herrera2005/loteria-binaria.git
cd loteria-binaria
```

### 2. Seleccionar la versión de Node

```bash
nvm install
nvm use
node --version
```

Resultado esperado:

```text
v24.18.0
```

### 3. Instalar las dependencias

```bash
pnpm install --frozen-lockfile
```

No se deben crear `package-lock.json` ni `yarn.lock`. El archivo oficial de dependencias es `pnpm-lock.yaml`.

### 4. Crear el archivo `.env`

El repositorio no debe guardar secretos reales. Cree `.env` en la raíz usando la plantilla de la siguiente sección.

### 5. Iniciar infraestructura

```bash
docker compose up -d --wait postgres redis
```

### 6. Validar Prisma y generar el cliente

```bash
pnpm db:validate
pnpm db:generate
pnpm db:status
```

### 7. Iniciar las aplicaciones

```bash
pnpm dev
```

`pnpm dev` inicia API, web y worker. La aplicación móvil se inicia por separado con `pnpm dev:mobile`.

## Variables de entorno

Cree un archivo `.env` en la raíz del repositorio:

```dotenv
# PostgreSQL local
POSTGRES_DB=loteria_binaria
POSTGRES_USER=loteria_binaria
POSTGRES_PASSWORD=lb_dev_change_me
POSTGRES_PORT=5433

# Prisma se conecta al puerto publicado por Docker
DATABASE_URL=postgresql://loteria_binaria:lb_dev_change_me@localhost:5433/loteria_binaria?schema=public

# Redis local
REDIS_PASSWORD=lb_redis_dev_change_me
REDIS_PORT=6380
REDIS_URL=redis://:lb_redis_dev_change_me@localhost:6380

# API
API_PORT=3001
```

### Variables de integración previstas

Estas variables deberán habilitarse cuando web y móvil empiecen a consumir la API:

```dotenv
# Web: accesible desde el navegador de la misma computadora
NEXT_PUBLIC_API_URL=http://localhost:3001/api/v1

# Móvil físico: usar la IP LAN de la computadora, no localhost
EXPO_PUBLIC_API_URL=http://192.168.1.100:3001/api/v1
```

Reemplace `192.168.1.100` por la IP local de la computadora que ejecuta la API.

### Reglas de secretos

- `.env` y `.env.*` no se suben a Git.
- Solo `.env.example`, sin credenciales reales, puede versionarse.
- Producción debe usar un gestor de secretos.
- Las claves de autenticación, cifrado y sorteos deben ser independientes.
- Los parámetros históricos de negocio no deben guardarse únicamente como variables de entorno; deben pertenecer a versiones de reglas en PostgreSQL.

## PostgreSQL y Redis

### Iniciar

```bash
docker compose up -d --wait postgres redis
```

### Consultar estado

```bash
docker compose ps
```

Los puertos locales predeterminados son:

| Servicio | Host | Puerto local | Puerto interno |
| --- | --- | ---: | ---: |
| PostgreSQL | `127.0.0.1` | `5433` | `5432` |
| Redis | `127.0.0.1` | `6380` | `6379` |

### Ver logs

```bash
docker compose logs -f postgres redis
```

### Probar PostgreSQL

```bash
docker compose exec postgres \
  sh -lc 'pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"'
```

### Probar Redis

```bash
docker compose exec redis \
  sh -lc 'REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli ping'
```

Resultado esperado:

```text
PONG
```

### Detener sin borrar datos

```bash
docker compose stop
```

### Detener y retirar contenedores sin borrar volúmenes

```bash
docker compose down
```

> [!CAUTION]
> `docker compose down -v` elimina los volúmenes y destruye la base local de PostgreSQL y los datos persistidos de Redis. Úselo únicamente cuando se quiera reiniciar deliberadamente el entorno de desarrollo.

### Diagnóstico automático

En Linux o WSL:

```bash
chmod +x scripts/doctor-local.sh
./scripts/doctor-local.sh
```

El script comprueba herramientas, `.env`, Docker Compose, salud de PostgreSQL y Redis, versión de Node, Prisma y estado de Git.

## Migraciones y Prisma

PostgreSQL es la fuente de verdad y todo cambio de estructura debe realizarse mediante una migración versionada.

### Validar el esquema

```bash
pnpm db:validate
```

### Generar Prisma Client

```bash
pnpm db:generate
```

### Consultar estado de migraciones

```bash
pnpm db:status
```

### Crear una migración durante desarrollo

Solo después de que el cambio de modelo haya sido revisado:

```bash
pnpm exec prisma migrate dev --name nombre_descriptivo
```

Ejemplos de nombres:

```text
create_identity_tables
add_ledger_accounts
add_draw_event_constraints
```

### Aplicar migraciones ya creadas

En staging o producción:

```bash
pnpm exec prisma migrate deploy
```

### Abrir Prisma Studio

```bash
pnpm db:studio
```

### Reglas obligatorias de migración

- No editar ni borrar una migración que ya haya sido aplicada o compartida.
- Crear una nueva migración correctiva.
- No usar `prisma db push` como sustituto de migraciones oficiales.
- Revisar restricciones, índices, claves foráneas y efectos sobre datos existentes.
- Los cambios financieros deben incluir estrategia segura de avance y recuperación.
- No crear modelos o migraciones basados en reglas antiguas del prototipo.
- No ejecutar migraciones destructivas en producción sin respaldo y plan aprobado.
- Toda migración debe citar las reglas `LOT-*`, máquinas, flujos y permisos afectados.
- El `schema.prisma` final debe conservar las 101 tablas y relaciones aprobadas o justificar formalmente cualquier cambio de implementación equivalente.

## Inicio de las aplicaciones

Ejecute los comandos desde la raíz del monorepo.

### API

```bash
pnpm dev:api
```

Dirección local predeterminada:

```text
http://localhost:3001
```

El puerto se controla con `API_PORT` y, como respaldo, `PORT`.

### Web

```bash
pnpm dev:web
```

Dirección local predeterminada:

```text
http://localhost:3000
```

### Worker

```bash
pnpm dev:worker
```

El worker no expone una página web. Debe mostrar en consola:

```text
Worker iniciado correctamente
```

### Mobile

```bash
pnpm dev:mobile
```

Expo mostrará opciones para abrir la aplicación en:

- Expo Go mediante código QR.
- Emulador Android.
- Simulador iOS en macOS.
- Navegador, cuando corresponda.

Comandos adicionales:

```bash
pnpm --filter mobile android
pnpm --filter mobile ios
pnpm --filter mobile web
```

Para un dispositivo físico, la URL de la API debe usar la IP LAN de la computadora. `localhost` dentro del teléfono apunta al propio teléfono.

### API, web y worker juntos

```bash
pnpm dev
```

### Todos los workspaces, incluido mobile

```bash
pnpm dev:all
```

Para depurar con claridad, se recomienda iniciar infraestructura y cada aplicación en terminales separadas.

## Pruebas y calidad

### Comprobación completa disponible

```bash
pnpm check
```

Este comando ejecuta:

1. Typecheck.
2. Lint.
3. Pruebas registradas.
4. Build.

### Comandos individuales

```bash
pnpm typecheck
pnpm lint
pnpm test
pnpm build
```

> [!CAUTION]
> En el estado actual del repositorio, los scripts `lint` de API y worker incluyen `--fix`, por lo que pueden modificar archivos. Antes de configurar CI debe añadirse una variante de verificación sin corrección automática, por ejemplo `lint:check`.

### API

```bash
pnpm --filter api test
pnpm --filter api test:watch
pnpm --filter api test:cov
pnpm --filter api test:e2e
```

### Worker

```bash
pnpm --filter worker test
pnpm --filter worker test:watch
pnpm --filter worker test:cov
pnpm --filter worker test:e2e
```

### Estado de cobertura actual

En el scaffolding actual, API y worker tienen scripts Jest. Web y mobile todavía no tienen un script `test` integrado al comando raíz; deben añadirse conforme se implementen sus primeras historias funcionales.

### Pruebas obligatorias antes de considerar completo el sistema

- Reglas matemáticas Octal, Decimal y Hexadecimal.
- Normalización y combinaciones sin repetidos.
- Compra concurrente de una misma combinación.
- Reserva expirada y cierre durante compra.
- Límite inicial del 20% y liberación al 80% de la ventana.
- Doble clic e idempotencia.
- Libro contable balanceado y saldos no negativos.
- Política de mayores residuos de `LOT-FIN-013` y redondeo a cuartos.
- Dos vendedores intentando tomar la misma solicitud.
- Carrera entre vendedor y conversión automática al minuto cinco.
- Resultado único, inmutable y verificable.
- Premios, devoluciones y reembolsos sin doble acreditación.
- Códigos privados de un solo uso y reclamación concurrente.
- Expulsión sin pérdida del historial ni del derecho a reclamar.
- Separación entre reglas de lotería oficial y sorteos creados por usuarios.
- Autorización por rol, modo activo y propiedad contextual del Organizador.
- Manipulación del reloj del dispositivo.
- Recuperación después de reinicios o fallos temporales.

No se debe fusionar código si fallan lint, tipos o pruebas críticas. No se debe liberar una versión si fallan concurrencia, idempotencia o reconciliación.

## Convenciones de Git

### Rama principal

- `main` debe permanecer estable y desplegable.
- No realizar push directo a `main` cuando exista flujo de pull requests.
- Para un equipo pequeño se utilizan ramas cortas creadas desde `main`.
- `develop` solo se adoptará mediante una decisión formal; no debe introducirse de forma accidental.

### Nombres de ramas

```text
feature/<descripcion>
fix/<descripcion>
docs/<descripcion>
refactor/<descripcion>
security/<descripcion>
```

Ejemplos:

```text
feature/ledger-base
fix/redis-connection
docs/readme-inicial
security/refresh-token-rotation
```

### Commits convencionales

```text
feat: nueva funcionalidad
fix: corrección de error
docs: documentación
test: pruebas
refactor: cambio interno sin modificar comportamiento
chore: mantenimiento o herramientas
```

Ejemplos:

```text
feat(api): agregar health check
fix(worker): evitar duplicar un trabajo reintentado
docs: documentar entorno local
test(ledger): validar transacciones balanceadas
refactor(web): separar componentes del dashboard
chore: actualizar configuración de Turbo
```

### Flujo recomendado

```bash
git switch main
git pull --ff-only
git switch -c docs/readme-inicial

# Realizar cambios y pruebas
pnpm check

git status
git add README.md
git commit -m "docs: documentar instalación y ejecución local"
git push -u origin docs/readme-inicial
```

### Pull requests

Toda pull request debe indicar:

- Objetivo y alcance.
- Regla o historia afectada.
- Riesgos.
- Pruebas ejecutadas.
- Cambios de variables de entorno.
- Migraciones incluidas o confirmación de que no existen.
- Impacto en API, web, mobile, worker y datos.
- Evidencia cuando modifica una operación crítica.

Los cambios de dinero, ledger, permisos, sorteos, resultados, fondos, migraciones o seguridad requieren una revisión reforzada.

### Archivos que no deben versionarse

- `.env` y secretos.
- `node_modules/`.
- `.next/`, `dist/`, `build/`, `.expo/` y `.turbo/`.
- `coverage/`.
- Logs y respaldos locales.
- Credenciales, tokens o datos reales.
- Copias `*.backup`.

Las carpetas vacías que deban conservarse pueden incluir un archivo `.gitkeep`.

> [!NOTE]
> En la revisión del repositorio público del 26 de julio de 2026 todavía aparecen `package.json.backup` y el directorio `.turbo/`. Ambos contradicen estas convenciones y deben retirarse del control de versiones cuando se confirme que no contienen información necesaria.

## Reglas técnicas obligatorias

Estas reglas previenen errores estructurales durante el desarrollo:

1. PostgreSQL y el libro contable son la fuente de verdad.
2. Redis solo contiene colas, caché, locks auxiliares o estado derivado.
3. Web y mobile presentan información; la API decide.
4. Los saldos no se calculan ni se aceptan desde el cliente.
5. Los montos se almacenan como enteros en centavos o centésimas; nunca como `float` o `double`.
6. REAL y VIRTUAL son unidades distintas y no se mezclan sin una conversión explícita.
7. Toda operación financiera o crítica debe ser transaccional, auditable e idempotente.
8. La hora del servidor y la base de datos es la autoridad para cierres y expiraciones.
9. Un evento oficial publicado no se edita; solo puede cancelarse mediante el flujo autorizado antes de fijar el resultado. Un resultado fijado es inmutable.
10. Las correcciones financieras se realizan con operaciones compensatorias, no editando el historial.
11. Una combinación completa no puede venderse dos veces dentro del mismo evento.
12. Un resultado, premio, reembolso o solicitud solo puede completarse una vez.
13. Las reglas históricas pertenecen a versiones inmutables en base de datos, no a números mágicos dispersos.
14. `localStorage`, JSON local, caché móvil o estado de React nunca son fuente de verdad.
15. Ningún secreto real debe aparecer en código, commits, logs, capturas o documentación pública.
16. Organizador no concede permisos globales: solo administra los sorteos de usuario que le pertenecen.
17. Los sorteos creados por usuarios utilizan el saldo VIRTUAL del libro global, pero mantienen reglas, estados y contabilidad de dominio separadas de la lotería oficial.
18. Los repartos 90/10, 95/5 y 50/25/15/10 usan la política de mayores residuos de `LOT-FIN-013`; las compras mayoristas aceptan incrementos de 1,00 VIRTUAL.
19. No existen decisiones funcionales abiertas en la baseline v1; cualquier comportamiento adicional pertenece a una versión futura y no puede introducirse silenciosamente.

## Solución de problemas

### Docker no responde

```bash
docker info
docker compose version
```

En Windows, verifique que Docker Desktop esté iniciado y que la distribución WSL tenga integración habilitada.

### El archivo Compose indica variables no definidas

Confirme que `.env` exista en la raíz:

```bash
ls -la .env
docker compose config
```

### PostgreSQL no acepta conexiones

```bash
docker compose ps
docker compose logs postgres
```

Confirme que `DATABASE_URL` use el puerto local `5433`, salvo que `POSTGRES_PORT` haya sido cambiado.

### Redis rechaza la conexión

```bash
docker compose logs redis
docker compose exec redis \
  sh -lc 'REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli ping'
```

Confirme que `REDIS_URL` y `REDIS_PASSWORD` coincidan.

### La versión de Node es incorrecta

```bash
nvm install
nvm use
node --version
```

### Prisma no encuentra `DATABASE_URL`

- Confirme que `.env` esté en la raíz.
- Ejecute los comandos desde la raíz del repositorio.
- Revise que la contraseña en `DATABASE_URL` coincida con `POSTGRES_PASSWORD`.

```bash
pnpm db:validate
```

### El teléfono no se conecta a la API

- No use `localhost` como host de la API en un dispositivo físico.
- Use la IP LAN de la computadora.
- Confirme que API y teléfono estén en la misma red.
- Verifique el firewall del sistema.
- La API escucha en `0.0.0.0`, pero PostgreSQL y Redis permanecen limitados a `127.0.0.1`.

---

**Autor académico:** Cristhian Herrera Nieto  
**Proyecto:** Lotería Binaria  
**Estado del README:** guía operativa oficial alineada con la baseline documental congelada v1; se actualiza únicamente cuando cambian comandos, infraestructura o una nueva versión documental aprobada.
