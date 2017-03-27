#!/bin/sh
if [ -z "$irclog" ]; then echo 'ERROR: the activitystats module requires $irclog to be defined' >&2; fi

activitystats()
{
  days="`grep -c '^--- Day changed ' "$irclog"`"
  hour="`date +%H`"
  msgcount="`grep -c "^${hour}:[0-9][0-9] <" "$irclog"`"
  perminute="`expr "${msgcount}000" / "$days" / 60`"
  say "This hour of day gets `decimals "$perminute" 3` messages per minute on average"
}

addcmd '!activitystats' activitystats
