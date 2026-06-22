#!/usr/bin/env bash
# glw907-vendor.sh: vendor the canonical glw907 Vale style into a consumer repo,
# or check a repo's vendored copy for drift against the canonical source. The
# canonical home is the dotfiles repo; every other repo carries a committed copy
# so Vale runs the same rules in CI and on a fresh machine.
set -uo pipefail

canon="$HOME/.dotfiles/vale/.config/vale/styles/glw907"

usage() {
  echo "usage: glw907-vendor.sh <repo-root> [--sync]" >&2
  echo "  default: check the repo's vendored copy against the canonical style" >&2
  echo "  --sync:  overwrite the repo's copy from the canonical style" >&2
}

repo="${1:-}"
mode="${2:-check}"
[ -n "$repo" ] || { usage; exit 2; }
[ -d "$canon" ] || { echo "canonical style missing: $canon" >&2; exit 2; }

repo="${repo%/}"
dest="$repo/.vale/styles/glw907"

case "$mode" in
  --sync)
    if ! mkdir -p "$repo/.vale/styles"; then
      echo "sync failed: could not create $repo/.vale/styles" >&2
      exit 1
    fi
    if ! rm -rf "$dest"; then
      echo "sync failed: could not remove existing $dest" >&2
      exit 1
    fi
    if ! cp -r "$canon" "$dest"; then
      echo "sync failed: could not write $dest" >&2
      exit 1
    fi
    echo "vendored glw907 -> $dest"
    ;;
  check)
    if [ ! -d "$dest" ]; then
      echo "DRIFT: no vendored glw907 at $dest; run with --sync" >&2
      exit 1
    fi
    out="$(diff -r "$canon" "$dest")"
    rc=$?
    if [ "$rc" -eq 0 ]; then
      echo "glw907 vendored copy is in sync"
    else
      echo "DRIFT: $dest differs from $canon; run with --sync" >&2
      printf '%s\n' "$out" >&2
      exit 1
    fi
    ;;
  *)
    usage
    exit 2
    ;;
esac
