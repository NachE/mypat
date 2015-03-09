#!/bin/bash

ORIG=$(cd $(dirname "$0")/; pwd)
. $ORIG/../../config/config.sh

while true
do
	virsh -c qemu:///system list --all
	printf '\nPlease, enter the EXACT NAME of VM you want to edit: '
	read -r VMNAME
	virsh -c qemu:///system dumpxml $VMNAME || VMEXIST="NO"
	if [ "$VMEXIST" == "NO" ];
	then
		printf '******* Sorry, this VM does not exist *******\n'
	else
		break
	fi
done

while true
do
	virsh -c qemu:///system net-list
	DEFVAL="default"
	read -p "Please, enter the network name you want to edit [$DEFVAL]: " NETNAME
	NETNAME=${NETNAME:-$DEFVAL}
	virsh -c qemu:///system net-info $NETNAME || NETEXIST="NO"
	if [ "$NETEXIST" == "NO" ];
	then
		printf '******* Sorry, this network (${NETNAME})  does not exist *******\n'
	else
		break
	fi
done

MACADDR=`virsh -c qemu:///system dumpxml  Windows7 | grep 'mac address' | cut -d"'" -f2`

printf 'Now a editor will be opened\n'
printf 'Put the following line inside <dhcp></dhcp> tags\n\n'
printf "    <host mac='$MACADDR' name='$VMNAME' ip='YOUR-IP-ADDR'/>\n\n"
read -p "Press any key to continue..."

virsh -c qemu:///system net-edit $NETNAME

read -p "Press a key to continue..."

