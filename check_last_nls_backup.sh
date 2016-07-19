#!/bin/bash

# Script:       check_last_nls_backup.sh
# Purpose:      Check most recent Elasticsearch/Nagios Log Server Backup - tested with curator 3.40
# Version:      0.1 initial creation
# Version:      0.2 changed --time-unit from 1 days to 25 hours, it appeared that a backup made yesterday evening (23:30) did not match filter "--newer-than 1 --time-unit days",  I assumed a last 24 hours filter. No matches
LAST=$(curator --loglevel warn show snapshots --repository "SharedBackupRepo" --newer-than 25 --time-unit hours  |tail -1)
RESULT=$(curl -s -XGET "localhost:9200/_snapshot/SharedBackupRepo/${LAST}?pretty" | awk -F\" '/state/ {print $4}')

# debug
#echo LAST=${LAST}, RESULT=${RESULT}.
#set -x


case ${RESULT} in
        SUCCESS)
                echo "OK: Last backup successful ${LAST}"
                exit 0
                ;;
        PARTIAL*)
                echo "WARNING: Last backup not fully successful but ${RESULT}"
                exit 1
                ;;
        FAILED)
                echo "CRITICAL: Last backup FAILED. Please verify curator session $LAST ${RESULT}"
                exit 2
                ;;
        *)
                echo "UNKNOWN: Last backup not successful. Please verify! Result: $LAST ${RESULT}"
                exit 3
                ;;
esac
