#!/usr/bin/env bash
# Wipe the session-cached age key (see secret-set.sh). Safe to run anytime;
# the next secret-set.sh / sync that needs it will re-prompt 1Password once.
shred -u "/dev/shm/.age-key-$(id -u)" 2>/dev/null && echo "age key cache cleared." || echo "no age key cache present."
