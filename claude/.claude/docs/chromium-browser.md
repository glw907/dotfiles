# Chromium on thinkpad-x1

Chromium is the only browser on this workstation. Google Chrome and Firefox were both removed
on 2026-08-16. Never suggest reinstalling either to solve a problem. If a task genuinely needs
a second engine, say so and let Geoff decide.

## The install

Mint's own `chromium` deb, not a snap. The snap build is specifically wrong here: its sandbox
blocks native messaging, which would break the Claude in Chrome extension.

- Binary: `/usr/bin/chromium`, a wrapper script around `/usr/lib/chromium/chromium`
- Invoke it as `chromium`. Not `google-chrome`, not `chromium-browser`
- Desktop entry: `chromium-browser.desktop` (the entry name keeps the old spelling; the
  `Exec` line is plain `chromium`)
- Projects grant `Bash(chromium:*)`. A leftover `Bash(google-chrome:*)` in any settings file
  is dead and should be rewritten.

## Telemetry is off by managed policy

The policy file is `/etc/chromium/policies/managed/no-google-telemetry.json`, owned by root.
Policy beats preferences, so nothing in the Chromium UI can switch these back on, and a
reinstall does not clear them. Chromium reads the file at startup, so a policy change needs a
browser restart to take effect.

Every key below was verified present in the 151.x binary before the file was written. Verify
again after a major version bump:

```bash
for p in MetricsReportingEnabled ChromeVariations SafeBrowsingProtectionLevel; do
  strings -a /usr/lib/chromium/chromium | grep -qx "$p" && echo "OK $p" || echo "MISS $p"
done
```

What it disables: metrics and crash reporting, the variations seed fetch, domain reliability,
URL-keyed anonymized collection, Safe Browsing and its extended reporting, search suggestions,
the spell-check service, the Privacy Sandbox surfaces, background mode, shopping, promotions.

The same file also forces DNS-over-HTTPS to Cloudflare in `secure` mode, which means no
cleartext DNS fallback. Swap the resolver by editing `DnsOverHttpsTemplates`.

To confirm the policy actually loaded, watch the loader say so:

```bash
chromium --headless=new --no-sandbox --user-data-dir=/tmp/probe \
  --enable-logging=stderr --vmodule='*config_dir_policy*=2' about:blank 2>&1 |
  grep -i 'policy file'
```

A clean run prints `Found mandatory policy file: /etc/chromium/policies/managed/...`. The
absence of `variations_compressed_seed` in that throwaway profile's `Local State` is the proof
that `ChromeVariations: 2` stopped the seed fetch.

**Do not quietly relax an entry to make a task easier.** Raise it with Geoff instead.

## Two deliberate trade-offs

`SafeBrowsingProtectionLevel: 0` means no malicious-site or dangerous-download warnings. This
buys privacy at a real security cost, because even standard Safe Browsing sends hashed URL
prefixes to Google. Set it to `1` to restore standard protection.

`ChromeVariations: 2` blocks the variations seed, which is also how Google ships emergency
killswitches between releases. Mint's apt updates are the patch channel instead. Set it to `1`
for critical fixes only.

`DnsOverHttpsMode: "secure"` will break captive portals, the sign-in pages at hotels and
airports, because those hijack DNS and secure mode refuses to fall back. On a laptop this
will happen. Switch the value to `automatic` before travelling, or edit it on the spot:

```bash
sudo -A sed -i 's/"secure"/"automatic"/' /etc/chromium/policies/managed/no-google-telemetry.json
```

Restart Chromium after either edit.

## Web development helpers

`chromium-shot` (in `~/.dotfiles/bin/.local/bin/`, stowed to `~/.local/bin`) renders a URL or
local file with headless Chromium using a throwaway profile, so it works while the browser is
open. It does viewport PNGs at any size, a full-document PDF, and a rendered DOM dump. Run
`chromium-shot -h` for the flags. It deliberately does not do full-page PNG with lazy-loaded
content, because that needs a driver that scrolls first; use Playwright's `fullPage` for
visual-fidelity work, which the `visual-fidelity` skill already requires.

The `chrome-devtools` MCP server is registered at user scope and pinned to this Chromium:

```
npx -y chrome-devtools-mcp@latest --executablePath /usr/bin/chromium
```

It drives a dedicated persistent profile under `~/.cache/chrome-devtools-mcp/`, separate from
daily browsing, so logging in there once is safe. This is what the `cloudflare:web-perf` skill
needs for Core Web Vitals and tracing.

Browser tools are wired per-directory, not globally, because they cost context in every
session. The `claude()` function in `~/.dotfiles/bash/.bashrc` adds `--chrome` inside the web
repos (all six SvelteKit repos, plus `asc-*` and the Hugo blogs) and leaves Go work such as
poplar and jrnl-md lean. Pass `--no-chrome` to opt out, or `--chrome` to force it on
elsewhere. Add a new web repo to the `case` list in that function.

## When claude.ai login loops

A login that bounces back to the login screen usually means a half-finished auth attempt left
stale state, with a `return-to` or `g_state` cookie sitting beside a fresh `sessionKey`.
Clearing that one site fixes it. Close Chromium first, since it holds the databases open:

```bash
pkill -x chromium
python3 - <<'PY'
import sqlite3, os
c = sqlite3.connect(os.path.expanduser('~/.config/chromium/Default/Cookies'))
c.execute("delete from cookies where host_key like '%claude.ai'")
c.commit()
PY
rm -rf ~/.config/chromium/Default/IndexedDB/*claude.ai*
```

Do not reach for this before checking `chrome://settings/cookies`, and do not blame the
managed policy: nothing in it blocks cookies, and the profile's cookie settings stay at their
defaults.

## Claude in Chrome

The extension installs from the Chrome Web Store and runs in Chromium normally. Claude Code
supports Chromium explicitly, alongside Chrome, Edge, Brave, Arc, Vivaldi, and Opera.

The native messaging host belongs at
`~/.config/chromium/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`.
Claude Code writes it the first time Chrome integration is enabled, via `claude --chrome` or
`/chrome`. Chromium reads that directory at startup, so restart the browser after the file
first appears. If `/chrome` reports the extension as not detected while it is enabled in
`chrome://extensions`, check that this path exists before debugging anything else.

## Extensions are installed by policy

`/etc/chromium/policies/managed/extensions.json` installs the Claude and 1Password extensions
with `installation_mode: normal_installed` and `toolbar_pin: default_pinned`. That auto-installs
them into any profile and pins them, while still letting Geoff disable, remove, or unpin either
one. Do not switch these to `force_installed`, which takes that control away.

- Claude: `fcoeoabgfenejglbffodgkkbkcdhcgfn`
- 1Password: `aeblfdkhhhdcdjpifhhbdiojplfjncoa`

The authoritative source for a 1Password extension id is the desktop app's own native messaging
manifest, which allow-lists the ids permitted to talk to it. Read that rather than guessing from
a store listing.

## 1Password

`/etc/chromium/policies/managed/1password.json` hands credentials to 1Password by turning off
Chromium's competing features: `PasswordManagerEnabled`, `PasswordLeakDetectionEnabled` (which
would ship hashed credentials to Google), `AutofillAddressEnabled`, and
`AutofillCreditCardEnabled`.

The desktop app's native messaging host sits at
`~/.config/chromium/NativeMessagingHosts/com.1password.1password.json` and points at
`/opt/1Password/1Password-BrowserSupport`. Desktop-app integration requires the extension and
the app to be on the same major version; 8.12.32 paired with extension 8.12.32.33 as of
2026-08-16.

Chrome-era saved passwords do not transfer, so 1Password is the only password path here.

## Playwright is unaffected

Every Playwright config on this machine uses Playwright's own bundled Chromium under
`~/.cache/ms-playwright`, and none pins `channel: 'chrome'`. Keep it that way. A
`channel: 'chrome'` pin would fail here, because no Chrome binary exists to satisfy it. The
managed policy does not touch Playwright, since those browsers are not the system Chromium.

## Leftovers from the removal

- `~/.config/google-chrome` (630M) and `~/.config/mozilla` (1.5G) are retained but orphaned.
  Delete them only on Geoff's explicit say-so.
- Chrome-era saved passwords cannot be read by Chromium. Each browser encrypts its login
  database against its own keyring entry, so the values only decrypt under a reinstalled
  Chrome. 1Password is the working password path.
- The google-chrome apt repo is disabled at
  `/etc/apt/sources.list.d/google-chrome.{list,sources}.disabled`. Re-enable by dropping the
  `.disabled` suffix.
- `mintchat` was purged with Firefox, which it depended on. `sudo -A apt install mintchat`
  restores it.
- Bookmarks from both browsers were merged into the Chromium profile. Firefox's landed under
  Other bookmarks in a folder named "Imported from Firefox".
