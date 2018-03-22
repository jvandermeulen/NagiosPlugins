#!/bin/bash
# Script:       service_active.sh
# Purpose:      The need for a script like this arose soon after Red Hat Enterprise Linux switched from upstart to systemd. 
#               Most of our customers have a Nagios agent called NCPA installed on their CentOS/RHEL servers. 
#               NCPA is perfectly capable of monitoring upstart/sysV services that should be started or should be stopped, however
#               NCPA 1.8.1 is not yet able to handle systemd services (version 2.x is on it's way). This script may loose its reason for existence (for us) when Nagios Enterprises release NCPA (both plugin en Nagios XI wizard) that can handle systemd services.
# Author:       Conclusion Xforce
# Version:      0.1 Jorgen: initial version of check for systemd service (expects one argument)
# Version:      1.0 Jorgen: production ready
# Version:      1.1 Jorgen: result "active" is not enough... second word should be running (not: exited)
# Version:      1.2 Jorgen: prevent abbreviation if the service is not running at all. Example: "failed (Result:". Print complete line skipping the first field using '{$1=""; print $0}'. Typo in word CRITICAL en remove leading spaces in RESULT.
# Version:      1.3 Jorgen: changed author Unacle B.V. to Conclusion Xforce

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
SERVICE=$1

if [ $# -lt 1 ]; then
    echo -e "Missing service argument\nUsage: $0 <service>";
    exit 3;
fi

#RESULT=$(/usr/bin/systemctl is-active ${SERVICE})
#RETCODE=$?
#if [ $RETCODE -eq 0 ]; then

# Result "active" is not enough... output between round brackets should be "running" (not: "exited"). 
# Should Logstash become low on memory it may lead to a "active (excited)" state, an indication to check for memory/java issues.
FULLRESULT=$(systemctl status ${SERVICE} | awk '/ .*Active:/ {$1=""; print $0}'|sed 's/^ *//')
RESULT=$(echo ${FULLRESULT} |awk '{print $1, $2}')
if [ "$RESULT" == "active (running)" ]; then
    echo "OK: Service $1 ${RESULT}"
    exit $STATE_OK;
else
    echo "CRITICAL: Service $1 ${FULLRESULT}"
    exit $STATE_CRITICAL;
fi
