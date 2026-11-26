# Autopilot: what the weekly run fixes on its own

Autopilot is the default. With the user's one "yes" at setup, the weekly scheduled run applies two kinds of
small, reversible fixes without waiting for anyone. Everything else is still queued for the user.

The engine enforces the limits in code (`adamup_state authorize` plus the scheduled-pass guard). You
cannot widen them, and you do not need to re-ask permission each week.

| Autopilot may | Engine limit |
| --- | --- |
| Add **EXACT** negative keywords for search terms that waste impressions | 25 terms per plan, 10 plans per account per day |
| **Pause a keyword** that is hurting the account | Keywords only (never a campaign, ad group or ad), 10 per account per day |

Autopilot never: creates or edits campaigns, ad groups or ads; changes bids, budgets, geo or bidding;
unpauses anything; touches conversion actions; runs A/B actions; removes anything.

## Turning it on (setup, once)

In `adamup-onboard` Step 9, when registering the weekly run, present autopilot as the default in one plain
message (the example below), and treat a yes as consent for both actions:

> Every week I will check your account and automatically do two small, safe things: block searches that
> waste your ads (like "jobs" or "free download") and pause keywords that drag your click rate down. Both
> are easy to undo and I list every change for you. Bigger changes always wait for your OK. Sound good?

On yes: `adamup_state authorize` with `{"confirmed": true, "operations": ["add_negative_keywords",
"pause_entity"]}` for the selected customer. On no: weekly runs stay review-only. Either way, register the
weekly run. The user can say "turn off autopilot" any time; then call `authorize` with an empty list
(`{"confirmed": true, "operations": []}`) and confirm it is off.

## Choosing negatives (scheduled run)

Read the last 30 days of search terms for each ENABLED Search campaign (`get_search_terms`). Add a term
as an EXACT negative when **any** of these is true and **none** of the exclusions apply:

- 20 or more impressions and 0 clicks.
- Clearly the wrong intent for a nonprofit grant account, per `keyword-doctrine.md`: jobs, salary,
  careers, "free download", login, phone number, reviews of an unrelated business, a different entity
  with the same name, or commercial purchase intent.

Exclusions (never negate): a term that recorded any conversion; a term containing the organization's or
program's name; a term identical to an enabled keyword; anything you are unsure about (queue it instead).

One plan per campaign, at most 25 terms, sorted by impressions wasted. Never use PHRASE or BROAD
negatives on autopilot: an exact negative removes one dud query without blocking its good variants
(`search-terms.md`).

## Choosing keyword pauses (scheduled run)

Read keyword performance for the last 30 days (`get_keyword_performance`). Pause a keyword when **any**
of these is true and **none** of the exclusions apply:

- Quality Score 1 or 2 (the grant policy forbids keeping them).
- 200 or more impressions, CTR under 1%, and 0 conversions.
- Search-only account CTR is under 5% (the emergency brake): pause the keywords with the most impressions
  and CTR under 2%, worst first, up to the daily limit.

Exclusions (never pause): brand keywords; the last enabled keyword in its ad group; a keyword added or
changed in the last 14 days (`change-hygiene.md`); anything with a conversion in the last 30 days.

## Every autopilot change is reported

Each applied change goes in the week's digest and the action log in one plain line with its reason, for
example "Blocked the search 'volunteer jobs near me' (41 people saw the ad, nobody clicked)." At the next
interactive session, open with a two-line summary of what autopilot did and offer a one-word undo
(`enable_entity` for a pause, `remove_negative_keywords` for a negative), applied through normal approval.

If the engine refuses an autopilot change, do not retry or reword it: queue it for the user.
