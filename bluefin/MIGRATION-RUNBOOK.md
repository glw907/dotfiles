# Bluefin DX migration runbook: thinkpad-x1

Wipe-day and restore procedure for the Mint 22.3 to Bluefin DX conversion. This
file is self-contained: a fresh Claude Code session on the new system, with no
memory of any prior conversation, can execute the restore (sections 3 onward)
from this file alone. Decisions and platform facts referenced here come from
`MIGRATION-BRIEF.md` in this same directory; read that file if any step below
needs more context than is repeated here.

Anything marked **verify on first boot** could not be checked from the old
system and must be confirmed for real once Bluefin is running, before relying
on it.

**sudo bootstrap chicken-and-egg**: `sudo -A` (the `claude-askpass` flow) does
not work until `claude-sudo-setup` has run, and that script needs the
1Password desktop app installed, running, and signed in. Until step 5 covers
that, use plain interactive `sudo` (type the password) for every sudo command
below.

---

## 1. Pre-wipe gate (run on Mint, in order)

Do not proceed to step 7 (flashing the ISO) until every check below passes.

1. **cairn-cms must already be pushed by its own session.** Do not push it
   from this session. Verify it is clean:

   ```bash
   cd ~/Projects/cairn-cms && git status && git log --branches --not --remotes --oneline
   ```

   Both commands must show a clean tree and an empty list of unpushed
   commits, and this includes any worktrees:

   ```bash
   for wt in ~/Projects/cairn-cms/.claude/worktrees/*/; do
     echo "== $wt =="
     git -C "$wt" status
     git -C "$wt" log --branches --not --remotes --oneline
   done
   ```

   If anything is dirty or ahead of its remote, stop and get Geoff to push
   cairn-cms himself before continuing.

2. **poplar must be clean and pushed**, alongside the cairn-cms check above:

   ```bash
   cd ~/Projects/poplar && git status && git log --branches --not --remotes --oneline
   ```

   Both commands must show a clean tree and an empty list of unpushed
   commits. Unlike cairn-cms there is no other live session using it, so if
   it's dirty or ahead of its remote, just commit and push it now.

3. **Final dotfiles commit and push.**

   ```bash
   cd ~/.dotfiles && git status
   git add -A && git commit -m "Final commit before Bluefin wipe"
   git push
   ```

   Skip the commit if `git status` is already clean.

4. **Verify the R2 objects exist and the chunk reassembly checksum matches.**
   This is the same reassembly the restore will do later (section 4), run
   now as a dry run while the USB stick copy still exists as a fallback.

   ```bash
   mkdir -p /tmp/pre-bluefin-verify && cd /tmp/pre-bluefin-verify
   export CLOUDFLARE_ACCOUNT_ID=120c269ad6d3dfbe6d63a0bb53758ca0
   # CLOUDFLARE_API_TOKEN is already sourced from ~/.local/secrets on Mint.

   suffixes=(aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at)
   for s in "${suffixes[@]}"; do
     key="pre-bluefin/chunk-$s"
     if ! npx wrangler r2 object get --remote "workstation-backup/$key" --file "chunk-$s" 2>/dev/null; then
       rm -f "chunk-$s"
       echo "stopped at chunk-$s (not found, expected once all chunks are fetched)"
       break
     fi
     echo "fetched chunk-$s"
   done

   n=$(ls chunk-* | wc -l)
   echo "fetched $n chunks"

   cat chunk-* > pre-bluefin-backup.tar.age
   sha256sum pre-bluefin-backup.tar.age
   ```

   Compare the printed hash against the brief's recorded value:

   ```
   db0c2c041d2587ac300421734e4d4f32f436832242d385f20cc913aee0a0dbe1
   ```

   They must match exactly. If they don't, do not proceed - the R2 copy is
   the *only* backup after step 7, so a mismatch here is a hard stop.

5. **Fetch the age identity and prove it decrypts the backup.** A hard stop
   like the checksum in step 4: the decrypt path must work before the stick
   (the local fallback) is overwritten in step 7.

   ```bash
   cd /tmp/pre-bluefin-verify
   op item get "Workstation age encryption key" --fields notesPlain --reveal \
     | sed 's/^"//;s/"$//' > "/dev/shm/.age-key-$UID"
   chmod 600 "/dev/shm/.age-key-$UID"

   pubkey=$(age-keygen -y "/dev/shm/.age-key-$UID")
   if [[ "$pubkey" != "age197mcd2m3z90t49n9t5v3ujjntw7krfkw5y9sjfc545v28qvezugshg7jgk" ]]; then
     echo "age public key mismatch: got $pubkey" >&2
     shred -u "/dev/shm/.age-key-$UID"
     exit 1
   fi

   age -d -i "/dev/shm/.age-key-$UID" pre-bluefin-backup.tar.age | tar -tf - | head
   ```

   The decrypt must print a real file listing, not an error. If the public
   key doesn't match or the decrypt fails, stop here - do not proceed to
   step 7.

   ```bash
   shred -u "/dev/shm/.age-key-$UID"
   cd ~ && rm -rf /tmp/pre-bluefin-verify   # clean up the dry-run copy
   ```

6. **Verify the USB stick still holds the tarball copy.**

   ```bash
   ls -la /media/glw907/writable/pre-bluefin/
   sha256sum /media/glw907/writable/pre-bluefin/pre-bluefin-backup.tar.age
   ```

   Confirm the hash matches the same value as step 4.

7. **Flash the Bluefin DX ISO to the stick with Fedora Media Writer.**

   This overwrites the stick, **destroying its tarball copy**. After this
   step, the R2 bucket (`workstation-backup`) is the *only* remaining copy
   of the backup — there is no local fallback until a fresh copy is made.

   - Download the Bluefin ISO (`stable` stream) from
     `https://download.projectbluefin.io/` (or the Universal Blue project
     page, whichever is current — **verify on first boot** which mirror is
     live at flash time). The ISO is unified: there is no separate DX
     image to download, and it installs non-DX `bluefin`. DX comes from the
     `devmode` rebase in section 3.
   - Open Fedora Media Writer, select the downloaded ISO, select the USB
     stick, and write.

8. **BIOS: enable Secure Boot settings.**

   Reboot into BIOS/UEFI setup and enable, in order:
   - Secure Boot: **Enabled**
   - "Allow Microsoft 3rd Party UEFI CA": **Enabled** (ThinkPad-specific
     option; Secure Boot alone is not sufficient — Bluefin's MOK enrollment
     needs this flag on)

   Save and exit.

---

## 2. Install

1. Boot from the USB stick (F12 or the ThinkPad boot-menu key at power-on).
2. Choose whole-disk automatic partitioning. Do not choose manual/custom
   partitioning.
3. Enable LUKS full-disk encryption when offered, and set the disk
   passphrase (Geoff's choice at install time — not recorded here).
4. Complete the install and reboot when prompted.
5. On first boot, Bluefin enrolls its MOK (Machine Owner Key) for Secure
   Boot. When the MOK enrollment (blue "shim") screen appears:
   - Choose "Enroll MOK"
   - Enter the password `universalblue`
   - Confirm and reboot

---

## 3. First boot

**Verify on first boot**: `~/.dotfiles/bluefin/bootstrap.sh` must exist,
committed before wipe day, with a `devmode` mode (bootc rebase to DX, needs a
reboot to apply), a `layer` mode (rpm-ostree layering, needs a second reboot)
and a `setup` mode (everything else — mise, uv, Homebrew, stow, syncthing,
kitty, udev rules, Chromium policies, Flatpak removals). If it does not exist
yet, do not proceed past this section until it is written and its contents
are checked against the brief's decisions:

- `devmode` should run `ujust devmode` and stop for a reboot.
- Layer only `1password`, `1password-cli`, `firefox`, `chromium` (plus the
  1Password RPM repo + signing key, added first).
- `setup` should install mise (Node) and uv (Python tool installs), install
  Homebrew if not already present, install the curated Brewfile (see the
  CLI estate list in the brief's "Current-machine facts" section, plus the
  `claude-code` cask and `xdotool`; no font casks), run `stow -R` for the
  `bash bin claude git kitty contacts` packages, install kitty via its own
  upstream installer (not layered, and as the tui-visual-verify gate
  platform rather than as the terminal), enable the syncthing user service,
  install the Chromium managed policies and the Android udev rule from
  `bluefin/etc/`, remove the preinstalled Flatpak Firefox and 1Password, and
  run `ujust dx-group`.

Steps:

1. Open a terminal. Clone dotfiles over HTTPS (no `gh` auth yet — that comes
   in step 5):

   ```bash
   git clone https://github.com/glw907/workstation.git ~/.dotfiles
   ```

2. Rebase to the Developer Experience image. The official ISO installs the
   non-DX `bluefin:stable`; DX is a post-install rebase (brief amendment,
   2026-08-30). This stages a `bootc switch` that takes effect on boot.

   ```bash
   ~/.dotfiles/bluefin/bootstrap.sh devmode
   ```

   `ujust devmode` prompts three times. Answer **yes** to enabling developer
   mode, **no** to the default development flatpaks, **no** to the extra
   monospace fonts. The declines are deliberate: flatpaks are tracked in
   `flatpaks.txt` so both workstations match, and no fonts are needed at all
   — the base image already ships JetBrains Mono and Symbols Nerd Font Mono,
   which is all `kitty.conf` asks for.

3. Reboot:

   ```bash
   sudo systemctl reboot
   ```

4. After reboot, confirm DX landed before layering anything onto it:

   ```bash
   rpm-ostree status
   docker --version
   ```

   The deployment should name a `bluefin-dx` image, and `docker` should
   exist (DX ships it; the base image does not). If you are still on
   `bluefin`, the rebase did not apply — do not continue, since `layer`
   would put the RPMs on the deployment about to be replaced. `layer` and
   `setup` both hard-stop on a non-DX image for this reason.

5. Run the layering phase. This uses `rpm-ostree install`, which stages
   packages for the next boot; it does not take effect until you reboot.

   ```bash
   ~/.dotfiles/bluefin/bootstrap.sh layer
   ```

6. Reboot again:

   ```bash
   sudo systemctl reboot
   ```

7. After reboot, confirm the layered packages landed:

   ```bash
   rpm-ostree status
   ```

   **Verify on first boot**: `1password`, `1password-cli`, `firefox`, and
   `chromium` should all appear in the current deployment's layered
   packages.

8. Run the setup phase:

   ```bash
   ~/.dotfiles/bluefin/bootstrap.sh setup
   ```

   Among other things this removes the preinstalled Flatpak Firefox and
   1Password and hands the default-browser association to the layered RPM.
   Both Flatpaks collide with the layered builds, and the sandboxed ones
   cannot do the native messaging that 1Password and Claude's browser
   tooling need. Manual equivalent, if running the phase piecemeal:

   ```bash
   flatpak uninstall --system -y --delete-data org.mozilla.firefox
   flatpak uninstall --system -y --delete-data com.onepassword.OnePassword
   xdg-settings set default-web-browser org.mozilla.firefox.desktop
   ```

   (The Fedora firefox RPM ships `org.mozilla.firefox.desktop`, the same
   desktop id the Flatpak exported, so the association resolves to the RPM
   once the Flatpak is gone — brief amendment, 2026-08-30 restore day.)

9. Launch 1Password, sign in, and enable **Settings → Developer →
   "Integrate with 1Password CLI"**. This is a GUI-only toggle with no CLI
   equivalent, and section 4 below depends on it. Make sure you are opening
   the layered RPM app, not a leftover Flatpak — step 8 should have removed
   the Flatpak entirely.

Do not launch `claude` yet — section 4 restores `~/.claude` before first
launch.

---

## 4. Restore

**Scripted path (preferred): run `~/.dotfiles/bluefin/bootstrap.sh restore`.**
It executes steps 1-10 below in order with the same hard stops, is
rerunnable (completed steps detect their state and skip), and prints the
remaining judgment items when done. The steps below are its specification
and the manual fallback; keep the two in sync when editing either.

Preconditions before starting: mise's Node is active (`npx` resolves) and
1Password desktop CLI integration is on (step 3.9).

1. **Fetch the 1Password age identity — one `op` call.** This decrypts the
   backup tarball in step 4.5. It is the same "Workstation age encryption
   key" 1Password item the dotfiles secrets store uses, cached in tmpfs
   matching the pattern in `~/.dotfiles/secrets/registry.md`:

   ```bash
   op item get "Workstation age encryption key" --fields notesPlain --reveal \
     | sed 's/^"//;s/"$//' > "/dev/shm/.age-key-$UID"
   chmod 600 "/dev/shm/.age-key-$UID"
   ```

2. **Get `CLOUDFLARE_API_TOKEN` for the R2 download.** `~/.dotfiles` is
   already cloned (step 3.1), so its secrets store is available. Step 4.1
   already pre-warmed the `/dev/shm` age-key cache `sync.sh` reads, so this
   call makes no additional `op` call:

   ```bash
   ~/.dotfiles/scripts/secrets/sync.sh --local
   source ~/.local/secrets
   ```

3. **Reassemble the tarball from R2 chunks.** All paths below are absolute
   under `~/restore-staging`, so this step doesn't depend on the shell's
   current directory.

   ```bash
   mkdir -p ~/restore-staging
   export CLOUDFLARE_ACCOUNT_ID=120c269ad6d3dfbe6d63a0bb53758ca0
   suffixes=(aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at)
   for s in "${suffixes[@]}"; do
     key="pre-bluefin/chunk-$s"
     if ! npx wrangler r2 object get --remote "workstation-backup/$key" --file "$HOME/restore-staging/chunk-$s" 2>/dev/null; then
       rm -f "$HOME/restore-staging/chunk-$s"
       break
     fi
   done
   n=$(ls "$HOME/restore-staging"/chunk-* | wc -l)
   echo "fetched $n chunks"
   cat "$HOME/restore-staging"/chunk-* > "$HOME/restore-staging/pre-bluefin-backup.tar.age"
   rm -f "$HOME/restore-staging"/chunk-*
   sha256sum "$HOME/restore-staging/pre-bluefin-backup.tar.age"
   ```

4. **Verify the checksum** against the brief's recorded value before
   decrypting anything:

   ```
   db0c2c041d2587ac300421734e4d4f32f436832242d385f20cc913aee0a0dbe1
   ```

   Stop here if it doesn't match — do not decrypt an unverified blob.

5. **Decrypt and extract into the staging dir.** Absolute paths again, so
   this step is independent of the previous step's shell state.

   ```bash
   age -d -i "/dev/shm/.age-key-$UID" "$HOME/restore-staging/pre-bluefin-backup.tar.age" \
     | tar -x -C "$HOME/restore-staging"
   rm -f "$HOME/restore-staging/pre-bluefin-backup.tar.age"
   ```

   This produces `~/restore-staging/home/`, `~/restore-staging/projects/`,
   `~/restore-staging/etc-capture/`, and `~/restore-staging/manifest.txt`.
   Check the manifest against what follows:

   ```bash
   cat ~/restore-staging/manifest.txt
   ```

6. **Selectively move into place.** Restore is additive, never destructive:
   use `--ignore-existing` so anything `stow -R` already symlinked in step
   3.8 is left alone (the git-tracked copy wins over the backup copy).

   Skip `home/.dotfiles` entirely — it's superseded by the git clone in
   step 3.1.

   ```bash
   S=~/restore-staging/home

   # Unfold any stow-folded directories among the restore targets first, so
   # the rsyncs below write into real directories and never into
   # ~/.dotfiles itself.
   for d in ~/.claude ~/.local/bin ~/.config/khard ~/.config/systemd/user; do
     [ -L "$d" ] && rm "$d" && mkdir -p "$d"
   done
   (cd ~/.dotfiles && stow -R bash bin claude git kitty contacts)

   # Direct restores: plain directories/files, no stow overlap.
   for item in .ssh .contacts .vdirsyncer .android Documents corpus Pictures; do
     [ -e "$S/$item" ] && rsync -a --ignore-existing "$S/$item" ~/
   done
   chmod 700 ~/.ssh 2>/dev/null || true
   chmod 600 ~/.ssh/* 2>/dev/null || true

   # .local/share/keyrings: not a stow target, but nested under .local/share
   # so it needs its own destination, not the top-level loop above.
   mkdir -p ~/.local/share
   [ -e "$S/.local/share/keyrings" ] && rsync -a --ignore-existing "$S/.local/share/keyrings" ~/.local/share/

   # .local/bin: the `bin` stow package also targets this dir, so merge,
   # don't clobber. nvim-journal is excluded: neovim is dropped on Bluefin
   # (brief), so its scripts should not come back.
   [ -d "$S/.local/bin" ] && rsync -a --ignore-existing --exclude nvim-journal \
     "$S/.local/bin/" ~/.local/bin/

   # Selected .config subdirs.
   mkdir -p ~/.config
   for item in chromium gcloud gh op 1Password poplar khard vale google-workspace systemd; do
     [ -e "$S/.config/$item" ] && rsync -a --ignore-existing "$S/.config/$item" ~/.config/
   done
   for item in "$S"/.config/jrnl*; do
     [ -e "$item" ] && rsync -a --ignore-existing "$item" ~/.config/
   done

   # .claude: memory/history/projects are runtime state, not stow-tracked.
   # Every top-level name in the claude stow package is excluded outright:
   # the backup holds Mint-era stow symlinks for those, and recreating them
   # through today's stow-folded dirs loops (ELOOP). The exclude set is
   # derived from the package dir so it cannot drift from what stow places;
   # the git-tracked copies placed by stow in step 3.8 are canonical.
   if [ -d "$S/.claude" ]; then
     excludes=()
     for entry in ~/.dotfiles/claude/.claude/*; do
       excludes+=(--exclude="/$(basename "$entry")")
     done
     rsync -a --ignore-existing "${excludes[@]}" "$S/.claude/" ~/.claude/
   fi

   # Assert the unfold + restore above didn't write anything into the
   # dotfiles repo itself. This should print nothing.
   git -C ~/.dotfiles status --short
   ```

   **Verify on first boot**: diff the restored `~/.local/bin` against the
   `bin` stow package's tracked contents and delete anything that's a
   Mint-only stray (a script that never made it into the dotfiles repo).

   **Verify on first boot**: confirm the age key file (documented in the
   brief as `asc-key.txt`) landed somewhere sane — its exact path wasn't
   given, so check `find ~/restore-staging/home -iname 'asc-key.txt'` and
   restore it to the same relative path under `$HOME` once found.

   ```bash
   find "$S" -iname 'asc-key.txt' 2>/dev/null
   # then, using the printed relative path, e.g. if it printed $S/.config/age/asc-key.txt:
   #   mkdir -p ~/.config/age && cp -n <printed-path> ~/.config/age/asc-key.txt
   ```

7. **Restore the projects/ contents that came in the tarball itself**
   (these are dirs that either lack a GitHub remote or carry local-only
   scratch/agent-memory state, per the brief):

   ```bash
   mkdir -p ~/Projects
   for item in aksailingclub-sveltekit cairn-scratch ecxc-ski-agent-memory; do
     [ -d ~/restore-staging/projects/"$item" ] && \
       rsync -a --ignore-existing ~/restore-staging/projects/"$item"/ ~/Projects/"$item"/
   done
   ```

   `aksailingclub-sveltekit` came in minus `node_modules/`, `cairn-scratch`
   minus `artifacts/` — both are regenerated in section 6, not restored.

   `smallbusinessak-org` has no GitHub remote (per the brief), so restore it
   from the git bundle in the tarball now, before `~/restore-staging` is
   cleaned up in step 4.10:

   ```bash
   git clone ~/restore-staging/projects/smallbusinessak-org.bundle \
     ~/Projects/smallbusinessak-org
   ```

8. **Restore the etc-capture/ contents** (needs sudo; this is before
   `claude-sudo-setup`, so type the password interactively). Found with
   `find` rather than a fixed subdirectory layout, since the exact layout
   inside `etc-capture/` wasn't pinned down when this was written:

   ```bash
   android_rule=$(find ~/restore-staging/etc-capture -iname '51-android.rules' | head -1)
   if [ -n "$android_rule" ]; then
     sudo cp "$android_rule" /etc/udev/rules.d/
     sudo udevadm control --reload-rules && sudo udevadm trigger
   fi

   sudo mkdir -p /etc/chromium/policies/managed
   find ~/restore-staging/etc-capture -iname '*.json' -ipath '*chromium*' -print0 \
     | xargs -0 -r -I{} sudo cp {} /etc/chromium/policies/managed/
   ```

   (If step 3.8's `bootstrap.sh setup` already installed these from
   `~/.dotfiles/bluefin/etc/`, this step is redundant — harmless either
   way, since the files are identical captures.)

9. **MANDATORY — fix SELinux contexts on everything just restored.**
   Bluefin enforces SELinux; the Mint backup carries no labels. Skipping
   this is a documented cause of broken logins.

   ```bash
   sudo restorecon -R -v /var/home/glw907
   ```

10. **Extras archive, on demand only.** Alongside the main backup, R2 holds
   `pre-bluefin/extras-chunk-*`: an age-encrypted last-sweep archive
   (irreplaceable `~/Downloads` subset, the US Mobile invoice, a current
   agent-memory copy newer than the one this restore just placed). It is not
   part of this restore; `pre-bluefin/EXTRAS.md` in the same bucket carries
   the contents list and reassembly commands.

11. Clean up the age key from tmpfs:

   ```bash
   shred -u "/dev/shm/.age-key-$UID"
   rm -rf ~/restore-staging
   ```

---

## 5. Re-authentication checklist

1. **GitHub CLI:**

   ```bash
   gh auth login
   gh auth status
   ```

2. **Wrangler:**

   ```bash
   npx wrangler login
   npx wrangler whoami
   ```

3. **1Password desktop integration + `claude-sudo-setup`.** Confirm the
   1Password desktop app is running and unlocked (already done in step
   3.9), then:

   ```bash
   claude-sudo-setup
   ```

   This re-mints the age file that `claude-askpass` decrypts. After this,
   `sudo -A` should work — test it:

   ```bash
   sudo -A true && echo "sudo -A OK"
   ```

4. **1Password browser extensions.** Manual, per browser:
   - Firefox (daily browser): open Firefox, install the 1Password
     extension from addons.mozilla.org, sign in.
   - Chromium (dev/testing browser): open Chromium, install the 1Password
     extension from the Chrome Web Store, sign in.

   **Verify on first boot**: confirm both extensions connect to the
   desktop app (the brief flags a known ostree helper-tool GID mismatch —
   if either extension can't connect, see the community fix script at gist
   `b-/ed2cdc182ae5a92bdcd6b73308832a70` referenced in the brief).

5. **adb key check.** Confirm the restored key pairs with the udev rule
   installed in step 4.8:

   ```bash
   ls -la ~/.android/adbkey ~/.android/adbkey.pub
   ```

   Functional pairing is checked with a device in section 6.

6. **Syncthing device re-share:**

   ```bash
   brew services start syncthing
   ```

   Open `http://localhost:8384`, confirm the device list and shared
   folders came back from the restored `~/.config/syncthing`
   (**verify on first boot** — re-pairing with remote devices may require
   accepting the connection on the other side).

7. **Re-clone `~/Projects` repos from GitHub.** The repos confirmed pushed
   in the brief:

   ```bash
   for repo in 907-life aksailingclub-org asc-site cairn-cms poplar; do
     gh repo clone glw907/"$repo" ~/Projects/"$repo"
   done
   ```

   **Verify on first boot**: check `gh repo list glw907 --limit 100` for
   any other repos under active development that aren't named above (the
   brief's repo list isn't exhaustive) and clone those too.

8. **`smallbusinessak-org`** was already restored from its git bundle in
   step 4.7 (it has no GitHub remote). Confirm it's there:

   ```bash
   git -C ~/Projects/smallbusinessak-org log --oneline -5
   ```

---

## 6. Verification

Run these smoke tests before considering the migration done.

1. **Go build**, in any Go repo (e.g. poplar):

   ```bash
   cd ~/Projects/poplar && go build ./...
   ```

2. **SvelteKit repo** — install deps and run its checks (regenerates the
   `node_modules/` excluded from the backup):

   ```bash
   cd ~/Projects/aksailingclub-sveltekit && npm install && npm run check
   ```

3. **poplar install:**

   ```bash
   cd ~/Projects/poplar && make install
   poplar --version   # or whatever the binary's version flag is
   ```

4. **adb:**

   ```bash
   adb devices
   ```

   Should list connected Android devices as `device`, not `unauthorized` —
   if `unauthorized`, the adb key restore or udev rule didn't take; check
   step 4.8 and 5.5.

5. **claude-in-chrome native host**, in the layered (non-Flatpak) Chromium:
   open Chromium, confirm the Claude extension/native host connects (this
   is the reason Chromium must be the RPM build, not Flatpak — a
   sandboxed browser can't reach the native-messaging host).

6. **sudo -A:**

   ```bash
   sudo -A true && echo "sudo -A OK"
   ```

   (Already checked in step 5.3; re-check here if any packages were
   layered after that point, since a new terminal session may be needed.)

---

## 7. Rollback note

- `ujust rebase-helper` switches image streams (`gts`/`stable`/`latest`) or
  rolls back to a previous date-tagged build. `bootc rollback` reverts to
  the previously booted deployment. Both operate at the **OS image level
  only** — layered packages, the base image, and kernel/system state. Use
  either if a `bootstrap.sh layer` step or a system update leaves the
  machine in a bad state.
- Neither touches `/var/home` in any way. Nothing about home-directory
  content, dotfiles, restored backup data, or anything done in sections 3
  through 6 of this runbook is affected by an image rollback, and neither
  command can restore lost or corrupted home-directory state — that's what
  the R2 backup is for, not `bootc`/`rpm-ostree`.
- The R2 backup (`workstation-backup` bucket, `pre-bluefin/` chunks) is
  retained indefinitely. It is **not** deleted as part of this migration —
  only Geoff deleting it explicitly removes it. Until he does, it remains
  available for a re-restore if something is discovered missing after the
  fact.
