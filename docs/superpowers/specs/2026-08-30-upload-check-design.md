# Check-on-upload: the family upload page (musicbox pass 2)

**Status: draft for pass 2, which kicks off as soon as pass 1 lands** (Geoff,
2026-08-30). Gets its adversarial review and implementation plan at kickoff; early
family-upload experience feeds the design if any exists by then, but is not a gate.

## What and why

A purpose-built upload page replaces FileBrowser for the family flow: drag an album
(ZIP or files) onto the page, and the server validates it before accepting — wrong
format rejected in the browser at upload time with the same friendly wording as the
pass-1 email, instead of minutes later by mail. The insight from pass 1: the family
never needed a file manager, only a drop target, and no file manager's upload filter
can see inside the ZIPs that are the primary upload unit.

## Shape (to be pressure-tested at kickoff)

- A small Go service on the musicbox VPS (single static binary, systemd unit, Go per
  the workstation go-conventions), published through the existing tunnel at the inbox
  hostname behind the existing Cloudflare Access policy.
- **No app-level login.** Cloudflare Access already authenticates the family; the
  service reads the Access JWT's verified email, maps it through contributors.yaml to
  the uploader's inbox directory, and writes there with the `music` uid. One login
  disappears from the family's life (Access PIN remains).
- Validation at upload: peek the ZIP central directory and each FLAC's STREAMINFO
  header — format, sample rate, bit depth are readable in the first few hundred bytes
  without decoding. Reject per-file with the pass-1 reason wording, rendered in the
  page. The pass-1 pipeline gate stays as the deep check (`flac -t` full decode);
  upload-time checks are the fast 95%, not a replacement.
- Accepted uploads land in `/srv/music/inbox/<user>/` exactly as FileBrowser's did;
  the pass-1 pipeline is unchanged.
- FileBrowser Quantum is then retired unless something still needs it, removing a
  single-maintainer dependency, a second login, and the estate's largest
  attack-surface component. (Admin file access over SSH is unaffected.)

## Kickoff questions (deliberately open)

- What did the first weeks of real family uploads reveal — does the email loop
  actually annoy anyone, and what rejection reasons dominate?
- Chunked/resumable upload need at family album sizes (~300-700 MB) over residential
  connections — plain multipart with generous timeouts, or tus-style resumability?
- Whether the pass-1 bring-up found FileBrowser Quantum post-upload hooks good enough
  to lower this pass's urgency.
- Mobile Safari drag-and-drop ergonomics for the iPad contributor (file picker
  fallback).

## Out of scope

Browsing, sharing, or managing files in the inbox; any change to the import pipeline,
review flow, or notification emails; music playback.
