# OpenAI local desktop runtime

This package is for local ChatGPT Work and Codex. Explicitly invoke `adamup-onboard` or choose Run setup to
start or resume, including after installation during a conversation. Browser-only ChatGPT, mobile and cloud
execution are outside this package's scope. No lifecycle hook is required or included.

## Engine and installed paths

Resolve the actual installed `skills/<skill>/SKILL.md`; two directories up is the package root. References
are `<root>/skills/reference/` and helpers, when bundled, are `<root>/scripts/`. Quote paths with spaces and
never depend on the chat's working directory. Find engine tools by their advertised schemas rather than a
session-specific prefix. First call `adamup_capabilities` and require the advertised compatible state schema
and operations. Use `adamup_state` for durable reads, account selection, updates and schedule ownership;
inspect the tool schema for exact operation payloads. Missing capabilities mean a compatible engine is
required, not permission to edit JSON or copy a developer's credentials.

The stdio engine owns local OAuth, state and audit paths. Missing auth is a setup state, not a reason to
hide discovery or onboarding. Call `connect_google_ads` when needed; never return or request token bytes.
Use engine-returned paths, respecting `ADAMUP_DATA_DIR` and the default `~/.adamup` profile. Operator
`~/.mcp-google-ads` credentials are separate and must not migrate automatically. Preserve data during
updates/uninstall unless deletion is explicitly requested. The generated package has no required Python
helper. Prefer advertised native site inspection; use a supported host browser or disclose a missing feature
if unavailable. Never install Python packages during account work.

Read `api-and-writes.md` in this reference directory for schema-1 operation payloads. Use
`scrape_website {url}` for native bounded HTML; it cannot prove a runtime event fires.

## Questions

Use an available OpenAI question tool or ordinary short text with a recommended choice and two alternatives.
Allow typed corrections. A missing specialized question UI does not prevent manual setup.

## Scheduling and notification

Register the weekly run as part of finishing setup; the user's answer to the autopilot question in `reference/autopilot.md` is the opt-in (a no to autopilot still gets a review-only weekly run unless they decline that too). Discover supported desktop automation tools; in Codex,
use the app's `automation_update` tool when exposed. Prefer a thread heartbeat for recurring work in this chat
unless the user requests standalone runs. Read the advertised schema instead of fabricating RRULE fields or
calling a Claude scheduler. Inspect matching existing registrations before creating one, and read back the
real task ID/status afterward. Do not edit scheduler internals, install cron jobs, or create a second schedule
when one already owns this profile. If create/readback is unavailable, say scheduling is unavailable here and
retain manual `run adamup`.

Register this host using `adamup_state` operation `register_host` with host `openai` and the selected customer.
Inspect existing schedules and confirm any previous owner task is disabled before replacement. Create the
new host task with a non-runnable placeholder that exits without account work. Read back ACTIVE status and
ID, then `schedule_claim` with host, scheduler_id and status (previous_disabled on transfer). Capture the
returned `state.schedule_epoch`, update the host prompt with that exact epoch and customer/profile, and
read back the final prompt/status. If any step fails, disable/reconcile the partial registration and do not
claim weekly operation is ready. Each scheduled run calls `schedule_check {host, epoch}`, then
`pass_begin {host, epoch}`. Manual runs use `pass_begin {manual:true, confirmed:true}` after the user
requests a pass. Retain the returned lease ID and call `pass_end {lease_id}` at closeout. Never manufacture
a generation or clear someone else's lease. Schema-1 payloads and supported standing-authorization actions
are listed in `api-and-writes.md`.

Store the timezone and actual recurrence. The app and computer must be running; missed-run, sleep, DST
and notification behavior require host tests.

Write a local digest after each run. Use only supported app notices; if none is exposed, the digest is the
notification fallback. Keep unchanged/non-actionable monitors quiet unless the user requested status updates.
Never promise an external push or continuously running background service.

## Authorization and recovery

An `auto` recommendation cannot authorize itself. Unattended writes are autopilot only (`reference/autopilot.md`):
EXACT negatives and keyword pauses under explicit persisted customer-bound standing permission. Without it,
run read-only and queue changes.
Structural changes always await interactive approval. All writes keep engine preview, confirmation, dry-run,
account binding and audit safeguards. Explain concrete redacted errors, preserve resumable state and bound
retries. Never replay an ambiguous write.

A/B tests run through the engine's `ab_*` tools only. Legacy experiment scripts, their Python dependency
stack and credential-file workarounds are never used.

## Product diagnostics

AdamUp collects no diagnostics. See `reference/telemetry.md`. Never show a diagnostics notice or opt-in question.
