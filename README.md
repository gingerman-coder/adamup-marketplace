# Install AdamUp

AdamUp runs your nonprofit's Google Ad Grants account from Claude. It is free. Nothing is sent to
AdamUp: your Google sign-in and account data stay on your computer.

## The easy way: let Claude install it

1. Install the Claude desktop app from claude.ai/download and sign in.
2. Open the **Code** tab, pick any folder (your Documents folder is fine), and paste this message:

> Install the AdamUp plugin for me. Follow the instructions at
> https://github.com/gingerman-coder/adamup-marketplace/blob/main/AGENT-INSTALL.md

3. When Claude says it is done, quit and reopen Claude, then say **set up AdamUp**.

Claude will ask you to sign in with Google once. That is the only step only you can do.

## Using ChatGPT instead (Codex)

1. Install the Codex app or the ChatGPT desktop app with Codex, and sign in.
2. Paste the same message into Codex:

> Install the AdamUp plugin for me. Follow the instructions at
> https://github.com/gingerman-coder/adamup-marketplace/blob/main/AGENT-INSTALL.md

3. When it is done, restart Codex and say **Run AdamUp setup**.

## What you need before starting

- A Google Ad Grants account (Google for Nonprofits approval). If you do not have one yet, say
  **help me apply for Google Ad Grants** after installing and AdamUp walks you through it.
- Your website login is NOT usually needed: if your site already has Google Analytics, AdamUp sets up
  tracking without touching the site.

## Which plugin is which

| Your computer | Claude plugin | Codex plugin |
| --- | --- | --- |
| Mac with Apple silicon (M1 or newer) | `run-adamup` | `run-adamup-openai` |
| Mac with Intel processor | `run-adamup-mac-intel` | `run-adamup-openai-mac-intel` |
| Windows PC | `run-adamup-windows` | `run-adamup-openai-windows` |
