#!/bin/sh
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
