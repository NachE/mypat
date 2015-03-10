#!/bin/bash
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
if [ $? ];
then
	echo "Error?"
fi
echo "Command used: $SUDOCOMMAND /sbin/iptables -t nat -I PREROUTING -p tcp -d $PUBLICIP --dport $PUBLICPORT -j DNAT --to-destination $PRIVATEIP:$PRIVATEPORT"

$SUDOCOMMAND /sbin/iptables -I FORWARD -m state -d $PRIVATEIP --state NEW,RELATED,ESTABLISHED -j ACCEPT
if [ $? ];
then
	echo "Error?"
fi
echo "Command used: $SUDOCOMMAND /sbin/iptables -I FORWARD -m state -d $PRIVATEIP --state NEW,RELATED,ESTABLISHED -j ACCEPT"

echo "Listing iptables rules: "
$SUDOCOMMAND /sbin/iptables -t nat -L -n -v
read -p "Press a key to continue..."

