#!/bin/bash
#
# Script:       aide_summary_to_syslog.bash
# Purpose:      Do regular aide check for security reasons. Write summary to (remote) syslog so a central log analyzer will alert you
# How to run:   Scheduled from crontab
# How to analyze: Please give Nagios Log Server a try (https://www.nagios.com/products/nagios-log-server/#benefits)
# Author:       Jorgen van der Meulen (Conclusion Xforce)
# 
# Version:      0.1  2015-01-20 initial creation

#==================================================
# Customize this:
THISHOST=$(hostname)
ENTRY="for ${THISHOST}. Please consult /var/log/aide/aide.log"
LOGGER_TAG=linuxaudit
# Note 1: Change syslog priorities in this script to match your needs
# Note 2: Change aide.conf to match your needs
# End customizations

/usr/bin/nice -n 19 /usr/sbin/aide --check >/dev/null 2>&1
RETVAL=$?
case $RETVAL in
        0) logger -t ${LOGGER_TAG} -p authpriv.notice "$0 found no differences ${ENTRY}";;
        1) logger -t ${LOGGER_TAG} -p authpriv.warn "$0 found NEW files ${ENTRY}";;
        2) logger -t ${LOGGER_TAG} -p authpriv.warn "$0 found REMOVED files ${ENTRY}";;
        3) logger -t ${LOGGER_TAG} -p authpriv.warn "$0 found both NEW and REMOVED files ${ENTRY}";;
        4) logger -t ${LOGGER_TAG} -p authpriv.warn "$0 found CHANGED files ${ENTRY}";;
        5) logger -t ${LOGGER_TAG} -p authpriv.warn "$0 found both NEW and CHANGED files ${ENTRY}";;
        6) logger -t ${LOGGER_TAG} -p authpriv.warn "$0 found both REMOVED and CHANGED files ${ENTRY}";;
        7) logger -t ${LOGGER_TAG} -p authpriv.warn "$0 found NEW, REMOVED and CHANGED files ${ENTRY}";;
        19) logger -t ${LOGGER_TAG} -p authpriv.crit "$0 error 19: Version mismatch error ${ENTRY}";;
        *) logger -t ${LOGGER_TAG} -p authpriv.crit "$0 other error ${RETVAL} ${ENTRY}";;
esac
