#!/bin/bash

# check_last_nls_backup.sh
# version 0.1
LAST=$(curator --loglevel warn show snapshots --repository "SharedBackupRepo" --newer-than 1 --time-unit days |tail -1)
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
                echo "UNKNOWN: Last backup not successful. Please verify curator session $LAST ${RESULT}"
                exit 3
                ;;
esac
