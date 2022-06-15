#!/bin/bash

. "${0%/*}/phrases.sh"
phrase_count=${#phrase[@]}
phrase=${phrase[`echo $((RANDOM%phrase_count))`]}
printf '\e[40;1;37m%s\e[0m\n\n%s\e[0m\n\e[1A' \
	"Typer - Check your type speed & accuracy" "$phrase"

timeStart=`date +%s`

while read -srN1 typed_char ; do
	[[ $typed_char != . ]] && typed_phrase+=$typed_char &&
		if [[ $phrase =~ ^$typed_phrase ]] ; then
			characters=${#typed_phrase}
			printf '\e[1;32m%s\e[0m' "$typed_char"
			[[ $phrase == $typed_phrase ]] && type_status='pass' && break
		else
			type_status='fail'
			characters=$((characters+1))
			printf '\e[1;31m%s\e[0m' "$typed_char"
			break
		fi 
done

timeEnd=`date +%s`
timer=$((timeEnd-timeStart))
printf '\n[%s] %s characters typed in %s seconds' \
	"$type_status" "$characters" "$timer"
