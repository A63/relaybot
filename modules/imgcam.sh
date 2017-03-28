#!/bin/sh
#
#   relaybot, the message-passing bot that grew into so much more
#   Copyright (C) 2015-2017  alicia@ion.nu
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, version 3 of the License.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
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
