---
name: vb-scriptable-api
description: Write VB.NET Data Acquisition scripts and API examples using only members exposed via [Scriptable]. Use for smoke tests, A/B behavior checks, and copy-paste example scripts for new APIs.
argument-hint: "[goal/api under test/style constraints]"
---

# VB Scriptable API Skill

Generate VB.NET scripting examples for MeasureLINK Data Acquisition that are safe to copy-paste.

## Primary Rule

Use only APIs exposed to scripting via `[Scriptable]`.

- If a member is not `[Scriptable]`, do not use it.
- Do not rely on internal/test-only members (for example `ActiveSeriesInfo`).
- If scriptability is unclear, inspect code or docs and choose a scriptable alternative.

## VB Rules
- When calling a Sub without `Call`, no parentheses are allowed around arguments. With `Call` parentheses are required
- When calling a Function, if you use the return value, you must assign it to a variable or use it in an expression, and parentheses are required

## Output Requirements

- Produce Visual Basic script snippets that run in the MeasureLINK scripting environment.
- Prefer complete `Sub Main` examples unless the user asks for a fragment.
- Keep snippets copy-paste ready with required setup (`MeasurementResults`, columns, chart/controls, tab display) when relevant.
- Use clear PASS/FAIL checks with `If ... Then Throw New Exception(...)` or `Debug.WriteLine(...)`.

## Example Style

Match project examples in `ApiDocumentation/examples`:

- Use naming/style patterns consistent with existing VB examples.
- Prefer simple, explicit flow and comments.
- Favor practical smoke-test scripts and A/B comparisons when validating new behavior.

## Behavior for Testing Requests

When asked for tests/scripts for new APIs:

1. Prefer a scriptable black-box check over internal-state assertions.
2. Use observable outcomes in script-exposed API/UX.
3. If direct assertion is impossible from scripting, provide an A/B pattern and state the expected visible difference.

## If Blocked

If the requested validation cannot be done through scriptable APIs alone:

- Say exactly which required member is not scriptable.
- Provide the closest scriptable test approach.
- Avoid suggesting non-scriptable access patterns.
