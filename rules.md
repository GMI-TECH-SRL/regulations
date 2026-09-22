# Rules — permanent

Applies to every code session. Language-agnostic: concrete commands and stack live in the repo's `CLAUDE.md`.

**Why this file is short:** generation is free, understanding is not. Every line you write is read once in human review and again by every future AI session. Optimize for the reader, not the writer.

## The 13

| # | Rule |
|---|------|
| 1 | **Spec before code.** No task without a written requirement + measurable acceptance criteria. "Refactor this" / "fix this up" are not tasks. |
| 2 | **Done = evidence.** A task is done only when tests, lint and typecheck pass. Paste the terminal output. Self-certifying without logs is forbidden. |
| 3 | **Small increments.** 1 task = 1 reviewable diff (~200-300 changed lines). No monoliths in one shot. |
| 4 | **AI proposes, human decides.** Architecture, libraries, data model, breaking changes → present ≥2 options with trade-offs, wait for a human call, record it in an ADR. |
| 5 | **The test is a requirement.** A feature without an automated test is an unfinished feature. |
| 6 | **Security & secrets.** Never put secrets in the repo or in logs. Code touching auth, crypto, PII or payments needs explicit human review, flagged in the PR. |
| 7 | **Boring tech, YAGNI.** No libraries or abstractions "for the future". Reuse patterns and modules already in the codebase. |
| 8 | **Reversible git, trunk-based.** Atomic descriptive commits. Branches live <24-48h. No force-push on shared branches. Semver + tag on every release. |
| 9 | **Context stays current.** Any change to conventions, APIs or config updates the matching docs in the same PR. |
| 10 | **Debt is visible.** Risks, temporary shortcuts and technical debt go into `debt.md` immediately. Never in memory, never as a `// TODO`. |
| 11 | **Scope isolation.** Touch only the files the spec names or strictly requires. No reformatting, renaming or "improving" adjacent files. No drive-by refactoring. |
| 12 | **No surprise dependencies.** Never install or add an external package (npm, pip, pub, cargo, …) without explicit human approval. |
| 13 | **Deterministic bug hunting.** Before fixing a bug, write an automated test that fails and reproduces it. The fix is approvable only when that test goes green with no regressions. |

## Code style

- **Boring > clever.** A smart one-liner packing 3-4 logical operations gets split into explicit steps.
- **Complexity limits.** 1 function = 1 responsibility, ≤ ~50 lines, nesting depth ≤ 3. Early return (guard clauses) over deep `if/else`.
- **One operation per line.** No fluent chains of 4+ calls, except standard readable idioms of the language (`.map().filter()`).
- **No black magic.** No regex for complex parsing, no opaque metaprogramming, no reflection, no abstractions or generics introduced only to save lines.
- **No magic constants.** Name them, explicitly.
- **Objective review bar.** If an outside developer needs more than 10 seconds to follow the flow of a block, rewrite it simpler.

## Bug fixing

Before editing, grep every caller of the function you touch. One guard in the shared function is both the smaller diff and the real fix — patching only the path named in the ticket leaves every sibling caller broken.

## Git

- Trunk-based: short-lived branches merged into `main` frequently. Long branches from concurrent AI sessions produce logical conflicts no merge tool can resolve.
- One commit = one logical change, message says *why*.
- Never force-push a shared branch. Never rewrite `main`.

## Commands

Never invent terminal flags. Every repo exposes one unified check target (`make check`, `npm run check`, …) declared in its `CLAUDE.md`. Run that. If it does not exist, say so — do not improvise a command sequence.
