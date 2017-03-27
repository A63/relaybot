#!/bin/sh
if [ "x${protocol}" != "xtc_client" ]; then echo 'WARNING: the videoutils module is unlikely to make sense on other protocols than tinychat/tc_client' >&2; fi
videoutils_mbs()
{
  if ! echo "$2" | grep -q '^youTube '; then return; fi
  vid="`echo "$2" | sed -e 's|^youTube ||; s/ .*//'`"
  bans="`curl --connect-timeout 10 -s "http://polsy.org.uk/stuff/ytrestrict.cgi?ytid=${vid}" | sed -n -e 's/.*<td>.*<td>.. - //p'`"
  if [ "`echo "$bans" | wc -l`" -gt 5 ]; then
    bans="`echo "$bans" | wc -l` countries, http://polsy.org.uk/stuff/ytrestrict.cgi?ytid=${vid}"
  else
    bans="`echo "$bans" | sed -e 's/$/, /' | tr -d '\n' | sed -e 's/, $//; s/, \([^,]*\)$/ and \1/'`"
  fi
# echo "Bans for ${vid}: ${bans}" >&2
  if [ "x${bans}" != "x" -a "x${bans}" != "xGermany" ]; then # Germany bans everything, so ignore it if it's just them
    say "Note: this video is blocked in ${bans}"
  fi
  # If a name wasn't given, find and announce it
  if echo "$2" | grep -q '^youTube [^ ]* 0$'; then
    title="`youtube-dl --get-title -- "$vid"`"
    if [ -n "$title" ]; then
      echo "/video: ${title}"
    fi
  fi
}

addcmd '/mbs' videoutils_mbs
