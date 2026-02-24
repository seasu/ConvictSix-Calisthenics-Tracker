# Agent Workflow Guide

Rules for AI assistants working on this project. Follow these in every session.

---

## 1. Workflow Orchestration

### Plan First
- Enter plan mode for any non-trivial task (3+ steps or architectural decisions).
- If something goes sideways, **stop and re-plan immediately** — don't keep pushing.
- Use plan mode for verification steps, not just building.
- Write detailed specs upfront to reduce ambiguity.

### Subagent Strategy
- Use subagents liberally to keep the main context window clean.
- Offload research, exploration, and parallel analysis to subagents.
- For complex problems, throw more compute at it via subagents.
- One task per subagent for focused execution.

### Self-Improvement Loop
- After **any** correction from the user: update `tasks/lessons.md` with the pattern.
- Write rules that prevent the same mistake from happening again.
- Review `tasks/lessons.md` at the start of each session for relevant context.

### Verification Before Done
- Never mark a task complete without proving it works.
- Diff behaviour between `main` and your changes when relevant.
- Ask yourself: *"Would a staff engineer approve this?"*
- Run `flutter analyze` and `flutter test` — all must pass before committing.

### Demand Elegance (Balanced)
- For non-trivial changes: pause and ask *"is there a more elegant way?"*
- If a fix feels hacky: *"Knowing everything I know now, implement the elegant solution."*
- Skip this for simple, obvious fixes — don't over-engineer.

### Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding.
- Point at logs, errors, failing tests — then resolve them.
- Go fix failing CI/analyzer issues without being told how.

---

## 2. Task Management

1. **Plan first** — write plan to `tasks/todo.md` with checkable items.
2. **Verify plan** — check in with the user before starting implementation on large features.
3. **Track progress** — mark items complete as you go using the TodoWrite tool.
4. **Explain changes** — provide a high-level summary at each step.
5. **Document results** — add a review/outcome section to `tasks/todo.md` when done.
6. **Capture lessons** — update `tasks/lessons.md` after any user correction.

---

## 3. Core Principles

- **Simplicity first** — make every change as simple as possible; impact minimal code.
- **No laziness** — find root causes, no temporary fixes, senior developer standards.
- **Minimal impact** — changes should only touch what's necessary; avoid introducing bugs.
