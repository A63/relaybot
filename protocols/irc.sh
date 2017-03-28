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
if [ -z "$port" ]; then port=6667; fi
protocol_cmd="`which nc` '${host}' '${port}'"

handleline()
{
  line="`echo "$line" | tr -d '\r\n'`"
echo "Got: ${line}" >&2
  name="`echo "$line" | sed -e 's/^://;s/!.*//'`"
  if echo "$line" | grep -q '^:[^ ]* 332 '; then
    handleevent topic "`echo "$line" | sed -e 's/^:[^:]*://'`"
  elif echo "$line" | grep -q '^:[^ ]* PRIVMSG '; then
    color="`echo "$line" | sed -n -e 's/.*\([0-9][0-9]\?\).*/\1/p'`"
    msg="`echo "$line" | sed -e 's/^:[^:]*://; s/[0-9][0-9]\?//g'`"
    handleevent chatmsg "$msg" "$name" "$color"
  elif echo "$line" | grep -q '^:[^ ]* JOIN '; then
    handleevent join "$name"
  elif echo "$line" | grep -q '^:[^ ]* \(QUIT\|PART\) '; then
    handleevent part "$name"
  elif echo "$line" | grep -q '^:[^ ]* 001 '; then
    echo "JOIN ${channel}"
  elif echo "$line" | grep -q '^PING '; then
    echo "$line" | sed -e 's/PING/PONG/'
    handleevent ping
  fi
}

say()
{
  saidlast="$1"
  echo "PRIVMSG ${channel} :${1}"
  echo "relaybot: $1" >> "${DATADIR}/relaybot.chat"
}

protocol_init()
{
  echo 'USER relaybot relaybot relaybot relaybot'
  echo "NICK ${nickname}"
}
