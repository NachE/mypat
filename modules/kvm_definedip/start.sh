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


MACADDR=`virsh -c qemu:///system dumpxml $VMNAME | grep 'mac address' | cut -d"'" -f2`

/usr/sbin/arp -n | grep --color -E "^|$MACADDR"

DEFCURRENTIP="YOUR-CUSTOM-IP-ADDR"
CURRENTIP=`/usr/sbin/arp -n | grep $MACADDR | cut -d" " -f1`
CURRENTIP=${CURRENTIP:-$DEFCURRENTIP}

printf 'Now a editor will be opened\n'
printf 'Put the following line inside <dhcp></dhcp> tags\n\n'
printf "    <host mac='$MACADDR' name='$VMNAME' ip='$CURRENTIP'/>\n\n"
read -p "Press any key to continue..."

virsh -c qemu:///system net-edit $NETNAME

read -p "Press a key to continue..."

