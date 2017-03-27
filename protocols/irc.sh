#!/bin/sh
if [ -z "$port" ]; then port=6667; fi
protocol_cmd="`which nc` '${host}' '${port}'"

handleline()
{
  line="`echo "$line" | tr -d '\r\n'`"
echo "Got: ${line}" >&2
  name="`echo "$line" | sed -e 's/^://;s/!.*//'`"
  if echo "$line" | grep -q '^:[^ ]* 332 '; then
    handleevent topic "`echo "$line" | sed -e 's/^:[^:]*://'`"
  elif echo "$line" | grep -q '^:[^ ]* PRIVMSG '; then
    color="`echo "$line" | sed -n -e 's/.*\([0-9][0-9]\?\).*/\1/p'`"
    msg="`echo "$line" | sed -e 's/^:[^:]*://; s/[0-9][0-9]\?//g'`"
    handleevent chatmsg "$msg" "$name" "$color"
  elif echo "$line" | grep -q '^:[^ ]* JOIN '; then
    handleevent join "$name"
  elif echo "$line" | grep -q '^:[^ ]* \(QUIT\|PART\) '; then
    handleevent part "$name"
  elif echo "$line" | grep -q '^:[^ ]* 001 '; then
    echo "JOIN ${channel}"
  elif echo "$line" | grep -q '^PING '; then
    echo "$line" | sed -e 's/PING/PONG/'
    handleevent ping
  fi
}

say()
{
  saidlast="$1"
  echo "PRIVMSG ${channel} :${1}"
  echo "relaybot: $1" >> "${DATADIR}/relaybot.chat"
}

protocol_init()
{
  echo 'USER relaybot relaybot relaybot relaybot'
  echo "NICK ${nickname}"
}
