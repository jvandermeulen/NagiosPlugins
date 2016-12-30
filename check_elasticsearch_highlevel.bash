#!/bin/bash
# Script:       check_elasticsearch_highlevel
# Purpose:      Check elasticsearch cluster status (highlevel)
# Author:       Conclusion Xforce
# Version:      0.1 Jorgen: initial version of check
# Version:      1.0 Jorgen: production ready

type curl >/dev/null 2>&1 || { echo >&2 "Please install curl package."; exit 3; }

STATUS=`/usr/bin/curl -s localhost:9200/_cluster/health?pretty|awk '/status/ {print $3}'|cut -d\" -f2`
NUMBEROFDATANODES=`/usr/bin/curl -s localhost:9200/_cluster/health?pretty|awk '/number_of_data_nodes/ {print $3}' | tr -d ,`

#if [[ ${NUMBEROFDATANODES} = *[[:digit:]]* ]]; then
# echo "${NUMBEROFDATANODES} is numeric"
#else
# echo "${NUMBEROFDATANODES} is not numeric"
#fi

if [[ $STATUS && "$STATUS" == "red" ]]; then
echo "CRITICAL - Status is $STATUS"
exit 2
elif [[ $STATUS && "$STATUS" == "yellow" ]] ; then
        WARN=1
        if [[ ${NUMBEROFDATANODES} -lt 2 ]] ; then
                echo "ADVISE: Please check replication or add more nodes to this ${NUMBEROFDATANODES}-node cluster - Status is $STATUS [Cluster IP running on $(hostname -s)]"
                exit 0
        elif [[ ${NUMBEROFDATANODES} -gt 1 ]] ; then
                echo "WARNING: Please check replication on this ${NUMBEROFDATANODES}-node cluster - Status is $STATUS [Cluster IP running on $(hostname -s)]"
                exit 1
        fi

elif [[ "$STATUS" == "green" ]]; then
echo "OK - Status is $STATUS [Cluster IP running on $(hostname -s)]"
exit 0
fi

echo "UNKNOWN - No data returned by Elasticsearch on host $(hostname). Is the service running?"
exit 3
