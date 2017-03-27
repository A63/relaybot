#!/bin/sh
if [ "x${protocol}" != "xtc_client" ]; then echo 'WARNING: the camface module is unlikely to make sense on other protocols than tinychat/tc_client' >&2; fi
camface()
{
  if toggle_cammode face; then
    "${EXECDIR}/camutil" \
"${EXECDIR}/relaybotface/relaybot1.png" \
"${EXECDIR}/relaybotface/relaybot1.png" \
"${EXECDIR}/relaybotface/relaybot2.png" \
"${EXECDIR}/relaybotface/relaybot2.png" \
"${EXECDIR}/relaybotface/relaybot3.png" \
"${EXECDIR}/relaybotface/relaybot3.png" \
"${EXECDIR}/relaybotface/relaybot4.png" \
"${EXECDIR}/relaybotface/relaybot4.png" \
"${EXECDIR}/relaybotface/relaybot4.png" \
"${EXECDIR}/relaybotface/relaybot4.png" \
"${EXECDIR}/relaybotface/relaybot3.png" \
"${EXECDIR}/relaybotface/relaybot3.png" \
"${EXECDIR}/relaybotface/relaybot2.png" \
"${EXECDIR}/relaybotface/relaybot2.png" \
"${EXECDIR}/relaybotface/relaybot1.png" \
"${EXECDIR}/relaybotface/relaybot1.png" &
  fi
}

addcmd '!cam' camface
