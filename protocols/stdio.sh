#!/bin/sh
protocol_cmd="run_with_PIPE_as_argv1"
if [ -n "$cookiejar" ]; then protocol_cmd="${protocol_cmd} --cookies '${cookiejar}'"; fi
if [ -n "$textcolor" ]; then protocol_cmd="${protocol_cmd} -c '${textcolor}'"; fi

handleline()
{
  handleevent chatmsg "$1" "user"
}

say()
{
  saidlast="$1"
  echo "$1"
  echo "relaybot: $1" >> "${DATADIR}/relaybot.chat"
}

protocol_init()
{
  true # Nothing to initialize
}
