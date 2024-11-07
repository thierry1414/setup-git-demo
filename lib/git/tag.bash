if [ -n "$__LIB_GIT_TAG__" ]; then
  return
fi
readonly __LIB_GIT_TAG__=true

# checks if tag exists, returns 0 if so, otherwise non-zero
# usage: check_tag <tag>
check_tag() {
  git tag | grep "$1" >/dev/null 2>&1
}
