---
name: private-executing-plans
description: Use when you have a written implementation plan to execute in the current repository with branch-based work and without mandatory worktree setup
---

# Private Executing Plans

## Overview

Load an implementation checklist/plan, review critically, execute tasks directly on a branch in the current workspace, and stop after implementation plus verification unless the user explicitly asks to continue into review or completion workflow.

**Ausgabesprache:** Deutsch. Fachbegriffe (Checklist, Review, Scope, etc.) bleiben englisch.

**Core principle:** Execute the agreed implementation checklist/plan on a branch in the current workspace. Do not require or introduce git worktrees as part of this workflow.

**Plan boundary:** Treat the active implementation plan as the source of truth for the **current execution state**. If a sibling `TODO-<id>-*.review-log.md` exists, read it as context for rationale and history, but do not turn the active plan into a review transcript while executing.

**Announce at start:** "I'm using the private-executing-plans skill to implement this plan."

**Expected upstream workflow:** In the default private workflow, this skill typically follows a design/planning pass (`private-brainstorming` or `persona-kingpanda`), then `private-create-checklist`, then `private-review-plan`.

## Current Workspace Rule

- Work on a branch in the current workspace.
- Do not create, require, or switch to a git worktree as part of this skill.
- If the current branch is unsuitable, create or switch to another branch in the same workspace.

## The Process

### Step 1: Load and Review Plan
1. Read the full plan file for context (scope, decisions, confirmed decisions).
2. If a sibling `*.review-log.md` exists for the same TODO, read it for review rationale, rejected alternatives, and prior findings history.
3. Identify the current `## Execution Checklist` as the **primary section you will modify** during execution.
4. Review the checklist critically and identify any gaps, contradictions, or unclear instructions.
5. If something is unclear or blocked: stop and ask the user.
6. If the plan is workable: proceed directly with implementation.

### Step 2: Execute the Plan
1. Follow the plan steps in order.
1a. Wenn die ersten Checklist-Punkte Board-/Status-Schritte sind (z. B. `Backlog` -> `In Progress` in `docs/TODO.md` oder vergleichbare Workflow-Updates), muessen diese **vor jeder Code-, Test- oder sonstigen Umsetzungsarbeit** erledigt werden.
1b. Solange solche vorgeschalteten Workflow-Schritte offen sind, darfst du nur den Kontext lesen/pruefen und die noetigen Markdown-Updates ausfuehren; keine Implementierung vorziehen.
2. Run the specified verifications.
3. Update execution state in the active plan narrowly:
   - check off items in `## Execution Checklist`
   - add short execution notes only when they materially help the next execution step
   - keep any `## Skill Run Log` entry brief if you touch it at all
4. Prefer narrow, repository-local workflow helpers for board/plan state updates **when they already exist and clearly fit the change**:
   - examples: small repo tools/scripts for moving a TODO between board sections, checking explicit checklist items, or appending short dated status notes
   - discover such helpers from local repository context first (repo guides, agent docs, existing scripts/tools); do not invent helper commands
   - do **not** assume such helpers exist in every repository
   - if no fitting helper exists, or using it would be more ambiguous than a direct edit, update the Markdown manually
5. Do not add findings histories, review narratives, or new decision journals to the active plan during execution; that belongs in the review flow and its `*.review-log.md`.
6. Keep progress moving without review checkpoints unless the user explicitly asks for them.
7. Stop only when something is genuinely unclear, blocked, or repeatedly failing.

### Step 3: Complete Development

After implementation and verification are complete:
- Stop by default and report that implementation plus verification are done.
- Present the available next steps explicitly:
  1. `$private-code-review` — optional, wenn ein Review vor dem Abschluss gewünscht wird
  2. `$private-workflow-close-todo` — schließt das TODO (Board-Eintrag, Plan-Archivierung, Branch)
- **Never** auto-start `private-code-review` or `private-workflow-close-todo`; only proceed when the user explicitly requests one of these steps.
- If the user requests `private-code-review`: announce "I'm using the private-code-review skill to review this work.", run it, then stop. Do not fix issues automatically — the code-review report determines the next step:
  - **P1/P2 findings:** new plan/review/execute cycle via `$private-create-checklist`
  - **P3 only:** user decides — quick inline fix or proceed to `$private-workflow-close-todo`
  - **No findings:** proceed to `$private-workflow-close-todo`
- **Never** move the TODO to `Completed`, archive the plan, or perform any branch-closing work in this skill — that is the responsibility of `$private-workflow-close-todo`.

## When to Stop and Ask for Help

**STOP executing immediately when:**
- A plan instruction is unclear
- A required dependency or file is missing
- Verification fails repeatedly without a clear local fix
- The plan has a critical gap that makes correct execution ambiguous

**Ask for clarification rather than guessing.**

## Remember

- Review the plan before changing files
- Read the sibling `*.review-log.md` when it exists, but treat it as context, not as the place you report implementation progress
- Work on branches in the current workspace, not in git worktrees
- Follow the written steps unless the plan is clearly wrong
- Keep the active plan focused on current execution state; do not expand it into a review log during implementation
- Discover repo-local helper tools/scripts from local repository context before using them; never invent helper commands from the skill alone
- Prefer existing repo-local helper tools/scripts for narrow board/checklist/status updates when they clearly fit; otherwise edit directly
- Never hardcode project-specific helper names or assume every repository provides such tooling
- Do not add review checkpoints unless the user asks for them
- Do not auto-start `private-code-review`; only suggest it as the manual next step unless the user explicitly asks for it
- Do not auto-start `finishing-a-development-branch`; only suggest it after review when the user explicitly asks for completion/integration handling
- Never move TODOs to `Completed` or archive plans in this skill
- Stop when blocked or unclear; do not guess
- Never start implementation on `main`/`master` without explicit user consent

## Integration

**Typical upstream/downstream workflow skills (manual trigger unless explicitly requested):**
- **private-brainstorming** or **persona-kingpanda** - Create and validate the design/problem framing before execution work starts
- **private-create-checklist** - Create or update the implementation checklist this skill executes
- **private-review-plan** - Review the current implementation checklist/plan before execution
- **private-code-review** - Optional manual next step after implementation/verification when the user wants review
- **private-workflow-close-todo** - Closes the TODO (board entry, plan archiving, branch) — manual trigger only
