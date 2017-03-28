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
if [ "x${protocol}" != "xtc_client" ]; then echo 'WARNING: the neverhaveiever module is unlikely to make sense on other protocols than tinychat/tc_client' >&2; fi
neverhaveiever_join()
{
  if [ "x${cammode}" != "xneverhaveiever" ]; then return; fi
  from="$1"
  if [ -n "$2" ]; then return; fi
  if echo "$neverhaveiever" | grep -q "^${from}: "; then
    say "${from}: you're already in the game"
  elif [ "x${neverhaveiever}" != "x" ] && echo "$neverhaveiever" | grep -v -q ": ${neverhaveieverstartnum}\(\| (next)\)$"; then
    say "${from}: the game has already started, join next round instead"
  else
    if [ "x${neverhaveiever}" = "x" ]; then
      neverhaveiever="${from}: ${neverhaveieverstartnum} (next)"
    else
      neverhaveiever="${neverhaveiever}
${from}: ${neverhaveieverstartnum}"
    fi
    convert -font /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf -size 320x240 -background '#ffffff' -fill "#000000" "label:${neverhaveiever}" /tmp/neverhaveiever.png
    pkill -x camutil
    "${EXECDIR}/camutil" /tmp/neverhaveiever.png &
  fi
}

neverhaveiever_quit()
{
  if [ "x${cammode}" != "xneverhaveiever" ]; then return; fi
  from="$1"
  neverhaveiever="`echo "$neverhaveiever" | sed -e "/^${from}: /d"`"
  if [ "x${neverhaveiever}" = "x" ]; then # No users left = stop
    toggle_cammode neverhaveiever
  elif [ "`echo "$neverhaveiever" | wc -l`" = "1" ]; then # Win by default
    say "Winner: `echo "$neverhaveiever" | sed -e 's/: .*//'`"
    toggle_cammode neverhaveiever
  else
    convert -font /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf -size 320x240 -background '#ffffff' -fill "#000000" "label:${neverhaveiever}" /tmp/neverhaveiever.png
    pkill -x camutil
    "${EXECDIR}/camutil" /tmp/neverhaveiever.png &
  fi
}

neverhaveiever_losepoint()
{
  if [ "x${cammode}" != "xneverhaveiever" ]; then return; fi
  from="$1"
  if [ -n "$2" ]; then return; fi
  points="`echo "$neverhaveiever" | sed -n -e "s/ (next)//; s/^${from}: //p"`"
  if [ "x${points}" = "x" ]; then
    say "${from}: you don't seem to have joined the game"
  else
    points="`expr "$points" - 1`"
    neverhaveiever="`echo "$neverhaveiever" | sed -e "s/^${from}: [0-9]*/${from}: ${points}/"`"
    convert -font /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf -size 320x240 -background '#ffffff' -fill "#000000" "label:${neverhaveiever}" /tmp/neverhaveiever.png
    pkill -x camutil
    "${EXECDIR}/camutil" /tmp/neverhaveiever.png &
    neverhaveiever="`echo "$neverhaveiever" | sed -e "/^.*: 0/d"`"
    if [ "`echo "$neverhaveiever" | wc -l`" = "1" ]; then
      say "Winner: `echo "$neverhaveiever" | sed -e 's/: .*//'`"
      toggle_cammode neverhaveiever
    fi
  fi
}

neverhaveiever_addnext='n;s/$/ (next)/'
neverhaveiever_next()
{
  if [ "x${cammode}" != "xneverhaveiever" ]; then return; fi
  from="$1"
  if ! echo "$2" | grep -qi '^have I ever'; then return; fi
  neverhaveiever="`echo "$neverhaveiever" | sed -e "s/ (next)//; /^${from}: /{${neverhaveiever_addnext};}"`"
  convert -font /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf -size 320x240 -background '#ffffff' -fill "#000000" "label:${neverhaveiever}" /tmp/neverhaveiever.png
  pkill -x camutil
  "${EXECDIR}/camutil" /tmp/neverhaveiever.png &
}

neverhaveiever_toggle()
{
  delcmd '-1' neverhaveiever_losepoint
  delcmd '!join' neverhaveiever_join
  delcmd '!quit' neverhaveiever_quit
  delcmd 'never' neverhaveiever_next
  delcmd 'Never' neverhaveiever_next
  delcmd 'NEVER' neverhaveiever_next
  if toggle_cammode neverhaveiever; then
    neverhaveieverstartnum="`echo "$2" | sed -e 's/ //g'`"
    if [ -z "$neverhaveieverstartnum" ]; then neverhaveieverstartnum=5; fi
    convert -font /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf -size 320x240 -background '#ffffff' -fill "#000000" "caption:Type !join to join never-have-I-ever, type '-1' when losing a point, !quit to quit" /tmp/neverhaveiever.png
    "${EXECDIR}/camutil" /tmp/neverhaveiever.png &
    neverhaveiever=''
    addcmd '-1' neverhaveiever_losepoint
    addcmd '!join' neverhaveiever_join
    addcmd '!quit' neverhaveiever_quit
    addcmd 'never' neverhaveiever_next
    addcmd 'Never' neverhaveiever_next
    addcmd 'NEVER' neverhaveiever_next
  fi
}

addcmd '!neverhaveiever' neverhaveiever_toggle
addcmd '!neverhaveIever' neverhaveiever_toggle
addcmd '!NeverHaveIEver' neverhaveiever_toggle
addcmd '!NEVERHAVEIEVER' neverhaveiever_toggle
