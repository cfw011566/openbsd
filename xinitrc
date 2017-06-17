#!/bin/sh
# $OpenBSD: xinitrc.cpp,v 1.13 2015/10/17 08:25:11 matthieu Exp $

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then







    xrdb -merge $sysresources

fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then







    xrdb -merge "$userresources"

fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# if we have private ssh key(s), start ssh-agent and add the key(s)
id1=$HOME/.ssh/identity
id2=$HOME/.ssh/id_dsa
id3=$HOME/.ssh/id_rsa
id4=$HOME/.ssh/id_ecdsa
id5=$HOME/.ssh/id_ed25519

if [ -z "$SSH_AGENT_PID" ];
then
 if [ -x /usr/bin/ssh-agent ] && [ -f $id1 -o -f $id2 -o -f $id3 -o -f $id4 -o -f $id5 ];
 then
  eval `ssh-agent -s`
  ssh-add < /dev/null
 fi
fi

# start some nice programs

xset fp+ /usr/local/share/fonts/TrueType
xset fp+ /usr/local/share/fonts/mono
xset fp+ /usr/local/share/fonts/noto

synclient TouchpadOff=1
xinput set-prop "/dev/wsmouse" "WS Pointer Wheel Emulation" 1
xinput set-prop "/dev/wsmouse" "WS Pointer Wheel Emulation Axes" 4 5 6 7
xinput set-prop "/dev/wsmouse" "WS Pointer Wheel Emulation Button" 2
xinput set-prop "/dev/wsmouse" "WS Pointer Wheel Emulation Timeout" 50
xinput set-prop "/dev/wsmouse" "WS Pointer Wheel Emulation Inertia" 3
xinput set-prop "/dev/wsmouse" "Device Accel Constant Deceleration" 0.4


if [ -x /usr/local/bin/dbus-launch -a -z "${DBUS_SESSION_BUS_ADDRESS}" ]; then
        eval `dbus-launch --sh-syntax --exit-with-session`
fi

export GTK_IM_MODULE="scim"
export QT_IM_MODULE="scim"
export XMODIFIERS="@im=SCIM"
/usr/local/bin/scim -d
#export LC_CTYPE=en_US.UTF-8
#export LANG=zh_TW.UTF-8
#export LC_CTYPE=zh_TW.UTF-8
#export LC_ALL=zh_TW.UTF-8

/usr/local/bin/xmobar &
cwm

if [ "$SSH_AGENT_PID" ]; then
 ssh-add -D < /dev/null
 eval `ssh-agent -s -k`
fi
