#!/bin/bash
# Script: 	check_isp.sh
# Purpose:	Display name of current ISP (according to whois)
# Version:	0.2
# Author: 	Conclusion Xforce - Jorgen van der Meulen
# 
WHOIS_URL="https://www.whoismyisp.org"

# Check availability

HTTP_CODE=$(curl -sL --connect-timeout 20 -w "%{http_code}\\n" ${WHOIS_URL} -o /dev/null)
case ${HTTP_CODE} in
  [2]*)
    printf "Info: ISP is "
    ;;
  [3]*)
    printf "Redirect from ${WHOIS_URL}. ISP is "
    ;;
  [4]*)
    echo "CRITICAL: Access is DENIED to ${WHOIS_URL}"
    exit 2
    ;;
  [5]*)
    echo "CRITICAL: ERROR connecting to ${WHOIS_URL}"
    exit 2
    ;;
  *)
    echo "CRITICAL: NO RESPONSE from ${WHOIS_URL}"
    exit 2
    ;;
  esac

curl -s ${WHOIS_URL} | awk -F "'"  '/Your Internet Service Provider/ {getline; print $2};'
