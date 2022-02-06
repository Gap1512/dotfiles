#!/bin/sh

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

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

dte(){
    dte="$(date +"%F %R")"
    echo -e " $dte"
}

upd(){
    upd=`checkupdates | wc -l`
    echo -e "累 $upd updates"
}

mem(){
    mem=`free | awk '/Mem/ {printf "%d MiB/%d MiB\n", $3 / 1024.0, $2 / 1024.0 }'`
    echo -e " $mem"
}

cpu(){
    read cpu a b c previdle rest < /proc/stat
    prevtotal=$((a+b+c+previdle))
    sleep 0.5
    read cpu a b c idle rest < /proc/stat
    total=$((a+b+c+idle))
    cpu=$((100 * ((total - prevtotal) - (idle - previdle)) / (total - prevtotal)))
    echo -e "ﲾ $cpu% cpu"
}

# Statusbar loop
while true; do
    RED="^c#FF6188^"
    GREEN="^c#A9DC76^"
    MAGENTA="^c#AB9DF2^"
    CYAN="^c#78DCE8^"
    WHITE="^c#FCFCFA^"
    xsetroot -name "${RED}$(cpu) ${WHITE}| ${GREEN}$(mem) ${WHITE}| ${MAGENTA}$(upd) ${WHITE}| ${CYAN}$(dte)"
    sleep 10s
done &

nitrogen --restore &
picom &
exec dwm
