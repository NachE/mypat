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



cat /etc/dnsmasq.conf | grep -v ^# | grep addn-hosts || FOUNDHOSTS="NO"
if [ "$FOUNDHOSTS" == "NO" ];
then
	printf 'NO custom hosts file found on dnsmas conf\n'
	printf 'Using /etc/hosts instead\n'
	DEFAULTHOSTSFILE="/etc/hosts"
else
	printf 'Found a custom hosts file\n'
	DEFAULTHOSTSFILE=`cat /etc/dnsmasq.conf | grep -v ^# | grep addn-hosts | cut -d"=" -f2`
	printf 'Using %s\n' ${DEFAULTHOSTSFILE}
fi



read -p "File where to add host entry [$DEFAULTHOSTSFILE]: " HOSTSFILE
HOSTSFILE=${HOSTSFILE:-$DEFAULTHOSTSFILE}

printf '\n\n  Actual status of %s:\n' $HOSTSFILE
$SUDOCOMMAND cat $HOSTSFILE




printf '\nEnter new IP: '
read -r IP

printf 'Enter a hostname: '
read -r HOSTNAME

echo -e "${IP}\t${HOSTNAME}" | $SUDOCOMMAND tee --append $HOSTSFILE
printf '\n\nFinal status of %s. Printing file:\n' $HOSTSFILE
$SUDOCOMMAND cat $HOSTSFILE

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

