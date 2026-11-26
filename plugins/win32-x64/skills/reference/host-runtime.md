# Claude desktop runtime

This reference supplies host services only; advertising decisions remain in shared skills. Explicitly
invoke `adamup-onboard` to start or resume setup, including when installed mid-conversation. The Claude
session-start hook is an optional reminder, never a setup requirement.

## Engine and local resources

Resolve the actual installed skill path, then go up two directories for the package root. References are
`<root>/skills/reference/`; helpers are `<root>/scripts/`. Quote complete paths with spaces. Do not use
workspace-relative paths. Find installed engine operations by schema, not a hardcoded MCP prefix.
Call `adamup_capabilities`; require compatible state schema and advertised operations before proceeding.
Use `adamup_state` for account selection, state reads/updates and schedule ownership. Inspect its schema
for exact operation arguments. Token material stays inside the engine. A missing credentials file is normal
with the embedded OAuth client. The existing npm route can load an older engine; if capabilities are absent,
request a compatible installation and do not try new state workflows against it.

Use the engine-returned data and audit paths. `ADAMUP_DATA_DIR` overrides the default `~/.adamup` profile;
operator `~/.mcp-google-ads` credentials are separate. Never copy them to a plugin profile. Preserve data on
updates and uninstall; delete it only on explicit user request. Unknown/corrupt state requires safe recovery,
not regeneration that discards account identity, approvals or schedule ownership.

Read `api-and-writes.md` in this reference directory for schema-1 operation payloads. Use
`scrape_website {url}` for native bounded HTML; it cannot prove a runtime event fires.

## Questions and optional helpers

Use a supported question UI when available; otherwise present two or three short choices in ordinary text.
A typed correction is always acceptable. Do not assume every host has one-tap chips. Prefer native engine
site inspection when advertised. Legacy Python scrape/telemetry helpers are developer utilities requiring
Python 3, not a clean-install dependency. If native inspection is unavailable, use a supported host browser
or explain the missing capability; do not install packages unattended or invent a terminal-free runtime.

## Scheduling and notices

Register the weekly run as part of finishing setup; the user's answer to the autopilot question in `reference/autopilot.md` is the opt-in (a no to autopilot still gets a review-only weekly run unless they decline that too). Inspect supported scheduler tools and existing task registrations.
Select local execution for local MCP/account access; current cloud task defaults do not provide this
local engine. A current Claude scheduler may expose `create_scheduled_task`; use its actual advertised schema and read
back the task ID/status. Do not edit scheduler files or substitute session cron tools. If registration or
readback is unavailable, leave scheduling unavailable and keep manual `run adamup` available.

Register this host using `adamup_state` operation `register_host` with host `claude` and the selected customer.
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

Store timezone and the actual host recurrence. Spread load across business weekdays/hours where the user
has no preference. The computer and app must be running; describe missed-run behavior only after testing
this host. A digest is always written. Send a notice only through an available supported notification tool;
otherwise tell the user to review the digest in the app. Never invent a push tool or promise delivery.

## Unattended authority and failure

Unattended writes are autopilot only (`reference/autopilot.md`): EXACT negatives and keyword pauses, under
explicit persisted customer-bound standing permission. A recommendation marked `auto` is eligibility, not consent. All writes still preview and
confirm through the engine; structural items wait for interactive approval. If standing permission is absent,
expired, or incompatible, produce a read-only digest and queue changes. On failure, preserve resumable state,
report the concrete redacted error and perform only bounded retries. Do not replay ambiguous writes.

A/B tests run through the engine's `ab_*` tools only. Never run legacy experiment scripts, install a
Python stack or request credentials for them.

## Product diagnostics

AdamUp collects no diagnostics. See `reference/telemetry.md`. Never show a diagnostics notice or opt-in question.
