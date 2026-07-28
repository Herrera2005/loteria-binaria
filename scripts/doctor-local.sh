#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

RUN_FULL_CHECK="${RUN_FULL_CHECK:-false}"
RUN_SEED="${RUN_SEED:-false}"

ok() {
  printf '✅ %s\n' "$1"
}

warn() {
  printf '⚠️ %s\n' "$1"
}

fail() {
  printf '❌ %s\n' "$1" >&2
  exit 1
}

section() {
  echo
  printf '=== %s ===\n' "$1"
  echo
}

require_env() {
  local variable_name="$1"

  if [[ -z "${!variable_name:-}" ]]; then
    fail "Falta la variable obligatoria: $variable_name"
  fi
}

section "Diagnóstico local de Lotería Binaria"

for command_name in git node pnpm docker curl; do
  command -v "$command_name" >/dev/null 2>&1 \
    || fail "No se encontró el comando: $command_name"
done

ok "Git, Node, pnpm, Docker y curl están disponibles"

section "Repositorio"

CURRENT_BRANCH="$(git branch --show-current)"

if [[ -z "$CURRENT_BRANCH" ]]; then
  fail "Git está en estado detached HEAD"
fi

ok "Rama actual: $CURRENT_BRANCH"

if [[ -n "$(git status --porcelain)" ]]; then
  warn "Hay cambios sin guardar en Git:"
  git status --short
else
  ok "Repositorio sin cambios pendientes"
fi

section "Configuración local"

[[ -f ".env" ]] \
  || fail "Falta el archivo .env"

git check-ignore -q .env \
  || fail "El archivo .env no está protegido por .gitignore"

ok ".env existe y está ignorado por Git"

set -a
# shellcheck disable=SC1091
source .env
set +a

require_env "DATABASE_URL"
require_env "REDIS_URL"
require_env "POSTGRES_USER"
require_env "POSTGRES_PASSWORD"
require_env "POSTGRES_DB"
require_env "REDIS_PASSWORD"

ok "Variables obligatorias presentes"

if [[ "${APP_ENV:-development}" == "production" ]] &&
   [[ "${SEED_DEMO_USERS:-false}" == "true" ]]; then
  fail "SEED_DEMO_USERS no puede estar habilitado en producción"
fi

if [[ "${SEED_DEMO_USERS:-false}" == "true" ]]; then
  require_env "SEED_DEMO_PASSWORD_HASH"

  if [[ "$SEED_DEMO_PASSWORD_HASH" != \$argon2id\$* ]]; then
    fail "SEED_DEMO_PASSWORD_HASH no parece un hash Argon2id"
  fi

  ok "Configuración de usuarios demo válida"
fi

section "Node y dependencias"

if [[ -f ".nvmrc" ]]; then
  EXPECTED_NODE="$(tr -d 'v[:space:]' < .nvmrc)"
  CURRENT_NODE="$(node -p 'process.version.slice(1)')"

  if [[ "$EXPECTED_NODE" != "$CURRENT_NODE" ]]; then
    fail \
      "Node actual: $CURRENT_NODE; esperado: $EXPECTED_NODE. Ejecuta: nvm use"
  fi

  ok "Versión de Node correcta: $CURRENT_NODE"
fi

[[ -d "node_modules" ]] \
  || fail "Falta node_modules. Ejecuta: pnpm install"

pnpm install --frozen-lockfile --offline >/dev/null 2>&1 \
  || warn \
    "No se pudo validar la instalación offline. Si cambió el lockfile, ejecuta pnpm install."

ok "Dependencias locales disponibles"

section "Docker"

docker info >/dev/null 2>&1 \
  || fail "Docker Desktop no está iniciado o WSL no tiene integración"

docker compose version >/dev/null 2>&1 \
  || fail "Docker Compose no responde"

docker compose config -q \
  || fail "El archivo compose.yaml contiene errores"

ok "Docker y Compose responden"

docker compose up -d --wait \
  || fail "No fue posible iniciar los contenedores"

ok "Contenedores iniciados"

docker compose exec -T postgres \
  sh -lc 'pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"' \
  >/dev/null \
  || fail "PostgreSQL no acepta conexiones"

ok "PostgreSQL responde"

REDIS_RESULT="$(
  docker compose exec -T redis \
    sh -lc 'REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli ping' \
    | tr -d '\r'
)"

[[ "$REDIS_RESULT" == "PONG" ]] \
  || fail "Redis no respondió PONG"

ok "Redis responde"

section "Prisma"

pnpm prisma validate >/dev/null \
  || fail "El esquema Prisma no es válido"

ok "Esquema Prisma válido"

pnpm db:generate >/dev/null \
  || fail "No se pudo generar Prisma Client"

ok "Prisma Client generado"

pnpm prisma migrate status \
  || fail "Las migraciones no coinciden con la base de datos"

ok "Migraciones actualizadas"

if [[ "$RUN_SEED" == "true" ]]; then
  pnpm db:seed \
    || fail "El seed no pudo ejecutarse"

  ok "Seed ejecutado"
fi

pnpm db:seed:verify \
  || fail "La verificación del seed falló"

ok "Seed verificado"

section "Procesos y puertos"

SUSPENDED_PROCESSES="$(
  ps aux |
    awk '$8 ~ /^T/ && $0 ~ /(nest|next|expo|prisma studio|turbo)/'
)"

if [[ -n "$SUSPENDED_PROCESSES" ]]; then
  warn "Hay procesos suspendidos:"
  echo "$SUSPENDED_PROCESSES"
  warn "Ciérralos antes de iniciar nuevos procesos."
else
  ok "No hay procesos de desarrollo suspendidos"
fi

for port in 3000 3001 5555 8081 19000 19001 19002; do
  if ss -ltn 2>/dev/null | grep -q ":${port} "; then
    warn "El puerto $port ya está ocupado"
  fi
done

section "Comprobaciones del monorepo"

if [[ "$RUN_FULL_CHECK" == "true" ]]; then
  pnpm check \
    || fail "pnpm check encontró errores"

  ok "Typecheck, lint, tests y build aprobados"
else
  warn "Comprobación completa omitida"
  echo "Ejecuta:"
  echo "  RUN_FULL_CHECK=true pnpm doctor:local"
fi

section "Estado final"

docker compose ps

echo
ok "Entorno local preparado"

echo
echo "Comandos siguientes:"
echo "  pnpm dev:api"
echo "  pnpm dev:web"
echo "  pnpm dev:worker"
echo "  pnpm dev:mobile"
echo "  pnpm db:studio"