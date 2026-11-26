---
name: adamup-fix
description: Diagnose and repair AdamUp when something breaks: setup won't finish, the weekly pass errored, the MCP server won't connect, or state looks wrong. Reads the audit log and last error, repairs what it can, and otherwise produces a pre-filled GitHub issue. This is the support channel; the product is free and unsupported.
trigger_phrases:
  - "adamup broke"
  - "fix adamup"
  - "adamup isn't working"
  - "adamup error"
  - "adamup won't"
---

# adamup-fix: self-diagnosis and repair

## Installed resources and host services

AdamUp collects no diagnostics. If the user asks about telemetry, follow `reference/telemetry.md`.

Resolve this installed `SKILL.md` first. The package root is two directories above it; `reference/...`
means `<package root>/skills/reference/...` and `scripts/...` means `<package root>/scripts/...`.
Never resolve resources from the current working directory. Load `reference/host-runtime.md` when using
setup, engine discovery, questions, local state, scheduling, notifications, or optional helpers. Discover
engine operations by their advertised schemas, without assuming an MCP prefix. Call
`adamup_capabilities` before stateful work; use `adamup_state` for durable state. If required capabilities
are missing, explain the incompatible engine and keep the account unchanged. Never edit state JSON or
run a legacy Python state writer as a workaround.


AdamUp is free and unsupported, so the agent is the support channel. Your job is to find the problem,
fix it if you safely can, and otherwise hand the user a pre-filled issue so a maintainer can act without a
back-and-forth. Address every failure by its **real
cause, not its surface message.** For query-level and mutate-level API traps, load
`reference/api-and-writes.md` via `reference/README.md` (the Plumbing entry); do not re-derive them here.

**Read the real error first.** The Google Ads API almost always sets `error.message` to the useless
"Request contains an invalid argument". The actual cause is in `error.details[0].errors[0].errorCode`.
Diagnose from that field; never from `error.message`. Everything below keys off the real code.

## 1. Gather (read-only first)

- `adamup_capabilities` and `health_check`: engine version, authentication status and available operations.
  An embedded OAuth client does not require a separate credentials file. Never print token material.
- `adamup_state`: schema compatibility, selected customer/profile and resumable progress. Preserve corrupt
  state and backups for recovery; do not overwrite identity or approvals from an API guess.
- The audit path reported by the engine: read the actual configured resolver output, respecting overrides.
  Corrupt audit/history blocks writes. Preserve the files, inspect the error and restore only a verified
  backup through supported recovery; never silently rebuild or truncate them.
- The supported host scheduler: read back task ID/status and compare ownership/generation in engine state.
  Do not inspect or edit scheduler implementation files.

## 2. Repair the common failures

### Connection, state, and schedule
| Symptom | Real cause | Repair |
|---|---|---|
| Onboarding re-triggers in every folder | state read relative to cwd | Use engine-owned state and installed-resource resolution, never cwd-relative state. |
| Wizard keeps re-triggering | `state.json` missing or unreadable | Preserve it and use supported engine migration/recovery. Resume onboarding only after account binding is confirmed. |
| MCP won't connect / token rejected | expired token, or the npm binary was not fetched | Inspect the installed engine path/version and auth status first. Use `connect_google_ads` for revoked/expired consent; preserve other state. Do not silently update a bundled engine. |
| `USER_PERMISSION_DENIED` | wrong `login_customer_id`, or the identity lacks account access | A single account sends no `login_customer_id`; the nonprofit's own identity has access by definition. |
| Consent screen keeps accumulating scopes | `include_granted_scopes=true` was sent | Never send it; it silently re-grants every scope the client ever held. |
| Weekly pass never runs | app asleep, task missing/paused, stale owner, or scheduler error | Read back the host registration and engine owner/generation. Reconcile before replacing it. Use the host runtime adapter; retain manual runs if scheduling is unavailable. |

### API and engine traps (also in `reference/api-and-writes.md`)
| Symptom | Real cause | Repair |
|---|---|---|
| "Invalid argument" on **every** query | `pageSize` in a `googleAds:search` body | Remove it; it 400s everything. |
| A selected nested field comes back blank | `format=table`/`csv` drops nested fields | Use `json` when a selected field has a dot after the resource name. |
| `primary_status_reasons` 400s | engine pinned below API v25 | Pin to v25; confirm the actual running binary/version; update through the documented package route. |
| Only some conversion actions returned | `get_conversion_actions` hides `HIDDEN`/`REMOVED` | Include them; tier 1 conversion tracking operates on exactly those rows. |
| `update_campaign` silently no-ops | non-leaf bidding field mask | `updateMask=maximize_conversions.target_cpa_micros`, `targetCpaMicros:"0"`. |
| "only approved for test accounts" | Cloud project not approved for production | The shipped project is Basic; only an issue if a reserve/self project is in use. |
| "not allowed for use with Explorer access" | keyword tools need Basic access | The shipped project has Basic; a self-project on Explorer must be upgraded. |
| `UNSUPPORTED_VERSION` / "GRPC method can't be resolved" | Google retired the API version | Bump the pinned version and re-test (the twice-yearly chore). |
| A/B test won't start | campaign not ready, experiment already running, ad group name not unique, or a create step returned `reconciliation_required` | Run `ab_propose` for the readiness reason and `ab_experiment_review` for existing experiments. Never retry a create; a SETUP experiment never spends. Never install Python or credentials for it. |

### Serving and account-shape issues (verify, do not just repair state)
| Symptom | Real cause | Repair |
|---|---|---|
| Account reads ELIGIBLE but serves ~0 impressions | age, PAUSED resources, targeting, missing history or a possible restriction | Read age, enablement, history and actual restrictions. Report suspected holds as uncertainty; new/paused campaigns do not prove suspension. |
| PMax eligible but silent | check `asset_group` (not `ad_group`) and zero signals | Diagnose the asset group; a $329/day PMax at single-digit impressions is this. |
| New campaign, Max Conversions, 0 impressions 14+ days, all eligible | cold-start deadlock: no conversion history, bids too low to enter any auction | Verify age, tracking evidence, targeting and rank/budget losses. Keep conversion-based bidding; any structural change requires review. Do not silently change the workspace strategy. |
| Tag check fails right after publishing | builder caching | Wait ~2 minutes and re-fetch the live URL. |
| "Tag is installed" but the check cannot see it | GTM injects at runtime | A curl check proves a tag present, never absent; verify via GA4 `/g/collect` beacons or the event label, not the base tag. |
| No GA4 and no GTM at all | account shell is UI-only (no `accounts.create`) | One visit to analytics.google.com to create the shell; everything after is API. |
| Broken ad landing URLs | "pretty" final URLs that 404 | The precheck flags any non-200; repoint (does not reset ad learning). |
| Huge/slow reads | a tool returned raw instead of summarized | Confirm the MCP server version; summaries are default, raw is behind an explicit flag. |

The account is authoritative for serving resources; engine state is authoritative for local account binding,
consent, approvals, audit and scheduler ownership. Recover these conservatively and preserve backups. And **verify, do not ask:** check
the live site or the API before asking the user, and **never optimize an account that cannot serve** (a
hold, or zero eligibility), and say so plainly.

## 3. If you cannot fix it

Offer **two** ways to get help, and let the user pick whichever they are comfortable with. Not everyone has
a GitHub account or knows what one is, so never make GitHub the only door.

**Option 1, the simple one (default for a non-technical user): a copyable plain-text summary they can send
to anyone who helps them.** Write it in plain language, no jargon, and tell them they can email it to
**help@adamup.tech** or forward it to a tech-savvy friend or volunteer. Something like:

```
Subject: AdamUp needs a hand

Hi, my AdamUp setup hit a problem I could not get past.

What I was doing:  <the step in plain words, e.g. "connecting my Google account">
What went wrong:   <plain-English symptom, e.g. "the sign-in window closed and nothing happened">
Error code:        <errorCode from error.details[0].errors[0].errorCode, or "none shown">
My computer:       <OS and version>
AdamUp version:    <plugin version>
```

Fill every angle-bracket in for them before you hand it over, so all they do is copy and send. **Never
include their Google Ads customer ID, any token, or any credential**, exactly as with the GitHub issue.

**Option 2, for a user who has GitHub: a pre-filled issue** for https://github.com/gingerman-coder/adamup-marketplace/issues
with plugin version, OS, the redacted last error (`errorCode`, not the raw message), the failing step, and the
state file with `customer_id` and any tokens **removed**. Never include credentials, tokens, or the customer
ID.

Either way, hand the user the finished text; do not email or submit anything on their behalf without asking.

Uncertain or partial remote writes require actual account/API readback. Preserve successful resource IDs and ask for the specific reconciliation decision. Only then use engine `reconcile_plan` with plan_id, confirmed:true, resolution APPLIED/NOT_APPLIED/PARTIAL and reviewed evidence. The engine retains the original outcome and audits the decision; do not delete outcome records or replay a whole create batch.
