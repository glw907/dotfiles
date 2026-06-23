#!/usr/bin/env bash
# check-py-comments.sh: the Python comment gate for the dotfiles repo. Runs ruff's D (docstring)
# rules and Vale's lexical net over the repo's Python. ruff lints every tracked .py file and every
# extensionless bin script with a python shebang (passed by explicit path, which ruff accepts
# regardless of extension). Vale's py = md scope reaches .py files only, so the extensionless bin
# scripts get the ruff layer but not the Vale lexical pass; that is a known limit of Vale's
# extension-keyed format detection, documented in the Python comment-arm plan.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

fail=0

# Tracked .py files, and extensionless bin scripts whose first line names python.
mapfile -t py_files < <(git ls-files -- '*.py')
bin_py=()
for f in bin/.local/bin/*; do
  [ -f "$f" ] || continue
  case "$f" in *.py) continue ;; esac   # .py already covered by py_files
  if head -1 "$f" | grep -qi 'python'; then bin_py+=("$f"); fi
done

echo "== ruff D (docstring) rules =="
if (( ${#py_files[@]} + ${#bin_py[@]} > 0 )); then
  ruff check "${py_files[@]}" "${bin_py[@]}" || fail=1
else
  echo "(no Python files)"
fi

echo "== vale on .py comment and docstring prose =="
if (( ${#py_files[@]} > 0 )); then
  vale --minAlertLevel=error "${py_files[@]}" || fail=1
else
  echo "(no .py files)"
fi

if [ "$fail" -eq 0 ]; then echo "check:py-comments OK"; else echo "check:py-comments FAILED"; fi
exit "$fail"
