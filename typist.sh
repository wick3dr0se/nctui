#!/bin/bash

phrases=(
  'pigs can not fly but elephants can'
  'he carried the bananas in a cardboard box on his head'
  'suddenly the room filled with a deafening silence'
  'she let out a silent scream as the cat walked through the door carrying a dead bird'
  "you are clearly confused by the situation you've found yourself in"
)

random_phrase(){
  phrase="${phrases[RANDOM%5]}"
  printf '\e[999H\e7%s' "$phrase"
}

random_phrase
while read -srN1 char; do
  typedPhrase+="$char"
  if [[ $phrase =~ ^$typedPhrase ]]; then
    printf "\e8\e[32m$typedPhrase\e[m"
  else
    printf "\e[31m$char\e[m\n"; exit
  fi
done