#!/usr/bin/env bash
set -euo pipefail

# Bluefin DX (stable) bootstrap for thinkpad-x1, and for the second
# workstation this same directory provisions later.
#
# Decisions and facts referenced here come from MIGRATION-BRIEF.md, in this
# same directory. Read it before changing this script.
#
# Usage:
#   bootstrap.sh layer     # run once, right after first boot
#   bootstrap.sh setup     # run once, right after the reboot from `layer`
#   bootstrap.sh restore   # run once, after `setup` and the 1Password CLI
#                          # toggle; executes MIGRATION-RUNBOOK.md section 4
#
# Uses plain `sudo`, not the `sudo -A` / claude-askpass flow: that flow
# depends on the `bin` stow package and ~/.local/secrets, neither of which
# exist yet at this point in a fresh install. Run this script interactively
# so sudo can prompt for the password directly.

BLUEFIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$BLUEFIN_DIR")"

# Shared between setup_stow and restore_place_home, which both pre-create
# these dirs (to keep stow from folding them) and then run the same stow.
STOW_PACKAGES=(bash bin claude git kitty contacts)
STOW_SHARED_DIRS=("$HOME/.local/bin" "$HOME/.claude" "$HOME/.config/khard" \
    "$HOME/.config/systemd/user")

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
    # Pre-create the target dirs that other things also write into, so stow
    # symlinks per file instead of folding the whole dir into a repo symlink
    # (a fold would make later installs write inside ~/.dotfiles).
    mkdir -p "${STOW_SHARED_DIRS[@]}"
    (cd "$DOTFILES_DIR" && stow -R "${STOW_PACKAGES[@]}")
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

Next: in 1Password, sign in and enable Settings -> Developer -> "Integrate
with 1Password CLI" (GUI-only toggle), then run:

  ~/.dotfiles/bluefin/bootstrap.sh restore

It executes MIGRATION-RUNBOOK.md section 4 with the same hard stops.
EOF
}

# --- restore phase -----------------------------------------------------------
# Executes MIGRATION-RUNBOOK.md section 4 (Restore) step for step. The runbook
# section is the specification and the manual fallback; keep the two in sync.
# Fail-fast and rerunnable: completed steps detect their own state and skip.

RESTORE_STAGING="$HOME/restore-staging"
AGE_KEY_CACHE="/dev/shm/.age-key-$UID"
BACKUP_SHA256="db0c2c041d2587ac300421734e4d4f32f436832242d385f20cc913aee0a0dbe1"
AGE_PUBKEY="age197mcd2m3z90t49n9t5v3ujjntw7krfkw5y9sjfc545v28qvezugshg7jgk"

# True once the tarball has been decrypted and extracted (manifest.txt is the
# last thing restore_extract writes), used by restore_reassemble,
# restore_verify_checksum, and restore_extract to skip work already done.
restore_staging_extracted() {
    [[ -f "$RESTORE_STAGING/manifest.txt" ]]
}

restore_preflight() {
    echo "== restore: preflight =="
    local missing=()
    local cmd
    for cmd in npx op age stow rsync git; do
        command -v "$cmd" > /dev/null 2>&1 || missing+=("$cmd")
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "missing commands: ${missing[*]} (run 'bootstrap.sh setup' first)" >&2
        return 1
    fi
}

# Runbook 4.1: one op call, cached in tmpfs. sync.sh reads the same cache, so
# the secrets step below makes no additional op call.
restore_fetch_key() {
    echo "== restore: age identity from 1Password =="
    if [[ -s "$AGE_KEY_CACHE" ]]; then
        echo "key already cached, skipping op call"
    else
        op item get "Workstation age encryption key" --fields notesPlain --reveal \
            | sed 's/^"//;s/"$//' > "$AGE_KEY_CACHE"
        chmod 600 "$AGE_KEY_CACHE"
    fi
    local pubkey
    pubkey="$(age-keygen -y "$AGE_KEY_CACHE")"
    if [[ "$pubkey" != "$AGE_PUBKEY" ]]; then
        echo "age public key mismatch: got $pubkey" >&2
        shred -u "$AGE_KEY_CACHE"
        return 1
    fi
}

# Runbook 4.2.
restore_secrets() {
    echo "== restore: local secrets from the age store =="
    "$DOTFILES_DIR/scripts/secrets/sync.sh" --local
    # shellcheck disable=SC1091
    source "$HOME/.local/secrets"
}

# Runbook 4.3. Existing non-empty chunk files are kept, so a rerun resumes
# rather than refetching.
restore_reassemble() {
    echo "== restore: reassemble tarball from R2 =="
    if restore_staging_extracted; then
        echo "staging already extracted, skipping"
        return
    fi
    if [[ -s "$RESTORE_STAGING/pre-bluefin-backup.tar.age" ]]; then
        echo "tarball already assembled, skipping"
        return
    fi
    mkdir -p "$RESTORE_STAGING"
    export CLOUDFLARE_ACCOUNT_ID=120c269ad6d3dfbe6d63a0bb53758ca0
    local suffixes=(aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at)
    local s key
    for s in "${suffixes[@]}"; do
        key="pre-bluefin/chunk-$s"
        if [[ -s "$RESTORE_STAGING/chunk-$s" ]]; then
            echo "chunk-$s already present"
            continue
        fi
        if ! npx -y wrangler r2 object get --remote "workstation-backup/$key" \
                --file "$RESTORE_STAGING/chunk-$s" 2> /dev/null; then
            rm -f "$RESTORE_STAGING/chunk-$s"
            break
        fi
        echo "fetched chunk-$s"
    done
    local chunks=("$RESTORE_STAGING"/chunk-*)
    echo "fetched ${#chunks[@]} chunks"
    cat "${chunks[@]}" > "$RESTORE_STAGING/pre-bluefin-backup.tar.age"
    rm -f "${chunks[@]}"
}

# Runbook 4.4: hard stop. Do not decrypt an unverified blob.
restore_verify_checksum() {
    echo "== restore: verify backup checksum =="
    if restore_staging_extracted; then
        echo "staging already extracted, skipping"
        return
    fi
    local sum
    sum="$(sha256sum "$RESTORE_STAGING/pre-bluefin-backup.tar.age" | cut -d' ' -f1)"
    if [[ "$sum" != "$BACKUP_SHA256" ]]; then
        echo "HARD STOP: checksum mismatch: got $sum" >&2
        echo "expected:  $BACKUP_SHA256" >&2
        return 1
    fi
    echo "checksum matches the recorded value"
}

# Runbook 4.5.
restore_extract() {
    echo "== restore: decrypt and extract =="
    if restore_staging_extracted; then
        echo "staging already extracted, skipping"
        return
    fi
    age -d -i "$AGE_KEY_CACHE" "$RESTORE_STAGING/pre-bluefin-backup.tar.age" \
        | tar -x -C "$RESTORE_STAGING"
    rm -f "$RESTORE_STAGING/pre-bluefin-backup.tar.age"
    echo "--- manifest ---"
    cat "$RESTORE_STAGING/manifest.txt"
}

# Runbook 4.6: additive, never destructive. --ignore-existing everywhere so
# the stow symlinks (git-tracked copies) win over the backup copies.
restore_place_home() {
    echo "== restore: selective restore into \$HOME =="
    local home_src="$RESTORE_STAGING/home"
    local d item

    # Unfold any stow-folded directories among the restore targets first, so
    # the rsyncs below write into real directories and never into
    # ~/.dotfiles itself. Parents (.local, .config) can be the folded link
    # when they didn't exist at first stow, so check them too.
    for d in "$HOME/.local" "$HOME/.config" "$HOME/.claude" "$HOME/.local/bin" \
             "$HOME/.config/khard" "$HOME/.config/systemd/user"; do
        if [[ -L "$d" ]]; then
            rm "$d" && mkdir -p "$d"
        fi
    done
    # Pre-create the shared target dirs so the re-stow can't re-fold them.
    mkdir -p "${STOW_SHARED_DIRS[@]}"
    (cd "$DOTFILES_DIR" && stow -R "${STOW_PACKAGES[@]}")

    # Direct restores: plain directories/files, no stow overlap.
    for item in .ssh .contacts .vdirsyncer .android Documents corpus Pictures; do
        if [[ -e "$home_src/$item" ]]; then
            rsync -a --ignore-existing "$home_src/$item" "$HOME/"
        fi
    done
    chmod 700 "$HOME/.ssh" 2> /dev/null || true
    chmod 600 "$HOME/.ssh"/* 2> /dev/null || true

    # .local/share/keyrings: not a stow target, but nested under .local/share
    # so it needs its own destination, not the top-level loop above.
    mkdir -p "$HOME/.local/share"
    if [[ -e "$home_src/.local/share/keyrings" ]]; then
        rsync -a --ignore-existing "$home_src/.local/share/keyrings" "$HOME/.local/share/"
    fi

    # .local/bin: the `bin` stow package also targets this dir, so merge,
    # don't clobber. nvim-journal is excluded: neovim is dropped on Bluefin.
    if [[ -d "$home_src/.local/bin" ]]; then
        rsync -a --ignore-existing --exclude nvim-journal "$home_src/.local/bin/" "$HOME/.local/bin/"
    fi

    # Selected .config subdirs.
    mkdir -p "$HOME/.config"
    for item in chromium gcloud gh op 1Password poplar khard vale google-workspace systemd; do
        if [[ -e "$home_src/.config/$item" ]]; then
            rsync -a --ignore-existing "$home_src/.config/$item" "$HOME/.config/"
        fi
    done
    for item in "$home_src"/.config/jrnl*; do
        if [[ -e "$item" ]]; then
            rsync -a --ignore-existing "$item" "$HOME/.config/"
        fi
    done

    # .claude: memory/history/projects are runtime state, not stow-tracked.
    # Skills/agents/docs/workflows/CLAUDE.md/settings.json ARE stow-tracked;
    # --ignore-existing means the stow symlinks win.
    if [[ -d "$home_src/.claude" ]]; then
        rsync -a --ignore-existing "$home_src/.claude/" "$HOME/.claude/"
    fi

    # The age key file the brief documents as asc-key.txt: restore it to the
    # same relative path under $HOME it had in the backup.
    local found rel
    found="$(find "$home_src" -iname 'asc-key.txt' 2> /dev/null | head -1)"
    if [[ -n "$found" ]]; then
        rel="${found#"$home_src"/}"
        mkdir -p "$(dirname "$HOME/$rel")"
        if [[ ! -e "$HOME/$rel" ]]; then
            cp "$found" "$HOME/$rel"
        fi
        echo "asc-key.txt restored to ~/$rel"
    else
        echo "WARNING: asc-key.txt not found in the backup; find it manually" >&2
    fi

    # Assert the unfold + restore above didn't write into the dotfiles repo.
    if [[ -n "$(git -C "$DOTFILES_DIR" status --short)" ]]; then
        echo "HARD STOP: restore dirtied ~/.dotfiles:" >&2
        git -C "$DOTFILES_DIR" status --short >&2
        return 1
    fi
}

# Runbook 4.7.
restore_projects() {
    echo "== restore: projects from the tarball =="
    local item
    mkdir -p "$HOME/Projects"
    for item in aksailingclub-sveltekit cairn-scratch ecxc-ski-agent-memory; do
        if [[ -d "$RESTORE_STAGING/projects/$item" ]]; then
            rsync -a --ignore-existing "$RESTORE_STAGING/projects/$item/" "$HOME/Projects/$item/"
        fi
    done
    if [[ ! -d "$HOME/Projects/smallbusinessak-org" ]]; then
        git clone "$RESTORE_STAGING/projects/smallbusinessak-org.bundle" \
            "$HOME/Projects/smallbusinessak-org"
    fi
}

# Runbook 4.8: interactive sudo (claude-sudo-setup hasn't run yet).
restore_etc() {
    echo "== restore: /etc drops from etc-capture =="
    local android_rule
    android_rule="$(find "$RESTORE_STAGING/etc-capture" -iname '51-android.rules' | head -1)"
    if [[ -n "$android_rule" ]]; then
        sudo cp "$android_rule" /etc/udev/rules.d/
        sudo udevadm control --reload-rules && sudo udevadm trigger
    fi
    sudo mkdir -p /etc/chromium/policies/managed
    find "$RESTORE_STAGING/etc-capture" -iname '*.json' -ipath '*chromium*' -print0 \
        | xargs -0 -r -I{} sudo cp {} /etc/chromium/policies/managed/
}

# Runbook 4.9: mandatory. Bluefin enforces SELinux; the Mint backup carries
# no labels, and skipping this is a documented cause of broken logins.
restore_selinux() {
    echo "== restore: SELinux contexts =="
    sudo restorecon -R -v /var/home/glw907
}

# Runbook 4.10.
restore_cleanup() {
    echo "== restore: cleanup =="
    shred -u "$AGE_KEY_CACHE"
    rm -rf "$RESTORE_STAGING"
}

restore_checklist() {
    cat <<'EOF'

== Restore done. Remaining judgment items (runbook "verify on first boot") ==

- Diff the restored ~/.local/bin against the bin stow package and delete any
  Mint-only stray.
- Section 5 (re-authentication) and section 6 (verification) remain, plus the
  CLAUDE.md machine-section rewrite from CLAUDE-md-draft.md.

Next: launch Claude Code (first launch asks you to log in), then hand it:

  claude "Read ~/.dotfiles/bluefin/MIGRATION-RUNBOOK.md. Sections 1-4 are done.
  Continue from section 5, then apply CLAUDE-md-draft.md per its header."
EOF
}

phase_restore() {
    local steps=(
        restore_preflight
        restore_fetch_key
        restore_secrets
        restore_reassemble
        restore_verify_checksum
        restore_extract
        restore_place_home
        restore_projects
        restore_etc
        restore_selinux
        restore_cleanup
    )
    local step
    for step in "${steps[@]}"; do
        if ! "$step"; then
            echo "phase_restore: stopped at $step (fix and rerun; completed steps skip themselves)" >&2
            exit 1
        fi
    done
    restore_checklist
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
    restore)
        phase_restore
        ;;
    *)
        echo "Usage: $0 {layer|setup|restore}" >&2
        exit 1
        ;;
esac
