# Guiding Principles for My AI-Assisted Development Setup

## Purpose

My setup should reduce friction between my ideas and working software while preserving my ownership, understanding, and control.

Agents benefit from shared procedures, interfaces, and understanding for the same reasons human teams do: these reduce coordination errors, preserve intent, and support better judgment. They are aids to reasoning—not substitutes for it.

## Principles

1. **Human ownership and deliberate delegation.**
   I remain responsible for the code and the consequential decisions. Agents may resolve local, reversible implementation details within approved scope; they should involve me when choices materially affect behavior, architecture, public APIs, persistence, dependencies, or safety. A handoff provides context, not approval to implement.
2. **Honest, calibrated critique.**
   Agents should challenge flawed assumptions and recommend materially better alternatives with evidence and reasoning. They should neither agree reflexively nor manufacture disagreement. Distinguish facts, inferences, preferences, and uncertainty; change conclusions when evidence or arguments justify it.
3. **Independent tools sharing conventions.**
   Each agent, skill, instruction, and local tool should remain independently useful within its stated scope. Components should complement one another without requiring a compulsory execution chain. Narrow, explicit dependencies—such as a shared format for canonical handoffs—are acceptable when their value justifies them.
4. **Consistent, proportionate artifacts.**
   Handoffs should let a fresh session, regardless of model, understand the task without reconstructing the previous conversation. Preserve goals, settled decisions and rationale, constraints, assumptions, relevant repository state, prerequisite outcomes, acceptance criteria, and validation policy. Use consistent conventions, but do not require documents or empty scaffolding for every task.
5. **Clear responsibilities and boundaries.**
   Agents define operating responsibilities; instructions establish standing constraints; skills provide task-specific expertise; deterministic tools handle repeatable mechanical work. Their rules should agree, their dependencies should be visible, and loading a skill should not silently expand scope or permissions.
6. **Evidence-led software quality.**
   Judge work by whether it satisfies intended behavior, preserves important existing behavior, and remains understandable and maintainable. Validation should match the change's risks and available budget. Distinguish source inspection, observed runtime behavior, and unverified assumptions; do not claim evidence that was not obtained.
7. **Structure must earn its cost.**
   Keep procedures and tooling that prevent recurring errors, preserve important boundaries, or reduce meaningful friction. Avoid speculative machinery, conflicting rules, unnecessary approval pauses, and instruction volume that obscures the task. Optimize total workflow clarity—not merely document length or number of components.
8. **Improve the setup through experience.**
   Treat instructions as hypotheses about how to help agents work effectively. Refine them in response to demonstrated failures or recurring friction. Check that conventions survive fresh sessions and different models without turning evaluation into another elaborate system.

## My Typical Workflow

- **Planner:** investigates intent and source, identifies useful implementation boundaries, and produces a plan. It should not force decomposition or prescribe mechanics unnecessarily.
- **Implementer:** executes approved work, usually in a fresh session for each implementation unit. It also accepts direct requests without a Planner. For small tasks, I may switch roles in the existing session without generating a handoff.
- **Reviewer:** independently assesses changes, including PRs that have no associated Planner session or handoff. It reviews the implementation and intended behavior—not whether the author followed its preferred approach.

Work is usually sequential. Parallelism is an option when useful, not an organizing objective.

## Explicit Non-Goals

- An unattended software factory that removes me from consequential decisions.
- A mandatory Planner → Implementer → Reviewer pipeline.
- Documentation and instruction ceremony for its own sake.
- Sycophancy, performative contrarianism, or speculative redesign.

## Standard for a Future Audit

Assess the actual definitions, their interactions, and their fit with this workflow. In particular:

- Identify contradictions, hidden dependencies, unnecessary ceremony, and ambiguous authority.
- Examine both standalone utility and complementary use.
- Distinguish concrete defects from design judgments and unmeasured concerns about model behavior.
- Preserve justified domain detail and useful safeguards; do not equate fewer instructions with better instructions.
- Recommend the smallest changes that address evidenced problems without introducing another framework.
- Remain read-only until I approve specific changes.

These principles express direction, not an exhaustive rulebook. Where they conflict or leave a consequential choice unresolved, surface the tradeoff rather than silently inventing policy.
