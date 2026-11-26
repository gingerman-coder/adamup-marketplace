# Performance: reading the account

How to turn a pull of account data into a diagnosis. This file is about reading, not writing: it tells you
which numbers matter, how to interpret them, and the traps that produce a confidently wrong read. It feeds
`search-terms.md`, `compliance.md`, and `low-impressions.md` with the numbers they act on.

**Measure CTR on Search campaigns only, always.** Performance Max is exempt from the Ad Grants CTR rule.
A blended query across all campaign types can be off by roughly 9x in the direction that trips the
emergency brake on an account that is actually healthy (measured on one mature account: 4.23% blended vs.
39.73% Search-only). Never substitute a blended `FROM customer` pull for a Search-segmented one. See
`guardrails.md` and `compliance.md` for the P1-A rule this protects.

## CTR is a volume lever, not just a compliance number: numerator vs denominator

Click-through rate is clicks (numerator) over impressions (denominator). There are two ways to raise it, and
they pull in opposite directions on volume:

```
NUMERATOR work  (raise clicks):        better ads, more/stronger RSA assets, headline
                                        diversification, sharper copy on what the org DOES.
                                        Raises CTR AND grows volume. This is the default.

DENOMINATOR work (cut impressions):     pause keywords, add negatives, tighten match types,
                                        narrow geo. Raises CTR by SHRINKING the account.
                                        Buys compliance at the cost of volume.
```

**Default to numerator work.** The account's objective is spend, impressions, clicks, and page views within
the CTR floor (`volume-first.md`), so the normal way to lift CTR is to earn more clicks, never to serve
fewer impressions. Cutting the denominator to prop up CTR is throwing away the very volume the grant exists
to generate.

**Denominator work is permitted only when P1-A compliance is genuinely at risk**, that is, under the CTR
emergency brake (`compliance.md`). Under the brake, and only then, the four-lever denominator ordering is
correct: pause the worst-CTR keywords, add negatives for the worst queries, tighten match types, narrow geo,
in that order, least destructive first. Applying that same ordering to a healthy account is wrong: it shrinks
an account that should be growing. So the same four moves are right under the brake and wrong outside it; the
trigger is real compliance risk, never a wish for a prettier CTR number.

## Account-level summary

Pull, per pass:

```
Account spend MTD:       ${amount}
Monthly ceiling:         $10,000 (the Ad Grants standard, ~$329/day x ~30.4 days)
Spend utilization:       {amount / 10000 * 100}%
Account CTR (Search):    {ctr}%
Total conversions MTD:   {count}
Total clicks MTD:        {count}
Conversion rate:         {conversions / clicks * 100}%
```

Nonprofit sector benchmark for conversion rate is roughly 2.6%. A rate far above that is usually a
conversion-hygiene problem, not outperformance; see the Conversions-column caveat below.

## The Conversions-column caveat

**Recompute conversions excluding vanity actions before drawing any conclusion.** Segment conversions by
conversion action and exclude anything that would fail a basic sanity check for a real per-person action
(a passive or page-view signal, anything not something one person actually did) even if it is marked as
the account's primary goal. Report both numbers, always labeled:

```
Total conversions MTD (reported):   {count}   <- bidding volume, NOT impact
Real conversions MTD (meaningful actions only): {count}
Real CPA:  {spend / real_conversions}
```

Every account should carry a page-view conversion as its primary bidding action, and that action's target
may legitimately be a campaign landing page (see `conversion-ladder.md`). Because of that, the reported
total will run close to the click count **by design**. That is not a defect and not an achievement; it is
the bidding instrument doing its job.

**Never present the reported total as impact, and never use it for a top/bottom campaign ranking or a
CPA.** A blended count that includes a page-view or many-per-click engagement action can overstate real
activity by an order of magnitude and understate real CPA by as much: one mature grant account reviewed
during setup research reported over 10,000 blended conversions where only about 500 reflected a real
action, and its real CPA (roughly $200) was about double what the blended number implied.

Every downstream use of "conversions" (in this file or any other) uses the **real**, segmented count. Pull
conversions segmented by conversion action, never blended.

## Judge by phase, not by a fixed rubric

Which metrics are diagnostic depends on the account's phase (`volume-first.md`).

```
PHASE 1 (accumulate) - judge the pass on:
  spend utilization, impressions, clicks, Search-only CTR.
  DO NOT judge on: conversion rate, CPA, cost per conversion.
  The denominator is the page-view action, so those numbers are
  arithmetic on a junk signal and will drive wrong decisions.

PHASE 2 (filter) - the above, plus:
  search-term relevance, real-conversion volume, real CPA.
```

Record the account's phase and its nearest phase-2 trigger in every report. An account sitting in phase 1
past 90 days with no trigger approaching is worth calling out explicitly rather than left to drift.

## Spend utilization

```
< 10%   severely underspending, primary diagnosis needed
10-30%  underspending, where most Ad Grants accounts land without active management
30-60%  moderate, active optimization pushing spend up
60-90%  good, the system is working
> 90%   excellent, near full utilization of the grant
```

**Utilization is a diagnostic, not a goal.** A niche or hyper-local org may be correctly built and unable to
exceed 20%, because the dual auction leaves it very little residual inventory (`auction-model.md`). Never
chase utilization by loosening keywords: that trades compliance risk (CTR) for spend, the exact trade the
priority order forbids. `low-impressions.md` Stage 9 exists to conclude "market ceiling" honestly, rather
than optimizing forever against a number the market will not give.

## Impression share

Pull `search_impression_share`, `search_budget_lost_impression_share`, and `search_rank_lost_impression_share`
every pass. Without them, low spend is undiagnosable and you will keep proposing fixes that cannot work.
See `auction-model.md` for how to read the rank-vs-budget split; the short version is that impression share
under 10% with most of the loss to rank is the normal resting state of a grant account, not a defect.

## Year-over-year, not peak-over-peak

Compare account impressions and clicks against the **same month last year**, not against the account's
historical peak. Grant serving is seasonal because it depends on leftover paid inventory, and available
inventory has been shrinking since 2025 as AI-generated answer boxes absorb more of the search page. A
decline that matches a broad market shift is a different problem from a decline you caused, and only the
year-over-year read tells them apart.

## Bid-cap check

Flag any campaign whose bidding strategy is Maximize Clicks, Target Impression Share, Manual CPC, or
Enhanced CPC. All four are capped at $2.00 CPC (see `guardrails.md` R-BID-1) and will look like a keyword,
budget, or Quality Score problem while actually being a bid-cap problem. This check is cheap and it
pre-empts an entire class of wasted diagnosis.

## Per-campaign breakdown

For each enabled campaign:

```
Campaign: {name}
  Daily budget:        ${budget/day}
  Spend MTD:           ${amount}
  Budget utilization:  {spend / (budget * days_elapsed) * 100}%
  CTR:                 {ctr}%
  Conversions:         {real count}
  Top keywords:        (by conversions, then by clicks)
  Bottom keywords:     (by CTR, among those with >=50 impressions)
```

## Top and bottom performers

- **Top campaigns** (by conversions, then spend efficiency): deserve maintained or increased budget.
- **Bottom campaigns** (by CTR, then spend): dragging account CTR down, or spending without converting;
  need diagnosis via `low-impressions.md` or `compliance.md`.
- **Top keywords** (by conversions): candidates for match-type expansion or seeding a related ad group; see
  `search-terms.md`.
- **Bottom keywords** (by CTR, among those with >=50 impressions): the primary CTR risk and the first
  targets for compliance surgery; see `compliance.md`.
- **Ad groups by ad strength:** below "Good" means fewer impressions and higher cost per click; route to
  headline diversification. "Excellent" needs no action.

## Drift detection

Compare the live account against your last recorded baseline. Flag anything that changed outside your own
process, whether you made the change and forgot to record it or something changed on its own.

```
For each campaign in the baseline:
  Still exists, still in the expected status?
    Missing, or status changed unexpectedly -> FLAG

  For each ad group in the baseline:
    Still exists? Keyword list matches? Ads match? Landing page URL unchanged?

  Budget, bidding strategy, and geo-targeting match baseline?

  Conversion actions match baseline?
    Run an UNFILTERED conversion-action pull every pass, not just the ones your
    records mention. A working, unmarked conversion action built manually and
    never logged is drift, same as an undocumented keyword or ad.
    Also check whether each action's primary status still matches the record:
    someone can promote or demote one manually without it showing up anywhere else.
```

**Dormant-campaign check:** an ENABLED campaign with zero clicks over a trailing 60-90 day window is not a
decision anyone made, it is decay, and nothing else flags it automatically. Check every enabled campaign's
trailing clicks; escalate any at zero for 60+ days:

```
WARNING: Campaign "{name}" has been ENABLED with 0 clicks for {days} days.
Diagnosis needed:
  - Is targeting (geo/keyword/asset) too narrow to generate any impressions?
  - Is the campaign underfunded (budget so low it never enters auctions)?
  - Should it be paused rather than left enabled-but-dormant?
Route to low-impressions.md.
```

**Handling drift:** drift is not inherently bad; a legitimate change may have happened outside the normal
flow. Update your record to match reality for small changes; flag for a decision on structural changes
(a campaign added or removed, a bidding-strategy change).

## Trend tracking

At the end of every pass, keep a compact snapshot: date, account CTR, real conversions, spend, spend
utilization, and a per-campaign CTR/conversions/spend line. A running local record (for example, one file
per organization under the engine-returned account `data_dir`) lets you read the trend without replaying every past
pull, and lets an account that reaches "market ceiling" (`low-impressions.md` Stage 9) stay there instead of
being re-diagnosed from scratch on the next pass.
