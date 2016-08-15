#!/bin/bash

# Script:       check_last_nls_backup.sh
# Purpose:      Check most recent Elasticsearch/Nagios Log Server Backup - tested with curator 3.40
# Author:       Jorgen van der Meulen (Conclusion Xforce)
# Version:      0.1 initial creation
#               0.2 changed  default --time-unit from 1 days to 25 hours, it appeared that a backup made yesterday evening (23:30) did not match filter "--newer-than 1 --time-unit days",  I assumed a last 24 hours filter. No matches
#               0.3 add multiline output to PARTIAL or FAILED backups: reason for failure
#               0.5 it appears that NRDS Version: 1.5.4 Date: 05/06/2016  cannot handle multiline output, so make it configurable
#               0.6 added readable date using "date -d <curatordate>, changed --newer-than and --time-unit parameters to variables to improve UNKOWN result with regards to timeframe
#               0.7 added help and version info
#               0.8 oops.. name of backup repository was hardcoded in this script, made it configurable using variable MYREPO
#               0.9 handle IN_PROGRESS state as UNKNOWN
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

# MYREPO: name of repository that should be checked using curator
MYREPO="SharedBackupRepo"

# debug
#set -x
# End customizations
#==================================================

function print_version () {
    cat <<EOF
check_last_nls_backup.sh - 0.9 - Copyright Conclusion Xforce
This Nagios plugin comes with no warranty. You can use and distribute it
under terms of the GNU General Public License Version 2 (GPL V2) or later.
EOF
}

function print_help () {
echo -e "\nCheck most recent Elasticsearch/Nagios Log Server Backup - tested with curator 3.40\nNo arguments required (variables for customization can be found in script\n
Usage: check_last_nls_backup.sh -h, --help
       check_last_nls_backup.sh -V, --version"
}

function get_reason_for_failure () {
REASON=$(curl -s -XGET "localhost:9200/_snapshot/${MYREPO}/${LAST}?pretty" | awk -F \" '/reason/ {print $4}')
}

function main () {
LAST=$(curator --loglevel warn show snapshots --repository "${MYREPO}" --newer-than ${MOSTRECENT_TIME_FILTER} --time-unit ${MOSTRECENT_TIME_UOM} |tail -1)
RESULT=$(curl -s -XGET "localhost:9200/_snapshot/${MYREPO}/${LAST}?pretty" | awk -F\" '/state/ {print $4}')

D=$(echo ${LAST} | awk -F\- '{print $2}' 2>/dev/null)
[[ -n $D ]] || { echo "UNKNOWN: Unable to determine result within last ${MOSTRECENT_TIME_FILTER} ${MOSTRECENT_TIME_UOM}: $LAST ${RESULT}" ; exit 3; }
PRETTY_TIMESTAMP=$(date -d "$(echo ${D:0:8} ${D:(-6):2}:${D:(-4):2}:${D:(-2):2})${CURATOR_TIME_CORRECTION}")


case ${RESULT} in
        SUCCESS)
                echo "OK: Last backup successful [${LAST} on ${PRETTY_TIMESTAMP}]"
                exit 0
                ;;
        PARTIAL*)
                get_reason_for_failure
                echo -e "WARNING: Last backup not fully successful but ${RESULT}. ${MULTILINE}${REASON}"
                exit 1
                ;;
        FAILED)
                get_reason_for_failure
                echo -e "CRITICAL: Last backup FAILED. Please verify curator session ${LAST} ${RESULT}. ${MULTILINE}${REASON}"
                exit 2
                ;;
        IN_PROGRESS)
                echo "UNKNOWN: Active session detected. ${LAST} is currently in progress. Please try again in a few minutes."
                exit 3
                ;;
        *)
                echo "UNKNOWN: Unable to determine result within last ${MOSTRECENT_TIME_FILTER} ${MOSTRECENT_TIME_UOM}: ${LAST} ${RESULT}"
                exit 3
                ;;
esac
}


# No command line arguments required, but we want to stick to some default plugin development guidelines
case "$1" in
        --help|-h)
            print_help
            exit $STATE_OK
        ;;
        --version|-V)
            print_version
            exit $STATE_OK
        ;;
        *)
            main
        ;;
esac
