# Bidding and budget: Smart Bidding strategy, targets, and spend

Chooses the Smart Bidding strategy per campaign and sets the daily budget. **Every campaign launches on
Maximize Conversions**, because every other strategy is capped at $2.00 CPC. See `auction-model.md` for
why the cap matters so much on a grant account, and `guardrails.md` for the compliance floors this file
has to satisfy (R-BID-1: Smart Bidding required, no manual CPC).

## Dependency: conversions first

Smart Bidding strategies (Maximize Conversions, Maximize Conversion Value, tCPA, tROAS) optimize toward
conversion actions. Don't set a conversion-based strategy on a campaign until at least one conversion
action exists, live or planned. In practice this is never a real blocker: `conversion-ladder.md` installs
a page-view conversion as the default primary on every account specifically so this precondition is met
the same day, on a campaign landing page if nothing deeper is available. If conversion tracking hasn't
been set up yet, do that first.

## Strategy selection

### The allowed strategies (R-BID-1)

For accounts created on or after April 22, 2019, every campaign must use one of these:

| Strategy | What it optimizes | When to use | Requires |
|---|---|---|---|
| **Maximize Conversions** | Most conversions within the daily budget | Default for most campaigns; best when conversions are roughly equal value | >= 1 conversion action |
| **Maximize Conversion Value** | Most total conversion value within the daily budget | Conversions have meaningful value differences (e.g. $10 vs $500 donations) | >= 1 conversion action with value tracking |
| **Target CPA (tCPA)** | Conversions at or below a target cost per acquisition | You know what a conversion should cost and want efficiency over volume | ~15-30 conversions in the last 30 days for reliable optimization |
| **Target ROAS** | Conversion value at or above a target return | Rare for nonprofits; only with solid revenue attribution and a specific return target | Strong conversion value data |

### The $2.00 cap: exempt vs. capped

The Ad Grants program imposes a **$2.00 maximum CPC bid**. The exemption is narrow: it applies only to
**conversion-based** Smart Bidding.

| Strategy | Subject to the $2.00 cap? |
|---|---|
| Maximize Conversions | No (exempt) |
| Maximize Conversion Value | No (exempt) |
| Target CPA | No (exempt) |
| Target ROAS | No (exempt) |
| **Maximize Clicks** | **Yes. Capped at $2.00.** |
| **Target Impression Share** | **Yes. Capped at $2.00.** |
| Manual CPC / Enhanced CPC | Yes, and separately not compliant (R-BID-1) |

The generalization: any strategy that doesn't optimize toward *conversions* is capped. Clicks, impression
share, and manual bids are all click-or-visibility objectives, none of which qualify. The test: does the
strategy's name contain "conversion" or a conversion metric?

Combined with the dual auction (`auction-model.md`), a $2.00 ceiling on top of a structurally last-place
auction position is what turns "low impression share" into "no impressions." A campaign found on a capped
strategy is a live defect, not a configuration preference, and should be fixed on the pass that finds it.

### Launch every campaign on Maximize Conversions, with no target CPA

Not after a bootstrap; from day one, on every campaign type (Brand included). Smart Bidding needs 15 to 30
conversions to optimize well, and a campaign on Maximize Conversions with thin data optimizes imperfectly.
But a campaign on Maximize Clicks is bid-capped and frequently can't enter auctions at all. Imperfect
optimization beats structural non-serving, and the thin-data problem cures itself as conversions
accumulate; the bid cap never does.

The real precondition is conversion **tracking**, not conversion **volume**. A page-view conversion also
gives denser data than a rare real action: Smart Bidding wants 15-30 conversions a month, a real action on
a small nonprofit account yields a handful at best, a landing-page-tier view yields one per click. Dense
data lets the algorithm bid freely against the budget; sparse data makes it bid timidly. For an
underspending account, dense wins.

### When Maximize Clicks is still permitted

Almost never, because the way out is cheap. If no real conversion action can fire yet, the fix is not to
sit on Maximize Clicks: install the page-view conversion (`conversion-ladder.md`), pointed at a page one
step below the ad's landing page if one is obvious, or the campaign landing page itself if not; count it
ONE per click; give it a low value; mark it primary; switch to Maximize Conversions immediately. A campaign
landing page is an acceptable target for this (the old "near-100% conversion rate reads as spam" claim is
unsourced folklore, not a rule): prefer a deeper page when one is free, but never delay the bidding switch
for it.

The practical consequence: there's no account where the page-view conversion can't be deployed, so
Maximize Clicks is permitted only where there is no tag access at all and no ability to create any
conversion action. That's a client-access problem to escalate as blocking, not a bidding decision.

Under this exception:

```
- Flag it as a SERIOUS limitation, not a routine ramp. The campaign is
  bid-capped at $2.00 and will underperform accordingly.
- Review at 30 days, not 60.
- The fix is always "make a real conversion fire," never "wait longer."
- The broad-match default in keyword-doctrine.md should not also be applied
  while a campaign sits in this state: a $2-capped campaign should not also
  be widening its match surface.
```

Never leave a campaign on Maximize Clicks because it's "still learning." There's nothing to learn on a
capped strategy that a conversion strategy wouldn't learn better.

### Cold-start caveat: Maximize Conversions can fail to serve at all

Beyond the usual case for Maximize Conversions, there's a second failure mode: **Maximize Conversions on
an account with a long zero-conversion history can bid effectively $0 and serve nothing, indefinitely.**
With no conversions ever recorded, the algorithm estimates ~0 conversion probability, so it never bids
enough to enter even uncontested auctions. Every status reads green (eligible, serving, funded, approved)
while impressions sit at zero for months.

This produces two opposite symptoms depending on inventory:

- **Wide inventory (national, broad targeting):** Maximize Conversions with no signal still serves, but
  bids blind and overpays with nothing to optimize toward. Spends, measures nothing.
- **Thin inventory (local, narrow targeting):** Maximize Conversions with no signal serves nothing at all.
  It can't get the first click, so it never gets the first conversion, so it never starts bidding: a
  cold-start deadlock.

**The tell:** a campaign on Maximize Conversions with 0 lifetime conversions and 0 impressions over 30+
days, everything else eligible. Don't diagnose this as geo, keywords, or budget if those check clean; it's
the bid strategy failing to bootstrap.

**The wide-inventory symptom hides, because the account looks like it's working.** A real anonymized
example, trailing 30 days, three campaigns all on Maximize Conversions with zero lifetime conversions:

| Campaign | Impressions | Clicks | Spend | Conversions | CTR | Avg CPC |
|---|---|---|---|---|---|---|
| A | 3,163 | 246 | $2,823 | 0 | 7.78% | $11.48 |
| B | 2,858 | 225 | $2,380 | 0 | 7.87% | $10.58 |
| C | 197 | 7 | $98 | 0 | 3.55% | $13.95 |
| **Total** | **6,218** | **478** | **$5,301** | **0** | 7.8% | **$11.09** |

Healthy CTR, roughly half the daily allowance spent, three green campaigns, and a CPC 4-5x grant-normal,
because Maximize Conversions with no conversion model has no basis to decline an expensive auction. Read
that as a **volume loss**, not a cost problem: the same $5,301 at a grant-normal $2-3 CPC would have bought
roughly 1,800-2,600 clicks instead of 478. A dead conversion signal is one of the most expensive volume
leaks available, and it presents as a healthy account.

```
STANDING CHECK, every pass, on every campaign on a conversion strategy:

  conversions == 0 over trailing 30 days AND impressions > 0
    -> BLIND BIDDING. The campaign is on a conversion strategy with no
       conversion model. Don't read its CPC, CPA, or conversion rate; none
       of them mean anything. Fix the signal before touching keywords,
       budget, or geo. This outranks every other optimization item, because
       every optimization is measured against a signal that doesn't exist.
```

**The fix is a deliberate, temporary Maximize Clicks bootstrap**, even though a fireable tag exists: Max
Clicks ignores conversion probability and bids to the $2 cap to win clicks, which breaks the deadlock and
produces the first page-view conversions. Switch back to Maximize Conversions once conversions accumulate.
This is the one case where Maximize Clicks is correct on an account with working conversion tracking; it's
a diagnostic and an on-ramp, not a destination, and it gets flagged exactly like the exception route above.

**API note:** switching a campaign's bidding strategy *to* Maximize Clicks via a generic campaign-update
call can silently no-op if the request sets `bidding_strategy=TARGET_SPEND` without populating the
`target_spend` oneof (some tooling returns SUCCESS anyway). The reliable path is the Google Ads REST API
directly, with `updateMask=targetSpend.cpcBidCeilingMicros` and
`targetSpend.cpcBidCeilingMicros=2000000` (a bare `targetSpend` mask fails with `FIELD_HAS_SUBFIELDS`).
Switching *to* Maximize Conversions doesn't have this problem.

### What is never allowed

- **Manual CPC**: not allowed for post-2019 accounts, and subjects the account to the legacy $2.00 cap.
- **Enhanced CPC**: a semi-automated variant of Manual CPC; also not compliant.
- **No bidding strategy set**: defaults to Manual CPC, which violates R-BID-1.

A campaign found on Manual CPC or Enhanced CPC is a compliance violation to fix immediately.

## Per-campaign decision logic

| Campaign type | Recommendation | Why |
|---|---|---|
| **Brand** | Maximize Conversions from launch | Low volume but high intent, typically 15-30% CTR. Brand terms are cheap because nobody else bids on them, so a $2 cap is *usually* survivable here, but there's no upside to accepting it when Maximize Conversions is available. Note that even uncontested brand terms return low impression share on a grant account, because the dual auction applies to brand queries too. |
| **Programs / Services** | Maximize Conversions from launch | Mid-funnel service queries often carry real commercial competition; these are the campaigns most damaged by the $2 cap. Never launch on Maximize Clicks. |
| **Donate** | Maximize Conversions, or Maximize Conversion Value if donation amounts are tracked as variable values | Donation-intent queries are among the most commercially contested in the account, so a $2 cap here is close to a guarantee of non-serving. Run Maximize Conversions on the page-view primary regardless of whether the actual donation is tracked; the primary conversion fires on essentially every click, so the campaign is never bid-capped for a tracking reason. If the donation itself isn't tracked, that's a measurement gap to fix in parallel (a processor-side tag or an onclick event), not a bidding gap. |
| **Awareness** | Maximize Conversions from launch | Informational queries are exactly where uncontested inventory exists, so a $2 cap here forfeits the grant's best territory. Point Awareness at the primary rung's conversion (`objective-ladder.md`), usually a list-building action. Awareness campaigns are also the most likely to drag account CTR below the 5% floor; monitor weekly. |
| **Volunteer** | Maximize Conversions from launch | Sign-ups are a clear conversion action and usually the cleanest signal in the account. |

**Target Impression Share is not a Brand alternative.** It looks appealing for a campaign whose real goal
is visibility, but it's capped at $2.00 for the same reason Maximize Clicks is: it optimizes toward
visibility, not conversions, so it falls outside the exemption. Observing another grant account run its
highest-volume Brand campaign on Target Impression Share is evidence of an uncaught defect in that account,
not a technique to copy.

**No Brand exception on the 30-day review either.** Low brand volume used to justify leaving Brand on
Maximize Clicks indefinitely (it would never hit 15 conversions). That just preserves the cap for no
benefit; switch Brand to Maximize Conversions like everything else and accept loose optimization at low
volume.

## Bootstrap path (exception route only)

Applies only under the narrow no-fireable-conversion exception above. The normal path has no bootstrap.

1. Launch on Maximize Clicks, knowing it's bid-capped at $2.00. Record this as a serious limitation.
2. Work the real problem, which is tracking, not time. The exit condition is "a real conversion action
   fires," not "enough data accumulated."
3. Switch to Maximize Conversions as soon as any real conversion action is live and recording. Don't wait
   for 15-30 conversions; waiting keeps the campaign under the cap, which costs more than thin-data
   optimization does.
4. Record the switch and the trigger that caused it.

Record, per bootstrapped campaign: the reason no conversion action fires yet, what's blocking it, when the
bootstrap started, a 30-day review date, and the trigger for switching (any real conversion recording, not
a count). This also determines whether broad match is permitted on the campaign's keywords: broad stays
off while a campaign is on this bootstrap (`keyword-doctrine.md`).

### 30-day review

If a campaign is still on Maximize Clicks after 30 days:

```
Is ANY real conversion action live and recording in this account?

  YES -> switch to Maximize Conversions now, regardless of conversion count.
         Don't wait for 15-30 conversions in 30 days; thin-data optimization
         beats a $2.00 cap.

  NO  -> this is the blocking problem, and it's a dependency outside ad
         management, not a bidding decision. What's missing (confirmation
         page, processor tag, onclick event)? Who has to fix it? What's the
         precise ask? Re-escalate every pass until resolved.
```

### Optional target CPA overlay on Maximize Conversions

Once a campaign is on Maximize Conversions, an *optional* target CPA can be layered on top. This differs
from the standalone Target CPA strategy: it doesn't require the 15-30 conversions/30 days threshold,
because Maximize Conversions is still the base algorithm and the target is a soft cost guardrail on it,
available from day one.

**Hard precondition:** only set the overlay once conversion actions have passed anti-pattern checks (no
`MANY_PER_CLICK` passive/engagement action may be primary; see `conversion-ladder.md`). A target CPA set
against an inflated conversion count isn't a guardrail. A reviewed comparison account set a uniform $100
target CPA across every campaign, but because roughly 95% of its counted "conversions" were a generic
page-engagement event, its real cost per meaningful conversion ran about $202, double the nominal target,
with no way for the algorithm or a dashboard glance to detect the gap.

## Target CPA discipline

**Hard rule: no target CPA while spend utilization is below 60%.** Run bare Maximize Conversions. When the
algorithm predicts a conversion will cost more than the target, it declines the auction, and on a grant
account already starved of inventory by the dual auction, declining auctions is the last thing wanted.
This presents to a client exactly as "we have budget and we are not spending it."

There's a real disagreement in the field: some practitioners pair Maximize Conversions with a target CPA
inside a portfolio bid strategy to help bypass bid constraints; others say never set a target CPA in a
grant account because it caps the bids Google is willing to place, undermining the whole reason Smart
Bidding is mandated. Resolve it by utilization: below 60%, the suppression risk outweighs any cost-control
benefit, and cost control isn't the constraint anyway. Above 60%, a target CPA becomes a legitimate
efficiency tool. The anti-pattern precondition above still applies regardless of utilization: never set a
target CPA against a conversion count padded with passive actions.

**Portfolio bidding strategies** (one strategy shared across several campaigns) can pool a thin conversion
signal across campaigns that would each fall below the learning threshold alone. Treat setting one as a
structural change: one per pass, with the same freeze that follows any bidding-strategy change
(`change-hygiene.md`).

## Daily budget setting

### Every campaign gets the full daily allowance

**Default every campaign's daily budget to $329.** Don't split the daily allowance across campaigns. See
`auction-model.md` for why: Google enforces the cap at the account level, not by summing campaign budgets,
so over-allocating is safe by construction, and unspent budget doesn't roll over. Capping any one campaign
below the account ceiling stops it serving the moment it hits its own cap, discarding impressions the
account won't recover that day.

### Do not budget above $329

Setting a campaign's budget far above $329 does nothing. $329 already permits a single campaign to consume
the account's entire daily allowance; a $1,000/day campaign budget and a $329/day campaign budget produce
identical behavior, because Google stops serving the account at $329 either way. A comparable well-run
grant account that runs $1,000/day on one campaign but only spends ~$244/day against its $329 allowance is
not counter-evidence: its budget never binds either, so raising an already-non-binding number changed
nothing. Revisit only if an account ever shows Lost IS (budget) materially above 0%.

### Documented exceptions

A campaign may be budgeted below $329/day only for a stated, recorded reason:

| Exception | Cap | Why |
|---|---|---|
| **PMax pilot** | $50-100/day | A fence so PMax can't consume the daily allowance before Search campaigns serve. |
| **Campaign under CTR remediation** | Current spend level | While the emergency brake is on, don't give a low-CTR campaign more room to accumulate bad impressions. Lift the cap when the brake releases. |
| **Deliberate spend fence during a pilot** | Stated per pilot | Any experiment that shouldn't be able to eat the whole account. |

**Moving an existing account onto this rule is a one-time correction**, not an optimization step, so it's
exempt from the ±10% step-size limit (`change-hygiene.md`). Make the move in one step, then let the
account settle 14 days before reading the result. After that, there's usually nothing left to reallocate:
the binding constraint moves from budget to inventory, which is the right place for it.

## Diagnosing a $2-capped campaign

From performance data: is any campaign on Maximize Clicks, Target Impression Share, Manual CPC, or
Enhanced CPC?

```
Is ANY conversion action live and recording in this account?
  (a page-view action counts here; this is about bidding eligibility, not
   about whether a meaningful conversion exists)

  YES -> switch to Maximize Conversions immediately. Don't wait for 15-30
         conversions.

  NO  -> install the page-view conversion today, then switch. A campaign
         landing page is an acceptable target, so this is never blocked by
         site content. Only genuine lack of tag access blocks it, and that's
         a dependency to escalate: what's missing, who must fix it, what
         exactly to ask for. Review at 30 days, not 60.

SEPARATELY, regardless of the above: is a real (non-page-view) conversion
recording this month? If not, that's a compliance issue on its own track
(P1-B). The page-view action doesn't cover it.
```

Don't diagnose a capped campaign's low impressions as a keyword, budget, or Quality Score problem. The cap
is the cause; fix it first, then re-measure before concluding anything else.

## Budget reallocation

Under the $329 default there's usually nothing to reallocate; the exceptions above are the only place a
real budget ceiling exists. Where reallocation is warranted:

1. **A campaign is only budget-constrained if Lost IS (budget) is materially above zero.** Check this
   before proposing any budget increase (see `auction-model.md`'s rank vs. budget split). More budget on a
   campaign losing impression share to rank buys nothing.
2. **Never starve a converting campaign.** A campaign with active conversions keeps at least its current
   daily budget.
3. **Don't budget below $329 to express priority.** Priority belongs in keyword quality, ad quality, and
   bidding strategy, which is how the algorithm decides where money goes. If a campaign genuinely shouldn't
   run, pause it; don't starve it.
4. **Step-size limits apply:** ±10% per pass under normal optimization; up to +50% when Lost IS (budget)
   proves the budget is the binding constraint; the one-time move to the $329 default is exempt
   (`change-hygiene.md`).

### Reallocation process

```
1. List campaigns with: daily budget, spend MTD, spend as % of budget,
   conversions MTD, CTR.
2. Identify donors (spending well below budget, low conversion density):
   budget available to move = daily_budget - avg_daily_spend, rounded down.
3. Identify recipients (spending at or near budget, good conversion rate,
   consistently hitting the daily cap, high CTR, active conversions).
4. Reallocate from donors to recipients. Document each move: from, to,
   amount, reason.
5. Run the P1 gate below before emitting.
```

### Example: moving an account onto the $329 default

```
Brand:    $50/day budget,  avg $22/day spend, 22% CTR, 1 conversion
           Lost IS (budget) 0%,  Lost IS (rank) 91%
Programs: $150/day budget, avg $140/day spend, 6.8% CTR, 5 conversions
           Lost IS (budget) 4%,  Lost IS (rank) 88%
Donate:   $149/day budget, avg $149/day spend (capped), 8.1% CTR, 2 conversions
           Lost IS (budget) 31%, Lost IS (rank) 62%

Brand:    not budget-constrained (0% lost to budget); low volume is
          structural. Cutting its budget gains nothing and risks a
          high-CTR campaign's impressions.
Programs: barely budget-constrained; has unused room.
Donate:   genuinely budget-constrained (31% lost to budget) with live
          conversions. This is the one case where more budget buys real
          impressions.

Move all three to $329/day in one step (the one-time exemption applies).

P1 check:
  Brand CTR 22%: uncapping a high-CTR campaign helps account CTR. Allow.
  Donate CTR 8.1%, above the 7% buffer: safe. Allow.
  Programs CTR 6.8%, inside the 5-7% warning band: uncapping lets a
    below-buffer campaign accumulate more impressions before it's fixed.
    Hold Programs at $150/day until CTR clears 7%, record the exception,
    and route the CTR fix separately.

Then freeze all three campaigns 14 days; don't read the result before then.
```

## P1 gate on every budget or bid recommendation

```
P1-A: does this change risk lowering account CTR below 7%?
  Adding broad-match keywords            -> CTR risk -> block
  Raising budget on a low-CTR campaign   -> risk      -> block
  Raising budget on a high-CTR campaign  -> no risk   -> allow
  Loosening a target CPA                 -> no risk   -> allow

P1-B: does this change risk taking conversions below 1/month?
  Pausing a campaign with the only converting keywords -> block
  Shifting budget off a converting campaign -> conditional: only if the
    campaign keeps enough budget to hold >= 1 conversion/month

If either check blocks the change, don't make it; record why.
```

Spend posture: while account spend utilization is well under the monthly ceiling, don't hold back budget,
tighten a target, or delay a bootstrap switch for cost-efficiency reasons. The objective is spend and
reach, not cost, as long as P1 holds (`volume-first.md`). Cost-efficiency tuning is a lever for once
utilization is already high.

After bidding is set, the next step is keyword and ad content (`keyword-doctrine.md`).
