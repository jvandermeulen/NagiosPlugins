#!/bin/bash

# Script:       check_last_nls_backup.sh
# Purpose:      Check most recent Elasticsearch/Nagios Log Server Backup - tested with curator 3.40
# Version:      0.1 initial creation
#               0.2 changed  default --time-unit from 1 days to 25 hours, it appeared that a backup made yesterday evening (23:30) did not match filter "--newer-than 1 --time-unit days",  I assumed a last 24 hours filter. No matches
#               0.3 add multiline output to PARTIAL or FAILED backups: reason for failure
#               0.5 it appears that NRDS Version: 1.5.4 Date: 05/06/2016  cannot handle multiline output, so make it configurable
#               0.6 added readable date using "date -d <curatordate>, changed --newer-than and --time-unit parameters to variables to improve UNKOWN result with regards to timeframe

#==================================================
# Customize this:

# Please change thesholds for most recent curator snapshots that are taken into account here. Please specify UOM (Unit of measurement) on lowercase
MOSTRECENT_TIME_FILTER=25
MOSTRECENT_TIME_UOM=hours

# MULTILINE: make it eiter an empty variable or "\n"
#MULTILINE="\n"
MULTILINE=""

# CURATOR_TIME_CORRECTION
CURATOR_TIME_CORRECTION=" +0000"

# debug
#set -x
# End customizations
#==================================================

LAST=$(curator --loglevel warn show snapshots --repository "SharedBackupRepo" --newer-than ${MOSTRECENT_TIME_FILTER} --time-unit ${MOSTRECENT_TIME_UOM} |tail -1)
RESULT=$(curl -s -XGET "localhost:9200/_snapshot/SharedBackupRepo/${LAST}?pretty" | awk -F\" '/state/ {print $4}')

D=$(echo ${LAST} | awk -F\- '{print $2}')
PRETTY_TIMESTAMP=$(date -d "$(echo ${D:0:8} ${D:(-6):2}:${D:(-4):2}:${D:(-2):2})${CURATOR_TIME_CORRECTION}")


case ${RESULT} in
        SUCCESS)
                echo "OK: Last backup successful [${LAST} on ${PRETTY_TIMESTAMP}]"
                exit 0
                ;;
        PARTIAL*)
                REASON=$(curl -s -XGET "localhost:9200/_snapshot/SharedBackupRepo/${LAST}?pretty" | awk -F \" '/reason/ {print $4}')
                echo -e "WARNING: Last backup not fully successful but ${RESULT}. ${MULTILINE}${REASON}"
                exit 1
                ;;
        FAILED)
                REASON=$(curl -s -XGET "localhost:9200/_snapshot/SharedBackupRepo/${LAST}?pretty" | awk -F \" '/reason/ {print $4}')
                echo -e "CRITICAL: Last backup FAILED. Please verify curator session $LAST ${RESULT}. ${MULTILINE}${REASON}"
                exit 2
                ;;
        *)
                echo "UNKNOWN: Unable to determine result within ${MOSTRECENT_TIME_FILTER} ${MOSTRECENT_TIME_UOM}: $LAST ${RESULT}"
                exit 3
                ;;
esac
