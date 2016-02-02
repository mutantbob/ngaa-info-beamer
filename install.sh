#!/bin/sh

running_on_pi()
{
    ( . /etc/os-release
      case $NAME in
	  Raspbian*)
	      return 0
	      ;;
      esac
      return 1
      )

}

echo "This is a shell script that configures a Raspberry Pi to run a slideshow any time a USB stick is plugged in that has an ngaa/ directory containing a node.lua info-beamer script"

if running_on_pi; then
    default_target=
else
    default_target=/auto/pi
fi

echo -n "choose install root [ default = $default_target ] "

read target

if [ -z "$target" ]; then
    target=$default_target
fi


install -v -o root -m 0644	10-info-beamer.rules $target/etc/udev/rules.d/
install -v -o pi -m 0755 -d	$target/home/pi/bin
install -v -o pi -m 0755	usb-stick-add.sh usb-stick-remove.sh $target/home/pi/bin/
install -v -o root -m 0755 -d	$target/root/bin $target/mnt/x
install -v -o root -m 0755	root/usb-stick-add.sh root/usb-stick-remove.sh $target/root/bin/

(grep -v "^gpu_mem" $target/boot/config.txt ; echo "#infobeamer needs gpu_mem "; echo "gpu_mem=192") > $target/boot/config.txt.new &&
mv $target/boot/config.txt.new $target/boot/config.txt
