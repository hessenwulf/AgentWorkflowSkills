---
name: private-workflow-close-todo
description: "Use when closing TODO items in a repository with a TODO-board workflow, including status move, plan archiving, link updates, and completed-list hygiene."
---

# Workflow Close TODO

## Ziel
TODO-Karten im konfigurierten Board-Dokument regelkonform abschliessen und Plan-Dateien sauber archivieren.

## Workflow-Profil (zuerst laden)
- Wenn vorhanden, `./.agents/workflow-profile.yaml` aus dem Repo-Root lesen.
- Verwende daraus die Pfade/Regeln (Board-Datei, Plan-Ordner, Archiv-Ordner, Completed-Limit, Basis-Branch).
- Falls keine Profil-Datei vorhanden ist, gelten die Default-Pfade aus diesem Skill als Fallback.

## Ablauf

0. **Preflight (Bevor du „Completed“ schreibst)**
   - Prüfen, ob die Arbeit wirklich abgeschlossen ist (Code gemerged oder Branch/Commit als Referenz akzeptiert).
   - Im zugehörigen Plan muss `## Validation (YYYY-MM-DD)` mit Commands + Ergebnis ausgefüllt sein (mindestens Build/Tests gemäß Plan); wenn nicht, erst validieren und dokumentieren.
   - **Final-Review-Gate:** Ein TODO darf erst geschlossen und der Plan erst archiviert werden, wenn nach den letzten Non-MD-Implementierungsänderungen ein frischer `$private-code-review` gelaufen ist und keine blockierenden Findings mehr offen sind. Bei P1/P2-Findings oder unklarer Review-Frische sofort stoppen, das TODO aktiv lassen bzw. Reopen empfehlen und mit `private-create-checklist`/`private-executing-plans` fortfahren. Wenn der Nutzer nur "fertig", "abschließen" oder ähnlich sagt, aber kein finaler Review ohne blockierende Findings nachweisbar ist, nicht archivieren.

0.1 **Git-Hygiene (optional, aber oft sinnvoll)**
   - Wenn du in einem `git worktree` arbeitest: `git status` prüfen und Änderungen in 1..n sinnvollen Paketen committen (z. B. Code/Tests getrennt von Docs/TODO-Abschluss).
   - Optional explizit anbieten: Ich packe die Änderungen in reviewbare Commits (z. B. via `git add -p`) und merge den Branch nach `master` gemäß `docs/git-workflow.md` (Rebase → FF merge).

0.2 **Git-Schreibzugriffe strikt seriell**
   - Alle Git-Schreiboperationen laufen in diesem Workflow **strikt seriell**. Niemals `git mv`, `git add`, `git commit`, `git rebase`, `git merge` oder `git switch` parallel zu einem weiteren Git-Schreibzugriff starten.
   - Git-Lesekommandos duerfen parallel zu Markdown-Reads laufen; Git-Schreibkommandos nicht.
   - Vor Archivierung/Merge erst alle Pfade und Textaenderungen planen, dann Git-Schritte einzeln ausfuehren und jeweils auf erfolgreichen Abschluss warten, bevor der naechste beginnt.
   - `git mv`-Schritte nie in `multi_tool_use.parallel` bündeln.
   - Wenn `.git/index.lock` auftritt: keine weiteren Git-Kommandos starten. Kurz pruefen, ob noch ein eigener Git-Prozess laeuft; wenn ja, warten und den blockierten Schritt genau einmal erneut versuchen. Bleibt der Lock bestehen, Workflow stoppen und den Nutzer informieren statt weiterzuschreiben.

1. **Regeln lesen**
   - Konfiguriertes TODO-Board (Default: `docs/TODO.md`) section-basiert lesen: Frontmatter, `## In Progress`, `## Ready`, `## Completed` bis zum naechsten Heading. Backlog und lange Historie nicht laden, ausser die TODO-Karte wird dort vermutet.
   - `docs/handsoff.md` lesen, falls Guardrail-Dokumente betroffen sind.
   - Hinweis: Falls im Repo zusätzlich ein `Docs/`-Mirror existiert (Case-/Sync-Thema): **kanonisch ist `docs/`**; nach Änderungen kurz prüfen, ob `Docs/` automatisch mitzieht oder separat angepasst werden muss.

2. **Abschlussdaten ermitteln**
   - Tagesaktuelles Datum ermitteln: `date +%Y-%m-%d` (Codex CLI ist ok; Host nur bei Abweichungen als Gegencheck). Falls Host/Codex CLI abweichen: Abweichung im Plan unter Validation notieren.

3. **TODO-Karte abschliessen (Completed oder Veraltet)**
   - Standardfall: TODO-Eintrag aus `## In Progress` oder `## Ready` nach `## Completed` verschieben.
   - Abbruch/Out-of-scope: TODO nach `## Veraltet` verschieben und Status als *(YYYY-MM-DD, Veraltet)* setzen (Plan trotzdem archivieren; kurzer Grundsatzsatz in Statuszeile).
   - Statuszeile auf aktuelles Datum setzen und kurzen Abschluss-Hinweis ergänzen.
   - Beispiel-Format:
     - `Status: *(YYYY-MM-DD, Completed)* — Owner: <Team>; <kurzer Abschluss-Text>`
   - Wenn das TODO-Board verändert wurde: YAML-Frontmatter `date:` auf das aktuelle Datum setzen (kein älteres Template-Datum stehen lassen).

4. **Plan archivieren**
   - Plan-Datei vom konfigurierten Implementierungsplan-Ordner (Default: `docs/planning/implementation/todo-specific-plans/`) in den konfigurierten Archiv-Ordner (Default: `docs/planning/implementation/archive/`) verschieben (**mit genau einem seriellen `git mv`**).
   - Link im TODO-Eintrag auf den neuen Archivpfad umstellen.
   - Falls ein separater Design-Link (oder „Implementation Plan“) existiert, unverändert lassen (nur Plan-Archivpfad anpassen). Design-Docs liegen unter `docs/planning/design/todo-specific/` oder `docs/planning/design/general/` (Archiv: `docs/planning/design/archive/`).
   - Danach repo-weit Verweise aktualisieren:
     - Tokenarm zuerst nur Dateiliste ermitteln: `rg -l "TODO-<id>|todo-specific-plans/TODO-<id>" docs`.
     - Nur Trefferdateien oeffnen/aendern; keine breiten `rg -n`-Kontextlisten oder Voll-Reads von `docs/` erzeugen.
     - Wenn keine Treffer ausser den erwarteten Board-/Plan-Dateien vorliegen, nicht weiter suchen.

5. **Completed-Regel pruefen**
   - In diesem Workflow ist das Completed-Limit oft bereits erreicht. Wenn `## Completed` vor dem Abschluss schon am Limit ist (Default: 10), die Auslagerung des aeltesten Completed-Eintrags **direkt als Standardpfad** einplanen: neuer Completed-Eintrag hinein, aeltester Completed-Eintrag nach `docs/TODO-archive.md` hinaus.
   - Completed-Anzahl tokenarm pruefen: nur `- **TODO-` Eintraege innerhalb `## Completed` bis zum naechsten `## ` zaehlen; keine Backlog-/Archivhistorie lesen.
   - Wenn `## Completed` mehr als das konfigurierte Limit hat:
     - Aeltesten Eintrag in die konfigurierte Archive-Board-Datei verschieben (Default: `docs/TODO-archive.md`; Beschreibung/Links beibehalten).
     - `docs/TODO-archive.md` nur frontmatter-/insertionsstellenbasiert lesen und schreiben; die lange Archivhistorie nicht vollstaendig laden.
     - Falls die zugehörige Plan-Datei noch nicht unter `docs/planning/implementation/archive/` liegt: ebenfalls dorthin verschieben (**mit genau einem seriellen `git mv`**) und Links anpassen. Wenn der Plan-Link bereits auf `archive/` zeigt, keinen weiteren Plan-Move machen.
     - In der Archive-Board-Datei die gleiche Statuszeile und den archivierten Plan-Link verwenden.
     - Wenn die Archive-Board-Datei verändert wurde: YAML-Frontmatter `date:` auf das aktuelle Datum setzen.

6. **Plan-Status nachziehen**
   - Im Plan `## Status` auf *(YYYY-MM-DD, Completed)* setzen und einen kurzen Abschluss-Satz ergänzen.
   - Checkliste im Plan aktualisieren (mindestens die erledigten Punkte abhaken; nicht „alles grün“ behaupten).
   - `## Validation (YYYY-MM-DD)` ausfüllen (Command + Ergebnis); Host-Checks nur wenn nötig/abweichend.

7. **Sanity Checks**
   - TODO-Board: Completed hat das konfigurierte Limit (Default: 10); Marker `<!-- BEGIN_* -->`/`<!-- END_* -->` unverändert.
   - Kein Link zeigt mehr auf `todo-specific-plans/TODO-<id>...` für das abgeschlossene TODO.

8. **Git Abschluss (immer am Ende, interaktiv)**
   - Status prüfen: `git status --porcelain=v1`
   - Auch hier gilt: Jeder Git-Schreibschritt einzeln und ohne Parallelisierung. Kein stage/commit/merge parallel zu anderen Git-Schreibkommandos.
   - **Wenn der Worktree dirty ist:** *immer* fragen, ob der Rest noch committed werden soll.
     - Wenn **nein**: hier stoppen (TODO ist zwar dokumentiert, aber Git-Hygiene bleibt beim Maintainer).
     - Wenn **ja**: Änderungen sinnvoll in 1..n Paketen committen (nicht “alles in einen Dump”).
       - Empfehlung für Pakete:
         1) Code/Behavior
         2) Tests/Snapshots
         3) Docs/TODO-Board/Plan-Status
       - Vorgehen:
         - Paketweise stage’n (bevorzugt): `git add -p` (oder gezielt per Pfad)
         - Committen: `git commit -m "<kurzer sinnvoller Titel>"`
         - Wiederholen bis `git status --porcelain=v1` leer ist.
  - **Wenn der Worktree sauber ist:** fragen, ob in den konfigurierten Basis-Branch gemerged werden soll (Workflow-Profil, sonst `master`).
    - Vorher Branch prüfen: `git branch --show-current`
    - Wenn bereits auf dem Basis-Branch: kein Merge nötig (optional: push bleibt Maintainer-Sache).
    - Wenn Feature-Branch:
       - Merge nur nach explizitem “ja” durchführen und Workflow aus `docs/git-workflow.md` befolgen (Rebase → FF merge).
       - Minimaler Ablauf (FF, tokenarm):
         - `git fetch --quiet` (falls erlaubt/gewünscht)
         - `git rebase <base-branch>`
         - `git switch <base-branch>`
         - `git merge --ff-only --quiet <feature-branch>`
         - `git switch <feature-branch>` (optional zurück)
       - Ausgabe bewusst klein halten:
         - Kein `git log`/kein großer `git diff --stat` im Standardpfad.
         - Nach Merge nur Kurzsignale ausgeben: `git rev-parse --short HEAD`, `git status --porcelain=v1`.
         - Nur bei Fehlern/Abweichungen auf detaillierte Ausgabe eskalieren.

## Guardrails
- Marker `<!-- BEGIN_*_SECTION -->` / `<!-- END_*_SECTION -->` nie entfernen.
- Spalten (`In Progress`, `Ready`, `Completed`, `Backlog`) nicht umbenennen oder neu anlegen.
- Datumsangaben nur mit tagesaktuellem Datum (`date +%Y-%m-%d`); Host-Gegencheck nur bei Abweichungen nötig.

## Ergebnis
- TODO ist im Completed-Abschnitt korrekt dokumentiert.
- Plan-Datei ist archiviert und Links stimmen.
- Completed-Liste ist auf das konfigurierte Limit begrenzt (Default: 10).

## Mini-Beispiel (Pfad + Status)

**TODO-Eintrag (Completed):**
- **TODO-105 – Domain-Caching konsolidieren (IMemoryCache vs. CacheEvaluator)**
  - Status: *(2025-12-22, Completed)* — Owner: Domain Services & PerformanceAnalysis; PivotPointsCacheKey eingefuehrt, API/Docs aktualisiert.
  - Plan: [TODO-105-domain-caching-strategy-unification.md](planning/implementation/archive/TODO-105-domain-caching-strategy-unification.md)

**Plan verschieben:**
- Quelle: `docs/planning/implementation/todo-specific-plans/TODO-105-domain-caching-strategy-unification.md`
- Ziel: `docs/planning/implementation/archive/TODO-105-domain-caching-strategy-unification.md`
