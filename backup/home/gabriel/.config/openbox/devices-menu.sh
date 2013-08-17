#!/bin/bash

# An openbox menu for removable media (requires udiskie).
#
# This script will generate sub-menus for any device mounted
# under /media. You can browse the device in a file manager or
# unmount it.
#
# It will ignore the "cd", "dvd", and "fl" directories and the U3
# containers found on some windows formatted drives
#
# By default, this script uses the thunar file manager to browse the
# media.

DIR=$(cd $(dirname "$0") && pwd)
SCRIPT=$(basename "$0")
NOTIFY="notify-send"
FM_CMD="thunar"

pipemenu() {

    cd /media
    echo '<openbox_pipe_menu>'

    for i in *
    do
	if [ "$i" != "*" ] && [[ ! "$i" =~ ^U3|cd|dvd|fl ]]; then
	    echo "<item label=\"Browse $i\">"
	    echo "<action name=\"Execute\">"
	    echo "<execute>$FM_CMD /media/$i</execute>"
	    echo "</action></item>"
	    echo "<item label=\"Unmount $i\">"
	    echo "<action name=\"Execute\">"
	    echo "<execute>$DIR/$SCRIPT unmount /media/$i</execute>"
	    echo "</action></item>"
	    echo "<separator/>"
	fi
    done

    echo "<item label=\"Eject CD/DVD\">"
    echo "<action name=\"Execute\">"
    echo "<execute>eject -T</execute>"
    echo "</action></item>"

    echo "<item label=\"Remount all\">"
    echo "<action name=\"Execute\">"
    echo "<execute>$DIR/$SCRIPT remount</execute>"
    echo "</action></item>"

    echo "</openbox_pipe_menu>"
}

case $1 in 
    unmount)
	udiskie-umount $2
	if mountpoint -q $2; then
	    $NOTIFY "Failed to unmount $2"
	else
	    $NOTIFY "Unmounted $2"
	fi
	;;
    remount)
	killall udiskie
	udiskie &
	$NOTIFY "Mounting removable media..."
	;;
    *)
	pipemenu
	;;
esac
