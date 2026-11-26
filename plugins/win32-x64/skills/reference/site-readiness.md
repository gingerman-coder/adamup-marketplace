# Site readiness: what the website must support

The website standard an Ad Grants account depends on, and the checks that catch a site-side constraint
before it gets misdiagnosed as an ads problem. Several of the most common "the ads aren't working"
findings aren't ads findings: there's no landing page that answers the searcher's question, the page is
too thin for Quality Score, the thank-you page doesn't exist, or the site is one level deep so nothing can
be tracked. Those are website constraints, and no amount of keyword or bidding work fixes them. Naming
them as website findings gets them to whoever can actually resolve them.

## The floor vs. the standard

There is a compliance floor (R-WEB-1): HTTPS, substantial original content, working links,
mobile-friendly, reasonable load speed, no ad-monetization-primary pages. Below it, the grant is at risk.
This file defines the **working standard**, which sits higher: a site can be perfectly compliant and still
unable to support a functioning grant account.

## The promotable-page standard

A **promotable page** is one an ad can legitimately point at:

```
- is about ONE topic
- has 300+ words of real content on that topic
- names the thing a searcher would call it, in their own words
- has a clear call to action
- is not a PDF
- is not the homepage
- loads fast and works on mobile
```

**Target: 10 or more promotable pages.** Below that, the account can't support meaningful ad-group
segmentation, because every ad group needs its own aligned landing page, and two ad groups sharing a page
is a compromise, not a design.

### Count them up front

```
10+   -> the site can support a full account. Proceed.
5-9   -> the account will be small. Build fewer, tighter ad groups, and
         flag the content gap as the main constraint on account growth.
<5    -> the site is the binding constraint, full stop. A bigger account
         won't help. Raise this BEFORE campaign design, not after the
         account underperforms.
```

Recount whenever the org reports a site update.

### Disqualifiers worth naming

| Not promotable | Why |
|---|---|
| **PDFs** | Can't carry tracking, poor mobile experience, no navigation, weak Quality Score. Never use a PDF as a final URL. A PDF *download* is a fine conversion; a PDF *landing page* is not. |
| **The homepage** | Serves every intent and therefore none. Homepage-as-final-URL is the single most common Quality Score defect industry-wide. |
| **Thin pages** (<300 words) | Google reads them as low-value; Landing Page Experience suffers, which suppresses ad rank in an auction where outbidding the problem isn't an option. |
| **Pages behind a login** | Not crawlable, not reachable by an ad clicker. |
| **Third-party redirect pages** | See below. |

## Conversion-tracking prerequisites

Two separate requirements, because bidding and compliance need different things.

```
FOR BIDDING (lifts the $2.00 cap) -- effectively always satisfiable:
  Any page the tag fires on, including a campaign landing page. A page one
  level deeper is preferred where one exists, but is NOT required (see
  conversion-ladder.md).

  The only way to fail this is having no tag access at all. If tag
  placement is genuinely blocked, escalate: the account can't escape the
  $2.00 CPC cap. That's the single most consequential site finding there
  is, and it's rare.

  VERIFY IT RATHER THAN ASSUMING IT. A tag configured in Google Ads is not
  a tag on the website; the two are independent facts, and only the second
  makes conversions fire. Verify by re-fetching rendered HTML and network
  requests (see conversion-ladder.md), not by asking whether it was
  installed. A useful cross-check:

      SELECT customer.conversion_tracking_setting.conversion_tracking_id
      FROM customer

  gives the AW-id to search for in the site's actual served output. It is
  entirely possible for an account to pass every account-side check while
  zero tag exists anywhere on the live site; the two checks are
  independent and both are required.

FOR P1-B (keeps the account alive) -- at least one of:
  - a distinct thank-you / confirmation page reachable ONLY after an action
  - a form submission event definable via tag manager or analytics
  - an outbound-click event on a donate/apply button
  - a tel: or mailto: link that can carry a click event
  - a file download that can fire an event

  If NONE of these exist, the account has no meaningful conversion and is
  on a direct disablement track. Escalate as blocking on compliance. Do
  not activate a new build until a real meaningful action is tracked alongside
  the verified bidding primary. A page view cannot substitute for it.
```

### The third-party redirect trap

Where a form, ticket sale, or donation completes on a third-party platform, the confirmation page lives on
**their** domain, not the org's. A tag on the org's own site never sees it.

```
CONSEQUENCE: a conversion action pointed at the org's own domain will never
fire for that action.

FIXES, in order:
  1. Place a conversion tag on the processor's side, or point the
     conversion at a post-transaction URL the processor exposes. Many
     platforms allow this with no change to the org's own site.
  2. Track the outbound click on the button that sends people there.
     Intent rather than completion, but real, and it can serve as the
     P1-B basis.
  3. If neither is available, find a different real micro-action on the
     site for P1-B (tel:, mailto:, download, newsletter).

The client-side page that links out (e.g. /donate) is still a perfectly
good target for the PAGE-VIEW BIDDING conversion. It just isn't a
meaningful conversion, so it can't be the P1-B basis and must not be
labeled a completed donation.
```

### The one-level-deep site

Some nonprofit sites are a homepage plus a handful of flat pages, nothing to click through to below them.

**This is no longer a problem for bidding.** Point the page-view conversion at a campaign landing page and
move on; the flat-site case is exactly why the deeper-page preference is a preference, not a gate.

```
It still matters for P1-B. Options, in order:
  1. A tel: or mailto: click, which most such sites do have.
  2. A form submission event via tag manager, even with no thank-you page.
  3. A file download that can fire an event.
  4. Ask the org to add ONE real action or confirmation page: an
     eligibility checker, a newsletter signup, a downloadable guide. A
     small ask with a large payoff.
```

## Speed and experience

| Check | Standard | Tool |
|---|---|---|
| Page speed | 50+/100 as a floor; higher is better | PageSpeed Insights |
| Mobile | Genuinely usable, not merely responsive | Manual check on a phone viewport |
| Broken links | Zero on any page used as a final URL | Automated: the engine's `snapshot` precheck GETs every enabled ad's final URL and flags any that does not return HTTP 200 (`precheck.broken_landing_urls`). Broken "pretty" URLs silently waste budget and get ads disapproved; repointing a final URL does not reset ad learning. Checked each pass per R-WEB-1. |
| HTTPS | Sitewide, no mixed content | R-WEB-1 |
| Intrusive elements | No interstitials, no autoplay, no slow carousels above the fold | Manual |

**Slow pages cost twice:** they depress Landing Page Experience (which suppresses ad rank, which costs
impressions that can't be bought back) and they lose the visitor who did click. In a grant account the
first cost is the larger one.

**Optional but useful:** free session-recording tools show what ad traffic actually does after landing.
Worth trying on a landing page that underperforms with no obvious cause.

## The demand-side content gap

The most consequential site finding, and the one most likely to be missed because it doesn't look like a
defect. Nearly all the search volume sits on demand-side queries: what the organization *does*, the
problems it solves, the questions people ask (`keyword-doctrine.md`). Those keywords need pages that
answer them.

```
For each demand-side keyword theme, does a page exist that actually
answers it?

An organization whose site is entirely ABOUT the organization -- mission,
history, board, ways to give, annual report -- has no demand-side landing
pages. Its keywords have to be supply-side, which is where the volume
isn't.
```

This is a content gap, not an ads gap. The fix is usually a handful of pages answering real beneficiary
questions, and it's often the highest-leverage thing the org can do for its own grant account. Raise it as
a specific, small, actionable ask: "three pages answering these three questions people actually search"
is something an org can act on. "Improve your website" is not.

**This also gates two automation features.** Dynamic Search Ads and AI Max final URL expansion both let
Google choose the landing page automatically. Both require the site to *have* good pages, and on a thin
site both make things worse by sending traffic to whatever is least bad. Don't enable either on a site
that fails this section.

## Output

Site readiness produces a finding, not a change; nothing here is fixable inside Google Ads.

```
SITE READINESS
  Promotable pages:         {n}  (target 10+)
  Tag deployed on live site: {pass/fail, pages checked}
  Conversion prerequisites: {which of the required list exist}
  Page speed (worst LP):    {n}/100
  Demand-side coverage:     {which keyword themes have no answering page}

  BLOCKING:     {anything preventing conversion-based bidding}
  CONSTRAINING: {anything capping account size}
  ASK:          {the specific, smallest request for the org to act on}
```

Record it in the account's profile at setup (`<engine-returned data_dir>/profile.md` if using the standard
layout), and recheck quarterly or whenever the site changes.
