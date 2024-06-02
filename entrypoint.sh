#!/bin/bash

# From https://github.com/docker-library/mariadb/blob/master/docker-entrypoint.sh#L21-L41
# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_POSTGRES_PASSWORD' 'example'
# (will allow for "$XYZ_POSTGRES_PASSWORD_FILE" to fill in the value of
#  "$XYZ_POSTGRES_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
    exit 1
  fi
  local val="$def"
  if [ "${!var:-}" ]; then
    val="${!var}"
  elif [ "${!fileVar:-}" ]; then
    val="$(<"${!fileVar}")"
  fi
  export "$var"="$val"
  unset "$fileVar"
}

TZ=${TZ:-UTC}

POSTGRES_HOST=${POSTGRES_HOST:-db}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_USER=${POSTGRES_USER:-spliit}
POSTGRES_DB=${POSTGRES_DB:-spliit}
POSTGRES_TIMEOUT=${POSTGRES_TIMEOUT:-60}

echo "Setting timezone to ${TZ}..."
ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime
echo ${TZ} > /etc/timezone

file_env 'POSTGRES_USER'
file_env 'POSTGRES_PASSWORD'

export PGPASSWORD=${POSTGRES_PASSWORD}
POSTGRES_CMD="psql --host=${POSTGRES_HOST} --port=${POSTGRES_PORT} --username=${POSTGRES_USER} -lqt"

echo "Waiting ${POSTGRES_TIMEOUT}s for database to be ready..."
counter=1
while ${POSTGRES_CMD} | cut -d \| -f 1 | grep -qw "${POSTGRES_DB}" > /dev/null 2>&1; [ $? -ne 0 ]; do
  sleep 1
  counter=$((counter + 1))
  if [ ${counter} -gt "${POSTGRES_TIMEOUT}" ]; then
    >&2 echo "ERROR: Failed to connect to PostgreSQL database on $POSTGRES_HOST"
    exit 1
  fi;
done
echo "PostgreSQL database ready!"

connString="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"
export "POSTGRES_PRISMA_URL=${connString}"
export "POSTGRES_URL_NON_POOLING=${connString}"

unset POSTGRES_USER POSTGRES_PASSWORD POSTGRES_CMD PGPASSWORD

echo "Prisma migrate and deploy..."
npx prisma migrate deploy

exec "$@"
