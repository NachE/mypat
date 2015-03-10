#!/bin/bash
##############################################################################
#
#    MyPATS - My Personal Admin System Tools
#    Copyright (C) 2015 Juan Antonio Nache <ja@nache.net>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
############################################################################

ORIG=$(cd $(dirname "$0")/; pwd)
. $ORIG/../../config/config.sh


while true
do
	DEFVAL=$SITENAME
	read -p "Name of this site [$DEFVAL]: " SITENAME
	SITENAME=${SITENAME:-$DEFVAL}

	if [ -e "/etc/nginx/sites-available/mypats-$SITENAME.vhost" ];
	then
		printf 'Sorry, "/etc/nginx/sites-available/mypats-$SITENAME.vhost" exists\n'
	else
		$SUDOCOMMAND touch /etc/nginx/sites-available/mypats-$SITENAME.vhost
		if [ -e "/etc/nginx/sites-available/mypats-$SITENAME.vhost" ];
		then
			break
		else
			printf 'ERROR: I cannot create "/etc/nginx/sites-available/mypats-$SITENAME.vhost" file\n'
		fi
	fi
done



DEFVAL=1234
read -p "Port to listen [$DEFVAL]: " LISTENPORT
LISTENPORT=${LISTENPORT:-$DEFVAL}

printf '\nNote: If you experiment 404 errors,\n'
printf 'try to use IP instead HOST on this parameter.\n'
printf 'Remember that you will set a proxy_set_header Host\n'
printf "parameter with this tool, so you don't need to set\n"
printf 'hostname here. This is specially problematic if you\n'
printf 'use a differente hostname here and with proxy_set_header Host.\n'
printf 'If you are thinking to use "localhost" here, maybe\n'
printf 'its better option to use "127.0.0.1" or a public/lan ip\n'

DEFVAL="127.0.0.1"
read -p "Destination IP or HOST (without http://): [$DEFVAL]: " DESTIP
DESTIP=${DESTIP:-$DEFVAL}

DEFVAL="80"
read -p "Destination port: [$DEFVAL]: " DESTPORT
DESTPORT=${DESTPORT:-$DEFVAL}

printf '\nNote: Use domain without http:// and without www.\n'
DEFVAL="fakehost.com"
read -p "Custom/Fake 'Host' request header to send [$DEFVAL]: " FAKEHOST
FAKEHOST=${FAKEHOST:-$DEFVAL}

echo -e "server {\n\
\tlisten $LISTENPORT;\n\
\tserver_name _;\n
\troot   /dev/null;\n\
\tlocation / {\n\
\t\tproxy_set_header Host      $FAKEHOST;\n\
\t\tproxy_pass       http://$DESTIP:$DESTPORT/;\n\
\t\tproxy_redirect http://$FAKEHOST/ /;\n\
\t\tproxy_redirect http://www.$FAKEHOST/ /;\n\
\t\tproxy_set_header X-Real-IP \$remote_addr;\n\
\t}\n\
}" | $SUDOCOMMAND tee /etc/nginx/sites-available/mypats-$SITENAME.vhost

$SUDOCOMMAND ln -s /etc/nginx/sites-available/mypats-$SITENAME.vhost /etc/nginx/sites-enabled/100-mypats-$SITENAME.vhost

printf 'Done, showing file:\n\n'
$SUDOCOMMAND cat /etc/nginx/sites-enabled/100-mypats-$SITENAME.vhost


while true
do
        DEFAULTRELOAD="Y"
        read -p "Reload nginx service? Y/N [$DEFAULTRELOAD]: " RELOAD
        RELOAD=${RELOAD:-$DEFAULTRELOAD}
        if [ "$RELOAD" == "Y" ];
        then
		printf 'Reloading...\n'
                $SUDOCOMMAND service nginx reload
		printf 'Done\n'
        elif [ "$RELOAD" == "N" ];
        then
                break
        fi
done

read -p "Press a key to continue..."


