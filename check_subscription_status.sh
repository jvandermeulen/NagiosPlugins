#!/bin/bash
# Script:       check_subscription_status.sh
# Purpose:      Check RHEL subscription status
# Author:       Conclusion Xforce
# Version:      0.1 Jorgen: initial version of check

# Requirements:
#               binary files:   subscription-manager, xargs, awk
#               config files:   /etc/os-release
#               authorization:  this script runs as nagios-user, subscription-manager needs sudo rights, please add NOPASSWD line using 'visudo'
#               NAGIOSXI ALL = NOPASSWD:/usr/bin/subscription-manager *,/usr/sbin/subscription-manager *
#
STATE_OK=0
STATE_WARN=1
MSG_WARN=WARNING
STATE_CRIT=2
MSG_CRIT=CRITICAL
CMD=subscription-manager
CMD_PROXY_OPTS=""
#CMD_PROXY_OPTS="--proxy=http://myproxy:8080"

#set -x
set -o pipefail

#


#Check if subscription-manager is installed (on CentOS and OEL it's NOT)
type ${CMD} >/dev/null 2>&1 || { echo >&2 "UNKNOWN: no ${CMD} binary found on $(awk -F \= 'NR == 1 {print $2}' /etc/os-release)."; exit 3; }
#Check xargs
type xargs >/dev/null 2>&1 || { echo >&2 "UNKNOWN: no xargs binary found. Please install findutils package."; exit 3; }

STATUS_MSG_SHORT=$(sudo ${CMD} status ${CMD_PROXY_OPTS}| sed  -ne '/Overall Status:/p' -ne '/^-/p' | xargs)
STATUSCODE=$(echo $?)

#echo ${STATUSCODE}
#echo ${STATUS_MSG_SHORT}

if [[ ${STATUSCODE} -ne 0 ]] ; then
        echo "${MSG_WARN}: Please check your Red Hat Subscription! ${STATUS_MSG_SHORT}"
        exit $STATE_WARN
fi
echo "OK: Red Hat Subscription ${STATUS_MSG_SHORT}"
exit 0
