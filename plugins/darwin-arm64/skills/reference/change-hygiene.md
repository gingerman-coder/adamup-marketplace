# Change hygiene: learning periods and the change budget

When *not* to change something. Governs the pace of every optimization move, across every kind of change.
A weekly (or scheduled) pass is designed to find something to fix, and nothing stops that from editing the
same campaign every cycle. Smart Bidding needs a stable configuration to learn from, and every material
change restarts that learning. An account edited every pass never leaves the learning period, and its
performance stays permanently worse than the same account left alone would be. This is a real and common
failure mode in managed accounts, and it's invisible: each individual change is defensible, and the
aggregate is destructive.

## The learning period

After a material change, Google's automation re-enters a learning period. Performance during it is
unrepresentative, usually depressed, always noisy. Judging a change during its own learning period is
measuring noise.

| Change | Learning period | Don't judge before |
|---|---|---|
| New campaign launched | 7 to 14 days | 14 days |
| Bidding strategy switched | 7 to 14 days | 14 days |
| Target CPA or ROAS added, removed, or moved more than 20% | 7 days | 14 days |
| Budget changed more than 20% | ~7 days | 14 days |
| PMax campaign launched | 14 days minimum | 8 weeks |
| AI Max component enabled | ~7 days | 3 to 4 weeks |
| Ad group's ads substantially rewritten | ~7 days | 14 days |
| Keywords added or paused | Minimal | 14 days for a volume read |
| Negatives added | None | Immediate; negatives are always safe to add |

**The 24 to 48 hour rule at launch.** A newly launched campaign shows nothing for 24 to 48 hours. This is
normal. Don't diagnose, don't adjust, don't report it as a problem. Every edit made during this window
restarts the clock.

## Freeze windows

A campaign under freeze accepts only the changes listed as always-permitted below.

```
FREEZE campaign for 14 days after:
  - the campaign is enabled for the first time
  - its bidding strategy changes
  - a target CPA or ROAS is added, removed, or moved more than 20%
  - an AI Max component is enabled on it
  - its budget moves more than 20%

FREEZE campaign for 8 weeks after:
  - a PMax campaign launches (the pilot review window)
```

### Always permitted, never frozen

Exempt because they reduce risk rather than change what the algorithm is optimizing:

1. **Negative keywords.** Adding negatives is always safe and always allowed.
2. **P1-compliance fixes.** Anything the emergency brake or a disablement trigger demands. Compliance
   outranks learning stability, without exception (`guardrails.md`).
3. **Pausing a disapproved or policy-violating ad.**
4. **Pausing a QS 1 to 2 keyword** (R-KW-3).
5. **Keyword changes backed by real volume data.** Adding volume-validated keywords, pausing confirmed
   zero-volume or `RARELY_SERVED` keywords, and match-type corrections toward the broad-match default
   (`keyword-doctrine.md`) are always permitted and should be applied in the pass that finds them. Ship
   them with their paired negative batch.

Everything else waits for the freeze to lift.

### Keyword findings get applied, never deferred

This deserves its own rule because the instinct to defer is strong and wrong. A pass that finds dead
keywords, or a broad-match share below doctrine, and defers the whole fix to a later pass (reasoning that
it counts against the one-structural-change ceiling, or that it should wait for CTR data) is making two
errors at once:

- **A dead keyword is not a change to the algorithm's optimization target; it's the removal of something
  that was never serving.** Pausing it teaches the account nothing new and costs nothing to attribute.
- **The one-structural-change ceiling is about attribution of *performance* changes** (bidding, budget,
  targeting). A zero-volume keyword generates no performance to attribute; counting it against the ceiling
  confuses "changes" with "changes that move a number."
- **Waiting for CTR data to gate a broad-match expansion is circular on an account that can't serve.**
  There's no CTR because there are no impressions, and missing broad seeds are part of why.

```
KEYWORD WORK IS NOT STRUCTURAL WORK.
It doesn't consume the one-structural-change-per-campaign budget, and it's
not subject to the 14-day freeze.

Find it in a pass -> apply it in that pass.
The ONLY exception is the emergency brake (CTR below 5% past grace), which
forbids ADDING keywords but still requires pausing dead ones.
```

### Honoring a freeze in a scheduled pass

Check each campaign's freeze state before emitting changes. A frozen campaign's non-urgent findings get
recorded, not emitted:

```
Campaign "Programs" is frozen until 2026-08-18 (bidding strategy switched
2026-08-04). 3 findings recorded and deferred:
  - 4 keyword candidates from search terms
  - 1 ad group below "Good" ad strength
  - budget headroom available
These get re-detected and emitted on the first pass after 2026-08-18.
```

Deferred findings aren't lost; the next pass re-detects them from live data. Don't keep a separate backlog
file: the account is the source of truth, and a finding that no longer reproduces wasn't worth acting on.

## The change budget

Even outside a freeze, there's a ceiling on how much to change at once. This is about attribution, not
caution: if a pass makes eight changes to one campaign and performance moves, the pass has learned
nothing.

**Per campaign, per pass:**

| Change class | Limit |
|---|---|
| Structural (campaign settings, bidding, budget, geo) | 1 |
| Content (keywords, ads, assets) | Unlimited within reason, batched into a single coherent edit |
| Negatives | Unlimited |
| Compliance fixes | Unlimited, and exempt from every limit here |

**One structural change per campaign per pass.** If a pass wants to switch the bidding strategy *and*
change the budget *and* enable AI Max on the same campaign, do the highest-value one and defer the rest.
This is enforced server-side as a hard floor (`guardrails.md`); this file is what prevents relying on that
floor as the only discipline. The same logic applies to broader optimization stages: fixing several
maturity-gated moves simultaneously (`account-lifecycle.md`, `recommendations-catalog.md`) means never
learning which one was the actual constraint.

### The carve-out: a campaign that has never served

**The ceiling doesn't apply to a campaign with no meaningful impression history.** Both limits above exist
to protect two things, and a campaign that has never served has neither:

```
Smart Bidding's learning period    -- nothing has been learned, so nothing resets
Attribution of a change to an outcome -- there's no outcome to attribute
```

A real case: an account with a handful of impressions in its entire lifetime and four stacked structural
defects (wrong bidding strategy, budget never corrected, geo too narrow, and a dead conversion signal).
Deferring the budget fix to a later pass "to measure the bidding fix in isolation" would have measured one
broken configuration against another, at a cost of a month per defect.

```
Campaign has < ~100 lifetime impressions
  -> fix every structural defect found, in one pass. The ceiling resumes
     the moment the campaign is actually serving.

Campaign is serving
  -> one structural change per campaign per pass, as above.
```

State the carve-out explicitly when it's used, with the impression count that justified it. It's a real
exception, not a license to batch changes on a live account because it's faster.

## Step-size limits

When adjusting a continuous value, move it in increments the algorithm can absorb.

```
Budget:      +/-10% per pass under normal optimization.
             Exception: a first move to the standard $329/day default is a
             one-time correction, not an optimization step, and isn't
             subject to this limit (bidding.md). Take it in one move.
             Exception: raising a budget that's demonstrably the binding
             constraint (high Lost IS to budget) may move up to +50%.

Target CPA:  +/-20% per pass, and never below the campaign's actual
             trailing CPA. Prefer removing the target entirely while
             utilization is low (bidding.md).

Bids:        The account-level guardrail caps bid increases at 100%
             (guardrails.md). Stay well under it: +/-20% per pass is the
             working limit for manual adjustments, and manual bid
             adjustment should be rare in a Smart Bidding account.
```

## Minimum data before judging

Don't act on a signal that hasn't accumulated enough volume to mean anything.

| Decision | Minimum before acting |
|---|---|
| Pause a keyword for low CTR | 100 impressions |
| Pause a keyword for cost with no conversion | 100 clicks, or the trailing CPA of a converting keyword, whichever is lower |
| Judge an ad group's CTR | 200 impressions |
| Judge a new RSA against an old one | 14 days and 500 impressions |
| Pause an underperforming ad | 1,000+ impressions. Ads need far more data than keywords before a judgement is sound, because Google is testing combinations, not a fixed creative. |
| Judge a bidding strategy change | 14 days and 30 conversions, or 30 days |
| Judge a PMax pilot | 8 weeks |
| Judge an AI Max component | 3 to 4 weeks |
| Add a search term as a keyword | Per volume tier; see `keyword-doctrine.md` |
| Conclude a market ceiling | Two consecutive passes reaching the same conclusion |

**Exceptions, act immediately regardless of volume:**
- QS 1 to 2 keyword: pause now (R-KW-3)
- Single-word or policy-violating keyword: pause now (R-KW-1)
- Disapproved ad: fix now
- Any disablement trigger: act now
- Adding a negative for a clearly off-mission term: add now, at any volume

## The set-and-forget failure, on the other side

This file is about restraint, and restraint has an opposite failure that's equally real. Ad Grants
accounts that sit genuinely idle degrade: search behavior shifts, the auction changes, ads go stale, and
Google treats prolonged inactivity as a signal (R-ACTIVITY-1). Idle accounts are more likely to be paused
or removed from the program.

The distinction is between **churn** and **attention**:

| Churn (what this file prevents) | Attention (what a good pass does) |
|---|---|
| Editing the same campaign every pass | Reading every campaign every pass |
| Changing bidding strategy repeatedly to chase results | Changing it once and letting it learn |
| Adjusting budgets by small amounts every pass | Setting them correctly and leaving them |
| Rewriting ads before the last rewrite has data | Adding a new headline variant to an RSA that has plateaued |

**A pass that reads everything and emits only negatives and a compliance check is a successful pass.**
Being able to conclude "no action this week" is not a failure to find work; record it explicitly so the
record shows the account was examined rather than skipped.

## Tracking freeze state

Whatever store holds account state, track per campaign: a `frozen_until` date, the reason for the freeze,
and a count of deferred findings. An absent or past-dated `frozen_until` means the campaign is open for
optimization; a scheduled pass should read this before emitting anything structural.
