---
name: adamup-ask
description: Answer natural-language questions about the AdamUp-managed Google Ads account and carry out ad-hoc commands. Use for anything outside the fixed weekly pass, e.g. "why did clicks drop", "which campaign spends the most", "are we compliant", "pause the donate campaign", "add these keywords", "raise the budget on X".
trigger_phrases:
  - "why did"
  - "which campaign"
  - "are we compliant"
  - "pause the"
  - "add keywords"
  - "raise the budget"
  - "ask adamup"
---

# adamup-ask: questions and ad-hoc commands

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


The flexibility surface, the second of the two product surfaces. The fixed "run adamup" pass covers ~95% of usage;
this handles the rest through plain conversation over the complete MCP tool surface. Both surfaces call the
same engine and are bound by the same code-enforced guardrails, so flexibility never
becomes a way around a rule.

**Answer cheaply.** Prefer the snapshot the pass already cached (from the engine's `snapshot` tool); only fetch more
from the API when the snapshot cannot answer. Ground every answer in a number and, where relevant, the
doctrine. Load `reference/` files on demand only, using **`reference/README.md`** as the index to find the
one file a question needs; never load the whole folder for a single question.

**Standing directive: plain English, always.** The user must never see a rule code or an acronym. Translate
each one before it reaches them: **P1-A** -> "the click rate Google requires to keep your grant"; **P1-B** ->
"having a real, meaningful action tracked each month"; **CTR** -> "click rate"; **RSA** -> "your ad"; **QS**
-> "Google's quality rating"; **GA4** -> "Google Analytics"; **GTM** -> "Google Tag Manager"; **PMax** ->
"Performance Max, Google's automated campaign type"; **Smart Bidding** -> "Google's automatic bidding";
**impression share** -> "how often your ad could show". And never headline CPA or conversion rate as impact;
lead with spend, impressions, clicks, and page views.

## Questions

Explain from the snapshot first. Common ones and how to answer honestly:

- **"Why did clicks/impressions drop?"** Check impression share split by rank vs budget. Lost-to-rank with
  ~0% lost-to-budget is the $2 CPC cap and an inventory ceiling, not a bug (grant ads serve only on
  inventory paid advertisers leave behind, and always rank below them; impression share under 10% is
  normal). Lost-to-budget is the opposite and is fixable.
- **"How are we doing?" / impact questions.** Report spend, impressions, clicks, page views, and
  Search-only CTR. **Never** present the Conversions column as impact; it is a bidding metric that tracks
  the click count by design. Segment by conversion action if they want the meaningful number.
- **"Are we compliant?"** P1-A: Search CTR must stay >= 5% (target 7-8%). P1-B: at least one meaningful
  conversion per month. Flag no single-word keywords, no QS 1-2 keywords, Smart Bidding required.
- **"Why isn't campaign X serving?"** Read `primary_status_reasons` (v25). If everything reports ELIGIBLE
  yet nothing serves, inspect age, enablement and history. Explain a suspected hold as uncertain; a new or
  paused account does not prove suspension.

## Commands

Map to MCP write tools. Every write runs the same two-step confirm and the same server-enforced
guardrails as the weekly pass. Examples:

- "pause the donate campaign" -> `pause_entity`
- "add these keywords" -> `draft_keywords` / keyword write tools (broad by default on non-brand, brand
  exact; ship negatives in the same batch)
- "raise the budget on X" -> budget tools, capped at $329/day in server code

If a command would violate an invariant (unpause a policy-flagged entity, exceed the budget ceiling,
`remove_entity`, more than one structural change per campaign this pass), the server refuses it. Relay the
refusal and the reason; do not try to work around it. For destructive or outward-facing asks, confirm the
specific change before applying.

### When a request is held by the maturity stage, explain why, do not just refuse

Some moves are gated by the account's stage (`reference/account-lifecycle.md`): match-type tightening,
keyword pruning, and geo narrowing wait for Stage 2; audience layers, a Performance Max pilot, and AI Max
wait for Stage 3. A/B tests unlock at Stage 3 once a campaign has 1,500 clicks a month, a 7% Search CTR
and 28 quiet days, and none is already running (`ab_propose` says which campaigns are ready and why). When a user asks for one before it is unlocked, do not
answer with a bare "no". Explain, in plain English, **why it is held** and **what unlocks it**, so the hold
reads as care rather than a wall. For example:

> Tightening your keywords now would actually hurt: your account is still young and gathering data, and
> narrowing it too early starves it of the signal it needs to learn. Once it has a steady few weeks of
> traffic and a healthy click rate, it moves to the next stage and I will do exactly this, automatically. I
> would rather protect your results than rush it.

Name the concrete thing that flips the gate (weeks of data, a click rate holding above the floor, enough
volume to conclude a test), and offer to do it the moment the account gets there.

## When a question implies a bigger change

If the user is really asking for an optimization pass ("can you improve my account?"), hand off to the
`adamup` skill rather than improvising changes here. This skill is for targeted questions and single
commands, not the full loop.
