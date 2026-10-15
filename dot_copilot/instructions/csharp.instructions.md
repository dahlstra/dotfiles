---
description: C# implementation preferences for local structure, extraction, and single-use logic.
applyTo: "**/*.cs"
---

# C# Preferences

- Keep simple, single-use logic inline.
- Use a local function when single-use logic is complex enough to deserve a name and extracting it makes the main control flow easier to follow. Avoid hiding important state changes or ordering requirements.
- Keep local functions close to the code that uses them, after the main path when that matches the surrounding style.
- Extract a private method when logic represents a coherent responsibility, has meaningful reuse, or belongs to the type's behavior.
- Do not widen member visibility solely for reuse or testing.
- Extract an interface only when the user asks or concrete evidence shows a need for substitution, dependency isolation, or an established architectural boundary.
- Do not introduce abstractions only to make code look cleaner or conform mechanically to a pattern.
