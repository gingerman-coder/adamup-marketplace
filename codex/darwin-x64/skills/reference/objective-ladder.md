# Objective ladder: what the grant is for

Decides what an account is actually trying to achieve, and encodes the consequence in conversion actions,
campaign mix, and how success gets reported. Decide this before building conversion tracking
(`conversion-ladder.md`) or campaigns (`architecture.md`), and revisit whenever the org's goals change.

**Why this matters:** a system can be good at running a grant account and have no opinion about what the
account is *for*. That gap produces a specific, expensive failure: an account gets pointed at direct
donations, the dual auction makes direct donations nearly unwinnable (`auction-model.md`), the account
gets judged against the thing it's worst at, and the conclusion is "the grant doesn't work." This is one
of the most common reasons nonprofits abandon a functioning Ad Grant.

## The core claim

**A Google Ad Grant is a top-of-funnel list-building and awareness instrument. It is a poor cold-donation
instrument.** This isn't pessimism, it's auction mechanics. Grant ads rank below every paid ad
(`auction-model.md`). Donation-intent queries are commercially contested, so paid demand consumes the
slots and grant ads rarely place there. Mission-informational and local-service queries are thinly
contested, so the grant actually serves. The grant reaches strangers, cheaply, on questions nobody is
paying much to answer. A stranger will give an email address; a stranger rarely gives money on first
contact.

**What this changes in practice:** stop asking the grant to close and start asking it to open. The
donation happens later, in a channel built for it: an email appeal, a year-end campaign, or a paid
remarketing account working a warm audience the grant assembled.

## The ladder

Four rungs. Every account sits on one as its **primary** rung. Higher rungs are harder for a grant account
to reach and shouldn't be primary unless the evidence supports it.

```
RUNG 4  DIRECT DONATION            hardest for a grant, rarely primary
        ^
RUNG 3  HIGH-COMMITMENT ACTION     volunteer signup, event registration,
        ^                          program application, contact request
RUNG 2  LIST BUILDING              newsletter signup, resource download,
        ^                          petition, quiz, account registration
RUNG 1  AWARENESS AND SERVICE      the right person reaches the right page:
                                   someone needing help finds help
```

### Rung 1: Awareness and service delivery

**Primary when** the org's mission is to deliver information or services to people who need them, and
"the right person found the page" is genuinely the goal: crisis services, health information, helplines,
referral services, advocacy education.

The honest tension: P1-B requires at least one meaningful conversion per month (`guardrails.md`), and
pure awareness has no natural conversion event. Resolve it in two parts, because bidding and compliance
are different problems:

- **Bidding is already solved.** A page-view conversion is primary on every account and carries Smart
  Bidding (`conversion-ladder.md`, `bidding.md`). Rung-1 accounts don't need a real conversion to spend.
- **P1-B still needs a real micro-action.** Find the one a genuinely-helped visitor takes: a resource PDF
  download, a "find a location near you" search, a phone-call click, a referral form. Nearly every service
  org has one. If the site truly has none, that's a website finding, not a launch blocker.

Rung 1 is a real answer, not a consolation prize. For a crisis-line nonprofit, connecting a person in need
to help *is* the mission, and the grant is excellent at it.

### Rung 2: List building

**The default rung for most accounts, and the grant's strongest position.**

**Primary when** the org has, or can build, an email program, which is most orgs. The queries where grant
ads actually serve are informational, and an informational searcher will trade an email address for
something useful; the ask matches the temperature of the traffic.

**Conversion design:** newsletter signup, resource or toolkit download, guide request, petition signature,
quiz completion, webinar registration. Each needs a real confirmation event (`conversion-ladder.md`).

**The handoff is the point.** A rung-2 conversion is only valuable if the org actually emails the list.
Confirm an email program exists and someone runs it before building to rung 2; otherwise the grant fills a
bucket with a hole in it.

### Rung 3: High-commitment action

**Primary when** the org has a concrete, locally-searched action with real intent behind it: volunteer
recruitment, event registration, program enrollment, service application.

**Why it works despite the auction:** these queries are often local and rarely commercially contested.
"Volunteer opportunities near me" has thin paid competition, so the grant can win it.

**Conversion design:** volunteer application submitted, event registered, program application completed,
contact form submitted. All real form completions with confirmation pages.

### Rung 4: Direct donation

**Rarely primary. Almost always secondary.**

**Primary only when all of:**
- The org has strong brand recognition and people search for it by name specifically to give, or
- The org sits in a vertical where cold donation search genuinely exists (disaster relief and animal
  welfare are the two documented cases)
- Conversion tracking captures the actual completed donation, not a proxy (see the off-domain handling in
  `conversion-ladder.md`)
- The account already clears rung 2 or 3 reliably

**Always include a Donate campaign anyway.** Brand-name donation searches and warm returning donors
convert, the traffic is cheap, and the campaign catches intent that would otherwise be forfeited. The
distinction is between *having* a Donate campaign and *judging the account by it*.

**What to tell an org that wants donations:** the grant builds the audience, the email program converts
it. Reporting the grant's donation count in isolation understates it, because the donations it caused
arrive months later through a different channel. Set that expectation before launch, not after the first
review.

## Assigning the rung

```
1. Check the email program: does the org have a mailing list and someone
   who sends to it?
     YES -> rung 2 is available.
     NO  -> rung 2 is a hole with a bucket. Flag it, prefer rung 1 or 3,
            and recommend building an email program as a prerequisite for
            getting real value from the grant.

2. Check for a high-commitment local action: volunteer recruitment, events,
   program enrollment, service applications the org actively wants filled?
     YES -> rung 3 is available.

3. Check the donation profile: strong brand recognition, or a
   disaster-relief / animal-welfare vertical, AND real donation tracking
   possible?
     ALL YES  -> rung 4 may be primary.
     OTHERWISE -> rung 4 is secondary only.

4. Assign one primary rung and up to two secondary rungs.

5. Sanity check against the auction model: if the primary rung is 4 and the
   org is neither brand-strong nor in a documented cold-donation vertical,
   stop and reconsider before building. A donation-primary account for an
   org the auction can't serve is a predictable failure.
```

### Recording the decision

```
Objective ladder
- primary_rung: 2 (list building)
- secondary_rungs: [3 (volunteer signup), 4 (donation)]
- primary_conversion: "Newsletter Sign-Up"
- email_program_confirmed: true
- rationale: "Org has an active list and a monthly newsletter with an
  editor. Mission queries are informational and thinly contested. Direct
  donation is secondary and is not the account's success metric."
```

Keep this in the account's profile notes; re-check on any change to the org's goals or programs.

## Consequences downstream

### For conversion design

Build conversion tracking against the primary rung: the primary conversion action is the rung's action;
secondary rungs' actions get tracked as secondary conversions.

**Assign a monetary value to every conversion action, not just donations.** Smart Bidding uses value to
allocate across conversion types, and an unvalued conversion is implicitly worth the same as every other
one, which is almost never true.

| Conversion | How to estimate |
|---|---|
| Donation | Actual transaction value where the processor passes it; otherwise the org's average gift |
| Newsletter signup | (Average annual giving per subscriber) x (share who ever give). If the org can't say, $5-$25 is a defensible placeholder to revisit later. |
| Volunteer signup | The org's own replacement cost for a volunteer, or an estimate of a volunteer's annual contribution |
| Event registration | Average ticket or expected per-attendee revenue |
| Resource download | Lowest value; a weak signal of intent, kept well below a signup |

Record the basis for each number. A documented estimate can be corrected; an undocumented one becomes
folklore.

### For campaign mix

`architecture.md` weights the campaign set toward the primary rung:

| Primary rung | Campaign emphasis |
|---|---|
| 1 Awareness / service | Programs and Awareness campaigns carry the account; Donate stays small |
| 2 List building | Programs and Awareness feed the signup; content and resource pages are first-class landing pages |
| 3 High-commitment | Volunteer or Events is the main campaign, geo-tight |
| 4 Donation | Brand and Donate carry the account; only valid under the narrow conditions above |

### For reporting

Report against the primary rung first. A rung-2 account gets reported on signups, list growth, and cost
per signup. Donations are a secondary line with the explicit caveat that the grant's donation contribution
is mostly indirect and lagged. Never lead a report with a metric the account wasn't built to produce.

## Expectation setting

Three numbers to set before launch, so early results get read correctly:

**Roughly 6 months to meaningful results.** A grant account needs time to accumulate conversion history,
Quality Score, and search-terms data, and Smart Bidding needs sustained history to learn. Time in market is
one of the largest factors in a mature account's performance, ahead of any single technique.

**The first 4 to 8 weeks will look bad.** Learning periods, thin data, negatives not yet found. This is
expected and is not a signal to change strategy (`change-hygiene.md` exists partly to stop overreacting to
it).

**Donation ROAS is structurally lower for small orgs, and that's a benchmark fact, not a performance
failure.** From the 2026 M+R Benchmarks Study (180 nonprofits): grant-dollar ROAS by annual org budget
averaged **$0.84** per grant dollar for large orgs ($5-10M), **$0.19** for medium orgs ($1-5M), and
**$0.04** for small orgs (under $1M, where most grant accounts sit). The study attributes most of the
20x spread to management quality (compliant structure, real keyword targeting, working conversion
tracking, actually using the full grant), not org size alone, which is a reason to run the account well
rather than a reason to expect a small org to underperform by default. But a small org shouldn't be
benchmarked against a donation-ROAS target calibrated on a $5M organization. This is the quantitative case
for the rung-2 framing: lead with reach and list-building metrics for most accounts, and treat donation
ROAS as a slow-arriving, secondary number.

Say all three up front. Told at month 3 that results take 6 months sounds like an excuse; told at launch,
it sounds like a plan.

## Grant and paid, division of labor

Where an org also runs, or could run, a paid Google Ads account, the two have different jobs and
shouldn't mirror each other. Mirroring a paid strategy into a grant account is a documented mistake: the
constraints differ, so the same structure performs differently.

| | Grant account | Paid account |
|---|---|---|
| Auction position | Below all paid ads | Competes on merit |
| Best at | Cold reach on uncontested queries, list building, awareness, local service | Conversion, remarketing, contested commercial queries |
| Rungs | 1 to 3 | 3 to 4 |
| Role in the funnel | Fills the top | Closes the bottom |

**The pattern to recommend:** the grant builds audiences and email lists at zero cost; the paid account
remarkets to those warm audiences for donations. The grant also doubles as a free testing ground: try ad
copy and keyword angles on grant budget, then move what works into paid.

**If both exist:** keep them as separate accounts under one manager account, and define conversion actions
at the manager-account level so both share one conversion setup rather than maintaining two divergent
definitions of the same conversion. Never let a paid billing method touch the grant account; confirm the
grant account's billing page shows no payment method attached.
