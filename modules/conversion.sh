#!/bin/sh
conversion_get_feet="s/'.*//;s/.*\"//"
conversion_get_inch="s/\".*//;s/.*'//"
imperial_to_metric()
{
  input="$2"
  if ! echo "$input" | grep -q "['\"]"; then input="${input}\""; fi
  feet="`echo "$input" | sed -e "$conversion_get_feet"`"
  inches="`echo "$input" | sed -e "$conversion_get_inch"`"
  if [ "x${feet}" = "x" ]; then feet=0; fi
  if [ "x${inches}" = "x" ]; then inches=0; fi
  decimals="`countdecimals "$inches"`"
  inches="`echo "$inches" | sed -e 's/\.//'`"
  feet="`tenpow "$feet" "$decimals"`"
  inches="`expr "$feet" '*' 12 + "$inches"`"
  decimals="`expr "$decimals" + 2`"
  centimeters="`expr "$inches" '*' 254`"
  centimeters="`decimals "$centimeters" "$decimals"`"
  if [ "x${centimeters}" = "x" ]; then return; fi
  say "${centimeters} cm"
}

metric_to_imperial()
{
  input="`echo "$2" | tr -d '[:alpha:]'`"
  decimals="`countdecimals "$input"`"
  input="`echo "$input" | sed -e 's/\.//'`"
  if echo "$2" | grep -i -q '[0-9]km$'; then
    input="${input}00000"
  elif echo "$2" | grep -i -q '[0-9]m$'; then
    input="${input}00"
  fi
  inch="`tenpow 254 "$decimals"`"
  inches="`expr "$input" '*' 100000 / "$inch"`"
  if [ "x${inches}" = "x" ]; then return; fi
  feet="`expr "$inches" '/' 12000`"
  inches="`expr "$inches" '%' 12000`"
  inches="`decimals "$inches" 3`"
  say "${feet}'${inches}\""
}

celsius_to_fahrenheit()
{
  c="`echo "$2" | sed -e 's|[/ .]||g'`"
  decimals="`echo "$2" | sed -n -e 's/^.*\.//p' | tr -d '\r\n' | wc -c`"
  dec='.'
  for x in `seq "$decimals"`; do dec="${dec}."; done
  zero="`echo "$dec" | tr . 0`"
  expr "$c" '*' 90 / 5 + "32${zero}" | sed -e "s/${dec}$/\.&°F/" | sayx
}

fahrenheit_to_celsius()
{
  f="`echo "$2" | sed -e 's|[/ .]||g'`"
  decimals="`echo "$2" | sed -n -e 's/^.*\.//p' | tr -d '\r\n' | wc -c`"
  dec=''
  for x in `seq "$decimals"`; do dec="${dec}."; done
  zero="`echo "$dec" | tr . 0`"
  expr '(' "$f" - "32${zero}" ')' '*' 50 / 9 | sed -e "s/${dec}.$/\\.&°C/" | sayx
}

gallons_to_liters()
{
  g="`echo "$2" | sed -e 's|[/ .]||g'`"
  expr "$g" '*' 379 | sed -e 's/..$/\.& liters/' | sayx
}

lbs_to_kg()
{
  decimals="`countdecimals "$2"`"
  lbs="`echo "$2" | sed -e 's|[/ .]||g'`"
  decimals="`expr "$decimals" + 5`"
  kg="`expr "$lbs" '*' 45359`"
  kg="`decimals "$kg" "$decimals"`"
  say "${kg} kg"
}

kg_to_lbs()
{
  decimals="`countdecimals "$2"`"
  kg="`echo "$2" | sed -e 's|[/ .]||g'`"
  decimals="`expr "$decimals" + 5`"
  lbs="`expr "$kg" '*' 220462`"
  lbs="`decimals "$lbs" "$decimals"`"
  say "${lbs} lbs"
}

addcmd '!imperial' metric_to_imperial
addcmd '!metric' imperial_to_metric
addcmd '!f' celsius_to_fahrenheit
addcmd '!F' celsius_to_fahrenheit
addcmd '!c' fahrenheit_to_celsius
addcmd '!C' fahrenheit_to_celsius
addcmd '!l' gallons_to_liters
addcmd '!L' gallons_to_liters
addcmd '!kg' lbs_to_kg
addcmd '!lbs' kg_to_lbs
