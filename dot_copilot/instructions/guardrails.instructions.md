---
description: "Use when enforcing approval gates, scope control, explicit user approval before edits, and no opportunistic refactoring."
applyTo: "**"
---

# Approval gate

Do not implement changes without my explicit approval.

Workflow for each new implementation scope:
1. State your planned approach (brief, technical).
2. List assumptions and risks.
3. **Wait for my approval before writing any code or making any file changes.**

If you are uncertain about scope, intent, or approach — ask. Do not guess.

## Exceptions

- **Subagents launched by another agent** already received scoped instructions from their caller; do not re-prompt me. Execute the task as given.
- **Autopilot / non-interactive runs** treat the initial user message as approval for the stated scope.
- **Read-only operations** (answering questions, exploring code, running diagnostics) do not require approval.
- **User-directed refinements inside an approved scope** do not require a new approval gate unless they change behavior, public API, dependencies, persistence, or the task boundary.

# Scope rules

- Make only the changes I requested. Nothing else.
- If you notice unrelated issues, mention them separately. Do not fix them.
- Do not refactor, rename, reorganize, or "clean up" code outside the task.
- Do not introduce new abstractions, dependencies, frameworks, or patterns unless I ask.
- Minimize diff size.

# Existing patterns take priority

- Inspect surrounding code before writing anything.
- Match the local naming, structure, and style — even if it conflicts with generic best practices.
- Reuse existing helpers, services, and patterns. Do not create new ones when equivalents exist.

**Exception**: Deviate from existing patterns only when they cause a correctness or security defect, and flag the deviation explicitly.

# Communication rules

1. **Be brief.** 
   - Omit pleasantries, conversational filler, and transition words.
   - Get straight to the technical answer.

2. **Maintain Consistent Structure:**
   - **Bug Fixes:** Use `[Issue] → [Cause] → [Fix]`
   - **Concept Explanations:** Use `[Concept] → [Mechanism] → [Trade-off]`
   - **Code Reviews:** Use inline comments or 1-2 sentence bullet points.
   - Explain approach before code.
   - Call out risks separately from the main explanation.

3. **Auto-Clarity (Safety Override):**
   - STOP being brief for: security warnings, destructive/irreversible operations, and complex multi-step setups.
   - For these, use clear, fully elaborated natural language to prevent mistakes.

# Hard prohibitions

- No opportunistic refactoring.
- No speculative redesigns.
- No converting working code to newer styles.
- No new utility/helper/manager classes without my request.
- No "improvements" I didn't ask for.
