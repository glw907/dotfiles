---
name: start-server
description: >
  Use when the user says "/start-server", "start the server",
  "run locally", or wants to start the local dev server.
  Also use with "stop", "kill", or "shut down" to stop a running server.
---

# Start Server

Start or stop the local Eudaimonia development server. No data
operations — use `/pull-data` separately if you need fresh
production data.

## Usage

`/start-server` — build and start wrangler dev server.
`/start-server stop` — stop the running dev server.

## Start

Run these steps in order:

1. **Build** (required — wrangler serves pre-built assets, not source):

```bash
npm run build
```

2. **Start wrangler dev in background** (use `run_in_background: true`):

```bash
npx wrangler dev
```

3. **Confirm it's up** (wait a few seconds, then check):

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:8787/
```

4. **Open browser in a new window** (not a tab):

```bash
firefox --new-window http://localhost:8787/ &
```

5. Report the URL: `http://localhost:8787`

The server stays up for the entire session. Do not poll or check on
it — you'll be notified if it exits.

## Refreshing after UI changes

After making UI changes, **rebuild, verify freshness, and refresh** the
existing browser window — never open a new tab or window:

```bash
npm run build 2>&1 | tail -3
```

Then verify the server is serving the current build:

```bash
# Extract the entry JS hash from the build output and the served page
BUILD_HASH=$(ls .svelte-kit/output/client/_app/immutable/entry/start.*.js | grep -oP 'start\.\K[^.]+')
SERVED_HASH=$(curl -s http://localhost:8787/ | grep -oP 'start\.\K[^.]+(?=\.js)')
if [ "$BUILD_HASH" = "$SERVED_HASH" ]; then
  echo "Build fresh: $BUILD_HASH"
else
  echo "STALE: built=$BUILD_HASH served=$SERVED_HASH — restart wrangler"
fi
```

If stale, kill and restart wrangler dev (step 2-3 from Start). Then refresh:

```bash
xdotool search --class firefox | tail -1 | xargs xdotool key --window F5
```

## Stop

```bash
pkill -f "wrangler dev"
```

Confirm the server has stopped.

## Notes

- First-time setup: if there's no local DB, run `npm run setup` first.
- The server uses the local D1 database in `.wrangler/state/`.
- Wrangler's default port is 8787.
- `wrangler dev` serves pre-built assets. Always `npm run build` after
  source changes before expecting them in the browser.
