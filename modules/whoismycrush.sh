#!/bin/false
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
guesscrush()
{
  nick="$1"
  lines=50000
  tail -n "$lines" "${DATADIR}/relaybot.chat" | sed -e 's/:.*//' | grep -B 1 -F -x -- "$nick" | grep -v -x -F -- "$nick" | grep -v -- -- | sort | uniq -c | sort -n | tail -n 1 | sed -e 's/.* //' | grep .
}

whoismycrush()
{
  from="$1"
  x="`echo "$from" | sed -e 's/[0-9]*$//'`"
  crush="`echo "$crushes" | sed -n -e "s/^${x}=//p"`"
  if [ -z "${crush}" ]; then
    crush="`guesscrush "$from" || echo "I don't know, sorry"`"
  else
    sleep 1 # Some artificial delay
  fi
  if echo "$saidlast" | grep -q '^[^ ]*: your crush is probably\.\.\. '; then
    say "${from}: ${crush}"
  else
    say "${from}: your crush is probably... ${crush}"
  fi
}
addcmd '!whoismycrush' whoismycrush
