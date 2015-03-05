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

. $ORIG/config/config.sh
. $ORIG/lib/util.sh

echo_info "Starting MyPATS"
echo_info "Loading Modules..."

# Load all modules
COUNT=1
MENUITEMS="\"EXIT\" \"[X] CLOSE THE PROGRAM\""
for i in `find $ORIG/modules/*/load.sh`
do
	MENU_ITEM_NAME="PLUGIN WITHOUT NAME"
	. $i
	DIRNAME=$(dirname $i)
	START=$DIRNAME/start.sh
	MODULES[$COUNT]=$START
	MENUITEMS="$MENUITEMS \"$COUNT\" \"$MENU_ITEM_NAME\""

	COUNT=`expr $COUNT + 1`
done
SELECTED=1

# Build Main menu
while true
do
	MENUCOMMAND="whiptail --title \"Main Menu\" --menu \"Choose an option\" 22 78 16 --default-item $SELECTED $MENUITEMS"
	RET=$(eval $MENUCOMMAND 3>&1 1>&2 2>&3)
	if [ $RET == "EXIT" ];then
		break
	fi
	SELECTED=$RET
	echo "You choosed ${MODULES[$RET]}"
	eval ${MODULES[$RET]}
done







