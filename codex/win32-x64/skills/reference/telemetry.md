# Product diagnostics

AdamUp collects no diagnostics. The engine has no diagnostics server, so nothing is queued or sent, and
there is no notice to show and nothing to opt out of. The only network traffic is the user's own calls to
Google.

If the user asks about telemetry, privacy or "turn off telemetry", call `adamup_telemetry` operation
`status`, then tell them in one sentence that it is off and cannot be turned on in this version. Never
ask the user an opt-in question and never block setup on it.
