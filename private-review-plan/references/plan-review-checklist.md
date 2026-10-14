---
title: "Plan Review Checklist"
date: "2026-01-03"
description: "Checklist for reviewing implementation plans for clarity, scope, testing, and risks."
tags: ["plan-review", "checklist"]
category: "Documentation"
---

# Plan Review Checklist

## Scope and Intent
- Is the goal clear and unambiguous?
- Are non-goals stated to prevent scope creep?
- Are success criteria or acceptance signals defined?
- Are constraints (time, risk, compatibility) explicit?

## Interfaces and Dependencies
- Are API or interface changes listed with all call sites?
- Are cross-project ripple effects identified?
- Are data format/schema changes covered?

## Data and Determinism
- Are data sources and fixtures specified?
- Any reliance on current date/time or external state?
- Is caching/consistency behavior documented?

## Testing and Validation
- What tests are needed (unit/integration/regression)?
- Are build/test commands listed and feasible?
- Are baseline/snapshot updates defined?

## Risks and Rollback
- What are the failure modes and mitigations?
- Is there a rollback or safe fallback path?
- Any performance or memory risks?

## Overengineering Check
- Is the approach heavier than needed?
- Is there a smaller, safer minimal path?
- Are optional features clearly deferred?

## Documentation
- Are required doc updates identified?
- Are guardrails or workflow docs affected?

## Alternatives
- List 2-3 credible alternatives with trade-offs.
- State why the chosen path is preferred.

## Open Questions
- What decisions are still missing or blocking?

## Decision Persistence
- Were all resolved decisions (`Q*`, `ALT*`, `R*`) written into the plan markdown (not just chat)?
- Does the plan contain a dated `## Plan-Review Entscheidungen (YYYY-MM-DD)` section with clear mappings?
- Is the scope split explicit (`In diesem TODO` vs. `Folge-TODO`) for each relevant decision?
- Was `## Skill Run Log` updated with a `plan-review` entry (date + key decisions)?
- Can a third person understand final decisions from markdown alone, without chat history?
