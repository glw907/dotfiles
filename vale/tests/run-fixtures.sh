#!/usr/bin/env bash
# run-fixtures.sh: a *.bad.* fixture must raise its named glw907 rule; a
# *.good.* fixture must raise nothing. Vale exits non-zero whenever it finds
# alerts, so capture its output before grepping; piping into grep under
# pipefail would surface Vale's exit, not the grep result.
set -uo pipefail
cd "$(dirname "$0")"
fail=0

for bad in fixtures/*.bad.*; do
  [ -e "$bad" ] || continue
  rule="glw907.$(basename "$bad" | cut -d. -f1)"
  out="$(vale --output=JSON "$bad")"
  if ! grep -q "\"$rule\"" <<<"$out"; then
    echo "FAIL: $bad did not raise $rule"; fail=1
  fi
done

for good in fixtures/*.good.*; do
  [ -e "$good" ] || continue
  out="$(vale --output=JSON "$good")"
  n="$(grep -c '"Check"' <<<"$out" || true)"
  if [ "$n" -ne 0 ]; then
    echo "FAIL: $good raised $n alert(s) but should be clean:"
    vale --output=line "$good"
    fail=1
  fi
done

[ "$fail" -eq 0 ] && echo "fixtures: OK" || echo "fixtures: FAILED"
exit "$fail"
