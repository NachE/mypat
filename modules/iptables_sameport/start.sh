#!/bin/bash


echo "Origin port: "
read ORIGPORT

echo "New port: "
read NEWPORT

$SUDOCOMMAND /sbin/iptables -t nat -A PREROUTING -p tcp --dport $NEWPORT -j REDIRECT --to-port $ORIGPORT

if [ $? ];
then
	read -p "Press a key to continue..."
fi
