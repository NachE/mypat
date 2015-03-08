#!/bin/bash

ORIG=$(cd $(dirname "$0")/; pwd)
. $ORIG/../../config/config.sh

/sbin/ifconfig

printf 'Public IP: '
read -r PUBLICIP

printf 'Public PORT: '
read -r PUBLICPORT

printf 'Private IP: '
read -r PRIVATEIP

printf 'Private PORT: '
read -r PRIVATEPORT

$SUDOCOMMAND /sbin/iptables -t nat -I PREROUTING -p tcp -d $PUBLICIP --dport $PUBLICPORT -j DNAT --to-destination $PRIVATEIP:$PRIVATEPORT
$SUDOCOMMAND /sbin/iptables -I FORWARD -m state -d $PRIVATEIP --state NEW,RELATED,ESTABLISHED -j ACCEPT

if [ $? ];
then
	echo "Error?"
	echo "Command used:  $SUDOCOMMAND /sbin/iptables -t nat -A PREROUTING -p tcp --dport $NEWPORT -j REDIRECT --to-port $ORIGPORT"
	echo "Listing iptables rules: "
	$SUDOCOMMAND iptables -t nat -L -n -v
	read -p "Press a key to continue..."
fi
