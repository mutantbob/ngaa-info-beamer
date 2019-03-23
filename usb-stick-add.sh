#!/bin/sh

#exec > /dev/pts/3 2>&1

DIR=/mnt/x/ngaa
if [ -d $DIR ]; then

    skill loop-video.sh
    skill omxplayer
    if [ -f $DIR/node.lua ] ; then

	INFOBEAMER_BLANK_MODE=layer $HOME/info-beamer-pi/info-beamer $DIR
    else
	omxplayer -b -o hdmi --loop --no-osd $DIR/loop.mp4
    fi
else
    echo "USB media has no ngaa/ subdirectory"
fi
