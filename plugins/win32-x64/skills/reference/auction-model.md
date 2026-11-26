# The grant auction and how to read impression share

The single most misread thing about Ad Grants. Understand this and most "why is my account flat" questions
answer themselves.

## The dual auction

Grant ads serve **only on the inventory paid advertisers leave behind**, and they **always rank below**
paid ads. A grant campaign is competing in a second, residual auction, not the main one.

Consequences that look like bugs but are not:
- **Impression share under 10% is normal.** It is not a problem to fix; it is the ceiling of the residual
  auction.
- **Low spend is often an inventory ceiling, not a misconfiguration.** There is only so much leftover
  inventory to serve on.
- **Only conversion-based bidding escapes the $2.00 CPC cap.** Maximize Conversions does; Maximize Clicks
  does not; Target Impression Share does not.

## Reading impression share (the cheapest diagnostic there is)

Pull impression share every pass, **split by rank vs budget**:

- **Lost to rank, ~0% lost to budget** -> the $2 bid cap and the residual auction. **No amount of budget
  fixes it.** The levers are conversion-based bidding, better ads/QS, and reaching more inventory (e.g.
  PMax Search+Maps at the right stage), not money.
- **Lost to budget** -> the opposite: real demand you are not funding. Raise or rebalance budget within the
  $329/day cap.

This one split explains a flat account to a worried director in a sentence, and it costs one field on a
report you were already pulling.

## Budget mechanics

Every campaign gets **$329/day** (the Ad Grants daily equivalent). Google caps at the **account level**,
so splitting the allowance across campaigns only throttles them. Do not "save" budget by giving campaigns
less.

## The volume ceiling is usually not keywords

Once an account is keyword-complete, the cap on volume is the dual auction itself, not a missing keyword.
The levers that actually add reach are structural (bidding mode, PMax Search+Maps, reviving a dead
campaign), gated by the maturity stage. Adding more near-empty category keywords does nothing.
