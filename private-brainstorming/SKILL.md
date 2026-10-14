---
name: private-brainstorming
description: "Use when a task needs design exploration before implementation: new features, new flows, unclear behavior changes, or requests with multiple viable approaches. Always use when explicitly invoked; do not auto-use for bug fixes, mechanical refactors, documentation-only work, or implementation-ready tasks."
date: "2026-03-16"
---

# Brainstorming

## Overview

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

**Ausgabesprache:** Deutsch. Fachbegriffe (Review, Scope, Checklist, etc.) bleiben englisch.

Use this skill automatically only when the request appears to need product or design exploration before implementation. Always use it when the user explicitly invokes brainstorming. Do not auto-use it for bug fixes, mechanical refactors, documentation-only work, straightforward edits, or tasks that are already implementation-ready.

Start by understanding the current project context, then ask questions one at a time to refine the idea. Use a recommendation-first decision pattern: explain the decision briefly, present the main alternatives with tradeoffs, state the recommended choice, and phrase the follow-up so a simple `ja` confirms the recommendation. Once you understand what you're building, present the design in small sections (200-300 words), checking after each section whether it looks right so far.

## The Process

**Understanding the idea:**
- Check out the current project state first (files, docs, recent commits)
- Ask questions one at a time to refine the idea
- Default to recommendation-first questions instead of open-ended prompts: explain the decision in plain language, name the alternatives, give the best choice with reasoning, and make `ja` sufficient when the user agrees
- Only one question per message - if a topic needs more exploration, break it into multiple questions
- Emit each decision question exactly once (no duplicate question in separate status/final outputs)
- Focus on understanding: purpose, constraints, success criteria

**Exploring approaches:**
- Propose 2-3 different approaches with trade-offs
- Present options conversationally with your recommendation and reasoning
- Lead with your recommended option and explain why
- End each decision step with a confirmation question phrased so the user can answer with `ja` when they accept the recommendation

**Presenting the design:**
- Once you believe you understand what you're building, present the design
- Break the design into small, digestible sections. Treat 200-300 words as a guideline, and adjust section length based on complexity and user feedback.
- Ask after each section whether it looks right so far
- Cover: architecture, components, data flow, error handling, testing
- Be ready to go back and clarify if something doesn't make sense

**Scope size check:**
- Before persisting the final design, assess whether the validated work still fits one coherent TODO or deliverable.
- Proactively recommend splitting when the design contains multiple independent contract changes, separate owners, different verification surfaces, or parts that can be implemented and reviewed independently.
- When recommending a split, name the proposed TODO boundaries and keep the current TODO focused on the smallest coherent deliverable.
- Ask for confirmation before changing board/design artifacts.

## After the Design

**Documentation:**
- MANDATORY: Before ending the run, persist the validated design to the repo's design/planning documentation area using the project's established structure. If no such structure exists yet, ask where the design should live or propose a sensible default.
- MANDATORY: If persisting is blocked (read-only environment, missing target path, or missing approval), ask for the required path/approval and do not end in chat-only mode.
- MANDATORY: Do not output the final Abschlusssatz until the design file exists on disk and reflects all confirmed decisions from the conversation
- MANDATORY: If the persisted design is a TODO-specific plan (for example `TODO-<id>-*.md`) and the repository has a TODO board, verify that the matching TODO entry links to that file before ending the run. If the board link is missing or stale, update it first.
- MANDATORY: Treat a missing board link for an existing TODO-specific plan as an incomplete persistence step, not as an optional follow-up.
- Optional: Commit the design document only if the user asks for it or the repository workflow explicitly requires it.

## Abschluss

When brainstorming and design work is complete (no open questions/decisions), the design document has been persisted, and you're stopping for this run, end with:

`Planung erledigt — Brainstorming verabschiedet sich für dieses Mal. Gute Nacht.`

## Key Principles

- **One question at a time** - Don't overwhelm with multiple questions
- **One question, one output** - Ask open decisions in a single message; never repeat the same question verbatim in a follow-up unless new context was added
- **Recommendation first** - Default to "decision + alternatives + recommended choice" instead of broad open questions
- **`ja` should usually be enough** - Phrase the confirmation step so agreement with the recommendation can be acknowledged with a simple `ja`
- **YAGNI ruthlessly** - Remove unnecessary features from all designs
- **Explore alternatives** - Always propose 2-3 approaches before settling
- **Incremental validation** - Present design in sections, validate each
- **Check TODO size before persistence** - If the conversation expands the design into independent behavior changes, actively propose a split instead of preserving the original TODO shape.
- **Be flexible** - Go back and clarify when something doesn't make sense
