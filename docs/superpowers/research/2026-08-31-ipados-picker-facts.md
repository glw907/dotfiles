# iPadOS Safari picker facts (documentary research 2026-08-31)

Attempted documentary closure of uploader gate 3. Three of six questions
closed; the rest need one probe-page run on any family iPad. Sources in
the session transcript; key ones inline.

## Closed by documentation

- webkitdirectory: CONFIRMED absent on iPadOS Safari (WebKit Bugzilla
  271705, open since 2024; MDN BCD's contrary claim is flagged wrong in
  mdn/browser-compat-data#11982). Degrades-to-normal-picker is
  standards-consistent inference.
- accept filtering: CONFIRMED unreliable in BOTH directions (fails to
  filter, or over-filters). Server-side rejection is mandatory - already
  dubplate's design.
- Picker-side size ceiling: none documented at selection/handoff. The
  File API hands a lazy reference; documented large-upload crashes
  (tus-js-client#146 NSMallocException >500MB) are in-page buffering,
  designed out by chunked Blob.slice. No first-person 2GB-from-iPad
  confirmation found; inference from tooling design.

## Design-changing finding

- WebKit UTI bug (root r250410): MIME-wildcard `audio/*` accepts can
  render audio files GREYED OUT and unselectable in Files - all sources
  (local, iCloud, Dropbox) equally (react-dropzone#1039, gradio#4021,
  openradar#19227). Field workaround: extension-based accept lists.
  RULING folded into plan U10: accept values extension-first, never bare
  audio/*. Currency on iPadOS 17/18 unverified - the probe's three
  accept variants settle it empirically.
- Multi-select gesture: on iPadOS the picker hides multi-select behind
  "... -> Select" (Apple dev forums). U10 copy must surface the gesture.

## Open - one probe run on any iPad answers

ZIP selection via accept=".zip"; audio/* greyout currency on current
iPadOS; webkitdirectory degradation shape; provider-specific multi-select
quirks; iPadOS 17->18 diffs (thinnest area). The published probe
(claude.ai artifact "Dubplate Picker Probe", accept-variant version)
records all of these in one two-minute tap-through by ANY family member;
no rig, cable, or farm required.
