#!/usr/bin/env bash
set -uo pipefail

# scripts/check.sh: the one gate for this repo. A pass, a pre-push, or a
# "did I break anything" moment runs this and nothing else; green here is
# what "the gate passed" means. Individual checks stay runnable on their own.

# Keep bytecode caches out of the stow packages; stow would link them into
# $HOME (it happened; see docs/HISTORY.md 2026-08-30).
export PYTHONDONTWRITEBYTECODE=1

cd "$(dirname "$0")/.."
fail=0

run() {
    echo ""
    echo "== $1 =="
    shift
    if ! "$@"; then
        echo "FAILED: $*" >&2
        fail=1
    fi
}

check_bash_syntax() {
    local f ok=0
    while IFS= read -r f; do
        if head -1 "$f" | grep -q 'bash'; then
            bash -n "$f" || ok=1
        fi
    done < <(git ls-files '*.sh' 'bin/.local/bin/*' 'scripts/githooks/*')
    return "$ok"
}

run "bash -n over tracked shell scripts" check_bash_syntax
run "ruff docstring rules (python)" bash scripts/check-py-comments.sh
run "vale-hook test suite" uv run --with pytest --no-project python -m pytest tests/ -q
run "vale style fixtures" bash tests/vale/run-fixtures.sh
run "gitleaks working-tree scan" gitleaks dir . --no-banner --redact

echo ""
if [[ "$fail" -eq 0 ]]; then
    echo "GATE: all checks passed"
else
    echo "GATE: FAILED (see above)" >&2
fi
exit "$fail"
