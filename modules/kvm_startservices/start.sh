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


printf 'Starting libvirtd...\n'
$SUDOCOMMAND service libvirtd start
printf 'Starting libvirt-guests...\n'
$SUDOCOMMAND service libvirt-guests start

while true
do
        virsh -c qemu:///system net-list --all
        DEFVAL="default"
        read -p "Please, enter the network name you want to start [$DEFVAL]: " NETNAME
        NETNAME=${NETNAME:-$DEFVAL}
        virsh -c qemu:///system net-info $NETNAME || NETEXIST="NO"
        if [ "$NETEXIST" == "NO" ];
        then
                printf '******* Sorry, this network (%s)  does not exist *******\n' $NETNAME
        else
                break
        fi
done

virsh -c qemu:///system net-start $NETNAME

DEFVAL=""
while true
do
        virsh -c qemu:///system list --all
        read -p "Domain you want to start?  [$DEFVAL]: " DOMAINNAME
        DOMAINNAME=${DOMAINNAME:-$DEFVAL}
	DEFVAL=$DOMAINNAME
        virsh -c qemu:///system dominfo $DOMAINNAME || DOMEXIST="NO"
        if [ "$DOMEXIST" == "NO" ];
        then
                printf '******* Sorry, this domain (%s) does not exist *******\n' $DOMAINNAME
	else
		printf 'Starting domain...\n'
		virsh -c qemu:///system start $DOMAINNAME
                virsh -c qemu:///system list --all
        fi

	DEFEXIT="Y"
	read -p "Exit? Y/N [$DEFEXIT]: " EXIT
	EXIT=${EXIT:-$DEFEXIT}
	if [ "$EXIT" == "Y" ];
	then
		break
	fi
done

read -p "Press a key to continue..."

