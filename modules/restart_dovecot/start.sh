#!/bin/bash

pidof systemd && $SUDOCOMMAND systemctl restart dovecot || $SUDOCOMMAND /etc/init.d/dovecot restart
read -p "Press a key to continue..."
