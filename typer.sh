#!/bin/bash

. "${0%/*}/phrases.sh"
phrase_count=${#phrase[@]}
phrase=${phrase[`echo $((RANDOM%phrase_count))`]}
printf '%s\n\n' "Typer - Check your type speed & accuracy"
printf '\e[40;1;37m%s\e[0m\r\e[?7l' "$phrase"

timeStart=`date +%s`

while read -erN1 typed_char ; do
	[[ $typed_char != . ]] && typed_phrase+=$typed_char &&
		if [[ $phrase =~ ^$typed_phrase ]] ; then
			typed_count=${#typed_phrase}
			printf '\e[42;1;30m%s\e[0m' "$typed_char"
			[[ $phrase == $typed_phrase ]] && type_status='pass' && break
		else
			type_status='fail'
			typed_count=$((typed_count+1))
			printf '\e[41;1;30m%s\e[0m' "$typed_char"
			break
		fi 
done 2>/dev/null

timeEnd=`date +%s`
timer=$((timeEnd-timeStart))
printf '\n[%s] %s characters typed in %s seconds\n' \
	"$type_status" "$typed_count" "$timer"
