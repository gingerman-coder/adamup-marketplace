# Automation governance: why Google's recommendations are not neutral

Two risks that sit outside the compliance invariants because they come from *how this tool operates*, not
from what Google requires. Both can cost the grant.

---

## Part 1: the asymmetry of automated writes

**The grant is not replaceable on demand.** If the account is suspended or restricted, the organization
loses the whole $10,000/month channel, not one campaign. Reinstatement takes 3 to 10 business days at best,
during which the account gets nothing, and severe or repeated violations can end in permanent cancellation
with limited appeal.

Set against that: the upside of any single optimization is marginal. A better keyword set moves spend by
some percentage. A suspension moves it to zero.

**The payoff is asymmetric, so the caution should be too.** This is the governing principle for a tool with
write access to an account it does not own.

### What this means in practice

```
This tool operates automated writes against an account it does not own, under a
grant that cannot be reissued on demand. Therefore:

1. PREFER REVERSIBLE ACTIONS.
   pause over remove (removal is blocked at the server level outright).
   Adding negatives over deleting keywords.
   A settings change that can be reverted over a structural change that cannot.

2. PREFER SMALL BATCHES.
   One structural change per campaign per pass is a performance rule AND a risk
   rule. A pass that makes one change per campaign is a pass whose blast radius
   is one change per campaign.

3. VERIFY WRITES BY READING BACK.
   The two-step confirm flow proves the API accepted the change. It does not
   prove the account is in the intended state. A campaign can read ENABLED with
   every ad group beneath it PAUSED; that alone can cost a live account a full
   day of zero impressions if it goes unchecked. Read back after any structural
   change, especially one that enables or pauses something across levels.

4. TREAT POLICY-ADJACENT CHANGES AS APPROVAL-REQUIRED, ALWAYS.
   Anything touching a keyword that could read as generic (R-KW-2), match-type
   widening, ad copy claims, or landing-page destinations is queued for the
   user's approval even when the general approval class would otherwise allow
   it to run unattended.
```

### The competence precondition

Do not let automation substitute for understanding the platform. A tool that emits plausible-looking
changes into an account nobody could audit is not leverage, it is unmanaged risk. Every proposed change
must be legible to a human who could have made the same decision manually, which is why every change object
carries a `reason` field (see `api-and-writes.md`). If a change cannot be explained in that field in terms
the account owner could be shown, it does not go out. "The model suggested it" is not a reason.

**Ad Grants management is its own discipline, not general search-ads management.** Strategies that are
correct on a normal paid account are frequently wrong here: the dual auction, the $2.00 cap on
non-conversion bidding, the structural floors, and the mission-relevance policy all change the answers.
Advice that does not account for grant-specific constraints should be treated as untested here, regardless
of how authoritative it sounds in general.

---

## Part 2: Google's own recommendations are not neutral advice

The Recommendations tab, the optimization score, and Google's "apply automatically" suggestions are **not**
an impartial audit of the account. They are Google's suggestions, tuned toward Google's objectives, and on
a grant account they frequently propose changes that waste budget or actively break compliance.

The MCP exposes `list_recommendations`, `apply_recommendation`, and `dismiss_recommendation`. The read tool
is useful. The apply tool is dangerous.

### The rule

```
NEVER auto-apply a Google recommendation. Not one, not ever, regardless of
optimization-score impact.

DO read recommendations every pass: they surface real signals (disapproved
ads, broken final URLs, conversion-tracking gaps) worth knowing about.

Route every recommendation through this tool's own rules before acting on it,
rather than accepting Google's framing of the fix.
```

**Turn off "auto-apply recommendations" in account settings.** This is a one-time setup item, and it
matters: an account with auto-apply left on can have its bidding strategy, budgets, or keywords changed by
Google without anyone's knowledge, which silently invalidates any change history and defeats drift
detection.

### Account setup checklist

One-time settings worth getting right, all easy to miss and expensive to discover late:

```
[ ] Auto-apply recommendations: OFF
[ ] Email notifications: ON for critical alerts
     Admin -> Notifications. Conversion tracking breaking, ads being
     disapproved, and policy flags should be pushed, not discovered on the
     next scheduled pass. Google communicates non-compliance mainly through
     in-product notifications, so an unmonitored notification email is a real
     risk (R-HUMAN-1 in invariants.md).
[ ] Notification email is a monitored inbox, opted in to Google's emails
[ ] NEVER use Smart Campaigns
     They hide the bidding controls, keyword-level data, and reporting this
     tool depends on, and an account running exclusively Smart Campaigns sits
     outside the normal CTR rule in a way that removes visibility rather than
     helping. Use the standard Google Ads interface; grant accounts are in
     expert mode by default, and should stay there.
[ ] No payment method attached to the grant account
     Verify on the billing page. A paid billing method on a grant account
     risks a real invoice. Keep any paid advertising as a fully separate
     account.
[ ] GA4 linked, key events imported (see conversion-ladder.md)
[ ] Google Business Profile linked, if the org has a physical location
     Required for location assets, and therefore for PMax on Maps.
[ ] Advertiser identity verification started (R-HUMAN-2 in invariants.md)
     Gates business name and logo assets. Needs a specific officer of the
     org, so start it early rather than discovering it as a blocker.
```

### Triage table

| Recommendation type | Response |
|---|---|
| Fix disapproved ads, broken URLs, missing conversion tracking | Genuinely useful. Act on it. |
| Add sitelinks, callouts, images, business name/logo | Usually useful, but apply through this tool's own asset standards rather than Google's suggested copy. |
| "Add broad match keywords" | Evaluate against the keyword rules (`keyword-doctrine.md`, `invariants.md`), never accept as-is. Google's suggested terms routinely fail R-KW-1 (single word) and R-KW-2 (overly generic), which is a policy violation here and merely a click for Google. |
| "Remove non-serving keywords" | Investigate, do not apply. Non-serving usually reflects a low-volume problem of our own, and the fix is better keywords, not fewer. Applying this shrinks the account. |
| "Switch to Maximize Clicks", Target Impression Share, or any click/visibility-based strategy | Reject outright. All are bid-capped at $2.00 (R-BID-1). Dismiss it. |
| "Set a target CPA" | Reject below meaningful budget utilization; it suppresses serving on a young or thin account. |
| "Raise your budget" | Meaningless in a grant account. Google does not model the account-level $329/campaign cap here. Check impression share lost to budget instead (Q-IS in `api-and-writes.md`). |
| "Conflicting negative keywords" | Read it, never click Apply. Google's one-click fix always deletes the negative, reopening every query it was blocking, not just the one keyword that triggered the alert. Compute the conflicts yourself and decide per keyword; the usual correct fix is the opposite of Google's. See below. |
| "Enable auto-apply" | Reject always. |
| Anything raising optimization score alone | Ignore. Optimization score is not a performance metric and not a compliance metric. |

### The conflicting-negatives alert, in detail

Worth its own note: the alert is genuinely useful, the one-click fix is genuinely harmful, and the two sit
right next to each other in the UI.

A conflicting negative is a negative keyword that blocks one of the account's own active keywords from
serving. Google's **Apply** resolves every such conflict the same way: it **deletes the negative**. That
reopens every query the negative was covering, not just the one keyword that triggered the alert.

Compute the conflicts yourself instead of clicking Apply. The three inputs are the account's keywords, its
campaign-level negatives, and its ad-group-level negatives; cross-reference them for overlap. Confirm
coverage first with:

```
SELECT shared_set.name, shared_set.type, campaign.name FROM campaign_shared_set
```

An empty result means the check saw every negative on the account directly; rows mean there are shared
negative-keyword lists to pull in too (`shared_criterion`), or the clean result is a false negative.

**Default to pausing the keyword, not deleting the negative.** Keep the negative where it protects the
campaign from a class of bad traffic; remove it only where it was genuinely too broad *and* the blocked
keyword is clearly on-mission.

A conflicting-negatives alert covering even a single keyword is not necessarily the account's real problem.
On a thin account, a handful of blocked keyword-matches is rarely what explains an account averaging a
handful of impressions a month; check impression share (Q-IS) before assuming the negative conflict is the
main cause, since computing the real conflict set takes about a minute where clicking Apply creates a new
problem.

### On optimization score

Do not report optimization score to the account owner and do not optimize toward it. It measures adherence
to Google's recommended configuration, which is not the same as account health and is sometimes opposed to
it. A compliant, well-performing grant account can sit at a low optimization score precisely because it
declines the recommendations above.

### Recording dismissals

When dismissing a recommendation, record the reason in the account's change log (see the digest/action-log
convention the `adamup` skill writes to). Google resurfaces dismissed recommendations, and without a record
each pass re-evaluates the same suggestion from scratch. A one-line note ("dismissed 'switch to Maximize
Clicks', $2 cap") saves that re-derivation permanently.

---

## Part 3: what genuinely threatens the grant

Ranked, so attention goes to the right place. `invariants.md` covers the rules in full; this is the risk
view.

| Threat | Likelihood | Severity | Mitigation |
|---|---|---|---|
| Missing the annual program survey | Moderate, easy to miss | Total loss | R-HUMAN-1. Calendar it. Confirm the notification email is monitored and opted in. |
| Failing advertiser identity verification by deadline | Moderate | Account paused | R-HUMAN-2. Start early; needs a specific officer of the org. |
| Two consecutive months under 5% CTR | Low if built correctly | Deactivation | P1-A. A well-built account runs 8-15%. |
| Zero meaningful conversions in a month | Moderate, especially with broken tracking | Deactivation | P1-B. The conversion-tracking ladder exists partly to prevent this. |
| Policy violation from generic or single-word keywords | Moderate, rises with broad match | Suspension | R-KW-1, R-KW-2, and negative pre-seeding. |
| An automated change applied wrongly | Low per change, rises with batch size | Varies | This file, Part 1. |
| Google auto-applying its own recommendations | Moderate if auto-apply is left on | Varies | This file, Part 2. Turn it off. |

**The top two are human tasks this tool cannot do on the account owner's behalf**, and they are the most
likely ways to lose a grant outright. The tool's job is to make sure they are never forgotten: surface them
well ahead of the deadline, every pass, until confirmed done.
