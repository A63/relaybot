#!/bin/sh
protocol_cmd="`which tc_client` --hexcolors ${channel} ${nickname} ${password}"
if [ -n "$cookiejar" ]; then protocol_cmd="${protocol_cmd} --cookies '${cookiejar}'"; fi
if [ -n "$textcolor" ]; then protocol_cmd="${protocol_cmd} -c '${textcolor}'"; fi

handleline()
{
  line="$1"

  if echo "$line" | grep -q '^\[[0-2][0-9]:[0-6][0-9]\] ([^)]*)[^:]*: '; then
    from="`echo "$line" | sed -e "s/^[^ ]* ([^)]*)\([^:]*\):.*/\1/"`"
    chatmsg="`echo "$line" | sed -e 's/^\[[0-2][0-9]:[0-6][0-9]\] ([^)]*)[^:]*: //'`"
    color="`echo "$line" | sed -e "s/^[^ ]* (//; s/[,)].*//"`"
    handleevent chatmsg "$chatmsg" "$from" "$color"
  elif echo "$line" | grep -q '^Room topic: '; then
    handleevent topic "`echo "$line" | sed -e 's/^Room topic: //'`"
  elif echo "$line" | grep -q '^[^ ]* cammed up$'; then
    handleevent camup "`echo "$line" | sed -e 's/ .*//'`"
  elif echo "$line" | grep -q '^guest-[0-9]* is logged in as '; then
    name="`echo "$line" | sed -e 's/ .*//'`"
    acc="`echo "$line" | sed -e 's|^guest-[0-9]* is logged in as ||'`"
    handleevent account "$name" "$acc"
  elif echo "$line" | grep -q '^\[[0-2][0-9]:[0-6][0-9]\] [^ ]* entered the channel$'; then
    name="`echo "$line" | sed -e 's/^\[[0-2][0-9]:[0-6][0-9]\] //;s/ .*//'`"
    handleevent join "$name"
    echo "/whois ${name}" # Used by multiple modules
  elif echo "$line" | grep -q '^\[[0-2][0-9]:[0-6][0-9]\] [^:]* changed nickname to '; then
    from="`echo "$line" | sed -e 's/^\[[0-2][0-9]:[0-6][0-9]\] //; s/ changed nickname to .*//'`"
    nick="`echo "$line" | sed -e 's/^\[[0-2][0-9]:[0-6][0-9]\] [^ ]* changed nickname to //'`"
    handleevent nick "$from" "$nick"
  elif echo "$line" | grep -q '^\[[0-2][0-9]:[0-6][0-9]\] [^:]* left the channel'; then
    nick="`echo "$line" | sed -e 's/^\[[0-2][0-9]:[0-6][0-9]\] //; s/ .*//'`"
    handleevent part "$nick"
  elif echo "$line" | grep -q '^[^ ]* is a moderator.'; then # TODO: expand into proper mod tracking?
    handleevent mod "`echo "$line" | sed -e 's/ .*//'`"
  elif [ "x${line}" = "xProbably cut off:" ]; then
    handleevent probablycutoff
  elif echo "$line" | grep '^Captcha:' >&2; then
    read x < /dev/tty
    echo done >&2
    echo
  fi
}

say()
{
  if [ "x${2}" = "xpriv" ]; then
    echo "/priv ${3} ${1}"
    return
  fi
  saidlast="$1"
  echo "$1"
  echo "relaybot: $1" >> "${DATADIR}/relaybot.chat"
}

protocol_init()
{
  true # Nothing to initialize
}
