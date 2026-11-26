# Low impressions: the triage playbook

The ordered diagnostic for the most common problem in Ad Grants management: the account is live,
compliant, and not serving. Run this whenever impressions, clicks, or spend are below expectation.

This replaces ad-hoc guessing with a fixed order. The order matters: every stage rules out a class of
cause, and running them out of order produces confident wrong answers. Stage 5, keywords, is where most
published advice starts, and by then four cheaper explanations should already be eliminated.

## When to run

Trigger this from `performance.md` when any of:

- Account spend utilization below 30%.
- Any enabled campaign with fewer than 100 impressions in the last 7 days.
- Any enabled campaign with zero clicks over 30 days (the dormant-campaign check).
- Account impressions down more than 40% versus the same month last year.
- You are asking why the account isn't spending.

**Do not run this while the emergency brake is active** (`compliance.md`). A braked account is deliberately
shedding impressions; raising impressions during compliance surgery works against the CTR floor. Finish the
surgery, release the brake, then diagnose spend.

## The stages

Run in order. Stop at the first stage that explains the gap, fix it, and re-measure before continuing. Do
not batch fixes from multiple stages into one pass: you will not learn which one worked, and you will spend
the one-structural-change-per-campaign-per-pass budget (`guardrails.md`) without a clean signal.

### Stage 1: is it eligible to serve at all?

Cheapest checks, and they explain more zero-impression cases than anything else. An account can look
perfectly configured and be structurally unable to serve.

```
CHECK: Account status
  Suspended or disabled -> stop. This is a disablement emergency. Nothing
  else matters until it's resolved.

CHECK: Campaign, ad group, and ad status, read separately
  A campaign can be ENABLED while every ad group or ad beneath it is PAUSED.
  Read all three levels; do not infer descendants from the parent. This is
  the same read-back the launch-completeness check requires
  (compliance.md); it has cost a live account a full day of zero impressions.

CHECK: Ad approval status
  Disapproved -> the ad cannot serve. Fix or remove it.
  "Eligible (limited)" -> serving is restricted. Read the limitation reason;
  it is usually a policy restriction on the vertical, not something you control.

CHECK: Keyword serving status
  RARELY_SERVED on most keywords -> the keyword set is too narrow to enter
  auctions. Go to Stage 5.

CHECK: Policy issues
  Any account-level policy flag -> resolve before diagnosing anything else.

CHECK: Landing pages resolve, over HTTPS, without redirect chains
  A 404 or broken final URL suppresses the ad (R-WEB-1).
```

**If Stage 1 finds nothing and impressions are still near zero, that is itself informative:** the account is
eligible and still not entering auctions, which points at targeting (Stage 4) or a market ceiling (Stage 9).

### Stage 2: is the conversion signal poisoned?

Runs early because it is invisible in impression metrics and silently degrades everything after it. Smart
Bidding steers on the conversion signal, and the failure mode is an **uncontrolled** signal: several
overlapping engagement events, none of them chosen, all marked primary, at least one counting many-per-click.
The Conversions column becomes unreadable and the algorithm chases whichever fires hardest.

**This stage is about signal hygiene, not purity.** One deliberate page-view action marked primary is the
standing default (`conversion-ladder.md`) and is correct even at a near-100% conversion rate. Do not flag it.

```
CHECK: Every conversion action's primary status, individually
  Run an UNFILTERED conversion-action pull; do not trust your records to be complete.

  HEALTHY:
    - Exactly ONE primary action.
    - It is the page-view action, counted once per click, low value. A
      ~100% conversion rate on it is EXPECTED, not a defect.
    - OR it is a real action with 15-30+ conversions/month.

  POISONED:
    - More than one primary action.
    - Many-per-click counting on any passive/engagement signal.
    - An analytics platform's generic engagement event left primary by default.
    - A page-view action valued high enough to outbid the real actions.
    - An offline-only conversion type with no offline-import pipeline: records nothing.

CHECK: Is there a meaningful-conversion basis at all?
  Zero meaningful conversions this month is a COMPLIANCE finding, not an
  impressions finding. Route to compliance.md immediately; it does not
  explain low impressions.
```

**Fix:** collapse to exactly one primary action, demote the rest, cap counting at one-per-click, then expect
a re-learning period. This gets worse before it gets better: removing a padded conversion source will make
the Conversions column drop sharply. That drop is the correction, not a regression; record it so the next
pass doesn't read it as damage.

**Do not "fix" low spend by adding a second weak conversion action.** If the account already has clean
conversion-based bidding running, another proxy adds nothing and the constraint is downstream: keep going
to Stage 3. The page-view conversion is how an account gets off Maximize Clicks; it is not a lever to pull
twice.

### Stage 3: is the bidding strategy the constraint?

```
CHECK: Any $2.00-capped bidding strategy anywhere?
  The capped set is Maximize Clicks, Target Impression Share, Manual CPC,
  Enhanced CPC. Only conversion-based strategies are exempt. In a dual
  auction where grant ads already rank last, a $2 cap means near-total
  non-serving on anything contested. Fix immediately (bidding.md).

CHECK: Is a target CPA set?
  A target CPA the account cannot hit causes the algorithm to decline
  auctions rather than overspend it. Presents exactly as "we have budget and
  we are not spending it." While spend utilization is low, a target CPA is a
  liability, not a guardrail: remove it, run bare Maximize Conversions, re-measure.

CHECK: Is the campaign stuck on Maximize Clicks past its bootstrap window?
  See the bootstrap review in bidding.md; escalate via compliance.md R-BID-1.

CHECK: Was the strategy changed in the last 14 days?
  It is re-learning. Do not diagnose yet.
```

### Stage 4: is targeting fencing the account in?

Two settings suppress far more volume than their prominence in the interface suggests.

```
CHECK: Location targeting method
  Default is "Presence": people in, or regularly in, the targeted locations.
  The alternative, "Presence or interest," also reaches people actively
  searching about the area from outside it.

  For a local nonprofit, "Presence or interest" is usually correct and is
  one of the highest-yield low-impression fixes available. A person planning
  a move, researching services for a relative in another city, or visiting
  the area is a legitimate audience that "Presence" silently discards.
  -> Switch it, monitor CTR and search terms weekly for 3 weeks. Revert if
     CTR degrades or geographically irrelevant search terms appear.

CHECK: Geographic radius
  A tight radius around a single address is the most common cause of a
  near-dead local campaign.
  -> Widen to the realistic service or donor catchment. A radius around a
     city or region generally beats a pin-tight radius around one building.
  -> Still specific enough to satisfy R-STRUCT-4; never "all countries."

CHECK: Location exclusions
  Inherited or stale exclusions that no longer reflect the org's footprint.

CHECK: Ad schedule
  A campaign restricted to business hours discards most of its available
  inventory. Unless there's a real reason (a phone line staffed only 9-to-5
  that is the only conversion path), run all hours.

CHECK: Language targeting
  Overly narrow language settings suppress volume; match the org's actual audience.

CHECK: Audience targeting mode
  An audience segment applied in TARGETING mode (rather than OBSERVATION)
  restricts the campaign to only that audience. Easy to set by accident, and
  it silently collapses reach. Keep audiences in observation mode unless
  deliberately chosen (see the audience gate doc).

CHECK: Demographic exclusions
  Excluded age brackets, genders, or income tiers, or the "unknown" bucket.
  The "unknown" bucket is large; excluding it is a common and costly accident.

CHECK: Bid adjustments set to -100%
  A -100% adjustment on a device, location, or audience is a complete block,
  not a reduction. Inherited or accidental -100% adjustments are a documented
  cause of a dead campaign and are nearly invisible in the interface.
  -> Audit every bid adjustment on every campaign; any -100% must be
     justified or removed.

CHECK: Device targeting
  Mobile excluded or heavily down-adjusted on an audience that is
  predominantly mobile.
```

**Exception, do not skip:** "Presence or interest" is wrong for an org whose service genuinely requires
physical presence and whose only conversion is an in-person action, because it buys clicks from people who
can never convert. Weigh it against the org's stated objective before flipping it.

### Stage 5: is the keyword surface too small, or pointed at the wrong demand?

Now, and only now, look at keywords. This is where most published advice begins.

**5a runs before 5b. Order matters more here than anywhere else in this playbook.**

```
CHECK 5a (FIRST): supply-side vs. demand-side composition
  Classify every keyword (see keyword-doctrine.md):
    supply-side = what the org IS ("animal welfare charity", "food bank
      nonprofit", "literacy organization")
    demand-side = what the org DOES ("adopt a rescue dog near me", "free
      groceries this week", "help my child read better")

  If supply-side share is above ~40% of keywords:
    -> STOP. This is a REBUILD, not a match-type problem. Category and
       identity terms are structurally near-empty: a narrow identity phrase
       can run in the low hundreds of monthly searches nationally, before
       geo-targeting and the dual auction take their cuts.
    -> Loosening match types here just finds more ways to say a thing nobody
       searches. Run a demand-side research pass instead, and do NOT
       proceed to 5b first.

CHECK 5b: keyword count per ad group
  Under 10 -> too thin. Target 10 to 15 quality keywords per ad group.
  Quality beats quantity: 10 relevant keywords outperform 50 weak ones, and
  weak ones import CTR risk.

CHECK 5c: match-type distribution
  All-exact or all-phrase with low volume -> the surface is over-qualified.
  Audits of managed grant accounts have found 50-80%+ of keywords
  RARELY_SERVED, mostly over-qualified phrase-match terms stacking audience,
  action, location, and cause into a single phrase.

  -> BROAD IS THE DEFAULT on every non-brand ad group (keyword-doctrine.md).
     If a non-brand ad group has no broad seeds, that is the finding. Add
     2-4, with the paired negative batch, in the same pass.
     BRAND ad groups stay exact; do not "fix" them by broadening.
  -> A broad keyword is a SEED, not a target. Do not require a seed to have
     volume before allowing broad match; that inverts cause and effect.

CHECK 5d: real search volume behind phrase/exact keywords
  Run keyword research on the ad-group theme. Keywords with genuinely zero
  volume cannot serve as phrase or exact.
  -> Replace with the higher-volume core terms covering the same intent.
     (Does not apply to broad seeds.)

CHECK: over-blocking by negatives
  Pull the negative-keyword list. A broad negative added months ago to fix a
  CTR problem can be blocking a whole intent cluster now. Cross-check every
  account-level negative against the current keyword list for collisions.
  Easy to forget, and it silently caps an account.
```

### Stage 6: is Quality Score suppressing rank inside the residual auction?

Within the grant auction, ad rank still decides placement, and Quality Score is the half of ad rank you
control. This matters more here than in a paid account, because there is no option to simply outbid the
problem.

```
CHECK: QS targets, not just the floor
  1-2  -> must be paused (R-KW-3). Non-negotiable.
  3-4  -> review and fix. Suppressing rank materially.
  5-6  -> acceptable, improvable.
  7+   -> the working target. Aim here, not at "above the floor."

CHECK: the three QS components, per keyword
  Pull Quality Score, Landing Page Experience, and Ad Relevance as separate
  columns; the composite number alone does not tell you what to fix.

  Expected CTR below average -> ad copy doesn't mirror the keyword.
  Ad relevance below average -> the ad group theme is too loose. Split it.
  Landing page below average -> the final URL doesn't answer the query. A
    website finding, not an ads fix; target 50+/100 on a page-speed check as a floor.

CHECK: the mirror test, per ad group
  Does the keyword appear in the ad headlines?
  Does the ad's promise appear on the landing page?
  Does the landing page serve the intent behind the keyword?
  Any "no" is a QS defect with a known owner: ad copy for the first two, a
  website flag for the third.

CHECK: Ad Strength
  Below "Good" -> fewer impressions and higher cost per click. Diversify headlines.
```

### Stage 7: is the account fragmented?

Counterintuitive, and frequently the answer for accounts that have been managed for a while.

```
CHECK: campaign count
  More than 8-10 campaigns on a grant account is almost always too many.
  Why it suppresses serving: campaigns do not share conversion learning.
  Splitting a thin conversion signal across many campaigns leaves every one
  of them below the volume Smart Bidding needs, so all of them optimize
  badly. Grant accounts have thin signal to begin with; fragmentation is expensive.
  -> Consolidate campaigns that share a goal and a geography into one
     campaign with more ad groups. Ad groups are where segmentation belongs;
     campaigns are where budget and targeting live. Structural, so it needs sign-off.

CHECK: split budgets
  Any campaign budgeted below $329/day without a documented reason.
  Splitting the daily allowance across campaigns throttles them for no
  benefit (see auction-model.md).

CHECK: self-competition
  Two campaigns bidding on overlapping keyword sets split their own data and
  suppress each other.
```

### Stage 8: have you opened the newer surfaces?

By this stage the classic Search campaign is correctly configured and still not finding inventory. That is
the expected outcome of the dual auction, not a failure of the work. The remaining lever is to compete for
inventory the classic Search slot does not reach.

```
CHECK: AI Max for Search enabled?
  Broadens matching beyond the keyword list and makes ads eligible for
  AI-generated answer-box placement, where a chunk of the "lost" impressions
  actually went. Gated by account maturity.

CHECK: a Performance Max campaign running?
  In Ad Grants, PMax reaches Search and Maps only. It consistently spends
  more easily than Search campaigns. For an org that wants Google Maps
  presence, PMax plus a location asset is the only route. Gated by account maturity.

CHECK: location asset attached, for any org with a physical presence?
  Required for Maps placement.

CHECK: advertiser verification complete, business name and logo assets set?
  Unlocks richer ad formats and more ad real estate.

CHECK: a Dynamic Search Ads ad group added?
  DSA targets the website's own content instead of a keyword list, letting
  the platform discover query-and-landing-page combinations you would not
  have guessed. Strong option for an account whose keyword research has plateaued.
  -> HARD PRECONDITION: the site must have substantial, current, on-mission
     content. DSA on a thin or stale site sends traffic to bad pages and
     makes things worse; verify with an actual content read, the same bar as
     any final-URL expansion.
  -> Structure as a SECONDARY ad group alongside the keyword-targeted ones,
     not a replacement. Pair with the account negative list at creation.
  -> Monitor search terms weekly for 3-4 weeks, same as any matching-surface
     expansion (search-terms.md).
  -> Caution: DSA and PMax in grant accounts can spike and then die. Treat as
     a monitored pilot, not a fix-and-forget.

CHECK: reviving a previously-working campaign that flatlined?
  Where a campaign performed and then stopped, setting a target CPA
  SUBSTANTIALLY HIGHER than its historical average cost per conversion can
  restart serving, then be lowered gradually over subsequent passes.
  -> This is the ONE case where a target CPA is a serving tool rather than a
     suppressant, a deliberate exception to "no target CPA below 60%
     utilization." Applies only to a campaign with real conversion history
     that has stalled, never to a cold or new campaign. Record the exception
     and the step-down schedule.
```

**Channel note, outside the grant.** If Stages 1 through 8 are clean and the vertical is simply too
contested, two options exist beyond this account: a paid Google Ads account for the hard keywords (an org
may hold one Ad Grant plus one paid account), and Microsoft Ads for Social Impact, which offers a
comparable nonprofit credit on a less contested auction. Both are legitimate to recommend once this
playbook is exhausted, rather than continuing to optimize against a ceiling.

Neither newer surface is a reflex for low spend: an unprepared PMax pilot burns grant budget on junk
traffic, which is worse than underspending. Each carries its own preconditions and rollback criteria.

### Stage 9: is this simply the market ceiling?

The honest ending. Some accounts are correctly built and cannot spend the grant.

```
CONCLUDE market ceiling when ALL of:
  - Stages 1 through 8 are clean or already applied.
  - Lost impression share to rank is high and lost to budget is near zero.
  - Keywords are mission-aligned with real, verified search volume.
  - CTR is healthy (8%+): the traffic you do get is well matched.
  - The org is niche, hyper-local, or in a commercially contested vertical.
```

Report it plainly and stop. Do not manufacture volume by loosening keywords into generic terms: that trades
a spend gain for CTR risk (R-KW-2 exposure), exactly the trade the priority order forbids.

**Reporting language:**

```
This account is at {x}% spend utilization. Stages 1 through 8 are clean.
Lost impression share to rank is {y}%, to budget {z}%.
Account CTR is {c}%, well above the 5% floor.

This account is well-optimized within its market. The remaining gap reflects
available residual-auction inventory for this geography and mission, not a
configuration problem. Further spend would require either a broader service
geography or looser keywords, and looser keywords would put the CTR floor at risk.

Recommend: hold current structure, revisit if the org expands its footprint.
```

An account at the market ceiling is a **success** and should stop consuming diagnostic attention; deprioritize
it rather than re-diagnosing it every pass. Record the ceiling finding, with the date and the evidence, so
the next pass reads the conclusion instead of re-deriving it.

## Stage-to-fix map

| Stage | What it points to |
|---|---|
| 1 Eligibility | `compliance.md`; ad-copy fixes for disapproved ads |
| 2 Conversion signal | `conversion-ladder.md` |
| 3 Bidding | `bidding.md` |
| 4 Targeting | `architecture.md` |
| 5 Keywords | `keyword-doctrine.md`, `search-terms.md` |
| 6 Quality Score | Ad copy and landing-page fixes |
| 7 Fragmentation | `architecture.md`, `bidding.md` |
| 8 New surfaces | `pmax-gate.md`, `ai-max-gate.md` |
| 9 Market ceiling | No fix. Report and deprioritize. |

Record the stage reached and the diagnosis every time this playbook runs. The stage history across passes
is the most useful signal you can keep about an underspending account: one that reaches Stage 9 three
passes running should not be re-triaged from Stage 1 each time.
