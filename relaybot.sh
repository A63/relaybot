#!/bin/sh
# TODO: accept path to configuration file as $1, make PIPE an environment variable instead?
# Or parse arguments normally, -r for reload, -b for the bot part, non-flag for configuration file
EXECDIR="`realpath "$0" | xargs dirname`" # Home of this script and all the modules + static data
DATADIR="." # Home of things like messages to relay
. ./relaybot.conf
. "${EXECDIR}/protocols/${protocol}.sh"
if [ "x${1}" != "xPIPE" ]; then
  (
    echo '[Net'
    echo "$protocol_cmd"
    echo ']' '[Bot' "$0" PIPE ']' '{Net:1>Bot:0}' '{Bot:1>Net:0}'
  ) | xargs pipexec -k
fi
echo '(Re-)loaded' >&2
chatcommands=''
addcmd()
{
  chatcommands="${chatcommands}
${1}=${2}"
}
delcmd()
{
  chatcommands="`echo "$chatcommands" | sed -e "/^${1}=${2}\$/d"`"
}
eventhandlers=''
addeventhandler()
{
# echo "Adding event handler '${2}' for '${1}'" >&2
  eventhandlers="${eventhandlers}
${1}=${2}"
}
deleventhandler()
{
  eventhandlers="`echo "$eventhandlers" | sed -e "/^${1}=${2}\$/d"`"
}
handleevent()
{
# echo "Handling event '${1}'" >&2
  for x in `echo "$eventhandlers" | sed -n -e "s/^${1}=//p"`; do
# echo "Handler: ${x}" >&2
    "$x" "$2" "$3" "$4"
  done
}
protocol_init
for module in ${modules}; do . "${EXECDIR}/modules/${module}.sh"; done
# TODO: move this into a module for cam features to depend on?
cammode=''
toggle_cammode()
{
  if [ "x$cammode" = "x${1}" ]; then
    cammode=''
    pkill -x camutil
    echo '/camdown'
    return 1
  else
    if [ "x$cammode" != "x" ]; then
      pkill -x camutil
    else
      echo '/camup'
    fi
    cammode="$1"
    return 0
  fi
}
if [ "x${2}" = "xreload" ]; then
  cammode="`cat relaybot.reload.cammode`"
  handleevent reload_after
  rm -f relaybot.reload.*
fi
saidlast=''
sayx()
{
  read x
  say "$x"
}
sayonce()
{
  if [ "x${saidlast}" != "x${1}" ]; then say "$1"; saidlast="$1"; fi
}
decimals()
{
  value="$1"
  decimalcount="$2"
  decimalpoints=''
  for x in `seq "$decimalcount"`; do
    value="0${value}"
    decimalpoints="${decimalpoints}[0-9]"
  done
  echo "$value" | sed -e "s/${decimalpoints}\$/.&/;s/^0*//;s/0*\$//;s/\\.\$//"
}
countdecimals()
{
  echo -n "$1" | sed -n -e 's/.*\.//p' | wc -c
}
tenpow()
{
  echo -n "$1"
  seq "$2" | sed -e 's/.*/0/' | tr -d '\n'
}

commandhandler()
{
  chatmsg="$1"
  from="$2"
  potentialcmd="`echo "$chatmsg" | sed -e 's/ .*//'`"
  for commandbinding in ${chatcommands}; do
    chatcommand="`echo "$commandbinding" | sed -e 's/=.*//'`"
    if [ "x${potentialcmd}" = "x${chatcommand}" ]; then
      commandcallback="`echo "$commandbinding" | sed -e 's/.*=//'`"
      "$commandcallback" "$from" "`echo "$chatmsg" | sed -e 's/^[^ ]*//; s/^ //'`"
    fi
  done
}
addeventhandler chatmsg commandhandler

do_reload()
{
  # TODO: cleaner implementation of restriction/authorization so this can be called as a command
  # TODO: callbacks for modules to save and restore state cleanly (events done, need handlers)
  if ! sh -n "$0"; then echo "/priv ${from} Syntax error, won't reload"; continue; fi
  echo "$cammode" > relaybot.reload.cammode
  handleevent reload_before
  exec "$0" PIPE reload
}

logchat()
{
  msg="$1"
  from="$2"
  echo "${from}: ${msg}" >> "${DATADIR}/relaybot.chat"
}
addeventhandler chatmsg logchat

while true; do
  line=''
  if ! read -r line; then
    if [ ! -e relaybot.say ]; then break; fi
  fi
  if [ "x${line}" = "x" ]; then continue; fi
  echo "Got line '${line}'" >> "${DATADIR}/relaybot.log" # TODO: clean up references to this obsolete thing (camspammers module)
  handleline "$line"
done
