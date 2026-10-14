---
name: private-code-review
description: Use when reviewing code changes on the current branch and producing a risk-focused report before merge or refactoring, especially when a TODO-linked follow-up checklist is needed.
---

# Private Code Review

## Overview

Ermittle die Diffs zwischen aktuellem Branch und `master` (Fallback: `main`) und liefere ein strukturiertes Review (Änderungsüberblick, Risiken, Qualitäts-Checks, konkrete Verbesserungs-Vorschläge) – ohne Code zu ändern.

**Skill Activation:** Wenn dieser Skill aktiv ist, musst du das am Anfang deiner Antwort mit folgender Zeile kennzeichnen: `[🔍 CodeReview Active]`

## Workflow (Report-only)

Defaults in this skill assume a TODO-driven workflow. If the repository provides `.agents/workflow-profile.yaml`, prefer its configured paths and conventions over hardcoded defaults.

**Ausgabesprache:** Deutsch. Fachbegriffe (Review, Findings, Checklist, Scope, etc.) bleiben englisch.

**Regel:** Im eigentlichen Review keine Änderungen/Commits am Code. Nur Analyse + Report.
**Preflight-Ausnahme:** Für `Non-MD dirty` darf der Skill standardmaessig einen Review-Snapshot-Commit erzeugen, sofern der Nutzer keinen anderen Modus vorgibt.

**Markdown-Ausnahme (erlaubt):**
- `*.md` Dateien dürfen für das Review **erstellt** oder **aktualisiert** werden (z. B. Review-Notizen/Report als Markdown), wenn das den Review-Prozess konkret verbessert.
- `*.md` Dateien dürfen **nur nach Rückfrage** gelöscht werden.

### 0) Startlogik (kompakt)
- **Default:** `current worktree = current TODO`.
- TODO-ID vor Preflight automatisch bestimmen (Reihenfolge):
  1) Branchname (z. B. `feature/todo-134-*`)
  2) geänderte `docs/planning/implementation/todo-specific-plans/TODO-*.md`
  3) Eintrag unter **In Progress** in `docs/TODO.md`
- Wenn keine **eindeutige** TODO-ID ermittelbar ist: Nutzer um explizite TODO-Nummer bitten und pausieren.

### 0.1) Preflight (Working Tree / Commit-Stand, Review-Modi)
- Prüfe `git status --porcelain=v1`.
- Klassifiziere uncommitted Änderungen in:
  - **MD-only dirty**: nur `*.md` (inkl. Adds/Mods/Renames/Deletes)
  - **Non-MD dirty**: mindestens eine Nicht-`*.md`-Änderung
- Der Skill kennt drei Preflight-Modi:
  - **Review-only**: liest und berichtet nur; keine Commits, kein Stash, keine Tree-Manipulation.
  - **Snapshot**: erzeugt einen Review-Snapshot-Commit und reviewt danach den sauberen `HEAD`.
  - **Committed-only**: reviewt nur `master...HEAD`; uncommitted Non-MD-Dateien bleiben bewusst ausserhalb des eigentlichen Diff-Scopes und muessen im Report explizit genannt werden.
- **Default-Modus:** `Review-only`, solange der Worktree clean oder nur `MD-only dirty` ist.
- **MD-only dirty:** Review ist im Default-Modus erlaubt; im Report klar nennen, dass `master...HEAD` uncommitted Änderungen nicht enthält, plus kurze MD-Dateiliste.
- **Non-MD dirty:** **Default ist `Snapshot`**. Wenn der Nutzer keinen anderen Modus vorgibt, darf Codex die aktuellen Non-MD-Änderungen in einen Review-Snapshot-Commit uebernehmen und den Review danach automatisch auf dem sauberen `HEAD` fortsetzen.
- Zulässige Fortsetzung bei **Non-MD dirty**:
  - **Option 1:** Nutzer committed selbst; danach normaler Review auf cleanem Tree.
  - **Option 2 (Default):** Codex committet den aktuellen Stand als Review-Snapshot und setzt den Review danach automatisch fort. Fuer Follow-up-Fixes bevorzugt den Commit-Betreff `Review snapshot for TODO-<id> follow-up <finding-id-or-purpose>` verwenden.
  - **Option 3:** Nutzer erzwingt explizit `CONFIRM: review only existing commits`; dann als **committed-only** fortsetzen und die Non-MD-dirty Files explizit im Scope nennen.
- `stash` ist kein Default- oder Auto-Pfad. Wenn überhaupt, dann nur auf ausdrücklichen Nutzerwunsch.

### 1) Basis bestimmen (master/main)
- Bevorzuge `master`. Wenn nicht vorhanden, nutze `main`.
- Wenn **weder** `master` **noch** `main` existiert: **Nutzer informieren und Skill-Workflow hier unterbrechen** (kein Fallback auf "irgendeinen" lokalen Default-Branch).
  - Bitte den Nutzer um eine explizite Basis (z. B. `develop`, `release/*`, `origin/main`) und führe das Review erst danach fort.
- Hinweis: Wenn kein `git fetch` erfolgt ist (z. B. wegen Sandbox/Policy), im Report explizit sagen, dass `master`/`origin/master` ggf. nicht aktuell sind.

### 2) Überblick generieren (automatisiert, Lean-first)
- Führe `scripts/branch_review.sh` aus und nutze dessen Output als Ausgangspunkt.
- **Pfadauflösung (wichtig):** `scripts/branch_review.sh` ist relativ zum **Skill-Verzeichnis** gemeint (neben dieser `SKILL.md`), nicht relativ zum Repo-Root.
  - Konkreter Pfad dieses Skills: `private-code-review/scripts/branch_review.sh`
  - Beispiel: `/home/Juergen/.agents/skills/private/private-code-review/scripts/branch_review.sh` mit `workdir` auf das Ziel-Repo.

### 2.0) Review-Scope bestimmen: Full vs. Follow-up
- **Full Review (Default):** Reviewe `base...HEAD`, wenn kein eindeutiges Follow-up-Signal vorliegt.
- **Follow-up Review (Delta Mode):** Aktiviere Delta Mode, wenn mindestens eins der folgenden harten Signale vorliegt:
  - Der Nutzer sagt explizit `follow-up`, `nach Fix`, `Runde 2`, `nächste Runde`, `nochmal review` oder aequivalent.
  - `HEAD` ist ein Review-Snapshot und der Commit-Betreff enthaelt `follow-up`, `F1`/`F2`/... oder einen Finding-/Fix-Hinweis.
  - `HEAD` ist ein Review-Snapshot und `HEAD~1` ist ein vorheriger Review-Snapshot oder anderweitig als bereits reviewter Stand erkennbar.
  - Das TODO-Plan-File enthaelt `## Code Review Findings` und die aktuelle `## Execution Checklist` referenziert `F1`/`F2`/... oder ist eine abgeschlossene Folge-Checklist.
- **Delta Mode Scope:**
  1. Nutze `base...HEAD` nur als Guardrail-Ueberblick: `branch_review.sh`, `git diff --stat base...HEAD`, `git diff --name-only base...HEAD`.
  2. Nutze als primaeren Review-Scope den letzten Follow-up-Delta, normalerweise `HEAD~1...HEAD`: `git show --stat HEAD`, `git diff --name-only HEAD~1...HEAD`, Risikocluster, dann gezielte Datei-Diffs nur fuer Delta-Dateien.
  3. Lies TODO-/Plan-Markdown nur section-basiert, um Finding-Labels und Checklist-Abdeckung zu bestaetigen.
  4. Im Report Scope klar `Mode: Follow-up Delta`, `Primary diff: HEAD~1...HEAD` und `Guardrail diff: base...HEAD` nennen.
- **Full-Review-Eskalation aus Delta Mode:** Wechsel sofort auf Full Review, wenn der Delta-Diff neue oder unerwartete Risiken beruehrt: public/API-Contracts, `*.csproj`/`Directory.*.props`/Packages, DI/Composition, Orchestrierung, Persistenz/Dateipfade, Guardrails/handsoff, Snapshot-/Baseline-Dateien, viele Subsysteme oder Dateien ausserhalb des Finding-/Checklist-Scope.
- **Qualitaetsregel:** Delta Mode darf bereits reviewte Flaeche ausblenden, aber keine neue Risikoflaeche. Wenn nicht sicher bestimmbar ist, ob `HEAD~1` ein geeigneter bereits reviewter Stand ist, Full Review verwenden.

### 2.1) Lean-Mode mit hartem Analyse-Budget (verbindlicher Default)
- Default ist **Lean Mode** mit festem Budget; Deep-Dive ist die Ausnahme, nicht der Standard.
- Erlaubt ohne Deep-Dive-Trigger:
  - `scripts/branch_review.sh`
  - `git diff --stat <base>...HEAD`
  - `git diff --name-only <base>...HEAD`
  - zuerst maximal **2-3** gezielte Datei-Diffs auf produktiven Hochrisiko-Dateien
  - insgesamt maximal **5** gezielte Datei-Diffs im Lean-Mode
  - maximal **3** gezielte Zeilenabfragen fuer exakte Referenzen
- Nicht erlaubt im Lean-Default:
  - Vollstaendiges Lesen grosser Diffs
  - Vollstaendiges Lesen kompletter Plan-/Markdown-Dateien
  - doppelte Sicht auf denselben Abschnitt (`git diff` plus `nl -ba` auf Verdacht)
  - breite Diff-Gruppen auf Vorrat, bevor die ersten Hochrisiko-Dateien ausgewertet sind
- Reihenfolge im Lean-Default ist verbindlich:
  1. `branch_review.sh`, `diff --stat`, `diff --name-only`
  2. Risikocluster bilden
  3. zuerst **2-3** produktive Hochrisiko-Dateien lesen
  4. erst danach gezielt Tests oder weitere Produktionsdateien nachziehen, wenn die ersten Diffs offene Fragen lassen
  5. Markdown zuletzt und nur bei echter Review-Notwendigkeit
- Diffs standardmaessig begrenzen:
  - Nutze `git diff --unified=3 <base>...HEAD -- <path1> <path2> ...`
  - Lies nur gezielte Hochrisiko-Dateien; keine "einmal alles aufmachen"-Schleife
  - Tests nicht parallel zu mehreren grossen Produktiv-Diffs oeffnen, solange der Kern-Change noch nicht verstanden ist
- Wenn innerhalb dieses Budgets keine belastbaren Defekte entstehen:
  - explizit `keine Findings im Lean-Scope` sagen
  - nur dann in Deep-Dive wechseln, wenn ein Trigger aus Abschnitt 3.2 vorliegt
- Test-Logs minimieren:
  - `dotnet test` standardmaessig mit `-v minimal` ausfuehren
  - `dotnet test`-Kommandos **immer sequenziell** ausfuehren: nie per `multi_tool_use.parallel`, Shell-Backgrounding, parallelen Shell-Sessions oder mehreren gleichzeitig laufenden `dotnet test`/Restore-Prozessen starten
  - erst wenn ein `dotnet test`-Prozess vollstaendig beendet und der Exit-Code gelesen ist, den naechsten Testfilter starten; das verhindert konkurrierende Restore-/`project.assets.json`-Zugriffe und vermeidet unnoetige Log-Ausgabe
  - andere Review-Reads (`git diff`, `sed`, `rg`, `branch_review.sh`) duerfen weiter parallelisiert werden, solange kein `dotnet test` parallel dazu laeuft
  - fuer den Report nur Summary-Zeilen plus Exit-Code auswerten; keine Vollausgabe in den Kontext laden, solange Tests gruen sind
  - bevorzuge dafuer `scripts/test_summary.sh --exit-code <code> --file <log-file>`, damit die Testauswertung knapp und konsistent bleibt
  - sprachrobuste Summary-Erkennung verwenden (mindestens Deutsch/Englisch), z. B.:
    - `^Testzusammenfassung:`
    - `^Test summary:`
    - `^Passed!  - Failed:`
    - `^Failed!  - Failed:`
  - wenn keine Summary-Zeile gefunden wird, Ergebnis trotzdem ueber den Prozess-Exit-Code bewerten und im Report transparent als `Summary nicht erkannt` markieren

### 2.2) Markdown-/Plan-Dateien nur section-basiert lesen (strict)
- Markdown-Dateien sind im Review standardmaessig Transportmedium, nicht primaerer Review-Gegenstand.
- TODO-/Plan-Dateien nur section-basiert lesen, in dieser Reihenfolge:
  1. Frontmatter
  2. `## Execution Checklist`
  3. `## Code Review Findings`
  4. `## Skill Run Log`
- Bevorzuge dafuer `scripts/extract_md_sections.sh <file> --frontmatter --heading "Execution Checklist" --heading "Code Review Findings" --heading "Skill Run Log"`, damit Markdown-Reads klein und reproduzierbar bleiben.
- Ganze Markdown-Dateien nur laden, wenn:
  - mehrere relevante Sektionen widerspruechlich wirken
  - die genaue Insertionsstelle sonst nicht sicher bestimmbar ist
  - die Markdown-Datei selbst Kern des Reviews ist

### 2.3) Dateiauswahl vor Dateilesen (strict)
- Vor jedem Datei-Open zuerst:
  - `git diff --name-only <base>...HEAD`
  - betroffene Dateien nach Risiko clustern
- Bevorzuge dafuer `scripts/review_risk_files.sh <base>` oder `scripts/review_risk_files.sh --stdin`, damit die Risikoselektion konsistent und knapp bleibt.
- Risikoreihenfolge fuer den ersten Zugriff:
  - Config/DI/Orchestrierung
  - Contracts/Public API
  - Reporting/Persistenz/Fehlerpfade
  - Tests
  - Markdown
- Erst danach gezielte Datei-Diffs auf die hoechsten Risikopfade anwenden.
- Markdown-Dateien nie vor produktivem Code priorisieren, ausser fuer TODO-Zuordnung oder Pflicht-Persistenz.

### 2.4) Exakte Referenzen spaet holen
- `nl -ba` nur fuer bereits identifizierte Findings verwenden.
- Erst inhaltlich klaeren, ob wirklich ein Finding vorliegt; danach gezielt Zeilennummern holen.
- Keine Referenzsammlung auf Verdacht.

### 3) Risikoanalyse

#### 3.1) Fokusbereiche
- Priorisiere: Konfiguration/Orchestrierung, Variation/Factories, Reporting/Outputs, Cross-Project-Interfaces/Contracts.
- Wenn `*.csproj`/`Directory.Build.props`/`Directory.Packages.props`/NuGet-Packages betroffen sind: API-/Build-/Runtime-Risiken explizit bewerten.
- Wenn DI-/Composition-Code betroffen ist: Lifetimes, Registrierungen und Ripple-Effekte in `App`/`PerformanceAnalysis` explizit prüfen.
- Wenn Guardrail-Dateien betroffen sind (siehe `docs/handsoff.md`), explizit markieren.

#### 3.2) Deep-Dive-Trigger (konkretes Risiko)
- Schalte von Lean auf Deep-Dive nur bei mindestens einem Trigger:
  - API-/Contract-Änderungen (`public` Signaturen, DTO-Shape, Cross-Project-Interfaces).
  - Konfig-/Build-/Package-Änderungen (`*.csproj`, `Directory.*.props`, NuGet-Versionen).
  - Orchestrierung/Fehlerpfade/Dateipfad- oder Persistenzlogik betroffen.
  - Snapshot-/Baseline-Änderungen ohne klaren Begründungszusammenhang.
  - Große oder breit gestreute Diffs (mehrere Subsysteme) mit unklarer Testabdeckung.
  - Guardrail-/Handsoff-Dateien betroffen.
- Wenn kein Trigger zutrifft: beim Lean-Umfang bleiben und kein unnötiger Vollscan.

#### 3.3) Priorisierung & Finding-Disziplin (verbindlich)
- **Findings immer nach Impact priorisieren** und mit expliziter Kennzeichnung ausgeben:
  - **Review-Runde 1 - Prio 1 (kritisch):** potenziell falsche Fachergebnisse, Breaking Changes, Datenverlust, harte Runtime-/Orchestrierungsfehler.
  - **Review-Runde 1 - Prio 2 (hoch):** wahrscheinliche Regressionen, fehlerhafte Diagnostik/Fehlerklassifikation, unzureichend abgesicherte Contract-Änderungen.
  - **Review-Runde 1 - Prio 3 (mittel/niedrig):** Wartbarkeit, Test-Hygiene, Logging-/Code-Smells ohne akuten Fachschaden.
- **Begriffe:** "Review-Runde" bezeichnet den Durchlauf dieses Reviews und ist unabhaengig von der "Umsetzungsrunde" eines TODO-/Plan-Dokuments. Beide Achsen nie vermischen.
- **Kurzreferenzen vermeiden:** Keine nackten `P1/P2/P3`- oder `R2-P1`-Labels — sprechende Formen wie `F1 (Review-Runde 1 - Prio 2)` im Review-Output verwenden.
- **Finding vs. Umsetzungsrunde-2+-Punkt:** Ein Punkt ist nur dann ein *Finding*, wenn er als konkretes Problem/Regression/Blocker bewertet wird. Reine Refactors/Verbesserungen, die bewusst in eine spätere Umsetzungsrunde verschoben werden, kommen in den Report-Block **Runde 2+ Punkte** (und ggf. als eigene Plan-Sektion), nicht in **Findings**.
- **No-noise Regel:** Low-Cost-Hygienechecks (z. B. `Console.WriteLine`) dürfen High-Impact-Findings nicht überlagern.
- **Wenn keine echten Defekte gefunden werden:** explizit "keine Findings" sagen statt künstlich schwacher Punkte.
### 4) Qualitätsbeurteilung (heuristisch + gezielt)
Für geänderte C#-Dateien (insb. `*.csproj`, `*.cs`):
- **High impact checks (priorisiert):**
  - **API-/Interface-/Contract-Änderungen:** Breaking Changes? Ripple-Effekte in `App`/`PerformanceAnalysis`/Tests? Migration/Compat klar?
  - **DI/Lifetimes:** Keine Singleton→Scoped-Abhängigkeiten; Registrierungen vollständig; Factory/Options/Wiring konsistent.
  - **Konfiguration/Dateipfade:** Änderungen an Options/Defaults/Path-Resolution/Fail-fast vs Fallback; `appsettings*.json`/Schemas/Validatoren konsistent.
  - **Determinismus (Reporting/Outputs):** Keine versteckten Zeitquellen (`Now/UtcNow`), keine unseeded Randomness, stabile Sortierung (z. B. `OrderBy(..., StringComparer.Ordinal)`), keine `Dictionary`-Iteration als Output-Reihenfolge, Kultur/TimeZone explizit.
  - **Backtest-Integrität (fachlich):** kein Lookahead-Bias, keine Daten-Leakage zwischen Trainings-/Auswertungsphasen, Signal-/Trade-Zeitbezug konsistent.
  - **Fehlersemantik/Diagnostik:** Error/Warning/Info korrekt klassifiziert, Root-Cause erkennbar, keine irreführenden Fehlermeldungen.
  - **Snapshot-/Baseline-Drift:** Bei Snapshot-Änderungen auf fachliche Plausibilität, Drift-Ursache und Guardrail-Qualität prüfen (nicht nur "Datei geändert").
  - **Test-Signale:** Tests angepasst/ergänzt und passend (Unit vs Integration); Guardrails (Snapshot/Drift) richtig platziert; keine unnötig flakigen Tests.
- **Quick sanity checks (sekundär, aber cheap):**
  - **Guards:** Constructor-Dependencies via `Guard.Against.Null(...)`/`NullOrEmpty(...)` abgesichert.
  - **Logging:** kein `Console.WriteLine`; strukturiertes Logging via `ILogger<T>`/`ILoggerFactory`.
  - **`Console.WriteLine`-Regel:** weiterhin **immer prüfen**, aber als Finding nur melden, wenn neu im produktiven Pfad (typisch Prio 3; bei sicherheits-/compliance-relevantem Kontext höher einstufen).
  - **Line endings / formatting noise:** Nur erwähnen, wenn Diff/Blame-Noise droht (z. B. große reine EOL-Änderungen).

Für geänderte Markdown-/Plan-Dateien:
- **Datumsangaben:** Status-/Validation-Notizen nutzen das tagesaktuelle Datum (keine alten Template-Werte).
- **Frontmatter:** YAML-Felder sind Englisch (keine `author`-Felder); Prosa i. d. R. Deutsch (Repo-Konvention).

### 5) Report-Raster (kompakt, immer gleich)
Nutze genau dieses Raster und diese Reihenfolge:

| Block | Pflichtinhalt |
|---|---|
| Scope | Branch, Basis-Branch, #Commits, #Files, betroffene Projekte |
| Findings | Priorisiert `Review-Runde 1 - Prio 1` → `Review-Runde 1 - Prio 3`; je Finding: Impact + konkrete Abhilfe |
| Runde 2+ Punkte | Optional: bewusst deferred Refactors/technische Schulden; je Punkt: Ziel + grober Fix-Ansatz |
| Wichtigste Änderungen | Nur wenn `branch_review.sh` den Kontext noch nicht ausreichend abdeckt |
| Risiken/Regression-Punkte | Mit expliziter Kennzeichnung |
| Codequalität | High-Impact-Checks + Hygienechecks; bei Hygiene ohne Verstöße kurz "keine Auffälligkeiten" |
| Konkrete Empfehlungen | Next steps |

#### 5.1) Kurzmodus (Default, verbindlich)
- Der Review-Output im Chat bleibt kurz und entscheidungsorientiert; detaillierte Beweisführung nur bei expliziter Nachfrage.
- Harte Längenlimits pro Block:
  - **Scope:** max. 4 bullets.
  - **Findings:** pro Finding genau 1 Bullet mit `Impact` + `Abhilfe`, jeweils knapp; Begründungstext max. 3 Sätze.
  - **Runde 2+ Punkte:** max. 2 bullets.
  - **Wichtigste Änderungen:** max. 3 bullets und nur wenn der Kontext nicht schon aus `branch_review.sh` klar ist.
  - **Risiken/Regression-Punkte:** max. 3 bullets.
  - **Codequalität:** max. 3 knappe Punkte.
  - **Konkrete Empfehlungen:** max. 3 nummerierte Punkte.
- Im Chat keine langen Zitierpassagen aus Design-/Code-Dateien. Stattdessen kurze Aussage + präzise Dateireferenzen.
- Bei persistierten Findings im Plan-`*.md`: im Chat nur Titel + Impact + Abhilfe plus Verweis auf Datei + Section.
- Ohne persistierpflichtige Findings bleibt der Review-Output standardmaessig im Chat; es wird kein Plan-`*.md` nur fuer Review-Notizen angelegt oder erweitert.
- `Runde 2+ Punkte` nur ausgeben, wenn es echte deferred Arbeit gibt oder der Nutzer explizit nach Follow-up-Scope fragt.
- Optionaler Deep-Dive nur bei Nutzerwunsch (`DETAILS: review`) oder wenn ein Trigger aus Abschnitt 3.2 vorliegt.

#### Findings-Template (kurz, copy/paste)

```md
**Findings**
- **F1 (Review-Runde 1 - Prio 1) – <Titel>**: Impact: <fachlich/technisch>. Abhilfe: <konkreter Fix/Absicherung>.
- **F2 (Review-Runde 1 - Prio 2) – <Titel>**: Impact: <Regression/Fehlklassifikation>. Abhilfe: <konkreter Fix/Test>.
- **F3 (Review-Runde 1 - Prio 3) – <Titel>**: Impact: <Wartbarkeit/Hygiene>. Abhilfe: <Verbesserung>.
```

Wenn keine Findings vorliegen:

```md
**Findings**
- Keine Findings.
```

#### Runde-2+-Template (kurz, copy/paste)

```md
**Runde 2+ Punkte**
- **Umsetzungsrunde 2 - Prio 1**: Ziel: <was soll besser werden>. Ansatz: <kurzer technischer Plan/Dateien>. Risiko: <falls liegen gelassen>.
- **Umsetzungsrunde 2 - Prio 2**: Ziel: <was soll besser werden>. Ansatz: <kurzer technischer Plan/Dateien>. Risiko: <falls liegen gelassen>.
```

#### 5.2) No-Redundancy-Regel (verbindlich)
- Dieselbe Information darf hoechstens an **einem** Ort voll ausformuliert werden:
  - entweder im Plan-File
  - oder im Chat
  - nicht in beidem
- Wenn Findings im Plan-File persistiert wurden:
  - im Chat nur Kurzfassung je Finding: Titel + Impact + Abhilfe in einer Zeile
  - keine zweite Langfassung
  - immer Verweis auf Datei + Section
### 6) Follow-up Lane
**Pflicht bei Review-Runde-1-Prio-1/2-Findings:** Wenn mindestens ein Finding mit `Review-Runde 1 - Prio 1` oder `Review-Runde 1 - Prio 2` existiert, müssen die Findings zwingend ins Plan-File persistiert werden — kein Ermessen, kein Optional. Erst danach darf der Skill abgeschlossen werden.

**Default bei Review-Runde-1-Prio-3-only:** Wenn ausschließlich Findings mit `Review-Runde 1 - Prio 3` vorliegen, wird standardmaessig **nicht** persistiert. Persistenz erfolgt nur bei explizitem Nutzerwunsch.

**Keine Findings:** Keine Persistenz, keine Plan-Aenderung. Der Review bleibt in diesem Fall reiner Chat-Output.

Nutze als Übergabe standardmäßig **Variante B** (Persistenz im TODO-Implementierungsplan):
- **Ziel:** Findings aus `$private-code-review` werden nur dann in das passende TODO-Plan-Dokument geschrieben, wenn daraus tatsaechliche umsetzbare Folgearbeit entsteht, sodass `$private-create-checklist` sie zuverlaessig "einsammelt".
- **Ablageort:** `docs/planning/implementation/todo-specific-plans/TODO-<id>-*.md` (das zu diesem Branch/Task passende File).
- **Form:** Füge (append) eine Sektion `## Code Review Findings (YYYY-MM-DD)` hinzu und liste dort die Findings stabil referenzierbar (z. B. `F1`, `F2`, ...).
- **Persistierungs-Sprache:** In Plan-Dateien die Umsetzungsrunden-Sicht verwenden, sofern die aktuelle Umsetzungsrunde erkennbar ist — z. B. `F1 (Umsetzungsrunde 3, Prio 2)` statt `F1 (Review-Runde 1 - Prio 2)`. Ist keine Umsetzungsrunde etabliert, `Review-Runde 1 - Prio x` als Fallback verwenden.
- **Nicht persistieren als Findings:** Reine Beobachtungen, Ideen, moegliche Refactors, Stil-/Strukturwuensche oder andere Punkte ohne konkreten Defekt-/Regressionscharakter werden nicht als Findings ins Plan-File geschrieben. Sie bleiben im Chat oder kommen nur bei explizitem Nutzerwunsch in `Runde 2+ Punkte`.
- **Deferred Punkte:** Wenn der Nutzer einen Punkt explizit in eine spätere Umsetzungsrunde verschiebt, nicht als Finding persistieren, sondern als eigene Sektion anhängen:
  - `## Runde 2+ Punkte (YYYY-MM-DD)` (oder spezifischer: `## Umsetzungsrunde <n> Punkte (YYYY-MM-DD)`)
  - Punkte mit genug Detail und Umsetzungsrunden-Kennzeichnung, damit eine spätere Runde sie ohne erneuten Kontextverlust angehen kann.
- **Plan statt Extra-Review-Datei:** Standard ist ein einziger Transportkanal übers TODO-Plan-`*.md` (Findings + deferred Punkte). Ein separates Review-`*.md` nur bei explizitem Nutzerwunsch oder wenn kein eindeutiges TODO-Plan-File existiert.
- **Transparenzpflicht:** Wenn du Findings in ein Plan-`*.md` geschrieben hast, gib im Review-Output explizit aus:
  - den Dateinamen **relativ zum Projekt-Root** (z. B. `docs/planning/implementation/todo-specific-plans/TODO-137-....md`)
  - den exakten Section-Titel (z. B. `## Code Review Findings (2026-01-17)`)
- **Kurzoutput-Regel:** Nach Persistenz im Plan-File keine erneute Vollwiedergabe aller Finding-Details im Chat; nur knappe Summary + Verweis auf Datei/Section.
- **Keine eindeutige Zuordnung:** Wenn kein eindeutiges `TODO-<id>` ableitbar ist (oder mehrere Plan-Files matchen), **kein Guessing**: Findings nur im Review-Output lassen und den Nutzer kurz um das Ziel-Plan-File bitten.
- **Regeln:** Nur `*.md` schreiben/ändern; keine Deletes ohne Rückfrage (siehe Workflow-Regeln).

## Script

### `scripts/branch_review.sh`
Erzeugt eine schnelle, standardisierte Zusammenfassung der Änderungen zwischen aktuellem Branch und Basis-Branch.
Der Aufruf erfolgt über den Script-Pfad im Skill-Verzeichnis (nicht über `./scripts` im Ziel-Repo, falls dort keine Datei liegt).

### `scripts/review_risk_files.sh`
Gruppiert `git diff --name-only <base>...HEAD` oder eine Stdin-Dateiliste in feste Risiko-Buckets.
Nutze das Script vor gezielten Datei-Diffs, um die Dateiauswahl im Lean-Mode knapp und reproduzierbar zu halten.

### `scripts/extract_md_sections.sh`
Extrahiert Frontmatter und gezielt benannte Markdown-Sections aus einer Datei.
Nutze das Script fuer TODO-/Plan-Dateien, damit standardmaessig nur die benoetigten Sections in den Kontext gelangen.

### `scripts/test_summary.sh`
Extrahiert aus einem Test-Log nur Exit-Code und die erste passende Summary-Zeile.
Nutze das Script fuer `dotnet test`-Runs, damit gruenen Testlaeufen kein Voll-Log in den Review-Kontext gezogen wird.

## Abschluss

**Skill Activation:** `[🔍 CodeReview Active]` muss am Anfang jeder Antwort stehen solange der Skill aktiv ist.

Empfohlener nächster Schritt je nach Ergebnis:

| Ergebnis | Empfehlung |
|---|---|
| Review-Runde-1-Prio-1/2-Findings vorhanden | Findings sind ins Plan-File persistiert (Pflicht). Empfehlung: `$private-create-checklist` für neue Umsetzungsrunde (Plan → Review → Execute) |
| Nur Review-Runde-1-Prio-3-Findings | Default ohne Persistenz; User entscheidet: quick inline fix, optionale Persistenz oder `$private-workflow-close-todo` |
| Keine Findings | Empfehlung: `$private-workflow-close-todo` |

Kein automatisches Routing — nur Empfehlung ausgeben und auf User-Entscheidung warten.

## Notes
- Wenn `master` lokal veraltet ist (kein `git fetch`), erwähne das im Report.
- Builds/Tests: Codex CLI/Sandbox-Runs sind ok; Host-Runs sind optional und primär bei Abweichungen als Gegencheck gedacht (siehe `docs/handsoff.md` / AGENTS.md).
