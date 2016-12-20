#!/bin/bash
# script:       switch_kayako_email.sh
# path:         /usr/local/bin
# purpose:      List and change current Email Parser settings for Kayako (Function in Kayako Admin is called Email Parser > select profile > Test Connection)
# author:       Conclusion Xforce - Jorgen van der Meulen
# Change log:   0.1 - Initial creation
#               0.2 - added parameter

function print_usage () {
    cat <<EOF
Usage: switch_kayako_email.sh -h, --help
       switch_kayako_email.sh
EOF
}

echo -e "\n\n==========[ INFO CURRENT KAYAKO SITUATION ]==========\n"

for CONFIGFILE in  \
/var/www/html/support4/__apps/parser/library/MailParser/class.SWIFT_MailParserIMAP.php \
/var/www/html/support4/__apps/parser/admin/class.Controller_EmailQueue.php
do
        #echo ${CONFIGFILE}
        echo  "Current setting for $(basename ${CONFIGFILE}) is $(awk -F \'  '/DISABLE_AUTHENTICATOR/ {print $(NF-1)}' ${CONFIGFILE})"
done

echo -e "\n\n==========[ CHANGE CURRENT SITUATION MENU ]==========\n"
echo -e "Do you want to change this to
        1) PLAIN
        2) GSSAPI
        3) exit and leave unchanged

Please type a number and press <ENTER>\n"
read ANSWER

case $ANSWER in
        1)
        export TYPE=PLAIN
        ;;
        2)
        export TYPE=GSSAPI
        ;;
        3)
        echo "OK, no changes made" ; exit 0
        ;;
esac


for CONFIGFILE in  \
/var/www/html/support4/__apps/parser/library/MailParser/class.SWIFT_MailParserIMAP.php \
/var/www/html/support4/__apps/parser/admin/class.Controller_EmailQueue.php
do
        sed -i -e "/DISABLE_AUTHENTICATOR/s/PLAIN/GSSAPI/g" -e "/DISABLE_AUTHENTICATOR/s/GSSAPI/$TYPE/g"  ${CONFIGFILE} || echo "FAILED to change ${CONFIGFILE}"
        echo "OK, ${CONFIGFILE} changed to $TYPE"
done
