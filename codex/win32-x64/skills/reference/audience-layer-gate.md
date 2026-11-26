# Audience layer gate

The canonical definition of when and how audience-segment targeting (in-market, affinity, detailed
demographics, custom audiences) may apply to a Search campaign. Audience layers are the other
Stage 3 "Layer" unlock in `account-lifecycle.md`, alongside PMax; read `broad-match.md` first,
since this file reuses its grace-period logic rather than re-deriving it.

Audience-layer targeting is a separate, additional layer on top of keyword targeting.
`keyword-doctrine.md` screens keyword text; this file governs who sees the ad, independent of what
keyword triggered it. The case for it: some organizations have real confidence in higher-volume
keywords that aren't mission-specific in text, with that confidence coming from an audience-signal
filter rather than keyword text alone, accepting more reach and compliance risk than pure text
screening allows, in exchange for real volume.

## Current capability note

Standard platform-defined segments (in-market, affinity, life-event, detailed-demographic) use
different targeting-criterion types than a simple custom user-list. Depending on what your
management tooling implements, only custom audiences (website-visitor remarketing, Customer Match)
may be available today, with platform-defined segments requiring additional tool support to attach.
Until that support exists, this file's rules apply to the two custom-audience types already usable
and serve as the rollout policy for platform-defined segments once support lands.

## Hard boundary: sensitive categories

Religion, ethnicity, sexual orientation, health status or condition, and similar sensitive-interest
categories may never be used as an audience-targeting signal, neither a platform-defined segment
nor a custom or inferred audience built from an org's own data. This is a hard advertising-policy
line, not just an internal caution, and it holds regardless of what an org's actual donor base
looks like.

Concretely: never build or infer a religion-coded, ethnicity-coded, or similarly identity-coded
audience segment for any client, no matter how relevant it would seem. An org serving a specific
ethnic or religious community can solve this compliantly through **geography** instead, targeting
the metro areas where that population concentrates, rather than an inferred identity-based segment.
That geographic-proxy pattern reaches the right population without touching a protected category
directly, and it generalizes to any client whose donor or beneficiary base skews toward a
particular community.

**Allowed segment types, once available:**
- Detailed demographics (age bracket, parental status, homeownership status where offered), never
  religion or ethnicity-coded categories.
- In-market segments describing a behavior, not an identity (e.g. "Charitable Donations,"
  "Nonprofits & Philanthropy" where defined as a segment).
- General affinity categories describing an interest, not an identity (broad philanthropy or
  giving-oriented categories).
- Custom audiences built from the org's own first-party data (website visitors, Customer Match
  from a donor list): these describe behavior or relationship to the org, not an inferred
  protected trait.

If a segment's name or targeting logic could plausibly function as a proxy for a protected
category, even with a neutral platform-assigned label, treat it as disallowed. Fail closed, same
discipline as the keyword wrong-entity screen in `keyword-doctrine.md`.

## Volume/confidence tier table

Provisional until real reach data is wired into your tooling (a platform's own audience-sizing and
reach-forecasting services can supply real reach tiers once available; until then, treat this table
as a placeholder).

| Audience layer confidence | Use |
|---|---|
| Custom audience, first-party (website visitors, Customer Match) | Observation only until Smart Bidding is live and the list has meaningful size; no minimum established, flag for review once real Customer Match data exists |
| Platform-defined segment (in-market/affinity/detailed-demographic), once available | Observation only, standard rollout below; never launch straight to Targeting mode |

## State gate

| Account state | Audience targeting allowed? |
|---|---|
| Maximize Clicks bootstrap, still in CTR grace period | No live segment targeting or observation-mode bid adjustment, regardless of segment type |
| Smart Bidding live, still in grace period | Observation only, on the single most relevant segment for the ad group's dominant intent; never Targeting mode this early |
| Post-grace, Smart Bidding established | Observation first for at least 2-4 weeks per segment, then Targeting mode only if Observation data shows the segment overlaps meaningfully with actual conversions |

## Rollout order: Observation before Targeting

The targeting-mode parameter (Targeting vs. Observation) is the core safety mechanism, not a
stylistic choice.

- **Observation** attaches the segment for reporting and bid-adjustment only; it does not restrict
  which searches the ad is eligible for, since the underlying keywords still do all the targeting.
  Low risk: worst case, a bad segment choice wastes reporting effort, not spend or CTR.
- **Targeting** restricts the ad to show only to users in the segment, on top of keyword matching.
  This is where the real risk/reward tradeoff lives, and where a bad segment choice can silently
  cut off delivery or waste spend on the wrong slice of an already-narrow keyword's traffic.

Never launch directly to Targeting mode. Every new segment starts in Observation, gets evaluated
against real conversion and CTR data for at least 2-4 weeks (the same cadence `broad-match.md`
uses for new broad-match keywords), and only moves to Targeting if that data supports it.

## Proactive negative-audience exclusion

Most audience work here defaults to excluding only past converters or site visitors already
captured elsewhere (the standard remarketing-exclusion pattern). A second, underused pattern:
exclude demographics that structurally cannot use the service, independent of any conversion
history, for example excluding older age brackets from a youth-only program's ad group, or
excluding a demographic segment plainly outside a program's own eligibility criteria. A click from
someone who cannot possibly qualify is a wasted click and a CTR drag regardless of prior visit
history, so this exclusion does not need to wait for negative conversion data; apply it at launch
if the program's own eligibility rules make the mismatch obvious.

This is a narrower, higher-confidence version of the sensitive-category boundary above: it excludes
based on the program's own stated eligibility (age, parental status where relevant), never a
protected or identity-coded category. Same fail-closed discipline: if excluding a group could
plausibly read as a proxy for a protected category, do not build it under this rule.

## RLSA: warm-traffic-only aggressiveness

Remarketing Lists for Search Ads, a website-visitor list attached to a Search campaign, is
typically supported today even where standard in-market or affinity segments are not, since it is
built through the same custom-audience path as Customer Match.

The pattern worth adopting: use RLSA to be *more* aggressive (broader match, higher bids) but only
for the segment of users who have already visited the site, never account-wide. A visitor who has
already seen the org once carries materially less relevance risk than a cold searcher, so the case
for broadening reach or bidding harder is much stronger for that specific audience than for the
account as a whole. This is a live option today for any org with enough site traffic to build a
meaningful remarketing list, gated by the same Observation-first rollout above: attach in
Observation, evaluate 2-4 weeks, only move to Targeting (or use it to inform a bid adjustment) once
the data supports it.

## Nearer-term option requiring no new engineering

If an org has a donor CRM or email export, a Customer Match audience can be built today via a
standard custom-audience creation call (`audience_type: CUSTOMER_MATCH`) and attached in
Observation mode. This has limited value until the list has real size and Smart Bidding is live to
use it as a genuine training signal, but it is free to stage now and costs nothing to have ready.
