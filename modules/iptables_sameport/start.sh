#!/bin/bash

ORIG=$(cd $(dirname "$0")/; pwd)
. $ORIG/../../config/config.sh

printf 'Original port: '
read -r ORIGPORT

printf 'New port: '
read -r NEWPORT

$SUDOCOMMAND /sbin/iptables -t nat -A PREROUTING -p tcp --dport $NEWPORT -j REDIRECT --to-port $ORIGPORT

if [ $? ];
then
	echo "Error?"
	echo "Command used:  $SUDOCOMMAND /sbin/iptables -t nat -A PREROUTING -p tcp --dport $NEWPORT -j REDIRECT --to-port $ORIGPORT"
	echo "Listing iptables rules: "
	$SUDOCOMMAND iptables -t nat -L -n -v
	read -p "Press a key to continue..."
fi
