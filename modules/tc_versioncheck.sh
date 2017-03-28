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
versioncheck="`date +%s | xargs expr 3600 +`"
versioncheck_check()
{
  if [ "`date +%s`" -gt "$versioncheck" ]; then
    version="`curl -s 'https://tinychat.com/embed/chat.js' | sed -n -e '/swfName =/{s/.*swfName = "Tinychat-//;s/\.swf".*//;p;q;}'`"
    if [ "$version" != "`cat "${DATADIR}/flashclient.version"`" ]; then
      if [ -e "${DATADIR}/flashclient.version" ]; then # Don't announce on the first check
        say "Flash client version changed to ${version}"
      fi
      echo "$version" > "${DATADIR}/flashclient.version"
    fi
    versioncheck="`date +%s | xargs expr 3600 +`"
  fi
}
addeventhandler chatmsg versioncheck_check
