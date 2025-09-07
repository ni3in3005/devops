#!/bin/bash
set -e

BACKUP_DIR="/opt/backups/jenkins"
TIMESTAMP=$(date +%F-%H%M)
ARCHIVE="$BACKUP_DIR/jenkins_home_$TIMESTAMP.tar.gz"

mkdir -p $BACKUP_DIR

echo "Starting Jenkins backup..."
docker exec jenkins bash -c "tar --exclude='jenkins_home/workspace/*' -czf - -C /var jenkins_home" > $ARCHIVE

echo "Backup completed: $ARCHIVE"

