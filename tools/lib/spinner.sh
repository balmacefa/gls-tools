#!/bin/bash
# shellcheck disable=2034,2086,2059,2004

# Author: Tasos Latsas
# Modified and enhanced with spinner_task() by: Apolo Pena
# Original repository: https://github.com/tlatsas/bash-spinner

# spinner.sh
# Description:
# Display an awesome 'spinner' while running your long shell commands
#
# Notes:
# Do *NOT* call _spinner function directly.
# Use {start,stop}_spinner wrapper functions

# usage:
#   1. source this script in your's
#   2. start the spinner:
#       start_spinner [display-message-here]
#   3. run your command
#   4. stop the spinner:
#       stop_spinner [your command's exit status]


function _spinner() {
    # $1 start/stop
    #
    # on start: $2 display message
    # on stop : $2 process exit status
    #           $3 spinner function pid (supplied from stop_spinner)

    local on_success="DONE"
    local on_fail="FAIL"
    local white="\e[1;37m"
    local green="\e[1;32m"
    local red="\e[1;31m"
    local nc="\e[0m"
    local colors=("\e[38;5;22m" "\e[38;5;34m" "\e[38;5;40m" "\e[38;5;46m")

    case $1 in
        start)
            # calculate the column where spinner and status msg will be displayed
            #let column=$(tput cols)-${#2}-8
            # display message and position the cursor in $column column
            echo -ne ${2}
            echo -n '  '
            #printf "%${column}s"

            # start spinner
            i=1
            sp='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
            delay=${SPINNER_DELAY:-0.1}

            while :
            do
                #printf "\b${colors[$(($i % 4))]}${sp:i++%${#sp}:1}"; printf "\e[0m"
                printf "\b${sp:i++%${#sp}:1}"
                sleep $delay
            done
            ;;
        stop)
            if [[ -z ${3} ]]; then
                echo "spinner is not running.."
                sleep 3 && exit 1
            fi

            kill $3 > /dev/null 2>&1

            # inform the user upon success or failure
            if [[ -z $4 ]]; then
              echo -en "\b["
              if [[ $2 -eq 0 ]]; then
                  echo -en "${green}${on_success}${nc}"
              else
                  echo -en "${red}${on_fail}${nc}"
              fi
              echo -e "]"
            else
              echo -e "$4"
            fi
            ;;
        *)
            echo "invalid argument, try {start/stop}"
            exit 1
            ;;
    esac
}

function start_spinner {
    # $1 : msg to display
    _spinner "start" "${1}" &
    # set global spinner pid
    _sp_pid=$!
    disown
}

function stop_spinner {
    # $1 : command exit status
    # $2 : optional message to replace [DONE] results on success
    _spinner "stop" $1 $_sp_pid "$2"
    unset _sp_pid
}

function encode_spinner_msg() {
  echo "$1" | tr ' ' '@@@'
}

function decode_spinner_msg() {
  echo "$1" | tr '@@@' ' '
}

### spinner_task ###
# Description:
# Dynamically invokes function or command with the arguments passed to it via a sub-shell
# Uses a spinner to inform the user with a message, a progress ticker and the result (DONE or FAILED)
# ($1) The message the spinner will display as it is ticking
# ($2) The function or command that will be invoked
# ($3) Optional flag --show-error which removes redirection of stderr to /dev/null for the command ($2)
# $1 and $2 are shifted away so that the rest of the arguments passed to this function ($@)
# are passed on to the subshell
#
# Note:
# Returns 0 on success and returns 1 on failure
# Any occurrence of @@@ in a spinner message will be replaced with a single space character
function spinner_task() {
  local e_pre msg ec cmd show_error
  e_pre="Spinner task failed:"

  [[ -z $1 ]] && echo "$e_pre Missing message argument" && return 1
  [[ -z $2 ]] && echo "$e_pre Missing command argument" && return 1
  [[ $3 == '--show-error' ]] && show_error="$3"
  
  msg="$(encode_spinner_msg "$1")"
  cmd="$2";
   
  if [[ -n $show_error ]]; then 
    shift; shift; shift
    start_spinner "$(decode_spinner_msg "$msg") " && ( "$cmd" "$@" )
  else
    shift; shift
    start_spinner "$(decode_spinner_msg "$msg") " && ( "$cmd" "$@" 2> /dev/null )
  fi
  
  ec=$? && [[ $ec != 0 ]] && stop_spinner 1 && return 1

  stop_spinner 0
}