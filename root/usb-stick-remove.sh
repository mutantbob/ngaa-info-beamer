#!/bin/sh

( sudo -u pi /home/pi/bin/usb-stick-remove.sh "$@" 

umount /dev/$1
) &
