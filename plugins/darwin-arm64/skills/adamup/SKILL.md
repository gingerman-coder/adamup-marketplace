---
name: adamup
description: The AdamUp optimization pass and dashboard. Reviews the last 30 days, shows a performance summary and a numbered list of recommended improvements the user approves in one word, applies safe changes, and adapts the account's strategy as it matures. This is what "run adamup" does, and it is the body of the weekly scheduled task.
trigger_phrases:
  - "run adamup"
  - "adamup"
  - "optimize my account"
  - "weekly pass"
  - "how is my account doing"
---

# run adamup

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


The main loop. Runs interactively when the user types "run adamup", and unattended as the weekly
scheduled task. **Both surfaces behave identically** because both read one snapshot and both defer to the
same recommendations engine and guardrails. Unattended writes additionally require stored standing permission.

**Token discipline is a hard rule.** Do all arithmetic in code. Read one snapshot.
Load `reference/` files only when a recommendation needs to explain itself, and use **`reference/README.md`
as the index** so you pull only the two or three files that matter, never the whole folder. Budget the
whole pass under **15k tokens** of context. Performance always wins over thrift, but thrift comes from
moving work into code, never from analyzing less.

**Standing directive: speak plain English to the user, always.** The doctrine files are full of rule codes
and acronyms; the user must never see one. Translate every one before it reaches them:

- **P1-A** -> "the click rate Google requires to keep your grant" (>= 5%).
- **P1-B** -> "having at least one real, meaningful action tracked each month".
- **CTR** -> "click rate" (the share of people who click your ad after seeing it).
- **RSA** -> "your ad" (a responsive search ad); **QS** -> "Google's quality rating for a keyword".
- **GA4** -> "Google Analytics"; **GTM** -> "Google Tag Manager"; **PMax** -> "Performance Max, Google's
  automated campaign type"; **Smart Bidding** -> "Google's automatic bidding"; **impression share** ->
  "how often your ad could show".
- Any `R-` rule code, `primary_status_reason`, or field name -> the thing it means, in words.

And **never headline CPA or conversion rate.** Those read as impact but are not, on these accounts; lead with
spend, impressions, clicks, and page views instead (`reference/performance.md`).

## 1. Load state and collect one snapshot

Read the selected customer/profile through `adamup_state`. If setup is incomplete, hand off to
`adamup-onboard`. A corrupt or unsupported schema is a recovery error, not permission to overwrite state.
On a scheduled run, validate the persisted owner and generation first; a stale task exits before reads or
writes. Acquire the pass lease with `pass_begin` from the host runtime. An explicit “run adamup” request
authorizes the manual lease, not every account recommendation. Without current standing permission,
unattended runs remain read-only and queue changes.

Call the engine's **`snapshot`** tool **once** (the deterministic logic lives in the compiled MCP engine;
its behavior is specified by the offline oracle in the engine repo). It
returns a compact JSON snapshot with everything the pass needs, all aggregated in code:

- 30-day spend + **spend utilization** (`budget_utilization`), impressions, clicks.
- **Search-only CTR** (never blended; PMax is CTR-exempt and skews it ~9x on a PMax-heavy account).
- **Impression share split by rank vs budget** (the cheapest diagnostic: lost-to-rank at ~0% lost-to-budget
  is the $2 cap, and no budget fixes it).
- Conversions **segmented by action** (`all_conversions` and the unfiltered-conversion list), never the
  account total as impact.
- `primary_status` and `primary_status_reasons` per campaign (Google's machine-readable "why not serving").
- RSA asset performance labels.
- `has_running_experiment` and `days_since_structural_change` (freeze-window and A/B readiness inputs).
- The current **maturity stage** and a possible **step-back recommendation**.
- A **`trend`** block: the engine reads `metrics-history.jsonl` and returns the movement of the key numbers
  (spend, CTR, clicks, real conversions) versus the prior period, already computed. Use `trend` for the
  "trend vs prior period" render below; do not diff the raw history yourself. Because the engine writes one
  history row every pass and reads it back here, the account genuinely **improves over time**: each pass can
  see whether the last change helped and steer accordingly.

## 2. Catch-up, not replay

Read `last_run`. If several weeks elapsed, run **one** pass covering the whole gap, not one pass per missed
week. A laptop schedule slips; degrade gracefully instead of lying about cadence.

## 3. Emergency brake and pathology first

Before anything else, check the snapshot for:

- **Search CTR below 5% past grace** -> emergency brake: skip all optimization, do compliance surgery only
  (`reference/guardrails.md`).
- **Confirmed account disablement or a poisoned conversion stack** -> halt progression and surface it.
  Suspected nonserving is uncertainty: check age, paused/enabled state, history and status before diagnosing
  a hold. A new or PAUSED account is not evidence of suspension. The verified phase-1 page-view primary
  is permitted, separate from a real meaningful action for compliance.

## 4. Render the dashboard

1. A compact **30-day table** with the trend vs the previous period (from the snapshot's `trend` block).
2. **Three to five plain-language takeaways.** Judge on spend, impressions, clicks and page views. Never
   headline conversion rate or CPA, and never report the Conversions column to the user as impact.
3. A **numbered recommendation list** with a **one-word approve** control (approve-all is the default;
   each item can be approved or skipped).

**When the account is young and quiet, reassure; do not alarm.** For roughly the first two to three months, a
new grant account normally shows very little: few impressions, low spend, sometimes near zero. This is
expected, not failure, and the user must hear that plainly. Two real reasons, both worth saying in plain
words when the numbers are low and the account is early (Stage 0 or 1, or launched recently, or impression
share is lost mostly to rank): first, Google only shows grant ads on the search traffic paid advertisers
leave behind, and always below them, so a small share of the available searches is completely normal;
second, Google's automatic bidding is still learning, and it needs several weeks of data before it can
compete for more of those searches. Tell them the account is doing exactly what a healthy new account does at
this stage, that it grows as it learns, and point to the direction of travel in the `trend` block (even a
small rise in impressions or clicks is the system warming up). Never imply something is broken when it is
simply early. Save concern for the two things that are genuinely wrong: the click rate falling below the
level Google requires, or a confirmed account restriction. Zero serving alone requires investigation, especially on new or paused campaigns.

**Target for plainness (one worked example).** Aim for exactly this register: a small table, a few sentences
a busy director understands at a glance, and a numbered list that ends in one word.

> **Your account, last 30 days**
>
> | | Last 30 days | Prior 30 days |
> |---|---|---|
> | Money used | $4,180 | $3,050 |
> | People who saw your ads | 61,400 | 52,900 |
> | People who clicked | 5,020 | 3,880 |
> | Click rate | 8.2% | 7.3% |
> | Page views tracked | 4,600 | 3,510 |
>
> **What this means**
> - You used about 42% of your $10,000 grant this month, up from 31%. That is real, healthy growth.
> - Your click rate is 8.2%, comfortably above the 5% Google requires, so your grant is safe.
> - More people are both seeing and clicking your ads than last month.
>
> **What I would like to do next**
> 1. Block 6 off-topic searches that are wasting a little spend. (I can do this safely on my own.)
> 2. Add a new ad group for "after-school tutoring", a phrase people are already searching for.
> 3. Refresh two weak ad headlines that are getting few clicks.
>
> Reply **approve** to do all three, or tell me which numbers to skip.

## 5. Recommendations come from code, not from you

Call the engine's **`recommend`** with the `snapshot_id` returned by this pass's snapshot and the same
customer. Inspect the advertised schema. Reject expired or mismatched handles; do not collect a second
snapshot or append duplicate history just to recommend. If snapshot reuse is unavailable, explain the
incompatible engine and leave the account unchanged.

Render the ranked gated list and rationale from code. `auto` identifies low-risk eligibility; `queued`
identifies changes requiring interactive approval. **A/B tests** (`reference/ab-testing.md`): every pass
calls `ab_experiment_review` and shows each experiment's verdict in plain English (KEEP_RUNNING reports
days/volume left, never a p-value). A WIN or LOSE/INCONCLUSIVE verdict becomes a queued item: promote or
end via `ab_experiment_action` with double confirmation. When `experiments_available` appears, call
`ab_propose`, write the RSA copy for a `needs_copy` proposal (`reference/ad-copy.md`), pick the ad group,
show the test, and on approval run `ab_experiment_draft` then `confirm_and_apply`, then ask before
`ab_experiment_action schedule`. A scheduled (unattended) run never creates, schedules, promotes or ends
an experiment; it only reviews and queues.

## 6. Apply

- **Autopilot (scheduled runs):** when standing permission is stored, pick and apply the week's negatives
  and keyword pauses exactly as `reference/autopilot.md` says. The engine enforces its limits; a refused
  change is queued, never retried or reworded.
- **`auto` items** (interactive runs): apply when the user approves in this session or standing permission
  covers the exact operation. The label is not consent. Inspect preview details before confirmation.
- **Interactive run after autopilot:** open with a two-line summary of what autopilot changed since the
  last session and offer a one-word undo.
- **`queued` items**: present for one-word approval. On approval, apply through the same guardrails. New
  campaigns/ad groups/copy, bidding or geo changes, unpausing, conversion primary-status changes, and any
  structural stage advance are always queued.

All writes go through the MCP two-step confirm and the server-enforced guardrails (budget ceiling,
`remove_entity` blocked, no unpausing policy-flagged entities, one structural change per campaign per pass,
covered-request metering and audit log). You cannot talk the server out of a rule; do not try.

## 7. Advance the maturity stage if earned

The engine's `recommend` tool reports whether the account now clears the next stage's entry condition
(`reference/account-lifecycle.md`). If it does and the user approves any structural changes the new stage
implies, persist the engine-recommended stage through `adamup_state`. On a regression the snapshot carries a **step-back recommendation**;
honor it through the engine state operation rather than deciding a stage yourself. Do not promote into
unavailable Stage 4 execution. This is how "start broad, then refine over
time" actually happens, in both directions.

## 8. Close out

Write a digest under the engine-returned selected account `data_dir`, at `digests/<date>.md` and append applied changes to
`action-log.md` (plain English, the user's trust record). Update run state through `adamup_state`. The engine
appends one compact row to `metrics-history.jsonl` per pass; that file is the account's memory, read for
trends the 30-day window cannot show, to judge whether a past change helped, and to drive stage
transitions. Read a summarized slice of it when a takeaway needs history, never the raw file.

**Product diagnostics.** None are collected; see `reference/telemetry.md`.

Finish the owned pass with `pass_end` and the returned lease ID, including after a recoverable failure.
Do not end another process's lease or claim an unfinished account change succeeded.

On scheduled runs, use only supported host notices from `reference/host-runtime.md`; the local digest is
the fallback. Queue all structural and unauthorized items for the next interactive run. Do not block on
approval or claim an unobserved push notification was sent.
