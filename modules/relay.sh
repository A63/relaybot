#!/bin/sh
active=''
mkdir -p "${DATADIR}/relaymsgs"
relay_msg()
{
  from="$2"
  # New relay format, potentially supporting nick aliasing
  first=true
  for msg in `grep -rli "^ to: ${from}\$" "${DATADIR}/relaymsgs" | sort -n`; do
    if "$first"; then
      sed -n -e "s/^\\([^ :]*\\):/${from}: Message from \1:/p" "$msg" | sayx
      first=false
    else
      sed -n -e "s/^\\([^ :]*\\):/From \1:/p" "$msg" | sayx
    fi
    rm -f "$msg"
    sleep 0.8
  done
  active="`echo "$active" | grep -v "^${from}: "`
${from}: `date +%s | xargs expr 300 +`"
}

relay_relay()
{
  from="$1"
  tolistplus="`echo "$2" | sed -e 's/ .*//;s|+| |g'`" # Get recipient(s) and separate by +
  actualtolist=''
  for tolist in ${tolistplus}; do
    tolist="`echo "$tolist" | sed -e 's|/| |g'`"
    for to in ${tolist}; do
      mintime="`echo "$active" | grep "^${to}: " | sed -e 's/.*: //'`"
      echo "mintime: ${mintime}, now: `date +%s`" >&2
      if [ "$mintime" -gt "`date +%s`" ] 2> /dev/null; then
        say "${to} looks active to me, won't relay" priv "$from"
        continue 2
      fi
      if [ "`grep -l "^ to: ${to}\$" "${DATADIR}/relaymsgs"/* | wc -l`" -gt 5 ]; then
        say "${from}: ${to}'s inbox is full (restricting to 6 messages to prevent getting autobanned)"
        continue 2
      fi
    done
    if [ "x${actualtolist}" = "x" ]; then
      actualtolist="`echo "$tolist" | tr ' ' '/'`"
    else
      actualtolist="${actualtolist}+`echo "$tolist" | tr ' ' '/'`"
    fi
    msg="`echo "$2" | sed -e "s/^[^ ]* //"`"
    echo "Relaying message from '${from}' to '${tolist}': '${msg}'" >&2
    id="`date +%s`"
    while [ -e "${DATADIR}/relaymsgs/${id}" ]; do id="`expr "$id" + 1`"; done
    for to in ${tolist}; do
      echo " to: ${to}" >> "${DATADIR}/relaymsgs/${id}"
    done
    echo "${from}: ${msg}" >> "${DATADIR}/relaymsgs/${id}"
  done
  if [ "x${actualtolist}" != "x" ]; then
    say "Will relay '${msg}' to ${actualtolist}" priv "$from"
  fi
}

relay_relayed()
{
  from="$1"
  to="$2"
  if grep -l "^ to: ${to}\$" "${DATADIR}/relaymsgs"/* | xargs --no-run-if-empty grep "^${from}: " | grep -q .; then
    say "There are messages from ${from} to ${to} which have not yet been delivered"
  else
    say "All messages from ${from} to ${to} have been delivered :)"
  fi
}

relay_part()
{
  active="`echo "$active" | grep -v "^${1}: "`"
}

addeventhandler chatmsg relay_msg
addeventhandler part relay_part
addcmd '!relay' relay_relay
addcmd '!relayed' relay_relayed
