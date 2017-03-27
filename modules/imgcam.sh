#!/bin/sh
if [ "x${protocol}" != "xtc_client" ]; then echo 'WARNING: the imgcam module is unlikely to make sense on other protocols than tinychat/tc_client' >&2; fi
imgcam()
{
  if toggle_cammode img; then
    img="$2"
    if ! wget -O img.img "$img"; then
      cammode=''
      echo '/camdown'
      continue
    fi
    if echo "$img" | grep -q '\.gif$'; then
      convert img.img -coalesce -resize 320x -alpha remove -alpha off img.gif
      "${EXECDIR}/camutil" img.gif &
    else
      convert img.img -resize 320x -alpha remove -alpha off img.png
      "${EXECDIR}/camutil" img.png &
    fi
  fi
}

addcmd '!img' imgcam
