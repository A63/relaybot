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
countdown_cmd()
{
  now="`date +%s`"
  target="`date -d "$countdownto" +%s`"
  diff="`expr "$target" - "$now"`"
  if [ "$diff" -lt 0 ]; then say "The target time has been reached"; return; fi
  days="`expr "$diff" / 86400`"
  diff="`expr "$diff" '%' 86400`"
  hours="`expr "$diff" / 3600`"
  diff="`expr "$diff" '%' 3600`"
  minutes="`expr "$diff" / 60`"
  output=''
  if [ "$days" != "0" ]; then
    output="${days} day"
    if [ "$days" != "1" ]; then output="${output}s"; fi
  fi
  if [ "$hours" != "0" ]; then
    if [ -n "$output" ]; then output="${output}, "; fi
    output="${output}${hours} hour"
    if [ "$hours" != "1" ]; then output="${output}s"; fi
  fi
  if [ "$minutes" != "0" ]; then
    if [ -n "$output" ]; then output="${output}, "; fi
    output="${output}${minutes} minute"
    if [ "$minutes" != "1" ]; then output="${output}s"; fi
  fi
  say "$output"
}

# Just a copy of the above, except for the / in the output
countdown_cmd_secret()
{
  now="`date +%s`"
  target="`date -d "$countdownto" +%s`"
  diff="`expr "$target" - "$now"`"
  if [ "$diff" -lt 0 ]; then echo "/The target time has been reached"; return; fi
  days="`expr "$diff" / 86400`"
  diff="`expr "$diff" '%' 86400`"
  hours="`expr "$diff" / 3600`"
  diff="`expr "$diff" '%' 3600`"
  minutes="`expr "$diff" / 60`"
  output=''
  if [ "$days" != "0" ]; then
    output="${days} day"
    if [ "$days" != "1" ]; then output="${output}s"; fi
  fi
  if [ "$hours" != "0" ]; then
    if [ -n "$output" ]; then output="${output}, "; fi
    output="${output}${hours} hour"
    if [ "$hours" != "1" ]; then output="${output}s"; fi
  fi
  if [ "$minutes" != "0" ]; then
    if [ -n "$output" ]; then output="${output}, "; fi
    output="${output}${minutes} minute"
    if [ "$minutes" != "1" ]; then output="${output}s"; fi
  fi
  echo "/ $output"
}

addcmd '!countdown' countdown_cmd
addcmd '/!countdown' countdown_cmd_secret
if [ -z "$countdownto" ]; then echo 'WARNING: the countdown module requires $countdownto to be set to a date' >&2; fi
