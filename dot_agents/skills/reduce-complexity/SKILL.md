---
name: reduce-complexity
description: Analyze and reduce developer-introduced complexity. Minimize code, concepts, indirection, configuration, and public surface area while preserving justified architectural boundaries.
---

# Reduce Complexity

Favor the least structural complexity that solves the problem clearly. Minimize code, concepts, indirection, configuration, and public surface area. Retain additional structure only when concrete evidence shows that it reduces greater complexity, protects an important responsibility, or supports a credible near-term need.

## Scope the review

Use the user's prompt as task-local context. Treat any stated hunch, desired direction, constraints, and protected behavior as hypotheses to investigate, not conclusions to force.

Inspect the relevant code, its callers, and nearby architectural patterns before recommending changes. Identify abstractions, wrappers, layers, registries, configuration, public APIs, or generalized machinery that make ordinary behavior harder to follow.

Code size is a strong signal of complexity and should be minimized by default. Judge the total affected workflow, not only one component. Do not reduce local code by exporting complexity to callers or violating an established architectural responsibility.

## Evaluate each candidate

For every meaningful candidate, state:

1. Its present responsibility and the concrete complexity it adds.
2. What would be lost if it were removed or inlined.
3. Evidence for that value from current behavior, the repository, or a credible near-term need.
4. Its effect on ownership, dependency direction, public surface area, and change coupling.
5. The smallest design that preserves the justified value.

Give real consequences, not generic possibilities such as "future flexibility" or "separation of concerns." Evidence for a near-term need may include approved work, active migration, sibling implementations, or concrete repository or product signals.

Architectural consistency is meaningful evidence, but not an automatic justification. Do not create a one-off exception casually, but challenge repeated ceremony rather than preserving it only because it is established. Treat one caller or one implementation as a prompt for investigation, not proof that an abstraction is unnecessary.

## Preserve demonstrated value

Keep an abstraction when it materially does one or more of the following:

- Enforces an invariant or domain rule.
- Preserves clear ownership or dependency direction.
- Isolates a volatile dependency or implementation detail.
- Supports genuinely different implementations that are currently needed or credibly near-term.
- Prevents meaningful repeated complexity, likely drift, or broad change coupling.
- Compresses meaningful domain behavior rather than merely renaming an operation.
- Establishes a boundary that makes ownership, testing, or failure handling substantially clearer.

Challenge it when it mostly renames or forwards an operation, fragments normal control flow, exposes more API than consumers need, or implies a generality the code does not use.

When relevant, account for responsibilities that may not be obvious from call structure alone, including state and resource lifecycle, concurrency, transactions, temporal ordering, failure handling, external dependencies, and test isolation.

Do not simplify by duplicating domain rules, bypassing safeguards, hard-coding special cases into unrelated components, or mixing responsibilities that change for different reasons.

Distinguish necessary problem complexity from complexity introduced by the codebase's structure. When the evidence is balanced, prefer less structure and accept later refactoring rather than paying abstraction costs prematurely.

## Report before changing code

Default to a concise, ranked review. For each recommendation, describe the tradeoff and confidence. Mark subjective or weakly evidenced judgments explicitly and invite the user's decision.

Do not refactor unless the user asks for implementation or clearly approves a recommendation. When implementing, make the smallest change that realizes the agreed simplification and verify preserved behavior with relevant checks.
