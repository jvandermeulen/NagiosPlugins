#!/bin/bash
# Check if CentOS/RHEL server needs reboot
# requirements: yum-utils package
#               el7
# version 0.2
set -o pipefail
/usr/bin/needs-restarting -r > /dev/null 2>&1
RESULT=$?
if [[ ${RESULT} -eq 1 ]]; then
        echo "WARNING: Reboot is required. Updated libraries or kernel detected"
        exit 1
elif [[ ${RESULT} -eq 0 ]]; then
        echo "OK: No system reboot required"
        exit 0
else
        echo "UNKNOWN: $0 failed (is yum-utils installed?)"
        exit 3
fi
