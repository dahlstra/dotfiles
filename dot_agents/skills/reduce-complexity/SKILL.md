---
name: reduce-complexity
description: Analyze and reduce developer-introduced code complexity, especially unnecessary abstraction, indirection, wrappers, layers, configuration, and stale generality. Use when reviewing or simplifying code whose structure may no longer provide a concrete benefit.
---

# Reduce Complexity

Examine code for complexity introduced by its own structure. Favor direct, locally understandable code, but retain boundaries that provide demonstrated value.

## Scope the review

Use the user's prompt as task-local context. Treat any stated hunch, desired direction, constraints, and protected behavior as hypotheses to investigate, not conclusions to force.

Inspect the relevant code and its callers before recommending changes. Identify candidate abstractions, indirection, wrappers, layers, registries, configuration, or generalized machinery that make ordinary behavior harder to follow.

## Evaluate each candidate

For every meaningful candidate, state:

1. Its present responsibility and the concrete complexity it adds.
2. What would be lost if it were removed or inlined.
3. Evidence from the repository for that loss or benefit.
4. Whether the benefit is current and demonstrated, plausible but unproven, or obsolete.
5. The smallest simplification that preserves the demonstrated value.

Give real consequences, not generic possibilities such as "future flexibility" or "separation of concerns." Treat a single source of truth as valuable only when duplicated copies would plausibly drift or make coordinated changes meaningfully harder.

## Preserve demonstrated value

Keep an abstraction when it materially does one or more of the following:

- Enforces an invariant or domain rule.
- Isolates a volatile dependency or implementation detail.
- Supports genuinely different, currently needed implementations.
- Prevents meaningful repeated complexity or likely drift.
- Establishes a boundary that makes ownership, testing, or failure handling substantially clearer.

Challenge it when it mostly renames or forwards an operation, has one caller and implementation without credible variation, fragments normal control flow, or implies a generality the code does not use.

Do not treat small size alone as evidence for removal. Distinguish necessary problem complexity from complexity introduced by the codebase's structure.

## Report before changing code

Default to a concise, ranked review. For each recommendation, describe the tradeoff and confidence. Mark subjective or weakly evidenced judgments explicitly and invite the user's decision.

Do not refactor unless the user asks for implementation or clearly approves a recommendation. When implementing, make the smallest change that realizes the agreed simplification and verify preserved behavior with relevant checks.

## Calibrate

At the end of a review, optionally ask which recommendations matched the user's preference and which did not. Use the response to inform the current conversation; do not alter this skill unless the user asks.
