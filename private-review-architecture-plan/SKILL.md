---
name: private-review-architecture-plan
description: Use when an implementation or design plan needs a focused second-pass review for architecture risk such as module boundaries, dependency direction, data ownership, migration, or degradation behavior.
date: "2026-03-25"
---

# Private Review Architecture Plan

## Overview

Review and tighten an architecture-sensitive design or implementation plan so the smallest viable change reduces failure risk without pushing a gratuitous redesign.

**Core principle:** Architecture review here is evidence-driven quality and risk reduction, not abstract redesign theater. Prioritize the smallest intervention that improves boundary clarity, contract safety, and changeability.

**Skill Activation:** When this skill is activated, you MUST indicate this at the start of your response with: `[🏗️ PrivateReviewArchitecturePlan Active]`

## Fit In Current Workflow

- This skill is **optional**. Do **not** assume it is part of the default chain.
- Typical use: after `private-review-plan`, before `private-executing-plans`, when the plan carries architecture risk beyond ordinary checklist review.
- It may also be used earlier on a design doc if no implementation plan exists yet.
- If both a design doc and an implementation plan exist, prefer the implementation plan as the primary document and use the design doc only as supporting context.
- Wenn Parallelisierung, Worker Fan-out oder Shared State im Scope ist -> zusaetzlich `$private-review-concurrency-plan` danach ausfuehren.

## Safety Rules

**Harte Sicherheitsregel (absolut):** Wenn dieser Skill aktiv ist, darfst du **keine Umsetzung starten**. Auch kleine Code-Aenderungen, Builds oder Tests sind verboten.

Erlaubt:
- Lesen und Analysieren von Markdown, Code und Workflow-Dokumenten.
- **Aenderungen an Markdown-Dateien (`*.md`, inkl. Neuanlage)**, um Architekturgrenzen, Risiken, Migration, Validierung und `Execution Checklist` zu schaerfen.

Verboten:
- Jede Aenderung an Nicht-Markdown-Dateien.
- Builds, Tests, Snapshots, Benchmarks oder sonstige Laufzeit-Verifikation.
- Das explizite Verdrahten dieses Skills in die Workflow-Kette, sofern der User das nicht separat anfordert.

## Documentation Rules

- **Single Source of Truth:** Entscheidungen bleiben standardmaessig im relevanten Plan-`*.md`. Kein separates Review-Dokument, ausser der User verlangt es explizit.
- **Decision Persistence (mandatory):** Jede bestaetigte Entscheidung (`AR-Q*`, `AR-ALT*`, `AR-R*`) muss im Plan-`*.md` dokumentiert werden.
- **Required sections:** Wenn noetig, add/update:
  - `## Architecture-Review Entscheidungen (YYYY-MM-DD)` — nur Entscheid-Zeilen (z. B. `AR-Q1=A`) mit kurzer Begruendung; kein vollstaendiger Review-Output
  - `## Open Questions`
  - `## Execution Checklist`
  - `## Skill Run Log`
- **Findings, Alternatives, Recommendations, Validation** bleiben im Chat-Output. Nicht in die Plan-Datei persistieren.
- **Scope split:** Jede Entscheidung nennt explizit `In diesem TODO` vs. `Folge-TODO`.
- **Open Questions hygiene:** Wenn alles geklaert ist, `## Open Questions` auf `Keine (Stand YYYY-MM-DD).` setzen.

## Review Focus

Always check for:
- Systemgrenzen und Abhaengigkeitsrichtung zwischen Modulen, Services oder Schichten
- Kohaesion-vs-Kopplung dort, wo sie spaetere Aenderungsgeschwindigkeit beeinflusst
- Datenhoheit, Konsistenzgrenzen und Vertragsstabilitaet
- Failure isolation und Degradation-Verhalten an kritischen Interaktionen
- Operability-Auswirkungen: Observability, Rollout-Sicherheit, Incident-Recovery
- Migrationsfaehigkeit vom Ist-Zustand zum Zielzustand
- Complexity budget: keine grossen Umbauten fuer lokale Probleme

Every finding must distinguish:
- **Confirmed evidence**
- **Hypothesis needing runtime, integration, or product-context validation**

## Workflow

0) If present, read `AGENTS.md` (or scoped variants) and `docs/handsoff.md`, and apply their constraints.
1) Identify the target doc:
   - Prefer the implementation plan.
   - If only a design doc exists, review that and document what must exist before execution can begin.
2) Extract:
   - changed or affected behavior boundary
   - system/module/service boundary and dependency direction
   - contracts that must remain stable
   - migration and rollout assumptions
3) Map the likely failure surface at those boundaries.
4) Separate confirmed evidence from hypotheses before recommending action.
5) Recommend the **smallest coherent intervention** with the highest architecture risk reduction.
6) Tighten validation planning so the plan explicitly covers:
   - one normal path
   - one failure/degradation path
   - one integration edge
7) Check whether the plan stays within its architectural complexity budget. If not, split or defer.
8) Update the plan markdown in the same turn:
   - persist findings and decisions
   - sharpen `## Execution Checklist`
   - remove stale or conflicting instructions
9) Add a dated entry to `## Skill Run Log` for `private-review-architecture-plan`.
10) Consistency gate: do not finish until chat guidance and markdown state match exactly.

## ID Scheme

- Findings: `AR-F1`, `AR-F2`, ...
- Alternatives: `AR-ALT1`, `AR-ALT2`, ...
- Recommendations: `AR-R1`, `AR-R2`, ...
- Questions: `AR-Q1`, `AR-Q2`, ...
- New items in later rounds: `R2-AR-F3`, `R3-AR-Q1`, ...

Every recommendation and question should include a `RelatesTo:` line pointing to a finding or boundary.

## Output Format

**Ausgabesprache:** Deutsch. Fachbegriffe (Review, Findings, Checklist, Scope, etc.) bleiben englisch.

Use this structure by default:

1. `Boundary`
   - exact scope analyzed
   - changed behavior boundary
   - stable contracts and dependencies
2. `Findings`
   - key risk(s) with supporting evidence
   - hypotheses clearly labeled as such
3. `Alternatives`
   - 2-3 viable approaches, including a minimal path
4. `Recommendations`
   - smallest safe change/recommendation
   - expected gain
   - trade-off cost
   - preferred option
5. `Architecture`
   - dependency direction
   - data ownership / consistency boundary
   - failure isolation / degradation
   - migration / rollout implications
6. `Validation`
   - normal path
   - failure/degradation path
   - integration edge
   - remaining runtime/environment checks not executed in this skill
7. `Questions`
   - only if decisions are still open

## Decision Capture

As soon as the user answers a question or confirms an option, update the relevant plan markdown in the same turn:

- add/update `## Architecture-Review Entscheidungen (YYYY-MM-DD)` with explicit mappings such as `AR-Q1=A`
- document short rationale
- state scope split (`In diesem TODO` vs. `Folge-TODO`)
- align `## Execution Checklist`
- remove stale `## Open Questions` entries
- update `## Skill Run Log`

## Quick Mode

If the user explicitly asks for a short pass, use:

```text
Architecture-Plan Review (Datum: YYYY-MM-DD)

Boundary:
- ...

Risiken:
- ...

Kleinster sicherer Schritt:
- ...

Validierung:
- Normalpfad: ...
- Failure-/Degradation-Pfad: ...
- Integrationskante: ...

Offene Fragen:
- ...
```

## Completion Rule

- Wenn **offene Fragen** existieren, endet die Antwort nach `## Questions`.
- Wenn **keine offenen Fragen** existieren, darf die Antwort mit dem Abschluss enden.

## Abschluss

**Nur im Chat ausgeben. Nicht in die Plan-Datei schreiben.**

Architecture-Plan-Review erledigt - ArchitecturePlanReview verabschiedet sich fuer dieses Mal. Gute Nacht.
Optional: `$private-executing-plans`

## Skill Change Log

- 2026-03-21: Initiale Projekt-Skill-Version fuer einen optionalen Spezial-Review von Architektur-Risiken nach Planerstellung angelegt.
- 2026-03-23: Kombinationshinweis fuer Concurrency ergaenzt; Workflow-Position im Kontext der 3 Sub-Skills klaergestellt.
