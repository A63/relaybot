#!/bin/sh
#
#   relaybot, the message-passing bot that grew into so much more
#   Copyright (C) 2018  alicia@ion.nu
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
mkdir -p "${DATADIR}/lastseen"
lastseen_msg()
{
  from="`echo "$2" | tr -d '/'`"
  date '+%s' > "${DATADIR}/lastseen/${from}"
}

lastseen_lastseen()
{
  who="$2"
  if [ -e "${DATADIR}/lastseen/${who}" ]; then
    time="`cat "${DATADIR}/lastseen/${who}"`"
    now="`date '+%s'`"
    time="`expr "$now" - "$time"`"
    days="`expr "$time" / 86400`"
    hours="`expr "$time" '%' 86400 / 3600`"
    minutes="`expr "$time" '%' 3600 / 60`"
    seconds="`expr "$time" '%' 60`"
    msg=""
    sep=''
    if [ "$days" != "0" ]; then msg="${msg}${sep}${days} day"; if [ "$days" != "1" ]; then msg="${msg}s"; fi; sep=', '; fi
    if [ "$hours" != "0" ]; then msg="${msg}${sep}${hours} hour"; if [ "$hours" != "1" ]; then msg="${msg}s"; fi; sep=', '; fi
    if [ "$minutes" != "0" ]; then msg="${msg}${sep}${minutes} minute"; if [ "$minutes" != "1" ]; then msg="${msg}s"; fi; sep=', '; fi
    if [ "$seconds" != "0" -o -z "$sep" ]; then
      msg="${msg}${sep}${seconds} second"
      if [ "$seconds" != "1" ]; then msg="${msg}s"; fi;
    fi
    say "${who} was last seen ${msg} ago"
  else
    say "Who is ${who}?"
  fi
}

addeventhandler chatmsg lastseen_msg
addcmd '!lastseen' lastseen_lastseen
