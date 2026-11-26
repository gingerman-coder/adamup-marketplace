---
name: adamup-onboard
description: The AdamUp setup wizard. Runs once per machine to connect Google, scrape the site, build a profile, set up conversion tracking, build the first campaigns, and register the weekly pass. Invoke when engine state shows setup is incomplete, when the user says "set up AdamUp" / "get started", or to resume an in-progress setup.
trigger_phrases:
  - "set up adamup"
  - "get started with adamup"
  - "onboard"
  - "connect my google ads"
  - "start adamup"
---

# AdamUp setup wizard

## Installed resources and host services

AdamUp collects no diagnostics. If the user asks about telemetry, follow `reference/telemetry.md`.

Resolve this installed `SKILL.md` first. The package root is two directories above it; `reference/...`
means `<package root>/skills/reference/...` and `scripts/...` means `<package root>/scripts/...`.
Never resolve resources from the current working directory. Load `reference/host-runtime.md` when using
setup, engine discovery, questions, local state, scheduling, notifications, or optional helpers. Discover
engine operations by their advertised schemas, without assuming an MCP prefix. Call
`adamup_capabilities` before stateful work; use `adamup_state` for durable state. If required capabilities
are missing, explain the incompatible engine and keep the account unchanged. Never edit state JSON or
run a legacy Python state writer as a workaround.


Runs **once** on this machine. Your job is to take a nonprofit with an approved Google Ad Grant from a
fresh install to a reviewed account with optional weekly runs, and to do it so a non-technical 70-year-old can follow.
She will fail at least one step. **Catch her failures; never trust a self-report.** Every question leads
with a best guess and short choices; typed corrections are available through the host runtime.

Guiding doctrine lives in `reference/`; **`reference/README.md` is the index of what to load when.** Load a
file only when the step needs it, to protect her token budget, never the whole folder.

After account selection, persist progress with `adamup_state` so setup can resume. Before selection,
keep progress in this conversation; do not invent a customer to store it. Inspect its advertised operation schema and
keep every read/update bound to the selected customer/profile. Do not write legacy state files.

## Preconditions

- **Do not trust a self-report about the grant.** Whether the account is a real, approved Ad Grant is the
  single thing we most expect a well-meaning user to get wrong, so verify it, do not ask it. Hand off to the
  **`adamup-grant`** skill (Mode A) for the status check. It reads the account and reports back:
  - `grant_active` -> continue here with setup.
  - `no_account_found` or `has_paid_account_not_grant` -> `adamup-grant` Mode B walks them through applying;
    there is nothing for this wizard to build yet.
  - `indeterminate` -> `adamup-grant` asks one clarifying question and re-classifies before we proceed.
- If the user says “not now”, record deferral in this conversation. After an account is selected, use
  `update` with `onboarding_progress` containing the current step and requested resume date. Reserve
  `status: declined` and `declined_reason` for an actual request to stop. Do not use unsupported fields or
  promise a future reminder without a registered host task.
- If engine state already shows `onboarded`, do not rebuild. Offer manual `run adamup`; inspect outstanding
  tracking or scheduling blockers instead of assuming activation.

## Step 0 - Greeting and expectations

One short message: what will happen, that it needs one Google sign-in, that it takes ~18 minutes of their
attention (more only if their website needs a code snippet). The grant itself is confirmed by `adamup-grant`
(above), not by asking them, so lead with what happens next, not with "do you have a grant?".

## Step 1 - Connect Google

The OAuth client is built into the engine, so there is nothing to place or paste; `connect_google_ads` uses
it automatically. The user's own token is the only credential written to this machine
(`~/.adamup/token.json`), by the sign-in itself.

**Say this first (before the popup opens), warmly and in plain words:**

> In a moment a Google sign-in window will pop up. That is **Google's own page**, not AdamUp or this chat app,
> so it is safe to sign in there. It will ask you to allow a few things (your ads, your analytics, your
> tags): those permissions are what let me actually run your account for you. AdamUp never sees your
> password and never receives any sign-in code; it all stays on your computer. We may need a website settings step later if tracking is missing.

Then call `connect_google_ads` (MCP). It opens the system browser for loopback OAuth sign-in: one consent
popup, the six scopes, no `include_granted_scopes`. The token is written to their machine only
(`~/.adamup/token.json`).

**If the sign-in does not work, do not just say "re-run it".** Name the likely cause in plain language and
give the one fix:

- **No popup appeared / it was blocked.** A popup blocker probably stopped it. Tell them to allow popups for
  this window (or watch for a blocked-popup icon in the address bar), then say "try again" and re-run
  `connect_google_ads`.
- **The window closed before it finished.** No harm done, nothing was saved. Re-run it and let the page
  finish loading the "you can close this tab" message before closing it.
- **Signed in with the wrong Google account.** The account you pick must be the one that manages the grant.
  Have them sign out of Google (or use the "use another account" link on Google's page), then re-run and pick
  the right one.
- **They clicked "Cancel" or "Deny" on the permissions.** Nothing was granted, which is fine. Reassure them
  the permissions are only used to run their ads, then re-run and click Allow.
- **"You do not have permission" / a work or school account blocks it.** Their organization's Google admin
  has locked down third-party sign-ins. They will need to use the personal or nonprofit Google account that
  owns the grant, not the locked-down work account.

Never ask them to copy or paste a token by hand; the loopback flow handles that.

## Step 2 - Pick the account

`list_accounts`. Show the account name and ask them to confirm it, even if exactly one is available. If there are several,
show short choices. Select the confirmed customer/profile through `adamup_state`; never silently switch an
already selected customer. Account selection does not approve campaign changes. If migrating legacy state, first verify older host packages are disabled or upgraded and acknowledge `legacy_hosts_disabled:true` in select; otherwise keep an isolated profile.

## Step 3 - Confirm the website

Pre-fill the URL from the GA4 property or the Ads account. Ask them to confirm or correct in one tap.

## Step 4 - Scrape the site

Use the advertised native site-inspection operation, or the supported host browser fallback from the host
runtime. It returns raw material for the profile, not campaign decisions. Do not assume a system Python
interpreter or download dependencies. If neither path is available, preserve progress and explain the gap.

## Step 5 - The question set (at most six one-tap questions)

Each pre-answered from the scrape. Ask only what the scrape could not settle. Present the scraped best guess plus short choices through the host runtime; accept a typed correction
when needed. The six:

1. **Objective rung** (what a good outcome looks like: email signups / volunteers / donations / awareness).
   See `reference/account-lifecycle.md` and the objective ladder.
2. **Primary geography.** Lead with the best guess from the scrape as a single confirm chip ("Looks like you
   serve **{guess}**. Right?") and offer a short pick list of the next most likely options (their city, their
   state/region, their country, nationwide). Only if they reject all of those do you accept a typed place.
   Then sanity-check it against what they DO: a "volunteer abroad" term is searched from the home country,
   not the destination, so targeting the destination serves nothing.
3. **What the org DOES**, confirmed not typed. Turn the scrape into a one-tap "Is this what you do?" chip
   with a plain sentence, plus two or three alternative phrasings drawn from the site as a pick list. Typing
   is the fallback only when every offered phrasing is wrong. This is the keyword-seeding anchor: bid on what
   the org DOES, not what it IS.
4. **Beneficiaries vs donors**: whose language should the ads speak? Seed on the supporter's language, not
   the delivered service.
5. **Budget** confirmation ($329/day per campaign is the default and is correct; every campaign gets it).
6. **One conversion-path guess** (the page or action that signals success).

Use the engine-returned selected account `data_dir` for `profile.md`. Never use the plugin cache or a
developer-specific Documents path. Persist supported profile/progress fields with `adamup_state.update`.

## Step 6 - Conversion tracking (the ladder + verify loop)

Load `reference/conversion-ladder.md`. Run tiers in order and stop at the first that works:

- **0.5** site already has any Google tag -> `destinations.link` adds GA4/Ads measurement. Zero site edits.
- **1** GA4 property exists -> `googleAdsLinks.create`, `keyEvents.create`, then flip the auto-surfaced
  `HIDDEN` action to `ENABLED` via mutate. Zero site edits. This is the default; prefer it.
- **2** known platform -> follow `reference/platform-tag-install.md`: detect the platform, fetch the GA4
  measurement ID yourself, have the user sign in to their site builder in your browser, then add the ID
  for them. Manual steps are the fallback.
- **3** nothing works -> record the blocker, preserve the proposal and keep campaigns PAUSED. Resume
  tracking setup when the site can send a verifiable event.

**Verify by re-fetching rendered HTML and network requests, never by asking "did it work?"** A curl check
can prove a tag present, never absent (GTM injects at runtime; GA4 sends `/g/collect` beacons). Name the
exact failure ("the snippet is in the footer, it has to be in the head"; "that is the preview, the live
site does not have it").

### If there is no GA4 and no GTM at all (the one unavoidable UI visit)

Neither Analytics nor Tag Manager has an API to create an account from scratch, so a nonprofit with neither
needs **one** short visit to analytics.google.com to make the empty shell; everything after that is
automatic. An analytics shell can wait only when another verified primary tracking path already works. Otherwise
explain that the proposal can be built PAUSED now and activation waits for observable tracking evidence.

**If you have a browser tool, do it for them:** open analytics.google.com, ask them to sign in with the
same Google account themselves, then fill in the account name (their organization), property (their
website, country, currency) and a Web stream for their site address. Hand back two things only: their
password or 2-step screen, and Google's terms-of-service checkbox, which they must accept themselves.
Then continue to Tier 1 and the platform step with no further clicks from them.

Without a browser tool, walk them through it one plain step at a time:

1. **Go to** [analytics.google.com](https://analytics.google.com) and sign in with the same Google account
   you just connected.
2. **You will see** a welcome screen or an "Admin" gear. Click **Admin** (the gear, bottom-left), then
   **Create** -> **Account**. Give the account your organization's name and continue.
3. **Next it asks for a "property".** Name it after your website, pick your country and currency, and
   continue.
4. **It asks how you collect data.** Choose **Web**, enter your website address, and click **Create stream**.
   That is the last thing you have to do there.
5. **Come back here and type "continue".** I will find the new property automatically and finish the tracking
   setup with no more clicks from you.

If they would rather wait, record the deferred shell and build only PAUSED resources. Do not activate on
the existence of an unfired conversion action.

## Step 7 - Pathology precheck (before building)

Run the cheap checks via the engine's `snapshot` precheck. Fix where a fix exists; stop honestly where it does not:

```
serves_zero_but_all_eligible  -> investigate age, enablement, history and actual account status.
                                 New/paused campaigns do not prove suspension. Report uncertainty.
conversion_stack_poisoned     -> distinguish approved phase-1 page-view primary from weak engagement.
                                 Any primary-status change requires explicit approval.
records_zero_conversions      -> actions exist but nothing fires. Re-run the tag ladder.
search_ctr_below_floor        -> P1-A clock. Compliance surgery first.
pmax_eligible_but_silent      -> check asset_group (NOT ad_group) and zero signals.
bidding_not_conversion_based  -> the $2 cap is on. Fix with a leaf field mask.
broken_landing_urls           -> any enabled ad final URL not returning HTTP 200. Repoint it;
                                 broken destinations waste budget and get ads disapproved.
```

A new grant is usually empty, so building is the normal path; this guard just stops you tuning a corpse.

## Step 8 - Review and build PAUSED, then separately approve activation

For the build, load the **"Building or rebuilding campaigns"** cluster from `reference/README.md` as each
piece needs it: `architecture.md` (structure), `objective-ladder.md` (the rung), `broad-match.md` (match
posture + negative pre-seeding), `ad-copy.md` (RSA copy), `bidding.md` (Max Conversions + the $2 cap), and
`assets.md` (sitelinks, callouts, snippets). Pull them one at a time, not the whole cluster at once.

Keyword research via `discover_keywords`, screened per `reference/keyword-doctrine.md` (drop wrong-entity
and commercial-drift ideas by judgment; Keyword Planner gives no relevance score; read
`reference/keyword-research.md` for the demand model when you actually build the set). Build at **Stage 0
(Broad Volume)** per `reference/account-lifecycle.md`:

- Broad match on every non-brand ad group, negatives pre-seeded **in the same batch**.
- Brand ad groups **exact** (brand exact CTR is the compliance basis).
- **Maximize Conversions** bidding (the only mode that escapes the $2 CPC cap).
- Exactly one verified phase-1 page-view primary, `ONE_PER_CLICK`, low value, plus a separate real
  meaningful action tracked for compliance. A landing page is acceptable for the bidding primary.
- Every campaign at **$329/day**. Geo wide but sane.

Present the planned scope and obtain approval for the bounded paused build. Then call `adamup_state`
`build_begin` with the selected customer and `payload: {"confirmed": true}`. Its current limit is 30
approved create plans within one hour; inspect the running schema for changes. Everything stays **PAUSED**.
Do not bypass structural guards when it is unavailable. If resuming an existing paused transaction,
reconcile uncertain results first, obtain resume approval and use advertised `build_resume` with
`payload: {"confirmed": true}`; never blindly replay creates. Verify existing and newly created resources
by API and present objective, geography, budget and tracking evidence for review.

Activation is a separate approval after the paused build. Observe the live site for the exact conversion
label/beacon or linked GA4 event volume, then collect an account-bound snapshot. The engine alone records
tracking evidence from observed Ads conversion actions: a firing enabled primary plus a separate meaningful
action defined. Creating an action, a base tag or user self-report is insufficient. Do not inject evidence
through `update`. The current activation guard requires snapshot evidence within 24 hours. If the selected
account cannot show it, keep campaigns PAUSED and report the precise gap, including attribution delay.
Only after the engine's gate passes and the user explicitly approves activation may an enable preview be
confirmed. Site checks alone do not override a rejected engine gate.

## Step 9 - Register the weekly pass and finish

Register the weekly run as part of finishing setup; do not make it a separate optional step. Use
`reference/host-runtime.md` for supported registration and readback. **Autopilot is the default:** follow
`reference/autopilot.md`, ask its one plain question, and on yes persist the standing permission with
`authorize`. Never infer consent from an `auto` recommendation. Structural changes always wait for review.

Inspect existing registrations and engine ownership before creating a task. Record the actual host task ID,
status, timezone, recurrence and ownership generation through engine state. If unavailable, finish manual
setup and state plainly that weekly scheduling is not enabled. Do not mark the account live if it is PAUSED.

The scheduled prompt must be self-contained:

> Invoke the `adamup` skill for the selected customer/profile. Validate the persisted schedule owner and
> generation before collecting data; stale tasks exit. Collect one account-bound snapshot, reuse its handle
> for recommendations, and perform one catch-up pass. Check compliance first. If autopilot is on, choose
> and apply its fixes exactly as `reference/autopilot.md` says, through preview/confirmation. Queue
> structural and all other changes; do not request input during an unattended run. Preserve failures for reconciliation, write
> the digest, update run state through the engine, and use only supported host notices.

Use the ownership registration sequence in the host runtime, including the returned `schedule_epoch`.
Read back the final prompt and task status; do not register a runnable prompt with a guessed generation. Persist setup completion through the supported `update` operation, while snapshot evidence
remains engine-owned. Tell the user what
is ready, what remains PAUSED, whether weekly runs were actually enabled, and that manual `run adamup` works.

**Set the expectation that the first months look quiet, so she never despairs.** Before you sign off, tell her
warmly and plainly what the next stretch will feel like, because this is the moment a new nonprofit most often
worries the tool is not working:

> Here is what to expect. For the first couple of months, this will look quiet: not many people seeing the
> ads yet, and only a little of the grant spent. That is completely normal and it is not a mistake. Google
> only shows grant ads on the searches that paid advertisers do not take, so it starts small on purpose, and
> the system spends the first few weeks learning before it can reach more people. It can grow as it learns. If weekly runs are enabled,
> I will check the direction it is heading. We will judge the actual results, rather than promise growth. The only things I would ever raise the alarm about are your click rate
> dropping too low or the account not running at all, and those checks come first on every run.

Keep it warm and specific to her; the goal is that a slow start reads as normal, not as failure.

**Privacy:** AdamUp sends nothing to AdamUp. No diagnostics, no health reports. Only the user's own calls to Google leave the computer.
