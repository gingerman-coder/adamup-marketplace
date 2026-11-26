# Desktop host contract, revision 1

Agreed implementation boundary, 2026-10-21. Shared skills contain advertising decisions. `skills/reference/host-runtime.md` supplies host behavior. A skill's package root is two directories above its installed `SKILL.md`; references live at `skills/reference/` and helpers at `scripts/`. Resolve from the actual installed skill, never the current working directory. The OpenAI exporter substitutes only this reference.

Both hosts expose the same five skill IDs. Resolve installed MCP operations by their advertised schemas, never a session-specific prefix. Before stateful work call `adamup_capabilities`; reject an incompatible state schema or unavailable required capability. Explicit setup must work without lifecycle hooks. OpenAI packages contain no hooks; Claude keeps its existing hook and plugin identity.

Questions use available question tools or short ordinary text. Scheduling uses only supported host tools, with readback of task ID/status. No scheduler-file edits, cron substitutes, or invented notification operations. Store one host owner plus generation in engine-owned state and put both in scheduled prompts. A stale generation exits before writes. Never activate a second schedule unless the previous schedule is confirmed disabled. If registration/readback is unavailable, manual runs remain available and scheduling is unavailable. Local runs require the app and computer running; notification and missed-run behavior require observed evidence.

Unattended work requires explicit persisted standing authorization for bounded low-risk actions. Recommendations cannot authorize themselves. Structural actions remain queued. Engine preview/confirmation remains mandatory. A/B execution is disabled until a supported credential bridge and lifecycle are proven; preserve its explanatory reference material.

Do not edit durable JSON in skills or use legacy Python state writers. Use engine state operations. Optional developer helpers must declare Python; native release onboarding cannot require undeclared runtimes. Preserve consent and account records on uninstall/update unless the user explicitly requests deletion. No host hook is a prerequisite for setup.

Fixture data isolation: set ADAMUP_DATA_DIR explicitly for every harmless host/engine fixture. CODEX_HOME
isolates host configuration/cache, not the engine's default profile. The observed CLI fixture kept the
real shell HOME; do not assume changing host config relocates ~/.adamup or credentials. The generated
production package deliberately uses the user's local profile unless explicitly configured otherwise.
Desktop UI executor HOME/data-directory mapping remains NOT RUN and must be verified separately. Hooks
respect the same ADAMUP_DATA_DIR override and do not write JSON.
