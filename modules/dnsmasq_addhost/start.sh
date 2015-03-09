#!/bin/bash

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

