#!/bin/sh
countdown_cmd()
{
  now="`date +%s`"
  target="`date -d "$countdownto" +%s`"
  diff="`expr "$target" - "$now"`"
  if [ "$diff" -lt 0 ]; then say "The target time has been reached"; return; fi
  days="`expr "$diff" / 86400`"
  diff="`expr "$diff" '%' 86400`"
  hours="`expr "$diff" / 3600`"
  diff="`expr "$diff" '%' 3600`"
  minutes="`expr "$diff" / 60`"
  output=''
  if [ "$days" != "0" ]; then
    output="${days} day"
    if [ "$days" != "1" ]; then output="${output}s"; fi
  fi
  if [ "$hours" != "0" ]; then
    if [ -n "$output" ]; then output="${output}, "; fi
    output="${output}${hours} hour"
    if [ "$hours" != "1" ]; then output="${output}s"; fi
  fi
  if [ "$minutes" != "0" ]; then
    if [ -n "$output" ]; then output="${output}, "; fi
    output="${output}${minutes} minute"
    if [ "$minutes" != "1" ]; then output="${output}s"; fi
  fi
  say "$output"
}

# Just a copy of the above, except for the / in the output
countdown_cmd_secret()
{
  now="`date +%s`"
  target="`date -d "$countdownto" +%s`"
  diff="`expr "$target" - "$now"`"
  if [ "$diff" -lt 0 ]; then echo "/The target time has been reached"; return; fi
  days="`expr "$diff" / 86400`"
  diff="`expr "$diff" '%' 86400`"
  hours="`expr "$diff" / 3600`"
  diff="`expr "$diff" '%' 3600`"
  minutes="`expr "$diff" / 60`"
  output=''
  if [ "$days" != "0" ]; then
    output="${days} day"
    if [ "$days" != "1" ]; then output="${output}s"; fi
  fi
  if [ "$hours" != "0" ]; then
    if [ -n "$output" ]; then output="${output}, "; fi
    output="${output}${hours} hour"
    if [ "$hours" != "1" ]; then output="${output}s"; fi
  fi
  if [ "$minutes" != "0" ]; then
    if [ -n "$output" ]; then output="${output}, "; fi
    output="${output}${minutes} minute"
    if [ "$minutes" != "1" ]; then output="${output}s"; fi
  fi
  echo "/ $output"
}

addcmd '!countdown' countdown_cmd
addcmd '/!countdown' countdown_cmd_secret
if [ -z "$countdownto" ]; then echo 'WARNING: the countdown module requires $countdownto to be set to a date' >&2; fi
