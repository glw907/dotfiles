#!/usr/bin/env bash
set -euo pipefail

# Bluefin DX (stable) bootstrap for thinkpad-x1, and for the second
# workstation this same directory provisions later.
#
# Decisions and facts referenced here come from MIGRATION-BRIEF.md, in this
# same directory. Read it before changing this script.
#
# Usage:
#   bootstrap.sh layer   # run once, right after first boot
#   bootstrap.sh setup   # run once, right after the reboot from `layer`
#
# Uses plain `sudo`, not the `sudo -A` / claude-askpass flow: that flow
# depends on the `bin` stow package and ~/.local/secrets, neither of which
# exist yet at this point in a fresh install. Run this script interactively
# so sudo can prompt for the password directly.

BLUEFIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$BLUEFIN_DIR")"

# Reads a list file, dropping comment and blank lines.
read_list() {
    grep -vE '^[[:space:]]*(#|$)' "$1"
}

phase_layer() {
    echo "== layer: 1Password repo =="
    sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
    sudo tee /etc/yum.repos.d/1password.repo > /dev/null <<'EOF'
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey="https://downloads.1password.com/linux/keys/1password.asc"
EOF

    echo "== layer: rpm-ostree install =="
    local list="$BLUEFIN_DIR/layered-packages.txt"
    if [[ ! -f "$list" ]]; then
        echo "layered-packages.txt not found in $BLUEFIN_DIR, nothing to layer" >&2
        exit 1
    fi
    local pkgs=()
    mapfile -t pkgs < <(read_list "$list")
    if [[ ${#pkgs[@]} -eq 0 ]]; then
        echo "layered-packages.txt is empty, nothing to layer" >&2
        exit 1
    fi
    sudo rpm-ostree install --idempotent "${pkgs[@]}"

    echo
    echo "Layering staged. Reboot, then run:"
    echo "  $0 setup"
}

setup_etc_drops() {
    echo "== setup: /etc drops =="

    sudo mkdir -p /etc/chromium/policies/managed
    shopt -s nullglob
    local policies=("$BLUEFIN_DIR"/etc/chromium-policies/*.json)
    shopt -u nullglob
    if [[ ${#policies[@]} -eq 0 ]]; then
        echo "no chromium policy files found in $BLUEFIN_DIR/etc/chromium-policies, skipping" >&2
    else
        sudo install -m 0644 "${policies[@]}" /etc/chromium/policies/managed/
    fi

    sudo install -m 0644 "$BLUEFIN_DIR/etc/udev/51-android.rules" \
        /etc/udev/rules.d/51-android.rules
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    # The rule grants uaccess via udev TAG+="uaccess" for known Android
    # vendor IDs; no group membership or relogin needed.
}

setup_dx_group() {
    echo "== setup: ujust dx-group =="
    ujust dx-group
}

setup_flatpaks() {
    echo "== setup: flatpak install =="
    local apps=()
    mapfile -t apps < <(read_list "$BLUEFIN_DIR/flatpaks.txt")
    flatpak install --or-update -y flathub "${apps[@]}"
}

setup_brew() {
    echo "== setup: brew bundle =="
    if ! command -v brew > /dev/null 2>&1; then
        # Bluefin DX ships Homebrew preinstalled; this is a fallback in case
        # that isn't true for this image build. Verify on first boot.
        echo "brew not on PATH, installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c \
            "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    eval "$(brew shellenv)"
    brew bundle --file="$BLUEFIN_DIR/Brewfile"
}

setup_mise_uv() {
    echo "== setup: mise + uv tool installs =="
    eval "$(mise activate bash)"
    mise use --global node@lts

    # khard, vdirsyncer, yt-dlp are Python tools per the brief; installed via
    # uv rather than Homebrew.
    uv tool install khard
    uv tool install vdirsyncer
    uv tool install yt-dlp
}

setup_stow() {
    echo "== setup: stow dotfiles packages =="
    (cd "$DOTFILES_DIR" && stow -R bash bin claude git kitty contacts)
}

setup_kitty() {
    echo "== setup: kitty upstream installer =="
    local kitty_bin="$HOME/.local/kitty.app/bin/kitty"
    if [[ -x "$kitty_bin" ]]; then
        echo "kitty already installed, skipping"
        return
    fi
    # Verify on first boot: confirm this URL still serves the installer script.
    curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    if [[ ! -x "$kitty_bin" ]]; then
        echo "kitty install failed: $kitty_bin not found" >&2
        return 1
    fi
}

setup_claude_code() {
    echo "== setup: Claude Code native installer =="
    local claude_bin="$HOME/.local/bin/claude"
    # Verify on first boot: confirm this URL still serves the installer script.
    curl -fsSL https://claude.ai/install.sh | bash
    if [[ ! -x "$claude_bin" ]]; then
        echo "Claude Code install failed: $claude_bin not found" >&2
        return 1
    fi
}

setup_syncthing() {
    echo "== setup: syncthing user service =="
    brew services start syncthing
}

print_checklist() {
    cat <<'EOF'

== Post-setup verification checklist ==

1Password (brief: known GID mismatch gotcha on ostree):
  - Open 1Password desktop, confirm it unlocks.
  - Confirm `op whoami` works from a terminal.
  - Confirm the browser extension (Firefox and Chromium) connects to the
    desktop app. If it does not: this is the documented helper-tool GID
    mismatch on ostree. Fix script: gist b-/ed2cdc182ae5a92bdcd6b73308832a70.

SELinux (brief: skipping this is a documented cause of broken logins):
  - After restoring anything into /var/home, run:
      sudo restorecon -R -v /var/home/glw907

Browsers:
  - chrome://policy in Chromium shows the three managed policies applied.
  - Firefox 1Password integration connects (needs the RPM build, not flatpak).

Android:
  - `adb devices` sees a plugged-in device (uaccess tagging applies
    immediately on replug, no login required).

Homebrew / mise / uv:
  - `brew doctor`
  - `mise doctor`
  - `uv tool list` shows khard, vdirsyncer, yt-dlp

Dotfiles:
  - `stow -n bash bin claude git kitty contacts` reports no conflicts
    (already stowed by this script; -n dry-runs to confirm).

kitty, Claude Code, syncthing:
  - `kitty --version`
  - `claude --version`
  - syncthing web UI reachable at http://127.0.0.1:8384

Next: selective restore from the encrypted backup. See MIGRATION-RUNBOOK.md.
EOF
}

phase_setup() {
    local steps=(
        setup_etc_drops
        setup_dx_group
        setup_flatpaks
        setup_brew
        setup_mise_uv
        setup_stow
        setup_kitty
        setup_claude_code
        setup_syncthing
    )
    local failed=()
    local step
    for step in "${steps[@]}"; do
        if ! "$step"; then
            echo "FAILED: $step" >&2
            failed+=("$step")
        fi
    done

    print_checklist

    if [[ ${#failed[@]} -gt 0 ]]; then
        echo >&2
        echo "phase_setup: ${#failed[@]} step(s) failed: ${failed[*]}" >&2
        exit 1
    fi
}

case "${1:-}" in
    layer)
        phase_layer
        ;;
    setup)
        phase_setup
        ;;
    *)
        echo "Usage: $0 {layer|setup}" >&2
        exit 1
        ;;
esac
