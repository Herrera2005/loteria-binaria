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

# Verificar comandos necesarios
for command_name in docker pnpm; do
  command -v "$command_name" >/dev/null 2>&1 \
    || fail "No se encontró el comando requerido: $command_name"
done

# Verificar que Docker esté iniciado
docker info >/dev/null 2>&1 \
  || fail "Docker Desktop no está iniciado o WSL no tiene integración"

# Verificar archivos esenciales
[[ -f compose.test.yaml ]] \
  || fail "No existe compose.test.yaml"

[[ -f apps/api/test/jest-postgres.json ]] \
  || fail "No existe apps/api/test/jest-postgres.json"

# A partir de aquí continúa lo que ya tenías
if [[ ! -f .env.test ]]; then
  fail "No existe .env.test. Ejecuta: cp .env.test.example .env.test"
fi

set -a
# shellcheck disable=SC1091
source .env.test
set +a
