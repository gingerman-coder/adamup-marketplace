# Architecture: account structure design

Turns an approved profile into Google Ads account structure: campaigns, ad groups, and geo-targeting.
Runs after `objective-ladder.md` decides what the account is for, and before `keyword-doctrine.md` and
`bidding.md` fill and configure what architecture builds. Everything here is created **PAUSED**; nothing
is enabled until content and a compliance check pass.

## Structural floors

These are compliance floors, not preferences:

- **R-STRUCT-2:** every campaign needs at least 2 ad groups. If a campaign naturally has only one theme
  (a single-name org's Brand campaign, say), create a second ad group for misspellings, abbreviations, or
  "org name + activity" variants.
- **R-STRUCT-3:** every ad group needs at least 2 RSAs. Architecture only has to confirm this is
  structurally possible; a theme too narrow to support two distinct ads is too narrow for an ad group.
- **R-STRUCT-4:** every campaign needs specific geo-targeting. Never "all countries."

Before designing anything new, read the live account. It is often not empty: a client, a prior agency, or
a past setup may have left campaigns behind. For every pre-existing campaign, record it, don't touch it,
and check whether its keyword themes overlap the campaigns about to be built. Two campaigns in one account
competing on the same keywords split budget and conversion data against each other (self-competition).
Flag any overlap before enabling anything new.

## Campaign split logic

Not every campaign applies to every org. Choose based on what the profile supports.

| Campaign | When to include | Typical intent | Min. landing pages needed |
|---|---|---|---|
| **Brand** | Always | People searching for the org by name | Homepage or About page |
| **Programs / Services** | Org has ≥1 distinct program with its own page | People searching for the type of help the org provides | One page per program area |
| **Donate** | A donation page exists | People searching to donate to the cause | Donation page with a thank-you confirmation |
| **Volunteer** | A volunteer page exists | People searching to volunteer | Volunteer page with a sign-up confirmation |
| **Awareness** | Mission is broad enough and keyword volume supports it | People searching about the issue the org addresses | Mission/impact page |

### Decision rules

1. **Start with 3-5 campaigns; keep the account under 8-10 forever.** The ceiling is about conversion
   data, not budget. Campaigns don't share learning with each other, and every campaign added splits an
   already-thin conversion signal into a thinner one; Smart Bidding needs a minimum volume per campaign to
   optimize at all. A grant account rarely has enough conversions to feed three campaigns well, let alone
   twelve. An account above 10 campaigns can usually be consolidated, and consolidating tends to improve
   performance because the surviving campaigns share more data.

2. **Segment at the ad-group level, not the campaign level.** Campaigns are where budget, geo-targeting,
   and language live; ad groups are where themes live. When tempted to add a campaign, ask whether it
   needs its own geography or its own budget fence. If not, it's an ad group.

3. **Brand is always included**, even for a small org. It protects name searches from competitors or
   irrelevant results, and Brand campaigns typically run 15-30% CTR, which helps the account-level 5%
   floor (see `guardrails.md`).

4. **Programs gets split by volume.** Two or three major programs fit one Programs campaign with one ad
   group per program. Five or more distinct programs may warrant splitting into two Programs campaigns
   (e.g. "Programs - Direct Services" and "Programs - Education") to keep each campaign focused.

5. **Donate and Volunteer are separate campaigns**, not ad groups inside Programs, because they have
   different intent, different landing pages, different conversion actions, and different bidding
   postures.

6. **Awareness is optional.** Include it only when the mission area has real search volume for
   informational queries (e.g. "what is food insecurity" for a food bank) and a page exists that answers
   them well. Awareness campaigns tend to run lower CTR; size them carefully against the 5% floor.

### Example

A local community clinic with three programs (urgent care, dental, mental health), a donation page with a
confirmation step, and a volunteer page but no current recruitment push:

```
Brand      - always
Programs   - 3 programs, each with its own page -> 1 campaign, 3 ad groups
Donate     - donation page + confirmation exists
Volunteer  - deferred (page exists but no active recruitment push yet)
Awareness  - deferred (mission is local; informational volume likely thin)

Result: 3 campaigns at launch. Volunteer and Awareness can be added later
via the "adding a campaign later" process below.
```

## Ad-group design

Each ad group is a tight cluster: one keyword theme, one landing page, ads written to that theme. The
tighter the alignment, the higher the Quality Score, the higher the CTR, the lower the cost per click.

1. **One theme per ad group.** An ad group called "General" is a red flag; each one should be nameable by
   its specific topic ("Emergency Dental Care," not "Services").
2. **5-20 keywords per ad group.** Fewer than 5 is too narrow to generate volume; more than 20 means the
   theme is too broad and should split.
3. **One primary landing page per ad group.** If two ad groups would share a landing page, they need
   clearly distinct keyword themes to justify the split.
4. **≥2 ad groups per campaign (R-STRUCT-2).**
5. **≥2 RSAs per ad group (R-STRUCT-3).** Architecture just has to confirm the theme supports two distinct
   ads; writing them is a separate step.

## Geo-targeting

Every campaign needs specific targeting (R-STRUCT-4). The org's actual footprint drives the decision.

| Org type | Geo-targeting | Rationale |
|---|---|---|
| Local service org (food bank, shelter, clinic) | Metro area or city + surrounding counties | People searching for local help; donors are also local |
| Regional org | State(s) or a defined region | Matches the service footprint |
| National org with national donors | The whole country | Donors are nationwide |
| Domestic org doing work abroad | The home country | Donors are at home; beneficiaries abroad don't search in the org's language for it |
| International org with global donors | Countries where donors are | Target where the money and volunteers come from |

**NOT** the whole country for a single-city org (generates impressions from people who will never engage,
tanking CTR). **NOT** "all countries" ever (a policy violation, R-STRUCT-4).

### Presence vs. presence-or-interest

Setting *where* to target is only half the decision. Google's location options, tucked behind an
"advanced" disclosure in campaign settings, govern a large share of available volume.

| Option | Who sees the ad | Google default |
|---|---|---|
| **Presence** | People in, or regularly in, the targeted locations | Yes |
| **Presence or interest** | The above, plus people actively searching about the targeted locations from outside them | No |

**Default to "presence or interest" for most accounts.** The people it adds are legitimate: someone
researching services for a relative elsewhere, someone planning a move, a donor searching about a region
they used to live in. On a grant account already starved of inventory by the dual auction (see
`auction-model.md`), discarding that traffic without being told is a large, invisible loss, and switching
is one of the highest-yield fixes available.

**Exception:** an org whose service requires physical presence and whose only conversion is an in-person
action gains nothing from a searcher three states away, and pays for it in CTR. Weigh this against the
account's primary rung (`objective-ladder.md`).

Whichever is chosen, record the decision and the reason. An unrecorded default is not a decision.

### Radius and exclusions

- **Radius targeting** usually beats a list of cities for a local org, and beats a pin-tight radius around
  one building. A radius around the metro casts a realistic catchment; a too-small radius is a documented
  cause of a near-dead account.
- **Location exclusions** are underused: target the whole country but exclude a region the org doesn't
  serve, or target a state but exclude a city another organization already covers.
- Both still satisfy R-STRUCT-4, which requires *specific* targeting, not *narrow* targeting. A radius
  around a metro is specific; "all countries" is not.

### Geo-targeting is a CTR lever

Overly broad targeting generates impressions from people who will never click, which inflates impressions
without clicks and drags down CTR. Tighter geo means more relevant impressions, means higher CTR. This
cuts against the volume advice above: tightening geo helps CTR and hurts volume; loosening helps volume
and risks CTR. **P1 wins** (see `guardrails.md`). Tighten when CTR sits at or below the 7% buffer; loosen
when CTR is healthy at 8%+ and the account is underspending. Never do both to the same campaign in the
same pass (`change-hygiene.md`).

## Seasonal and timely campaigns

Events, appeals, awareness days, and year-end giving need their own handling.

**Lead time: build 4 to 6 weeks before the event, minimum.** Not the week before. The campaign needs time
to clear the learning period, accumulate Quality Score, and let the search-terms report surface negatives
before the traffic that matters arrives. A campaign launched days before an event spends its whole life
learning and never performs.

```
6 weeks out:  build, keywords, ads, landing page confirmed. Launch PAUSED.
4 weeks out:  enable. Learning period runs. Do not touch it.
2 weeks out:  first search-terms review, negatives added.
Event week:   the campaign is mature. This is when it earns its keep.
After:        pause, don't delete. Next year's version starts from it
              with its history intact.
```

**Reuse rather than rebuild.** A paused seasonal campaign keeps its Quality Score history and negative
list; re-enabling last year's version beats building a new one and starts warm.

**Seasonality bid adjustments** exist in Smart Bidding for short, predictable conversion-rate spikes (a
giving day, a matched-appeal window). Use them only for events under about 7 days where conversion rate is
genuinely expected to change, not as a general "more traffic" lever. Record any adjustment with its
window.

**Record the calendar early.** Annual events, awareness months, appeal windows, and fiscal year-end should
be known up front so the 6-week clock can be set rather than discovered late.

## Campaign types

Search is the backbone. Two additional surfaces exist and are gated by account maturity
(`account-lifecycle.md`, `recommendations-catalog.md`):

| Type | Role | Gate |
|---|---|---|
| **Search** | The backbone. Carries the structural floors (R-STRUCT-2, R-STRUCT-3) and the CTR that P1-A measures. Every account has at least one. | None; the default |
| **Search + AI Max** | The same Search campaigns with broadened, conversion-aware matching, and AI Overview eligibility | Gated separately per component |
| **Performance Max** | Keyword-less. On a grant, reaches Search and Maps only. Spends more easily than Search; converts at a lower rate. The only route to Maps placement. | Maturity-staged; never in the initial build |

**Never design a PMax campaign in the initial build.** A new account has no conversion history, and PMax
without conversion history produces junk traffic. It's a later decision made against a live account with
clean conversion data.

**PMax does not count toward the structural floors.** R-STRUCT-2 and R-STRUCT-3 are Search-campaign
concepts; an account cannot meet its structural obligations with PMax alone.

## Structural floor pre-check

Before finalizing a design, verify:

```
Every campaign has >= 2 ad groups planned?         NO -> flag which campaign and how to split
Every ad group will get >= 2 RSAs?                 NO -> flag; a theme too narrow for 2 RSAs is too narrow for an ad group
Account will have >= 2 sitelink assets possible?   NO -> stop; not enough confirmed landing pages
Geo-targeting is set for every campaign?           NO -> stop; this is a compliance violation (R-STRUCT-4)
```

If any check fails, don't finalize the design; report what's missing and what's needed to fix it.

## Adding a campaign later

When the org adds a program, launches a volunteer push, or otherwise needs a new campaign against an
existing live account:

1. Review the current structure: what campaigns exist, their ad groups, their geo-targeting.
2. Design the new campaign under the same rules above: purpose, ≥2 ad groups, a landing page per ad group,
   geo-targeting from the existing footprint unless the new program has different geography.
3. Run the structural pre-check on the new campaign only.
4. Record it in the account profile as a new section; don't modify existing campaign sections.
5. Create the new campaign **PAUSED**. It goes through keyword and ad content and the pre-launch
   compliance gate before enabling.
6. Don't disturb existing campaigns. A new campaign addition must not change budgets, keywords, or ads
   elsewhere. If budget reallocation is warranted, that's `bidding.md`'s job on a later pass.

After architecture, the next steps are conversion tracking (`conversion-ladder.md`), then bidding strategy
(`bidding.md`), then keyword and ad content (`keyword-doctrine.md`).
