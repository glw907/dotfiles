# Bluefin bootstrap

Bootstrap artifacts for converting a workstation from Linux Mint to Bluefin
DX (stable). Decisions record and fact base: `MIGRATION-BRIEF.md`. Read that
file first; this directory implements it and does not repeat its reasoning.

## Contents

| File | Purpose |
|------|---------|
| `MIGRATION-BRIEF.md` | Decisions, verified platform facts, backup state |
| `MIGRATION-RUNBOOK.md` | Wipe-day and restore procedure, authoritative from step 7 |
| `bootstrap.sh` | `layer` and `setup` phases, run in order below |
| `layered-packages.txt` | The minimal rpm-ostree layered set |
| `flatpaks.txt` | Flatpak app IDs to install |
| `Brewfile` | CLI tool formulae for `brew bundle` |
| `CLAUDE-md-draft.md` | Draft CLAUDE.md machine-section replacement, applied during restore |
| `etc/` | Captured `/etc` drops: chromium policies, android udev rule |
| `inventory/` | Captured lists from the Mint machine, source data for the above |

## Order of operations, fresh install

1. Write the Bluefin DX ISO with Fedora Media Writer, install to `stable`
   with whole-disk LUKS. Enable "Allow Microsoft 3rd Party UEFI CA" in BIOS
   first.
2. First boot: enroll the MOK (password `universalblue`).
3. Clone dotfiles:
   ```
   git clone https://github.com/glw907/workstation.git ~/.dotfiles
   ```
4. Layer packages and add the 1Password repo:
   ```
   ~/.dotfiles/bluefin/bootstrap.sh layer
   ```
5. Reboot (the layered packages need the new deployment applied).
6. Run the rest of setup:
   ```
   ~/.dotfiles/bluefin/bootstrap.sh setup
   ```
   Read the verification checklist it prints at the end before moving on.
7. Selective restore from the encrypted backup: `MIGRATION-RUNBOOK.md` is
   authoritative from here on. It covers decrypting
   `pre-bluefin-backup.tar.age` and which paths get restored, and is
   self-contained for a fresh session with no memory of this directory's
   other files.

## Second workstation

This same directory provisions the second workstation arriving a few weeks
after thinkpad-x1: same ISO, same `bootstrap.sh layer` / `setup` sequence,
same package lists. A custom uBlue image is a later decision point, not
assumed here.

## Changing the layered package set

`layered-packages.txt` stays minimal by design. Before adding a package to
it, record the reason in `MIGRATION-BRIEF.md`. That file is the source the
list is curated from, not the other way around.
