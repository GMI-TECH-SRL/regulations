# <Project name> — AI entry point

Copy to the repo root as `CLAUDE.md`. Fill every `<…>`. Keep it under 40 lines: this loads on every session.
Also works as `AGENTS.md` (Codex) or `.cursorrules` (Cursor) — symlink it, do not copy it twice.
The `@regulations/…` lines are Claude Code imports: keep them outside backticks or they do not load. Other agents ignore `@`, so the same lines also tell them to read the files.

---

# <Project name>

Stack: <language / framework> · <backend> · <state or key lib>

## Always read first
- @regulations/rules.md — permanent rules. Non-negotiable.
- @regulations/process.md — follow Part 2 "Session protocol", the 5 steps every task follows.
- On design, test or requirement decisions, also read `regulations/principles.md` (not imported: too long for every session).

## Commands — use these, do not invent flags
| Purpose | Command |
|---|---|
| **Full check (run before every handover)** | `<make check / npm run check / …>` |
| Tests | `<…>` |
| Lint | `<…>` |
| Typecheck / analyze | `<…>` |
| Run locally | `<…>` |

## Where things live
| What | Where |
|---|---|
| <Entry point> | `<path>` |
| <Business logic> | `<path>` |
| <Data access> | `<path>` |
| <Tests> | `<path>` |
| <Project-specific docs> | `<path>` |

## Project conventions
<5-10 lines maximum. Only what is TRUE HERE and not in rules.md: naming, layering, the one weird thing about this repo, the trap a new session falls into.>

Approved MCP servers / plugins: <none | list>

## Before you touch these, ask
<Files or areas where a wrong change is expensive: auth, migrations, payment, the schema.>
