---
description: C# implementation preferences for local structure, extraction, and single-use logic.
applyTo: "**/*.cs"
---

# C# Preferences

- Prefer local functions for logic that is only referenced once but is complex enough to deserve a name.
- Keep local functions close to the code that uses them, after the main path when that matches the surrounding style.
- Extract private methods when logic is reused, belongs to the type's behavior, or improves testability without expanding the public surface.
- Extract interfaces only when the user asks, when existing patterns require one, or when there is a concrete need for substitution across implementations.
- Do not introduce new abstractions only to make code look cleaner.
