#!/bin/bash
# Script: check_nna_flow_devices.sh
# Purpose: 	Check number of running NetFlow or sFlow devices on Nagios Network Analyzer server compared 
# 		to the configured devices
# Author: Jorgen van der Meulen (Conclusion Xforce)
# Version: see print_version function
# Change log: 	0.1 - Initial creation
#		0.2 - added type parameter
#		0.3 - changed calculation of warning/critical thresholds (X-1 = warning, X-2 = critical)
# Requirements: Admin -> System Config \ System Settings -> Allow HTML Tags in Host/Service Status (checked)
# Installation: This script should be placed on a Nagios Network Analyzer server, made executable and configured in NRPE. 
# 				Nagios client NCPA needs no configuration, just put it underneath directory /usr/local/ncpa/plugin/ 


#declare states
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

function print_version () {
    cat <<EOF
check_flow_devices 0.3 - Copyright Conclusion Xforce

This Nagios plugin comes with no warranty. You can use and distribute it 
under terms of the GNU General Public License Version 2 (GPL V2) or later. 
EOF
}


function print_usage () {
    cat <<EOF
Usage: check_flow_devices -h, --help
       check_flow_devices -V, --version
       check_flow_devices --type NetFlow|sFlow  	WARNING: case sensitive!!
EOF
}

function print_help () {
echo -e "\nPlugin for monitoring flow capture daemon on a Nagios Network Analyzer\n"
print_usage
}

function main_program () {
#echo entering main program

[[ -n $2 ]] && flow_type=$2
#Set default flow_type to NetFlow if nothing specified
flow_type=${flow_type:-NetFlow}
case $flow_type in
  NetFlow)
	PATTERN=nfcapd
	;;
  sFlow)
	PATTERN=sfcapd
	;;
       *)
	echo -e "CRITICAL: you did not supply a valid flowtype. Please remember options are case sensitive!\n\n" ; print_usage ; exit ${STATE_UNKNOWN}
	;;
esac
        
# collect number of NetFlow/sFlow sources configured

FLOW_SOURCES=$(mysql -sN -u nagiosna --password=nagiosna -e "use nagiosna; select count(*) from nagiosna_Sources where flowtype = '${flow_type,,}';")
FLOW_PROCESSES=$(ps -e |grep ${PATTERN} | wc -l)
FLOW_PROCESSES_DIVIDEDBYTWO=$(expr ${FLOW_PROCESSES} / 2)

WARN=$(expr ${FLOW_SOURCES} - 1 )
CRIT=$(expr ${FLOW_SOURCES} - 2 )

if [ "$FLOW_PROCESSES_DIVIDEDBYTWO" -gt "$WARN" ]; then
        NAGSTAT=$STATE_OK
        NAGRES="OK"
fi
if [ "$FLOW_PROCESSES_DIVIDEDBYTWO" -le "$WARN" ]; then
        NAGSTAT=$STATE_WARNING
        NAGRES="WARNING"
        if [ "$FLOW_PROCESSES_DIVIDEDBYTWO" -le "$CRIT" ];then
                NAGSTAT=$STATE_CRITICAL
                NAGRES="CRITICAL"
        fi
	# since we're in a NON-OK state: provide some additional help
	REMEDIATE_HINT="Check your <a href="http://$(hostname)/nagiosna/index.php/sources">NNA Sources Page</a> and look for stopped devices"
fi

echo "${NAGRES}: ${FLOW_PROCESSES_DIVIDEDBYTWO} active ${flow_type} devices [total configured ${flow_type} devices: ${FLOW_SOURCES}] |${flow_type}DevsActive=$FLOW_PROCESSES_DIVIDEDBYTWO;$WARN;$CRIT;;"
echo "Additional info: found a number of ${FLOW_PROCESSES} process(es) on $(hostname) with pattern <b>${PATTERN}</b>, each configured device has two processes. ${REMEDIATE_HINT}"
exit $NAGSTAT
}

# 
case "$1" in
        --help|-h)
            print_help
            exit $STATE_OK
        ;;
        --version|-V)
            print_version
            exit $STATE_OK
        ;;
        --type|-t)
            if [ "$#" != 2 ] ; then
                print_usage
                exit $STATE_UNKNOWN
            fi
	    main_program $1 $2
        ;;
        *)
            print_usage
            exit $STATE_UNKNOWN
        ;;
esac
