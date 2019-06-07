#!/usr/bin/env bash
set -e

wait-for-it.sh \
    -h ${POSTGRES_HOSTNAME:-db} \
    -p ${POSTGRES_PORT:-5432} \
    -t 15 \
    -- echo 'database available'

echo 'database setup'
cd apps/re && mix ecto.setup || true
cd ../re_integrations && mix ecto.setup || true

# TODO (jpd): allow custom command to be executed
echo 'app available'
exec sleep infinity
