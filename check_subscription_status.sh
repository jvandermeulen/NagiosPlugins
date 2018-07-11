#!/bin/bash
# Script:       check_subscription_status.sh
# Purpose:      Check RHEL subscription status
# Author:       Conclusion Xforce
# Version:      0.1 Jorgen: initial version of check
#               0.2 Jorgen: run sudo with "-A" option to make sure a failure is returned instead of infinite waiting for user password when sudoers is not edited              
#               sudo: no askpass program specified, try setting SUDO_ASKPASS
#               0.3 Jorgen: added ${CMD_FULL} var. Full path the subscription-manager binary under /usr/bin/ keeps returning old info (caching?)
#               0.4 Jorgen: suggested to create a seperate file in /etc/sudoers.d/ as Nagios XI upgrade might wipe your own sudo lines
# Requirements:
#               binary files:   subscription-manager, xargs, awk
#               config files:   /etc/os-release
#               authorization:  this script probably runs as nagios-user, subscription-manager needs root privileges that can be adressed by sudo, please add NOPASSWD option using 'visudo' or even better by adding  the line below to a dedicated file in /etc/sudoers.d/
#               NAGIOSXI ALL = NOPASSWD:/usr/bin/subscription-manager *,/usr/sbin/subscription-manager *
#
#               Updating from Nagios XI 5.4.13 to 5.5.0 wiped my/etc/sudoers entries, so be warned and use a seperate file.
#
STATE_OK=0
STATE_WARN=1
MSG_WARN=WARNING
STATE_CRIT=2
MSG_CRIT=CRITICAL
CMD=subscription-manager
CMD_FULL=/usr/sbin/subscription-manager
CMD_PROXY_OPTS=""
#CMD_PROXY_OPTS="--proxy=http://myproxy:8080"

#set -x
set -o pipefail
#

#Check if subscription-manager is installed (on CentOS and OEL it's NOT)
type ${CMD} >/dev/null 2>&1 || { echo >&2 "UNKNOWN: no ${CMD} binary found on $(awk -F \= 'NR == 1 {print $2}' /etc/os-release)."; exit 3; }
#Check xargs
type xargs >/dev/null 2>&1 || { echo >&2 "UNKNOWN: no xargs binary found. Please install findutils package."; exit 3; }

STATUS_MSG_SHORT=$(sudo -A ${CMD_FULL} status ${CMD_PROXY_OPTS}| sed  -ne '/Overall Status:/p' -ne '/^-/p' | xargs)
STATUSCODE=$(echo $?)

#echo ${STATUSCODE}
#echo ${STATUS_MSG_SHORT}

if [[ ${STATUSCODE} -ne 0 ]] ; then
        echo "${MSG_WARN}: Please check your Red Hat Subscription! ${STATUS_MSG_SHORT}"
        exit $STATE_WARN
fi
echo "OK: Red Hat Subscription ${STATUS_MSG_SHORT}"
exit 0
