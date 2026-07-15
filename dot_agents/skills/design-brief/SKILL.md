---
name: design-brief
description: >
  Produces a technology-agnostic design brief describing the desired user
  experience, visual language, interaction philosophy, and design rationale for
  a software application. Use before UI prototyping, implementation, or design
  critique when the visual direction has not yet been established.
---

# Purpose

Your job is to transform product requirements into a concise but complete Design
Brief.

The Design Brief defines **what the interface should communicate**, not how it
will be implemented.

It is intentionally technology-agnostic. Avoid discussing HTML, CSS, WPF,
WinUI, React, Flutter, MAUI, SwiftUI, Qt, or implementation details unless the
chosen platform materially influences user expectations.

The Design Brief becomes the source of truth for downstream skills such as:

- UI prototyping
- UI critique
- style guide generation
- UI implementation planning
- design reviews

---

# When to Use

Use this skill when the product direction is known, but the interface's design
intent is not yet explicit.

Good fits:

- new application concepts
- major redesigns
- UI prototypes that need visual direction
- design critiques where success criteria are unclear
- implementation handoffs that need a shared UX target

Do not use this skill for:

- small UI fixes
- bug fixes
- copy-only changes
- implementation questions
- cases where a complete design brief, style guide, or mockup already exists

---

# Overall Philosophy

Good interface design is the result of deliberate decisions rather than
accidental defaults.

Infer as much as possible from the requirements.

Only interrupt the user when a design decision is:

- high-impact,
- genuinely ambiguous,
- and cannot be reasonably inferred.

Avoid questionnaires for their own sake.

---

# Process

## 1. Understand the Product

Identify, where possible:

- application purpose
- primary workflows
- target platform
- target audience
- user expertise
- operating environment
- constraints
- business goals

Record assumptions.

---

## 2. Infer Design Intent

For each of the following dimensions, determine an appropriate value.

These dimensions are guides rather than mandatory sections.

### Product Domain

Examples:

- Scientific instrument
- Engineering
- Medical
- Industrial
- Enterprise
- Consumer
- Education
- Finance
- Creative
- Government
- Internal tooling

---

### Target Audience

Examples:

- novice
- occasional
- expert
- administrator
- technician
- scientist
- engineer
- analyst

---

### Personality

Describe the emotional qualities the interface should communicate.

Examples:

- trustworthy
- technical
- professional
- conservative
- precise
- calm
- approachable
- elegant
- industrial
- playful

---

### Information Density

Examples:

- spacious
- moderate
- dense
- extremely dense

---

### Interaction Philosophy

Examples:

- guided
- discoverable
- workflow-oriented
- expert-first
- keyboard-first
- mouse-first

---

### Visual Weight

Describe the visual emphasis.

Consider:

- borders
- panel separation
- shadows
- cards
- whitespace
- hierarchy

---

### Geometry

Describe the overall geometric language.

Examples:

- square
- subtly rounded
- moderately rounded
- soft

Discuss:

- alignment
- symmetry
- spacing
- control sizing

---

### Color Strategy

Describe how color should be used.

Examples:

- restrained
- neutral
- accent-driven
- status-driven
- vibrant
- high contrast

---

### Typography

Describe typography goals.

Examples:

- readable
- compact
- technical
- modern
- information-dense

---

### Motion

Describe animation philosophy.

Examples:

- none
- minimal
- moderate
- expressive

Favor restraint unless animation improves usability.

---

### Familiarity

Determine whether the interface should prioritize:

- convention
- innovation

Users generally value familiarity over novelty in productivity software.

---

### Comparable Software

Identify existing software whose interaction model or visual language would be
helpful inspiration.

These are references, not templates.

Examples:

- Visual Studio
- Excel
- MATLAB
- Photoshop
- SolidWorks
- VS Code
- Laboratory instrument software

---

### Anti-Goals

Explicitly identify aesthetics and interaction patterns to avoid.

Examples:

- avoid fintech dashboards
- avoid oversized cards
- avoid excessive whitespace
- avoid mobile-first layouts
- avoid decorative animations
- avoid highly rounded corners

Anti-goals are often as valuable as positive goals.

---

# Confidence

Assess your confidence for each major design decision.

Use one of:

- High
- Medium
- Low

High confidence means the decision follows naturally from the requirements.

Low confidence indicates multiple reasonable interpretations.

---

# Clarification

If any **high-impact** decision has Low confidence, ask focused questions before
producing the Design Brief.

Ask only about the dimensions that materially affect the design.

Never ask about dimensions that already have High confidence.

Keep questions concrete.

Prefer:

"What existing software should this resemble?"

instead of

"What style do you want?"

If the remaining uncertainty would not materially change the design direction,
state the assumption and continue.

---

# Output

Produce a Design Brief using this structure:

## Overview

Summarize the product, audience, operating context, and intended experience.

## Design Goals

Describe what success looks like for users and stakeholders.

## Design Dimensions

Summarize the inferred design decisions.

Do not mechanically include every dimension if it adds no value.

Use concise labels such as:

- Domain
- Audience
- Personality
- Information Density
- Interaction Philosophy
- Visual Weight
- Geometry
- Color Strategy
- Typography
- Motion
- Familiarity

## Comparable Software

Include only references that clarify interaction model, visual language, or user
expectations.

## Anti-Goals

List aesthetics, behaviors, or patterns to avoid.

## Assumptions

Document important assumptions that influenced the design direction.

## Open Questions

Include only unresolved questions that could materially change the design
direction.

## Design Intent Summary

Conclude with one concise paragraph describing the overall feeling the interface
should create.

---

# Handoff Contract

Downstream agents should treat the Design Brief as design intent, not as a
component specification.

The brief should be specific enough that a UI prototyping or critique agent can:

- choose layout density and hierarchy
- select an appropriate visual language
- avoid mismatched reference styles
- explain why design decisions fit the product
- identify when a mockup violates the intended experience

The brief should not prescribe:

- framework-specific implementation details
- exact component APIs
- pixel-perfect dimensions
- final color tokens
- production-ready copy

---

# Principles

- Design for users rather than trends.
- Favor consistency over novelty.
- Favor clarity over decoration.
- Favor usability over visual flourish.
- Match the expectations of the application's domain.
- Match the expertise of the intended users.
- Infer before asking.
- Ask before guessing when ambiguity significantly changes the result.
- Explain design decisions when they may not be obvious.