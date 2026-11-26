# Ad Grants invariants: the complete rule catalog

Every Google Ad Grants compliance rule, in one place. This is the exhaustive reference; `guardrails.md`
only summarizes the change-authority split (auto vs queued). When Google changes a rule, this is the file
to edit.

**Priority system:**
- **Priority 1:** never get the account disabled. Always wins.
- **Priority 2:** maximize spend and conversions toward the $10k/month grant ceiling. Defers to Priority 1
  on any conflict.

---

## PRIORITY-1 GUARDRAILS: disablement triggers

These two rules disable accounts. Check them first, every pass, no exception. When either is at risk, stop
all optimization and do compliance surgery only.

### P1-A: account-level Search CTR >= 5%

**Threshold:** 5% CTR measured monthly at the account level, on Search campaigns. Two consecutive months
below 5% is automatic deactivation, without warning.

**Grace period:** new accounts get a 2-month grace window from the account's start date. During grace, CTR
is monitored and reported but the floor is not a disablement trigger yet.

**Buffer:** target 7-8% account CTR, not the bare 5% floor. Normal weekly fluctuation should never dip
below the floor. Between 5% and 7% is a warning: begin preventive action.

**Calibration:** a well-structured grant account normally runs 8-15% CTR, commonly around 12%, not 5%. The
floor is what disables an account; it is not the target and it is not "fine." An account sitting at 5.5%
is not comfortably compliant, it is structurally wrong: loose ad groups, ads that do not mirror their
keywords, or geo targeting too broad. Read 5-7% as a structural warning worth acting on. See
`auction-model.md` for the benchmark context.

**Check:** weekly. Pull account-level impressions and clicks for the current month-to-date on Search
campaigns only. Compute CTR = clicks / impressions. Compare against the 5% floor and the 7% buffer. Do not
wait for month-end; by then it is too late to recover.

**Fix:** pause high-impression, low-CTR keywords. Tighten broad match to phrase/exact. Add negatives for
irrelevant search terms. Improve ad relevance (headlines matching keyword intent).

**Automatable:** yes.

**Disablement risk:** direct.

#### CTR is a ratio: cutting spend does not raise it

CTR = clicks / impressions. Reducing budget lowers both numerator and denominator proportionally; the
ratio stays the same or worsens. The fix is always on the impression side: remove or pause keywords that
generate impressions without clicks, tighten match types so fewer irrelevant queries trigger ads, add
negatives to block non-converting search terms, and improve ad copy so more impressions convert to clicks.
Spend drops as a *consequence* of that surgery, never as the mechanism. No skill or recommendation may
throttle budget and call it a CTR fix.

The four CTR levers, in order of impact:
1. **Pause high-impression, low-CTR keywords.** The single biggest lever. One bad keyword with 10,000
   impressions and 2% CTR drags the whole account down.
2. **Tighten match types.** Move broad match to phrase or exact to stop irrelevant impression bleed.
3. **Add negatives.** Block search terms that trigger ads but never get clicks.
4. **Improve ad relevance.** Rewrite headlines to match keyword intent so impressions convert to clicks.

**Example:** an account has 50,000 impressions and 2,800 clicks this month (5.6% CTR, inside the warning
zone). One keyword, "community resources," has 8,000 impressions and 120 clicks (1.5% CTR). Pausing it
changes the math to 42,000 impressions and 2,680 clicks: 6.4% CTR. That is the fix. Cutting the campaign
budget from $300/day to $100/day would not change the ratio.

**PMax note:** Performance Max campaigns are excluded from the 5% CTR calculation. Accounts running
exclusively Smart Campaigns are exempt from the CTR rule entirely (and lose keyword-level visibility as a
result; see the "never use Smart Campaigns" item in `automation-governance.md`).

---

### P1-B: at least one meaningful conversion per month

**Threshold:** at least 1 meaningful conversion per month. Applies to accounts created on or after April
22, 2019; also to any account using conversion-based Smart Bidding, and to any account created on or after
January 1, 2018 with conversion tracking set up.

**What counts as meaningful:** donations, purchases, ticket sales, membership registrations, email
sign-ups, volunteer sign-ups, form completions, petitions signed, quizzes completed, information-request
submissions, calls to the organization, or substantive engagement with content. The conversion must
represent a real action by a real person.

**What does not count:** passive metrics (time on site, homepage visits, scroll depth) may be tracked but
must be excluded from "Conversions" and categorized as "Other." Donation conversions should be categorized
as purchase/sale.

**The single most important reading rule in this file: the page-view conversion is not P1-B.**

`conversion-ladder.md` installs a page-view conversion as the default primary on the account, deliberately,
to lift the $2.00 bid cap. Its target may be a campaign landing page, so the account's headline Conversions
number is expected to run close to its click count.

```
The Conversions column is a BIDDING metric, not a compliance metric.
NEVER read P1-B off the account-level conversion total.
```

The page-view action is a bidding mechanism and does **not** satisfy P1-B. The account must also track at
least one genuinely meaningful action. An account whose only conversion is a page view is exposed on this
direct disablement trigger however well the bidding is working, and the inflated headline number hides
that.

**How to check P1-B correctly:** segment by conversion action. Read the monthly count of actions flagged
as the P1-B basis (form submissions, downloads, tel:/mailto: clicks, signups, donations). That segmented
number is P1-B. If it is zero, the account is exposed regardless of a five-figure headline total.

Two separate questions, both asked every pass:
1. Is Smart Bidding running on exactly one clean primary? (the page-view action)
2. Is there a meaningful conversion this month? (the meaningful-action total only)

**Anti-pattern: clicks approx. equal conversions on a real action.** If a conversion action that claims to
be meaningful has a rate near 100%, it is misconfigured against a page every visitor hits, and it cannot
serve as the P1-B basis. Point real actions at confirmation pages or submission events. On the designated
page-view action, a near-100% rate is expected and is not a finding.

The claim that Google treats a near-100% account conversion rate as a spam signal triggering manual review
is unsourced practitioner folklore, not a documented rule. P1-B is the documented exposure.

**Check:** monthly. Pull conversion counts segmented by conversion action, never blended. Alert if the
meaningful-conversion total is zero by the 15th of the month. Separately alert if the page-view action has
stopped recording, since that puts bidding back toward the $2 cap.

**Fix:** if zero meaningful conversions, first check whether a meaningful conversion action is even
defined. If none is, that is the finding, and it is a blocking dependency (a form event, a tel:/mailto:
click, a download, a signup) to resolve before anything else. If one is defined but recording zero: is the
tracking tag firing? Is the thank-you page reachable? Is the action still active? Has the website changed?
Broken tracking usually needs a human to re-check the site.

**Automatable:** monitoring is automatable. Fixing broken tracking usually requires a human.

**Disablement risk:** direct. Zero meaningful conversions in a month can trigger deactivation, and a large
Conversions column does not protect against it. This is the single most likely way for the conversion
doctrine to go wrong: an account that looks busy, spends well, and has no meaningful conversion behind the
number. Check it separately every pass.

---

## Emergency brake

**Rule:** if the account is *actively* below 5% CTR past the grace period (not merely trending toward it,
but currently below), the pass does compliance surgery only: no optimization, no new keywords, no budget
reallocation, no experiments, until CTR recovers above 7%.

The brake releases when account CTR is above 7% (not the bare 5% floor), to prevent immediate re-entry.

**Example:** an account is past grace. Month-to-date CTR is 4.2%. The emergency brake activates; the pass
skips budget reallocation and keyword expansion and runs only: pause the worst-CTR keywords, add negatives
from the search-terms report, tighten match types. Next week's check shows 6.8%: the brake stays on.
Following week shows 7.3%: the brake releases and normal optimization resumes.

---

## Already-disabled alarm

**Rule:** if the account is found disabled, deactivated, or suspended on any read, surface it immediately
with the probable reason, ahead of everything else in that pass. Do not attempt optimization.

**What to surface:**
- The detected status (disabled/deactivated/suspended).
- The probable reason if detectable (CTR violation, conversion violation, policy violation, inactivity,
  identity-verification deadline missed).
- The reinstatement path: fix the issue, then submit a reactivation request via Google's form
  (support.google.com/grants/contact/Request_for_reactivation_cases_2).

**Example:** a scheduled pass reads the account and its status comes back SUSPENDED. The pass stops all
other work and emits:

```
ACCOUNT DISABLED
Status: SUSPENDED
Probable cause: CTR below 5% for 2 consecutive months
Action required:
  1. Pause all high-impression, low-CTR keywords
  2. Add negatives for irrelevant search terms
  3. Verify ads are relevant to keyword themes
  4. Once CTR would be >= 5% with the remaining keywords, submit a reactivation request
```

This appears before any other output for that pass.

---

## Compliance rules

Rules that can cause suspension but are not the two primary disablement triggers. Still serious: several
of these suspend without warning.

### R-STRUCT-1: at least 2 sitelink assets, account-wide

**Threshold:** at least 2 active sitelink assets serving on the account. Sitelinks attached at the
**campaign** level satisfy this; they do not have to be account-level.

**Detection trap:** a query that only checks account-level sitelink assets returns 0 on an account whose
sitelinks are attached per campaign, which is a normal and fully compliant build pattern (every serving ad
still has sitelinks available). Count ENABLED sitelink assets across **both** the account-level assets
**and** the campaign-level assets, or a compliant account reads as a structural violation and gets
duplicate sitelinks built on top of working ones. An account can carry, say, 24 enabled sitelink assets
spread across 4 campaigns and return an empty account-level-only query.

**Fix:** create sitelink assets pointing to distinct, relevant pages on the organization's website (for
example: Donate, Programs, About, Contact). Two is the floor; four is better for ad real estate and CTR.

**Automatable:** yes.

**Disablement risk:** indirect (structural violation).

### R-STRUCT-2: at least 2 ad groups per campaign

**Threshold:** every campaign has at least 2 ad groups, each with tightly themed keywords aligned to their
ads and landing pages.

**Fix:** if a campaign has only 1 ad group, split it by theme or add a second relevant ad group.

**Automatable:** yes.

**Disablement risk:** indirect.

### R-STRUCT-3: at least 2 ads per ad group

**Threshold:** every ad group has at least 2 active ads. Use Responsive Search Ads (RSAs).

**Ceiling:** Google permits a maximum of 3 enabled RSAs per ad group. Target 2-3, with at least one rated
"Good" or "Excellent" Ad Strength. Do not propose a fourth RSA; it cannot be enabled.

**PMax does not count.** R-STRUCT-2 and R-STRUCT-3 are Search-campaign concepts. A Performance Max campaign
has asset groups, not ad groups, and cannot satisfy these floors. The account needs at least one healthy
Search campaign regardless of what else it runs.

**Fix:** create additional RSAs with 10-15 headlines and 4 descriptions, relevant to the ad group's keyword
theme.

**Automatable:** yes.

**Disablement risk:** indirect.

### R-STRUCT-4: specific geo-targeting

**Threshold:** every campaign has specific geographic targeting set. Never target "All countries" or leave
geo-targeting blank.

**Fix:** set location targeting based on the organization's actual service or donor geography. An org
funded by domestic donors but delivering relief abroad should target where the donors are, not where the
program runs. A local food bank should target only its own metro area, not the whole country.

**Automatable:** yes.

**Disablement risk:** indirect; fixed by adding proper geo-targeting and sitelinks, then requesting
reinstatement if already triggered.

### R-KW-1: no single-word keywords

**Threshold:** single-word keywords are not permitted, except:

**Allowlist:**
- Branded terms owned by the organization (its own name).
- Approved medical conditions (per Google's exception list).
- These common nonprofit terms: `charity`, `charities`, `donate`, `donation`, `ngo`, `ngos`, `nonprofit`,
  `nonprofits`, `volunteer`, `volunteering`.

**Detection rule:** a keyword with no space is a single-word keyword. Dashes, periods, and special
characters do not make a term single-word (for example, "covid-19" is allowed).

**Check:** on every keyword proposal, before it is written, and on a recurring audit of live keywords. Fail
closed: if uncertain whether a term is on the allowlist, reject it.

**Fix:** pause the single-word keyword immediately. Replace with a multi-word variant capturing the same
intent (for example, "cancer" -> "cancer treatment options", "cancer support groups").

**Automatable:** yes: a string check (no space = single word) plus an allowlist lookup.

**Disablement risk:** indirect (policy violation, can trigger suspension).

### R-KW-2: no overly generic keywords

**Threshold:** keywords must indicate the intent of the person searching. Generic terms that don't connect
to the organization's mission or don't show clear searcher intent must be paused or removed.

**Tell:** a below-average landing-page-experience score is the primary signal that a keyword is too generic
for the ad and page it's attached to.

**Examples to reject:** "free videos", "e-books", "today's news", "best apps", "how to", "help",
"information", "resources" (without qualification).

**Check:** on every keyword proposal and on a recurring audit; check the landing-page-experience component
of Quality Score.

**Fix:** pause the generic keyword. Replace with a more specific, mission-aligned variant, or remove.

**Automatable:** yes (QS-component check plus pattern matching), though borderline cases need judgment.

**Disablement risk:** indirect.

### R-KW-3: no Quality Score 1-2 keywords

**Threshold:** any keyword with Quality Score 1 or 2 must be paused or removed. Keywords with QS shown as
"-" (null, not enough data) are exempt and should not be touched.

**Check:** daily or weekly. Pull QS by keyword. Pause anything with QS <= 2 that is not "-". Google
documents an automated rule for exactly this; replicate the logic: condition QS <= 2, action = pause, run
on trailing-30-day data.

**Fix:** pause the keyword immediately. Diagnose QS components (expected CTR, ad relevance, landing-page
experience) to decide whether to attempt recovery (better ad copy, better landing page) or remove
permanently.

**Example:** a keyword "community programs" has QS 2, with landing-page experience below average because
its final URL is the homepage rather than a specific programs page. If a matching page exists, remap the
final URL and try again; if not, remove the keyword.

**Automatable:** yes: pull plus auto-pause rule.

**Disablement risk:** indirect; Google's own mission-based policy requires removal, and repeated QS 1-2
keywords indicate broader account health issues.

### R-BID-1: conversion-based Smart Bidding required

**Threshold:** accounts created on or after April 22, 2019 must use conversion-based Smart Bidding on all
campaigns (unless using Smart Campaigns). Non-compliant campaigns are subject to automatic bid-strategy
changes by Google.

**Allowed strategies:** Maximize Conversions, Maximize Conversion Value, Target CPA, Target ROAS.

**Maximize Clicks and Target Impression Share are not exempt from the $2.00 CPC cap.** The exemption
covers conversion-based Smart Bidding only, the four strategies above. Any strategy optimizing toward
clicks or visibility rather than conversions is capped at $2.00 per click, same as Manual CPC. The full
capped set is Maximize Clicks, Target Impression Share, Manual CPC, and Enhanced CPC. Combined with the
dual auction (grant ads always rank below paid ads; see `auction-model.md`), a $2.00 ceiling makes a
campaign non-competitive on most keywords. Treat any campaign found on Maximize Clicks as a live defect,
not a configuration preference.

**Detection trap: Maximize Clicks reports as `TARGET_SPEND` in the API.** The enum for Maximize Clicks is
`TARGET_SPEND`, not `MAXIMIZE_CLICKS`. A campaign showing `biddingStrategyType: TARGET_SPEND` **is** on
Maximize Clicks and **is** capped at $2.00. Easy to miss because the name reads like a budget setting, not
a bid strategy.

**The full capped set, by API enum:**

| API value | UI name | Capped? |
|---|---|---|
| `TARGET_SPEND` | Maximize Clicks | Yes |
| `TARGET_IMPRESSION_SHARE` | Target Impression Share | Yes |
| `MANUAL_CPC` | Manual CPC | Yes |
| `MAXIMIZE_CONVERSIONS` | Maximize Conversions | No |
| `MAXIMIZE_CONVERSION_VALUE` | Maximize Conversion Value | No |
| `TARGET_CPA` | Target CPA | No |
| `TARGET_ROAS` | Target ROAS | No |

**Bootstrap exception (narrow):** Maximize Clicks is permitted only when no real conversion action can be
made to fire yet, and only with a 30-day review. The exit condition is "a real conversion action fires,"
not "enough data accumulated." The default is Maximize Conversions from launch, with conversion tracking
as the launch gate (`conversion-ladder.md`).

**Manual CPC:** not allowed for post-2019 accounts, and capped at $2.00 regardless.

**Check:** weekly. Query campaign bidding-strategy type. Flag any campaign on Maximize Clicks, Target
Impression Share, Manual CPC, or Enhanced CPC immediately, and escalate any campaign on Maximize Clicks
past 30 days.

**Fix:** switch the campaign to Maximize Conversions (the safest default). Requires conversion tracking
active and firing (see P1-B).

**Hard precondition: the campaign's budget must not be `explicitly_shared`.** Google rejects every
conversion-based strategy on a shared budget with `BIDDING_STRATEGY_TYPE_INCOMPATIBLE_WITH_SHARED_BUDGET`,
and `explicitly_shared` cannot be flipped after the budget is created. The only fix is a new dedicated
budget, repointing the campaign at it. This is not a rare edge case: a budget created without an explicit
`explicitlyShared: false` **defaults to shared**, so a campaign built without that flag set will carry it
even at `reference_count: 1`. One shared budget referenced by one campaign still counts as shared, and it
is why a campaign can sit on `TARGET_SPEND` indefinitely despite every attempt to switch it.

```
Check before any R-BID-1 fix:
  SELECT campaign.name, campaign.bidding_strategy_type,
         campaign_budget.explicitly_shared, campaign_budget.amount_micros
  FROM campaign

  explicitly_shared = true  ->  create a dedicated budget carrying the same
                               amount, repoint the campaign, THEN switch bidding.
```

Verify the flag is `false` after any bidding fix; a silent failure here leaves the account bid-capped while
the change log says it was fixed.

**Automatable:** yes.

**Disablement risk:** indirect; Google may auto-change the bid strategy, which can disrupt performance, and
non-compliance is itself a policy violation.

### R-WEB-1: website policy floor

**Threshold:** the organization's website must meet all of:
- HTTPS sitewide, no mixed content.
- Substantial, original content that clearly states the organization's mission.
- All links functional (no broken pages, no 404s on landing pages used in ads).
- Mobile-friendly.
- Reasonable page load speed.
- No primary use of AdSense or affiliate monetization.

**Check:** at setup and on a recurring cadence; landing pages used in ads should be checked monthly for
broken links and HTTPS status.

**Fix:** website issues need human intervention; flag them rather than attempting a fix. Do not run ads
pointing to broken or non-compliant pages. If a landing page goes down, pause the ads pointing to it
immediately.

**Donation-processor verification.** When the donation flow completes on a third-party processor's domain
(for example Classy, Kindful, PayPal, Qgiv, or similar) rather than the organization's own site, that
processor relationship needs its own verification: ownership of the primary domain alone doesn't cover it,
and a mismatch here can disqualify ads even when performance looks strong. Confirm which domain actually
completes the conversion and flag any third-party processor domain for verification, the same way a broken
landing page would be flagged.

**Automatable:** partially. URL checking and HTTPS verification are automatable; content quality and
mission clarity require human judgment.

**Disablement risk:** indirect; broken landing pages and website policy violations can trigger suspension
independent of Ad Grants-specific rules.

### R-WEB-2: standard Google Ads policies

**Threshold:** all standard Google Ads advertising policies apply on top of the Ad Grants-specific rules:
prohibited content, prohibited practices, restricted content, editorial and quality standards.

**Check:** ongoing. Monitor for disapproved ads and check disapproval reasons.

**Fix:** fix or remove disapproved ads immediately. Common causes: misleading claims, editorial issues
(excessive punctuation, ALL CAPS), destination-URL mismatches.

**Automatable:** partially; detecting disapprovals is automatable, fixing the underlying content issue may
need judgment.

**Disablement risk:** indirect; policy violations can suspend the account.

---

## Human-only tasks

These cannot be automated. Surface them as reminders and never attempt to complete them on the user's
behalf.

### R-HUMAN-1: annual program survey

**Threshold:** all grantees must complete an annual program survey sent to the login email addresses on
the account. Non-participation results in account deactivation.

**Responsibility:** surface a reminder as the survey window approaches (typically annual from grant
activation). Confirm the account's notification email is opted in to Google's emails; missing the survey
email is a common failure mode. Submit as soon as the survey opens rather than close to any deadline:
multiple independent sources treat a late submission as a compliance trigger in its own right, not just a
formality. The survey form requires the account's 10-digit Google Ads customer ID entered in the correct
format; a malformed ID is a common way a submission fails silently.

**Automatable:** no. A human must complete the survey.

**Disablement risk:** direct; non-participation deactivates the account.

### R-HUMAN-2: advertiser identity verification

**Threshold:** Google Ads runs an advertiser identity verification program. The verifying individual's
name, address, and government ID must match the organization's incorporation documents. Failure to
complete verification by the deadline pauses the account.

**Responsibility:** flag when verification is requested. Identify the correct verifying individual: an
officer of the organization whose identity matches its incorporation documents. That is not necessarily
the person operating the account day-to-day, if that person is not an officer of the org.

**Automatable:** no. A specific human (an officer of the org) must complete verification.

**Disablement risk:** direct; the account is paused until verification completes.

### R-ACTIVITY-1: account login activity

**Threshold:** at least one login to the account every 30 days. API activity counts as a login.

**Check:** satisfied by regular API activity, but verify it is actually happening: an account not read in
30 days is not being managed, whatever the schedule says.

**Do not dismiss this rule.** Practitioner guidance identifies failure to log in monthly as the single most
common reason nonprofits lose the grant. It is a non-issue for an actively-managed account and a leading
cause of loss for a neglected one. The risk case is an account parked at a volume ceiling (see
`account-lifecycle.md`) that then gets deprioritized: attention drops, API activity stops, and the clock
starts. Deprioritized never means untouched; every live account gets a read at least monthly, including one
parked at its maturity ceiling.

**Automatable:** yes, by regular scheduled operation, provided the schedule actually runs.

**Disablement risk:** direct in practice, even though Google frames it as inactivity rather than a policy
breach.

---

## Enforcement note

Google states that any account found in violation of program policies is subject to automatic suspension
without notification. Google communicates non-compliance primarily through in-product notifications, not
email. Monitor account status on every read; do not rely on email alerts.

Severe or repeated violations can lead to permanent cancellation with limited appeal.

**Prevention is the strategy. Reinstatement is the fallback.**

Reinstatement path: bring the account into compliance, then submit a reactivation request via Google's form
at support.google.com/grants/contact/Request_for_reactivation_cases_2. Typical turnaround is 3-10 business
days, during which the account gets zero ad spend.

---

## Quick-reference table

| ID | Rule | Threshold | Check cadence | Automatable | Disablement risk |
|---|---|---|---|---|---|
| **P1-A** | **Account Search CTR >= 5%** | **>=5% monthly (2-mo grace)** | **Weekly** | **Yes** | **DIRECT** |
| **P1-B** | **>=1 conversion/month** | **>=1 meaningful conv** | **Monthly (alert by 15th)** | **Monitoring yes; fixing partial** | **DIRECT** |
| R-STRUCT-1 | >=2 sitelink assets | >=2, account or campaign level | Monthly | Yes | Indirect |
| R-STRUCT-2 | >=2 ad groups/campaign | >=2 per campaign | Monthly | Yes | Indirect |
| R-STRUCT-3 | >=2 ads/ad group | >=2 per ad group, max 3 RSAs | Monthly | Yes | Indirect |
| R-STRUCT-4 | Specific geo-targeting | Set correctly | Monthly | Yes | Indirect |
| R-KW-1 | No single-word keywords | None (except allowlist) | Weekly + pre-write | Yes | Indirect |
| R-KW-2 | No overly generic keywords | None | Weekly + pre-write | Yes (with judgment) | Indirect |
| R-KW-3 | No QS 1-2 keywords | Pause/remove | Daily/weekly | Yes (auto rule) | Indirect |
| R-BID-1 | Conversion-based Smart Bidding required | Post-2019 accounts | Monthly | Yes | Indirect |
| R-WEB-1 | Website policy floor | HTTPS, links, content, mobile | Quarterly + monthly URLs | Partial | Indirect |
| R-WEB-2 | Standard Google Ads policies | Always | Ongoing | Partial | Indirect |
| R-HUMAN-1 | Annual survey | Complete when sent | Annual (flag) | No | Direct |
| R-HUMAN-2 | Advertiser ID verification | Match incorporation docs | On request (flag) | No | Direct |
| R-ACTIVITY-1 | Account login | >=1 per 30 days | Auto-satisfied by use | Yes | Indirect |

**Bold rows are Priority-1.** Check P1-A and P1-B before anything else, every pass. The emergency brake
activates on a P1-A violation past grace. The already-disabled alarm fires on any detected suspension.
