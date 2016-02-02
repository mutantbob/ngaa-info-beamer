#!/bin/sh

#exec > /dev/pts/0 2>&1 < /dev/null


mount -o ro /dev/$1 /mnt/x || exit 1
sudo -u pi /home/pi/bin/usb-stick-add.sh "$@"
