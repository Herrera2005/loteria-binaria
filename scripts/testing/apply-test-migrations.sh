#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail() {
  printf '❌ %s\n' "$1" >&2
  exit 1
}

ok() {
  printf '✅ %s\n' "$1"
}

[[ -f .env.test ]] \
  || fail "No existe .env.test"

set -a
# shellcheck disable=SC1091
source .env.test
set +a

[[ "${NODE_ENV:-}" == "test" ]] \
  || fail "NODE_ENV debe ser test"

[[ -n "${TEST_DATABASE_URL:-}" ]] \
  || fail "TEST_DATABASE_URL no está definida"

case "$TEST_DATABASE_URL" in
  *localhost:5434/*test*)
    ;;
  *)
    fail "TEST_DATABASE_URL no parece apuntar a PostgreSQL de pruebas"
    ;;
esac

export DATABASE_URL="$TEST_DATABASE_URL"

docker inspect lb-postgres-test >/dev/null 2>&1 \
  || fail "El contenedor lb-postgres-test no existe"

container_status="$(
  docker inspect \
    --format='{{.State.Status}}' \
    lb-postgres-test
)"

[[ "$container_status" == "running" ]] \
  || fail "lb-postgres-test no está ejecutándose"

health_status="$(
  docker inspect \
    --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}unknown{{end}}' \
    lb-postgres-test
)"

[[ "$health_status" == "healthy" ]] \
  || fail "lb-postgres-test no está healthy"

ok "PostgreSQL de pruebas está disponible"

pnpm exec prisma validate \
  --schema=prisma/schema.prisma

ok "El esquema Prisma es válido"

pnpm exec prisma migrate deploy \
  --schema=prisma/schema.prisma

ok "Las migraciones fueron aplicadas"

pnpm exec prisma migrate status \
  --schema=prisma/schema.prisma

failed_migrations="$(
  docker exec lb-postgres-test \
    psql \
    -U "$TEST_POSTGRES_USER" \
    -d "$TEST_POSTGRES_DB" \
    -tAc '
      SELECT COUNT(*)
      FROM "_prisma_migrations"
      WHERE finished_at IS NULL
        AND rolled_back_at IS NULL;
    '
)"

[[ "$failed_migrations" == "0" ]] \
  || fail "Se detectaron migraciones incompletas"

ok "No existen migraciones incompletas"

table_count="$(
  docker exec lb-postgres-test \
    psql \
    -U "$TEST_POSTGRES_USER" \
    -d "$TEST_POSTGRES_DB" \
    -tAc "
      SELECT COUNT(*)
      FROM information_schema.tables
      WHERE table_schema = 'public'
        AND table_type = 'BASE TABLE'
        AND table_name <> '_prisma_migrations';
    "
)"

[[ "$table_count" =~ ^[0-9]+$ ]] \
  || fail "No se pudo contar las tablas"

(( table_count > 0 )) \
  || fail "La migración no creó tablas de aplicación"

ok "Se encontraron ${table_count} tablas de aplicación"
ok "Infraestructura de migraciones de prueba verificada"
