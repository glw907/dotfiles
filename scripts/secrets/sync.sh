#!/usr/bin/env bash
set -euo pipefail

# Workstation secrets sync — decrypts values.age and pushes secrets to local and Cloudflare targets.
# Requires: 1Password CLI authenticated (eval $(op signin) before use).
#
# Usage:
#   sync.sh               # Sync local + all workers
#   sync.sh --local       # Local secrets only (no worker push)
#   sync.sh --worker NAME # Push to a single named worker
#   sync.sh --dry-run     # Show what would be pushed, no changes made
#   sync.sh --verify      # Diff targets vs registry; exits non-zero if mismatch
#
# Design notes:
#   - Private age key lives in 1Password only — never on disk persistently.
#   - Decrypted secrets written to /dev/shm (tmpfs, not persisted to disk).
#   - Trap ensures shred cleans up temp files even if script exits early.
#   - Use count=$((count + 1)) not ((count++)) — the latter aborts under set -e.

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SECRETS_FILE="$DOTFILES_DIR/secrets/values.age"
LOCAL_SECRETS="$HOME/.local/secrets"

# Temp files in /dev/shm (memory-backed, not written to disk)
AGE_KEY_FILE="/dev/shm/age-key-$$.txt"
DECRYPTED_FILE="/dev/shm/secrets-$$.txt"

# Cleanup on any exit
trap 'shred -u "$AGE_KEY_FILE" "$DECRYPTED_FILE" 2>/dev/null; true' EXIT

# --- Worker routing table ---
# Maps worker name -> space-separated list of secrets to push
declare -A WORKER_SECRETS
WORKER_SECRETS["907-life"]="CLOUDFLARE_API_TOKEN RESEND_API_KEY"
# cairn-cms admin (shared GitHub App — one app installed on both repos). Per-site
# MAGIC_LINK_SECRET/SESSION_SECRET are NOT managed here (worker-only, rotatable —
# set directly via `wrangler secret put`; they must differ per site for session isolation).
WORKER_SECRETS["ecnordic"]="GITHUB_APP_ID GITHUB_APP_INSTALLATION_ID GITHUB_APP_PRIVATE_KEY_B64"

# --- Argument parsing ---
MODE="all"
WORKER_TARGET=""
DRY_RUN=false
VERIFY=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --local)
            MODE="local"
            shift
            ;;
        --worker)
            if [[ -z "${2:-}" ]]; then
                echo "Error: --worker requires a worker name argument." >&2
                exit 1
            fi
            MODE="worker"
            WORKER_TARGET="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verify)
            VERIFY=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: sync.sh [--local] [--worker NAME] [--dry-run] [--verify]" >&2
            exit 1
            ;;
    esac
done

# --- Verify mode: diff targets vs registry ---
if [[ "$VERIFY" == true ]]; then
    echo "=== Verify mode ==="
    FAILED=false

    # Check local secrets
    if [[ -f "$LOCAL_SECRETS" ]]; then
        echo "Local (~/.local/secrets): present"
        # List keys present in local secrets
        while IFS='=' read -r key _; do
            [[ "$key" =~ ^export\ ([A-Z_]+)$ ]] && echo "  ✓ ${BASH_REMATCH[1]}"
        done < "$LOCAL_SECRETS"
    else
        echo "Local (~/.local/secrets): MISSING" >&2
        FAILED=true
    fi

    echo ""

    # Check each worker
    for worker in "${!WORKER_SECRETS[@]}"; do
        echo "Worker: $worker"
        EXPECTED_KEYS="${WORKER_SECRETS[$worker]}"
        ACTUAL_KEYS=$(npx wrangler secret list --name "$worker" 2>/dev/null \
            | grep '"name"' | sed 's/.*"name": "\([^"]*\)".*/\1/' | sort)

        for key in $EXPECTED_KEYS; do
            if echo "$ACTUAL_KEYS" | grep -q "^${key}$"; then
                echo "  ✓ $key"
            else
                echo "  ✗ $key MISSING" >&2
                FAILED=true
            fi
        done

        # Report extra keys (present on worker but not in registry)
        for actual_key in $ACTUAL_KEYS; do
            if ! echo "$EXPECTED_KEYS" | grep -qw "$actual_key"; then
                echo "  ~ $actual_key (extra — not managed by this registry)"
            fi
        done
    done

    if [[ "$FAILED" == true ]]; then
        echo ""
        echo "Verification FAILED — run sync.sh to push missing secrets." >&2
        exit 1
    else
        echo ""
        echo "Verification PASSED"
        exit 0
    fi
fi

# --- Decrypt ---
echo "Fetching age private key from 1Password..."

# Fetch key from 1Password. The notesPlain field contains the full age key file text.
# sed strips surrounding quotes that op may add.
op item get "Workstation age encryption key" --fields notesPlain --reveal 2>/dev/null \
    | sed 's/^"//;s/"$//' > "$AGE_KEY_FILE"
chmod 600 "$AGE_KEY_FILE"

if [[ ! -s "$AGE_KEY_FILE" ]]; then
    echo "Error: Could not fetch age key from 1Password." >&2
    exit 1
fi

echo "Decrypting secrets..."
age --decrypt -i "$AGE_KEY_FILE" "$SECRETS_FILE" > "$DECRYPTED_FILE"
chmod 600 "$DECRYPTED_FILE"

# Helper: get a value from the decrypted file
get_secret() {
    local key="$1"
    grep "^${key}=" "$DECRYPTED_FILE" | head -1 | cut -d'=' -f2-
}

# --- Push local secrets ---
push_local() {
    echo ""
    echo "=== Pushing to ~/.local/secrets ==="
    mkdir -p "$(dirname "$LOCAL_SECRETS")"

    if [[ "$DRY_RUN" == true ]]; then
        echo "[dry-run] Would write local secrets:"
    fi

    # Build the output in a temp file to avoid subshell counting issues
    local out_file="/dev/shm/local-secrets-out-$$.txt"
    count=0

    {
        echo "# Workstation secrets — generated by ~/.dotfiles/scripts/secrets/sync.sh"
        echo "# DO NOT EDIT — re-run sync.sh to update"
        echo ""
    } > "$out_file"

    while IFS='=' read -r key value; do
        # Skip blank lines and comments
        [[ -z "$key" || "$key" =~ ^# ]] && continue
        if [[ "$DRY_RUN" == true ]]; then
            echo "[dry-run]   $key=***"
        else
            echo "export ${key}=${value}" >> "$out_file"
        fi
        count=$((count + 1))
    done < "$DECRYPTED_FILE"

    if [[ "$DRY_RUN" == false ]]; then
        cp "$out_file" "$LOCAL_SECRETS"
        chmod 600 "$LOCAL_SECRETS"
        shred -u "$out_file" 2>/dev/null || rm -f "$out_file"
    fi

    echo "  $count secrets pushed to local"
}

# --- Push worker secrets ---
push_worker() {
    local worker="$1"
    local keys="${WORKER_SECRETS[$worker]:-}"

    if [[ -z "$keys" ]]; then
        echo "Error: Worker '$worker' not found in routing table." >&2
        exit 1
    fi

    echo ""
    echo "=== Pushing to worker: $worker ==="
    count=0
    for key in $keys; do
        value=$(get_secret "$key")
        if [[ -z "$value" ]]; then
            echo "  Warning: $key not found in values.age — skipping" >&2
            continue
        fi
        if [[ "$DRY_RUN" == true ]]; then
            echo "[dry-run]   $key=*** → $worker"
        else
            npx wrangler secret put "$key" --name "$worker" > /dev/null <<< "$value"
            echo "  ✓ $key"
        fi
        count=$((count + 1))
    done
    echo "  $count secrets pushed to $worker"
}

# --- Execute based on mode ---
case "$MODE" in
    local)
        push_local
        ;;
    worker)
        push_worker "$WORKER_TARGET"
        ;;
    all)
        push_local
        for worker in "${!WORKER_SECRETS[@]}"; do
            push_worker "$worker"
        done
        ;;
esac

echo ""
if [[ "$DRY_RUN" == true ]]; then
    echo "Dry run complete. No changes made."
else
    echo "Sync complete."
fi
