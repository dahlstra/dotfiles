# Workflow Audit Prompt

Audit my AI-assisted development workflow against my guiding principles in `~/.copilot/guiding-principles.md`. The principles are for this audit; ordinary agents should not need to load them.

Inspect my personal agents, skills, instructions, and tools. Assess:

- Effectiveness, consistency, and unnecessary complexity.
- Portability of my personal core across projects and AI platforms.
- How it coexists with work-local and repo-owned guidance.
- Whether it supports capturing valuable project knowledge without duplicating code or requiring documentation or lessons-learned ceremony.
- Trust boundaries, hidden dependencies, and useful capabilities or practices I may not know about.

Check current official documentation for the relevant platforms when needed. Cite sources, and distinguish confirmed defects from plausible risks, design judgments, and unverified claims. Don't send private files or code to external services.

Recommend the smallest worthwhile changes, including what could be removed, what would be lost, and how to validate the result. Say when no change is warranted. Remain read-only and ask only questions that materially affect the conclusions.
