#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

ok() {
  printf '✅ %s\n' "$1"
}

fail() {
  printf '❌ %s\n' "$1" >&2
  exit 1
}

echo
echo "=== Diagnóstico local de Lotería Binaria ==="
echo

for command_name in git node pnpm docker; do
  command -v "$command_name" >/dev/null 2>&1 \
    || fail "No se encontró el comando: $command_name"
done

ok "Git, Node, pnpm y Docker están disponibles"

docker info >/dev/null 2>&1 \
  || fail "Docker Desktop no está iniciado o WSL no tiene integración"

ok "Docker responde"

docker compose version >/dev/null 2>&1 \
  || fail "Docker Compose no responde"

docker compose config -q \
  || fail "El archivo compose.yaml contiene errores"

ok "Docker Compose es válido"

[[ -f ".env" ]] \
  || fail "Falta el archivo .env"

git check-ignore -q .env \
  || fail "El archivo .env no está protegido por .gitignore"

ok ".env existe y está ignorado por Git"

if [[ -f ".nvmrc" ]]; then
  EXPECTED_NODE="$(tr -d 'v[:space:]' < .nvmrc)"
  CURRENT_NODE="$(node -p 'process.version.slice(1)')"

  if [[ "$EXPECTED_NODE" != "$CURRENT_NODE" ]]; then
    fail "Node actual: $CURRENT_NODE; esperado: $EXPECTED_NODE. Ejecuta: nvm use"
  fi

  ok "Versión de Node correcta: $CURRENT_NODE"
fi

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

pnpm prisma validate >/dev/null \
  || fail "El esquema Prisma no es válido"

ok "Esquema Prisma válido"

pnpm prisma migrate status \
  || fail "Las migraciones no coinciden con la base de datos"

ok "Migraciones actualizadas"

echo
docker compose ps
echo

if [[ -n "$(git status --porcelain)" ]]; then
  echo "⚠️ Hay cambios sin guardar en Git:"
  git status --short
else
  ok "Repositorio sin cambios pendientes"
fi

echo
echo "✅ Entorno local preparado."
echo "Ahora puedes ejecutar: pnpm dev"
