# A/B testing on a grant account

A/B testing here means a **Google Ads experiment**: it splits a campaign's traffic between the original
(control) and one change (treatment), and Google reports whether the difference is real. Grant accounts are
small, so most tests on most accounts never reach a clear answer, and a test that cannot conclude only
costs learning time. This is why A/B testing is the **Stage 4** capability (see `account-lifecycle.md`),
not a day-one feature. Experiments run natively in the engine (no Python, no extra credentials):
`ab_propose` -> `ab_experiment_draft` -> `confirm_and_apply` -> `ab_experiment_action schedule` (double confirm) -> `ab_experiment_review` each pass -> `ab_experiment_action promote|end` (double confirm). Every step goes through the same preview, confirmation and audit as any other write.
`scripts/ab_tester.py` is a development reference only; never run it from a skill.

## When a campaign is ready to test

All four must hold, or `propose` returns nothing for that campaign:

- It has run **>= 28 days** since launch or its last structural change (a fresh change is still learning).
- It has **enough volume to finish the test in the planned window**: at least `min_conversions_per_arm`
  over the last 28 days. On a page-view primary, conversions track clicks, so this is really a clicks floor.
- The account is **not under the CTR emergency brake**, and Search CTR is **>= 7%**.
- **Nothing else is changing** on that campaign during the test. One test per campaign at a time.

## Good tests for grant accounts, ranked by likely value

1. **Ad-copy angle:** a new responsive search ad with a different lead message (what the org DOES versus
   its story). The model supplies the copy from `ad-copy.md`; the proposal is marked `needs_copy`.
2. **Landing page:** send an ad group to a deeper, more specific page.
3. **Broad versus phrase:** add a phrase copy of a winning broad query (never replace the seed).
4. **More searches:** add keywords with real monthly volume in the service area to an underspending ad
   group (needs Keyword Planner, i.e. Basic access; see `keyword-research.md`).
5. **Locations:** a wider or narrower area, when volume is the problem.
6. **Bidding:** only after a real conversion reaches 15+ a month (e.g. make it primary in the treatment).

## Tests not to run

- A target CPA, or any change that restricts bids, while the account underspends.
- Anything on a campaign in its first 28 days.
- Two tests on the same campaign at once.
- Anything judged on conversions while the page view is primary and the test changes something the page
  view cannot see (e.g. donation quality).

## The closed change vocabulary

A treatment is expressed only as engine ops (`ab_experiment_draft.treatment_changes`):
`add_responsive_search_ad`, `add_keywords` (multi-word only), `add_negative_keywords`,
`set_network_settings` (Search/partners only, never Display), `set_ad_group_cpc_bid`. `ad_group_id` is the
base campaign's id; the engine finds Google's draft copy by name, so the ad group name must be unique in the
campaign. An idea that cannot be written as one of these fails validation rather than being improvised. At least one change
must land: Google refuses to schedule a treatment identical to its control.

## Reading results: the power gate comes first

Google returns the statistics (per-arm clicks and conversions, the conversion-change point estimate, its
margin of error, and the p-value). **We never recompute significance.** The discipline is in when we read:

- Below the floor (`min_days` not reached, or the thinner arm under `min_conversions_per_arm`) the test is
  **underpowered**, not "not yet significant." Any p-value is noise. Report only days and volume remaining.
  There is no "trending positive." Reading a p-value early is how a coin flip becomes a strategy.
- Once powered: p below the significance threshold with a positive effect is a **WIN** (promote the
  treatment to the original campaign); p below threshold with a negative effect is a **LOSE** (end it, keep
  the original); past the end date without significance is **INCONCLUSIVE** (a real result: the change did
  not move the metric enough to matter at this volume; record it so it is not retried blind); otherwise
  **KEEP_RUNNING**.

## Lifecycle and safety

- Create the Experiment in `SETUP`, create both arms in one request (Google auto-creates the draft campaign
  behind the treatment), modify the draft, then schedule. **Nothing spends until scheduling**, so creation
  and approval are separate from the moment money moves.
- Approval is the engine plan: `ab_experiment_draft` returns a preview, and only `confirm_and_apply` on
  that plan creates anything. Schedule, promote and end each need their own preview and `confirmed_twice`.
  Never schedule, promote or end inside an unattended scheduled run; queue them for the user.
- If a create step fails after the experiment exists, the engine returns `reconciliation_required` with the
  experiment name. It sits in SETUP and never spends. Do not retry the create; report it.
- Cadence: look for tests every 10 days, at most one idea per ready campaign and three per account, often
  none. A dismissed idea and its reason are kept so it is not suggested again.
- Experiment state lives in the Google Ads account; `ab_experiment_review` rebuilds it every pass.

Ported from the proven implementation in the `adamup-selfserve` repo (`experiments.py`, `proposal.py`,
`review.py`), adapted to run-adamup's OAuth auth.
