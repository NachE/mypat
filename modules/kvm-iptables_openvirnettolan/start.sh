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

#################################################################################################
# function extracted from 
# http://www.linuxquestions.org/questions/programming-9/bash-cidr-calculator-646701/
function mask2cidr() {
	typeset -A octets=([255]=8 [254]=7 [252]=6 [248]=5 [240]=4 [224]=3 [192]=2 [128]=1 [0]=0)
	while read -rd '.' dec
	do
		(( nbits += ${octets[$dec]} ))
		[[ $dec -lt 255 ]] && break
	done <<<"$1."
	echo "$nbits"
}
#################################################################################################

$SUDOCOMMAND /sbin/iptables -t nat -L -n -v
/sbin/ifconfig

while true
do
	virsh -c qemu:///system net-list
	DEFVAL="default"
	read -p "Please, enter the network name you want to edit [$DEFVAL]: " NETNAME
	NETNAME=${NETNAME:-$DEFVAL}
	virsh -c qemu:///system net-info $NETNAME || NETEXIST="NO"
	if [ "$NETEXIST" == "NO" ];
	then
		printf '******* Sorry, this network (%s)  does not exist *******\n' $NETNAME
	else
		break
	fi
done

DEFIFACE=`virsh -c qemu:///system net-info $NETNAME | grep Bridge | tr -d '[[:space:]]' | cut -d":" -f2`
read -p "Interface used to bridge with guests [$DEFIFACE]: " IFACE
IFACE=${IFACE:-$DEFIFACE}

VIRTIP=`/sbin/ifconfig $IFACE | grep "inet addr" |  tr -t '[[:space:]]' ' ' |cut -d":" -f2|cut -d" " -f1`
VIRTMASK=`/sbin/ifconfig $IFACE | grep "inet addr" |  tr -t '[[:space:]]' ' ' | cut -d":" -f4`
VIRTCIDR=$(mask2cidr $VIRTMASK)

IFS=. read -r i1 i2 i3 i4 <<< $VIRTIP
IFS=. read -r m1 m2 m3 m4 <<< $VIRTMASK
DEFVIRTNETWORK=$(printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" "$((i4 & m4))")
VIRTCIDR=$(mask2cidr $VIRTMASK)

DEFVIRTNETWORK=$DEFVIRTNETWORK/$VIRTCIDR
read -p "Virtual Network Destination [$DEFVIRTNETWORK]: " VIRTNETWORK
VIRTNETWORK=${VIRTNETWORK:-$DEFVIRTNETWORK}

echo "$SUDOCOMMAND /sbin/iptables -I FORWARD -m state -d $VIRTNETWORK --state NEW,RELATED,ESTABLISHED -j ACCEPT"

$SUDOCOMMAND /sbin/iptables -I FORWARD -m state -d $VIRTNETWORK --state NEW,RELATED,ESTABLISHED -j ACCEPT
$SUDOCOMMAND /sbin/iptables -t nat -L -n -v
read -p "Press a key to continue..."

