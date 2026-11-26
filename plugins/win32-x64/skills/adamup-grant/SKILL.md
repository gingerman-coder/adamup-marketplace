---
name: adamup-grant
description: Check whether a nonprofit already has an approved Google Ad Grant, and if not, walk them through applying for one step by step. Runs before setup. Invoke when the user asks "do I have a grant", "check my grant status", "apply for a grant", or "google ad grant application", or when the setup wizard needs to confirm a real grant exists before building anything.
trigger_phrases:
  - "apply for a grant"
  - "do I have a grant"
  - "check my grant status"
  - "google ad grant application"
  - "am I approved for the grant"
---

# adamup-grant: get a grant, or prove you have one

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


A Google Ad Grant is $10,000 a month of free Google Ads for a registered nonprofit. Everything else in
AdamUp assumes the grant is already approved. This skill is the front door: it either **confirms the grant
is real by looking at the account** (not by asking), or it **walks the user through getting one**, one plain
step at a time.

Two modes. Pick the one that fits, do not ask which:

- **Mode A, status check.** The user wants to know if they have a grant, or the setup wizard sent them here
  to confirm before building. Verify from the account.
- **Mode B, application walkthrough.** The user has no grant yet and wants to apply.

Write to me warmly and simply. One idea per step. No jargon without a plain-English gloss. Never invent a
status you did not verify.

---

## Mode A: is there an approved grant? (verify, do not ask)

The doctrine here is "verify, do not ask": a self-report is the thing we most expect
to be wrong. Look at the account instead.

1. **Connect if needed.** Use the engine authentication status. If not connected, run `connect_google_ads` (MCP) first so
   there is an account to read. This is the one Google sign-in popup; explain it the way `adamup-onboard`
   Step 1 does (Google's own page, AdamUp never sees the password).
2. **List the accounts.** Call `list_accounts`. Then `get_account_info` on each one to read currency,
   status, and the account shape.
3. **Classify** what you found into exactly one of these, and act:

   - **`grant_active`** verified Google grant/account evidence confirms an approved grant. Campaign type,
     a $329 budget and bidding settings are supporting clues, not proof on their own. When confirmed, say so plainly and **hand back to `adamup-onboard`** to do the real setup. If
     the wizard sent them here, return control to it.

   - **`has_paid_account_not_grant`** the account has directly verified paid billing rather than an approved grant.
     Campaign type or a $329 budget alone cannot establish this, especially with grant PMax support. Explain the
     difference in one line (a grant is subsidized; a paid account is billed), and offer Mode B to
     apply for an actual grant.

   - **`no_account_found`** the identity has no Google Ads account at all. Go to **Mode B**.

   - **`indeterminate`** the signals conflict (for example, Search-only but with billing attached, or a
     budget nowhere near $329). Do **not** guess. Ask **one** clarifying question that would settle it, for
     example: "Do you get a monthly bill from Google Ads, or is it free?" Then classify.

Never fabricate a determination. If you could not read the account, say that plainly and offer to retry the
sign-in rather than reporting a status you did not see.

---

## Mode B: apply for a grant (the plain walkthrough)

Getting a grant happens on Google's websites, outside the chat app, and it can take a few weeks because a human
at Google reviews it. Set that expectation up front, warmly: "This part is a few steps on Google's own site
and can take a couple of weeks for them to approve. I will walk you through each one, and you can stop and
come back anytime."

Go through these in order. For each, tell the user **what they will see**, **what to click**, and **what to
have ready**. Do not dump all six at once; move one at a time and confirm before advancing.

### 1. Check you are eligible

- **What to have ready:** your nonprofit's registration details (in the US, your 501(c)(3); other countries
  have their own equivalents).
- **The rule in plain words:** you must be a registered charity. A few kinds of organizations are **not**
  eligible even if they are nonprofits: government bodies, hospitals and most healthcare providers, and most
  schools, colleges, and universities (their own Google for Education program covers them). The grant is
  also only offered in [certain countries](https://support.google.com/nonprofits/answer/3215869).
- If they are clearly in an excluded category, say so kindly and stop; do not send them through weeks of
  steps that end in a rejection.

### 2. Get your TechSoup validation token

- **What it is:** TechSoup is the organization Google uses to confirm you are a real registered nonprofit.
  They give you a **validation token**, a short code that proves it.
- **What to do:** create a free account at [techsoup.org](https://www.techsoup.org), register your
  organization, and request the token.
- **What to expect:** this step can take a few days, because a person verifies your paperwork. It is normal
  to wait. Tell them we will pick up right here when the token arrives.

### 3. Enroll in Google for Nonprofits

- **What to have ready:** the TechSoup validation token from step 2.
- **What to do:** go to [google.com/nonprofits](https://www.google.com/nonprofits), click to enroll, and
  enter the token when asked.
- **What you will see:** a confirmation that your organization is being reviewed, then approved. Once
  approved, you can request individual Google products, and Ad Grants is one of them.

### 4. Make sure your website is ready

The grant reviewers check your website, so it is worth getting this right before you apply, not after a
rejection. Load `reference/site-readiness.md` for the full standard; the essentials Google checks:

- The site is **yours** (your own domain) and is **live**.
- It runs on **HTTPS** (the padlock in the address bar, a valid SSL certificate).
- It has **substantial, real content** about what your nonprofit does, not a one-page placeholder.
- No broken links, and no site built mainly to show ads.

**Offer to check this for them:** use native engine site inspection or the supported host browser to read the site and HTTPS/tag checks,
so you can tell them concretely what passes and what to fix before they submit. This is the "verify, do not
ask" doctrine again: point at the exact problem ("your site loads on http, not https") rather than a vague
"make sure your site is good."

### 5. Activate the Ad Grant

- **What to have ready:** approved Google for Nonprofits access (step 3) and a website that passes step 4.
- **What to do:** inside Google for Nonprofits, find **Google Ad Grants** and start activation. You fill in
  a short eligibility form about your organization and website, then submit.
- **What to expect:** Google reviews the submission. Approval usually takes a few days to a couple of weeks.
  There is nothing to do while you wait.

### 6. Come back when you are approved

When Google emails that the grant is approved, the hard part is over. Tell the user: "Once you get the
approval email from Google, come back here and type **set up AdamUp**. I will take it from there and have
your first campaigns running the same day."

---

## Persistence: so a later session can resume

The user will not finish this in one sitting; a token or an approval takes days. Record where they are so a
fresh session (which has no memory of this one) can pick up exactly here.

Before there is a confirmed selected customer, keep the application step and next action in this
conversation and give the user a short copyable resume note. Persistent cross-chat application resume is
not available before account selection in this candidate. Do not invent an account or write unsupported
`apply_step`, `apply_note` or snooze fields.

If a customer is already selected, persist supported progress through `adamup_state` `update` with
`status: applying` and an `onboarding_progress` object containing the step and next action. On approval,
resume `adamup-onboard`; preserve the account binding and prior evidence rather than replacing state.
If the user defers, record their requested resume date in that progress object, and do not promise a
future reminder unless the supported host scheduler actually registers one. A request to stop can set
`status: declined` with `declined_reason` only for an already selected profile.
