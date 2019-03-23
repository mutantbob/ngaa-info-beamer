#!/bin/sh


PD=/var/tmp/pkgroot.$$

mkdir $PD || exit 1


install -m u=rw -D debian/control $PD/DEBIAN/control || exit 1
install -m u=rwx,og=rx -D debian/postinst $PD/DEBIAN/postinst || exit 1
install -m u=rwx,og=rx -D debian/rules $PD/DEBIAN/rules || exit 1

install -m u=rw,og=r -D -t $PD/etc/systemd/system slideshow@.service || exit 1
install -D -t $PD/root/bin root/usb-stick-add.sh root/usb-stick-remove.sh || exit 1
install -D -t $PD/home/pi/bin usb-stick-add.sh usb-stick-remove.sh || exit 1
install -m u=rwx,og=rx -D raspbian-stretch-udev.rules $PD/etc/udev/rules.d/10-slideshow.rules || exit 1
mkdir -p $PD/mnt/x || exit 1


dpkg-deb --build $PD autoplug-video-loop.deb || exit 1

echo "deleting $PD in 5 seconds"
sleep 5 && rm -r $PD
