# Keyword research: seeding, expansion, and the demand model

The deep methodology behind keyword-doctrine.md's three rules. Read that file first for the compressed
version; this file is the full research and screening process, plus the demand-side reasoning behind it.

## Core principle

No keyword is proposed, kept, or expanded on judgment alone. Every keyword decision is backed by real
data: Google Keyword Planner volume for candidates, or the account's own live serving status for anything
already running. "This seems like it would get searched" is not a basis for a keyword; it is exactly how
an account fills up with terms that never serve.

## The demand model: what to seed with

Every candidate keyword sits on one side of a line:

- **Supply-side** (what the org IS): "[cause] charities near me," "[cause] nonprofit," "donate to
  [cause]." Describes the org, its category, or the act of giving to it. The searcher is looking for an
  organization.
- **Demand-side** (what the org DOES, for whom, why): "food pantry near me," "free tutoring for kids,"
  "emergency shelter tonight," "how to help a parent with dementia." Describes a need, a service, a
  question, a problem. The searcher is looking for help, information, or an action.

**Almost all the search volume is demand-side, and almost all the instinct runs supply-side.** People do
not search for organizations in order to donate; giving follows a relationship, an appeal, or a personal
connection, not a search. What people do search is their own problem. A narrow category term restricted
to one cause and one city can return only a few hundred searches a month nationwide, before geo-targeting
and the dual auction take their cut (auction-model.md); an account built entirely on that shape of term
has no realistic path to spending its budget.

### Donation intent is a decision, not a search

By the time someone decides to give, they usually already know the recipient, so they navigate by brand
rather than search a category. Illustrative pattern, seen repeatedly across verticals: a
donation-transaction phrasing like "donate to [cause] research" or "fund [cause] program" returns at or
near zero volume, while the adjacent condition, problem, or interest the cause is organized around ("the
specific condition name," "caregiver burnout," "ptsd in veterans") returns real, often order-of-magnitude
larger volume. The donation ask belongs on the landing page and in the ad copy; it does not belong in the
keyword.

```
DO NOT build ad groups around: donate to X / support X / fund X / X charity /
                               where to give to X / best charity for X

DO build ad groups around the ADJACENT INTEREST:
   the condition or problem   the specific health condition, the life problem
   the service sought         the type of care, program, or support
   the cause interest         the broader issue the org exists around
```

Exception worth keeping: comparison/evaluation queries ("best animal charities," "top rated food banks")
are real, because that searcher has decided to give but not to whom. Low volume, high intent: worth a
small exact/phrase cluster, never a whole campaign.

### Where demand-side volume comes from, roughly in order of size

1. **The service, in the beneficiary's words**, not the program's official name. ("Nutritional Security
   Initiative" internally; "food pantry near me," "free groceries," "where to get food" from the people
   who need it.) This gap is usually the single largest untapped source of volume in the account; mine it
   from the org's own frontline staff, inbox, and site search.
2. **The problem, before the service is known** ("my mom keeps forgetting things," "landlord won't fix
   heat"). High-volume, low-competition, and where a grant account wins most easily, because commercial
   advertisers have little to sell against them.
3. **Questions**: harvest from "People also ask" and "Related searches" on the SERP for each core service
   term, and from the org's own FAQ page and inbox. These also make strong RSA headlines and sitelink
   labels (ad-copy.md).
4. **Adjacent-need and life-event terms**: the situations that put someone in the org's path ("moving a
   parent into assisted living," "eviction notice what to do," "after school programs near me").
5. **Volunteer and participation intent**: consistently under-exploited, and genuinely searched, because
   volunteering, unlike donating, is a search-initiated behavior. Real, local, low-competition volume.
6. **Mission conquesting**: a peer or comparable nonprofit's site draws demand for problem/need language
   the org's own content never suggested. Not their brand terms; read the peer's landing pages by hand
   for service/problem vocabulary, then feed that language as seeds (`discover_keywords` takes seed
   keywords only, not a URL; the Keyword Planner UI's "start with a website" option is the only by-URL
   path).
7. **Search Console**: where available, 12-18 months of the org's own organic query data surfaces
   demand-side terms the site already earns impressions for, free of keyword-planner guesswork. Terms
   with decent impressions but weak click-through are gap candidates; the phrasing itself is a direct feed
   into ad copy's mirror test.
8. **Brand and category terms**: still belong in the account. They convert well and cost little, and they
   carry the account's CTR, but they are not the volume engine. Keep them, size them honestly.

### Portfolio balance target

| Keyword class | Share of keyword list | Expected share of impressions |
|---|---|---|
| Demand-side (service, problem, question, adjacent) | 70-85% | 85-95% |
| Volunteer / participation | 5-15% | 3-10% |
| Supply-side (brand, category, donate) | 10-20% | 2-8% |

Supply-side terms are a meaningful share of the list and a small share of impressions; that asymmetry is
correct. If supply-side terms are producing most of the impressions, the demand-side research has not
been done.

**Diagnostic**: if supply-side keywords exceed roughly 40% of an account's list, the account is bidding
on the organization rather than on what it does. That is a rebuild, not a match-type tuning problem;
broadening match types on a supply-side list just finds more ways to say the same near-empty category
term.

## Sourcing tools

| Tool | Use | Cost |
|---|---|---|
| Google Keyword Planner (`discover_keywords`) | Primary. Ideas from broad seeds, each with monthly volume, competition, competition index, bid range, and seasonality. Draws directly from the account's own auction. | Free; counts against a shared daily operation ceiling (~15,000 ops/day), effectively unlimited for normal research. |
| `get_keyword_performance` | Volume/CPC/QS/conversion history for keywords already in the account. | Free |
| "People also ask" / related searches | Question-form and demand-side term discovery on any SERP. | Free |
| Google Trends | Direction and seasonality (Keyword Planner also returns 12 months of seasonality per idea). | Free |
| The org's own site search, inbox, and frontline staff | Often the best source of the beneficiary's actual vocabulary. | Free |
| DataForSEO or a similar paid provider | Optional fallback: per-market volume for a non-US geo (`discover_keywords` has no geo parameter and returns one geo's volume), or when a planner call errors. Never required. | Paid, per call |

**`discover_keywords` output is a hazard, not just a data source**: a single call can spill to roughly
90,000 characters for 50 ideas. Never read that raw output into context; let it be summarized before
reasoning over it (keyword-doctrine.md). **`get_keyword_forecasts` does not forecast unlaunched
candidates**: it silently returns data only for keywords already live in the account, so don't use it to
evaluate new terms.

**No relevance score.** Unlike some third-party tools, Keyword Planner returns no similarity-to-seed
score, so the wrong-intent and commercial-drift screen (Screen 3 below) is always a judgment call, not an
automated filter. Use `competition` and bid range as weak proxies: a nonprofit-seeded idea that comes
back high-competition with a rich bid range is almost always paid-commercial demand, not free-service or
volunteer intent.

**How to run it:**
1. Generate broad seeds, not final keywords: 1-3 words per seed, one per ad group theme. Long,
   pre-qualified seeds return almost nothing useful; short broad seeds return dozens of ideas each.
   Generate broad, then qualify, never the reverse: a candidate stacked with 3+ qualifiers (audience +
   action + location + cause) consistently returns zero or near-zero volume even when the unqualified
   core term has real demand.
2. Screen the ranked results for wrong intent and commercial drift (Screen 3) before treating any of them
   as candidates.
3. Only after volume is confirmed on the broad/core term, layer in location or audience modifiers if the
   ad group needs them, and re-check the modified phrase's volume. Never assume a modifier preserves the
   core term's volume.
4. Where multiple candidate phrasings cover the same intent, keep only the 2-4 highest-volume ones
   (Screen 5).
5. A candidate with 0 or near-0 volume can still be proposed if no better-volume alternative covers that
   intent; flag it `low_volume_risk` rather than silently shipping it or silently dropping the intent.

### Mine the account's own drift before researching externally

Before running new external research on a dead ad group, check whether the same theme is already live and
serving elsewhere in the account: a misfiled keyword, a leftover from a removed ad group, or drift from a
Brand ad group. This is often the highest-value source in the whole research pass, because it's proof, not
an estimate: a live account once found an entire ad group's keywords sitting at zero volume, every one a
four-word over-qualified phrase, while the same underlying activity phrased as a two-word term was live
and serving the whole time in a different, unrelated ad group.

## Screening: five gates, run in order

Fail closed: if a check is uncertain, reject the keyword. Missing a keyword is always safer than letting a
bad one through.

**Screening order:** Screen 1 (single-word) -> Screen 2 (generic) -> Screen 3 (mission + wrong-entity) ->
Screen 4 (policy risk, flags rather than rejects) -> Screen 5 (volume selection + match-type gate). A
keyword failing 1, 2, or 3 is rejected outright.

### Screen 1: single-word check (R-KW-1)

A keyword with no space is single-word and rejected, with three exceptions: terms with a dash or period
("covid-19" passes), terms on the allowlist (charity, charities, donate, donation, ngo, ngos, nonprofit,
nonprofits, volunteer, volunteering, and approved medical conditions per Google's exception list), and the
org's own name.

### Screen 2: overly generic check (R-KW-2)

Keywords must show intent that connects to the org's mission. Reject terms that could apply to any
organization, show no action intent, or would trigger for people with no interest in the mission (Google's
own examples: "free videos," "e-books," "today's news"). "Free resources," "help," and "information" fail;
"emergency shelter near me" and "donate to animal shelter" pass because they carry specific,
mission-aligned intent.

### Screen 3: mission alignment and wrong-entity check

Ask whether a reasonable person searching this term could plausibly be looking for what the org offers.
This screen also carries the wrong-intent and wrong-entity check that a relevance score would otherwise
automate:

- **Commercial drift**: a broad seed in an elder-care or caregiving vertical, for example, reliably
  surfaces the paid professional home-care-agency vocabulary at very high volume: a seed like "senior
  companion" can return "companion care" at tens of thousands of searches a month, high competition, rich
  bid range, the commercial-drift tell. That volume belongs to a different buyer (someone shopping for
  paid home care), not the nonprofit's volunteer-visiting program. Reject regardless of volume; a much
  smaller, on-mission variant ("senior companion program," "senior companion services") is the real
  candidate.
- **Wrong entity**: broad-seed research reliably surfaces high-volume terms that are topically adjacent
  but belong to a different, real, specific organization: another nonprofit, a hospital system, a national
  franchise, a trade publication. These pass every other screen and still must be rejected, since
  proposing them risks brand confusion and near-certainly wastes spend on someone searching for the other
  entity. Cause-adjacent category seeds (a broad "[cause] charity" seed) surface real named organizations
  at a much higher rate than org-specific seeds do, because federations, foundations, and trade press
  share vocabulary with generic category terms; run this check especially rigorously on category-intent
  keywords (below). When a candidate's likely real-world referent is ambiguous but plausibly a specific
  large organization, reject rather than verify-by-omission.

### Screen 4: policy-topic risk (advisory, not a rejection)

Some keywords are mission-aligned and specific but still get rejected by Google's ad content policies at
build time. The most common trap for nonprofits is the health policy: clinical or medical terms trigger a
health-content restriction even in a non-medical context such as volunteer recruitment.

Flag before proposing: physiotherapy, physical therapy, chiropractor, chiropractic, psychologist,
psychiatry, therapy (clinical sense), medical, clinic, diagnosis, treatment of a named condition,
prescription, rehab (medical sense). Softer wellness terms usually pass: massage, acupuncture,
reflexology, osteopathy, sound healing, energy healing, yoga, wellness, holistic. Also flag:
politics/elections, sensitive events, tragedy/bereavement, firearms, or a named health condition.

Prefer a compliant rephrasing that keeps the intent ("chiropractor volunteer" becomes "holistic
volunteer"). If no clean rephrasing exists, propose the term anyway but mark it `policy_risk` so a
build-time rejection is expected, not a surprise.

### Screen 5: volume-based selection and the match-type gate

Screens 1-4 decide eligibility; they never check whether a term gets any traffic. When two or more
eligible candidates cover the same intent, run `discover_keywords` on the ad group's seeds and keep only
the **2-4 highest-volume candidates per distinct intent**, dropping the rest even if they individually
passed every earlier screen. If a candidate is the only phrasing covering a given intent and its volume is
0 or near-0 with no better alternative, it can still ship, marked `low_volume_risk`.

Match-type decision at this screen: broad match is the default on every non-brand ad group regardless of
the candidate's own volume (a broad keyword is a seed, not a target; see keyword-doctrine.md and
account-lifecycle.md Stage 0). Brand ad groups are the sole exception and stay all exact. Broad ships only
paired with a negative-keyword batch in the same change batch, sourced from the same `discover_keywords`
pull's rejected off-mission and commercial-drift ideas: a free byproduct of research already run. A
candidate with 0/no-data volume is not a valid broad seed; Google has nothing coherent to expand from.

A "no volume" reading from Keyword Planner is not proof a keyword won't serve, and a live "serving" status
is not proof it has volume; they are different signals. Use planner volume for pre-launch candidate
selection; use the account's own live serving status once a keyword is running, since that's Google's
authoritative real-time signal.

## Bucketing

Every keyword belongs in one of four buckets, which decides its ad group:

- **Branded**: the org's name, abbreviations, common misspellings. Highest CTR (often 15-30%, since
  searchers already know the org). Usually exact match: `[org name]`, `[org name misspelled]`, `"org name
  nonprofit"`.
- **Program/service**: what the org does, its programs, services, activities. Mid-funnel; match the
  landing page's language. Usually phrase match: `"emergency shelter near me"`, `"free tutoring for
  kids"`.
- **Need-based**: what the searcher needs, phrased from their perspective. Often the highest-empathy,
  highest-intent bucket: `"where to sleep tonight"`, `"help paying for groceries"`, `"donate to food
  bank"`.
- **Category-intent**: the category of organization a donor or volunteer is shopping in, not this org's
  specific program. Real for a narrow-mission org with an identifiable donor persona (an animal-welfare
  org's donor may also search "animal welfare organizations" or "wildlife charities" without naming this
  org specifically). Isolate these in their own ad group rather than folding them into an existing one,
  since they've never been paired with this org's ad copy before; check performance within 1-2 weeks
  rather than waiting for the normal cadence, and run the wrong-entity screen especially hard here.

### Match-type target mix per ad group

```
NON-BRAND ad group:
  2-4  BROAD seeds   the core intent, 2-3 words each - these carry the ad group
  2-4  phrase        specific, volume-verified variants
  2-4  exact         proven converters promoted from the search-terms report

BRAND ad group:
  ALL EXACT          org name + misspellings; no broad, no phrase
```

Exact-match keywords increasingly should come from search terms rather than research: when a broad seed
surfaces a converting query, promote it to exact. That's the intended lifecycle, not a one-time build
decision.

## Keyword volume targets

| Ad group situation | Target keyword count | Note |
|---|---|---|
| New ad group at setup | 8-15 | Check real volume before finalizing; don't pad with near-duplicate zero-volume phrasings just to hit a count. |
| Mature ad group (3+ months live) | 10-25 | Grown from search-terms mining. |
| Brand ad group | 5-10 | Low or zero volume is expected here, not a Screen 5 concern. |
| Genuinely narrow niche | as few as 2-4 | If every phrasing for a narrow theme comes back at or near zero, consolidate to the best 2-4 real-volume terms rather than forcing a count, or reconsider whether the theme should exist as its own ad group. |

Fewer than 5 keywords usually means the theme is too narrow or shouldn't be its own ad group, unless
volume data shows that's the genuine ceiling for real demand. More than 25 means the theme is too broad;
consider splitting.

## Maintaining the list

Never permanently delete a keyword; pause it (guardrails.md blocks delete operations entirely). Pause is
also the right move any time a keyword is being relocated rather than genuinely killed: a keyword found
live in the wrong ad group gets paused in place and re-added correctly elsewhere, not removed.

When the search-terms report surfaces a candidate: run the five screens, assign a bucket, assign to the
right ad group by theme, assign match type per the rules above, check for duplicates against the existing
list.

Before building an "Awareness" or broad-reach ad group for a narrow-mission org: run the same research and
screening as any other ad group. Broad "awareness" seeds for a narrow mission tend to resolve into generic
industry content unrelated to the actual org, or into general advocacy/political sentiment terms with real
volume but the wrong intent (informational or political searchers, not donors or volunteers), not a
genuine new audience. If nothing survives that isn't already covered elsewhere, don't build the ad group;
fold any genuinely safe volume into existing themed ad groups instead.
