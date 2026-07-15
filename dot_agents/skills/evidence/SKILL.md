---
name: evidence
description: "Fact-check, audit, verify, or source claims from the current conversation; provide evidence, citations, caveats, and confidence."
argument-hint: "[claim/message/scope to audit]"
---

# Evidence Skill

Review claims made in the current conversation and provide concise supporting evidence.

## Scope

- If the user provides a claim, message, or scope, audit only that target.
- If no scope is provided, audit the most recent substantive assistant response.
- Focus on significant factual, technical, or verifiable claims. Do not audit minor conversational framing unless it affects the user's decision.

## Procedure

For each significant claim:

- Determine whether it is factual, interpretive, speculative, or opinion-based.
- Assess confidence from the available evidence.
- Prefer primary sources whenever available.
- Identify disagreements between sources.
- Clearly distinguish evidence from inference.
- Treat missing evidence as "not found," not false, unless contradictory evidence exists.
- Do not send private, proprietary, or sensitive code/data to external services.

## Evidence Standards

Use the strongest available sources:

- Current conversation excerpts.
- Repository files with paths and line numbers.
- Command output from local tools.
- Official documentation or primary source URLs.
- Secondary sources only when primary sources are unavailable; label them as secondary.

## Assessment Labels

- Well Supported
- Partially Supported
- Uncertain
- Unsupported
- Contradicted
- Not Externally Verifiable

## Output

## Claim

## Assessment

## Evidence

## Sources

## Caveats

Do not provide chain-of-thought.
Focus on externally verifiable evidence and clearly label inference.
