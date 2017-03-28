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
gettimeat()
{
  timezone="`echo "$2" | sed -e 's/ /_/g'`"
  timezone="`find /usr/share/zoneinfo -follow -type f -iname "$timezone" | head -n 1`"
  if [ "x${timezone}" = "x" ]; then
    say "Unknown timezone"
  else
    TZ="$timezone" date '+%H:%M %Z' | sayx
  fi
}

gettimeatsecret()
{
  timezone="`echo "$2" | sed -e 's/ /_/g'`"
  timezone="`find /usr/share/zoneinfo -follow -type f -iname "$timezone" | head -n 1`"
  if [ "x${timezone}" = "x" ]; then
    echo "/Unknown timezone"
  else
    TZ="$timezone" date '+%H:%M %Z' | sed -e 's|^|/|'
  fi
}

addcmd '!time' gettimeat
addcmd '/!time' gettimeatsecret
