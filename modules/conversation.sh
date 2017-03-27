#!/bin/false
getspecies()
{
  if echo "$species" | grep -q "^${1}="; then
    echo "$species" | sed -n -e "s/^${1}=//p"
  else
    echo 'human'
  fi
}

conversation()
{
  chatmsg="$1"
  from="$2"

  if echo "$chatmsg" | grep -i -q '\(thx\|tha*nks*\|thanks* *y*o*u\)[,.]* *\(relay\|bots*\|relaybots*\)[!,.]*$'; then
    say "you're welcome `getspecies "$from"`"

  elif echo "$chatmsg" | grep -q '^ *good  *\(relay\|\)bot *$'; then
    say "good `getspecies "$from"`"

  elif echo "$chatmsg" | grep -i -q '^\(hee*yy*a*\|hii*\|hee*ll*oo*\)\(\| there\),*\(\| fellow\) \(homos\|homosexuals\|everyone*\|y*o*u *all\|y*o*u *guys\|everybody\|bots\|relaybot\|all\|yall\|y.all\|lesbos\|ladies\|friends\|girls\|gays\)\([ \.!,].*\|\)[ ~]*$'; then
    sayonce "Hey ${from}"

  elif echo "$chatmsg" | grep -i -q '^\(good *night\|good *nite\|g.night\|g.nite\|nights*\|night night\|nite nite\),* \(everyone*\|y*o*u *all\|y*o*u *guys\|everybody\|bots\|relaybot\|all\|yall\|y.all\|lesbos\|ladies\)\([ \.!,].*\|\)$'; then
    sayonce "Good night ${from}"

  elif echo "$chatmsg" | grep -i -q '^\(good *morning*\|good *morn\|g.morning*\|g.morn\|morning\),* \(everyone*\|y*o*u *all\|y*o*u *guys\|everybody\|bots\|relaybot\|all\|yall\|y.all\|lesbos\|ladies\)\([ \.!,].*\|\)$'; then
    sayonce "Good morning ${from}"

  elif echo "$chatmsg" | grep -i -q '^\(<3\|&lt;3\|I love\|I love you\|I luv\|I luv u\),* \(everyone*\|y*o*u *all\|y*o*u *guys\|everybody\|bots\|relaybot\|yall\|y.all\)\([ \.!,].*\|\)$' || echo "$chatmsg" | grep -i -x -q ' *relaybot[:,]* *\(<3\|I love you\) *'; then
    sayonce "<3 ${from}"

  elif (echo "$chatmsg" | grep -i -q '\(relay\|\)bots*\b' && echo "$chatmsg" | grep -i -q '^\(.* \|\)how old ') || echo "$chatmsg" | grep -i -q "^\(\|.* \)how old \(is\|are\) \(everyone*\|y*o*u *all\|y*o*u *guys\|y'*all\)"; then
    sec="`date +%s`"
    sec="`expr "$sec" - 1429999200`"
    weeks="`expr "$sec" / 60 / 60 / 24 / 7`"
    say "${weeks} weeks" # TODO: Count years and months instead?

  else
    return 1
  fi
  return 0
}

addeventhandler chatmsg conversation
