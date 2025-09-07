#!/bin/bash
set -e

# ---- CONFIG ----
VOLUME_NAME="jenkins_home"
BACKUP_DIR="/opt/backups/jenkins"
BACKUP_FILE="$1"   # pass the backup tar.gz as argument

if [ -z "$BACKUP_FILE" ]; then
  echo "Usage: $0 <backup_file.tar.gz>"
  echo "Example: $0 $BACKUP_DIR/jenkins_home_2025-09-07-1010.tar.gz"
  exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
  echo "Error: Backup file not found: $BACKUP_FILE"
  exit 2
fi

echo ">>> Stopping Jenkins container..."
docker stop jenkins || true

echo ">>> Cleaning existing Jenkins volume data..."
docker run --rm -v ${VOLUME_NAME}:/var/jenkins_home alpine \
  sh -c "rm -rf /var/jenkins_home/*"

echo ">>> Restoring from backup: $BACKUP_FILE"
docker run --rm \
  -v ${VOLUME_NAME}:/var/jenkins_home \
  -v ${BACKUP_DIR}:/backup \
  alpine sh -c "tar -xzf /backup/$(basename $BACKUP_FILE) -C /var"

echo ">>> Fixing permissions..."
docker run --rm -v ${VOLUME_NAME}:/var/jenkins_home alpine \
  sh -c "chown -R 1000:1000 /var/jenkins_home"

echo ">>> Starting Jenkins..."
docker start jenkins

echo "✅ Restore completed successfully!"

