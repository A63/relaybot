#!/bin/false
versioncheck="`date +%s | xargs expr 3600 +`"
versioncheck_check()
{
  if [ "`date +%s`" -gt "$versioncheck" ]; then
    version="`curl -s 'https://tinychat.com/embed/chat.js' | sed -n -e '/swfName =/{s/.*swfName = "Tinychat-//;s/\.swf".*//;p;q;}'`"
    if [ "$version" != "`cat "${DATADIR}/flashclient.version"`" ]; then
      if [ -e "${DATADIR}/flashclient.version" ]; then # Don't announce on the first check
        say "Flash client version changed to ${version}"
      fi
      echo "$version" > "${DATADIR}/flashclient.version"
    fi
    versioncheck="`date +%s | xargs expr 3600 +`"
  fi
}
addeventhandler chatmsg versioncheck_check
