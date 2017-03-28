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
protocol_cmd="run_with_PIPE_as_argv1"
if [ -n "$cookiejar" ]; then protocol_cmd="${protocol_cmd} --cookies '${cookiejar}'"; fi
if [ -n "$textcolor" ]; then protocol_cmd="${protocol_cmd} -c '${textcolor}'"; fi

handleline()
{
  handleevent chatmsg "$1" "user"
}

say()
{
  saidlast="$1"
  echo "$1"
  echo "relaybot: $1" >> "${DATADIR}/relaybot.chat"
}

protocol_init()
{
  true # Nothing to initialize
}
