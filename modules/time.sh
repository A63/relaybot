#!/bin/sh
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
