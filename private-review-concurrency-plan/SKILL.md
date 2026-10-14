---
name: private-review-concurrency-plan
description: Use when an implementation or design plan needs a focused second-pass review for concurrency risk such as parallelism model, shared mutable state, determinism, aggregation ordering, or race-condition containment.
date: "2026-03-25"
---

# Private Review Concurrency Plan

## Overview

Review and tighten a concurrency-sensitive design or implementation plan so parallelization stays explicit, deterministic where required, and bounded against race conditions and hidden shared-state hazards.

**Core principle:** Concurrency review here is evidence-driven quality and risk reduction, not vague warnings about races. Prioritize the smallest intervention that makes ownership, ordering, and failure semantics concrete.

**Skill Activation:** When this skill is activated, you MUST indicate this at the start of your response with: `[🧵 PrivateReviewConcurrencyPlan Active]`

## Fit In Current Workflow

- This skill is **optional**. Do **not** assume it is part of the default chain.
- Typical use: after `private-review-plan`, before `private-executing-plans`, when the plan introduces or reshapes concurrency, parallelism, worker fan-out, shared caches, or scheduler-sensitive behavior.
- It may also be used earlier on a design doc if no implementation plan exists yet.
- If both a design doc and an implementation plan exist, prefer the implementation plan as the primary document and use the design doc only as supporting context.

## Safety Rules

**Harte Sicherheitsregel (absolut):** Wenn dieser Skill aktiv ist, darfst du **keine Umsetzung starten**. Auch kleine Code-Aenderungen, Builds oder Tests sind verboten.

Erlaubt:
- Lesen und Analysieren von Markdown, Code und Workflow-Dokumenten.
- **Aenderungen an Markdown-Dateien (`*.md`, inkl. Neuanlage)**, um Parallelitaetsmodell, State-Ownership, Race-Risiken, Determinismus, Validierung und `Execution Checklist` zu schaerfen.

Verboten:
- Jede Aenderung an Nicht-Markdown-Dateien.
- Builds, Tests, Benchmarks oder sonstige Laufzeit-Verifikation.
- Das explizite Verdrahten dieses Skills in die Workflow-Kette, sofern der User das nicht separat anfordert.

## Documentation Rules

- **Single Source of Truth:** Entscheidungen bleiben standardmaessig im relevanten Plan-`*.md`. Kein separates Review-Dokument, ausser der User verlangt es explizit.
- **Decision Persistence (mandatory):** Jede bestaetigte Entscheidung (`CR-Q*`, `CR-ALT*`, `CR-R*`) muss im Plan-`*.md` dokumentiert werden.
- **Required sections:** Wenn noetig, add/update:
  - `## Concurrency-Review Entscheidungen (YYYY-MM-DD)` — nur Entscheid-Zeilen (z. B. `CR-Q1=A`) mit kurzer Begruendung; kein vollstaendiger Review-Output
  - `## Open Questions`
  - `## Execution Checklist`
  - `## Skill Run Log`
- **Findings, Alternatives, Recommendations, Validation** bleiben im Chat-Output. Nicht in die Plan-Datei persistieren.
- **Scope split:** Jede Entscheidung nennt explizit `In diesem TODO` vs. `Folge-TODO`.
- **Open Questions hygiene:** Wenn alles geklaert ist, `## Open Questions` auf `Keine (Stand YYYY-MM-DD).` setzen.

## Review Focus

You MUST explicitly check for:
- **Art der Parallelitaet:** data-parallel, task-parallel, pipeline, batching oder gemischtes Modell
- **Parallelisierungsgrenze:** exakt welche Schleife, Stufe oder Aufrufebene parallelisiert wird und was bewusst seriell bleibt
- **Shared-vs-local state inventory:** welche Objekte immutable geteilt werden duerfen und welche pro Task/Run/Worker exklusiv bleiben muessen
- **Race-condition surface:** Listen, Aggregationen, Caches, RNGs, Sampler, Event-Engines, accumulators, sort/order steps, lazy init, snapshot capture
- **Determinismusregeln:** seed derivation, slot/index ownership, ordering guarantees, barriers, and schedule-independent result assembly
- **Failure model:** partial task failure, cancellation, empty or short runs, partial aggregation
- **Backpressure / contention / starvation risk**, if queues or worker pools are involved

Every concurrency review must name the concrete mutable state holders and the concrete containment rule for each one.

## Workflow

0) If present, read `AGENTS.md` (or scoped variants) and `docs/handsoff.md`, and apply their constraints.
1) Identify the target doc:
   - Prefer the implementation plan.
   - If only a design doc exists, review that and document what must exist before execution can begin.
2) Extract:
   - exact parallelization target
   - serialization boundary
   - state ownership model
   - aggregation path and ordering assumptions
3) Map the concrete race/failure surface.
4) Separate confirmed evidence from hypotheses before recommending action.
5) Recommend the **smallest coherent intervention** that makes ownership, ordering, and determinism explicit.
6) Tighten validation planning so the plan explicitly covers:
   - one normal path
   - one failure/guard path
   - one integration edge
   - one repeatability or race-sensitive path
7) Check whether concurrency scope is larger than necessary. If yes, narrow it.
8) Update the plan markdown in the same turn:
   - persist findings and decisions
   - sharpen `## Execution Checklist`
   - remove stale or conflicting instructions
9) Add a dated entry to `## Skill Run Log` for `private-review-concurrency-plan`.
10) Consistency gate: do not finish until chat guidance and markdown state match exactly.

## ID Scheme

- Findings: `CR-F1`, `CR-F2`, ...
- Alternatives: `CR-ALT1`, `CR-ALT2`, ...
- Recommendations: `CR-R1`, `CR-R2`, ...
- Questions: `CR-Q1`, `CR-Q2`, ...
- New items in later rounds: `R2-CR-F3`, `R3-CR-Q1`, ...

Every recommendation and question should include a `RelatesTo:` line pointing to a finding or boundary.

## Output Format

**Ausgabesprache:** Deutsch. Fachbegriffe (Review, Findings, Checklist, Scope, etc.) bleiben englisch.

Use this structure by default:

1. `Boundary`
   - exact scope analyzed
   - parallelization target
   - serialization boundary and stable contracts
2. `Findings`
   - concrete race / ownership / ordering risks with evidence
3. `Alternatives`
   - 2-3 viable approaches, including a minimal path
4. `Recommendations`
   - smallest safe change/recommendation
   - expected gain
   - trade-off cost
   - preferred option
5. `Concurrency/Races`
   - parallelism model
   - shared vs local state
   - aggregation / barriers
   - race risks and mitigations
   - determinism guarantees
   - failure model
6. `Validation`
   - normal path
   - failure/guard path
   - integration edge
   - repeatability / race-sensitive path
   - remaining runtime/environment checks not executed in this skill
7. `Questions`
   - only if decisions are still open

Do not stop at "avoid races". Name the concrete state holders and the concrete containment rule.

## Decision Capture

As soon as the user answers a question or confirms an option, update the relevant plan markdown in the same turn:

- add/update `## Concurrency-Review Entscheidungen (YYYY-MM-DD)` with explicit mappings such as `CR-Q1=A`
- document short rationale
- state scope split (`In diesem TODO` vs. `Folge-TODO`)
- align `## Execution Checklist`
- remove stale `## Open Questions` entries
- update `## Skill Run Log`

## Quick Mode

If the user explicitly asks for a short pass, use:

```text
Concurrency-Plan Review (Datum: YYYY-MM-DD)

Boundary:
- ...

Risiken:
- ...

Concurrency/Races:
- Parallelitaetsmodell: ...
- Shared State: ...
- Aggregation: ...
- Race-Risiko: ...
- Determinismus: ...

Kleinster sicherer Schritt:
- ...

Validierung:
- Normalpfad: ...
- Failure-/Guard-Pfad: ...
- Integrationskante: ...
- Repeatability-Pfad: ...

Offene Fragen:
- ...
```

## Completion Rule

- Wenn **offene Fragen** existieren, endet die Antwort nach `## Questions`.
- Wenn **keine offenen Fragen** existieren, darf die Antwort mit dem Abschluss enden.

## Abschluss

**Nur im Chat ausgeben. Nicht in die Plan-Datei schreiben.**

Concurrency-Plan-Review erledigt - ConcurrencyPlanReview verabschiedet sich fuer dieses Mal. Gute Nacht.
Optional: `$private-executing-plans`

## Skill Change Log

- 2026-03-21: Initiale Projekt-Skill-Version fuer einen optionalen Spezial-Review von Parallelisierungs-, Race- und Determinismus-Risiken nach Planerstellung angelegt.
- 2026-03-23: Workflow-Position im Kontext der 3 Sub-Skills klaergestellt; `private-review-refactor-plan` entfernt.
