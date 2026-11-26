# Conversion tracking: the tiered ladder

A campaign cannot escape the $2 CPC cap without conversion-based bidding, and conversion-based bidding
needs a conversion action. So conversion tracking is a hard launch gate. Run these tiers in order and
stop at the first that works. Prefer the earliest tier possible; each later tier costs the user more.

Verify every step by **re-fetching rendered HTML and network requests**, never by asking "did it work?"
A curl check can prove a tag present, never absent: GTM injects at runtime and GA4 sends `/g/collect`
beacons rather than script tags.

Each Google API method below is exposed as a named engine tool; use the engine tool, the raw method name is
given only so the mapping is unambiguous. Discovery helpers: `ga4_account_summaries` (find the GA4 account
and its properties), `ga4_data_streams` (find the web stream and its measurement id), `ga4_key_events_list`
and `ga4_google_ads_links_list` (see what already exists before creating), and `tag_destinations_list` (see
what a Google tag already measures).

## Tier 0.5 - site already has any Google tag
Add GA4 or Ads measurement as a **destination** on the existing Google tag container via `destinations.link`
(engine: **`tag_destinations_link`**; list first with **`tag_destinations_list`**). **Zero site edits.** A
Google tag container is not a GTM container: no versions, no publish step, managed through `destinations`.
This collapses the hardest onboarding case for a large population.

## Tier 1 - GA4 property exists (the default; prefer it)
Zero site edits, fully API-automatable, proven live 2026-09-16:

1. `googleAdsLinks.create` (engine: **`ga4_google_ads_links_create`**) links the GA4 property to the Ads
   account (`analytics.edit`; `customer_id` immutable on create). A pending-approval state does not occur when
   one person holds edit on the property and admin on the account, which is the normal single-nonprofit case.
2. `keyEvents.create` (engine: **`ga4_key_events_create`**) creates the key event.
3. Google auto-surfaces it in Ads as a conversion action with `status = HIDDEN` **within seconds**.
4. **Import = flip `HIDDEN` -> `ENABLED`** via `conversionActions:mutate`. On that mutate you may also set
   `primary_for_goal`, `category`, `name`, `value_settings`. Anything else returns `MUTATE_NOT_ALLOWED`.

**Importing is not creating.** Creating a `GOOGLE_ANALYTICS_4_CUSTOM` action directly fails with
`CREATION_NOT_SUPPORTED`, and `GoogleAnalytics4Settings` is output-only. This path is strictly better than
`WEBPAGE_CODELESS`, which cannot be mutated at all, so promoting/demoting a primary stops being a UI round
trip.

Check that the chosen key event **has volume** (GA4 Data API `properties.runReport`, engine:
**`ga4_run_report`**, or the purpose-built **`ga4_event_has_volume`**; needs `analytics.readonly`) before
relying on it. A key event that never fires records nothing; that is exactly how an account ends up with zero
conversions for months.

## Tier 2 - known platform
Follow `platform-tag-install.md`: detect the platform from the site's HTML, fetch the GA4 measurement ID
from the API, then **add it for them in the browser** after they sign in to their site builder themselves
(Wix, Squarespace, WordPress, Webflow). Hand-authored manual steps are the fallback. Never code where
avoidable. Never model-generate a snippet. Then
verify in a loop and finish with Tier 1.

## Tier 3 - nothing works
Record the blocker and keep campaigns PAUSED. Creating an action does not prove tracking. A bare site
with no GA4 and no GTM may need a visit to analytics.google.com or tagmanager.google.com for the account
shell. Preserve the paused proposal and resume setup when a verifiable tracking path is available.

## Activation evidence

Use engine-owned tracking evidence bound to the selected customer and primary conversion action: live URL,
observation time, and the matching event label/beacon or measured GA4 event volume linked to the Ads action.
A base tag alone, action creation, or user self-report is insufficient. Exactly one low-value phase-1
page-view primary with `ONE_PER_CLICK` is permitted, including a campaign landing page. Track a separate
real meaningful action for monthly compliance. The snapshot persists account-bound Ads observations: a firing enabled primary and a separate meaningful
action defined, observed within 24 hours. Site evidence supplements this gate and cannot override it.
Do not inject tracking fields through state updates. If the gate is unavailable or rejected, leave campaigns
PAUSED. Activation always needs separate explicit approval.

All GA4 and tag writes use the engine preview/confirmation flow with customer/property/container binding;
raw API method names below describe semantics, not a direct-write bypass.

## Which wizard path yields WEBPAGE vs WEBPAGE_CODELESS (tiers 2-3, the no-GA4 world)

When there is no GA4 to import from and you fall back to a Website conversion action in the Ads UI, the
wizard forks, and the two paths are not equivalent:

- **The site-scan path returns `WEBPAGE_CODELESS`.** It carries a `URL contains <domain>` rule and needs no
  code, but it **can never be modified through the API** (`MUTATE_NOT_ALLOWED`), so its primary/secondary
  status must be set in the wizard at creation, and every later change is a UI round trip.
- **The "add manually" path returns `WEBPAGE`.** It has no URL rule and records nothing until an **event
  snippet** is deployed on the site, but once created it is mutable through the API.

**Prefer `WEBPAGE` plus a deployed snippet for the one conversion you expect to promote and demote** (the
primary bidding conversion), precisely because you will want to change its status later without a UI trip.
Codeless stays a fine default for secondary actions you will not touch again.

**Verify a Website action via the event LABEL, not the base tag alone.** The base Google tag being present on
the site proves the tag loads; it does not prove the specific conversion event fires. Confirm the event label
in the rendered output or the `/g/collect` beacons, the same verify-loop discipline as the tiers above.

## MCP note
`get_conversion_actions` must include `HIDDEN` and `REMOVED` (a status filter or dedicated tool). Those
are exactly the rows tier 1 operates on; a version that hides them cannot run the ladder.
