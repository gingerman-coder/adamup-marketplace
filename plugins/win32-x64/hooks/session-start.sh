#!/usr/bin/env bash
# Optional read-only reminder. Explicit setup works without this hook.
# Durable state belongs to the engine, never this script or a shell snippet.
set -euo pipefail

STATE_FILE="${ADAMUP_DATA_DIR:-${HOME}/.adamup}/state.json"

emit_context() {
  # Callers supply only fixed ASCII text, never state, paths, errors or user input.
  # This keeps valid JSON without requiring Python or jq.
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$1"
}

if [ ! -f "$STATE_FILE" ]; then
  emit_context 'AdamUp setup is available. If relevant to the user, offer explicit adamup-onboard, or adamup-grant for grant assistance. Read the installed host runtime and engine capabilities first. Do not write state or invent an account to record a deferral; before account selection, keep progress in this conversation. If the user declines, stay quiet for this session.'
  exit 0
fi

# This read is a reminder hint only, not validation of engine schema or account truth.
# The engine must validate state before any account work. Never expose raw file data.
status="$(grep -o '"status"[[:space:]]*:[[:space:]]*"[^"]*"' "$STATE_FILE" 2>/dev/null | head -1 | sed 's/.*"\([^"]*\)"$/\1/' || true)"
# Preserve legacy snoozes on read only. New workflows use engine-supported progress.
snooze_until="$(grep -o '"snooze_until"[[:space:]]*:[[:space:]]*"[^"]*"' "$STATE_FILE" 2>/dev/null | head -1 | sed 's/.*"\([^"]*\)"$/\1/' || true)"
if [ -n "$snooze_until" ]; then
  now="$(date +%Y-%m-%dT%H:%M:%S)"
  if [[ "$now" < "$snooze_until" ]]; then
    exit 0
  fi
fi

case "$status" in
  declined|onboarded)
    exit 0
    ;;
  applying)
    emit_context 'AdamUp has a saved grant-application progress hint. Offer explicit adamup-grant if relevant. Load the installed host runtime, check capabilities and read engine state before resuming. Do not edit JSON or run a legacy state writer.'
    ;;
  in-progress|"")
    emit_context 'AdamUp setup may be incomplete. Offer explicit adamup-onboard if relevant. Read the installed host runtime and engine capabilities first. Missing, corrupt or incompatible state requires supported recovery, never overwriting account identity or approvals.'
    ;;
esac
