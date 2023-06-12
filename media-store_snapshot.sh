#!/bin/bash

DATETIME=$(date '+%Y-%m-%d_%H-%M')					# Get current date and time in a specific format
SOURCE_DIR="/mnt/mfs/media-store"					# Source directory to take snapshot from
SNAPSHOT_DIR="/mnt/mfs/Backups/matrix.perthchat.org/media-store/"	# Directory to save snapshots
DESTINATION_DIR="${SNAPSHOT_DIR}media-store_${DATETIME}"		    # Create a destination directory path with timestamp
LOG_FILE="${HOME}/.mfs-snapshots.log"				# Log file path
MAXNUMDUMPS=30								        # Max number of snapshot folders to retain

# Take snapshot using mfsmakesnapshot
mfsmakesnapshot -o ${SOURCE_DIR} ${DESTINATION_DIR}

# Check the status of the last command run (mfsmakesnapshot command)
if [ $? -eq 0 ]
then
    # Write to the log file in case of success
    echo "${DATETIME} - Snapshot was successfully taken from ${SOURCE_DIR} to ${DESTINATION_DIR}" >> ${LOG_FILE}
else
    # Write to the log file in case of error
    echo "${DATETIME} - Snapshot failed for ${SOURCE_DIR} to ${DESTINATION_DIR}" >> ${LOG_FILE}
fi

# Delete old snapshots if there are more than 30
SNAPSHOT_COUNT=$(ls -dt ${SNAPSHOT_DIR}media-store_* | wc -l)
if [ ${SNAPSHOT_COUNT} -gt ${MAXNUMDUMPS} ]
then
    # Get the list of directories, sorted by modification time, and remove the 30 newest ones from the list
    OLDEST_SNAPSHOTS=$(ls -dt ${SNAPSHOT_DIR}media-store_* | tail -n +31)
    for SNAPSHOT in ${OLDEST_SNAPSHOTS}
    do
        rm -rf ${SNAPSHOT}
        echo "${DATETIME} - Old snapshot ${SNAPSHOT} has been deleted" >> ${LOG_FILE}
    done
fi