# Reading and writing Google Ads: the MCP contract

How reads and writes are structured against the Google Ads API. **All Google Ads I/O, interactive and
scheduled alike, goes through the tools of the `adamup-engine` MCP server**, the AdamUp Google Ads engine. It is deliberately not named `google-ads`, so it never collides with a developer's own server of that name. Resolve tool names by the installed schema and check `adamup_capabilities` before stateful work.
Use `adamup_state` for durable state; never a Python writer. The one
account read per pass is the engine's **`snapshot`** tool; the ranked change list is the engine's
**`recommend`** tool with the returned account-bound `snapshot_id`; every write is a two-step-confirmed engine tool. The scheduled weekly pass is not a
separate code path: it is the same `adamup` skill calling the same engine tools, unattended.

Reject stale/mismatched snapshot handles. Do not collect again just to recommend or append duplicate history.
GA4 and tag writes also preview and confirm with resource binding. An unavailable guard is a blocker,
not permission to call the Google endpoint directly.

The `snapshot` and `recommend` engine tools are the runtime. Their deterministic behavior is defined by a
**reference specification and offline test oracle** kept in readable Python in the private engine repo (not
shipped with this plugin): the logic is specified there, implemented in the compiled engine, and the engine's
behavior is tested against it. There is no live data path outside the engine tools. The API traps below apply to
the engine's tools, since they hit the same underlying API.

---

## Local profile operations (schema 1)

Call `adamup_capabilities` first. Require `state_schema: 1`, `snapshot_handles: true` and the operations
needed for this task. `auth_connected` describes local token presence; verify access rather than treating
it as proven consent validity. `advanced_ab_execution: true` means the `ab_*` experiment tools are available; if false, skip A/B.

`adamup_state` accepts `operation`, optional `customer_id`, and object `payload`:

| Operation | Payload and result |
| --- | --- |
| `read` | No customer needed; returns `state` and `data_root`. Other operations require the selected customer. |
| `select` | `{"confirmed": true}` after the user's account confirmation. One customer per profile; use a separately configured profile for another. |
| `update` | Supported fields only: status, stage (0..3), last_run, onboarding_progress, consent, declined_reason, telemetry_enabled, org_name, website_url, location. Never inject approval/tracking fields. |
| `authorize` | `{"confirmed": true, "operations": [...]}` after explicit standing permission. Only add_negative_keywords and pause_entity are eligible (autopilot, `autopilot.md`). Scheduled applies are further limited in code: EXACT negatives, at most 25 per plan and 10 plans a day; keyword pauses only, at most 10 a day. |
| `register_host` | `{"host": "claude"}` or `{"host": "openai"}`. Registration alone creates no schedule. |
| `schedule_claim` | Host, read-back ACTIVE scheduler_id/status, and previous_disabled on transfer. Returns incremented state.schedule_epoch. |
| `schedule_check` | Host and epoch; rejects obsolete ownership before scheduled work. |
| `pass_begin` | Scheduled: host and epoch. Manual: `{"manual": true, "confirmed": true}` after the user requests a pass. Returns state.pass_lease.id. |
| `pass_end` | `{"lease_id": "<returned ID>"}`; release only the owned lease. |
| `build_begin` | `{"confirmed": true}` after paused-build approval; bounded initial build, separate from activation. |
| `build_resume` | `{"confirmed": true}` after approval to resume the same paused build. Preserves resources and rejects unresolved outcomes until reconciled. |

Use `scrape_website` with `url` for native bounded HTML inspection. It does not execute browser scripts or
prove an event fires. A supported host browser may be needed for rendered/event checks. Reference schemas
above describe this candidate; inspect the actual installed tool before sending arguments.

---

## Access and auth

- **No developer-token header.** Google sunset developer tokens on 2026-09-09. Access level now rides the
  Google Cloud project that owns the OAuth client, not a per-call header. Do not add one; a request that
  includes it is not more authorized, and a future API version may reject it outright.
- **Pin the API version to one constant.** Some fields (`campaign.primary_status_reasons`, the
  machine-readable "why is this not serving" field) 400 on older pinned versions. Use v25. Bump the pin
  deliberately, in one place, with a test run, not by drifting.
- **OAuth only.** The account is reached via the user's own OAuth refresh token; there is no shared
  management account sitting in front of it.

---

## Known API traps

- **Never send `pageSize` in a `search`/`searchStream` request body.** It 400s the entire query, every
  time. Page through results the way the endpoint expects instead.
- **Read the error code from `error.details[0].errors[0].errorCode`, never `error.message`.** The top-level
  message is consistently the useless "Request contains an invalid argument"; the real, actionable code
  lives in `details`.
- **Use JSON output for any query with a nested field.** A selected field with a dot after the resource
  name (`ad_group_criterion.keyword.text`, `campaign_criterion.location.geo_target_constant`, and similar)
  only round-trips correctly as JSON. Table and CSV output silently drop or blank those fields.
- **A rate-limited call returns `RESOURCE_EXHAUSTED`.** Back off exponentially rather than failing the
  whole pass:

```
Attempt 1: immediate
Attempt 2: wait 1s
Attempt 3: wait 2s
Attempt 4: wait 4s
Attempt 5: wait 8s
Max retries: 5
```

  If all retries fail, log the error and skip that query for this pass; do not crash the entire run over
  one rate-limited read.
- **Quota is shared across every install of this plugin, not per account.** The OAuth client's Cloud
  project has a fixed daily operation ceiling that covers every user running this plugin. Keep any single
  install's daily operation count well under its per-install share, and let the weekly schedule land at a
  randomized weekday/hour per install rather than a fixed time, so load spreads instead of spiking.

---

## Read tools

| Tool | What it does | When to use |
|---|---|---|
| `snapshot` | The one-per-pass summarized account pull: 30-day spend + `budget_utilization`, Search-only CTR, impression-share split, conversions by action (`all_conversions` + the unfiltered list), `primary_status_reasons`, RSA labels, `has_running_experiment`, `days_since_structural_change`, the pathology precheck (incl. broken-final-URL and cold-start-deadlock), the maturity stage, a step-back recommendation, and the `trend` block from `metrics-history.jsonl`. Its behavior is specified by the offline oracle in the engine repo. | Once per pass. Everything reads this one result; never poll. |
| `recommend` | The ranked, gated, stage-aware change list; each item tagged `auto` or `queued` with a one-line rationale. Its behavior is specified by the offline oracle in the engine repo. | After `snapshot`, to get the pass's proposed changes. |
| `run_gaql` | Execute arbitrary GAQL queries (json/table/csv output). | When a purpose-built tool below doesn't cover the query. Flexible, but you write the raw GAQL yourself. |
| `get_campaign_performance` | Campaign metrics (cost, clicks, conversions, CPA). | Performance snapshots, spend tracking. |
| `get_ad_performance` | Ad-level metrics with headlines and descriptions. | Ad-copy performance analysis. |
| `get_keyword_performance` | Keyword metrics with Quality Scores. | QS audits, CTR analysis, keyword-level optimization. |
| `get_search_terms` | Actual user queries that triggered ads. | Search-term mining for new keywords and negatives. |
| `get_negative_keywords` | List negative keywords. | Negative-keyword audit. |
| `list_accounts` | List accessible Google Ads accounts for the connected identity. | Confirming which account this install is pointed at. |
| `get_account_info` | Account details (currency, timezone, status). | Account-status checks, disabled-account detection. |
| `health_check` | Check server connectivity and configuration. | Diagnostic; the first thing to run when something looks broken. |
| `search_geo_targets` | Find location IDs for geo-targeting. | Setting up geo-targeting for new campaigns. |
| `get_geo_performance` | Performance breakdown by location. | Geo analysis. |
| `list_recommendations` | Active Google Ads recommendations. | Recommendation review (see `automation-governance.md` before acting on any of them). |
| `list_extensions` | List campaign extensions (sitelinks, callouts, snippets). | Extension audit (R-STRUCT-1). |
| `discover_keywords` | Keyword ideas from seed keywords (Keyword Planner). Returns roughly 50 ideas per call, each with 12 months of per-month volume, competition, competition index, and top-of-page bid range. | The primary keyword-volume source. Its raw payload runs close to 90k characters; never read it unsummarized. The MCP server summarizes by default; raw output sits behind an explicit flag. |
| `get_keyword_forecasts` | **Misnamed.** Returns historical metrics only for keywords already live in the account, ignoring any candidate not already present. Does **not** forecast new candidates. | Rarely. For candidate research use `discover_keywords`; for live-keyword history use `get_keyword_performance`. Do not use it to size unlaunched keywords; it silently returns nothing for them. |
| `get_policy_issues` | Disapproved or limited ads and policy violations. | Policy compliance check (R-WEB-2). |
| `get_conversion_actions` | Conversion actions configured on the account. | Conversion-tracking audit (P1-B). Must include `HIDDEN` and `REMOVED` status, not just `ENABLED`: the GA4-import tier of `conversion-ladder.md` operates on exactly those hidden rows, and a version that filters them out cannot run that path. |

---

## GA4 and tag tools (the conversion ladder)

These drive `conversion-ladder.md`. Discovery tools read; the `create`/`link` tools write.

| Tool | What it does | Ladder tier |
|---|---|---|
| `ga4_account_summaries` | List the connected identity's GA4 accounts and their properties. | Find the property (tier 1). |
| `ga4_data_streams` | List a GA4 property's data streams and their measurement ids. | Find the web stream (tiers 0.5-1). |
| `ga4_key_events_list` | List a property's key events. | See what exists before creating (tier 1). |
| `ga4_key_events_create` | Create a GA4 key event. | Tier 1 step 2. |
| `ga4_google_ads_links_list` | List existing GA4 -> Ads links. | Avoid a duplicate `ALREADY_EXISTS` (tier 1). |
| `ga4_google_ads_links_create` | Link a GA4 property to the Ads account. | Tier 1 step 1. |
| `ga4_event_has_volume` | Whether a key event has recorded any data (wraps `properties.runReport`). | Gate before relying on an event (tier 1). |
| `ga4_run_report` | Run an arbitrary GA4 Data API report. | The general form behind `ga4_event_has_volume`. |
| `tag_destinations_list` | List what a Google tag container already measures. | See before linking (tier 0.5). |
| `tag_destinations_link` | Add GA4/Ads measurement as a destination on an existing Google tag. | Tier 0.5, zero site edits. |

---

## Write tools

All write tools use a two-step safety flow: the draft call returns a preview with a `plan_id`, then
`confirm_and_apply` executes it.

| Tool | What it does |
|---|---|
| `draft_campaign` | Create campaign + ad group + keywords in one call. Defaults to PAUSED. |
| `update_campaign` | Modify budget, bidding, targeting. |
| `draft_responsive_search_ad` | Create an RSA (3-15 headlines, 2-4 descriptions). Defaults to PAUSED. |
| `create_ad_group` | Create an ad group in an existing campaign. Defaults to PAUSED. |
| `update_ad_group` | Modify ad group name or CPC bid. |
| `draft_keywords` | Add keywords with match types. |
| `remove_keywords` | Remove keywords from an ad group. |
| `add_negative_keywords` | Block irrelevant searches. |
| `remove_negative_keywords` | Remove negative keywords. |
| `draft_sitelinks` | Sitelink extensions. |
| `create_callouts` | Callout extensions. |
| `create_structured_snippets` | Structured snippet extensions. |
| `remove_extension` | Remove a campaign extension. |
| `create_pmax_campaign` | Performance Max campaign with text assets. |
| `create_custom_audience` | Remarketing / customer-match audiences. |
| `add_audience_targeting` | Target audiences (TARGETING/OBSERVATION). |
| `create_portfolio_bidding_strategy` | Shared bidding strategy (CPA, ROAS, impression share). |
| `create_conversion_action` | Create a conversion action for server-side uploads (`UPLOAD_CLICKS` type only, gclid-based). There is no MCP tool for a website-destination-URL conversion action; that path goes through the Google Ads UI (Goals > Conversions > + Create > Website), or through the GA4-import path in `conversion-ladder.md`. |
| `set_conversion_action_primary_status` | Mark a conversion action primary or secondary. Does **not** work on a `WEBPAGE_CODELESS` (auto-detected) conversion; those must be promoted or demoted manually in the UI, at creation time if possible, since every later change is otherwise a UI round trip. |
| `update_keyword_bid` | Modify a keyword's CPC bid. |
| `upload_image_asset` | Upload a base64-encoded image. |
| `upload_text_asset` | Create a reusable text asset. |
| `set_campaign_schedule` | Ad scheduling / dayparting. |
| `apply_recommendation` | Apply a Google recommendation. Never call this; see `automation-governance.md`. |
| `dismiss_recommendation` | Dismiss a recommendation. |
| `pause_entity` | Pause a campaign, ad group, ad, or keyword. |
| `enable_entity` | Enable a paused entity. |
| `remove_entity` | Permanently remove an entity. **Blocked by server config.** Use `pause_entity`. |
| `exclude_geo_target` | Exclude a location from a campaign. |
| `remove_geo_target` | Remove a positively-targeted location. |
| `confirm_and_apply` | Execute a previewed change. `dry_run=true` by default. |

### Write gotcha: keyword/criterion entity IDs

`pause_entity` and `remove_keywords` require the **composite** entity ID `{ad_group_id}~{criterion_id}`
(matching the `ad_group_criterion` resource-name format), not the bare `criterion_id` from a GAQL pull. A
bare criterion ID returns `PENDING_CONFIRMATION` at the preview step, which looks like it worked, then
fails with `BAD_RESOURCE_ID` at `confirm_and_apply`. Always construct the ID as
`f"{ad_group_id}~{criterion_id}"` first. `remove_keywords` additionally requires `confirmed_twice=true` on
`confirm_and_apply` (it's destructive), on top of `dry_run=false`.

### Server-enforced guardrails

Enforced at the write choke point, in code, so they cannot be talked out of:

- Budget cap: $329/day max per campaign (the Ad Grants daily equivalent).
- Broad match + Manual CPC combination is blocked at the write choke point: broad keywords on a Manual CPC
  campaign spray spend against the $2 cap with no conversion signal to steer them, so the engine refuses the
  pairing rather than letting it be created.
- Bid-increase limit: 100% max per change.
- New campaigns and ads default to PAUSED.
- `remove_entity` is blocked; `pause_entity` is the only removal path.
- Destructive ops require `confirmed_twice=true` in addition to `dry_run=false`.
- Dry-run is the default; every write needs an explicit `dry_run=false` to execute.
- All mutations are logged to the audit log (`${ADAMUP_DATA_DIR}/audit.log`, default `~/.adamup/audit.log`).

See `guardrails.md` for the full change-authority split (which of these are auto-applied vs. queued for a
one-word approval) and the rest of the server-enforced invariant list.

---

## The change object

Every proposed change, whether auto-applied or queued for approval, is a structured object:

```yaml
- id: "C-001"                    # unique within this batch, sequential
  target: campaign               # account | campaign | campaign_budget | ad_group | keyword | ad | asset | conversion_action | criterion
  target_id: "NEW"               # Google Ads resource name if existing, "NEW" if creating
  action: create                 # create | edit | pause | remove | enable
  campaign: "Brand"               # which campaign this belongs to (null for account-level)
  ad_group: null                  # which ad group (null for campaign-level and above)
  before: null                    # current state (null for creates)
  after:                          # desired state
    name: "Brand"
    advertising_channel_type: SEARCH
    status: PAUSED                # created paused; enabled after all children are built
  reason: "Brand campaign for owned terms per architecture design"
  invariant_ref: null             # which rule from invariants.md drives this, if compliance-driven (e.g. "P1-A", "R-KW-3")
  priority: setup                 # P1-compliance | P2-optimization | setup
  depends_on: []                  # change IDs that must complete first
```

**Field notes:**
- `action` maps directly: `pause` sets PAUSED, `remove` deletes (blocked server-side; use `pause`),
  `enable` sets ENABLED, `edit` changes fields, `create` makes a new entity.
- `reason` is always filled, in terms a human could act on without re-deriving them. "The model suggested
  it" is not a reason. If a proposed change cannot be explained this way, it does not go out.
- `invariant_ref` links a compliance-driven change to the rule in `invariants.md` that requires it.
- `depends_on` is enforced, not advisory: a change cannot execute until every ID it depends on has
  completed.

### Dependency ordering

Never emit a step whose prerequisite isn't done:

```
1. Conversion actions        <- must exist before Smart Bidding can reference them
2. Campaign creation         <- must exist before anything inside it
3. Campaign budget           <- set before enabling
4. Geo-targeting criteria    <- must be set before enabling (R-STRUCT-4)
5. Bidding strategy          <- depends on conversion actions existing
6. Ad groups                 <- must exist before keywords/ads
7. Keywords                  <- can be created once the ad group exists
8. Ads (RSAs)                <- can be created once the ad group exists
9. Assets (sitelinks, etc.)  <- can be added at campaign or account level anytime
10. Campaign enable          <- last, only after all children are built and compliant
```

### Batching

1. **By campaign.** All changes for one campaign together, then the next. No interleaving.
2. **Within a campaign, by change type.** Follow the dependency order above.
3. **Priority ordering.** P1-compliance changes come before P2-optimization changes.

---

## Execution flow per change

```
1. Map the change object to the correct MCP tool + parameters.
2. Call the tool (every write tool returns a preview with a plan_id).
3. Check the preview for errors.
4. Run the invariant gate (below).
5. No approval here. Approval already happened once, at the plan level: an `auto` item runs
   unattended inside the guardrails, and a `queued` item only reaches this step after the
   user's one-word approval (guardrails.md). The two-step preview is a mechanical safety
   step, not a second approval gate.
6. Call confirm_and_apply with plan_id and dry_run=false (and confirmed_twice=true for a
   destructive op).
7. Read back the affected entity to confirm the account is actually in the intended state,
   not just that the API accepted the write (see the read-back rule below).
8. Log the before/after state.
```

### Invariant gate at write time

Before calling `confirm_and_apply`, check the change object against `invariants.md`:

- Keyword create: reject a single word not on the allowlist (R-KW-1), fail closed.
- Campaign create: assert >=2 ad groups planned, >=2 ads/group planned, geo-targeting set, Smart Bidding
  set (R-STRUCT-2, R-STRUCT-3, R-STRUCT-4, R-BID-1).
- Budget change: reject a daily budget over $329 (enforced by the server guard **and** checked here).
- Bidding change: reject `MANUAL_CPC` for a post-2019 account (R-BID-1).
- Broad match + Manual CPC: blocked by the server guard.

If a check fails, reject the change with the reason and the invariant reference; it does not proceed to
`confirm_and_apply`. Fail closed.

### Read back after writing

The two-step confirm flow proves the API accepted the change. It does not prove the account ended up in the
intended state. A campaign can read ENABLED with every ad group beneath it still PAUSED. Read back after
any structural change, especially one that enables or pauses something across levels.

### Partial success

Google Ads batch operations can partially succeed: a campaign and ad group create while some keywords are
rejected (a policy topic, for instance), or a campaign creates but its budget mutate errors. Before
retrying any failed step, query the live account to see what actually exists. A blind retry causes
`DUPLICATE_CAMPAIGN_NAME` / `DUPLICATE_NAME` errors. Record which items were rejected and why.

---

## MCP tool mapping

| Target | Action | Tool |
|---|---|---|
| campaign | create | `draft_campaign` |
| campaign | edit (budget, bidding, targeting) | `update_campaign` |
| campaign | pause | `pause_entity` |
| campaign | enable | `enable_entity` |
| ad_group | create | `create_ad_group` |
| ad_group | edit | `update_ad_group` |
| keyword | create | `draft_keywords` |
| keyword | pause | `pause_entity` |
| keyword | remove | `remove_keywords` |
| ad | create (RSA) | `draft_responsive_search_ad` |
| ad | pause | `pause_entity` |
| asset (sitelink) | create | `draft_sitelinks` |
| asset (callout) | create | `create_callouts` |
| asset (snippet) | create | `create_structured_snippets` |
| asset (call / phone) | create | none; manual in the Google Ads UI |
| asset | remove | `remove_extension` |
| conversion_action | create (offline/upload) | `create_conversion_action`, `UPLOAD_CLICKS` type only |
| conversion_action | create (website destination URL) | none; Google Ads UI (Goals > Conversions > + Create > Website), or the GA4-import path in `conversion-ladder.md` |
| conversion_action | set primary/secondary | `set_conversion_action_primary_status`; does not work on `WEBPAGE_CODELESS` |
| criterion (geo) | create | geo params inside `draft_campaign` or `update_campaign` |
| criterion (geo) | exclude | `exclude_geo_target` |
| criterion (geo) | remove | `remove_geo_target` |
| negative keyword | create | `add_negative_keywords` |
| negative keyword | remove | `remove_negative_keywords` |
| keyword bid | edit | `update_keyword_bid` |
| ad schedule | create | `set_campaign_schedule` |

---

## GAQL query catalog

For anything not covered by a purpose-built tool, use `run_gaql`. Purpose-built tools are preferred where
they exist; they handle pagination, formatting, and error handling for you.

### Q-CTR-ACCOUNT: account-level CTR, month-to-date

Used for the P1-A check.

**Use the Search-only query. A `FROM customer` query is wrong for any account running PMax:**

```
Tool: run_gaql
customer_id: "<customer_id_no_hyphens>"
query: "SELECT campaign.name, campaign.advertising_channel_type, metrics.impressions, metrics.clicks
        FROM campaign
        WHERE segments.date DURING THIS_MONTH
          AND campaign.advertising_channel_type = 'SEARCH'"
```

Compute CTR yourself: sum clicks across rows, sum impressions across rows, divide. Do not average the
per-campaign `metrics.ctr` values; that weights a 14-impression campaign the same as a 5,000-impression one
and produces a meaningless number.

**Why this is not a footnote.** PMax campaigns are excluded from the Ad Grants 5% CTR rule, so a blended
`FROM customer` number is not what Google measures for P1-A, and the gap is not small. Measured once on a
PMax-heavy grant account:

```
Blended (FROM customer):   548 clicks / 12,968 impressions =  4.23%   <- below the floor
Search only (P1-A basis):   29 clicks /      73 impressions = 39.73%  <- the real number
```

Reading the blended number there would have fired the emergency brake on a healthy account and torn down
the PMax campaigns carrying 99% of its traffic. The inverse risk exists too: because PMax volume dominates
and is exempt, a real Search CTR problem can hide inside a healthy-looking blended number on a different
mix. Only the Search-only basis is diagnostic in either direction. Also report the blended number
separately, labeled, since it's what the dashboard shows and needs to be explainable rather than a surprise.

### Q-CONVERSIONS: conversions segmented by conversion action, month-to-date

Used for the P1-B check.

**Never read P1-B from a blended account total.** The account carries a page-view conversion as its primary
bidding action, and its target may be a campaign landing page, so the blended total runs close to the click
count. A bare "conversions > 0" check would pass an account with no meaningful conversion at all, which is
the exact disablement trigger P1-B exists to catch. Segment by conversion action, always.

```
Tool: run_gaql
customer_id: "<customer_id_no_hyphens>"
query: "SELECT conversion_action.name, conversion_action.id, conversion_action.category,
               conversion_action.type, conversion_action.counting_type,
               conversion_action.primary_for_goal, metrics.all_conversions
        FROM conversion_action
        WHERE segments.date DURING THIS_MONTH"
```

Classify each row:

```
role: bidding, not meaningful   -> the page-view action. Exclude from P1-B.
meaningful                      -> counts toward P1-B.
unclassified                    -> resolve before trusting the check; GA4 can add
                                    actions without warning.

REAL_CONVERSIONS = sum of metrics.all_conversions over the meaningful rows.
P1-B passes on REAL_CONVERSIONS >= 1 for the month. Nothing else.
```

Also pull the unfiltered action list (`get_conversion_actions`, including `HIDDEN`/`REMOVED`), not just
metric-bearing rows: an action that exists but recorded zero can be missing from a metrics-segmented query
entirely, and "no meaningful action is even defined" is a distinct and more serious finding than "one is
defined and recorded zero."

Report both numbers, labeled, wherever conversions are shown:

```
Total conversions MTD (reported):        {blended}   <- bidding volume, not impact
Meaningful conversions MTD (P1-B basis): {real}      <- the compliance number
```

### Q-STRUCTURE: campaign/ad-group/ad counts

Used for R-STRUCT-1 through R-STRUCT-4.

Ad groups per campaign:
```
Tool: run_gaql
customer_id: "<customer_id_no_hyphens>"
query: "SELECT campaign.name, campaign.status, campaign.advertising_channel_type, ad_group.name, ad_group.status FROM ad_group WHERE campaign.status = 'ENABLED'"
```

Ad count per ad group:
```
Tool: run_gaql
customer_id: "<customer_id_no_hyphens>"
query: "SELECT ad_group.name, ad_group_ad.ad.type, ad_group_ad.status, campaign.name FROM ad_group_ad WHERE ad_group_ad.status = 'ENABLED' AND campaign.status = 'ENABLED'"
```

Sitelink count (R-STRUCT-1): use `list_extensions`.

### Q-GEO: geo-targeting by campaign

Used for R-STRUCT-4.

```
Tool: run_gaql
customer_id: "<customer_id_no_hyphens>"
query: "SELECT campaign.name, campaign_criterion.location.geo_target_constant, campaign_criterion.negative FROM campaign_criterion WHERE campaign_criterion.type = 'LOCATION' AND campaign.status = 'ENABLED'"
```

**Resolve the IDs, never eyeball them.** Two `geoTargetConstants/...` IDs can look equally plausible in a
result set and refer to entirely different countries.

```
Tool: run_gaql
query: "SELECT geo_target_constant.id, geo_target_constant.canonical_name, geo_target_constant.target_type FROM geo_target_constant WHERE geo_target_constant.resource_name IN ('geoTargetConstants/...', ...)"
```

**Then check the geo against the keywords. Nothing in Google Ads warns you when they contradict each
other.** A geo target and a keyword list each encode an assumption about who is searching, and a mismatch
between them produces a campaign that serves nothing while reporting `ELIGIBLE`, with no alert anywhere.

Ask this on every pass, per campaign:

```
Where does someone searching this keyword physically sit?

  "<service> in <place>"        -> searcher is usually OUTSIDE <place>.
                                   Target the source markets, not <place>.
  "<service> near me"           -> searcher is inside the fence. "near me"
                                   resolves against the geo target, so a
                                   national-volume term becomes local traffic.
  "<service> <local place>"     -> searcher is usually inside or adjacent.
```

A real case of this shape: a campaign targeted a single country and nothing else, built entirely around
keywords like "volunteer in <that country>." Those are searches from abroad, by people planning to travel
there, not people already there. The campaign advertised local opportunities exclusively to people who were
already local, and returned close to zero impressions for months. The fix was one `update_campaign` call
once the mismatch was seen; nothing in the account had flagged it.

### Q-BIDDING: bidding strategy by campaign

Used for R-BID-1.

```
Tool: run_gaql
customer_id: "<customer_id_no_hyphens>"
query: "SELECT campaign.name, campaign.bidding_strategy_type, campaign.maximize_conversions.target_cpa_micros, campaign.target_roas.target_roas, campaign.status FROM campaign WHERE campaign.status = 'ENABLED'"
```

Always pull `campaign_budget.explicitly_shared` in the same query: a shared budget is what makes a bidding
fix look impossible, and the flag is immutable once set (see R-BID-1 in `invariants.md`).

### Q-IS: impression share, and why it is lost

The cheapest diagnostic available. Run it every pass, not only during a spend investigation.

```
Tool: run_gaql
customer_id: "<customer_id_no_hyphens>"
query: "SELECT campaign.name, metrics.impressions, metrics.clicks, metrics.search_impression_share, metrics.search_rank_lost_impression_share, metrics.search_budget_lost_impression_share FROM campaign WHERE segments.date DURING LAST_30_DAYS"
```

It separates two explanations for a starved account that otherwise look identical from the outside:

```
lost to RANK, ~0% lost to budget
  -> the ads cannot win the auction. On a grant account this is almost
     always the $2.00 bid cap, i.e. a non-conversion bidding strategy.
     Adding budget does nothing. Fix the bidding strategy.

lost to BUDGET
  -> the ads win but run out of allowance. Raise the budget toward $329.

impression share present but small, little lost either way
  -> the inventory ceiling of the dual auction. Normal. See
     auction-model.md before "fixing" it.
```

### Q-URLS: destination URLs by ad

Used for R-WEB-1.

```
Tool: run_gaql
customer_id: "<customer_id_no_hyphens>"
query: "SELECT ad_group_ad.ad.id, ad_group_ad.ad.final_urls, ad_group_ad.status, ad_group.name, campaign.name FROM ad_group_ad WHERE ad_group_ad.status = 'ENABLED' AND campaign.status = 'ENABLED'"
```

### Q-KW-SERVING: keyword real-time serving status

Used for RARELY_SERVED keyword detection, and as a cross-check on any match-type decision.

```
Tool: run_gaql
customer_id: "<customer_id_no_hyphens>"
query: "SELECT ad_group_criterion.keyword.text, ad_group_criterion.keyword.match_type, ad_group_criterion.system_serving_status, campaign.name, ad_group.name FROM keyword_view WHERE ad_group_criterion.status != 'REMOVED' AND campaign.status = 'ENABLED'"
```

Returns one row per live keyword. `system_serving_status` is `ELIGIBLE` or `RARELY_SERVED`, Google's own
real-time signal for whether a keyword is getting any traffic, independent of any third-party volume
estimate. **Use `format: json`** if reading more than a handful of rows; the `table` output has a rendering
bug that leaves nested `ad_group_criterion.*` fields blank, while `json` renders them correctly.

This is authoritative for keywords already live. Third-party volume estimates are for pre-launch candidate
selection, where no serving-status signal exists yet, and the two do not always agree at the very-long-tail
end.

### Q-DISCOVER: keyword ideas from Keyword Planner

Used by the keyword-research step (see `keyword-doctrine.md`).

```
Tool: discover_keywords
customer_id: "<customer_id_no_hyphens>"
seed_keywords: ["broad seed 1", "broad seed 2"]   # 1-3 words each, one per ad-group theme
```

**Never read the raw result into context.** The payload runs close to 90k characters (12 months of
per-month volume per idea); the MCP server summarizes it by default, with raw output behind an explicit
flag. Read the summarized table.

**Returns per idea:** `avgMonthlySearches`, `competition` (LOW/MEDIUM/HIGH), `competitionIndex` (0-100),
top-of-page bid range, and 12 months of `monthlySearchVolumes`. Single-word ideas are flagged so they are
never proposed (R-KW-1).

**Two limitations to design around:**
- **No geo/language parameter.** `discover_keywords` returns volume for one geo (verify empirically which,
  historically US). For an organization operating across multiple countries, this tool alone cannot give
  per-market volume; you need a geo-aware fallback for non-domestic markets.
- **No relevance score.** The tool returns no similarity-to-seed score, so a high-volume idea that has
  drifted to a different commercial intent or a different organization entirely will not flag itself. That
  screen is a judgment call (see `keyword-doctrine.md`), using `competitionIndex` and bid range as weak
  proxies.

**`get_keyword_forecasts` is not a candidate forecaster.** Passed a mix of live and unlaunched terms, it
returns data only for the one already live in the account and silently ignores the rest. Use
`discover_keywords` for candidate volume and `get_keyword_performance` for live-keyword history.

---

## If access drops

Both `discover_keywords` and `get_keyword_forecasts` need Keyword Planning API access at Basic level or
above; at a lower access tier they error outright. If that ever happens, fall back to a manual or
third-party keyword-volume source for that pass rather than blocking on it, and retry the MCP tools once
access is confirmed restored (`health_check`).

Legacy schema migration requires verified disabling or upgrading older AdamUp hosts before `select` acknowledges `legacy_hosts_disabled:true`. If that cannot be verified, use a separate profile and do not overwrite old state. For uncertain writes, preserve all resource results, inspect the actual account by API, and only after explicit user review call `reconcile_plan` with its plan ID, resolution, and evidence. New writes remain blocked until reconciled; never replay a whole partial batch.
