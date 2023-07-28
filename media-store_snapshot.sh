#!/bin/bash

DATETIME=$(date '+%Y-%m-%d_%H-%M')                                      # Get current date and time in a specific format
SOURCE_DIR="/mnt/mfs/media-store"                                       # Source directory to take snapshot from
SNAPSHOT_DIR="/mnt/mfs/Backups/matrix.perthchat.org/media-store/"       # Directory to save snapshots
DESTINATION_DIR="${SNAPSHOT_DIR}media-store_${DATETIME}"                # Create a destination directory path with timestamp
LOG_FILE="${HOME}/.mfs-snapshots.log"                                   # Log file path
MAXNUMDUMPS=30                                                          # Max number of snapshot folders to retain

# Capture the start time
START_TIME=$(date +%s)

# Take snapshot using mfsmakesnapshot
mfsmakesnapshot -o ${SOURCE_DIR} ${DESTINATION_DIR}

# Check the status of the last command run (mfsmakesnapshot command)
if [ $? -eq 0 ]
then
    # Calculate the time taken
    END_TIME=$(date +%s)
    TIME_TAKEN=$((END_TIME - START_TIME))
    HOURS=$((TIME_TAKEN / 3600))
    MINUTES=$(( (TIME_TAKEN / 60) % 60))
    SECONDS=$((TIME_TAKEN % 60))

    # Write to the log file in case of success
    echo "${DATETIME} - Snapshot was successfully made at ${DESTINATION_DIR} The snapshot took $MINUTES minutes $SECONDS seconds." >> ${LOG_FILE}
else
    # Write to the log file in case of error
    echo "${DATETIME} - Snapshot failed for ${DESTINATION_DIR}" >> ${LOG_FILE}
fi

# Delete old snapshots if there are more than MAXNUMDUMPS
SNAPSHOT_COUNT=$(find ${SNAPSHOT_DIR} -maxdepth 1 -type d -name 'media-store_*' | wc -l)
if [ ${SNAPSHOT_COUNT} -gt ${MAXNUMDUMPS} ]
then
    # Get the list of directories, sorted by name in reverse order (newest first), then select the ones to delete
    OLDEST_SNAPSHOTS=$(ls -d1 ${SNAPSHOT_DIR}media-store_* | sort -r | tail -n +$((${MAXNUMDUMPS}+1)))
    for SNAPSHOT in ${OLDEST_SNAPSHOTS}
    do
        DELETE_START_TIME=$(date +%s)
        mfsrmsnapshot ${SNAPSHOT}
        DELETE_END_TIME=$(date +%s)
        DELETE_TIME_TAKEN=$((DELETE_END_TIME - DELETE_START_TIME))
        DELETE_HOURS=$((DELETE_TIME_TAKEN / 3600))
        DELETE_MINUTES=$(( (DELETE_TIME_TAKEN / 60) % 60))
        DELETE_SECONDS=$((DELETE_TIME_TAKEN % 60))
        echo "${DATETIME} - Old snapshot ${SNAPSHOT} has been deleted. Deletion took $DELETE_MINUTES minutes $DELETE_SECONDS seconds." >> ${LOG_FILE}
    done
fi
