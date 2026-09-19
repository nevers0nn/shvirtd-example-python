#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="/opt/backup"
SECRETS_FILE="/opt/backup.env"
DB_CONTAINER="mysql-db-compose"

if [[ ! -f "$SECRETS_FILE" ]]; then
    echo "Файл с учётными данными $SECRETS_FILE не найден" >&2
    exit 1
fi

set -a
source "$SECRETS_FILE"
set +a

mkdir -p "$BACKUP_DIR"

NETWORK_NAME=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' "$DB_CONTAINER")

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DUMP_FILE="${DB_NAME}_${TIMESTAMP}.sql"

docker run --rm \
    --network "$NETWORK_NAME" \
    -v "$BACKUP_DIR:/backup" \
    -e MYSQL_HOST="$DB_HOST" \
    -e MYSQL_USER="$DB_USER" \
    -e MYSQL_PASSWORD="$DB_PASSWORD" \
    -e MYSQL_DATABASE="$DB_NAME" \
    --entrypoint sh \
    schnitzler/mysqldump \
    -c 'mysqldump --opt --no-tablespaces -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" > "/backup/'"$DUMP_FILE"'"'

find "$BACKUP_DIR" -name '*.sql' -mtime +7 -delete
