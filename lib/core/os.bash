# Git Tools. A set of custom Git commands that might come in handy for certain tasks.
#
# Copyright (C) 2025 Isik Erhan
#
# This file is part of Git Tools.
#
# Git Tools is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Git Tools is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Git Tools.  If not, see <https://www.gnu.org/licenses/>.

if [ -n "$__LIB_CORE_OS__" ]; then
  return
fi
readonly __LIB_CORE_OS__=true

# check if current platform is MinGW
# usage: is_mingw
is_mingw() {
  [[ "$(uname -s)" == "MINGW"* ]]
}

# check if current platform is Cygwin
# usage: is_cygwin
is_cygwin() {
  [[ "$(uname -s)" == "CYGWIN"* ]]
}

# check if the given value refers to an open file descriptor
# usage: is_open_fd possible_fd
is_open_fd() {
  command >&"$1"
}

# allocate new file descriptor dynamically
# usage: alloc_new_fd target out_param
# note: the value of out_param must not be "__fd__", as this name is used internally.
alloc_new_fd() {
  local __fd__

  if is_open_fd "$1"; then
    exec {__fd__}>&"$1" 2>/dev/null
  else
    exec {__fd__}>"$1" 2>/dev/null
  fi

  if [ $? -eq 0 ]; then
    eval "$2=\"$__fd__\""
    return
  fi

  # fallback implementation for Bash versions prior to 4.1
  for i in $(seq 10 100); do
    if ! (: <&$i) 2>/dev/null && ! (: >&$i) 2>/dev/null; then
      eval "exec $i>&" 2>/dev/null

      if is_open_fd "$1"; then
        eval "exec $i>&$1" 2>/dev/null
      else
        eval "exec $i>$1" 2>/dev/null
      fi

      if [ $? -eq 0 ]; then
        __fd__=$i
        break
      fi
    fi
  done

  eval "$2=\"$__fd__\""
}

# create temporary output for writing which is redirected to the given target
# and return the file descriptor or file name
# usage: create_temporary_output target out_param
# note: the value of out_param must not be "__out__", as this name is used internally.
create_temporary_output() {
  local __out__

  if is_mingw || is_cygwin; then
    __out__="$(mktemp -d)/fifo"
    mkfifo -m 0600 "$__out__"

    if is_open_fd "$1"; then
      cat "$__out__" >&"$1" &
    else
      cat "$__out__" >"$1" &
    fi
  else
    alloc_new_fd __out__ "$1"
  fi

  eval "$2=\"$__out__\""
}

# close temporary output
# usage: close_temporary_output out
close_temporary_output() {
  local out="$1"

  if is_mingw || is_cygwin; then
    rm "$out"
  else
    exec {out}>&-
  fi
}
