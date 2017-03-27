#!/bin/false
wordtonum='s/\ba\b/1/g;
s/\ban\b/1/ig;
s/\bone\b/1/ig;
s/\btwo\b/2/ig;
s/\bthree\b/3/ig;
s/\bfour\b/4/ig;
s/\bfive\b/5/ig;
s/\bsix\b/6/ig;
s/\bseven\b/7/ig;
s/\beight\b/8/ig;
s/\bnine\b/9/ig;
s/\bten\b/10/ig;
s/\beleven\b/11/ig;
s/\bfifteen\b/15/ig;
s/\btwenty\b/20/ig;
s/\bthirty\b/30/ig;
s/\bfourty\b/40/ig;
s/\bfourtyfive\b/45/ig;
s/\bfifty\b/50/ig;
s/\band\b/+/ig;
s/,/+/g;
s/\btomorrow\b/+1day/ig;
s/\bnext day\b/+1day/ig;
s/\bnext week\b/+7days/ig;
s/\bnext month\b/+1month/ig;
'
reversepronouns='s/\bmy\b/yourXX<tmp>XX/ig; s/\bme\b/youXX<tmp>XX/ig; s/\byour\b/my/ig; s/\byou\b/me/ig; s/XX<tmp>XX//g'

reminder()
{
  chatmsg="$1"
  from="$2"
  if echo "$chatmsg" | grep -qi '^\(relaybot: *\|relaybot, *\|\)remind me to .* \(in\|at\|on\) '; then
    inat="`echo "$chatmsg" | sed -e 's/^\(relaybot: *\|relaybot, *\|\)remind me to .* \(in\|at\|on\) .*/\2/i'`"
    desttime="`echo "$chatmsg" | sed -e "s/^\(relaybot: *\|relaybot, *\|\)remind me to .* \(in\|at\|on\) //i; ${wordtonum}"`"
    remindmsg="`echo "$chatmsg" | sed -e 's/^\(relaybot: *\|relaybot, *\|\)remind me to \(.*\) \(in\|at\|on\) .*/\2/i'`"
  elif echo "$chatmsg" | grep -qi '^\(relaybot: *\|relaybot, *\|\)remind me \(in\|at\|on\) .* to .'; then
    inat="`echo "$chatmsg" | sed -e 's/^\(relaybot: *\|relaybot, *\|\)remind me \(in\|at\|on\) .* to ./\2/i'`"
    desttime="`echo "$chatmsg" | sed -e "s/^\(relaybot: *\|relaybot, *\|\)remind me \(in\|at\|on\) .* to .//i; ${wordtonum}"`"
    remindmsg="`echo "$chatmsg" | sed -e 's/^\(relaybot: *\|relaybot, *\|\)remind me \(in\|at\|on\) .* to \(.*\)/\3/i'`"
  else
    return
  fi
  remindmsg="`echo "$remindmsg" | sed -e "$reversepronouns"`"
  if [ "$inat" = "in" ]; then desttime="+${desttime}"; fi # TODO: what about "remind me in <month/year>?"
  if date -d "$desttime" > /dev/null 2> /dev/null; then
    desttime="`date -d "$desttime" +%s`"
    diff="`date +%s`"
    diff="`expr "$desttime" - "$diff"`"
    if [ "$diff" -lt 1 ]; then return 1; fi
    if [ "$diff" -gt 30 ]; then
      say "ok ${from}, I will remind you"
    fi
    if [ "$diff" -lt 86400 ]; then # Less than 24 hours, volatile but precise reminder
      (
        sleep "$diff"
        say "${from}: remember to ${remindmsg}"
      ) &
    else # 24 hours or more, less precise but persists across reloads/reconnects
      mkdir -p "${DATADIR}/reminders"
      id="`date +%s`"
      while [ -e "${DATADIR}/reminders/${id}" ]; do id="`expr "$id" + 1`"; done
      echo "Time: ${desttime}" > "${DATADIR}/reminders/${id}"
      echo "For: ${from}" >> "${DATADIR}/reminders/${id}"
      echo "Message: ${remindmsg}" >> "${DATADIR}/reminders/${id}"
    fi
    return 0
  fi
  for x in `grep -rl "^For: ${from}$" "${DATADIR}/reminders" 2> /dev/null`; do
    desttime="`sed -n -e 's/^Time: //p' "$remindmsg"`"
    if [ "$desttime" -gt "`date +%s`" ]; then continue; fi
    msg="`sed -n -e 's/^Message: //p' "$x"`"
    say "${from}: remember to ${msg}"
    rm -f "$x"
    break # Only one reminder per message
  done
  return 1
}

addeventhandler chatmsg reminder
