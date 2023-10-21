#!/bin/bash
# netconnect

# get bashin (ncurses alternative)
(( BASHIN ))&&{
  read -rp 'Install Bashin: A lightweight TUI framework? [y/N]: '
  if [[ ${REPLY} =~ y(es)? ]]; then
    bash <(curl -s https://raw.githubusercontent.com/wick3dr0se/bashin/main/setup.sh)
  else
    exit 1
  fi
}

import std/{ansi,tui}

trap init_term WINCH
trap deinit_term EXIT
trap 'exit 1' INT

ethernet=0

_msg(){
  buffer_main
  color="${2:-green}"
  sgr_writeline fg:"$color" "${BASH_SOURCE[0]##*/}" '-' fg:"$color" "${FUNCNAME[1]} " "$1"
}

init_term(){
  get_term_size
  ((LINES=ROWS-1))
  cursor="$LINES"
  
  buffer_alt
  cursor_pos 1 "$ROWS"
  cursor_hide
}

deinit_term(){
  buffer_main
  cursor_show
}

status_bar(){
  cursor_pos 1 "$ROWS"
  erase_row
  sgr_write fg:green "$networkingTool" "${@:+: $*}"
}

hover_networks(){
  hover="${STACK[$1-ROWS]}"
  cursor_pos 1 "$1"
  sgr_write mode:inverse "$hover"

  hoverHist+=("${1}H$hover")
  skip&&{
    printf '\e[%s' "${hoverHist[0]}"
    hoverHist=("${hoverHist[@]:1}")
  }; :
}

scroll_networks(){
  if (( cursor > LINES )); then
    ((cursor=ROWS-${#STACK[@]}))
  elif (( cursor < ROWS-${#STACK[@]} )); then
    cursor="$LINES"
  fi
}

draw_networks(){
  unset SKIP hoverHist

  erase_screen
  cursor_pos 1 "$LINES"
  printf '%s\n' "${STACK[@]}"
}

if ip link show etho0 2>/dev/null; then
  ethernet=1
elif hash iwctl 2>/dev/null; then
  networkingTool='iwd'

  wireless_scan(){
    status_bar 'Scanning for wireless networks..'

    iwctl station wlan0 scan
    
    while read -rd ' ' line; do
      skip 4&&{
        [[ $line == '' ]]||{
          if [[ $line =~ psk|802|\* ]]; then
            unset wirelessNetwork
          else
            [[ $wirelessNetwork ]]&& STACK=("${STACK[@]:1}")
            wirelessNetwork+="$line "
            push "${wirelessNetwork% }"
          fi
        }
      }
    done < <(iwctl station wlan0 get-networks | tail -n +5)

    draw_networks
  }

  wireless_connect(){
    iwctl station wlan0 connect "$hover" --passphrase "${REPLY-}" &>/dev/null
  }

  is_connected(){
    iwctl station wlan0 show | awk '/Connected net/{print $3}'
  }
elif hash nmcli 2>/dev/null; then
  networkingTool='networkmanager'

  wireless_scan(){
    status_bar 'Scanning for wireless networks..'

    ip link show eth0 2>/dev/null||{
      while read line; do
        [[ $line == ''|| ${STACK[@]} =~ $line ]]|| push "$line"
      done < <(nmcli -c=no -t -f SSID device wifi list)

      draw_networks
    }
  }

  wireless_connect(){
    nmcli device wifi connect "$hover" password "${REPLY-}" &>/dev/null
  }

  is_connected(){
    nmcli -c=no -t -f ssid,active dev wifi | awk -F':' '/yes/{printf $1}'
  }
fi

main(){
  for((;;)){
    hover_networks "$cursor"

    status_bar
  
    read_keys
    case $KEY in
      [qQ]|A|H|\[D) return 1;;
      S|J|\[B) ((cursor++));;
      W|K|\[A) ((cursor--));;
      D|L|\[C)
        (( ethernet))&&{
          _msg 'Already connected to ethernet!'
          return
        }

        if [[ $(is_connected) == "$hover" ]]; then
          _msg "Already connected to $hover!"
          return
        fi

        cursor_show
        status_bar 'Passphrase: '
        read -rs
  
        if wireless_connect; then
          _msg "Sucessfully connected to $hover"
          return
        else
          _msg "Failed connecting to $hover" red >&2
          return 1
        fi
      ;;
    esac

    scroll_networks
  }
}

init_term
wireless_scan
main