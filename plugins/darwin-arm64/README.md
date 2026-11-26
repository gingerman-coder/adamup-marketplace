# AdamUp

Run a nonprofit's Google Ad Grant account with guided setup, account questions and weekly review. Five
skills share one Google Ads engine: `adamup-grant`, `adamup-onboard`, `adamup`, `adamup-ask`, `adamup-fix`.

This private source repository builds native plugins for Claude Code and Codex. See the
[build contracts](docs/desktop-plugins/host-contract.md) for package details.

## Claude installation

After publication, install the native plugin from the GitHub catalog:

```
claude plugin marketplace add gingerman-coder/adamup-marketplace
claude plugin install run-adamup@adamup
```

Local MCP workflows require a desktop host that can launch the bundled engine.

A generated Claude native candidate also contains its own marketplace. For isolated developer testing,
set CLAUDE_CONFIG_DIR and ADAMUP_DATA_DIR to new test directories, then run:

```sh
claude plugin validate /absolute/path/to/claude-darwin-arm64
claude plugin marketplace add /absolute/path/to/claude-darwin-arm64
claude plugin install run-adamup@adamup
claude plugin list --json
```

Start or resume explicitly with `adamup-onboard` or “set up AdamUp”, including when installed during a
conversation. The existing Claude hook is only a reminder. Google sign-in opens a browser; missing website
tracking may need a separate website settings step. Setup asks you to confirm the nonprofit account and
builds campaigns PAUSED. Activation requires tracking evidence and separate approval.

## OpenAI local desktop installation

See the [Codex package guide](targets/openai/README.md) for the generated package and the
[GitHub catalog](https://github.com/gingerman-coder/adamup-marketplace) for installation.

## Runs and approval

Type “run adamup” for account review, or ask a specific question. Recommendations lead with spend,
impressions, clicks, page views and Search-only click rate. A page-view bidding action is distinct from a
real meaningful conversion for compliance. Broad non-brand keywords, exact brand, $329/day campaign ceilings,
paused defaults, blocked deletion and engine preview/confirmation remain in place.

Weekly local runs are optional. The host must register and read back one schedule owner; the computer and
app must be running. Unattended low-risk actions require explicit stored standing permission covering those
actions. Structural and unauthorized changes wait for review. Without permission, a run stays read-only.
Notifications and missed-run behavior depend on the tested host. A/B tests run natively in the engine
(`ab_*` tools) once an account clears the volume gate.

## Privacy and local data

Google tokens and durable profile state remain on your computer, outside the replaceable plugin cache.
The engine uses `ADAMUP_DATA_DIR` or `~/.adamup`; operator credentials under `~/.mcp-google-ads` are separate.
Google and the selected model host process information needed for account work under their services.
AdamUp collects no diagnostics. Nothing is sent to AdamUp; the only network traffic is your own calls to Google.


Updates replace package files, not account records. Use a compatible pinned engine; do not silently replace
a bundled binary. Stop an incompatible downgrade and recover through supported backups rather than
rewriting state. Uninstall through the host and inspect/pause its schedule separately. Local records remain
unless you explicitly request deletion.

## Recovery and development

AdamUp is free and unsupported. Invoke `adamup-fix` for redacted diagnostics and a copyable support summary or issue draft. Do not include
tokens, credentials or account IDs in a public issue, and do not submit or email diagnostics automatically.
The plugin is free; account decisions still need the permissions described above.

The shared engine lives in the separate `gingerman-coder/mcp-google-ads` repository. Python collect/recommend
scripts are development oracles, not alternate live execution paths. Native release setup must not depend
on an undeclared Python runtime. Local build/test success does not prove OAuth, live activation, observed
weekly triggers, Windows behavior, or public availability.

MIT. See [LICENSE](LICENSE).
