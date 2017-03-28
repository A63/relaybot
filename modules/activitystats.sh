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
if [ -z "$irclog" ]; then echo 'ERROR: the activitystats module requires $irclog to be defined' >&2; fi

activitystats()
{
  days="`grep -c '^--- Day changed ' "$irclog"`"
  hour="`date +%H`"
  msgcount="`grep -c "^${hour}:[0-9][0-9] <" "$irclog"`"
  perminute="`expr "${msgcount}000" / "$days" / 60`"
  say "This hour of day gets `decimals "$perminute" 3` messages per minute on average"
}

addcmd '!activitystats' activitystats
