# Compliance: the priority-1 gate

This file is the CTR and conversion compliance playbook: how to check the account against the Ad Grants
rules, and what surgery to run when a check fails. It runs first in every pass, and its findings outrank
every optimization action; when compliance and optimization conflict, compliance wins. For the
change-authority split (what applies automatically vs. what needs sign-off) and the full invariant list,
see `guardrails.md`; this file does not restate that table.

Two modes, same rules, different data sources:

- **Pre-launch validation:** before a new campaign goes live, check the planned build (campaigns, ad
  groups, keywords, ads, assets) against these rules. Cheaper to fix a plan than a live account.
- **Live audit:** every scheduled pass, before any optimization. Catches violations that appeared in the
  running account: keywords that degraded, Quality Score that dropped, URLs that broke, structure someone
  changed outside the normal flow.

## P1-A: account CTR >= 5% (target 7-8% buffer)

**Measure CTR on Search campaigns only, always.** Do not substitute a blended query across all campaign
types. Performance Max is excluded from the Ad Grants CTR rule, and on a PMax-heavy account the blended
figure can be off by roughly 9x in the direction that fires the emergency brake on an account that is
actually healthy (measured on one mature account: 4.23% blended vs. 39.73% Search-only).

**Grace period:** the first 2 months after account launch. CTR below 5% during grace is a WARN, not a FAIL;
do not activate the emergency brake during grace.

**After grace:**

```
CTR >= 7%  -> PASS. Still worth a light monthly pass: flag any individual
              keyword persistently under 5% CTR or QS <= 3 as a hygiene
              candidate, even though account CTR is healthy enough that no
              surgery is required. Preventive weeding catches weak keywords
              before they accumulate, rather than only once CTR is already
              in trouble.

CTR 5-7%   -> WARN, below the buffer. Pull per-keyword CTR, identify surgical
              targets (highest-impression keywords with CTR < 5%), simulate
              pausing them, and pause as a compliance-priority action.

CTR < 5%   -> FAIL. ACTIVATE EMERGENCY BRAKE (below). Pull per-keyword CTR
              and pause enough to project simulated CTR above 7%, not just
              above 5%: the brake releases at 7%.
```

**Pre-launch CTR-risk checks:**

```
Any broad-match keyword planned:
  No broad-match-gate annotation, or gate not passed -> WARN. Verify the five
    preconditions from keyword-doctrine.md's gate: conversion-based Smart
    Bidding live, clean conversion tracking, a populated negative list, a
    paired negative batch in the same launch batch, and a scheduled weekly
    search-terms review.
  Account Search CTR already below 7% -> WARN. Stop adding broad; tighten
    existing seeds instead.
  Ad group is a BRAND ad group -> FAIL. Brand stays EXACT; brand-exact CTR is
    the account's compliance basis.
  Seed search volume is NOT a gate condition. A broad keyword is a seed, not
    a target; don't flag a broad keyword for low seed volume.
  Gate passed but no paired negative-keyword batch in the same launch -> WARN.
    Negatives ship in the same batch, not after.
  Gate passed, paired negatives present -> PASS. This is the expected,
    compliant path, not a risk to flag.

Any very generic keyword that passed screening anyway -> WARN.
Keyword count per ad group much higher than the ad-group design target ->
  WARN (loose theming).
Each ad group has a tight keyword theme, ads match keyword themes (headline
  includes the keyword) -> PASS.
```

## P1-B: at least 1 meaningful conversion per month

**Read this before running the check.** Every account should carry a page-view conversion as its primary
bidding action, whose target may legitimately be a campaign landing page (`conversion-ladder.md`). The
account-level conversion total is therefore always non-zero and always close to the click count. Running a
blended check against it would pass every account unconditionally, including one with no meaningful
conversion at all, which is exactly the disablement trigger this check exists to catch.

```
P1-B IS READ FROM REAL ACTIONS ONLY. NEVER FROM THE ACCOUNT TOTAL.
```

```
1. Pull conversions for the current month SEGMENTED BY CONVERSION ACTION.
   Never the blended account total.

2. Classify each action:
     Bidding-role page-view action     -> excluded from P1-B.
     A designated meaningful action    -> counts toward P1-B.
     Unlisted in your records          -> FAIL ("Untracked conversion action
       '{name}' exists in the account. Classify it before this check can be
       trusted." Run an unfiltered pull every pass: an analytics platform can
       add actions without warning.)

   REAL_CONVERSIONS = sum over meaningful actions.

3. If today is before the 15th:
     REAL_CONVERSIONS = 0 -> WARN ("Zero meaningful conversions MTD on day
       {n}. The account total is {blended}, which does NOT satisfy P1-B.
       Monitor.")
     REAL_CONVERSIONS > 0 -> PASS

4. If today is the 15th or later:
     REAL_CONVERSIONS = 0 -> FAIL ("Zero meaningful conversions past
       mid-month. DIRECT DISABLEMENT TRIGGER. The account reports {blended}
       conversions, but those are page views and do not qualify. Diagnose:
       does a meaningful action exist at all? Is its tag firing? Has the site
       changed? Escalate this pass.")
     REAL_CONVERSIONS > 0 -> PASS

5. Does the account have ANY meaningful conversion action defined at all?
     NO -> FAIL ("No meaningful conversion action defined. This is a direct
       disablement trigger no matter how large the Conversions column looks."
       Route to conversion-ladder.md and treat as a blocking dependency.)

6. Anti-pattern checks:
     a. Blended conversion rate near 100% -> NOT a finding. Expected. Skip.
     b. Any meaningful action converting at its own rate > 50%
        -> WARN ("Real action '{name}' converts at {x}%, implausible for a
           meaningful action. Likely misconfigured against a common page.")
     c. More than one action with primary status set
        -> WARN ("{n} primary actions. Collapse to one.")
     d. Any passive/engagement action counting many-per-click
        -> WARN ("'{name}' is many-per-click on a passive signal. Set it to
           one-per-click.")

7. Is the page-view (bidding) action still recording at all this month?
     NO -> WARN ("Bidding instrument has stopped firing. Smart Bidding is
       losing its signal and the campaign drifts back toward the $2 cap. Not
       a P1-B issue on its own, but urgent for spend.")

8. Conversion-type check, for every action meant to fire from the website
   (not a deliberate offline import or call-tracking setup):
     Offline-only type (e.g. an uploaded-clicks/calls type) -> FAIL. It can
       only be populated by an offline import and will NEVER fire from web
       traffic, regardless of tag or page setup.
     A standard website or analytics-linked type -> PASS.
```

**Pre-launch validation:**

```
1. Is a page-view (bidding) conversion planned?
     NO -> FAIL. The campaign will launch bid-capped at $2.00. A campaign
       landing page is an acceptable target, so there is no reason for this
       to be missing.
2. Is exactly ONE action marked primary?
     NO -> FAIL, with the list of primaries.
3. Is at least one meaningful action planned?
     NO -> WARN, and record as a blocking dependency with an owner. Does NOT
       block launch: the campaign goes live on the page-view conversion while
       the real action is built. It DOES stay on the escalation list every
       pass until resolved.
4. Do the planned real conversions pass the anti-pattern checks (a distinct
   thank-you page or event, not sitting in the main navigation)? These checks
   do not apply to the page-view action itself.
```

## Rule-code checks

Each check below references a rule code, a cadence, and the fix. Full invariant definitions live in
`guardrails.md`; this is the audit procedure.

**R-KW-1, no single-word keywords.** Weekly (live), every validation (pre-launch).

```
Keyword text contains a space -> PASS.
No space, but a dash or period (exemption) -> PASS.
No space, on an allowlist -> PASS.
Otherwise -> FAIL. Pause it.
```

**R-KW-2, no overly generic keywords.** Weekly (live audit only; hard to detect pre-launch without
performance data).

```
Landing page experience component = below average -> WARN.
Also QS <= 3 -> FAIL. Pause it.
```

**R-KW-3, no Quality Score 1-2 keywords.** Daily or weekly (live audit only; QS doesn't exist pre-launch).

```
QS null/unrated -> SKIP, insufficient data.
QS <= 2          -> FAIL. Pause immediately.
QS 3-4           -> WARN. Diagnose components.
QS >= 5          -> PASS.
```

**RARELY_SERVED keyword detection.** Not a Grants rule itself; an operational check that keeps the
volume-ceiling problem from silently regrowing after a one-off fix. Weekly, same cadence as P1-A, live
audit only.

```
Pull system_serving_status per keyword.
RARELY_SERVED for 2+ consecutive weekly checks?
  YES -> Generate a broader replacement (seed-broad-first research, see
         keyword-doctrine.md), screen it through the standard checks plus the
         broad-match gate. Pause the confirmed dead keyword (don't remove it:
         removal is disabled by design, see guardrails.md) and create the
         replacement alongside it in the same batch.
         If no confident replacement is found, pause it anyway and leave the
         ad group thinner rather than pad it with a weak pick. Flag if this
         drops the ad group below 2 keywords (R-STRUCT-2 territory).
  NO (ELIGIBLE, or RARELY_SERVED for only 1 check so far) -> PASS, no action.
```

Requiring 2 consecutive checks, not 1, matters: brand and other naturally low-volume keywords can show
RARELY_SERVED intermittently without it indicating a phrasing problem. Requiring persistence avoids
false-positive churn on keywords that are working as intended.

**R-STRUCT-1, >=2 sitelinks account-level.** Monthly (live), every validation (pre-launch).

```
Count active account-level sitelinks. >= 2 -> PASS. < 2 -> FAIL, create sitelinks.
```

**Launch completeness: zero PAUSED descendants.** Mandatory, synchronous, part of the launch gate itself
(not cadence-gated like the monthly checks below): run every time before a campaign's status is set to
live.

```
Campaign status = ENABLED?  NO -> FAIL, not actually launched.
Count PAUSED ad groups beneath it: must be 0.
Count PAUSED ads beneath it: must be 0.
  Any found -> FAIL ("Campaign shows ENABLED but {n} ad group(s)/{n} ad(s)
    beneath it are still PAUSED. The campaign is not actually serving. Enable
    them before marking it live.")
  Zero found -> PASS.
```

Why this exists as its own gate: new ad groups and ads are created PAUSED by default as a safety measure,
so a campaign can show ENABLED at the top level while everything underneath is still PAUSED. This has
produced a real incident: an account logged as "live" and serving zero impressions for a full day before
anyone noticed. The normal monthly structural cadence would eventually catch it, but only on the next pass,
too late to matter for a launch-day check.

**R-STRUCT-2, >=2 ad groups per campaign.** Monthly, both modes.

```
Count enabled ad groups per enabled campaign. >= 2 -> PASS. < 2 -> FAIL, add an ad group.
```

**Before pausing an entire ad group:** check what it does to this count first. If a campaign has exactly 2
ad groups, pausing one drops it to 1 and fails this check the moment it's next checked. Flag this before
acting, not after. Real-world precedent: one org's brand campaign had exactly 2 ad groups, and one of them
had degraded to nothing but confirmed-RARELY_SERVED keywords. Pausing it was the right fix for keyword
health but put that campaign at 1 ad group, a known, accepted structural gap held until a replacement ad
group could be designed, not a silent regression.

**R-STRUCT-3, >=2 ads per ad group.** Monthly, both modes.

```
Count enabled RSAs per enabled ad group. >= 2 -> PASS. < 2 -> FAIL, create an RSA.
```

**R-STRUCT-4, specific geo-targeting.** Monthly, both modes.

```
Enabled campaign has at least one positive location criterion?
  YES -> PASS.  NO -> FAIL, set geo-targeting.
```

**R-BID-1, Smart Bidding required.** Weekly (raised from monthly: a capped strategy costs performance every
day it persists), both modes.

```
Strategy in {Maximize Conversions, Maximize Conversion Value, Target CPA,
Target ROAS} -> PASS. These four are exempt from the $2.00 CPC cap.

Strategy = Maximize Clicks
  -> WARN ALWAYS, even inside a bootstrap window. Not exempt from the $2 cap;
     a live performance defect, not a neutral early state.
  -> ESCALATE if the bootstrap window exceeds 30 days.
  -> FAIL if there is no documented bootstrap reason at all. An unexplained
     Maximize Clicks campaign is an unmanaged defect.

Strategy = Target Impression Share
  -> FAIL. Also $2-capped: it optimizes for visibility, not conversions, so
     it falls outside the exemption. Measured on one mature account, a Brand
     campaign on this strategy took 62% impression share and lost 38% to
     rank, while an equivalent Brand campaign on Maximize Conversions took
     100% with 0% lost.

Strategy = Manual CPC or Enhanced CPC
  -> FAIL. Also $2-capped, and separately non-compliant.

Target CPA set while account spend utilization < 60%
  -> WARN. A cost ceiling on an underspending account suppresses serving by
     causing the algorithm to decline auctions rather than overspend it.
```

Why this runs weekly: the $2 cap applies to Maximize Clicks, and a grant ad already ranks below every paid
ad in the dual auction. A capped campaign is close to structurally non-serving, and the symptom presents as
a keyword, budget, or Quality Score problem. See `auction-model.md` and `low-impressions.md` Stage 3.

**R-WEB-1, disapproved ads.** Weekly, live audit.

```
Any ad with approval status = DISAPPROVED -> FAIL each. Fix or remove, including
the specific policy-topic reason.
```

**R-WEB-1, broken landing page URLs.** Monthly, live audit.

```
For each enabled ad's final URL: HTTP GET it.
  200 + HTTPS + page loads -> PASS.
  Otherwise -> FAIL. Pause the ad immediately and flag the broken URL.
```

**R-HUMAN-1, annual survey reminder.** Check quarterly whether the window is approaching. Flag only, never
attempt to complete it: "Ensure the annual Ad Grants program survey is completed when sent. Verify the
account's login email is opted in to receiving the platform's emails."

**R-HUMAN-2, advertiser identity verification.** When detected. Flag only, never attempt to complete it: if
the account status shows a pending verification deadline, flag it immediately. The verifying individual
must be an officer of the org whose name, address, and ID match incorporation documents.

## Grace-period handling

```
months_elapsed = (today - account_start_date) in months

if months_elapsed < 2:
  grace_period = ACTIVE
  P1-A: monitor and report, do not classify as FAIL
  Do not activate the emergency brake
  Do not flag as a disablement risk

if months_elapsed >= 2:
  grace_period = EXPIRED
  P1-A enforced normally; emergency brake eligible
```

## Emergency brake activation

When P1-A returns FAIL (CTR below 5%, past grace):

```
EMERGENCY BRAKE ACTIVATED

This pass does COMPLIANCE SURGERY ONLY:
  Skip all optimization (budget changes, keyword expansion, ad testing).
  Run only: keyword pauses, match-type tightening, negative additions, ad
  relevance fixes.
The brake releases when account CTR exceeds 7%, not bare 5%.
Treat this account as top priority until it releases.
```

**Do not run `low-impressions.md`'s triage playbook while the brake is active.** A braked account is
deliberately shedding impressions; raising them fights the very fix in progress. Finish the surgery,
release the brake, then diagnose spend.

## Fix routing

| Violation | Fix |
|---|---|
| Keyword pause (QS, single-word, generic, CTR surgery) | Pause the keyword |
| RARELY_SERVED keyword (2+ consecutive weeks) | Pause it; create a broader replacement (`keyword-doctrine.md`) |
| Match-type tightening | Edit the keyword's match type |
| Broad-match keyword missing its gate annotation or paired negatives | Hold; don't ship until both are present (`keyword-doctrine.md`) |
| Negative keyword addition | Create the negative (`search-terms.md`) |
| Disapproved ad | Edit or remove the ad |
| Ad creation (< 2 per ad group) | Create an RSA |
| Sitelink creation (< 2) | Create sitelinks |
| Ad group creation (< 2 per campaign) | Add an ad group (`architecture.md`) |
| Geo-targeting fix | Set a location criterion (`architecture.md`) |
| Bidding-strategy fix | Switch strategy (`bidding.md`) |
| Conversion-tracking fix | `conversion-ladder.md`, or flag as a website dependency |
| Landing page fix | Flag as a website dependency |
| Human tasks (survey, verification) | Flag as a reminder, never complete it yourself |

All compliance-driven fixes carry top priority and execute before any optimization change in the same pass.

## Output

A compliance report: each check's invariant code, result (PASS/WARN/FAIL), detail, and the fix if
applicable; run before anything else in the pass. The emergency-brake state and the grace-period status,
so the rest of the pass knows whether the CTR floor is currently enforced.

```markdown
## Compliance report
Date: {date} | Grace period: EXPIRED (account start: {date})
Emergency brake: INACTIVE

| Check | Result | Details |
|---|---|---|
| P1-A CTR | WARN | 6.1% - below 7% buffer. 2 surgical targets identified. |
| P1-B Conversions | PASS | 8 real conversions MTD |
| R-KW-1 Single-word | PASS | No violations |
| R-KW-3 QS 1-2 | FAIL | 1 keyword at QS 2 |
| RARELY_SERVED detection | WARN | 3 keywords RARELY_SERVED 2+ weeks, routed for replacement |
| R-STRUCT-1 Sitelinks | PASS | 4 active |
| R-STRUCT-2 Ad groups | PASS | All campaigns >= 2 |
| R-STRUCT-3 Ads | PASS | All ad groups >= 2 |
| R-STRUCT-4 Geo | PASS | All campaigns targeted |
| R-BID-1 Bidding | PASS | Smart Bidding on all campaigns |
| R-WEB Disapproved | PASS | No disapproved ads |
| R-WEB URLs | PASS | All landing pages reachable |
```
