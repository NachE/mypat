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
	printf '\n\n***********************************************\n'
	printf 'Where you can save the hard disk image (qcow2)?\n'
	printf 'Type path of new qcow2 image or 'sh' to give you a shell: '
	read -r QCOW_FILE
	if [ $QCOW_FILE == 'sh' ];
	then
		printf '\n\nGiving you a shell. Type 'exit' to back this program\n\n'
		/bin/bash
	elif [ -e $QCOW_FILE ];
	then
		printf 'Error, file exists.\n'
	else
		
		printf 'Size of image in GB: (for example, 5): '
		read -r QCOW_SIZE
		$SUDOCOMMAND qemu-img create -f qcow2 -o preallocation=metadata $QCOW_FILE ${QCOW_SIZE}G
		if [ $? -gt 0 ];
		then
			printf 'ERROR!!!'
		else
			break
		fi
	fi
done

while true
do

	printf '\n\nWhere is the iso of install media?\n'
	printf 'Type path of iso install or sh for a shell: '
	read -r ISOFILE
	if [ $ISOFILE == 'sh' ];
	then
		printf '\n\nGiving you a shell. Type 'exit' to back this program\n\n'
		/bin/bash
        elif [ -e $ISOFILE ];
	then
		printf 'Ok, using $ISOFILE for install\n'
		break
	else
		printf '!!Error: File not found :(\n'
	fi
done

DEFVAL=1024
read -p "Amount of ram [$DEFVAL]: " RAMSIZE
RAMSIZE=${RAMSIZE:-$DEFVAL}

DEFVAL=1
read -p "Number of CPUs [$DEFVAL]: " CPUNUM
CPUNUM=${CPUNUM:-$DEFVAL}

virt-install --os-variant list
printf 'OS Variant: '
read -r OSVARIANT

printf 'Name of this VM: '
read -r VMNAME

DEFVAL="YES"
read -p "Use virtio for network and disk? [$DEFVAL]: " USEVIRTIO
USEVIRTIO=${USEVIRTIO:-$DEFVAL}
if [ "$USEVIRTIO" == "YES" ];
then
	VIRTIODISK=",bus=virtio"
	VIRTIONET="virtio"
else
	VIRTIODISK=",bus=virtio"
	VIRTIONET="rtl8139"
fi

echo "Now we exec this command: "
echo "virt-install \
        --connect qemu:///system \
        --name $VMNAME \
        --ram $RAMSIZE \
        --vcpus $CPUNUM \
        --disk path=$QCOW_FILE,format=qcow2$VIRTIODISK,cache=writeback,size=${QCOW_SIZE} \
        --cdrom $ISOFILE \
        --network=bridge:virbr0,model=$VIRTIONET \
        --vnc \
        --noautoconsole \
        --hvm \
        --accelerate \
        --os-variant $OSVARIANT"

virt-install \
        --connect qemu:///system \
        --name $VMNAME \
        --ram $RAMSIZE \
        --vcpus $CPUNUM \
        --disk path=$QCOW_FILE,format=qcow2$VIRTIODISK,cache=writeback,size=${QCOW_SIZE} \
        --cdrom $ISOFILE \
        --network=bridge:virbr0,model=$VIRTIONET \
        --vnc \
        --noautoconsole \
        --hvm \
        --accelerate \
        --os-variant $OSVARIANT

read -p "Press a key to continue..."


#cd
#while true
#do
#	echo -e "\n\n\nYour current selection: $(pwd)$IMAGE"
#	echo    "Type 'done' to finish"
#	select FILENAME in .* *;
#	do
#
#		if [ $REPLY == "done" ];then
#			break
#		fi
#
#		if [ -d $FILENAME ];then
#			cd $FILENAME
#			IMAGE=""
#		else
#			IMAGE=/$FILENAME
#		fi
#
#		break
#	done
#done
#printf 'Original port: '
#read -r ORIGPORT

