# cli-mode.md - Terminal Assistant

## Context

This is Geoff's home directory on a personal workstation. Use this file to assist with command line tasks, scripting, and system administration.

## Environment

- **OS**: Ubuntu (24.04 LTS)
- **Shell**: bash
- **Package manager**: apt, snap
- **Editor**: Prefer `nano` for quick edits, `vim` for scripting

## Preferences

### Troubleshooting Strategy
**Search the web early when troubleshooting issues.** Don't exhaust all local options first.

**Use WebSearch after 1-2 failed attempts when:**
- A command fails with an unfamiliar error message
- Package installation or configuration fails
- System behavior is unexpected or inconsistent
- Dealing with version-specific issues
- Error messages reference specific files, packages, or services

**Example workflow:**
1. First attempt: Try the standard/obvious solution
2. If that fails: Search online for the error message or issue (include "Ubuntu 24.04" in search)
3. Apply the solution found online
4. Only if no online solution exists: Continue with deeper local troubleshooting

**What to search for:**
- Exact error messages (in quotes)
- Include version numbers and "Ubuntu 24.04"
- Package names with "installation" or "configuration"

### Communication Style
- Direct answers without unnecessary follow-up questions
- Show the command first, explain after if needed
- When multiple approaches exist, recommend one and briefly note alternatives
- Include flags/options that make output more useful (e.g., `ls -lah` not just `ls`)

### Command Output
- Use `--help` or `man` pages for reference, don't guess at flags
- Prefer POSIX-compatible commands when reasonable
- For destructive operations, show a dry-run or confirmation step first
- Quote variables and paths to handle spaces: `"$HOME"` not `$HOME`

### Scripting
- Use `#!/usr/bin/env bash` for portability
- Include `set -euo pipefail` at the top of scripts
- **Always include a header comment** defining the script's purpose and basic usage
- Add comments explaining complex operations, non-obvious logic, and important design decisions
- Comments should provide context for future readers (including future Claude sessions)
- Prefer functions over deeply nested conditionals

Example script structure:
```bash
#!/usr/bin/env bash
set -euo pipefail

# Script purpose and usage
# Example: ./script.sh argument

# Explanation of key design decisions or complex logic
# Example: We use method X instead of Y because...

# Rest of script...
```

### Sudo and Privileges
- **Use `sudo -A` instead of `sudo`** - this uses the askpass helper
- Sudo password is cached automatically when the session starts
- **IMPORTANT: Always ask for permission before running sudo commands** - briefly explain what the command will do and wait for user confirmation
- If `sudo -A` fails with "no askpass program specified", ask the user to restart the session with `cld`
- For multi-step privileged operations, chain with `&&` to avoid repeated prompts
- For apt installs, use `-y` flag when automation is intended: `sudo -A apt install -y package`

## Common Tasks

### File Operations
```bash
# Find files by name (case-insensitive)
find . -iname "*pattern*"

# Find and act on files
find . -name "*.log" -mtime +30 -delete

# Disk usage, human-readable, sorted
du -sh */ | sort -h

# Compare directories
diff -rq dir1/ dir2/
```

### Text Processing
```bash
# Search recursively, show line numbers
grep -rn "pattern" .

# Replace in files
sed -i 's/old/new/g' file

# Column extraction
awk '{print $1, $3}' file.txt

# Unique sorted lines with counts
sort file.txt | uniq -c | sort -rn
```

### Network
```bash
# Check if host is reachable
ping -c 3 hostname

# See what's listening
ss -tlnp

# Download file
curl -LO "https://example.com/file"

# HTTP headers only
curl -I "https://example.com"
```

### Process Management
```bash
# Find process by name
pgrep -fl "processname"

# Resource usage
htop      # install: sudo -A apt install htop
top -o %CPU

# Kill by name
pkill -f "pattern"
```

### Git Quick Reference
```bash
# Status and branch info
git status -sb

# Last N commits, one line each
git log --oneline -10

# Diff staged changes
git diff --cached

# Undo last commit, keep changes
git reset --soft HEAD~1

# Clean untracked files (dry run first)
git clean -nd
git clean -fd
```

### Archives
```bash
# Create tar.gz
tar -czvf archive.tar.gz directory/

# Extract tar.gz
tar -xzvf archive.tar.gz

# List contents without extracting
tar -tzvf archive.tar.gz

# Zip with password
zip -er archive.zip directory/
```

### System Info
```bash
# Disk space
df -h

# Memory
free -h

# CPU info
lscpu

# Ubuntu version
lsb_release -a

# Kernel
uname -r
```

### Package Management
```bash
# Update package lists
sudo -A apt update

# Upgrade installed packages
sudo -A apt upgrade

# Install package
sudo -A apt install packagename

# Search for package
apt search keyword

# Show package info
apt show packagename

# Remove package (keep config)
sudo -A apt remove packagename

# Remove package and config
sudo -A apt purge packagename

# Clean up unused packages
sudo -A apt autoremove

# List installed packages
apt list --installed | grep keyword

# Snap: list installed
snap list

# Snap: remove package
sudo -A snap remove packagename
```

### Firewall (ufw)
```bash
# Status
sudo -A ufw status verbose

# Enable/disable
sudo -A ufw enable
sudo -A ufw disable

# Allow port
sudo -A ufw allow 22/tcp

# Allow application profile
sudo -A ufw allow 'OpenSSH'

# Deny port
sudo -A ufw deny 3306

# Delete rule
sudo -A ufw delete allow 22/tcp
```

### Users and Permissions
```bash
# Add user
sudo -A adduser username

# Add user to group
sudo -A usermod -aG groupname username

# Check groups for user
groups username

# Change ownership
chown -R user:group directory/

# Set permissions (rwxr-xr-x)
chmod 755 file
chmod -R 755 directory/
```

### Android SDK Tools
The official Android SDK Command-line Tools are installed (distribution-agnostic method):

**Installation location:**
- SDK root: `~/Android/`
- Command-line tools: `~/Android/cmdline-tools/latest/`
- Platform tools (adb, fastboot): `~/Android/platform-tools/`

**Environment variables:**
```bash
export ANDROID_HOME="$HOME/Android"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
```

**Common adb commands:**
```bash
# List connected devices
adb devices

# Connect to device over WiFi (after initial USB connection)
adb tcpip 5555
adb connect <device-ip>:5555

# Install APK
adb install app.apk

# Pull/push files
adb pull /sdcard/file.txt ~/Downloads/
adb push ~/file.txt /sdcard/

# Shell access
adb shell

# View logs
adb logcat

# Reboot device
adb reboot
```

**Update SDK components:**
```bash
# Update all installed components
sdkmanager --update

# List available/installed packages
sdkmanager --list

# Install specific component
sdkmanager "platform-tools"
```

**USB device permissions:**
For USB device access, udev rules should be configured:
```bash
sudo -A tee /etc/udev/rules.d/51-android.rules << 'EOF'
SUBSYSTEM=="usb", ATTR{idVendor}=="*", MODE="0666", GROUP="plugdev"
EOF
sudo -A udevadm control --reload-rules
```

**Automated updates:**
Run `update-android-sdk` to check for and install updates to all SDK components.

## Automation Patterns

### Safe Batch Operations
```bash
# Preview first, then execute
find . -name "*.bak" -print           # Review
find . -name "*.bak" -delete          # Execute

# Or use xargs with confirmation
find . -name "*.tmp" | xargs -p rm
```

### Backup Before Modify
```bash
# Create timestamped backup
cp file.txt "file.txt.bak.$(date +%Y%m%d_%H%M%S)"
```

### Logging Script Output
```bash
# Redirect stdout and stderr to file and terminal
./script.sh 2>&1 | tee output.log
```

## Notes

### Claude Session Sudo Access
Sudo access is initialized on-demand from within the session:
- When Claude needs sudo, it will run a password prompt command - type your password when prompted
- Password is cached in `~/.cache/claude-sudo-token` (mode 600)
- Token is automatically cleared when the claude session exits
- If sudo stops working mid-session, Claude will re-prompt for password

### Key Locations
- User config: `~/.config/`
- System config: `/etc/`
- System logs: `/var/log/` (or use `journalctl`)
- Snap apps: `/snap/`, user config in `~/snap/`
- SSH keys: `~/.ssh/`

### Systemd
- Service control: `systemctl status|start|stop|restart|enable|disable servicename`
- Follow logs: `journalctl -u servicename -f`
- Recent logs: `journalctl -u servicename -e`
- Boot logs: `journalctl -b`

### Useful Alternatives (apt installable)
- `bat` (as `batcat`): syntax-highlighted cat - `sudo apt install bat`
- `fd-find` (as `fdfind`): faster, friendlier find - `sudo apt install fd-find`
- `ripgrep` (as `rg`): faster grep - `sudo apt install ripgrep`
- `ncdu`: interactive disk usage - `sudo apt install ncdu`
- `tldr`: simplified man pages - `sudo apt install tldr`

### Verifying Success
```bash
# Check last command exit status
echo $?    # 0 = success, non-zero = failure

# Chain commands (stop on failure)
cmd1 && cmd2 && cmd3

# Run regardless of previous success
cmd1; cmd2; cmd3

# Run only if previous failed
cmd1 || fallback_cmd
```
