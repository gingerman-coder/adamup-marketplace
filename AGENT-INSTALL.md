# AdamUp: install instructions for the agent

You are installing the AdamUp plugin for a non-technical user. Do every step yourself. Ask the user
nothing except what is marked USER. Keep messages short and plain.

1. Detect the platform with one command:
   - macOS: `uname -m` (`arm64` means Apple silicon, `x86_64` means Intel).
   - Windows: the platform is Windows (`$env:PROCESSOR_ARCHITECTURE` is `AMD64`).
   Pick the plugin (Claude name, then Codex name):
   - Mac with Apple silicon (M1 or newer): `run-adamup`, `run-adamup-openai`
   - Mac with Intel processor: `run-adamup-mac-intel`, `run-adamup-openai-mac-intel`
   - Windows PC: `run-adamup-windows`, `run-adamup-openai-windows`
   Any other platform: tell the user AdamUp supports Mac and Windows only, and stop.

2. Work out which app you are running in. You are Claude (Claude Code or the Claude desktop app) or
   Codex (the Codex app, the ChatGPT desktop app's Codex, or the Codex CLI). Use that app's steps only.

3. **Claude.** Add the marketplace and install:
   ```
   claude plugin marketplace add gingerman-coder/adamup-marketplace
   claude plugin install <plugin>@adamup
   ```
   Confirm with `claude plugin list` that `<plugin>@adamup` shows enabled.
   If `claude` is not found: USER: open Claude's plugin settings, add the marketplace `gingerman-coder/adamup-marketplace`, and
   install `<plugin>`.

4. **Codex.** Add the marketplace and install:
   ```
   codex plugin marketplace add gingerman-coder/adamup-marketplace
   codex plugin add <codex plugin>@adamup
   ```
   Confirm with `codex plugin list --marketplace adamup --json`.
   If `codex` is not found or the CLI does not support plugin installation: USER: open Codex's
   plugin settings, add the marketplace `gingerman-coder/adamup-marketplace`, and install `<codex plugin>`.

5. If install failed, show the user the one-line error and stop. Never download files from anywhere
   else, never use sudo, never edit settings files by hand.

6. Tell the user, in one short message:
   USER: "AdamUp is installed. Quit and reopen the app, then say: set up AdamUp."
