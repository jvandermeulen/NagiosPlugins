#!/bin/bash
##########################################################
# Script 	: check_experiment2.sh
# Purpose	: Test how Nagios XI (Highcharts) handles Performance Output in Graphs and Gauge dashlet
#		  Status Output is not important, it's all about Performance Output
#
# Known bugs	: Minute 08 or 09 cause a failure	 ./check_experiment1.sh: line 23: [[: 08: value too great for base (error token is "08")
#Define variables 
PROGNAME=$(basename $0)
RELEASE="ver.0.1"
# 
var=$(date "+%M")
MINUTE=$(echo $var)
#
WARN_RANGE="20:"
WARN=20
CRIT_RANGE="48:"
CRIT=48
# Toggle threshold integer or range, see https://nagios-plugins.org/doc/guidelines.html#THRESHOLDFORMAT
#PERFDATA="|'Minute'=${MINUTE}m;${WARN_RANGE};${CRIT_RANGE};0;60"
PERFDATA="|'Minute'=${MINUTE}m;${WARN};${CRIT};0;60"
#exit 0

if [[ $MINUTE -gt $CRIT ]]; then
    echo "CRITICAL $PROGNAME - Current Minute: $MINUTE $PERFDATA"
    exit 2
elif [[ $MINUTE -gt $WARN ]]; then
    echo "WARNING $PROGNAME - Current Minute: $MINUTE $PERFDATA"
    exit 1
elif [[ $MINUTE -lt $WARN ]]; then
    echo "OK $PROGNAME - Current Minute: $MINUTE $PERFDATA"
    exit 0
else
    echo "UNKNOWN: The check failed for unknown reason."
    exit 3
fi
#
