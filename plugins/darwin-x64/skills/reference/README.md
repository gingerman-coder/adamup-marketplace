# Reference doctrine: index and loading rules

This folder is the plugin's full ad-running knowledge, distilled and cause-neutral. It is the internal
AdamUp doctrine, de-branded, so the plugin operates as well as a managed account.

**Loading rule (this is how comprehensive stays cheap): load a file only when the task in front of you
needs it.** The skills read this index, then pull the one or two files that matter. Never load the whole
folder. The weekly pass budgets under 15k tokens of context; most passes touch three or four files here.

## What to load, when

### Every pass reads these (small, high-value)
- **auction-model.md** how the grant's residual auction works and how to read impression share. The single
  most misread thing about Ad Grants.
- **guardrails.md** the change-authority split (auto vs queued) and the server-enforced invariants.
- **volume-first.md** the sequencing doctrine: accumulate volume, then filter.
- **account-lifecycle.md** the maturity ladder (Stage 0 to 4) that gates build posture and the rec menu.

### Building or rebuilding campaigns
- **architecture.md** campaign and ad-group structure.
- **objective-ladder.md** picking the primary objective rung for this nonprofit.
- **keyword-doctrine.md** the principles: bid on what the org DOES, seed on supporter language, screen by
  judgment.
- **keyword-research.md** the full research methodology and demand model (deep; load when actually building
  the keyword set).
- **broad-match.md** the default match-type posture and negative pre-seeding.
- **ad-copy.md** responsive search ad copy: counts, character limits, pinning, CTR levers.
- **assets.md** sitelinks, callouts, structured snippets, images and logos.
- **bidding.md** bidding modes, the $2 CPC cap, why only conversion-based bidding escapes it, budgets.
- **conversion-ladder.md** the tiered conversion-tracking setup (tiers 0.5 to 3) and the verify loop.
- **site-readiness.md** landing-page and tag readiness before launch. Also read by the `adamup-grant` skill,
  which checks the same site standard while walking a nonprofit through applying for a grant.

### Running the weekly pass and diagnosing
- **recommendations-catalog.md** the full menu of moves the engine can propose, with gating.
- **performance.md** how to read the account: which metrics matter and how to interpret them.
- **search-terms.md** the search-terms mining loop: terms to negatives to new ad groups.
- **low-impressions.md** why a campaign serves little or nothing; the dual-auction ceiling; program holds.
- **quality-score.md** reading and improving Quality Score.
- **change-hygiene.md** freeze windows and one structural change per campaign per pass.

### Compliance and safety
- **compliance.md** the P1-A CTR floor, P1-B meaningful conversion, the emergency brake, surgery playbook.
- **invariants.md** the complete Ad Grants rule catalog (every R- rule code). The exhaustive reference.
- **automation-governance.md** why Google's own recommendations are not neutral; auto-apply stays off.

### Advanced formats and targeting (gated by maturity stage)
- **pmax-gate.md** Performance Max preconditions and config. Grant PMax serves Search and Maps only.
- **ai-max-gate.md** AI Max for Search, three components gated separately.
- **audience-layer-gate.md** in-market, affinity, demographic, and custom audience layering.
- **ab-testing.md** Google Experiments A/B testing (Stage 4 only): readiness, the ranked test types, the
  closed change vocabulary, and power-gate-first results. Execution is disabled in this candidate; this
  reference preserves strategy and future acceptance gates.

### Plumbing
- **host-runtime.md** installed paths, engine capabilities/state, host questions, scheduling, notifications
  and missing-capability fallback. Load when using these services; advertising doctrine stays here.
- **api-and-writes.md** how reads (GAQL) and writes are structured, the canned query patterns, and the
  known API traps. Load when a query or mutate misbehaves.

## The three keyword files, disambiguated
- **keyword-doctrine.md**: the short principles. Read first.
- **keyword-research.md**: the deep methodology (seed, expand, screen, demand model). Read when building.
- **api-and-writes.md**: the mechanics of pulling and summarizing keyword data through the MCP.

- `autopilot.md`: what the weekly run fixes on its own (EXACT negatives, keyword pauses), its limits and reporting.
- `platform-tag-install.md`: Tier 2 per-platform steps to put GA4 on Wix, Squarespace, WordPress, Webflow.
- `telemetry.md`: AdamUp collects no diagnostics; how to answer privacy questions.
