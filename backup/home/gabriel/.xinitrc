#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run window manager from here)

XRESOURCES
######################################################

# Define Xresources
userresources=$HOME/.Xresources

# Merge what is available
if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

XPROFILE
######################################################

# Define xprofile
# Make sure this is before the 'exec' command or it won't be sourced.
[ -f /etc/xprofile ] && source /etc/xprofile
[ -f ~/.xprofile ] && source ~/.xprofile

EXECUTE WINDOW MANAGER
######################################################

# exec gnome-session
# exec startkde
# exec startxfce4
# exec startfluxbox
# ...or the Window Manager of your choice

DEFAULT_SESSION=openbox-session

case $1 in
openbox-session)
	exec openbox-session
	;;
*)
	exec $DEFAULT_SESSION
	;;
esac
