# CLAUDE.md machine-section draft: Bluefin DX

DRAFT. Not live. Replaces four headers in `~/.claude/CLAUDE.md` once Bluefin is the
running system: **Machine Environment**, **Browser: Chromium only**, **Sysadmin
Preferences**, **System Organization**. Also DELETE the **Neovim** section entirely
at apply time -- it is not replaced by anything here, since neovim is dropped on
Bluefin (brief: "Neovim is dropped entirely; Geoff does not use it. micro is the
terminal editor."). Deleting that section leaves `~/.claude/docs/neovim-setup.md`
unreferenced; delete that file from the `claude` stow package in the same apply step.
Every other section of the live file (Search before you spelunk, One executor per
worktree, Git Conventions, Go Development, Cloudflare / Wrangler, and everything
after Dotfiles Management) is unchanged and out of scope for this draft -- do not
fold this file's content into those sections, and do not carry any of those sections
into this one.

Applied during the migration runbook's restore step, after `~/.claude` is restored
from the encrypted backup and before the workstation is considered cut over. Until
that step runs, `~/.claude/CLAUDE.md` stays exactly as it is -- correct for Mint. Do
not edit the live file from this task.

Full context and decisions record: `~/.dotfiles/bluefin/MIGRATION-BRIEF.md`.
Day-to-day admin reference this draft points to: `~/.claude/docs/bluefin-admin.md`.

---

## Machine Environment

- **OS**: Bluefin DX, `stable` stream (Fedora 44 base), image-based (bootc/ostree)
- **Desktop**: GNOME (Wayland) | **Shell**: bash | **Terminal**: Ptyxis (ships
  with the image). kitty is installed but is NOT the daily terminal -- it is the
  gate platform for `tui-visual-verify` only, forced to XWayland in its config so
  the xdotool/`import` capture path works. Do not suggest kitty as the terminal
  or assume a kitty-specific feature in day-to-day work.
- **Key paths**: `~/Projects/` (all repos), `~/.dotfiles/` (config), `~/.local/bin/`
  (scripts)
- **Dev tools**: Node via mise, Python via uv, Go via Homebrew, Java 17 (OpenJDK) for
  Android tooling
- **Android SDK**: `~/Android/` -- `ANDROID_HOME` set in `.bashrc`

## Browsers: Firefox + Chromium, no Flatpak

Firefox (layered RPM) is the daily browser, with 1Password integration. Chromium
(layered RPM) is the development and testing browser -- what Claude Code drives via
the claude-in-chrome native host, chrome-devtools MCP, and `chromium-shot`. Never
suggest a Flatpak build of either: Flatpak's sandbox blocks the native messaging both
1Password and Claude's browser tooling depend on. Invoke Chromium as `chromium`.
Read `~/.claude/docs/bluefin-admin.md` before any browser, Playwright, or extension
work -- it supersedes `chromium-browser.md`'s Mint-specific install and path details.

## Sysadmin Preferences

- **Troubleshooting**: Search web after 1-2 failed attempts -- include "Bluefin DX"
  or "Fedora 44" or "Universal Blue" in queries, whichever fits the symptom
- **sudo**: Always `sudo -A`. Decrypted automatically by `claude-askpass`. If the age
  file is missing or stale, run `claude-sudo-setup` (requires 1Password desktop app
  running and unlocked). If it fails after a fresh install, check the 1Password GID
  gotcha in `bluefin-admin.md` before assuming the script itself is broken.
- **Software tiers**: mise/uv for runtimes, Homebrew for CLI tools, Flatpak for GUI
  apps, distrobox/devcontainers for dev environments, rpm-ostree layering
  (`rpm-ostree install`) as last resort only. Full policy and the command map
  (`ujust update`/`rebase-helper`/`dx-group`, `bootc status`/`switch`):
  `~/.claude/docs/bluefin-admin.md`. The layered set is deliberately minimal and
  tracked in `~/.dotfiles/bluefin/layered-packages.txt`; that file is the source of
  truth, and any addition to it gets recorded in `MIGRATION-BRIEF.md` too.
- **Destructive ops**: Show dry-run or confirmation step first

## System Organization

- Home dir (`~/`) should have minimal loose files
- Scripts -> `~/.local/bin/` | Configs -> `~/.config/`
- When modifying configs: check if they belong in `~/.dotfiles/`
- `/etc` changes: land in `~/.dotfiles/bluefin/etc/` first, then install from there.
  Never edit `/etc` directly -- see `bluefin-admin.md` for the current captured files
  and install targets.
- micro is the editor. Neovim is not installed; do not suggest it or reference
  `nvim-journal` setup for this machine.
