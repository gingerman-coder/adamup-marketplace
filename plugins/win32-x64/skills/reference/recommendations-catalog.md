# Recommendations catalog

The full menu of changes the engine's `recommend` tool can propose, with gating. The engine reads
the snapshot and emits a ranked, gated list; the `adamup` skill renders it. Keeping generation in code
holds the token budget and keeps the interactive and scheduled passes identical.

Each item is tagged **`auto`** (low-risk eligibility, requiring user approval or matching stored standing permission) or **`queued`**
(structural, needs one-word approval). Ordering is roughly by how much each earns its keep on
grant-volume accounts.

## Always available (no volume floor, all stages)

| Move | Tag | Why |
|---|---|---|
| CTR emergency brake | auto | Search CTR < 5% past grace: stop everything else, compliance surgery only. Pre-empts all other items. |
| Search terms -> negatives | auto | The actual improvement engine on these accounts; it compounds. |
| Negative-exact CTR instrument | auto | An exact negative kills one dud query without touching its high-CTR variants (negatives never match close variants). |
| Pause a dud keyword / losing ad | auto | Reversible; removes drag. |
| Replace a LOW-labeled RSA asset | auto | Deterministic from the asset performance label; no significance test needed. |
| Budget shift within $329/day | auto | Every campaign gets the full daily equivalent; Google caps at the account level, so splitting only throttles. |
| Search terms -> new ad group | queued | Structural: promote a winning query cluster into its own ad group. |
| Impression-share diagnosis | (takeaway) | Lost-to-rank vs lost-to-budget. Surfaced as a takeaway, not a change: lost-to-rank at ~0% lost-to-budget is the $2 cap and no budget fixes it. |

## Gated on maturity stage (see account-lifecycle.md)

| Move | Unlocks at | Tag |
|---|---|---|
| Match-type tightening (exact/phrase alongside broad for proven winners) | Stage 2 | queued |
| Keyword pruning of persistent duds | Stage 2 | queued |
| Geo narrowing | Stage 2 | queued |
| Audience layering | Stage 3 | queued |
| PMax pilot (Search + Maps only) | Stage 3 | queued |
| AI Max components (gated separately) | Stage 3 | queued |

Proposing any of these before its stage is the most common way to strangle a young account. The engine
will not.

## Gated on the A/B volume floor (Stage 3 and up)

`experiments_available` appears only at Stage 3+, with 1,500+ clicks/30d and no experiment running.
`ab_propose` then applies the per-campaign gates (7% Search CTR, 28-day freeze, volume, fails closed on
unknowns). Lifecycle and safety: `ab-testing.md`. Never call legacy Python execution from a skill.

## What is never a headline recommendation

- Conversion rate or CPA as a goal. The objective on these accounts is spend, impressions, clicks and page
  views. Junk conversions now beat no conversions; filter once there is data to filter.
- The account-total Conversions column as impact. It is a bidding metric. Segment by action for anything
  reported as meaningful.
- Scaling back for "efficiency." The standing objective is to maximize spend and volume within the CTR
  floor; the CTR floor is the only guardrail on volume.

Every emitted recommendation carries a one-line rationale grounded in a snapshot number, so the render can
explain *why* without a second API read.
