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
##############################################################################

ORIG=$(cd $(dirname "$0")/; pwd)
. $ORIG/../../config/config.sh

DEFAULTHOSTSFILE="/etc/mypathosts/hphosts"
read -p "Put file on (will be overwrited) [$DEFAULTHOSTSFILE]: " HOSTSFILE
HOSTSFILE=${HOSTSFILE:-$DEFAULTHOSTSFILE}

DEFAULTFAKEIP="127.0.0.1"
read -p "Fake ip [$DEFAULTFAKEIP]: " FAKEIP
FAKEIP=${FAKEIP:-$DEFAULFAKEIP}

TIMESTAMP=`date +%s`

mkdir -p /tmp/mypats$TIMESTAMP

wget http://hosts-file.net/download/hosts.zip -O /tmp/mypats$TIMESTAMP/hosts.zip
cd /tmp/mypats$TIMESTAMP/
unzip hosts.zip

sudo mkdir -p $(dirname "$HOSTSFILE")
cat hosts.txt | grep -v "localhost #IPv4" | sed "s/127\.0\.0\.1/$FAKEIP/g" > hosts_mypat
sudo cp hosts_mypat $HOSTSFILE 


printf '\n\nRemeber to add %s to your dnsmasq configuration\n' $HOSTSFILE
printf 'You can add a file (addn-hosts=%s)\n' $HOSTSFILE
HOSTSDIR=$(dirname "$HOSTSFILE")
printf 'Or a directory (addn-hosts=%s)\n' $HOSTSDIR
printf 'Warning: All files on %s will be readed.\n' $HOSTSDIR
printf 'The option addn-hosts may be repeated for more than\n'
printf 'one additional hosts file.\n\n'

printf 'Listing addn-hosts on your dnsmasq configuration\n'
printf 'grep addn-hosts /etc/dnsmasq.conf:\n'
grep addn-hosts /etc/dnsmasq.conf

while true
do
	DEFAULTRELOAD="Y"
	read -p "Restart dnsmasq service? Y/N [$DEFAULTRELOAD]: " RELOAD
	RELOAD=${RELOAD:-$DEFAULTRELOAD}
	if [ "$RELOAD" == "Y" ];
	then
		$SUDOCOMMAND service dnsmasq restart
	elif [ "$RELOAD" == "N" ];
	then
		break
	fi
done


read -p "Press a key to continue..."

