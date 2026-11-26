# The account maturity ladder

How an AdamUp account changes over time. The account is set up **once** and improved forever, and the
*way* it is improved changes as data accumulates. This is the "start super broad, max volume, then refine"
doctrine made into an explicit state machine. The engine-owned selected profile records the current stage and gates
both the build posture and the recommendation menu, so the same account behaves differently at week 1 and
week 20.

Stage transitions are **data-driven**. The engine's `snapshot` tool scores the account against each stage's entry
condition every pass; its `recommend` tool proposes advancing when the next stage is earned, or stepping back
one stage on a regression. A structural advance is a **queued** change: the user approves it.

## The stages

### Stage 0 - Broad Volume (new build)
The goal is **signal, not efficiency**. A young account has no data to be efficient with, and tightening
early strangles it.

- Broad match on every non-brand ad group; **negatives pre-seeded in the same batch**.
- Brand ad groups **exact** (brand exact CTR is the compliance basis).
- **Maximize Conversions** bidding: the only mode that escapes the $2 CPC cap. Maximize Clicks and Target
  Impression Share do not.
- A page-view **primary conversion** installed immediately, so Smart Bidding runs.
- Every campaign at **$329/day**. Geo wide but sane (sanity-check geo against the keywords).

The engine will: add negatives only from clearly-bad search terms. It will **not** prune, tighten match
types, narrow geo, or run experiments.

### Stage 1 - Signal (~4 weeks, or a threshold of clicks/conversions)
Structure unchanged; the account now has query history to mine.

The engine will: mine search terms in earnest, seed new ad groups from winning queries, replace LOW-labeled
RSA assets, enrich negatives. It will **not** tighten match types yet.

### Stage 2 - Refine (stable Search CTR >= floor + enough query history)
The first stage where the account gets *more efficient*, not just bigger.

The engine will: introduce exact/phrase alongside broad for proven winners, prune persistent duds, narrow
geo where the data supports it. One structural change per campaign per pass still holds.

### Stage 3 - Layer (refined base, CTR buffer holding)
Add reach on top of a healthy core.

The engine will: consider audience layers, a PMax pilot (**Search + Maps only** on a grant; not Display,
YouTube, Discover or Gmail), and AI Max components, each behind its own gate. Check `asset_group` (never
`ad_group`) and zero-signal on any PMax diagnosis.

### Stage 4 - Experiment (clears the A/B tester volume floor)
Steady structure, controlled tests.

The engine scores stages 0 to 3; experiments are unlocked at Stage 3 by volume, not by a separate stage
number. They require the age/freeze, volume, Search CTR and single-experiment gates in `ab-testing.md`
together (`ab_propose` enforces them). Experiments are never created, scheduled, promoted or ended
unattended.

## Invariants that override the ladder at any stage

- **The CTR emergency brake** fires regardless of stage: Search CTR below 5% past grace -> stop all
  optimization, compliance surgery only.
- **A program-level hold or a poisoned conversion stack** halts progression until fixed. You cannot mature
  a corpse; optimizing one is what let an account serve 2 impressions in 21 months while reporting healthy.

## Improvising for edge cases

An account that arrives **non-empty** (a stranger who dabbled, or a previously managed account) is not
assumed to be Stage 0. Run the pathology precheck first, then set the stage to the **highest one whose
entry condition the data actually satisfies**. A weird account lands where its numbers say it belongs, not
where a formula assumes. When a situation fits no stage cleanly, hold at the lower stage and explain the
call; never advance on a guess.
