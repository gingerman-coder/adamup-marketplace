# Performance Max gate

The canonical definition of when an account may run a Performance Max (PMax) campaign, how to
configure it, and when to roll it back. PMax is one of the two Stage 3 "Layer" unlocks in
`account-lifecycle.md`; the other is the audience layer (`audience-layer-gate.md`).

## What PMax is in a grant account

PMax is keyword-less: instead of a keyword list it takes an asset group (headlines, descriptions,
images, logo) plus audience signals, and the platform's automation decides where and to whom to
serve.

**When diagnosing a PMax campaign, always check at the `asset_group` level, never `ad_group`.**
PMax has no ad groups; a diagnostic script or query written for Search campaigns will silently
return nothing useful if pointed at `ad_group` on a PMax campaign.

**Grant inventory is restricted to Google Search and Google Maps only.** YouTube, Display,
Discover, and Gmail are part of paid PMax and are **not** included on a grant. Never promise a
client, or expect, reach on those surfaces from a grant PMax campaign. Re-verify the current
surface list periodically since it can change.

| Situation | Why PMax helps |
|---|---|
| Account cannot spend its Search budget | PMax reliably spends more easily than Search in grant accounts |
| Local org wants Google Maps presence | PMax plus a location asset is the only way to get grant ads onto Maps |
| Keyword selection is genuinely hard | No keyword list required; the automation finds queries a keyword list would not have guessed |
| The audience is definable but the query is not | Audience signals do work keywords cannot |

**What it costs:**
- Lower conversion rate than Search; spending the grant is not the same as helping the org.
- Coarser visibility than Search. A search-term insight report can surface real query data down to
  grant-tier spend levels, but it does not segment by ad group (PMax has none) the way a Search
  campaign's report does. Monitor with real but lower-resolution data, not blind, but expect less
  precision than Search.
- Cannibalization risk: PMax can absorb queries a Search campaign was already winning, so account
  totals move less than the campaign-level numbers suggest.
- Volatility: PMax spiking then dying in grant accounts is a commonly reported pattern. It needs
  monitoring, not set-and-forget.

## Precondition gate

All four must pass before proposing a PMax campaign.

| # | Precondition | Why |
|---|---|---|
| 1 | Conversion tracking is hygienic: the page view plus the real meaningful actions are primary, one-per-click where applicable, no stacked weak engagement events, no conversion goal left holding zero primaries | PMax is fully automated and steers only on the conversion signal; a messy signal produces a messy campaign no matter how good the monitoring is. |
| 2 | Conversion volume exists: roughly 30 conversions in the trailing 30 days, page views included | The automation needs volume to learn from. The page-view conversion counts toward this; in practice this is satisfied on any account that is serving at all. |
| 3 | At least one Search campaign is live and healthy | PMax is an addition, never a replacement. Search carries structural compliance and the CTR that P1-A measures. |
| 4 | Quality creative assets exist | Asset groups need real headlines, descriptions, images, and a logo; weak assets produce a weak campaign. |

**Precondition 2 counting page views is a deliberate choice, not an oversight.** Read literally as
"real conversions only," most small grant accounts never clear 30/month, which would make this a
permanent block on the highest-spend surface a grant account has. Counting page views opens PMax on
any account that passes the other preconditions, with an explicit tradeoff stated plainly:

```
PMax will steer on a signal that does not discriminate between clicks.
It will buy volume, not outcomes: high spend, PMax CTR in the low single
digits, poor traffic quality. That is the accepted trade under a
volume-first objective (`volume-first.md`), not a bug.
```

The P1-A risk here is genuinely low: PMax is excluded from the CTR calculation entirely, so a low
PMax CTR does not threaten the grant. The exposure is spending grant allowance on weak traffic, not
losing the grant. Two things this does not relax:
- Precondition 1 still applies in full; "page views count" is not "any mess counts."
- P1-B is unaffected. PMax volume is not meaningful conversion volume; the account still needs a
  real, tracked meaningful action recording monthly.

### The 30-conversion threshold and its exception

Most small accounts will not clear 30 real conversions per month, which is the honest reason PMax
is not a default. A pilot is permitted below the threshold when all of:

- The account is severely underspending its daily allowance (utilization under roughly 20%)
  despite a clean Search build, and is losing impression share to rank rather than to budget,
  meaning the constraint is inventory, not effort.
- Precondition 1 (clean conversion tracking) passes without qualification, no exceptions.
- The user explicitly approves the pilot, recorded with a start date.

Run the pilot with a spend fence (below) and the tightened review cadence. This exception exists
because an account stuck at a hard underspend floor is getting nothing from the grant, and a
monitored PMax pilot is a better use of otherwise-forfeited daily allowance than continued
underspending. It is not a license to skip precondition 1.

## Configuration rules

```
Bidding:            Maximize Conversions. No target CPA during a pilot; a
                    target CPA on a cold PMax campaign suppresses it into
                    non-serving.

Campaign goal:      The customer-acquisition setting biases the automation
                    toward prospecting rather than re-serving people the
                    account already reached. Do NOT set it when a
                    first-party audience is attached as an asset-group
                    signal: the signal says find people like existing
                    converters, the acquisition setting says bid away from
                    them. On a volume-first account, the signal is worth
                    more; leave acquisition on "bid equally." Where used,
                    prefer "bid higher for new customers" over "new
                    customers only" (the latter is a hard serving
                    restriction that can choke a small campaign).

Budget:             Pilot: fence at $50-100/day so PMax cannot starve
                    Search of the daily allowance. Established: release
                    toward the standard $329/day cap.

Final URL expansion: Decide on what actually constrains the account, not on
                    a blanket default.
                      Rank-limited (impression share lost mostly to RANK,
                      little to budget) AND the site is deep and current
                      -> expansion ON. It is one of PMax's largest reach
                      levers, on the one surface not rank-limited.
                      Spend already healthy, OR the site is thin or stale
                      -> expansion OFF.
                    The containment is the week-4 search-terms review, not
                    the setting: expansion ON is reversible with data,
                    while reach forgone by defaulting OFF never recovers.
                    If junk landings appear, turn it off then, or prefer
                    URL exclusions over a blanket OFF.

Asset groups:       Segment by conversion INTENT, not just by program: one
                    asset group per distinct action the campaign drives
                    (e.g. a donate-intent group, a volunteer-intent group,
                    a program-info group), each with its own audience
                    signals. The platform mixes and matches assets WITHIN
                    a group, so mixing unrelated intents in one group
                    produces incoherent ad combinations. Do not split below
                    the volume that supports it: stay at a single group
                    until the campaign reliably produces enough
                    conversions to give each split its own signal (~30/
                    month, matching the precondition above almost
                    exactly). Cap: 100 asset groups per campaign,
                    irrelevant at nonprofit scale.

Creative assets:    Real headlines, descriptions, a logo, and several
                    images (aim for 3-5+, more than one aspect ratio).
                    Video is not worth production time: grant inventory is
                    Search + Maps only, video assets do not serve there,
                    and a "Good" ad-strength rating is achievable without
                    one. Generic PMax advice recommending mandatory video
                    is written for paid PMax's YouTube inventory and does
                    not transfer to the grant's restricted surface.

Audience signals:   Required, not optional; the single biggest driver of
                    PMax quality in a grant account. Build from the org's
                    actual supporter/beneficiary demographics, in-market
                    and affinity segments matching the mission, and custom
                    segments built from keywords Search already knows
                    convert. Route segment selection through
                    `audience-layer-gate.md`.

                    Priority order: customer-match lists first (if the org
                    has donor/supporter data to import), then remarketing
                    (site revisitors), then in-market and life-event
                    audiences, then affinity last. First-party signal
                    beats inferred signal. Stacking too many signals at
                    once dilutes rather than sharpens targeting; pick the
                    handful that actually fit the org.

                    Signals are a starting point, not a fence: expect the
                    platform to serve outside the specified signals once
                    it finds conversion likelihood elsewhere. Don't fight
                    this by narrowing repeatedly; watch outcomes, not
                    signal adherence.

Location asset:     Required for any org with a physical location; this is
                    what enables Maps placement, the main reason a local
                    nonprofit runs PMax at all. Requires a verified
                    business profile, linked to the account, kept current
                    (accurate hours, categories, photos). A stale or
                    sparse profile is the most common reason Maps
                    placement underperforms once the technical setup is
                    correct.

Brand exclusions:   Gate on the Brand campaign's actual volume, not on its
                    existence.
                      Brand campaign drawing meaningful impressions
                      -> add a formal brand-list exclusion; otherwise PMax
                         harvests the cheap brand traffic Brand should be
                         winning and reports it as PMax success. That is
                         the most common way a pilot is wrongly judged a
                         win.
                      Brand campaign at negligible volume (tens of
                      impressions/month) -> skip the formal list; a
                      handful of phrase negatives on the PMax campaign
                      carrying the org's brand tokens covers the same
                      risk for a fraction of the effort, and the org may
                      not exist in the platform's brand database yet
                      anyway.

Negatives:          Apply the account-level negative list to the PMax
                    campaign at creation. Do not wait for junk to appear.

Status at creation: PAUSED. Enable only after the pre-launch compliance
                    gate passes.
```

**Treat these config rules as defaults to reason against, not a checklist to satisfy.** Final URL
expansion, brand exclusions, and the customer-acquisition setting are the three most commonly
misapplied purely because "the doctrine said so." Ask what is actually constraining the account
before applying any of them.

## Monitoring cadence

Tightened for the first 8 weeks, then falls back to the normal pass rhythm.

| Week | Check |
|---|---|
| 1-2 | Do not touch (learning period, read only) |
| 3-8 | Weekly: search-terms review, negatives added, spend vs. Search cannibalization, real conversion count and rate |
| 4 | Search-only CTR checkpoint (mandatory, see below) |
| 8 | Pilot review, go/no-go criteria below |
| after | Normal scheduled-pass cadence |

Check the campaign's own status field before touching anything in weeks 1-2: a campaign can read as
still learning past the two-week mark, and an edit made while still learning resets the clock.

A PMax campaign's own CTR under roughly 3% is an early-warning signal, distinct from the 5%
account-wide compliance rule. PMax is exempt from that calculation, so a low PMax CTR is never a
compliance problem by itself, but persistent sub-3% (below even the ~4% baseline normal for PMax)
suggests the asset group or audience signals have drifted from relevance. Review them during the
weeks 3-8 cadence.

Pull the search-term insight report for the weeks 3-8 review rather than inferring from spend and
conversion patterns alone. It is coarser than Search's own report (no ad-group-level segmentation,
since there are no ad groups) but is real data for negative-keyword additions and relevance checks.

### The 4-week Search-only CTR checkpoint

```
At week 4, read account CTR on Search campaigns only, never blended.

Search-only CTR >= 7%   -> continue the pilot
Search-only CTR 5-7%    -> PAUSE the PMax campaign, investigate; do not
                           wait for week 8
Search-only CTR < 5%    -> EMERGENCY BRAKE; pause PMax, compliance
                           surgery only
```

PMax cannot pollute this number (it is excluded from the calculation), but PMax absorbing the daily
budget allowance can starve the Search campaigns that carry the account's compliance basis, and a
Search campaign serving less serves a worse mix of its own queries. That indirect failure is why
this checkpoint exists rather than waiting to notice it at week 8.

**Cannibalization check, every review:** compare account-level clicks, real conversions, and spend
against the pre-pilot baseline, not just PMax's own numbers, and read it on real conversions and
clicks, never the blended conversion total (under a page-view default, both Search and PMax report
near-100% conversion rates, so the blended number cannot show displacement by construction). PMax
reporting its own conversions while account totals stay flat means it absorbed traffic Search was
already winning: a no-go regardless of how good the campaign's own numbers look.

## Pilot review, at 8 weeks

```
GO (keep and scale) when ALL of:
  - Account-level real conversions flat or up vs. the pre-pilot baseline
  - Account-level spend up meaningfully
  - Account CTR still clears the 7% buffer, measured on Search only
  - Search-terms review shows relevant, mission-aligned traffic
  - No policy issues on the asset group

NO-GO (pause) when ANY of:
  - Account-level real conversions dropped
  - Search terms show junk traffic negatives cannot economically contain
  - PMax spend rose while account conversions stayed flat (cannibalization)
  - The asset group drew policy warnings

INCONCLUSIVE (extend 4 weeks, one variable changed):
  - Spend rose, conversions flat, search terms clean; it may still be
    learning
```

Record the outcome either way. A no-go is a real finding worth keeping so the next pass does not
re-propose PMax as a fresh idea.

## What a working result looks like

Directional benchmarks from third-party nonprofit case studies, useful for calibrating whether a
pilot's trajectory is plausible, not as a promise to make to a client:

- Monthly grant spend rising roughly 4-5x over about a year after adding PMax alongside Search,
  with conversions up ~65% in the 3 months following launch.
- On a smaller account, clicks +25% and conversions +22% in the month immediately after launch, a
  reminder results can arrive quickly on a small account too.
- A well-run, Search-heavy grant account reaching well over 100,000 clicks and roughly 20% of
  traffic completing a real engagement action within its first 9 months.

None of these are guarantees; use the account's own pre-pilot baseline as the real yardstick.

## The volume/compliance split

Once PMax is running well, a specific shape tends to emerge: PMax campaigns carry most of the
volume at a CTR (commonly around 4%) that would be non-compliant if it counted, while a small,
tight, high-intent Brand Search campaign carries the account's actual compliance measurement,
sometimes on well under 100 impressions a month. This resolves a real tension: the CTR floor pushes
toward narrow high-intent keywords, while spending the grant pushes toward breadth. PMax takes the
broad volume onto a CTR-exempt surface, leaving Search free to stay clean.

Two cautions before treating this as a target state:
1. It is compliance-fragile. If the account's entire P1-A position rests on a couple hundred
   impressions a month, one bad month swings the ratio hard. Monitor the Brand/Search side as a
   compliance asset, not a leftover; flag if its impressions fall below roughly 200/month while
   PMax carries the account.
2. PMax's low CTR is still real information: mediocre engagement, bought rather than earned
   traffic. It does not threaten compliance, but read it alongside conversion quality rather than
   ignoring it because it is exempt.

## Compliance interactions

- PMax is excluded from the P1-A CTR calculation. It cannot fix a CTR problem and cannot cause one;
  never propose PMax as a CTR remedy.
- Compute account CTR on Search campaigns only. A blended CTR on a PMax-heavy account can be wrong
  by close to an order of magnitude, in the dangerous direction, and can trigger compliance surgery
  against campaigns carrying nearly all the account's real, compliant traffic.
- PMax does not satisfy the structural floors R-STRUCT-2 (2 ad groups per campaign) and R-STRUCT-3
  (2 ads per ad group). Those are Search-campaign concepts; an account cannot meet its structural
  obligations with PMax alone, which is exactly why precondition 3 (a healthy Search campaign)
  exists.
- PMax conversions count for P1-B: a meaningful conversion is meaningful regardless of which
  campaign type produced it.
- The emergency brake suspends PMax work entirely. A braked account does compliance surgery only;
  do not launch, tune, or review a PMax pilot while the brake is on.

## Building one: platform mechanics

A PMax asset group is validated for completeness inside the same call that creates it; there is no
create-then-fill sequence, so the asset group and every asset link need to land in one atomic batch
or the whole thing fails.

A PMax campaign cannot exist without images. Minimum accepted:

| Field type | Ratio | Minimum size | Use |
|---|---|---|---|
| Logo | 1:1 | 128x128 (1200x1200 preferred) | required |
| Marketing image | 1.91:1 | 600x314 (1200x628 preferred) | required |
| Square marketing image | 1:1 | 300x300 (1200x1200 preferred) | required |
| Landscape logo | 4:1 | 512x128 | optional |
| Portrait marketing image | 4:5 | 480x600 | optional |

Source images from the org's own site and look at every one before it ships. A naive scraper grabs
the most prominent homepage images first, which on many nonprofit sites is a strip of press or
partner logos, not the org's own brand. Using another organization's mark as the advertiser's logo
is not a cosmetic error.

Set the campaign budget to not-explicitly-shared at creation: a PMax campaign born on a shared
budget cannot run conversion bidding, and the flag is immutable after creation.

A PMax asset group with no signals and thin conversion data barely explores; search themes are
PMax's equivalent of broad keywords, and without them PMax has almost nothing to explore against on
a low-conversion account. Always attach signals at launch (up to 25 search themes per asset group
is a cheap, high-leverage reach lever, and since PMax is CTR-exempt, it is pure volume upside with
no compliance risk), and check for their absence on any PMax campaign serving near zero.

PMax cannot use a Maximize Clicks bootstrap, so a cold-start PMax campaign (Maximize Conversions
with zero conversions yet) cannot bootstrap itself the way a Search campaign can; it needs the
Search side of the account to produce the first conversions first.
