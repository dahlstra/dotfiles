---
name: handoff
description: Produce or interpret self-contained handoffs for fresh sessions. Defines the shared document format (Implementation, Continuation, Review fixes); may also be consulted as a task-contract reference.
argument-hint: "What will the next session be used for?"
---

# Handoff

Use this format to produce or interpret a handoff that lets a fresh session, on any model, continue the work without this conversation. Producers and receivers use these section names exactly.

Loading this skill is not a request to create a document. When reading a handoff or consulting the format, do not ask for a destination or write files. Apply Destination and Writing Rules only when the user requests a document. Ordinary plans and direct tasks do not require this skill.

If the user passed arguments, treat them as the next session's focus and tailor the document to it.

## Destination

- Ask where to save the document unless the user already said. Do not assume a default directory.
- Write inside a repository working tree only when the user names a path there.
- File name: kebab-case ending in `-handoff.md`. Prefix the work-item number when known, and `unit<N>-` for one unit of a multi-unit plan, for example `60098-unit2-zone-validation-handoff.md`.
- Do not overwrite an existing file without asking. Report the full path when done.

## Writing Rules

- Self-contained: no "as discussed above." Record decisions and reasons, not the conversation that produced them.
- Compact: cite files, symbols, and line ranges instead of pasting code. Include snippets only when exact text matters.
- Label requirements versus suggestions, and observed facts versus inferences.
- Redact secrets, credentials, and personal information.
- Omit a section only when it would be empty; write "None" under Non-Goals and Open Questions rather than omitting them.

## Receiving a Handoff

- Read the supplied document and any linked original contract; do not require the producing agent or its conversation.
- Compare the recorded repository state and prerequisite outcomes with the current workspace. A changed HEAD alone is not a blocker; distinguish expected progress from changes that invalidate decisions or assumptions.
- Report missing references or contradictory evidence. Ask only when they leave a material gap in the task contract.
- A handoff supplies context, not authorization to edit. Follow the active role and approval policy.

## Core Sections

Start with `# Handoff: <title>` and a `Kind:` line (`Implementation`, `Continuation`, or `Review fixes`), then these sections in order:

0. `## Required Preflight` — **Step 0.** Skills that must be invoked and instruction files that must be read before any investigation or edit, each with a one-line reason. Include the instruction files matched by the target file patterns, not only skills. State that handoff constraint summaries do not substitute for loading them. Write `None` only when nothing is required.
1. `## Goal` — the outcome the next session must achieve.
2. `## Repository State` — repository, branch, HEAD commit SHA (or no commits), base when relevant, and relevant staged, unstaged, and untracked changes at handoff time.
3. `## Settled Decisions` — each decision with its rationale and any rejected alternative worth remembering. Settled unless new evidence contradicts them.
4. `## Constraints`
5. `## Invariants to Preserve`
6. `## Non-Goals`
7. `## Assumptions` — each with why it matters and what observation would disprove it.
8. `## Evidence` — investigated files and symbols, and what each established.
9. `## Validation Policy` — ownership (`agent`, `user`, or `hybrid`); exact commands or `none requested`; manual steps; budget or exclusions (for example, `do not run the full solution build`).
10. `## Recommended Skills` — **Recommended** skills only, each with a one-line reason tied to the task; required skills belong in `## Required Preflight`. List only skills the runtime reported as available.
11. `## Open Questions` — unresolved questions or blockers.

Kind-specific sections follow the core sections.

## Kind: Implementation

For work planned in one session and implemented in another.

- `## Required Changes` — required behavior. Prescribe mechanics only when they are a settled decision.
- `## Acceptance Criteria` — observable checks.
- `## Risk Areas`
- `## Suggested Order` — steps with target locations. The Implementer may reorder independent steps.

For a multi-unit plan, write one file per unit and add `## Unit Map` after `## Goal`: the overall goal, each unit with a one-line scope and its relationship (`Same unit`, `Ordered` after a named unit, `Independent`, or `Deferred`), and which unit this file covers.

For each Ordered unit, identify the prerequisite unit and the observable outcome or interface that must be present before this unit starts.

## Kind: Continuation

For resuming the same role in a fresh session, for example when context runs out.

- Link the original handoff if one exists, and include only the core sections that changed since it. If the original cannot be made available to the receiving session, include the necessary core contract instead of relying on the link.
- `## Progress` — completed work and files changed.
- `## Remaining Work`
- `## Deviations` — differences from the original task contract, with reasons.
- `## Current Problem` — failing condition, exact errors, and hypotheses already tested with their results. Omit when there is no active problem.

## Kind: Review fixes

For handing review findings to an Implementer.

- `## Reviewed Scope` — refs or diff reviewed, and coverage limits.
- `## Findings to Fix` — one subsection per finding: severity, location, defect, evidence, impact, and acceptance criteria for the fix. Describe the required outcome; prescribe a patch only when the fix is settled.
- `## Observations Not Requested` — mention-only items. The receiving Implementer must not act on them without approval.