#!/bin/sh
if [ "x${protocol}" != "xtc_client" ]; then echo 'WARNING: the magnifier module is unlikely to make sense on other protocols than tinychat/tc_client' >&2; fi
magnifier_toggle()
{
  deleventhandler chatmsg magnifier
  if toggle_cammode magnifier; then
    addeventhandler chatmsg magnifier
    magnifier
  fi
}

magnifier()
{
  chatmsg="$1"
  from="$2"
  if [ "x${cammode}" != 'xmagnifier' ]; then return; fi
  convert -font /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf -size 320x240 -background '#ffffff' -fill "#000000" "caption:${from}: ${chatmsg}" /tmp/magnifier.png
  pkill -x camutil
  "${EXECDIR}/camutil" /tmp/magnifier.png &
}

addcmd '!magnifier' magnifier_toggle
