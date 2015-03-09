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
	printf '\n\n\n***********************************\n'
	$SUDOCOMMAND /sbin/iptables -t nat -L -n -v

	DEFVAL=yes
	read -p "Again? yes/no [$DEFVAL]: " AGAIN
	AGAIN=${AGAIN:-$DEFVAL}

	if [ "$AGAIN" == "no" ];
	then
		break
	fi
done
