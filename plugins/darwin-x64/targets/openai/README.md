# AdamUp for local ChatGPT Work and Codex

Development candidate, not a published or approved OpenAI directory listing. Five shared skills provide
grant assistance, setup, weekly optimization, account questions/commands and repair. They use the same
Google Ads engine and advertising doctrine as the Claude package.

## Install and start

Use the generated marketplace instructions and commands supplied with the build's acceptance artifacts.
The developer path uses a local Git/folder marketplace registered through supported Codex plugin commands;
a ZIP alone is not a verified installer. A package copied to an arbitrary directory must include its engine
and all shared references. The portable manifest declares local execution and Run setup. In a local chat,
choose Run setup or explicitly invoke `adamup-onboard`, including after installation mid-conversation.

For a generated native marketplace, use these supported local commands, replacing the path with the complete
marketplace directory supplied with this candidate:

```sh
codex plugin marketplace add /absolute/path/to/openai-native-marketplace
codex plugin add run-adamup-openai@adamup-openai-local
codex plugin list --marketplace adamup-openai-local --json
```

For isolated developer testing, set CODEX_HOME to an empty test directory and ADAMUP_DATA_DIR to a separate
empty profile before these commands. CODEX_HOME alone does not isolate the engine's account data. The build
acceptance report distinguishes CLI/runtime checks from untested desktop setup invocation. Use one selected
profile per account across both hosts; old unpatched packages must be disabled or upgraded before migration.

A developer npm package requires Node.js and its exact pinned engine version. The published older engine
may lack this candidate's state/capability operations; setup stops safely in that case. A native candidate
contains a selected platform binary. macOS/Windows support, signing and clean-machine behavior require
actual platform tests, separate from cross-compilation or archive validation. Read the build ledger for
what was tested. No Rust, Node or Python prerequisite is intended for the final native release.

## Setup and account changes

Google sign-in opens Google's page in your browser and stores the token locally. Confirm the nonprofit
account before the engine binds state to it. Setup inspects the website, prepares conversion tracking and
builds campaigns PAUSED. Activation needs separate approval and observable tracking evidence; an unfired
conversion action does not enable launch. Account actions use previews, confirmation and audit safeguards.
A/B tests run natively in the engine once an account clears the volume gate.

## Weekly runs

Manual `run adamup` remains available. Optional desktop scheduling uses supported host automation tools,
requires registration/readback and one recorded schedule owner, and needs the app and computer running.
Unattended writes additionally require explicit stored permission for specific low-risk actions. Structural
changes wait for review. Without permission, scheduled runs produce a read-only digest and queue changes.
No continuous background execution, missed-run behavior or push delivery is promised without host tests.

## Data, updates and recovery

The engine owns local profile state under `ADAMUP_DATA_DIR` or `~/.adamup`; plugin cache folders are not
durable storage. Operator credentials under `~/.mcp-google-ads` are separate. Tokens are not returned to the
model. Account data can be sent to Google and the selected model host as needed to fulfill the workflow.
AdamUp collects no diagnostics. Nothing is sent to AdamUp; the only network traffic is your own calls to Google.


Updates replace package resources, not durable account records. Keep the compatible engine version pinned;
do not silently swap a bundled executable. On rollback, stop when an older engine cannot read newer state
and use supported backups/recovery. Uninstall through the host's plugin management UI/CLI and inspect or
pause the host schedule separately. Preserve local data unless you explicitly request deletion. Run
`adamup-fix` for a concrete redacted diagnosis. No credential or account data belongs in a public issue.

Public distribution, partner allowlisting, platform acceptance and live account canaries are separate release
gates. A local fixture install does not establish those outcomes.
