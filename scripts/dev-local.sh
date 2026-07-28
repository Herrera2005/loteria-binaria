#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SERVICE="${1:-api}"

case "$SERVICE" in
  api)
    exec pnpm dev:api
    ;;

  web)
    exec pnpm dev:web
    ;;

  worker)
    exec pnpm dev:worker
    ;;

  mobile)
    exec pnpm dev:mobile
    ;;

  studio)
    exec pnpm db:studio
    ;;

  *)
    echo "Uso:"
    echo "  pnpm dev:local api"
    echo "  pnpm dev:local web"
    echo "  pnpm dev:local worker"
    echo "  pnpm dev:local mobile"
    echo "  pnpm dev:local studio"
    exit 1
    ;;
esac