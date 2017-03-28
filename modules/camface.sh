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
if [ "x${protocol}" != "xtc_client" ]; then echo 'WARNING: the camface module is unlikely to make sense on other protocols than tinychat/tc_client' >&2; fi
camface()
{
  if toggle_cammode face; then
    "${EXECDIR}/camutil" \
"${EXECDIR}/relaybotface/relaybot1.png" \
"${EXECDIR}/relaybotface/relaybot1.png" \
"${EXECDIR}/relaybotface/relaybot2.png" \
"${EXECDIR}/relaybotface/relaybot2.png" \
"${EXECDIR}/relaybotface/relaybot3.png" \
"${EXECDIR}/relaybotface/relaybot3.png" \
"${EXECDIR}/relaybotface/relaybot4.png" \
"${EXECDIR}/relaybotface/relaybot4.png" \
"${EXECDIR}/relaybotface/relaybot4.png" \
"${EXECDIR}/relaybotface/relaybot4.png" \
"${EXECDIR}/relaybotface/relaybot3.png" \
"${EXECDIR}/relaybotface/relaybot3.png" \
"${EXECDIR}/relaybotface/relaybot2.png" \
"${EXECDIR}/relaybotface/relaybot2.png" \
"${EXECDIR}/relaybotface/relaybot1.png" \
"${EXECDIR}/relaybotface/relaybot1.png" &
  fi
}

addcmd '!cam' camface
