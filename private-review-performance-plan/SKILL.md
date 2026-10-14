---
name: private-review-performance-plan
description: Use when an implementation or design plan needs a focused second-pass review for performance risk such as bottlenecks, measurement quality, scaling limits, fallback strategy, or reproducible before/after validation.
date: "2026-03-25"
---

# Private Review Performance Plan

## Overview

Review and tighten a performance-sensitive design or implementation plan so optimization effort stays evidence-driven, targets the dominant cost center, and avoids broad rewrites for marginal gains.

**Core principle:** Performance review here is evidence-driven quality and risk reduction, not optimization theater. Prioritize the smallest intervention that reduces user-visible latency or throughput risk while preserving delivery speed.

**Skill Activation:** When this skill is activated, you MUST indicate this at the start of your response with: `[⚡ PrivateReviewPerformancePlan Active]`

## Fit In Current Workflow

- This skill is **optional**. Do **not** assume it is part of the default chain.
- Typical use: after `private-review-plan`, before `private-executing-plans`, when the plan contains meaningful performance risk or optimization work.
- It may also be used earlier on a design doc if no implementation plan exists yet.
- If both a design doc and an implementation plan exist, prefer the implementation plan as the primary document and use the design doc only as supporting context.

## Safety Rules

**Harte Sicherheitsregel (absolut):** Wenn dieser Skill aktiv ist, darfst du **keine Umsetzung starten**. Auch kleine Code-Aenderungen, Builds, Tests, Benchmarks oder Messlaeufe sind verboten.

Erlaubt:
- Lesen und Analysieren von Markdown, Code und Workflow-Dokumenten.
- **Aenderungen an Markdown-Dateien (`*.md`, inkl. Neuanlage)**, um Bottleneck-Hypothesen, Messpfade, Verifikation, Fallbacks und `Execution Checklist` zu schaerfen.

Verboten:
- Jede Aenderung an Nicht-Markdown-Dateien.
- Laufzeitmessungen, Benchmarks, Build-/Test-Ausfuehrung oder sonstige Verifikation.
- Das explizite Verdrahten dieses Skills in die Workflow-Kette, sofern der User das nicht separat anfordert.

## Documentation Rules

- **Single Source of Truth:** Entscheidungen bleiben standardmaessig im relevanten Plan-`*.md`. Kein separates Review-Dokument, ausser der User verlangt es explizit.
- **Decision Persistence (mandatory):** Jede bestaetigte Entscheidung (`PF-Q*`, `PF-ALT*`, `PF-R*`) muss im Plan-`*.md` dokumentiert werden.
- **Required sections:** Wenn noetig, add/update:
  - `## Performance-Review Entscheidungen (YYYY-MM-DD)` — nur Entscheid-Zeilen (z. B. `PF-Q1=A`) mit kurzer Begruendung; kein vollstaendiger Review-Output
  - `## Open Questions`
  - `## Execution Checklist`
  - `## Skill Run Log`
- **Findings, Alternatives, Recommendations, Validation** bleiben im Chat-Output. Nicht in die Plan-Datei persistieren.
- **Scope split:** Jede Entscheidung nennt explizit `In diesem TODO` vs. `Folge-TODO`.
- **Open Questions hygiene:** Wenn alles geklaert ist, `## Open Questions` auf `Keine (Stand YYYY-MM-DD).` setzen.

## Review Focus

Always check for:
- Latenz- und Throughput-Bottlenecks in relevanten Nutzer- oder Backend-Pfaden
- CPU-, Memory-, I/O- und Allokations-Hotspots bezogen auf reale Lastannahmen
- Datenbank-/Cache-/Render-/Queue-/Contention-Themen, sofern relevant
- Dominanten Kostenblock statt Nebengeraeusch
- Regression risk, fallback strategy, and rollback practicality
- Before/after validation plan that is concrete and reproducible
- Capacity headroom and scaling characteristics when burst behavior matters

Every performance claim must be labeled as one of:
- **Measured evidence**
- **Strong inference from code/design**
- **Hypothesis needing runtime measurement**

## Workflow

0) If present, read `AGENTS.md` (or scoped variants) and `docs/handsoff.md`, and apply their constraints.
1) Identify the target doc:
   - Prefer the implementation plan.
   - If only a design doc exists, review that and document what must exist before execution can begin.
2) Extract:
   - exact feature path / component / service / hot path being optimized
   - workload assumptions
   - current validation or measurement strategy
   - fallback and regression constraints
3) Map the likely dominant cost center and likely user-visible failure surface.
4) Separate measured evidence from inference and hypothesis before recommending action.
5) Recommend the **smallest coherent intervention** with the highest likely performance gain.
6) Tighten validation planning so the plan explicitly covers:
   - one normal path
   - one failure/regression path
   - one integration edge
   - one before/after measurement path
7) Check whether the plan is over-optimizing local noise. If yes, narrow it.
8) Update the plan markdown in the same turn:
   - persist findings and decisions
   - sharpen `## Execution Checklist`
   - remove stale or conflicting instructions
9) Add a dated entry to `## Skill Run Log` for `private-review-performance-plan`.
10) Consistency gate: do not finish until chat guidance and markdown state match exactly.

## ID Scheme

- Findings: `PF-F1`, `PF-F2`, ...
- Alternatives: `PF-ALT1`, `PF-ALT2`, ...
- Recommendations: `PF-R1`, `PF-R2`, ...
- Questions: `PF-Q1`, `PF-Q2`, ...
- New items in later rounds: `R2-PF-F3`, `R3-PF-Q1`, ...

Every recommendation and question should include a `RelatesTo:` line pointing to a finding or boundary.

## Output Format

**Ausgabesprache:** Deutsch. Fachbegriffe (Review, Findings, Checklist, Scope, etc.) bleiben englisch.

Use this structure by default:

1. `Boundary`
   - exact scope analyzed
   - affected workload / hot path
   - user-visible performance risk
2. `Findings`
   - key bottleneck claim(s) with evidence level
3. `Alternatives`
   - 2-3 viable approaches, including a minimal path
4. `Recommendations`
   - smallest safe change/recommendation
   - expected gain
   - trade-off cost
   - preferred option
5. `Performance Evidence`
   - measurement source and confidence level
   - dominant cost center
   - fallback / regression considerations
6. `Validation`
   - normal path
   - failure/regression path
   - integration edge
   - before/after measurement path
   - remaining runtime/environment checks not executed in this skill
7. `Questions`
   - only if decisions are still open

## Decision Capture

As soon as the user answers a question or confirms an option, update the relevant plan markdown in the same turn:

- add/update `## Performance-Review Entscheidungen (YYYY-MM-DD)` with explicit mappings such as `PF-Q1=A`
- document short rationale
- state scope split (`In diesem TODO` vs. `Folge-TODO`)
- align `## Execution Checklist`
- remove stale `## Open Questions` entries
- update `## Skill Run Log`

## Quick Mode

If the user explicitly asks for a short pass, use:

```text
Performance-Plan Review (Datum: YYYY-MM-DD)

Boundary:
- ...

Risiken:
- ...

Messlage:
- Quelle: ...
- Confidence: ...

Kleinster sicherer Schritt:
- ...

Validierung:
- Normalpfad: ...
- Failure-/Regression-Pfad: ...
- Integrationskante: ...
- Before/After-Messpfad: ...

Offene Fragen:
- ...
```

## Completion Rule

- Wenn **offene Fragen** existieren, endet die Antwort nach `## Questions`.
- Wenn **keine offenen Fragen** existieren, darf die Antwort mit dem Abschluss enden.

## Abschluss

**Nur im Chat ausgeben. Nicht in die Plan-Datei schreiben.**

Performance-Plan-Review erledigt - PerformancePlanReview verabschiedet sich fuer dieses Mal. Gute Nacht.
Optional: `$private-executing-plans`

## Skill Change Log

- 2026-03-21: Initiale Projekt-Skill-Version fuer einen optionalen Spezial-Review von Performance-Risiken nach Planerstellung angelegt.
- 2026-03-23: Workflow-Position im Kontext der 3 Sub-Skills klaergestellt; `private-review-refactor-plan` entfernt.
