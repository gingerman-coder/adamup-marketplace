# Tier 2: putting Google Analytics on the user's website, per platform

Use this only when Tier 0.5 and Tier 1 of `conversion-ladder.md` found no Google tag and no GA4 on the
site. The goal is a GA4 property that receives data, so Tier 1 can then finish with zero site edits.

## Order of work

1. **Detect the platform yourself; never ask.** Fetch the live home page (`scrape_website`) and match:
   - `static.wixstatic.com` or `wix.com` in the HTML -> Wix
   - `squarespace.com` or `static1.squarespace.com` -> Squarespace
   - `wp-content` or `wp-includes` -> WordPress
   - `webflow.com` or `data-wf-site` -> Webflow
   - none of these -> Other
2. **Make sure a GA4 property exists.** If `ga4_account_summaries` returns none, use the one-visit
   analytics.google.com walkthrough in `adamup-onboard` Step 6 first.
3. **Get the measurement ID yourself** with `ga4_data_streams` (it looks like `G-XXXXXXXXXX`). The user
   pastes this ID. Never ask them to find it, and never generate or paraphrase a code snippet.
4. **Do it for them in the browser** (next section) when the app gives you a browser tool. Only if there is
   no browser tool, or the browser route fails twice, give the one platform's manual steps below, one step
   per line, with the ID in a copyable code span.
5. **Verify without asking.** Wait about a minute, then check `ga4_event_has_volume` for `page_view` (and
   re-fetch the site for the ID). When data arrives, go straight to Tier 1. If nothing arrives after two
   checks, name the likely cause from the platform's notes below and give that one fix.

## Fastest: you do it in the browser, they only sign in

Use the browser tool the app provides: in Claude, the built-in browser or Claude in Chrome; in Codex,
its browser or computer-use tool when available. Check which exists from your tool list; never install one.

1. Say, in one message: "I can add Google Analytics to your website for you. I will open your
   <platform> login in a browser. Please sign in yourself; I never see or type your password. Tell me
   when you are in." Their reply is the go-ahead for this one change.
2. Open the platform's sign-in page: Wix `https://www.wix.com/signin`, Squarespace
   `https://login.squarespace.com`, WordPress `<site>/wp-admin`, Webflow `https://webflow.com/login`.
   Stop and wait. **Never type a password, a one-time code or a recovery answer, and never click past a
   CAPTCHA.** Those are always the user's.
3. When they say they are in, take over: read the page (prefer reading text over screenshots), go to the
   path in the platform's section below, paste the `G-` ID, and click Save. On Webflow also click
   Publish. On WordPress, installing Site Kit asks them to sign in with Google: hand that one screen back
   to them, then continue.
4. Touch nothing else on their site. If the page asks to pay, upgrade, change a domain, or delete
   anything, stop and tell them what it asked. If a menu label differs from the section below, read the
   page and find the Google Analytics setting; if you cannot find it in two tries, switch to the manual
   steps.
5. Say what you changed in one line ("Added Google Analytics ID G-XXXX to your Wix site and saved"),
   then verify (step 5 above).

Menu labels change. If the user says a label is not there, ask for a screenshot of what they see and
guide from that. Do not guess a different menu path.

## Wix

Use Wix's built-in Google Analytics connection, no code:

1. Open your site's dashboard at wix.com and click **Marketing & SEO**, then **Marketing Integrations**.
2. Find **Google Analytics** and click **Connect**.
3. Paste `G-XXXXXXXXXX` and click **Save**.

Notes: Wix needs a connected domain (a paid plan) for marketing integrations. On a free `wixsite.com`
address this option may be locked; tell the user plainly and keep campaigns PAUSED.

## Squarespace

1. In Squarespace, open **Settings**, then **Developer Tools**, then **External API Keys** (on some
   versions: **Settings**, **Advanced**, **External API Keys**).
2. In **Google Analytics**, paste `G-XXXXXXXXXX` and click **Save**.

Notes: If that field is missing, the fallback is **Code Injection** (Settings, Developer Tools), which is
only on some paid plans. Only then give the Google tag from the GA4 stream's "View tag instructions" page,
copied by the user from Google, pasted into the **Header** box.

## WordPress (self-hosted, wp-admin)

Use Google's own official plugin, Site Kit:

1. In your WordPress admin, go to **Plugins**, then **Add New**, search **Site Kit by Google**, click
   **Install**, then **Activate**.
2. Click **Start setup** and sign in with the same Google account you connected to AdamUp.
3. When asked, connect **Analytics** and choose the existing property for this site.

Notes: On WordPress.com (no wp-admin plugin page), plugins need a paid plan. On a free WordPress.com site,
say so plainly and keep campaigns PAUSED.

## Webflow

1. In Webflow, open **Site settings**, then **Apps & integrations**.
2. Under **Google Analytics**, paste `G-XXXXXXXXXX` and click **Save**.
3. Click **Publish** at the top right. Nothing goes live until the site is published.

Notes: The usual failure is forgetting to publish.

## Other or unknown

Ask once who manages the website. If it is someone else, write a short, copyable message they can forward
to that person: "Please add Google Analytics measurement ID `G-XXXXXXXXXX` to every page of our website
(platform setting or the Google tag in the page head) and publish." Then keep the proposal PAUSED and
resume verification when the user says it is done.
