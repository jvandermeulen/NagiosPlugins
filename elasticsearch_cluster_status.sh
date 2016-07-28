#!/bin/bash
# Script:       elasticsearch_cluster_status.sh
# Purpose:      Check elasticsearch cluster status
# Original author:       unknown
# Altered by    Conclusion Xforce
# Version:      0.1 Jorgen: initial adapted version of check that used abbreviated performance data (so that graphs will not cut off multiple sources)
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
                echo "ADVISE: Please check replication or add more nodes to this ${NUMBEROFDATANODES}-node cluster - Status is $STATUS"
                exit 0
        elif [[ ${NUMBEROFDATANODES} -gt 1 ]] ; then
                echo "WARNING: Please check replication on this ${NUMBEROFDATANODES}-node cluster - Status is $STATUS"
                exit 1
        fi

elif [[ "$STATUS" == "green" ]]; then
echo "OK - Status is $STATUS"
exit 0
fi

echo "UNKNOWN - No data returned by Elasticsearch on host $(hostname). Is the service running?"
exit 3
