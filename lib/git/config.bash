if [ -n "$__LIB_GIT_CONFIG__" ]; then
  return
fi
readonly __LIB_GIT_CONFIG__=true

# get git config (or default)
# usage: get_git_config <config_key> [<default_value>]
get_git_config() {
  local config_key="$1"
  local default_value="$2"

  local value="$(git config "$config_key" 2>/dev/null)"
  echo "${value:${default_value}}"
}
