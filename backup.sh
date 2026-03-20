#!/bin/bash
set -e
S3_BUCKET="s3://your-bucket-name/backups"
CONTAINER_NAME="mysql"
BACKUP_DIR="/tmp/backups"
TIMESTAMP=$(date +"%Y-%m-%d-%H%M")
FILENAME="backup-${TIMESTAMP}.sql"
FILEPATH="${BACKUP_DIR}/${FILENAME}"

echo ">>> Starting backup: $FILENAME"
mkdir -p "$BACKUP_DIR"

docker exec "$CONTAINER_NAME" \
    sh -c 'MYSQL_PWD=$MYSQL_ROOT_PASSWORD mysqldump -u root --all-databases' \
    > "$FILEPATH"
S3_PATH="${S3_BUCKET}/${FILENAME}"
aws s3 cp "$FILEPATH" "$S3_PATH"
rm "$FILEPATH"
echo ">>> Local file cleaned up."
