if [ -n "$__LIB_GIT_REVISION__" ]; then
  return
fi
readonly __LIB_GIT_REVISION__=true

# echoes the commit hash of the speficied revision
# usage: resolve_revision <revision>
resolve_revision() {
  echo "$(git show -s --pretty="%H" "$1" 2>/dev/null)"
}

# checks if revision exists, returns 0 if so, otherwise non-zero
# usage: revision_exists <revision>
revision_exists() {
  git show -s --pretty="%H" "$1" >/dev/null 2>&1
}
