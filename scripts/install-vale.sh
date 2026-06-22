#!/usr/bin/env bash
# install-vale.sh: install a pinned Vale release binary into ~/.local/bin.
set -euo pipefail

VALE_VERSION="3.15.1"   # pin; bump deliberately
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) VALE_ARCH="64-bit" ;;
  aarch64|arm64) VALE_ARCH="arm64" ;;
  *) echo "unsupported arch: $ARCH" >&2; exit 1 ;;
esac

URL="https://github.com/errata-ai/vale/releases/download/v${VALE_VERSION}/vale_${VALE_VERSION}_Linux_${VALE_ARCH}.tar.gz"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Downloading Vale ${VALE_VERSION} ..."
curl -fsSL "$URL" -o "$TMP/vale.tar.gz"
tar -xzf "$TMP/vale.tar.gz" -C "$TMP" vale
install -m 0755 "$TMP/vale" "$HOME/.local/bin/vale"
echo "Installed: $("$HOME/.local/bin/vale" --version)"
