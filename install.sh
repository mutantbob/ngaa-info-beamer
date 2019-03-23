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


rig_usb_magic()
{

install -v -o root -m 0644	10-info-beamer.rules $target/etc/udev/rules.d/
install -v -o root -m 0644	slideshow\@.service $target/etc/systemd/system/slideshow\@.service

install -v -o pi -m 0755 -d	$target/home/pi/bin
install -v -o pi -m 0755	usb-stick-add.sh usb-stick-remove.sh $target/home/pi/bin/
install -v -o root -m 0755 -d	$target/root/bin $target/mnt/x
install -v -o root -m 0755	root/usb-stick-add.sh root/usb-stick-remove.sh $target/root/bin/

}

rig_gpu_mem()
{
    (
	egrep -v "^(gpu_mem|.*infobeamer needs gpu_mem)" $target/boot/config.txt
	echo "#infobeamer needs gpu_mem "
	echo "gpu_mem=192"
    ) > $target/boot/config.txt.new &&
	mv $target/boot/config.txt.new $target/boot/config.txt
}

install_info_beamer()
{
    (
	cd $target/home/pi
	tar xzf /home/thoth/ftp/info-beamer-pi-0.9.8-beta.3261a8-stretch.tar.gz
    )
}

rig_static_address_stretch()
{
cat <<EOF >> $target/etc/network/interfaces
#Bob was here
auto eth0
iface eth0 inet static
    address 169.254.3.16
    netmask 255.255.0.0
    gateway 169.254.0.1
EOF
}

deactivate_lightdm_stretch ()
{
    for f in $target/etc/rc*.d/S??lightdm; do
	d=$(dirname $f)
	b=${f##*/S??}
	mv -v $f $d/K01$b
    done
}

rig_us_keyboard_stretch ()
{
    f=$target/etc/default/keyboard
    sed -e 's/XKBLAYOUT=.*/XKBLAYOUT="us"/' < $f > $f.new
    mv -v --backup $f.new $f
}

activate_sshd_stretch ()
{
    for f in $target/etc/rc[3-9].d/K??ssh; do
	d=$(dirname $f)
	b=${f##*/K??}
	mv -v $f $d/S99$b
    done
}

#
#
#

rig_usb_magic
rig_gpu_mem
install_info_beamer
rig_static_address_stretch
deactivate_lightdm_stretch
rig_us_keyboard_stretch
activate_sshd_stretch

udevadm control --reload

