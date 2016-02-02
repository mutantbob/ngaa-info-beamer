#!/bin/sh

#exec > /dev/pts/3 2>&1


DIR=/mnt/x/ngaa
if [ -d $DIR ]; then

    skill loop-video.sh
    skill omxplayer

    INFOBEAMER_BLANK_MODE=layer $HOME/vendor/info-beamer-pi/info-beamer $DIR
else
    echo "USB media has no ngaa/ subdirectory"
fi
