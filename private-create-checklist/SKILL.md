---
name: private-create-checklist
description: Use when a user wants a concise, actionable execution checklist that can be persisted into an existing TODO or implementation plan document.
---

# Private Create Checklist

## Goal

Turn a user prompt into a **single, actionable current execution checklist** that can live in the active TODO implementation plan without turning that file into a history dump.

**Ausgabesprache:** Deutsch. Fachbegriffe (Checklist, Review, Scope, etc.) bleiben englisch.

This skill is the practical bridge between a validated design and execution: it turns decisions into an implementation-ready checklist without reopening broad design exploration.

## Minimal workflow

Operate in a read-mostly mode. You may create/update `*.md` files when persisting the plan (see “Plan persistence”). Never modify non-Markdown files in this skill.

**Skill Activation:** When this skill is activated, you MUST indicate this at the start of your response with: `[🧭 PrivateCreateChecklist Active]`

**Run Log (MANDATORY):** If you create or modify any Markdown files (`*.md`) while this skill is active, add/maintain a section named `## Skill Run Log` and append a new bullet in the format `YYYY-MM-DD HH:mm — private-create-checklist`. Keep the note short; do not turn the run log into decision history.

**Workflow profile:** If `.agents/workflow-profile.yaml` exists in the repository, use its configured TODO/plan paths first. The path examples below are defaults for a TODO-based docs workflow.

**Workflow position:** Prefer this skill after a design/planning pass such as `private-brainstorming` or `persona-kingpanda`, and before `private-review-plan` / `private-executing-plans`.

## Plan persistence

Default behavior: persist the plan into the active TODO implementation plan file to avoid copy/paste. Still output the plan in the final assistant message using the template.

**Active-plan minimalism (mandatory):** The active TODO implementation plan is for the **current state only**. This skill may update the current checklist and closely related execution state, but must not expand the active plan into a round-by-round review or audit trail.

Allowed in the active plan:
- `## Execution Checklist`
- `## Open Questions`
- Short updates to `## Confirmed decisions` when the user explicitly asks for them as part of the checklist refresh
- A short `## Skill Run Log` entry

Not allowed in the active plan from this skill:
- Detailed review narratives
- Alternative analysis
- Multi-round decision histories
- Long findings archives
- More than one archived checklist block

- Default target file: `docs/planning/implementation/todo-specific-plans/TODO-<id>-*.md` (match by the `TODO-<id>` in the user prompt).
- Default insertion point: update a section named `## Execution Checklist` in that TODO plan file (in-place by default).
- **Primary rule (avoid duplicate open work):** If the target file already contains `## Execution Checklist` with many open items, update/refine that checklist in-place and keep existing checkmarks/history.
- **Archive rule (only when truly needed):** Archive the current checklist only if at least one of these is true:
  1) The user explicitly asks for a fresh checklist/reset for a new run.
  2) The existing checklist is largely done (roughly >= 70% checked or functionally complete) and a new phase/start-over checklist is needed.
  - Archive procedure:
    - Rename the existing section header to `## Execution Checklist (Archive YYYY-MM-DD)` (use today’s date; get it via `date +%Y-%m-%d`).
    - Then create a fresh `## Execution Checklist` section with the new items for this run.
  - **Active-plan cap:** Keep at most **one** archived checklist block in the active plan. If one already exists, do not create another archive block; refresh the current checklist in place and mention the reset briefly in `## Skill Run Log`.
- If the target plan file already contains `## Code Review Findings (YYYY-MM-DD)`, treat it as input for this run:
  - Ensure the new/updated `## Execution Checklist` contains explicit checklist items that address the findings (reference labels like `F1`, `F2`, ... so `$executing-plans` can tick them off).
  - Do **not** rewrite, compress, or curate the findings sections in this skill. Findings history belongs in the review flow, not in checklist generation.
- `## Execution Checklist` is the source of truth for progress tracking; `$executing-plans` should check off items there (and may add short notes in the same plan file).
- If no `TODO-<id>` is provided, or multiple files match, ask exactly 1 clarifying question and do not guess.
- Do not write to `docs/planning/design/` (that’s for design/spec docs, not execution checklists). Use `docs/planning/design/todo-specific/` or `docs/planning/design/general/` as appropriate.

## TODO Board Hygiene (if applicable)

If the user prompt refers to a `TODO-<id>` and `docs/TODO.md` contains that TODO, add an **early** checklist item to move the TODO from `Ready` → `In Progress` (with today’s date). Ensure status dates use the current day (`date +%Y-%m-%d`) and never keep stale template dates.

1. **Scan context quickly**
   - Read `README.md` and any obvious docs (`docs/`, `CONTRIBUTING.md`, `ARCHITECTURE.md`).
   - Skim relevant files (the ones most likely touched).
   - Identify constraints (language, frameworks, CI/test commands, deployment shape).

2. **Ask follow-ups only if blocking**
   - Ask **at most 1–2 questions**.
   - Only ask if you cannot responsibly plan without the answer; prefer multiple-choice.
   - If a preceding design pass already settled the architecture, do **not** reopen broad design questions.
   - Only use questions here for the last practical execution decisions that materially change the checklist.
   - If unsure but not blocked, make a reasonable assumption and proceed.

3. **Create a plan using the template below**
   - Start with **1 short paragraph** describing the intent and approach.
   - If useful, include a short `## Confirmed decisions` section with the 1-5 execution-relevant decisions that the checklist assumes.
   - Clearly call out what is **in scope** and what is **not in scope** in short.
   - Then provide a **small checklist** of action items (default 6–10 items).
      - Each checklist item should be a concrete action and, when helpful, mention files/commands.
      - **Make items atomic and ordered**: discovery → changes → tests → rollout.
      - **Verb-first**: “Add…”, “Refactor…”, “Verify…”, “Ship…”.
   - Include at least one item for **tests/validation** and one for **edge cases/risk** when applicable.
   - If there are unknowns, include a tiny **Open questions** section (max 3).
   - If there are no unknowns, set `## Open questions` to `- Keine.`.
   - `## Open questions` is a hard gate: if it contains real questions, the plan is not done.
   - End with a short **Abschluss** block:
     - If `## Open questions` is `- Keine.`: state planning is done.
     - If `## Open questions` contains real questions: do **not** claim completion; mark the plan as pending clarification.
     - Do not include casual sign-offs such as `Gute Nacht`.
     - If a TODO ID is known, append it to each optional follow-up command using the user's command style (e.g. `todo139`); if the user prompt included a short routing suffix such as `nächste runde`, preserve that suffix on both optional commands.
     - Put each optional follow-up command on its own line so it can be copied directly.

4. **Do not preface the plan with meta explanations; output only the plan as per template**
   - Do not output the completion variant of `## Abschluss` while open questions remain or required persistence is still incomplete.

## Plan template (follow exactly)

```markdown
# Plan

<1–3 sentences: what we’re doing, why, and the high-level approach.>

## Confirmed decisions
- <Optional; omit section entirely if there are no notable decisions to lock in>

## Scope
- In:
- Out:

## Action items
[ ] <Step 1>
[ ] <Step 2>
[ ] <Step 3>
[ ] <Step 4>
[ ] <Step 5>
[ ] <Step 6>

## Open questions
- Keine.

## Abschluss
<Wenn `## Open questions` = `- Keine.`: `Planung erledigt — PrivateCreateChecklist verabschiedet sich für dieses Mal.`>
<Wenn offene Fragen vorhanden: `Plan noch offen — bitte zuerst Open questions klaeren.`>
Optional:
`$private-review-plan <todo-id><optional-routing-suffix>`
`$private-executing-plans <todo-id><optional-routing-suffix>`
```

## Checklist item guidance
Good checklist items:
- Point to likely files/modules: src/..., app/..., services/...
- Name concrete validation: “Run npm test”, “Add unit tests for X”
- Include safe rollout when relevant: feature flag, migration plan, rollback note

Avoid:
- Vague steps (“handle backend”, “do auth”)
- Too many micro-steps
- Writing code snippets (keep the plan implementation-agnostic)
- Adding history-management work that belongs in a review log or archive workflow

## Skill Run Log

- 2026-03-16 13:00 — private-create-checklist (rename/migration)
- 2026-03-29 13:00 — private-create-checklist (active-plan minimalism, findings no longer rewritten, archive cap added)
- 2026-05-16 10:55 — private-create-checklist (copy-friendly follow-up commands with TODO id)
