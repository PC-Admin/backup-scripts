#!/bin/bash

# Note you need the curl, jq, postgres-client-15 and pv packages to use this script!

DATE=$(date '+%Y-%m-%d_%H-%M')
DUMPFILEDIR="/mnt/mfs/Backups/matrix.perthchat.org/postgresql/"
LOGFILE="$HOME/.psql_dumps.log"
DBUSER="matrix"
DBPORT=5432
PATRONI_NODES=("postgres01.perthchat.org" "postgres02.perthchat.org" "postgres03.perthchat.org")
MAXNUMDUMPS=30

for url in "${PATRONI_NODES[@]}"; do
    # Execute curl and save the output to a variable
    RESPONSE=$(curl --max-time 60 -s http://$url:8008/patroni)
    # Check the status of curl
    if [ $? -ne 0 ]; then
        echo "${DATE} - Curl request to $url failed." >> ${LOGFILE}
        continue
    fi
    role=$(echo $RESPONSE | jq -r '.role')
    # Check the status of jq
    if [ $? -ne 0 ]; then
        echo "${DATE} - jq failed to parse the JSON from $url." >> ${LOGFILE}
        continue
    fi
    if [ "$role" = "master" ]; then
        DBHOST=$url
        # Capture the start time
        START_TIME=$(date +%s)
        # Execute the command
        time pg_dumpall -h ${DBHOST} -p ${DBPORT} -U ${DBUSER} | pv | pigz --stdout --fast --blocksize 16384 --independent --processes 4 --rsyncable > ${DUMPFILEDIR}postgres_${DATE}.sql.gz
        # Check the status of pg_dumpall
        if [ $? -eq 0 ]; then
            # Calculate the time taken
            END_TIME=$(date +%s)
            TIME_TAKEN=$((END_TIME - START_TIME))
            HOURS=$((TIME_TAKEN / 3600))
            MINUTES=$(( (TIME_TAKEN / 60) % 60))
            SECONDS=$((TIME_TAKEN % 60))
            echo "${DATE} - Database dump from replica ${DBHOST}:${DBPORT} was successful. The dump file is located at: ${DUMPFILEDIR}postgres_${DATE}.sql.gz The dump took $HOURS hours $MINUTES minutes $SECONDS seconds." >> ${LOGFILE}
            # If successful, exit the loop
            break
        else
            echo "${DATE} - Database dump from replica ${DBHOST}:${DBPORT} failed." >> ${LOGFILE}
        fi
    fi
done

# Delete old backup files and directories if there are more than the retention limit
FILE_COUNT=$(ls -1 $DUMPFILEDIR | wc -l)
while [ $FILE_COUNT -gt $MAXNUMDUMPS ]
do
  # Find the oldest file and delete it
  OLDEST_FILE=$(ls -t $DUMPFILEDIR | tail -1)
  time rm -rf "$DUMPFILEDIR/$OLDEST_FILE"
  echo "${DATE} - Deleted the oldest postgresql backup: ${DUMPFILEDIR}/${OLDEST_FILE}." >> ${LOGFILE}
  FILE_COUNT=$(ls -1 $DUMPFILEDIR | wc -l)
done
