# Assets: sitelinks, callouts, snippets, images and logos

Assets are among the least restricted parts of an Ad Grants account and among the most underused:
completeness here is cheap performance, because it acts directly on how much of the results page the ad
occupies once it wins a slot in the residual auction (auction-model.md). Audit coverage on every pass;
assets are commonly built once and never revisited, and a missing logo or a stale sitelink costs
impressions quietly.

## Sitelinks

Minimum 2 active sitelinks at the account level (R-STRUCT-1); below that the account risks deactivation.
Target 6-8, each with both description lines populated.

Each sitelink: link text (25 characters max, action-oriented), description line 1 (35 characters max),
description line 2 (35 characters max), and a final URL distinct from the main ad's landing page and from
every other sitelink (sitelinks add options, they don't duplicate the ad).

Cover the org's main actions (donate, programs, volunteer, about, contact, get help) based on what pages
actually exist. No generic text ("Click Here," "Learn More" waste the slot): use specific labels ("Donate
Now," "Our Programs," "Volunteer With Us"). Sitelinks apply account-level (all campaigns) unless a
specific campaign needs its own.

## Callouts

Not a compliance requirement, and a healthy account can run with zero, but they're a cheap, legitimate
Quality Score input worth building. Callouts are short, non-clickable text (25 characters max) shown
below the ad; Google selects which to show per impression.

Target 8-10. Be specific ("Free Services" beats "Great Services"), use facts (hours, years operating,
service details), and don't duplicate sitelink text. **Mix categories rather than clustering similar
messages**: spread across trust (years operating, credentials), cost (free, no fees), accessibility
(hours, no ID required, languages), and impact (people served, outcomes). A set that's all "trust"
signals wastes slots Google could use to cover a different angle. Account-level.

## Structured snippets

A header (from Google's predefined list; relevant ones for a nonprofit are "Service catalog,"
"Neighborhoods," "Types") with 3-10 values, each 25 characters max. Choose the header that matches the
org's actual strengths: a multi-program org uses "Service catalog," a metro-area org uses
"Neighborhoods." Values come from the org's actual program names, not invented categories. Account-level
unless a campaign warrants its own.

## Image assets

Attaching a photo increases the ad's physical size on the results page and its share of attention: one of
the few levers available when the ad's rank and position are otherwise fixed by the auction. Target up to
10 images, covering multiple aspect ratios: square 1:1 is required, landscape 1.91:1 and portrait 4:5 are
rewarded.

Source real photography of the org's work, people, and place; stock imagery reads as generic and
undermines the trust a nonprofit ad depends on. No text overlaid on the image (Google restricts this and
it renders badly at small sizes), no collages, no logo inside the image. **Confirm documented consent for
any identifiable person, especially a service recipient**: this is a real safeguarding question, not a
formality. Never use a photo of a beneficiary without confirmed permission; when in doubt, use staff,
volunteers, facilities, or events instead.

## Business name and logo

Supplying the org's exact public name and a logo turns a plain text ad into a branded one; both are
one-time and commonly skipped. Business name: exactly as the public knows it, matching the website and
Google Business Profile. Logo: square 1:1 required, landscape 4:1 recommended, transparent or white
background.

**Both are gated on advertiser identity verification**, a human-only step requiring an officer of the
organization: start it early rather than discovering it as a blocker later. The day verification clears,
set business name and logo immediately. Verification clearing and nobody going back to configure them is
the most common way this lever stays at zero indefinitely.

## Call and location assets

A call asset (phone or WhatsApp number in the ad) may not be automatable through every Ads API surface;
where it isn't, add it by hand in the UI (Assets -> + -> Call) and track it as a pending manual step, not
a completed build item. Apply it only to campaigns where a call is a plausible next action, and **only if
the line is actually staffed**: a call asset pointed at voicemail turns a promising click into a dead
end. If the org has defined phone hours, schedule the asset to match them.

A location asset links the account to the org's Google Business Profile so ads can show an address, map
pin, and distance from the searcher. Required for any org with a physical location the public visits, and
required for any PMax campaign meant to reach Google Maps: no location asset means no Maps placement,
which is the main reason a local nonprofit runs PMax at all. Precondition: a claimed and verified Google
Business Profile.

## Coverage target

| Asset | Target | Floor |
|---|---|---|
| Sitelinks | 6-8 | 2 (account-level, R-STRUCT-1) |
| Callouts | 8-10 | none, but always populate |
| Structured snippets | 1-2 headers, 4-10 values each | none |
| Images | up to 10 | none |
| Business name | 1 | requires advertiser verification |
| Logo | 1 square, 1 landscape | requires advertiser verification |
| Call asset | 1, where a call is a plausible next action | manual step if not API-supported |
| Location asset | 1, for any org with a physical presence | required for PMax on Maps |

A larger ad earns a higher CTR; a higher CTR raises the expected-CTR Quality Score component; a higher
Quality Score raises Ad Rank; Ad Rank decides how much of the residual auction's leftover inventory the
account wins (auction-model.md). Assets buy clicks directly and impressions indirectly: finish this table
before proposing any other optimization.

Negative keywords are covered in guardrails.md (auto-applied, including the negative-exact CTR
instrument) and recommendations-catalog.md (search-terms -> negatives); this file doesn't duplicate that
list.
