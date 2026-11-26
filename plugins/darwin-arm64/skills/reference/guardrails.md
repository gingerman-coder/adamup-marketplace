# Guardrails and change authority

These are enforced in the MCP server, in code, not in prompts. Prompts drift and a user can talk an agent
out of a rule; code cannot be talked out of anything. This file documents them so the skills know what to
expect and can explain refusals.

## Change authority

**Eligible for low-risk action (reversible):**

Apply only with explicit current approval or persisted customer-bound standing permission covering the
exact operation. `auto` is eligibility, never authorization. Without permission, queue the change.

- Add negative keywords, including the negative-exact CTR instrument.
- Pause a dud keyword or a losing ad.
- Shift budget within the $329/day cap.
- The CTR emergency brake.
- Replace a LOW-labeled RSA asset.

**Queued for one-word approval (structural):**
- New campaigns, ad groups, or ad copy.
- Bidding-strategy changes; geo changes.
- Anything that unpauses.
- Anything touching a conversion action's primary status.
- Any stage advance that changes structure (match-type tightening, PMax, audience layers).

## Server-enforced invariants

- **Budget ceiling:** $329/day per campaign (the Ad Grants daily equivalent).
- **`remove_entity` is blocked.** Use `pause_entity`. Deletion is not reversible and is never worth it.
- **Never unpause a policy-flagged entity.**
- **At most one structural change per campaign per pass** (change hygiene: churn costs more than it looks).
- **Request metering** covers only operations reported by the actual running engine capabilities. A local
  meter cannot guarantee the remaining shared Cloud-project quota; reads, retries and batches must count
  according to documented coverage. Never equate applied plan count with all API traffic.
- **Two-step confirm on every write** (`plan_id` preview, then `confirm_and_apply`).
- **A rollback log** keyed to the audit log.
- New campaigns and ads default to **PAUSED**. Initial builds use only an advertised bounded setup
  transaction; no global structural-guard bypass. Activation is separately approved after engine-accepted
  observable conversion evidence, never merely creating an action.

## The Ad Grants compliance rules (the real stakes)

- **P1-A:** account Search CTR must stay **>= 5%** (target 7-8% buffer). Two months below = automatic
  deactivation.
- **P1-B:** at least **one meaningful conversion per month** (segment by action; not the account total).
- **Emergency brake:** Search CTR < 5% past grace -> skip all optimization, do compliance surgery only.
- No single-word keywords; no Quality Score 1-2 keywords; Smart Bidding required; conversion-based bidding
  required to escape the $2 CPC cap.

Measure CTR on **Search campaigns only**. PMax is CTR-exempt; the blended number is off by ~9x on a
PMax-heavy account and would fire the brake on a healthy account.

## Never auto-apply Google's own recommendations

Turn off auto-apply on every account. Google's recommendations are not neutral advice. The
conflicting-negatives "Apply" in particular always deletes the negative; compute conflicts in code and
usually pause the keyword instead.
