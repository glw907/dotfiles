#!/usr/bin/env bash
# run-fixtures.sh: prove the vendored Microsoft package resolves and fires. The
# fixture is wordy copy that must raise Microsoft.Wordiness; a miss means the
# Microsoft styles are not vendored under StylesPath. Vale exits non-zero
# whenever it finds alerts, so capture its output before grepping.
set -uo pipefail
cd "$(dirname "$0")"
fail=0

ms="fixtures/microsoft/copy.md"
ms_out="$(vale --config=microsoft.vale.ini --output=line "$ms")"
if ! grep -q 'Microsoft.Wordiness' <<<"$ms_out"; then
  echo "FAIL: $ms did not raise Microsoft.Wordiness; the Microsoft baseline may not be vendored"; fail=1
fi

[ "$fail" -eq 0 ] && echo "fixtures: OK" || echo "fixtures: FAILED"
exit "$fail"
