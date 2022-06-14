#!/bin/bash

. ./phrases.sh
phrase_count=${#phrase[@]}
phrase=${phrase[`echo $((RANDOM%phrase_count))`]}
printf '\t\e[40;1;37m%s\e[0m\n\e[1m%s\e[0m\n' \
	"Typer - Type the phrase below as quick as possible" "$phrase"

timeStart=`date +%s`

while read -reN1 typed_char ; do
	echo
	typed_phrase+=$typed_char
	if [[ $phrase =~ ^$typed_phrase ]] ; then
		characters=${#typed_phrase}
		printf '\e[1A\r\e[K\e[1;32m%s\e[0m' "$typed_phrase"
		[[ $phrase == $typed_phrase ]] && {
			type_status='pass'
			break
		}
	else
		type_status='fail'
		characters=$((characters+1))
		printf '\e[1A\e[1;32m%s\e[1;31m%s\e[0m' \
			"${typed_phrase::-1}" "$typed_char"
		break
	fi
done 2>/dev/null

timeEnd=`date +%s`
timer=$((timeEnd-timeStart))
printf '\n[%s] %s characters typed in %s seconds' \
	"$type_status" "$characters" "$timer"
