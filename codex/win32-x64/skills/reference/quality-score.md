# Quality Score: diagnosis and fix routing

Quality Score is upstream of both CTR and cost efficiency; improving it helps both. Diagnose from the
three components Google reports per keyword: `search_predicted_ctr` (expected CTR),
`creative_quality_score` (ad relevance), `post_click_quality_score` (landing page experience), each rated
ABOVE_AVERAGE / AVERAGE / BELOW_AVERAGE, alongside the overall 1-10 score (or null if Google hasn't
evaluated the keyword yet).

## Tiers and actions

| QS | Action |
|---|---|
| 1-2 (not null) | Compliance failure (R-KW-3). Pause immediately; no single-word keywords, no QS 1-2 keywords is a hard Ad Grants rule (guardrails.md). |
| 3-4 | Optimization warning. Diagnose components and fix; not urgent but drags ad rank, and if CTR falls, threatens the account CTR floor. |
| 5-6 | Acceptable. Monitor for a downward trend across passes. |
| 7-10 | Healthy. No action. |
| null / "-" | Insufficient data. Google hasn't evaluated the keyword; leave it alone. |

### Recovery assessment for QS 1-2

```
All three components BELOW_AVERAGE:
  -> pause and replace permanently. No amount of ad-copy or landing-page work
     saves it; the keyword is a poor fit for the account.

One or two components BELOW_AVERAGE:
  -> pause now, attempt recovery. Fix the below-average components (below),
     re-enable, and re-check QS in 2-3 weeks. Still <= 2 after fixes -> replace
     permanently.
```

## Component diagnosis

### Expected CTR: BELOW_AVERAGE

Google predicts a lower-than-average CTR for this keyword because the ad group's headlines don't compel a
click when it triggers. Fix in ad-copy.md: add 3-5 headlines that directly include the keyword or a close
variant, with at least one near-exact match to the keyword text, plus a benefit-driven headline that
answers the searcher's implied question.

Example: keyword "family support services near me" in an ad group whose current headlines are
"[Org Name]," "Get Help Now," "Free Services Nearby": none mentions "family support," the keyword's core
phrase. Add "Family Support Services," "Local Family Support," "Free Family Support Services."

### Ad relevance: BELOW_AVERAGE

Either the ad group's keywords don't align with its ad copy, or the ad group's theme is too broad to
write one relevant ad for. Diagnose which:

- **Too many themes in one ad group**: if the ad group mixes 2+ distinct themes ("emergency shelter near
  me," "food bank near me," "youth mentoring programs," "family counseling services" all in one group),
  split into theme-pure ad groups and write a new theme-matched RSA for each (keyword-research.md for the
  moves, ad-copy.md for the new ads).
- **Well-themed but generic copy**: if the keywords are tightly themed but the ad copy is generic, add
  keyword-matching headlines (ad-copy.md).

### Landing page experience: BELOW_AVERAGE

Three possible causes: the URL doesn't match the keyword theme (the ad points to the homepage instead of
the relevant program page), the page itself is slow, not mobile-friendly, or thin, or the page lacks the
specific content the ad promises.

If a more relevant page exists on the org's site, repoint the ad group's final URL (ad-copy.md). If no
such page exists, flag it as a content gap: this is a website change, not something fixable from the ads
account. If the page can't be improved in the near term and other components are also weak, consider
pausing the keyword rather than leaving a compounding BELOW_AVERAGE landing-page score dragging it toward
QS 1-2.

## Recovery tracking

```
Week 0: keyword paused at QS 2. Fix plan: add keyword-matching headlines.
Week 1: ad-copy.md ships the new headlines. Keyword re-enabled.
Week 3: re-pull QS.
  QS >= 3 -> recovery worked, monitor.
  QS <= 2 -> recovery failed, replace permanently.
```

Note the fix, track whether it shipped, and re-check on a later pass. Don't verify in the same session the
fix was made: Quality Score updates on Google's own review cadence, not instantly.

## Batch processing order

When a pass surfaces many low-QS keywords at once, work in this order:
1. Every QS 1-2 keyword, every pass: compliance, not optional.
2. QS 3-4 with expected CTR BELOW_AVERAGE: highest CTR impact, fix ad copy.
3. QS 3-4 with ad relevance BELOW_AVERAGE: fix grouping or ad copy.
4. QS 3-4 with landing page BELOW_AVERAGE: flag as a website change, slowest to resolve.

Within tiers 2-4, prioritize the 3-5 keywords with the highest impression volume per pass rather than
trying to fix everything at once; the rest can wait for the next pass.
