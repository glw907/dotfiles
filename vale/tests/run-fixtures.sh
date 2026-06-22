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

# Comment scope: the rule fires on comment text and ignores code tokens. The
# comment (line 3) carries Slop tokens; the code line (line 4) carries a Judgment
# token as the func name, so a leak would raise on x.go:4.
cs="fixtures/comment-scope/x.go"
cs_out="$(vale --config=comment-scope.vale.ini --output=line "$cs")"
if ! grep -q 'glw907.Slop' <<<"$cs_out"; then
  echo "FAIL: $cs did not raise glw907.Slop on its comment"; fail=1
fi
if grep -q 'x.go:4:' <<<"$cs_out"; then
  echo "FAIL: $cs raised on the code line, comment scope leaked"; fail=1
fi

[ "$fail" -eq 0 ] && echo "fixtures: OK" || echo "fixtures: FAILED"
exit "$fail"
