---
name: local-tool-author
description: Decide whether to create or update a local deterministic tool (not skills), then author it conservatively using existing local language, conventions, and validation patterns.
argument-hint: "[repeatable hurdle/tool idea/scope]"
---

# Local Tool Author Skill

Use this skill before creating a new local tool or materially expanding an existing one.

The goal is restraint: do not create a tool for every hiccup. Create tools only for repeatable deterministic work that is safer, cheaper, and more reliable when automated.

## Decision Gate

Before writing a tool, classify the problem:

- One-off judgment problem -> do not create a tool. Answer directly or update instructions if useful.
- Repeatable decision problem -> prefer a skill, checklist, or instruction.
- Repeatable deterministic/mechanical problem -> consider a local tool.

A proposed tool must satisfy most of these:

- The hurdle is likely to recur across sessions or files.
- The operation is mechanical with clear inputs and outputs.
- Manual execution is token-heavy, tedious, or error-prone.
- Correctness can be checked deterministically.
- Failure conditions can be detected and reported clearly.
- Existing tools or scripts do not already solve it.
- The tool can be small and conservative.
- The tool can fail loudly instead of guessing.

If the tool does not clear this bar, do not create it.

## Inspect Local Conventions First

Before writing a tool:

1. Inspect existing local tools/scripts.
2. Use the language already used for comparable local tools.
3. Match naming, parameter style, output style, and validation style.
4. Prefer extending an existing tool over creating a new one when the scope naturally fits.
5. Avoid adding dependencies unless the existing tool ecosystem already uses them or the user explicitly approves.

Keep personal tools in a user-owned tools directory, separate from project repositories unless they are intentionally adopted as shared tooling. Follow the active agent environment's documented tool-discovery mechanism when available.

## Tool Design Rules

Build the smallest deterministic tool that solves the repeatable hurdle.

Prefer:

- explicit parameters
- dry-run support for file-changing tools
- precise validation before writing
- clear error messages
- conservative refusal when safety is uncertain
- smoke-testable behavior

Avoid:

- broad "framework" tools
- speculative features
- hidden network calls
- silent fallbacks
- broad catch-and-continue behavior
- changing files before validating inputs
- tool creation just to compensate for lack of planning

## Safety Checks

For file-changing tools:

- Validate all required inputs before writing.
- Preserve unrelated content.
- Prefer creating backups only if consistent with local conventions.
- Support `DryRun`/preview when practical.
- Fail before writing if the tool detects ambiguous state.
- Smoke-test with a temporary fixture, not production files, before declaring complete.

## Repeatable Verification

Every new or materially changed local tool must include a safe repeatable verification path before it is considered complete.

Prefer one of:

- a `SelfTest` mode
- a sibling test script
- a documented smoke-test command using temporary fixtures

The verification must not mutate repository files or user project files. It should create disposable inputs under the OS temp directory, assert expected outputs and refusal cases, and clean up after itself.

If a tool cannot be safely tested this way, do not create it unless the user explicitly accepts the risk.

## Output Requirements

When proposing or creating a tool, report:

- why a tool is warranted instead of an instruction or skill
- existing convention inspected and chosen language
- tool path
- supported inputs/outputs
- conservative refusal cases
- validation performed

Do not run git commit or push.
