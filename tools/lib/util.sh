#!/bin/bash
#
# SPDX-License-Identifier: MIT
# Copyright © 2022 Apolo Pena
#
# util.sh
#
# Description:
# Utility library
# 
# Note:
# Only share functions from this script that really need to be shared
# Avoid the 'god object' even though the 'utils' pattern this script uses encourages it ;)


### url_exists ###
# Description:
# Essentially a 'dry run' for curl. Returns 1 if the url ($1) is a 404. Returns 0 otherwise.
_url_exists() {
  [[ -z $1 ]] && echo "Internal error: No url argument" && return 1
  if ! curl --head --silent --fail "$1" &> /dev/null; then return 1; fi
}

### is_subpath ###
# Description:
# returns 0 if ($2) is a subpath of ($1), returns 1 otherwise
is_subpath() {
  if [[ $(realpath --relative-base="$1" -- "$2")  =~ ^/ ]]; then
    return 1
  else
    return 0
  fi
}

### split_ver ###
# Description:
# splits a version number ($1) into three numbers delimited by a space
#
# Notes:
# Assumes the format of the version number will be:
# <any # of digits>.<any # of digits>.<any # of digits>
#
# Usage:
# split_ver 6.31.140
# # outputs: 6 31 140 
split_ver() {
  local first mid last
  first=${1%%.*}; last=${1##*.}; mid=${1##$first.}; mid=${mid%%.$last}
  echo "$first $mid $last"
}


### comp_ver_lt ###
# Description:
# Compares version number ($1) to version number ($2)
# Echos 1 if version number ($1) is less than version number ($2)
# Echos 0 if version number ($1) is greater than or equal to version number ($2)
#
# Notes:
# Assumes the format of the version number will be:
# <any # of digits>.<any # of digits>.<any # of digits>
#
# Usage:
# comp_ver_lt 2.28.10 2.28.9
# # outputs: 1
# comp_ver_lt 0.0.1 0.0.0
# # outputs: 0
comp_ver_lt() {
  local v1=()
  local v2=()
  IFS=" " read -r -a v1 <<< "$(split_ver "$1")"
  IFS=" " read -r -a v2 <<< "$(split_ver "$2")"
  [[ ${v1[0]} -lt ${v2[0]} ]] && echo 1 && exit
  [[ ${v1[0]} -eq ${v2[0]} ]] && \
  [[ ${v1[1]} -lt ${v2[1]} ]] && echo 1 && exit
  [[ ${v1[0]} -eq ${v2[0]} ]] && \
  [[ ${v1[1]} -eq ${v2[1]} ]] && \
  [[ ${v1[2]} -lt ${v2[2]} ]] && echo 1 && exit
  echo 0
}

### gls_verion ###
# Description:
# Parses the first occurrence of a major.minor.patch version number from a file ($1)
gls_version() {
  local ver=
  ver="$(grep -oE "([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+)?" "$1" | head -n 1)"
  [[ -z $ver ]] && return 1
  echo "$ver"
  return 0
}