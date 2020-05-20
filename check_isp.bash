#!/bin/bash
# Script:       check_isp.sh
# Purpose:      Display name of current ISP (according to whois)
# Version:      0.3     whois changed "Your Internet Service Provider" to "Your ISP".
#                       example output: 
#                       Info: ISP is Xs4all Internet BV
# Version:      0.4     added 2nd line holding 'aka' information
#                       example output: 
#                       Info: ISP is Xs4all Internet BV also known as 'XS4ALL Networking'
# Author:       Conclusion Xforce - Jorgen van der Meulen
#
WHOIS_URL="https://www.whoismyisp.org"

# Check required binaries
type curl >/dev/null 2>&1 || { echo >&2 "Please install curl package."; exit 3; }

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
  
# Continue displaying ISP info as long as http_code status starts with 2xx
#curl -s ${WHOIS_URL} | awk '/Your ISP is/ {getline; print $0}' | sed -e 's/<[^>]*>//g'  -e 's/^[ \t]*//'
curl -s ${WHOIS_URL} | awk '/Your ISP is/ {getline; printf $0; getline; print $0}' | sed -e 's/<[^>]*>//g'  -e 's/^[ \t]*//' | tr -s ' '
