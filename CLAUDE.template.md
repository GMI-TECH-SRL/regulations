# <Project name> — AI entry point

Copy to the repo root as `CLAUDE.md`. Fill every `<…>`. Keep it under 40 lines: this loads on every session.
Also works as `AGENTS.md` (Codex) or `.cursorrules` (Cursor) — symlink it, do not copy it twice.

---

# <Project name>

Stack: <language / framework> · <backend> · <state or key lib>

## Always read first
- `regulations/rules.md` — permanent rules. Non-negotiable.
- `regulations/process.md` §"Session protocol" — the 5 steps every task follows.

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

## Before you touch these, ask
<Files or areas where a wrong change is expensive: auth, migrations, payment, the schema.>
