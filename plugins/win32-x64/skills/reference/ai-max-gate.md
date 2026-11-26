# AI Max gate

The canonical definition of when a Search campaign may enable AI Max, which of its three
components to enable, and when to roll back. AI Max is a Stage 3 "Layer" unlock
(`account-lifecycle.md`), gated separately per component, and it is a settings-level upgrade to an
existing Search campaign, not a new campaign type, which makes it far easier to enable carelessly
than PMax.

## Why it matters here

AI Max is the mechanism that makes grant ads eligible for AI Overview placement, a meaningful share
of search-result real estate since 2025 (see `auction-model.md`). Third-party coverage of grant
accounts running AI Max reports CPAs roughly halved, ROAS roughly doubled, CTRs roughly doubled,
and CPCs cut by more than half, directionally consistent with the idea that it finds inventory a
keyword list was too narrow to reach, which is the grant's binding constraint. Treat these figures
as directional, not as an outcome to promise a client: no methodology is published, and this file's
conservative, one-component-at-a-time rollout exists precisely because "it worked well elsewhere"
is not evidence for a specific account.

There are reports that some newer AI-mode search placements require either broad-match keywords or
AI Max to be eligible at all. Re-verify this directly against current platform documentation before
using it to justify enabling AI Max on a campaign that would not otherwise clear this file's
preconditions; eligibility for a new placement type is not a reason to skip the gate.

## What AI Max is

Three distinct capabilities under one switch. Gate them separately: enabling all three at once is
the mistake to avoid, because when performance moves, you will not know which one moved it.

| Component | What it does | Risk | Default |
|---|---|---|---|
| Conversion-aware matching | Broadens query matching past the literal keyword list, prioritizing queries predicted to convert | Irrelevant queries, CTR drag, off-mission traffic | Enable first, alone |
| Dynamic asset optimization | Rewrites and tailors headlines/descriptions per query | Copy the org did not write or approve, serving under its name | Enable second, after matching proves out |
| Final URL expansion | Sends traffic to whichever page the model judges most relevant, not just the ad group's set URL | Traffic landing on thin, stale, or off-mission pages; degrades the keyword-ad-landing-page match Quality Score rewards | Off by default; highest bar |

## Precondition gate

| # | Precondition | Why |
|---|---|---|
| 1 | Conversion tracking is hygienic: exactly one primary, one-per-click, no stacked engagement events | The primary will normally be the default page-view action, which fires on nearly every click and so does not discriminate between queries. Conversion-aware matching under it broadens on predicted click volume, not predicted value, which makes the negative list and search-terms review the real containment, same as broad match. Weigh this before enabling on an account whose real conversions are all thin. |
| 2 | Conversion-based Smart Bidding is live | Broadened matching without a conversion-based strategy filtering it is just noise. |
| 3 | Past the CTR grace period, or CTR comfortably above 8% | An account inside its first two months has no CTR history to absorb a bad week. |
| 4 | Negative keyword list is populated | The negative list is the containment mechanism; enabling broadened matching against an empty list is how an account acquires a CTR problem in a couple of weeks. |
| 5 | For final URL expansion only: the site passes R-WEB-1 with substance, not just an HTTPS check | Expansion can send a searcher to any page on the site. That is fine on a deep, current, mission-focused site and harmful on a thin one with stale pages; requires a deliberate content read. |

Preconditions 1-4 gate conversion-aware matching and dynamic asset optimization. Precondition 5
additionally gates final URL expansion.

## Rollout sequence

Never enable more than one component per pass, and never on more than one campaign at a time until
the pattern is established for the account.

```
PASS 1  Enable conversion-aware matching on ONE campaign: the one with the
        healthiest CTR and most conversion history, since it has the most
        buffer to absorb a bad result. Do NOT enable on Brand; Brand is
        already matching what it should, and broadening it just buys
        generic traffic at brand-campaign prices.
        -> Weekly search-terms review for 3 weeks.
        -> Hold 3-4 weeks before judging (change hygiene: one structural
           change per campaign per pass).

PASS 2  Review. Then either roll matching out to the remaining non-Brand
        campaigns, or roll back. Not both at once.

PASS 3  Once matching is stable account-wide for 4 weeks, consider dynamic
        asset optimization on the same one-campaign-first sequence.

PASS 4+ Final URL expansion, only if precondition 5 passes and only after a
        deliberate decision the site can support it. Most small nonprofit
        sites will not clear this bar; that is an acceptable, expected
        outcome, not a gap to close.
```

## Review criteria

Applied 3-4 weeks after enabling each component, on the campaign it was enabled on.

```
KEEP when ALL of:
  - Campaign CTR at or above its pre-enable level, or down less than 1
    point while impressions rose materially
  - Account CTR still clears the 7% buffer
  - Search-terms review shows relevant, mission-aligned queries
  - Impressions and clicks are up
  - No new R-KW-2 (overly generic) exposure in the matched terms

ROLL BACK when ANY of:
  - Account CTR fell below 7%
  - Search terms show off-mission traffic at a volume negatives cannot
    economically contain
  - Conversions fell
  - Quality Score degraded across the campaign's keywords

  Rollback is a single settings change, effective immediately; there is no
  sunk cost. Roll back decisively and record why.

EXTEND 2 weeks when impressions rose, CTR held, and conversions are flat.
  Conversion lag is real; give it the extra window before judging.
```

## Interaction with the broad-match gate

AI Max's conversion-aware matching and broad match both widen the query surface, and they compound.
Running both aggressively at once on the same ad group is how an account loses control of its
search terms.

- Do not enable AI Max on a campaign in the same pass that broad match is introduced anywhere in it
  (`broad-match.md`); space them by at least one full review cycle.
- If account CTR sits in the 5-7% warning band, neither gate opens; tighten first.
- If a search-terms review after enabling AI Max shows drag, the first lever is tightening broad
  match back toward phrase, not disabling AI Max: broad match is the blunter instrument, since AI
  Max's matching is at least conversion-aware.

## Compliance interactions

- R-KW-2 (no overly generic keywords) still applies to what AI Max matches. The account is
  accountable for the queries its ads actually serve on, not only the keywords typed in. If the
  matched terms drift generic, that is a compliance finding, fixed with negatives plus rollback,
  not excused because "AI Max chose it."
- AI Max does not exempt the account from negative-keyword discipline; a wider matching surface
  needs a better negative list, not a smaller one.
- The emergency brake suspends AI Max rollout. A braked account tightens, it does not broaden. If
  the brake activates while AI Max is live, disabling it is a legitimate first CTR lever: it is a
  one-click reduction in impression surface.
