---
title: "Code Review Checklist"
date: "2026-01-03"
description: "Kurzcheckliste für Reviews zwischen aktuellem Branch und master/main."
tags: ["code-review", "checklist", "workflow"]
category: "Documentation"
---

# Code Review Checklist

Kurzcheckliste fuer Reviews zwischen aktuellem Branch und `master`/`main`:

- Guardrails: `docs/handsoff.md` lesen; bei Änderungen an Guardrail-Dateien explizit markieren.
- Constructors: Dependencies via `Ardalis.GuardClauses` absichern (`Guard.Against.Null(...)`).
- Logging: keine `Console.WriteLine`; strukturiert mit `ILogger<T>`/`ILoggerFactory`.
- Tests: betroffene Bereiche mit Tests absichern; bei Snapshot-Änderungen Baselines nur explizit updaten.
- Cross-project: Änderungen in Kern-/Domain-Modulen auf Auswirkungen in App/API/UI/Jobs prüfen.
