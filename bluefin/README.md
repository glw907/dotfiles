# Bluefin bootstrap

Bootstrap artifacts for converting a workstation from Linux Mint to Bluefin
DX (stable). Decisions record and fact base: `MIGRATION-BRIEF.md`. Read that
file first; this directory implements it and does not repeat its reasoning.

## Quick card: fresh Bluefin to working machine

Every command to type on the new system, in order. Details and hard stops
live in `MIGRATION-RUNBOOK.md`; nothing here requires reading it first.

```bash
git clone https://github.com/glw907/workstation.git ~/.dotfiles
~/.dotfiles/bluefin/bootstrap.sh devmode   # answer: yes, no, no
sudo systemctl reboot
~/.dotfiles/bluefin/bootstrap.sh layer
sudo systemctl reboot
~/.dotfiles/bluefin/bootstrap.sh setup
# 1Password app: sign in, then Settings -> Developer -> "Integrate with 1Password CLI"
~/.dotfiles/bluefin/bootstrap.sh restore
claude   # first launch asks you to log in
```

Two reboots, both required. The official ISO installs the non-DX `bluefin`
image; `devmode` rebases to `bluefin-dx` and only takes effect on boot, and
`layer` must run against the image that is actually booted. `layer` and
`setup` both hard-stop if they find themselves on a non-DX image.

Then hand the Claude session this prompt, and it finishes the rest
(re-authentication walkthrough, verification, the CLAUDE.md rewrite) with
its full memory restored:

> Read ~/.dotfiles/bluefin/MIGRATION-RUNBOOK.md. Sections 1-4 are done.
> Continue from section 5, then apply CLAUDE-md-draft.md per its header.

## Contents

| File | Purpose |
|------|---------|
| `MIGRATION-BRIEF.md` | Decisions, verified platform facts, backup state |
| `MIGRATION-RUNBOOK.md` | Wipe-day and restore procedure, authoritative from step 7 |
| `bootstrap.sh` | `devmode`, `layer`, `setup`, and `restore` phases, run in order below |
| `layered-packages.txt` | The minimal rpm-ostree layered set |
| `flatpaks.txt` | Flatpak app IDs to install |
| `Brewfile` | CLI tool formulae for `brew bundle` |
| `CLAUDE-md-draft.md` | Draft CLAUDE.md machine-section replacement, applied during restore |
| `etc/` | Captured `/etc` drops: chromium policies, android udev rule |
| `inventory/` | Captured lists from the Mint machine, source data for the above |

## Order of operations, fresh install

1. Write the Bluefin ISO with Fedora Media Writer, install to `stable` with
   whole-disk LUKS. Enable "Allow Microsoft 3rd Party UEFI CA" in BIOS
   first. There is no separate DX ISO — the image is unified and installs
   non-DX `bluefin`; DX comes from the `devmode` rebase in step 4.
2. First boot: enroll the MOK (password `universalblue`).
3. Clone dotfiles:
   ```
   git clone https://github.com/glw907/workstation.git ~/.dotfiles
   ```
4. Rebase to the Developer Experience image:
   ```
   ~/.dotfiles/bluefin/bootstrap.sh devmode
   ```
   This wraps `ujust devmode`, which prompts three times: answer **yes** to
   enabling developer mode, then **no** to the default development flatpaks
   and **no** to the extra monospace fonts. Both declines are deliberate —
   flatpaks come from `flatpaks.txt` and fonts from the `Brewfile`, so that
   the second workstation gets the same tracked set.
5. Reboot into the DX image.
6. Layer packages and add the 1Password repo:
   ```
   ~/.dotfiles/bluefin/bootstrap.sh layer
   ```
7. Reboot (the layered packages need the new deployment applied).
8. Run the rest of setup:
   ```
   ~/.dotfiles/bluefin/bootstrap.sh setup
   ```
   Read the verification checklist it prints at the end before moving on.
9. Selective restore from the encrypted backup:
   ```
   ~/.dotfiles/bluefin/bootstrap.sh restore
   ```
   This executes `MIGRATION-RUNBOOK.md` section 4 with the same hard stops
   (checksum, decrypt, dotfiles-repo cleanliness). The runbook section
   remains the specification and the manual fallback, and the runbook is
   authoritative for everything after: re-authentication, verification, and
   the CLAUDE.md rewrite.

## Second workstation

This same directory provisions the second workstation arriving a few weeks
after thinkpad-x1: same ISO, same `bootstrap.sh devmode` / `layer` / `setup`
sequence, same package lists. A custom uBlue image is a later decision point,
not assumed here — though note that a custom image is the standard way to
avoid the devmode rebase and the Flatpak removals below, by baking both into
the image instead of undoing them per machine.

## Changing the layered package set

`layered-packages.txt` stays minimal by design. Before adding a package to
it, record the reason in `MIGRATION-BRIEF.md`. That file is the source the
list is curated from, not the other way around.
