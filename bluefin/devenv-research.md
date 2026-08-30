# Bluefin DX Dev Environment Research (Aug 2026)

Scope: clean, idiomatic, atomic-friendly dev setup for a Bluefin DX thinkpad-x1 workstation, covering Go/bubbletea, Node/SvelteKit+Cloudflare, Python, and Android/adb, plus running Claude Code against it. Confidence tags: **[High]** official docs / multiple corroborating sources, **[Med]** single good source or maintainer discussion, **[Low]** forum anecdote / inference, **[Unsettled]** genuinely contested in the community as of Aug 2026.

---

## 1. What Bluefin itself recommends

**[High]** Bluefin's own philosophy is explicit separation of OS from dev tooling: "development is done in containers." The docs (docs.projectbluefin.io/bluefin-dx/) and the `projectbluefin/documentation` repo converge on a **layered model**, not a single answer:

- **Devcontainers — the flagship, recommended pattern** for project work. Rationale given directly in the docs: config lives in the repo (version-controlled, cross-platform Linux/macOS/Windows-WSL), so teammates on other OSes aren't second-class, and there's "no need to install programming languages and runtimes on the host." VS Code ships with the Dev Containers extension pre-installed and Docker Engine as the default runtime for it.
- **Distrobox / "pet containers"** — for traditional distro package managers (apt/dnf/pacman) or specific tools not packaged as Flatpak/Homebrew/devcontainer features. Explicitly framed as secondary/complementary to devcontainers, not a dev-environment replacement. Managed via DistroShelf GUI or Ptyxis's built-in distrobox integration (Ctrl-Alt-Enter).
- **Homebrew** — for host-scoped CLI tools "when containerization isn't preferred," especially cross-project utilities (ripgrep, gh, jq, etc.). The docs explicitly say this is "less recommended than declaring project dependencies in version control" — i.e., Homebrew is the *fallback* tier, not the primary one, in Bluefin's own framing. It's paired with mise for version pinning.
- Flatpak remains the GUI-app tier (unchanged, not central to this research).

**[Med, recent]** "DX Next" (per PR #288 on `projectbluefin/common` and 2026 discourse threads) is consolidating: base Bluefin image is gaining containerd/Docker so the separate DX image matters less over time, plus Podman Quadlets for Cockpit/Incus/Libvirt integration and systemd units for rootful/rootless Docker daemons. Direction of travel is toward *less* need for a distinct "DX" layer and more toward containers/VMs as the default dev substrate regardless of which Bluefin variant you're on. This is in-flight, not finalized — treat as **[Unsettled]** exactly how it lands.

Sources:
- https://docs.projectbluefin.io/bluefin-dx/
- https://github.com/projectbluefin/documentation/blob/main/docs/bluefin-dx.md
- https://universal-blue.discourse.group/t/bluefin-rely-on-oci-layer-sharing-for-distrobox-and-devcontainer/6519
- https://github.com/projectbluefin/common/pull/288
- https://github.com/ublue-os/bluefin/discussions/3847 (removing bundled VS Code — signals de-emphasis of a single blessed IDE)
- https://github.com/ublue-os/bluefin/issues/3879 ("Remove the need for a dedicated DX image")

---

## 2. Devcontainers vs distrobox vs toolbox vs host mise/brew — when each fits

**[High]** No single tool wins across the board; experienced atomic-desktop users converge on a **tiered decision**, roughly:

| Tier | Use for | Why |
|---|---|---|
| **Host (Homebrew + mise)** | Cross-project CLI utilities, git/gh, small scripts, anything you want available instantly in every terminal without an `enter` step | Zero friction, self-contained under `/home/linuxbrew/.linuxbrew`, "can be blown away without interfering with the system" (Brian Ketelsen). Bluefin's own docs and Ketelsen's field report both put "basic shell tools" here. |
| **Devcontainers (Docker)** | Per-project language runtimes and toolchains that need to be reproducible and shareable with non-Linux teammates (Node/SvelteKit, anything with a team) | Config in git, works identically on macOS/Windows-WSL, matches Bluefin's official recommended pattern, and is what Claude Code's own devcontainer feature targets. |
| **Distrobox/toolbox (pet containers)** | Distro-specific package managers, one-off native tool installs, Android SDK/adb-heavy workflows, anything needing host display/USB/GPU integration that devcontainers make awkward | Shares home dir + network + PID namespace with host by default (unlike devcontainers), so USB/display/adb "just work" much more easily. |
| **Incus/libvirt VM** | Complex multi-service stacks, or when you want disposable, fast-boot (<5s) pre-built images with Nix/Homebrew baked in | Mentioned by Ketelsen as his tier for "complex projects" — heavier isolation than containers, still fast with Incus. Given the owner is already in the incus-admin/libvirt groups, this tier is available for free. |

**[Med]** Community consensus by project type, synthesized from the sources found (this is genuinely still settling — flag as **[Unsettled]** at the edges):
- **Go development**: Mixed. Devcontainer is fine and reproducible, but Go's toolchain is trivial to pin with `mise` (or just `go.mod`'s `go` directive + `mise` for the compiler version), and Go binaries are static/self-contained, so many Go devs on atomic desktops skip containers entirely and use host mise + a plain toolbox only if they need cgo/native deps. For a **bubbletea TUI app** specifically, a devcontainer works (VS Code/Ptyxis terminal both attach fine), but there's no strong pull toward containerizing purely for the TUI — nothing about bubbletea needs isolation.
- **Node/SvelteKit + Cloudflare/wrangler**: Devcontainer is the more strongly recommended tier here — Node dependency trees are messier, native addons more common, and Wrangler/`nodejs_compat` version sensitivity benefits from a pinned, shareable image. This matches Bluefin's own framing (docs explicitly cite Node-style stacks as the devcontainer use case). No devcontainer-specific Wrangler/Cloudflare gotchas surfaced in search beyond the generic "wrangler dev needs network egress" (relevant to Claude Code's firewall discussion below).
- **Python**: Split opinion **[Unsettled]**. `uv` is fast and self-contained enough that many people now treat it like Go — host-level (`uv tool install`, per-project `.venv` via `uv sync`) — and skip containers for pure-Python CLI utilities. Devcontainers are still favored when the project needs system libraries (native wheels, GPU/CUDA, etc.) beyond what `uv` manages. For the owner's stated Python tools (khard, vdirsyncer, yt-dlp — all personal CLI utilities, not deployable services), host-level `uv tool install` is the natural fit and matches what's already in place.
- **Android/adb tooling**: distrobox, not devcontainer — devcontainers isolate USB/udev by default and require extra passthrough config; distrobox's shared-namespace model makes adb "just work" much more often (see §4).

Sources:
- https://brian.dev/articles/how-i-bluefin/
- https://falcao.org/posts/distrobox-toolbox-podman-docker/
- https://github.com/89luca89/distrobox/discussions/1305
- https://sreake.com/en/blog/stop-worrying-about-ai-wrecking-your-code-a-template-for-unified-development-environments-using-dev-containers-and-mise/
- https://www.milkstraw.ai/blog/devcontainer-to-mise-migration (explicit "we replaced devcontainers with mise" case study — direct evidence for the **[Unsettled]** framing)
- https://blog.ace-dev.me/posts/2025/04/how-we-use-mise-at-work-part-2/

---

## 3. Running Claude Code against devcontainer/distrobox projects

**[High]** Claude Code has **first-class, documented devcontainer support** (code.claude.com/docs/en/devcontainer, formerly docs.anthropic.com/en/docs/claude-code/devcontainer):
- Official `ghcr.io/anthropics/devcontainer-features/claude-code` devcontainer feature — drop into any `devcontainer.json`, installs Claude Code (and Node if missing) into the container.
- Claude Code then **runs inside the container** — when opened via VS Code/Codespaces/JetBrains, the integrated terminal, language servers, build tools, and Claude Code all execute inside; only the editor UI and the bind-mounted repo live on the host.
- Auth/config persistence across rebuilds requires mounting a named volume at `~/.claude` **and** setting `CLAUDE_CONFIG_DIR` to the same path (because `~/.claude.json` lives outside `~/.claude` and holds the OAuth token/MCP config).
- A reference hardened container (`anthropics/claude-code/.devcontainer`) ships a default-deny iptables firewall (`init-firewall.sh`) requiring `NET_ADMIN`/`NET_RAW` capabilities, which is what officially licenses `--dangerously-skip-permissions` for unattended use — the docs explicitly warn that *without* egress restriction, skip-permissions mode inside a container can still exfiltrate anything reachable, including `~/.claude` credentials, so **don't mount `~/.ssh` or cloud creds into an agent-driven devcontainer.**
- Official comparison doc (`sandbox-environments`) puts dev containers at "medium" setup effort, requiring Docker, appropriate for "standardize a sandboxed environment across a team" and for unattended `--dangerously-skip-permissions`/auto-mode work.

**[Med]** Running Claude Code **on the host, driving a containerized build** (i.e., host Claude Code shelling out to `distrobox enter -- cmd`, `docker exec`, or `mise` tasks that themselves call into a container) is a **workable, commonly-used pattern but not what the official docs describe** — the docs' model is "Claude Code runs inside the container." Evidence found:
- There is at least one published "Distrobox container manager" skill for Claude Code (mcpmarket.com listing, "for Bazzite") that explicitly automates distrobox orchestration from a host-side Claude Code session — i.e., people are building tooling for exactly this pattern.
- A blog post (akitaonrails.com, Apr 2026) describes running Claude Code against an "emulation distrobox," i.e., host-driven agent orchestrating a distrobox for a specialized workload.
- This matches how the owner's existing stack (mise tasks, Brewfile, Docker present) would naturally be driven: Claude Code on host, using `mise run build`/`mise run test` as the uniform entry point, where those tasks internally call `distrobox enter mybox -- go build ...` or `docker compose exec ...` as needed. This is idiomatic *for this specific mixed setup*, but **note it forfeits the isolation benefits** Claude Code's own docs assume (the container-as-security-boundary story only holds if Claude Code itself is inside the boundary — see §4/§5).

**[High]** For build/test loops that don't need agent sandboxing (i.e., trusted first-party repos, interactive supervised use — which matches "Claude Code runs on the host and needs to build/test these projects" as stated), host-side Claude Code invoking `mise` tasks (which may shell into distrobox/docker as needed) is a completely standard and supported way to work — it's just outside the "isolate the agent" story that the devcontainer feature is built for. If/when the owner wants unattended (`--dangerously-skip-permissions` or auto mode) runs, the guidance is unambiguous: **put Claude Code itself inside the container/VM boundary at that point**, not just the build tooling.

Sources:
- https://code.claude.com/docs/en/devcontainer
- https://code.claude.com/docs/en/sandbox-environments
- https://mcpmarket.com/tools/skills/distrobox-container-manager-for-bazzite
- https://akitaonrails.com/en/2026/04/11/emulation-distrobox-with-claude-code/

---

## 4. Sharp edges

**[High] SELinux + bind mounts**: The classic Fedora-atomic gotcha applies to any container tooling here.
- Use `:Z` (private) or `:z` (shared) suffixes on bind mounts so SELinux relabels correctly; omitting them causes cryptic permission-denied errors.
- **Never** apply `:Z`/`:z` to a mount of a broad host directory like `/home` or `/usr` — it recursively relabels and can render the host unusable. Scope mounts to the specific project dir.
- Devcontainer-specific: if a devcontainer fails to start with SELinux errors, `restorecon -R -v $HOME/.local/share` (config-store issue) or `restorecon -R -v /path/to/project` (mount issue) are the documented fixes; alternatively `--security-opt label=disable` when mounting home-relative paths, at the cost of the SELinux boundary.

**[Med] Homebrew PATH vs host binaries**: A real, documented, still-somewhat-open issue (ublue-os/bluefin#687): Homebrew packages (e.g. `p11-kit`) can shadow host system libraries via PATH ordering and break unrelated things (Steam/Discord Flatpaks broke via SSL cert resolution in that case). Maintainer comment acknowledges this could generalize to "a bunch of other stuff." **Practical mitigation**: keep Homebrew's install set narrow and CLI-tool-focused (which matches the owner's current Brewfile — go, gh, git, jq, pandoc, hugo, imagemagick, ffmpeg are all "leaf" CLI tools, not libraries other things link against, so this specific failure mode is low-risk for the current Brewfile, but worth remembering before adding brew packages that ship shared libs).

**[Low/Unsettled] mise inside vs outside containers**: Genuinely split in the wild.
- Inside-container camp: mise inside the devcontainer Dockerfile/setup gives a portable, reproducible per-project tool matrix that travels with the repo (sreake.com, rezachegini.com, Acesyde blog — all 2025).
- Host-only camp: at least one documented migration *away* from devcontainers back to host-level mise, citing weekly "container won't start" debugging overhead vs. mise's near-zero friction, explicitly trading team-wide reproducibility for developer velocity (milkstraw.ai, "Replacing Dev Containers: Reducing Setup Time from Minutes to Seconds").
- For the owner's setup specifically: since Node is already on host via mise, and the plan is devcontainers for SvelteKit projects, the practical resolution is: **`.mise.toml` per repo either way** (it's cheap and gives you a single command surface — `mise run build`/`mise run test` — that works identically whether that repo currently lives on host or inside a devcontainer), and let the devcontainer's Dockerfile install/activate mise itself for that project rather than trying to share the host's mise state into the container.

**[High] Docker rootful vs rootless / Podman default**: Podman is Bluefin's system default and is rootless-by-default (rootless is the primary supported mode, not an afterthought). Docker CE is *also* pre-installed on DX specifically because VS Code's Dev Containers extension defaults to expecting a Docker socket — Bluefin ships both engines side by side for this reason. Docker's rootless mode exists but is officially described (in general Docker docs, corroborated by the search) as more of an opt-in mode with narrower feature support than Podman's rootless-first design. **Practical implication**: keep using Docker (already present, already the DX default) for devcontainers/VS Code integration; if driving containers directly from scripts/mise tasks rather than through VS Code, Podman is the more "native" Bluefin choice and can be pointed at from VS Code too via `dev.containers.dockerPath: podman` + the rootless podman socket path — but this is a per-preference switch, not something the docs say you must do.

**[Med] ptrace / Go debugging in containers**: `CAP_SYS_PTRACE` is not granted by default in rootless containers. To run Delve inside a devcontainer/distrobox for a bubbletea app, add `--cap-add=SYS_PTRACE --security-opt seccomp=unconfined` (or the devcontainer.json `runArgs` equivalent: `"capAdd": ["SYS_PTRACE"], "securityOpt": ["seccomp=unconfined"]`). Without this, `dlv debug`/`dlv attach` inside the container fails or is severely restricted. This is a generic container-Delve issue, not Bluefin-specific, but easy to trip over.

**[Med] USB/adb passthrough for Android tooling**: Distrobox handles this far more gracefully than devcontainers because pet containers share the host's PID/network namespace and (as of distrobox 1.8.1.2+) adb reportedly works out of the box in rootless containers. If it doesn't on your version, the fallback is explicit volume mounts: `--volume /dev/bus/usb:/dev/bus/usb --volume /etc/udev/rules.d:/etc/udev/rules.d` plus a udev rule keyed to the device's vendor/product ID (`lsusb` to find it), `MODE="0666" GROUP="<user>"`. Devcontainers would need the equivalent `runArgs`/`mounts` config and generally fight you more, since the whole devcontainer model assumes no host device access by default — **this is the strongest single argument in this research for keeping Android/adb work in distrobox rather than devcontainers.**

Sources:
- https://github.com/ublue-os/bluefin/issues/687
- https://universal-blue.discourse.group/t/default-path-hierarchy-homebrew-and-user-binaries/4243
- https://github.com/89luca89/distrobox/blob/main/docs/README.md
- https://discussion.fedoraproject.org/t/how-to-bind-mount-additional-directories-in-toolbox/19793
- https://dev.to/archerallstars/running-adb-in-a-rootless-podman-distrobox-container-2kap
- https://github.com/go-delve/delve/issues/1741
- https://lucaberton.com/blog/podman-vs-docker-2026/

---

## 5. Recommended tiering for this machine

Given the owner's stated priorities (idiomatic-Bluefin, atomic-friendly, minimal host footprint, project-scoped toolchains, reproducible, Claude Code running on host driving builds), and everything above:

**Keep as-is (already correct per Bluefin's own guidance):**
- **Homebrew Brewfile** for the CLI estate (go, gh, git, jq, pandoc, hugo, imagemagick, ffmpeg) — this is exactly Bluefin's documented host tier for cross-project CLI tools, and the current package list is all "leaf" tools with low PATH-shadowing risk.
- **`uv`** for personal Python CLI utilities (khard, vdirsyncer, yt-dlp) — these aren't deployable services, they're host tools; `uv tool install` is the right tier, no container needed.
- **Flatpak** for GUI apps, **4 layered RPMs** (1password, 1password-cli, firefox, chromium) — unaffected by this research, standard practice.

**Per-project tiering to adopt:**

| Project type | Tier | Scaffolding |
|---|---|---|
| **Go CLI/TUI (bubbletea)** | **Host mise**, not container, unless a project needs cgo/native deps | `.mise.toml` pinning `go`; `mise.toml` tasks for `build`/`test`/`lint`. Add a `distrobox.ini`-based box only if a specific project needs cgo cross-compilation toolchains you don't want on host. |
| **Node/SvelteKit → Cloudflare (wrangler)** | **Devcontainer** | `.devcontainer/devcontainer.json` with a Node base image + `ghcr.io/anthropics/devcontainer-features/claude-code` feature if you want Claude Code running inside it for unattended work; otherwise keep Claude Code on host and add a `.mise.toml` with a `dev`/`build`/`deploy` task that runs `docker compose exec` (or just relies on the devcontainer being opened separately in VS Code when needed). Pin `wrangler` version in `package.json`/devcontainer Dockerfile, not host mise. |
| **Python utilities (project-scoped, not personal tools)** | **Host `uv`** for pure-Python; escalate to devcontainer only if native/system deps are needed | `pyproject.toml` + `uv.lock`; `.mise.toml` optional if you want a uniform `mise run` surface across repos. |
| **Android/adb tooling** | **Distrobox**, not devcontainer | A `distrobox.ini`/assemble file (see `ublue-os/toolboxes` for examples) with `/dev/bus/usb` and `/etc/udev/rules.d` mounted; add udev rules for your device's vendor/product ID once. |
| **Claude Code itself** | **Host**, driving `mise` tasks that dispatch into distrobox/docker as needed, for day-to-day supervised work (matches "Claude Code runs on the host and needs to build/test these projects") | If/when you want `--dangerously-skip-permissions` or unattended/auto-mode runs on any of the above, move Claude Code *inside* that project's container (devcontainer feature, or a distrobox with Claude Code installed) rather than relying on host-level Claude Code + container-only build tooling — the isolation story only holds if the agent process itself is inside the boundary. |

**Contradictions with / refinements to current setup:**
- Nothing in the current setup is wrong per Bluefin's own guidance — Homebrew for CLI, mise for Node, uv for Python, Docker present, Flatpak for GUI, layered RPMs for a handful of apps is *exactly* the pattern Bluefin's docs describe (with Homebrew explicitly framed as an acceptable fallback tier, not an anti-pattern).
- The one real gap: **no devcontainers yet for the SvelteKit/Cloudflare projects**, which is where Bluefin's docs and the community most strongly agree containers add value (team portability, Wrangler/Node version pinning) — worth adding per-repo as those projects mature, rather than a big-bang migration.
- **Watch the Homebrew package list** for anything that installs shared libraries (not just leaf binaries) going forward, given the documented PATH-shadowing failure mode (#687) — current Brewfile looks safe, but this is a "don't add libpq/openssl/etc via brew casually" caution, not an action item today.
- If any project needs Delve debugging inside a container later, remember `--cap-add=SYS_PTRACE` up front rather than discovering it mid-debug session.

---

## Overall confidence / recency note

Most claims here are corroborated across at least two independent sources (official Bluefin docs + community discourse/blog, or official Claude Code docs + third-party usage evidence), dated within the last ~12 months. The genuinely **unsettled** areas, explicitly called out above, are: (1) exactly how "DX Next" consolidates devcontainer/distrobox/homebrew tiers going forward, (2) whether mise-on-host or mise-in-devcontainer is the "right" default for team projects, and (3) whether Python specifically should default to devcontainer or host `uv` — the community is visibly split on all three as of August 2026, and Bluefin's docs themselves say explicitly "you do not need to use everything in here... at the end of the day it's your computer," i.e., the project deliberately declines to force a single answer.
