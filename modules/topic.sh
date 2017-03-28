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
topic='{UNSET}'

topic_changed()
{
  if [ "$topic" = "{UNSET}" ]; then
    echo "Topic (join): ${1}" >&2
  else
    echo "Topic (new): ${1}" >&2
    say "Topic changed: ${1}"
  fi
  topic="$1"
}

topic_save()
{
  echo "$topic" > relaybot.reload.topic
}
topic_load()
{
  topic="`cat relaybot.reload.topic`"
}

topic_get()
{
  say "Topic: ${topic}"
}

addeventhandler topic topic_changed
addeventhandler reload_before topic_save
addeventhandler reload_after topic_load
addcmd '!topic' topic_get
