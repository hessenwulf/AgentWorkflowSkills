---
name: private-review-plan
description: Use when a written implementation or design plan should be reviewed for risks, gaps, alternatives, and execution readiness before coding.
---

# Private Review Plan

## Overview
Review a plan or design doc and produce a structured critique that highlights missing information, risks, alternatives, and recommendations.

**Dokumentationspflicht (verbindlich):** Entscheidungen aus dem Review duerfen nicht nur im Chat bleiben. Persistiere aber mit Augenmass: Der **aktive Plan** enthaelt nur die **aktuell gueltigen** Entscheidungen, offenen Fragen und Referenzen, die fuer die naechste Umsetzungsrunde relevant sind. Die **vollstaendige Review-Historie** (Findings, Alternativen, alte Entscheidungen, begruendete Verwerfungen, Pass-3-Notizen) gehoert in ein separates Review-Log-`*.md`, nicht in die aktive Plan-Datei.

**Harte Sicherheitsregel (absolut):** Wenn dieser Skill aktiv ist, darfst du **unter keinen Umständen** mit der Umsetzung beginnen. Das gilt auch dann, wenn der User Formulierungen wie „mach jetzt“, „setze um“, „commit“, „tests laufen lassen“ o. ä. verwendet.

Erlaubt:
- Lesen/Analysieren von Dateien und Plänen.
- **Änderungen an Markdown-Dateien (`*.md`, inkl. Neuanlage)**, um Plan/Design klarer, konsistenter oder vollständiger zu machen (ohne gesonderte Bestätigung durch den User).

Verboten:
- Jede Änderung an Nicht-Markdown-Dateien (z. B. `*.cs`, `*.csproj`, `*.json`, `*.cshtml`, `*.yml`).
- Ausführen von Builds/Tests/Snapshots/Baseline-Updates (z. B. `dotnet build`, `dotnet test`, `SNAPSHOT_UPDATE=1`).
- Jede Form von Implementierungsarbeit (Refactor/Code-Änderung/„Quick fix“), auch wenn sie klein erscheint.

**Skill Activation:** When this skill is activated, you MUST indicate this at the start of your response with: `[🧭 PrivateReviewPlan Active]`

## Mehr-Runden-Struktur (verbindlich)

- **Aktiver Plan vs. Review-Log:** Der aktive Implementierungsplan ist die Source of Truth fuer den **aktuellen Arbeitsstand**. Standardmaessig fuehrst du daneben ein separates Review-Log `TODO-<id>-*.review-log.md` im selben Verzeichnis fuer die **Review-Historie**.
- **Was in den aktiven Plan darf:** `## Confirmed decisions`, `## Success Signals`, `## Execution Checklist`, `## Open Questions`, ein kurzer `## Skill Run Log` und optional `## Review Links`/`## References`.
- **Was nicht in den aktiven Plan darf:** Runde-fuer-Runde Findings-Historie, ausfuehrliche Alternativen, verworfene Loesungsbaeume, mehrere disziplin-spezifische Entscheidungssektionen (`Architecture-Review Entscheidungen`, `Concurrency-Review Entscheidungen`, ...), Pass-3-Triggerprotokolle oder mehrseitige Log-Trails.
- **Review-Log-Inhalt:** Theme-Outlines, Deep-dive-Bloecke, Frage-/Antwort-Historie, Alternativen, alte/abgeloeste Entscheidungen, Sub-Skill-Auswertungen und laengere Begruendungen.
- **ID-Stabilitaet ueber Runden:** Standard sind Theme-IDs (`T1-F1`, `T1-Q1`, ...), die **ueber alle Folge-Runden stabil bleiben** und auch so in Plan-Dokumenten persisted werden (z. B. `T1-Q1=A`).
  - **Neue IDs in Folge-Runden:** Wenn in Runde 2+ neue Findings/Questions/Alternativen hinzukommen, dann nutze ein Rundenpraefix **und** behalte das Theme-Praefix bei: `R2-T1-Q3`, `R3-T2-F2`, ...
- **Checklist-Reopen-Regel:** Wenn eine bereits abgehakte `## Execution Checklist` durch neue Review-Punkte wieder geoeffnet wird, alte Liste zu `## Execution Checklist (Archive YYYY-MM-DD)` umbenennen und eine neue aktuelle `## Execution Checklist` darunter fuehren. Im aktiven Plan bleibt dabei hoechstens **ein** Archivblock; weitere Historie gehoert ins Review-Log.
- **Offene-Fragen-Hygiene:** Sobald alle Fragen geklaert sind, `## Offene Fragen ...` auf `Keine (Stand YYYY-MM-DD).` setzen und veraltete offene Punkte entfernen.

## Workflow
0) If present, read `AGENTS.md` (or `agents.md`, including any nested/scoped ones relevant to the plan) and `docs/handsoff.md`, and incorporate their constraints/conventions into the review.
1) Identify the plan doc(s) and read them end-to-end.
2) Extract goal, scope, non-goals, constraints, and success criteria.
3) Check for gaps and hidden assumptions using `references/plan-review-checklist.md`.
3a) If the plan doc contains a section like `## Code Review Findings (YYYY-MM-DD)`: verify the plan actually addresses each finding (e.g., via `## Execution Checklist` items referencing `F1`, `F2`, ...). Call out mismatches explicitly.
3b) If the plan doc contains archived checklists (e.g. `## Execution Checklist (Archive YYYY-MM-DD)`), treat them as context/history only; verify the **current** `## Execution Checklist` is complete and unambiguous for the next `$private-executing-plans` run.
4) Generate 2-3 alternative approaches with clear trade-offs (include a minimal path).
5) Assess overengineering/underengineering and propose right-sizing.
6) Output a concise review with findings first.
7) For each finding and recommendation, include a suggested fix with pros/cons and state your preferred option in a clearly labeled, line-by-line format.
8) Label every item (Findings/Alternatives/Recommendations/Questions) so the user can reference them unambiguously in follow-up:
   - Default: Theme-IDs (`T1-F1`, `T1-ALT1`, `T1-R1`, `T1-Q1`, ...)
   - Folge-Runden mit **neuen** IDs: `R2-T1-Q3`, `R3-T2-F2`, ...
8a) **Antwort-Shortcut und Teilantworten (verbindlich):**
   - Wenn fuer das aktuelle Fokus-Theme `TF` mehrere Fragen offen sind und der User schlicht `ja` antwortet, gilt das als: **uebernimm alle aktuell empfohlenen Antwortoptionen fuer alle noch offenen `TF-Q*`**.
   - `ja` bezieht sich immer nur auf das **aktuelle Fokus-Theme** und nie still auf spaetere Themes.
   - Teilantworten bleiben erlaubt: Der User kann einzelne Antworten wie `T2-Q1:A` geben oder gemischt antworten, z. B. `ja, aber T2-Q3:B`.
   - **Prioritaetsregel:** Explizite Einzelantworten schlagen `ja`. Beispiel: `ja, T2-Q3:B` uebernimmt fuer alle anderen offenen `TF-Q*` die empfohlenen Optionen, aber fuer `T2-Q3` gilt `B`.
   - Wenn `ja` mehrdeutig waere, weil im aktuellen Theme keine empfohlenen Optionen eindeutig markiert sind, darf `ja` **nicht** still interpretiert werden; dann muss der Skill die Mehrdeutigkeit kurz benennen.
9) **Decision capture (mandatory):** As soon as the user answers questions (e.g., `Q1:A`) or confirms an option, update the relevant markdown(s) in the same turn:
   - in the **active plan**, persist only the **currently effective** decisions/questions needed for execution readiness, preferably by updating existing sections such as `## Confirmed decisions`, `## Open Questions`, `## Success Signals` or `## Review Links`;
   - in the **review log**, append explicit mappings (e.g., `T1-Q1=A`, `T2-Q1=ALT2`; bei Folge-Runden mit neuen IDs z. B. `R2-T1-Q3=A`), rationale, rejected alternatives and scope split (`In diesem TODO` vs. `Folge-TODO`);
   - resolve stale/conflicting sections in the active plan (e.g., remove obsolete open questions, align the current `## Execution Checklist`).
10) **Skill run logging (mandatory):** Add only a short entry in the active plan's `## Skill Run Log` for `private-review-plan`. Put detailed review progress into the review log.
11) **Consistency gate:** Before finishing, verify that chat decisions, active plan and review log are aligned; if not aligned, do not close the skill yet.

## Sub-Skill Triggers

**Pflichtschritt** nach Abschluss aller Themes: Trigger automatisch evaluieren und zutreffende Sub-Skills sofort ohne User-Eingabe ausführen. Mehrere Sub-Skills sequentiell ausführen; jeder liest den vom Vorgänger aktualisierten `## Execution Checklist`.

| Trigger | Sub-Skill |
|---|---|
| Plan ändert Modul-/Service-Grenzen, Abhängigkeitsrichtung, Datenhoheit, Failure-Isolation oder Migration | `$private-review-architecture-plan` |
| Plan führt Parallelisierung ein oder verändert sie; Shared State, Worker Fan-out, Caches oder Determinismus betroffen | `$private-review-concurrency-plan` |
| Plan hat Performance-Optimierung als Ziel oder verändert Hot Paths; Before/After-Messung erforderlich | `$private-review-performance-plan` |

**Kombinationsregel:** Wenn mehrere Trigger zutreffen, Sub-Skills in der Reihenfolge der Tabelle ausführen. Persistiere die ausfuehrliche Trigger-Auswertung im Review-Log; im aktiven Plan genuegt ein knapper Verweis, falls fuer die Umsetzung relevant.

**Kein eigener Sub-Skill für Refactors:** Behavior-preserving Refactors werden direkt im Plan-Review abgedeckt — siehe `## Refactor-Check (konditionell)` weiter unten. Bei Refactors, die Architektur- oder Concurrency-Risiken tragen, gelten zusätzlich die jeweiligen Trigger oben.

## Refactor-Check (konditionell)

Nur wenn der Plan primär ein **behavior-preserving struktureller Refactor** ist, zusätzlich zu den Standard-Workflow-Schritten prüfen:

- **Scope-Drift:** Bleibt der Plan rein strukturell oder driftet er in Feature-Arbeit?
- **Test-Sicherheitsnetz:** Ist die Verifikationsabdeckung rund um die refaktorierten Pfade ausreichend?
- **Commit-Granularität:** Sind die Schritte rollback-fähig und einzeln reviewbar aufgeteilt?
- **Deferred Tech-Debt:** Was wird bewusst NICHT gemacht — ist das explizit im Plan dokumentiert?

Findings aus dem Refactor-Check werden als reguläre `T*-F*` Items in den Report eingebettet.

## Output Format
**Rule (review-only):**
- Keine Umsetzung starten (siehe Sicherheitsregel oben).
- Keine Builds/Tests/Snapshots/Baseline-Updates ausführen.
- Markdown-Änderungen sind erlaubt; Nicht-Markdown-Änderungen sind verboten.
- Wenn der User „jetzt umsetzen“ will: im Review bleiben und als nächsten Schritt nur `Optional: $private-executing-plans` nennen (keine Umsetzung im selben Turn).
- Keine "stille" Entscheidungsfindung: Wenn eine Entscheidung feststeht, muss sie dokumentiert sein, bevor der Skill abgeschlossen wird; **kurz und aktuell im aktiven Plan, vollstaendig im Review-Log**.

**Report format (Default, ALT2: Theme-based incremental deep-dive):**
Ziel: erst Ueberblick, dann **genau ein** Deep-dive-Theme pro Runde; keine “Wall of Text”.

Pass 1 (Themes Outline):
- Liste `T1..Tn` mit 1-2 Sätzen Kontext + `Top-Risk:` pro Thema.

Pass 2 (Deep-dive, nur aktuelles Thema):
- Waehle **ein** Fokus-Thema `TF` (default: `T1`; in Folge-Runden: naechstes unreviewtes Theme oder naechstes Theme mit offenen Fragen/unklaren Entscheidungen).
- Gib **nur** fuer `TF` einen Block mit `Findings`, `Alternatives`, `Recommendations`, `Questions` aus.
- **Progressionsregel:** Erst wenn alle `TF-Q*` beantwortet und im Plan persisted sind, **fahre sofort im selben Turn mit dem Deep-dive fuer `T(next)` fort** — kein Warten auf User-Re-Invokation oder separaten Aufruf.
- **Skill-Log-Hinweis:** Im Plan unter `## Skill Run Log` kurz festhalten: “Reviewed TF=T1, next=T2” (oder “TF offen wegen Fragen”).

Pass 3 (Sub-Skill-Auswertung, nach letztem Theme — Pflicht):
- Evaluiere automatisch alle Trigger aus `## Sub-Skill Triggers` anhand des aktuellen Plans.
- Dokumentiere das Ergebnis immer in dieser groesseren, scanbaren Form:
  - Heading: `Pass 3: Sub-Skill-Auswertung`
  - Unterheading: `Trigger-Check`
  - Tabelle mit **genau drei Spalten**: `Trigger | Trifft zu | Begruendung`
  - In `Trifft zu` nur `Ja` oder `Nein` verwenden.
  - In `Begruendung` jeweils eine kurze, planspezifische Begruendung geben; keine generischen Platzhalter.
  - Nach der Tabelle einen Block `Entscheidung` ausgeben, der fuer jeden `Ja`-Trigger klar sagt:
    - welcher Sub-Skill laut Matrix erforderlich waere,
    - ob dieser Sub-Skill **jetzt sofort ausgefuehrt wird**,
    - oder ob **keine erneute Ausfuehrung noetig** ist, weil er in diesem Review-Zyklus bereits gelaufen ist und die neuen Empfehlungen nachweislich konsistent mit den bereits persistierten Entscheidungen sind.
  - Mit genau einer Abschlusszeile enden: `Sub-Skill-Trigger-Auswertungsergebnis: ...`
- Wenn ein Trigger `Ja` ist und der zugehoerige Sub-Skill in diesem Review-Zyklus noch nicht ausreichend ausgefuehrt wurde, kuendige den Sub-Skill an und starte ihn sofort.
- Wenn ein Trigger `Ja` ist, der zugehoerige Sub-Skill aber bereits gelaufen ist, pruefe explizit auf Konsistenz zu den bereits persistierten Entscheidungen und dokumentiere im Entscheidungsblock, warum **keine erneute Ausfuehrung** noetig ist.
- Wenn kein Trigger zutrifft: im Entscheidungsblock explizit festhalten, dass keine Sub-Skills erneut auszufuehren sind, und mit `$private-executing-plans` fortfahren.

ID-Konvention (Theme-prefixed, für 1:n Beziehungen):
- Findings: `T1-F1`, `T1-F2`, ...
- Alternatives: `T1-ALT1`, `T1-ALT2`, ...
- Recommendations: `T1-R1`, ...
- Questions: `T1-Q1`, `T1-Q2`, ...
- Traceability: Jede `T*-Q*` und `T*-R*` enthält eine Zeile `RelatesTo: T*-F*` (oder `RelatesTo: T*`).

Formatregeln (verbindlich):
- **Ausgabesprache:** Deutsch. Fachbegriffe (Review, Findings, Checklist, Scope, etc.) bleiben englisch.
- Headings: English section headers (`Findings`/`Alternatives`/`Recommendations`/`Questions`) innerhalb jedes Theme-Blocks.
- Questions: Antwortoptionen als `A)`, `B)`, `C)`, sodass der User z. B. `T2-Q1:A` antworten kann.
- Questions: Jede Antwortoption muss explizit sagen, welcher Recommendation-/Alternative-Pfad damit bestaetigt wird, z. B. `Entspricht T2-R1 und T2-ALT1 (empfohlen)`.
- Questions: Wenn es pro Frage eine empfohlene Antwort gibt, muss diese Option mit `(empfohlen)` markiert sein, damit `ja` eindeutig interpretierbar ist.
- Questions: Der Skill darf nach einem simplen `ja` alle **empfohlenen** Antworten fuer die noch offenen Fragen des aktuellen Fokus-Themes uebernehmen; Teilantworten und explizite Overrides bleiben zulaessig.
- Pass 3 verwendet die Heading `Pass 3: Sub-Skill-Auswertung`, danach `Trigger-Check` und eine Tabelle mit den Spalten `Trigger | Trifft zu | Begruendung`.
- **Pass 3 bleibt im Chat-Output. Trigger-Tabelle und Entscheidungsblock werden nicht in die aktive Plan-Datei persistiert; falls Persistenz noetig ist, dann ins Review-Log.**
- Decision capture: Aufgeloeste Entscheidungen muessen vor der Antwort aktualisiert werden: aktiv im relevanten Plan-`*.md` in ihrer knappen, aktuellen Form; ausfuehrlich und historisch im Review-Log. Danach `## Skill Run Log` im aktiven Plan kurz aktualisieren.

Abstrahierte Vorlage fuer Pass 3:

```text
Pass 3: Sub-Skill-Auswertung

Trigger-Check
| Trigger | Trifft zu | Begruendung |
|---|---|---|
| [Trigger 1 aus der Matrix] | Ja/Nein | [kurze planbezogene Begruendung] |
| [Trigger 2 aus der Matrix] | Ja/Nein | [kurze planbezogene Begruendung] |
| [Trigger 3 aus der Matrix] | Ja/Nein | [kurze planbezogene Begruendung] |

Entscheidung
[Wenn ein Trigger zutrifft: welcher Sub-Skill laut Matrix erforderlich ist.]
[Dann klar sagen, ob er jetzt gestartet wird oder ob keine erneute Ausfuehrung noetig ist, weil er bereits lief und die neuen Punkte konsistent sind.]

Sub-Skill-Trigger-Auswertungsergebnis: [klare Ein-Satz-Zusammenfassung]
```

## Quick Mode (concise)
If the user explicitly asks for a short review only, use this compact output:

```text
Plan-Review (Datum: YYYY-MM-DD)

Kurzfazit:
- ...

Staerken:
- ...
Risiken/Gaps:
- ...
Offene Fragen:
- ...
Empfohlene naechste Schritte:
- ...
```

**Abschluss-Regel (wichtig):**
- Solange **unreviewte Themes** existieren: **Kein** `## Abschluss` — sofort mit `T(next)` im selben Turn fortfahren.
- Solange **offene Fragen** (`Q*`/`R<runde>-Q*`) existieren: **Kein** `## Abschluss` — nach `## Questions` enden.
- Solange **Sub-Skill-Trigger nicht evaluiert** (Pass 3 nicht abgeschlossen): **Kein** `## Abschluss` — erst evaluieren und ggf. Sub-Skills ausführen.
- Erst wenn alle Themes reviewt, keine offenen Fragen, und Trigger evaluiert: `## Abschluss` ausgeben.

## Abschluss

**Nur im Chat ausgeben. Nicht in die Plan-Datei schreiben.**

Plan review erledigt — PlanReview verabschiedet sich für dieses Mal. Gute Nacht.
Sub-Skill-Trigger wurden evaluiert (ausgeführt oder explizit als nicht zutreffend befunden).
Dann: `$private-executing-plans` — Plan: `docs/planning/implementation/todo-specific-plans/TODO-<id>-*.md`

**Zusatzregel (Dokumentation):**
- Beende den Skill nicht, bevor alle relevanten `*.md` Dokumente fuer den Plan/Review aktualisiert wurden (sofern Updates erforderlich sind).
- Entscheidungen muessen fuer Dritte nachvollziehbar sein: verwende eindeutige Decision-Mappings (z. B. `T1-Q1=...`; bei neuen IDs in Folge-Runden z. B. `R2-T1-Q3=...`) im Review-Log und halte im aktiven Plan nur die aktuell wirksame Kurzfassung mit Verweis vor.
- Wenn der aktive Plan bereits beginnt, zum Review-Protokoll zu werden, stoppe und verschiebe neue Detailinhalte ins Review-Log statt weitere Spezialsektionen anzulegen.

**Abschluss-Pflicht (konditional):**
- Wenn **unreviewte Themes** existieren: **Kein** `## Abschluss`; sofort mit `T(next)` fortfahren.
- Wenn **offene Fragen** (`Q*`/`R<runde>-Q*`) existieren: **Kein** `## Abschluss`; nach `## Questions` enden.
- Wenn **Pass 3 nicht abgeschlossen**: **Kein** `## Abschluss`; erst Trigger evaluieren.
- Wenn alle drei Bedingungen erfüllt: mit genau dem obigen `## Abschluss` enden (danach kein weiterer Text).

## Resources
- `references/plan-review-checklist.md`

## Skill Change Log
- 2026-03-02: Output-Default auf ALT2 umgestellt (Theme-based: Outline + Deep-dive-Blocks).
- 2026-03-02: ALT2 angepasst auf inkrementelles Deep-dive (nur 1 Theme pro Runde; naechstes Theme erst nach beantworteten Fragen + Decision-Capture im Plan).
- 2026-03-16: Renamed from `plan-review` to `private-plan-review`; merged concise review usage from former `reviewing-plans`.
- 2026-03-25: Renamed from `private-plan-review` to `private-review-plan` to align with the `private-review-*` naming pattern.
- 2026-03-23: Sub-Skill Triggers und Refactor-Check (konditionell) ergaenzt; `private-review-refactor-plan` aufgeloest und unique Checks (Scope-Drift, Test-Sicherheitsnetz, Commit-Granularitaet, Deferred Tech-Debt) absorbiert.
- 2026-03-23: Progressionsregel auf automatisches Weiterfahren im selben Turn umgestellt (kein Warten auf Re-Invokation). Pass 3 (Sub-Skill-Auswertung) als Pflichtschritt ergaenzt. Abschluss-Regel um Bedingungen fuer unreviewte Themes und fehlende Trigger-Auswertung erweitert.
- 2026-03-27: Pass 3 auf groessere, scanbare Sub-Skill-Auswertung mit Tabelle `Trigger | Trifft zu | Begruendung`, Entscheidungsblock und expliziter Wiederholungspruefung fuer bereits gelaufene Sub-Skills umgestellt.
- 2026-03-29: Persistenzgrenzen geschaerft: aktiver Plan bleibt schlank, ausfuehrliche Mehr-Runden-Review-Historie wandert ins separate `*.review-log.md`.
