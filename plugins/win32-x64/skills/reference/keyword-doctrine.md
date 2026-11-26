# Keyword doctrine

Keyword research is free under Basic access (`discover_keywords`, `get_keyword_forecasts`). Its output is
a hazard: ~91,000 characters for 50 ideas, and it returns **no relevance score**, so nothing catches a
wrong-entity or commercially-drifted idea automatically. Screening is by judgment, always.

## The three rules

1. **Bid on what the org DOES, not what it IS.** Category terms are near-empty. Bid on the activity, the
   service, the outcome the org delivers, not its self-description or its sector label.
2. **Seed research on the supporter's or donor's language, not the delivered service.** Seeding the
   service reaches people who want to *receive* it, which is the wrong side of the transaction for a
   list-building or donation objective.
3. **Screen every high-volume idea for wrong-entity and commercial drift.** A high volume number is a trap
   when the searchers want a commercial product, a different organization, or the service for themselves.
   Real failures that passed a volume-only filter (kept here as shapes, not causes): a media brand name
   for an accessibility library, "[service] near me" for a charity that gives that service away free, a
   specific medical treatment for a foundation focused on a different condition.

## Match type

Broad match is the **default on every non-brand ad group**. A broad keyword is a seed, not a target;
negatives ship in the same batch to shape it. **Brand ad groups stay exact** (brand exact CTR is the
compliance basis). Tighten toward exact/phrase only for proven winners, and only once the account reaches
the Refine stage (`account-lifecycle.md`).

## Demand reality

Category and identity terms have almost no volume; activity and need terms carry the demand. Check the geo
target against the keywords: a "volunteer abroad" style term is searched from the home country, not the
destination, so a campaign geo-targeted to where the org operates rather than where the searchers are will
serve nothing, and Google warns you of nothing. The campaign just serves nothing and reports ELIGIBLE.

## Output discipline

Never read raw `discover_keywords` output into context. The MCP server summarizes by default (raw behind a
flag). A research artifact is still required; the source is Keyword Planner, and the discipline is
unchanged from the internal doctrine. `get_keyword_forecasts` does **not** forecast unlaunched candidates;
it silently returns data only for keywords already in the account.
