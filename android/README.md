# Android SDK Setup

Instructions for setting up Android SDK Command-line Tools on Ubuntu/Linux Mint.

## Installation

### 1. Download Command-line Tools

Visit the official Android developer site and download the latest command-line tools:
https://developer.android.com/studio#command-line-tools-only

Or use wget (update version number as needed):

```bash
cd ~/Downloads
wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
```

### 2. Extract and Setup Directory Structure

```bash
# Create Android SDK directory
mkdir -p ~/Android/cmdline-tools

# Extract the downloaded tools
cd ~/Android/cmdline-tools
unzip ~/Downloads/commandlinetools-linux-*_latest.zip

# Rename to 'latest' (required directory name)
mv cmdline-tools latest
```

### 3. Add to PATH

Add these lines to your `~/.bashrc` (already included if you used the dotfiles setup):

```bash
export ANDROID_HOME="$HOME/Android"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
```

Then reload:

```bash
source ~/.bashrc
```

### 4. Accept Licenses and Install Platform Tools

```bash
# Accept SDK licenses
sdkmanager --licenses

# Install platform tools (adb, fastboot, etc.)
sdkmanager "platform-tools"
```

### 5. Setup USB Device Permissions (for adb)

```bash
# Create udev rules for Android devices
sudo -A tee /etc/udev/rules.d/51-android.rules << 'EOF'
SUBSYSTEM=="usb", ATTR{idVendor}=="*", MODE="0666", GROUP="plugdev"
EOF

# Reload udev rules
sudo -A udevadm control --reload-rules

# Add your user to plugdev group (if not already)
sudo -A usermod -aG plugdev $USER
```

Log out and back in for group changes to take effect.

## Verify Installation

```bash
# Check sdkmanager is available
sdkmanager --version

# Check adb is available
adb version

# List installed packages
sdkmanager --list_installed
```

## Common Commands

### ADB (Android Debug Bridge)

```bash
# List connected devices
adb devices

# Connect via WiFi (after initial USB connection)
adb tcpip 5555
adb connect 192.168.1.xxx:5555

# Install APK
adb install app.apk

# Copy files
adb pull /sdcard/file.txt ~/Downloads/
adb push ~/file.txt /sdcard/

# Shell access
adb shell

# View logs
adb logcat

# Reboot device
adb reboot
```

### SDK Manager

```bash
# Update all components
sdkmanager --update

# List available packages
sdkmanager --list

# Install specific component
sdkmanager "platforms;android-34"
sdkmanager "build-tools;34.0.0"

# Use the custom update script (included in dotfiles)
update-android-sdk
```

## Directory Structure

After setup, your Android SDK should look like:

```
~/Android/
├── cmdline-tools/
│   └── latest/
│       └── bin/
│           ├── sdkmanager
│           └── ...
└── platform-tools/
    ├── adb
    ├── fastboot
    └── ...
```

## Troubleshooting

### "Command not found: sdkmanager"

Make sure `ANDROID_HOME` is set and the path is correct:

```bash
echo $ANDROID_HOME
which sdkmanager
```

If not found, reload your shell configuration:

```bash
source ~/.bashrc
```

### "adb: no permissions"

Check USB permissions and udev rules:

```bash
# Check if device is detected
lsusb

# Check udev rules are in place
cat /etc/udev/rules.d/51-android.rules

# Reload udev
sudo -A udevadm control --reload-rules

# Try unplugging and replugging the device
```

### "Failed to connect via WiFi"

Ensure device and computer are on the same network:

```bash
# First connect via USB
adb devices

# Enable TCP/IP on port 5555
adb tcpip 5555

# Find device IP (in Android: Settings > About > Status > IP address)
# Then connect
adb connect 192.168.1.xxx:5555
```

## Notes

- The Android SDK is distribution-agnostic and doesn't require apt/snap
- Updates are managed through `sdkmanager`, not system package managers
- The `update-android-sdk` script (included in dotfiles) automates updates
- SDK is self-contained in `~/Android/` and can be easily backed up or moved
