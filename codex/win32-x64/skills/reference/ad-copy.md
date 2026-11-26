# Ad copy: RSA construction and revision

Ad relevance is the second front-line CTR and Quality Score lever, after keyword screening
(keyword-research.md) and before negative keywords (guardrails.md). Write ads in the organization's own
voice, mapped to the ad group's landing page.

## RSA construction

Each ad group gets at least 2 RSAs (R-STRUCT-3). Google assembles ads from the pool you provide, showing
2-3 headlines and 1-2 descriptions per impression, so more diverse, non-redundant inputs mean more
combinations to test and higher ad strength.

| Element | Count | Character limit |
|---|---|---|
| Headlines | 10-15, use all 15 | 30 characters each |
| Descriptions | 4 (max 4) | 90 characters each |
| Final URL | 1, the ad group's landing page | - |

**Use all 15 headline slots.** Every unused slot is discarded optimization capacity; the count is a floor,
not a target to stop short of.

## Headline mix

Distribute headlines across six categories so repetition is structurally difficult:

| Category | Count | Purpose | Example |
|---|---|---|---|
| Keyword-matching | 3-4 | mirrors the ad group's primary keyword; direct ad-relevance QS lever | "Emergency Shelter Near You" |
| Benefit-driven | 3-4 | what the searcher gets | "A Warm Bed Tonight" |
| CTA | 2-3 | tells the searcher what to do | "Get Help Now", "Donate Today" |
| Location-specific | 1-2 | service area, boosts local relevance | "Serving the Tri-County Area" |
| Credibility | 1-2 | trust signal | "Serving Families Since 2015" |
| Org name | 1 | brand recognition, in every campaign, not just Brand | "[Organization Name]" |

Rules:
- At least 3 headlines should include the ad group's primary keyword or a close variant, and the first
  few headlines should mirror the keyword: this is the strongest single driver of the expected-CTR and
  ad-relevance components.
- No two headlines may make the same claim in different words ("Help Families in Need" and "Support
  Families in Need" are the same headline; cut one). Check both within the ad and across every other ad
  group in the account: identical or near-identical headline text reused verbatim in another ad group
  produces served ads that repeat themselves.
- No ALL CAPS, no excessive punctuation, no clickbait.
- Include one headline carrying the organization's name in every campaign, not only Brand. Most
  impressions are never clicked; the impression itself carries brand value (see auction-model.md), so the
  name should show even when the click doesn't happen.

## Pinning

Pinning locks a headline to a fixed position and removes it from Google's combination testing. Heavy
pinning is the most common cause of an ad stuck at "Average" strength.

**Pin exactly one headline, carrying the organization's name, to position 1 or 2. Pin nothing else.**
Pinning nothing risks the org's name never appearing in a served ad; pinning several strangles testing.
One pin buys the naming guarantee at the smallest cost to ad strength.

Additional pins are permitted only for a legally required disclaimer or a phrase the organization
contractually requires to always appear. Never pin more than 2 headlines in a single RSA. Do not pin a
DKI headline (below): pinning forces it into every impression, including the ones where the inserted text
reads badly.

## Descriptions

| Description | Focus | Example |
|---|---|---|
| 1 | What the org does + primary CTA | "We provide free groceries to families in need. Visit us anytime or call for help." |
| 2 | Who it's for + differentiator | "No income verification required. Fresh produce and pantry staples every week." |
| 3 | Specific detail from the landing page | "Open six days a week, with home delivery for seniors and people with disabilities." |
| 4 | Credibility + secondary CTA | "Serving the community since 2015. Find a distribution site near you." |

Each description must be substantially different from the others, include at least one CTA across the
four, and reference specific detail from the landing page (this improves post-click relevance and Quality
Score). Stay under 90 characters: Google truncates rather than wraps.

## Dynamic keyword insertion (DKI)

Syntax: `{KeyWord:Default Text}`. The default text shows whenever the matched keyword won't fit, so it
must read as a complete, sensible headline on its own.

Use only when: the ad group's keyword list is tight and every keyword reads well as a headline; match
types are phrase/exact, or broad with a mature negative list; a human has read every keyword in the ad
group and would be comfortable showing each one to the organization.

Do not use when: the ad group runs broad match with a thin negative list (Google inserts whatever it
matched, which may not be what was written); any keyword could read oddly or offensively in a headline (a
real risk in health, crisis, and bereavement verticals); the ad group bids on a competitor or third-party
name (their name would get inserted into this org's ad); or DKI would be the only keyword-mirroring
mechanism in the ad. Use it as one headline among 15, never as the whole relevance strategy: if DKI is
doing all the relevance work, the underlying ad is weak and fails the moment DKI can't fire.

## The mirror test

Run before shipping any RSA, and again whenever a Quality Score diagnosis (quality-score.md) routes an ad
group here.

1. Does the KEYWORD appear in the AD? If someone types the keyword, do they see those words in a
   headline? If not, add keyword-matching headlines.
2. Does the AD's promise appear on the LANDING PAGE? If the ad promises an action, is that action visible
   on the page it lands on? If not, the ad is overpromising or the URL is wrong.
3. Does the LANDING PAGE serve the INTENT behind the keyword? Someone searching "free food near me" needs
   a page about receiving food, not a page about donating food. Words can match while intent does not.

When everything mirrors, Quality Score, CTR, and cost per click improve together, because all three
measure facets of the same alignment. A failed mirror test blocks launch at setup, and is a standing
optimization finding on a live account.

## Search-term language as copy input

The search-terms report supplies the actual words people used when they converted: the highest-quality
copy input available, because it's evidence, not a guess. Add phrasings that converted as search terms,
especially where they differ from the org's own vocabulary ("Food Assistance Program" internally vs.
"free food near me" from converters: the searchers are right). Remove headline phrasings that show
consistently poor CTR or zero conversions as search terms; language that doesn't convert as a search term
is unlikely to convert as copy. RSAs make this cheap, since Google discards underperforming assets
quickly, so testing a variant costs little.

## Ad strength

Google rates RSA ad strength Incomplete -> Poor -> Average -> Good -> Excellent. **Target Good or
Excellent**, which requires 10+ genuinely diverse headlines, keywords included in headlines, unique
(non-repetitive) descriptions, and a real mix of headline types. If strength is below Good after
drafting: add more keyword-matching headlines, remove any two headlines that say the same thing
differently, add a location headline if missing. Ad strength measures input diversity, not outcome, but
Google rewards it with more impressions, which matters under a fixed grant budget.

Two operational gotchas:
- **`ad_strength` is asynchronous.** A freshly created ad reads `PENDING` with
  `review_status: REVIEW_IN_PROGRESS` right after creation; the real grade only populates once Google's
  policy review finishes, which is hours to a day, not seconds. Don't expect same-session verification.
- **No tool edits an existing RSA's headlines or descriptions in place.** Improving an "Average" ad means
  creating a new replacement RSA (`ENABLED`) and pausing the old one, never editing in place. Google caps
  **enabled RSAs at 3 per ad group**: when replacing both ads in a standard 2-ad ad group, add one new ad
  (3 enabled), pause one old ad (back to 2), add the second new ad (3 again), pause the last old ad (back
  to 2). Adding both replacements before pausing anything fails with `RESOURCE_COUNT_LIMIT_EXCEEDED`.

## Voice and don't-say discipline

Write in the org's own voice: use its actual words from its own site and messaging, use its tagline
verbatim if it fits in 30 characters, write like a real person at the org would talk about the work, be
specific ("Free groceries for families nearby" beats "Helping those in need"), be warm and direct.

Avoid: AI-template language ("Unlock your potential," "Transforming lives," "Making a difference"), em
dashes (they waste characters and read templated), buzzwords ("innovative," "cutting-edge," "holistic,"
"synergy"), excessive formality, and fluff. Every word earns its 30-character slot.

Check every draft headline and description against the org's don't-say list before proposing it (common
ones: pity framing like "poor" or "unfortunate"; deficit language like "the homeless" or "the needy";
anything the org has flagged as sensitive). If a term matches, reject and rewrite without it: "Help the
Homeless Near You" fails the check; "Help People Find Shelter Near You" passes.

## Landing-page mapping

Every ad's final URL must be a working page on the organization's own site, relevant to the ad group's
keyword theme, and the same page used by every other ad in that ad group. Never point an ad at an
external site, a broken page, a generic page unrelated to the ad group's theme (the homepage for a
"Youth Mentoring" ad group when a dedicated program page exists), or a different URL than the ad group's
other ads use. If a landing page goes down or changes materially, update the final URL or pause the ads
until it's restored.

## Revising a live ad group

Triggered by low CTR, low ad strength, or a Quality Score component diagnosis (quality-score.md) flagging
expected CTR or ad relevance as below average.

1. Identify the weakest headlines: highest impressions with lowest CTR, or headlines Google rarely shows
   (it suppresses low performers).
2. Draft replacements following the rules above; if the trigger is a QS diagnosis, draft new
   keyword-matching headlines specifically.
3. Screen replacements against the don't-say list.
4. **Never replace all headlines at once.** Replace 3-5 at a time and keep proven performers (high
   impressions and high CTR).
5. With 2 RSAs per ad group, treat one as a control (unchanged) and one as the test (updated); compare
   after 2-4 weeks.
