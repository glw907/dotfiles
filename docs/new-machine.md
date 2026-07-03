# New Machine Setup

Step-by-step bootstrap for a fresh Linux Mint 22 (Cinnamon) machine.

## 1. Prerequisites

```bash
sudo apt update && sudo apt install -y stow git curl micro gh aerc
gh auth login
```

## 2. Clone and Stow

```bash
git clone https://github.com/glw907/workstation.git ~/.dotfiles
cd ~/.dotfiles
stow bash bin claude git
source ~/.bashrc
```

**Core packages** (stow first): `bash bin claude git`

**Optional packages** (stow as needed): `kitty applications contacts themes wallpapers`

## 3. Node / NVM

Required for `npx`/wrangler and Claude CLI:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash
source ~/.bashrc
nvm install --lts
```

## 4. Claude Code

```bash
npm install -g @anthropic-ai/claude-code
claude   # Opens browser for auth on first run
```

## 5. Secrets

Prerequisite: 1Password desktop app running + CLI integration enabled.

```bash
eval $(op signin)
~/.dotfiles/scripts/secrets/sync.sh --local
```

See [docs/secrets.md](secrets.md) for the full architecture.

## 6. Email Stack

```bash
stow beautiful-aerc contacts
```

Then create `~/.config/aerc/accounts.conf` manually (not committed -- contains credentials).

Contact sync: `vdirsyncer discover fastmail_contacts && vdirsyncer sync`

See [docs/email.md](email.md) for how the components connect.

## 7. Optional: kitty

Installed via official installer (not apt):

```bash
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh
```

Launcher symlinks (`kitty`, `kitten`) are created at `~/.local/bin/`. Config is tracked in the `kitty` stow package. Update later via `workstation-update`.

## 8. Optional: Android SDK

Follow [android/README.md](../android/README.md). Summary:

```bash
mkdir -p ~/Android/cmdline-tools
# Download and extract command-line tools to ~/Android/cmdline-tools/latest/
sdkmanager --licenses && sdkmanager "platform-tools"
```

`ANDROID_HOME` and `PATH` entries are already in `.bashrc`.

## 9. Optional: Nord Theme

```bash
cd ~/.dotfiles/themes && ./setup-nord.sh
stow wallpapers
gsettings set org.cinnamon.desktop.background picture-uri \
  "file://$HOME/Pictures/Wallpapers/nord-gradient.png"
```

## 10. Flatpak Apps

Flatpak is pre-installed on Linux Mint:

```bash
flatpak install flathub com.discordapp.Discord
flatpak install flathub com.fastmail.Fastmail
flatpak install flathub org.gnome.Apostrophe
flatpak install flathub com.noson.Noson
```

## 11. Verify

```bash
~/.dotfiles/sync-dotfiles.sh    # Should report all packages in sync
which cld                        # ~/.local/bin/cld
ls -la ~/.claude/CLAUDE.md      # Symlink into ~/.dotfiles
claude                           # Starts Claude
```
