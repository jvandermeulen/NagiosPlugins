#!/bin/bash
# Check if CentOS/RHEL server needs reboot
# requirements: yum-utils package
#               el7
# version 0.3
set -o pipefail
/usr/bin/needs-restarting -r > /dev/null 2>&1
RESULT=$?
if [[ ${RESULT} -eq 1 ]]; then
        echo -e "WARNING: Reboot is required. Updated libraries, service or kernel detected\nSee Red Hat article https://access.redhat.com/solutions/27943"
        exit 1
elif [[ ${RESULT} -eq 0 ]]; then
        echo "OK: No system reboot required"
        exit 0
else
        echo "UNKNOWN: $0 failed (is yum-utils installed?)"
        exit 3
fi
