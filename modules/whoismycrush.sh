#!/bin/false
guesscrush()
{
  nick="$1"
  lines=50000
  tail -n "$lines" "${DATADIR}/relaybot.chat" | sed -e 's/:.*//' | grep -B 1 -F -x -- "$nick" | grep -v -x -F -- "$nick" | grep -v -- -- | sort | uniq -c | sort -n | tail -n 1 | sed -e 's/.* //' | grep .
}

whoismycrush()
{
  from="$1"
  x="`echo "$from" | sed -e 's/[0-9]*$//'`"
  crush="`echo "$crushes" | sed -n -e "s/^${x}=//p"`"
  if [ -z "${crush}" ]; then
    crush="`guesscrush "$from" || echo "I don't know, sorry"`"
  else
    sleep 1 # Some artificial delay
  fi
  if echo "$saidlast" | grep -q '^[^ ]*: your crush is probably\.\.\. '; then
    say "${from}: ${crush}"
  else
    say "${from}: your crush is probably... ${crush}"
  fi
}
addcmd '!whoismycrush' whoismycrush
