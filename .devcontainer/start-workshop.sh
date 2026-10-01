#!/usr/bin/env bash
set -eu

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

docker network inspect pg-network >/dev/null 2>&1 || docker network create pg-network >/dev/null
docker volume create ny_taxi_postgres_data >/dev/null
docker volume create pgadmin_data >/dev/null

docker compose up -d

if pgrep -f '[j]upyter-notebook.*--port=8888' >/dev/null; then
  exit 0
fi

nohup uv run jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser \
  >"${TMPDIR:-/tmp}/pipeline-jupyter.log" 2>&1 </dev/null &