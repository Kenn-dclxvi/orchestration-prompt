# Orchestration Prompt Set

This repository contains a generic prompt set for agent-based implementation workflows.

It separates four responsibilities:

- Parent agent: normalizes approved work, launches role agents, and manages results.
- Plan agent: drafts implementation instructions without creating execution permission.
- Implement agent: changes only the approved target, scope, and done conditions.
- Audit and review agents: inspect results non-destructively with separate classification systems.

## Contents

```text
AGENTS.md
AI_APPLY_GUIDE.md
prompts/
  plan.md
  implement.md
  audit.md
  review.md
docs/
  orchestration-process.md
  prompt-guide.md
templates/
  launch-plan-sa.md
  launch-implement-sa.md
  launch-audit-sa.md
  launch-review-sa.md
overlays/
  example/
    repo-context.md
```

## How To Use

1. Read `AI_APPLY_GUIDE.md`.
2. Create a project-specific overlay for the target repository.
3. Copy or adapt `AGENTS.md`, `prompts/`, and any needed templates into the target repository.
4. Keep project-specific paths, commands, and canonical documents in the overlay or target repository, not in this generic prompt set.
5. Use `docs/orchestration-process.md` as the process specification and `docs/prompt-guide.md` as the design guide.

## Contract

This prompt set does not grant execution permission by itself. Execution permission must come from the user's current instruction or from an approved implementation instruction in the target repository.

Do not commit, push, deploy, connect to production, send external data, or broaden scope unless the current user instruction explicitly permits it.

