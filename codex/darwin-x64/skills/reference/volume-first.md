# Volume first, then filter

The sequencing doctrine. It is why the account launches broad (see `account-lifecycle.md` Stage 0) and why
early passes are judged differently from later ones.

## The principle

**Junk conversions now beat no conversions.** Smart Bidding needs signal, and a young account has none.
So phase one accumulates volume: broad match, wide-but-sane geo, a page-view primary conversion, Maximize
Conversions bidding. Phase two filters, once there is data to filter. Every new account is in phase one.

Judge an early pass on **spend utilization and impressions**, not on conversion rate or CPA. Reading a
week-two account by its cost-per-acquisition would condemn a perfectly healthy account for not yet having
the data it was launched to gather.

## The two things that never wait

Even in phase one, two problems are handled immediately, not deferred to the filter phase:

1. **A real, meaningful conversion action** (P1-B). A page-view primary is fine to bid on, but it is never
   the *only* thing tracked; a genuine meaningful action must be tracked alongside it.
2. **Search-only CTR below the floor.** Below ~7% forces filtering immediately, and below 5% past grace
   fires the emergency brake (`guardrails.md`). CTR is the one metric that cannot be left to accumulate.

## The objective is spend and volume

The standing objective on these accounts is to **maximize spend, impressions, clicks and page views**
within the CTR floor. Efficiency is not a goal in itself, and scaling back for efficiency is never a
recommendation. The CTR floor is the only guardrail on volume.

## The Conversions column is not impact

It is a bidding metric and runs close to the click count by design. Never report it to the user as impact
and never read P1-B off the account total; segment by conversion action. Impact reporting uses spend,
impressions, clicks and page views.
