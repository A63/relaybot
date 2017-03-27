#!/bin/sh
gitreport="`date +%s | xargs expr 30 +`"
mkdir -p "${DATADIR}/gitreport"
gitreport_check()
{
  if [ "`date +%s`" -gt "$gitreport" ]; then
    gitreport="`date +%s | xargs expr 300 +`"
    for repo in ${gitreport_repos}; do
      fsrepo="`echo "$repo" | sed -e 's/[^-a-zA-Z0-9]/_/g'`"
      commit="`curl -s "${repo}/refs/heads/master"`"
      oldcommit="`cat "${DATADIR}/gitreport/${fsrepo}" 2> /dev/null`"
      if [ -z "$oldcommit" ]; then echo "$commit" > "${DATADIR}/gitreport/${fsrepo}"; return; fi
      if [ -z "$commit" ]; then continue; fi
      if [ "x${commit}" = "x${oldcommit}" ]; then continue; fi
      echo "$commit" > "${DATADIR}/gitreport/${fsrepo}"
      object="`echo "$commit" | sed -e 's|^..|&/|'`"
      msg="`(printf '\037\213\010\000\026\022\360\127'; curl -s "${repo}/objects/${object}") | gzip -d 2> /dev/null | sed -e '1,/^$/d'`"
      if [ -z "$msg" ]; then continue; fi
      say "New commit in `basename "$repo"`: ${msg}"
    done
  fi
}
addeventhandler chatmsg gitreport_check
addeventhandler join gitreport_check
addeventhandler part gitreport_check
addeventhandler ping gitreport_check
if [ -z "$gitreport_repos" ]; then echo 'WARNING: the gitreport module requires $gitreport_repos to be set to a list of git repository URLs' >&2; fi
