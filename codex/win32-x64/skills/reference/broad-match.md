# Broad match gate

The canonical definition of when a keyword may run broad match, and why broad is the default
non-brand match type from Stage 0 of the account lifecycle (`account-lifecycle.md`) onward.
`keyword-doctrine.md` states the default in one line; this file carries the full precondition set,
seed selection, and rollback logic behind it.

## A broad keyword is a seed, not a target

An intuitive but wrong gate asks: does this keyword have real search volume on its own? That
question is a category error when applied to broad match. A broad-match keyword is not a term you
bid on; it is a seed the platform uses to find semantically related queries. Its own volume barely
matters to how much traffic it generates: a 40-search-per-month seed can pull thousands of
impressions across the query space around it, which is exactly the mechanism a grant account needs
when it cannot find inventory.

Gating broad match on the seed's own volume forbids it exactly where it is most needed: on the
low-volume, over-qualified keyword sets that are failing to serve. A new account built entirely on
specific phrase-match keywords (stacking audience, action, location, and cause into one phrase)
commonly shows most of its keywords `RARELY_SERVED`; phrase alone rarely reaches adequate volume
for a small, niche account.

Volume still matters, but for a different decision: it tells you which phrase and exact keywords
are worth having, and when a broad seed is so obscure the platform has nothing coherent to expand
it into. It does not decide whether broad match is permitted.

## Broad is the default

```
DEFAULT for every non-brand ad group:
  broad seeds carry the ad group
  phrase/exact support them and capture proven winners

EXCEPTION, the only one:
  BRAND ad groups stay EXACT (plus the org's own misspellings)
```

No constraint check is required to use broad on a non-brand ad group; broad is simply the default.
The constraint model further below governs one thing only: when to stop adding it.

### Why brand stays exact

Not caution: brand exact match is the account's compliance basis. Brand ad groups commonly run 35
to 56% CTR at Quality Score 8 to 10 on tiny volume, and that CTR is what holds the account's P1-A
measurement above the floor. Broaden brand and it starts matching generic category searches; brand
CTR collapses toward the account average and the compliance basis goes with it, for negligible
upside, since brand terms have almost no incremental volume to unlock.

Brand exact is a load-bearing wall. Everything else is a partition.

### What "default broad" looks like

```
Per non-brand ad group:
  2-4  BROAD seeds     the core intent, 2-3 words each; these carry it
  2-4  phrase          specific variants worth having in their own right
  2-4  exact           proven converters promoted from the search-terms report

Per brand ad group:
  ALL EXACT           the org name and its misspellings; no broad, no phrase
```

### Anti-pattern: the token broad seed

Shipping exactly one broad seed per non-brand ad group and letting phrase/exact carry the rest
satisfies a checklist reading of "every non-brand ad group has a broad seed" while inverting the
doctrine: broad seeds are supposed to carry the ad group. One seed carries nothing, and a broad
seed with zero volume is not a seed at all; it gives the platform nothing coherent to expand from.

```
CHECK on any account review:
  broad_count / non_brand_keyword_count

  < 25%          -> under-built; expand to 2-4 seeds per non-brand ad group
  any seed at 0  -> replace it
```

## Preconditions for any broad match

These make aggressive broad match survivable rather than reckless. The difference between "broad
match works" and "broad match destroys the account" is entirely this list.

| # | Precondition | Why |
|---|---|---|
| 1 | Conversion-based Smart Bidding is live (not a Maximize Clicks bootstrap) | This is the safety mechanism: with Maximize Conversions the algorithm uses predicted conversion likelihood to choose which expansions to serve on. Broad match without a conversion signal to filter it is untargeted spending. |
| 2 | Conversion tracking is clean: exactly one primary, one-per-click, no stacked engagement events | A hygiene check, not a purity check; the primary will normally be the default page-view action, and that is expected. |
| 3 | A populated negative-keyword list exists | Broad match plus an empty negative list is how an account acquires a CTR problem in a couple of weeks. Target 30-50 seed negatives before the first broad keyword. |
| 4 | A paired negative batch ships in the same change, never after | See negative pre-seeding below. |
| 5 | Weekly search-terms review for 3-4 weeks after | The only real containment mechanism; non-negotiable. |

Once campaigns launch on Maximize Conversions with a conversion action already in place
(`conversion-ladder.md`), preconditions 1 and 2 are usually satisfied by default; the live work is
3 through 5, the negative list.

### The page-view default weakens precondition 1; preconditions 3-5 carry the load

A page-view conversion fires on nearly every click, so it does not discriminate between them. Broad
match under it expands roughly on predicted click volume, not predicted value, which makes it less
self-limiting than the precondition-1 argument assumes. This does not withdraw broad match (the
binding constraint for most grant accounts is inventory, not CTR, and phrase-only starves them of
it), but it does mean:

- The negative list and the weekly search-terms review are the real containment, not a backup to
  the algorithm.
- Weekly search-terms review runs on an ongoing basis, not just 3-4 weeks, on any campaign running
  broad under a page-view primary.
- The CTR lever below is the emergency reaction and gets checked every pass regardless of how well
  spend is going.

## Grace-period rule

| State | Broad match |
|---|---|
| In CTR grace period, conversion tracking not yet verified | No |
| In grace period, Smart Bidding live and tracking verified | Pilot: 1 broad seed per ad group, on its dominant intent; weekly review |
| Post-grace, Smart Bidding live, tracking verified | Standard rollout per the CTR lever below |

A new account has no CTR history to absorb a bad week, which is the real reason for caution during
grace. It is not a reason to launch an account phrase-only and leave it starving for two months.

## The CTR lever

The one place the constraint still governs a decision, and it runs in the opposite direction from
the default:

```
Search-only CTR >= 7%           -> expand broad, normal case
Search-only CTR 5-7%            -> hold, do not add broad; tighten existing
Search-only CTR < 5% past grace -> emergency brake; no expansion at all
NO DATA (never served, or under ~100 impressions)
                                 -> EXPAND NOW; there is nothing to protect
                                    yet, and missing volume is the actual
                                    problem. Ship the paired negatives and
                                    start the weekly search-terms review
                                    from day one.
```

A young, unserved account waiting for "enough CTR data" before opening up broad match is circular:
it cannot produce CTR without impressions, cannot get impressions without inventory, and cannot
reach inventory without broad seeds.

## Seed selection

Since the seed's own volume is not the gate, choose seeds on quality of intent.

**Good broad seeds:**
- The ad group's core intent, stated plainly, in 2-3 words ("meal delivery for seniors", not
  "free home meal delivery for elderly residents in the county").
- Terms that describe what the org does, not what it is (see `keyword-doctrine.md`: activity and
  service language carries far more volume than category and identity language).
- Terms whose semantic neighborhood is clearly on-mission; say the seed out loud and ask what else
  the platform might reasonably relate it to. If the answer includes a commercial vertical, expect
  drift and pre-seed against it.

**Bad broad seeds:**
- Over-qualified long-tail strings: handing the platform four constraints and asking it to relax
  them produces unpredictable expansion. Long-tail belongs in phrase or exact.
- Terms with ambiguous meaning across domains ("shelter", "recovery", "support", "placement").
- Anything that would fail as an overly generic literal keyword (R-KW-2). Broad match does not
  launder a generic term.

**Recommended mix once inventory-constrained and preconditions are met:**

```
1-2  broad seeds     the core intent, for reach
3-6  phrase          the specific, verified-volume variants
2-4  exact           proven converters harvested from search terms
```

Exact-match keywords should increasingly come from the search-terms report rather than research:
when a broad seed surfaces a query that converts, promote it to exact. That is the intended
lifecycle, and how a broad seed pays for itself.

## Negative pre-seeding requirement

No broad-match keyword launches without a paired negative-keyword batch in the same change, never
after. Source negatives from the same keyword-research pull used to generate the broad candidate:
every off-mission term returned alongside it is a same-session negative candidate, a free byproduct
of research already run.

**Commercial-drift risk.** In any vertical where a paid commercial equivalent of the org's service
exists, that commercial vocabulary is the primary drift risk. Example shape: a broad seed for a
senior-companionship program pulling heavily into paid home-care-agency vocabulary, a wrong-intent
term at tens of thousands of monthly searches sitting right next to the on-mission seed. Identify
the paid equivalent for the org's vertical up front and write its vocabulary into the seed negative
list before the first broad keyword goes live.

**Wrong-intent screen.** Where the keyword tool exposes no relevance or similarity score, treat
this as a judgment call: read the competition level and bid-range columns on each candidate. A
candidate from a nonprofit seed that comes back high-competition with a rich commercial bid range
is almost always paid-commercial demand and needs a mission-alignment check regardless of volume.
High volume never waives this check.

## Monitoring and rollback

Weekly search-terms review for 3-4 weeks minimum after any broad keyword goes live.

```
ROLL BACK a broad seed to phrase when ANY of:
  - Account CTR drops below 7%
  - The ad group's CTR drops more than 2 points
  - Search terms show off-mission traffic negatives cannot economically contain
  - Quality Score degrades across the ad group

KEEP and consider expanding when:
  - Impressions and clicks up, CTR held within 1 point
  - Search terms are relevant
  - New converting queries appear (promote them to exact)
```

Rolling back is one change and takes effect immediately. Treat a rollback as a normal outcome of a
test, not a failure; the alternative, never testing, leaves the account exactly where it started.

## Interaction with AI Max

AI Max's conversion-aware matching also widens the query surface, and the two compound. Do not
enable AI Max on a campaign in the same pass that broad match is introduced anywhere in it; see
`ai-max-gate.md`.
