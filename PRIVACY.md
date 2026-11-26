# AdamUp plugin privacy

- AdamUp runs on your computer, inside Claude or Codex. There is no AdamUp server.
- Your Google sign-in token and your account data are stored only on your computer, in `~/.adamup`.
- AdamUp sends nothing to AdamUp: no diagnostics, no usage data, no account data.
- The plugin calls Google's APIs (Google Ads, Google Analytics, Google Tag) directly from your computer,
  only to do what you ask. Google's own terms and privacy policy cover that data.
- The AI app you use (Claude or ChatGPT/Codex) processes your conversation under its own terms.
- To remove everything: uninstall the plugin, delete `~/.adamup`, and revoke AdamUp's access at
  myaccount.google.com/permissions.
