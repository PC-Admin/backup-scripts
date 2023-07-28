#!/bin/bash

# Variables
LOG_FILE="/root/.lemmy_backup.log"
BACKUP_DIR="/srv/lemmy/lemmy.perthchat.org"
BACKUP_FILE="postgresql_dump_$(date +%Y-%m-%d'_'%H_%M_%S).sql.gz"
BORG_CONFIG="/root/.config/borgmatic/config.yaml"
POSTGRES_CONTAINER="lemmyperthchatorg_postgres_1"

# Cleanup old backup files
rm $BACKUP_DIR/postgresql_dump_* 2>> $LOG_FILE

# Database backup
START_TIME=$(date +%s)
docker exec $POSTGRES_CONTAINER pg_dumpall -c -U lemmy 2>> $LOG_FILE | gzip > $BACKUP_DIR/$BACKUP_FILE
END_TIME=$(date +%s)

# Time calculation
TIME_DIFF=$((END_TIME - START_TIME))
HOURS=$((TIME_DIFF / 3600))
MINUTES=$(( (TIME_DIFF / 60) % 60))
SECONDS=$((TIME_DIFF % 60))
echo "Database backup finished at $(date). Time taken: $MINUTES minutes $SECONDS seconds." >> $LOG_FILE

# Borgmatic backup
START_TIME=$(date +%s)
borgmatic --config $BORG_CONFIG 2>> $LOG_FILE
END_TIME=$(date +%s)

# Time calculation
TIME_DIFF=$((END_TIME - START_TIME))
HOURS=$((TIME_DIFF / 3600))
MINUTES=$(( (TIME_DIFF / 60) % 60))
SECONDS=$((TIME_DIFF % 60))
echo "Borgmatic backup finished at $(date). Time taken: $MINUTES minutes $SECONDS seconds." >> $LOG_FILE
