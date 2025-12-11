#!/bin/sh
set -eu

PORT="${PORT:-8080}"
HOST="0.0.0.0"

mkdir -p /tmp/.wrangler

VAR_ARG=""
if [ -n "${JINA_API_KEY-}" ]; then
  VAR_ARG="--var JINA_API_KEY=${JINA_API_KEY}"
fi

exec npx wrangler dev src/index.ts \
  --local \
  --ip "${HOST}" \
  --port "${PORT}" \
  --config wrangler.jsonc \
  --persist-to /tmp/.wrangler \
  --local-protocol http \
  ${VAR_ARG} \
  "$@"
