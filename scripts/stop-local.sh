#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo
echo "=== Cierre seguro de Lotería Binaria ==="
echo

MATCHING_PROCESSES="$(
  pgrep -f \
    'nest start --watch|next dev|expo start|prisma studio|turbo run dev' \
    || true
)"

if [[ -n "$MATCHING_PROCESSES" ]]; then
  echo "Deteniendo procesos de desarrollo:"
  echo "$MATCHING_PROCESSES"

  kill $MATCHING_PROCESSES 2>/dev/null || true
  sleep 2
fi

REMAINING_PROCESSES="$(
  pgrep -f \
    'nest start --watch|next dev|expo start|prisma studio|turbo run dev' \
    || true
)"

if [[ -n "$REMAINING_PROCESSES" ]]; then
  echo "Forzando cierre de procesos restantes:"
  echo "$REMAINING_PROCESSES"

  kill -9 $REMAINING_PROCESSES 2>/dev/null || true
fi

docker compose stop

echo
docker compose ps
echo

echo "✅ Servicios locales detenidos."
echo "Los volúmenes y datos de PostgreSQL se conservaron."