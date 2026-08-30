# Workstation Configuration

Dotfiles and machine configuration for a single Bluefin DX workstation
(`thinkpad-x1`, Fedora 44 base, `bootc`/`ostree`), managed with
[GNU Stow](https://www.gnu.org/software/stow/). The repo tracks two things:
the dotfiles Stow links into `$HOME`, and the machine-provisioning artifacts
that bring a fresh Bluefin install to a working state.

## Layout

| Path | Contents |
|------|----------|
| `bluefin/` | Machine config: `Brewfile`, `flatpaks.txt`, `layered-packages.txt`, staged `/etc` drops, `bootstrap.sh`, `stow-packages.txt` |
| `scripts/` | Repo-maintenance scripts, including the secrets sync pipeline |
| `secrets/` | Age-encrypted secret store and rotation registry |
| `docs/` | Repo documentation, including this file's companions |
| `tests/` | Python test suite for the repo's own scripts |

Each directory listed above with its own `.md` (`bash/`, `bin/`, `claude/`,
`contacts/`, `git/`, `kitty/`, `vale/`) is a Stow package. The authoritative
package list is `bluefin/stow-packages.txt`; both `bluefin/bootstrap.sh` and
`sync-dotfiles.sh` read it rather than carrying their own copy, so it is the
single place to add or remove a package.

### Day-to-day Stow usage

    cd ~/.dotfiles
    stow bash              # Install (create symlinks)
    stow -D bash           # Remove (delete symlinks)
    stow -R bash           # Restow (after file changes)
    stow $(cat bluefin/stow-packages.txt | grep -v '^#')   # All packages

## Fresh-machine bring-up

See [bluefin/README.md](bluefin/README.md) for the full bootstrap sequence:
rebasing to the DX image, layering the minimal RPM set, running `setup`, and
restoring from the encrypted backup.

## Secrets

1Password is the source of truth. Secret values are age-encrypted in
`secrets/values.age` and synced out to `~/.local/secrets` and Cloudflare
Workers by `scripts/secrets/sync.sh`. Full architecture and the secret
inventory: [docs/secrets.md](docs/secrets.md).

## System maintenance

| Command | Purpose |
|---------|---------|
| `sync-dotfiles.sh` | Check Stow status and git drift across tracked packages |
| `workstation-update` | Run the Bluefin update flow: `ujust update`, mise, uv tools, kitty |

## Repo status and history

Current state and open items: [docs/STATUS.md](docs/STATUS.md). Per-pass
ledger of what changed and why: [docs/HISTORY.md](docs/HISTORY.md).

## Intentionally untracked local tools

Some tools this workstation relies on are deliberately outside this repo,
because they own their own install or update path:

- **poplar** -- a terminal email client, installed from its own repo via
  `make install`, not Stow or Homebrew.
- **Standalone binaries** -- `harper-ls`, `marksman`, `perfspike`,
  `samfusdl`, `odin4`. Each ships as a single binary with no package manager
  of its own; they live in `~/.local/bin` without a tracked source.
- **uv-tool shims** -- Python CLIs (`khard`, `vdirsyncer`, `yt-dlp`, `ruff`,
  `jrnl`) installed via `uv tool install` land in `~/.local/bin` as shims.
  `bluefin/bootstrap.sh` installs the set; nothing in this repo tracks the
  shims themselves.
