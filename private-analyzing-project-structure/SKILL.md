---
name: private-analyzing-project-structure
description: Use when asked to understand an existing repository's code structure, entrypoints, major subsystems, intended business or domain logic, current functionality, or how implementation aligns with local docs; not for brainstorming new features or designs
---

# Analyzing Project Structure

## Overview

Use this skill to identify what already exists. Analyze the codebase from local evidence first, then explain structure, execution flow, intended business/domain logic, and current functionality. Explain what is known, what is inferred, and what remains uncertain. Use the web only when the user asks for it or when external, current information is necessary.

## Workflow

1. Start with a short statement that this skill is being used and whether the pass is local-only or may include web research.
2. Read the highest-signal root files first: `AGENTS.md`, `README*`, `docs/`, solution or package manifests, and the main entrypoint files.
3. Build a structure map with fast file discovery tools such as `rg --files`, then inspect only the directories that look architecturally important.
4. Identify:
   - executable entrypoints
   - core libraries or domain modules
   - integration boundaries such as CLI, web, persistence, APIs, jobs
   - business/domain concepts expressed in models, services, rules, calculations, workflows, and terminology
   - user-visible functionality and internal capabilities that are already implemented
   - tests, demos, fixtures, and generated outputs
   - configuration, build, and deployment files
5. Infer intent from code plus docs together, not from folder names alone. Prefer design docs, example scenarios, and main program flow over aspirational concept docs.
6. Separate findings into:
   - facts directly supported by files
   - inferences that connect those facts
   - unknowns or conflicts that need confirmation
7. If web research is needed, use it narrowly:
   - only for external dependencies, standards, current docs, or referenced external systems
   - prefer primary sources
   - keep the repository analysis grounded in local evidence

## Output Shape

Default to a concise report with these sections:

- `Purpose`: what the project appears to do
- `Top-Level Structure`: major directories and their roles
- `Execution Flow`: how the system starts and where key control flow lives
- `Business/Domain Logic`: the main rules, calculations, workflows, and concepts implemented today
- `Implemented Functionality`: what the system currently appears to support
- `Architecture Intent`: the likely design goals, with evidence
- `Docs vs Reality`: where local documentation matches or diverges from code
- `Open Questions`: unresolved areas or risky assumptions

## Heuristics

- Read breadth first, then go deep on the 2-4 areas that drive behavior.
- Treat `Program`, `main`, composition roots, and example/demo paths as high-signal.
- Tests show expected behavior; docs show intended behavior; entrypoints show actual behavior.
- Call out stale docs explicitly rather than silently reconciling them.
- Do not present inferred intent as fact. Label it.

## When Not to Use

- New feature ideation, design exploration, or solution shaping where `private-brainstorming` is the better process skill.
- Narrow bugfixes where `systematic-debugging` is the better process skill.
- Implementation work where the user already provided a clear plan and does not need repo discovery.
