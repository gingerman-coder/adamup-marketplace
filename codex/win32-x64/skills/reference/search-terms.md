# Search terms: the mining loop

Mining the search-terms report for new keyword candidates and new negative candidates is the single
highest-value recurring task in running an account. It is where the two priorities meet: finding new
conversions (growth) and cutting CTR-killing junk (compliance).

**This file is the filtering mechanism under `volume-first.md`.** In phase 1 the conversion signal cannot
filter anything: a page-view primary fires on nearly every click, so it cannot tell a good query from a bad
one, and broad match is the default. That makes this loop, not the bidding algorithm, the thing standing
between the account and a CTR problem. Two consequences:

- **The review is ongoing, not a one-time onboarding ritual.** It does not lapse while a campaign runs broad.
- **Negatives carry no learning period.** They are exempt from freeze windows and the one-structural-change-
  per-campaign-per-pass budget (`guardrails.md`). They are always safe to ship, in every phase.

Judge search terms on **relevance and CTR, never on conversion rate**. In phase 1 the conversion rate is
junk by construction and is not evidence about a query.

## Pull the report

```sql
SELECT
  search_term_view.search_term,
  search_term_view.status,
  metrics.impressions,
  metrics.clicks,
  metrics.ctr,
  metrics.conversions,
  metrics.cost_micros,
  ad_group.name,
  campaign.name
FROM search_term_view
WHERE segments.date DURING LAST_30_DAYS
  AND metrics.impressions > 0
ORDER BY metrics.impressions DESC
```

Focus on `status = NONE`: search terms that triggered an ad but are not yet added as a keyword or excluded
as a negative. `status = ADDED` is already a keyword; `status = EXCLUDED` is already a negative.

## New keyword candidates

**The tiers below assume a real conversion signal. In phase 1 they do not have one.** Under a page-view
primary that fires on nearly every click, "conversions > 0" is approximately the same set as "clicks > 0",
so read literally the tiers select almost nothing useful in phase 1.

```
PHASE 1 (page-view primary):  rank candidates by CLICKS, then CTR.
                               Ignore the conversions column entirely.
                               Tier 1 collapses into Tier 2, substituted below.

PHASE 2 (a real action is primary and has volume): the tiers apply as written.
```

Check which phase the account is in (`volume-first.md`) before applying these thresholds.

### Tier 1: converting terms (phase 2 only)

```
Conversions > 0 AND status = NONE
-> This term drove a real conversion. Add it as a keyword.
```

The most valuable find: a term that already converts will convert again.

**In phase 1, substitute:** `clicks >= 3 AND status = NONE`, ranked by clicks descending. A term the
account is already paying for repeatedly is the phase-1 equivalent of a proven term, and it is the only
evidence available.

### Promotion is additive. It never narrows.

Promoting a search term to an explicit keyword must not reduce the account's query surface.

```
DO:
  - Add the promoted term as a new keyword.
  - Build a new ad group, or a new campaign theme, where the term points at an
    intent no existing ad group covers. This is the highest-value output of
    this file: search terms are the cheapest source of new ad-group ideas
    there is, and a new ad group is new inventory, not a reallocation of
    existing inventory.
  - Add matching sitelinks or callouts if the new theme warrants them.

DO NOT:
  - Pause, tighten, or narrow the broad seed that surfaced the term. The seed
    is what found it and will find others. A promoted term and its seed
    coexist; the auction resolves the overlap on its own.
  - Treat promotion as a substitute for the seed's continued running.
  - Promote in order to "clean up" the keyword list.
```

**Target: 10 to 20 promotions per month on an account with real click volume** (roughly 100+ clicks/month).
Below that, say there is nothing to promote from rather than manufacturing candidates. An account running
at only a handful of clicks per month has no input for this file to work with, and that absence is itself
the finding: the constraint is upstream demand, not search-term mining.

### Tier 2: high-engagement terms

```
Clicks >= 5 AND CTR >= 5% AND conversions = 0 AND status = NONE
-> Gets clicked at a healthy rate but hasn't converted yet. May convert with
   more volume. Add as a keyword to give it that chance.
```

### Tier 3: promising terms (watch list)

```
Clicks >= 2 AND CTR >= 8% AND conversions = 0 AND status = NONE
-> Small sample but a strong signal. Add if clearly mission-aligned.
   Otherwise note it and check again next pass.
```

### Handing off a keyword candidate

For each: state the source data (term, impressions, clicks, CTR, conversions, campaign, ad group);
recommend a theme bucket and which existing ad group it fits (or flag that none fits well, which may
signal a new ad group); recommend a starting match type, phrase by default, exact for a high-value specific
term. This is a starting recommendation only: the final call on match type, including whether the term
clears the volume and relevance bar for broad match, belongs to the account's keyword-screening step and
`keyword-doctrine.md`'s broad-match gate. A converting term with real volume behind it is a plausible
broad-match candidate; flag it as such if it looks like one, but don't assign broad match here.

## New negative candidates

### Tier 1: pure CTR drag (highest priority)

```
Impressions >= 50 AND clicks = 0 AND conversions = 0 AND status = NONE
-> Generates impressions with zero clicks. Pure CTR denominator inflation. Block it.
```

The most damaging pattern for the CTR floor: high impressions with zero clicks directly reduce account CTR.

### Tier 2: irrelevant clicks (budget waste)

```
Impressions >= 20 AND clicks >= 1 AND conversions = 0 AND CTR < 2% AND status = NONE
-> A few clicks, never converts, low CTR. Wastes budget and drags CTR.
   Block it if clearly irrelevant.
```

Use judgment: a term with low CTR and zero conversions may still be relevant if the ad group is new and
needs more data. Block it once it is clearly off-mission.

### Tier 3: off-mission terms (any volume)

```
status = NONE AND the term is clearly unrelated to the org's mission
-> Block regardless of volume. Even small impression counts add up.
```

Examples: "dog grooming supplies" surfacing on a food bank's campaign, "resume writing service" on a
literacy nonprofit's campaign, "veterinary clinic jobs" on an animal shelter's campaign.

### Safety check: never negative a converting term

```
HARD RULE: if conversions > 0 for a search term, do NOT add it as a negative.
A converting term is valuable regardless of its CTR.

If a term has conversions > 0 but CTR < 5%:
  It is NOT a negative candidate.
  It IS a keyword candidate (Tier 1).
  The low CTR may mean the ad copy doesn't match well; fix the ad copy,
  don't block the term.
```

### Handing off a negative candidate

State the source data (term, impressions, clicks, conversions, campaign); recommend match type (phrase by
default, exact if the term is specific enough that you don't want to block related terms too); recommend
level (campaign by default, account-level only for universally irrelevant terms); state why it's
irrelevant, briefly, for the record.

## The third channel: language for ad copy

The search-terms report is not only a source of keywords and negatives. It is the only place you see the
actual words people use to describe what the org does, and that is raw material for ad copy.

The logic: if a phrase does not convert as a search term, it is unlikely to convert as a headline; if a
phrase converts well as a search term, it is likely to convert as a headline. The searcher has already told
you which framing resonates.

```
CONVERTING LANGUAGE (feed into ads)
  For every search term with conversions > 0, note the specific phrasing,
  especially where it differs from your own keyword. "help for my mom at
  home" converting against the keyword "senior companion services" is a
  finding: the searcher's own words are warmer and more specific than yours.
  -> Candidate headline and description language.
  -> Also a candidate for callout text.

NON-CONVERTING LANGUAGE (remove from ads)
  Phrasings that appear in your current headlines and descriptions and show
  consistently poor CTR or zero conversions as search terms.
  -> Removal candidates.

QUESTION PHRASINGS
  Search terms framed as questions indicate informational intent and often
  make strong headlines and strong sitelink labels. Cross-reference "People
  also ask" for the same query cluster to find related questions.
```

Do this **after** the negative and keyword passes, not before: the keyword and negative work determines
which terms are staying, and there is no point mining ad-copy language out of a term about to be blocked.

RSAs make this cheap to act on. The ad platform tests headline combinations automatically, so adding a new
variant costs little and gets discarded quickly if it underperforms. There is not much to lose by adding a
well-sourced variant, and a real gain when the searcher's own words outperform yours.

## Processing order

1. **Negatives first** (Tier 1 -> Tier 2 -> Tier 3). Removing junk impressions immediately helps CTR.
2. **Keywords second** (Tier 1 -> Tier 2 -> Tier 3). Adding converting terms grows conversions and spend.
3. **Ad-copy language third.** Mined from the terms that survived steps 1 and 2.

This order updates the negative list before adding keywords, reducing the chance a new keyword immediately
matches a term that should be blocked, and it means ad copy is only ever built from language you intend to
keep competing for.

## Cadence

Normal cadence is every scheduled pass. **Tighten to weekly for 3 to 4 weeks after any expansion of the
matching surface**: a broad-match keyword going live, an AI Max component being enabled, or a Performance
Max campaign launching (see `keyword-doctrine.md`, `account-lifecycle.md`). Each of these widens the set of
queries you serve on, and this report is the only containment mechanism. A wider matching surface demands a
better negative list, not the same one.

- Expect 5-20 actionable terms per pass for a moderately active account.
- Don't batch-add everything at once. If the report surfaces 30+ negative candidates, add the worst
  offenders (highest impression count) first; the rest can wait.
- Track what's been processed. A term showing `status = ADDED` or `status = EXCLUDED` in the next report
  confirms it was implemented.

## Output

This step does not decide the final keyword or negative object on its own. It produces a keyword candidate
list (source data, recommended bucket, ad group, starting match type) and a negative candidate list (source
data, recommended match type, level, reason). The keyword-side screening, including the full invariant
check and the broad-match gate, belongs to `keyword-doctrine.md` and `compliance.md`.
