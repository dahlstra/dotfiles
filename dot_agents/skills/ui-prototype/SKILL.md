---
name: ui-prototype
description: >
  Fast HTML-first UI prototyping for aligning on screens, workflows, states,
  layout, copy, and behavior. Use when the user wants UI mocks, quick visual
  iteration, browser-based prototypes, or design-system translation for app,
  device, instrument, desktop, mobile, embedded, or web UI work.
argument-hint: "[screen/workflow/platform/fidelity/design-system notes]"
---

# UI Prototype Skill

Create fast, low-token UI prototypes that help the user and implementation agent agree on layout, states, copy, and behavior before implementation.

## Scope

Default to **HTML/CSS/JS mocks** because they are cheap, fast, portable, and easy to inspect in a browser.

This skill is **not** a native implementation skill. Do not generate production UI code for a target framework or device unless the user explicitly asks after approving the mock direction.

## Inputs to Prefer

Ask for missing inputs only when the mock would otherwise be misleading.

- Target platform or medium, if known: desktop app, mobile app, web app, embedded panel, scientific instrument front panel, WPF/Telerik, MAUI, etc.
- Screen or workflow goal
- Key user tasks
- Required states: empty, loading, normal, warning, error, disabled, busy, success
- Sample data
- Design-system notes: colors, typography, spacing, components, screenshots, docs
- Fidelity level: wireframe, styled mock, high-fidelity visual approximation
- Output goal: quick mock, stakeholder review, design alignment, behavior exploration
- Output destination, when files should be created

## When Design Direction Is Provided

If the user provides a design brief, style guide, reference mockup, product
principles, or comparable software, treat it as input for visual direction,
density, interaction philosophy, anti-goals, and assumptions.

Do not require a specific brief structure. Extract the usable design intent and
ask only when the provided direction conflicts with the user's current request or
leaves a high-impact ambiguity unresolved.

## Default Output

Produce the smallest useful artifact set:

1. A single-file HTML mock with embedded CSS and minimal JS when interaction helps.
2. A concise state table.

Prefer one complete HTML file over fragmented snippets.

## Fidelity Rules

- Use CSS variables for design tokens: color, spacing, radius, typography, elevation, borders.
- Approximate the target design system visually, but do not claim pixel-perfect parity unless working from exact specs.
- If a target technology or design system is known, translate its documented tokens, control patterns, density, navigation, and theme behavior into the mock.
- If the target technology is unknown, use neutral UI primitives: surfaces, navigation, command areas, forms, status indicators, data displays, alerts, dialogs, and progressive disclosure.
- For physical, embedded, or instrument-panel UIs, account for operating context: viewing distance, touch/glove use, hardware buttons, alarm states, constrained resolution, and high-contrast status visibility.
- Use placeholder charts/tables when data visualization details are not the focus.
- Flag fidelity risks separately: native control behavior, focus/accessibility behavior, touch/keyboard/hardware-button navigation, animation, virtualization, theme edge cases, physical ergonomics, and display constraints.

## Avoid Generic AI-Looking UI

- NEVER produce generic AI aesthetics: purple gradients on white, Inter font, predictable card grids, cookie-cutter component layouts. Every output should feel designed for its specific context.
- Anchor the UI in domain nouns, real tasks, and real failure states from the user's context.
- Avoid generic SaaS/dashboard patterns unless the product genuinely needs them: decorative cards, vague metrics, gradient hero areas, excessive icons, pill/chip overload, and perfectly symmetric layouts.
- Prefer labels that answer operator questions: what is selected, where data will be saved, what is safe/unsafe, what is blocked, what needs review, and what happens next.
- Use realistic hierarchy and density for the target context. Scientific, industrial, medical, embedded, and professional tools often need restrained styling, tables, forms, logs, status panels, and explicit state labels.
- Include non-happy-path states when relevant: disconnected hardware, invalid configuration, unsaved data, failed save, stale data, permission limits, warning thresholds, aborted operations, and incomplete metadata.
- Avoid fake polish that hides unresolved product questions. If an element is speculative, make it visibly provisional or list it as an open question.
- Use icons sparingly. Do not use emoji in professional/product mocks unless the target product already uses them.

## Token-Cost Rules

- Be brief.
- Avoid long explanations before the mock.
- Do not include multiple design alternatives unless requested.
- Use compact CSS and semantic class names.
- Use representative sample data, not exhaustive data.
- Prefer a useful first pass over perfect fidelity.

## HTML Mock Requirements

- Single file that can be saved as `.html` and opened locally.
- No external CDN dependencies unless the user approves.
- Use responsive layout when target size is unknown.
- Include light/dark support if the target app has theme switching.
- Include comments only where they clarify how to adapt the mock.
- Use semantic HTML, visible focus states, accessible labels, sufficient contrast, keyboard-reachable controls, and reduced-motion-safe interactions.
- Account for known viewport constraints: fixed resolution, kiosk/fullscreen display, safe areas, touch target size, viewing distance, and scaling behavior.

## File Output Destination

Do not assume a default folder for generated prototype files.

If the user asks to create/save prototype files and does not provide an output destination, ask for the folder before creating files.

If the user only wants the mock in chat, no destination is needed.

When saving files, use a descriptive prototype filename such as `screen-or-workflow-prototype.html`.

After creating a file, verify that the artifact is self-contained and can be opened locally.

## When Design-System Docs Are Provided

Extract only implementation-relevant tokens and patterns:

- Brand/accent colors
- Surface/background colors
- Text colors
- Typography scale
- Spacing/radius/elevation
- Component examples
- Theme variants

Do not copy large documentation verbatim. Summarize and translate into CSS variables plus usage rules.

## Approval Gate

If the user asks to create or edit project files, first state the planned approach, assumptions, and risks, then wait for approval before changing files.

Generating an HTML mock in the chat is allowed without approval because it is not a file change.
