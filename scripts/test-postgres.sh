#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail() {
  printf '❌ %s\n' "$1" >&2
  exit 1
}

ok() {
  printf '✅ %s\n' "$1"
}

if [[ ! -f .env.test ]]; then
  fail "No existe .env.test. Ejecuta: cp .env.test.example .env.test"
fi

set -a
# shellcheck disable=SC1091
source .env.test
set +a

if [[ "${NODE_ENV:-}" != "test" ]]; then
  fail "NODE_ENV debe ser test"
fi

if [[ -z "${TEST_DATABASE_ADMIN_URL:-}" ]]; then
  fail "Falta TEST_DATABASE_ADMIN_URL en .env.test"
fi

if [[ -z "${TEST_DATABASE_URL:-}" ]]; then
  fail "Falta TEST_DATABASE_URL en .env.test"
fi

if [[ "$TEST_DATABASE_URL" != *"test"* ]]; then
  fail "TEST_DATABASE_URL no parece apuntar a una base de pruebas"
fi

if [[ "$TEST_DATABASE_URL" == *":5433/"* ]]; then
  fail "TEST_DATABASE_URL apunta al puerto 5433 de desarrollo"
fi

ok "Variables de prueba cargadas"

docker compose \
  --env-file .env.test \
  -f compose.test.yaml \
  up -d --wait

ok "PostgreSQL de pruebas está disponible"

pnpm --filter @loteria-binaria/test-utils build

ok "test-utils compilado"

pnpm --filter api test:pg "$@"
