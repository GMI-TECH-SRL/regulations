# Spec — <feature / product name>

Status: draft | approved · Approved by: <dev> + <sales> · Date: <YYYY-MM-DD>

## Problem
<What breaks for the user today. One paragraph. Not the solution.>

## Target users
<Who. Be specific enough to name a real person we interviewed.>

## Scope
- <Thing we build>
- <Thing we build>

## Non-scope
- <Thing we explicitly do NOT build, and why not now>
- <…>

Anything not listed under Scope is out of scope. Do not infer.

## Acceptance criteria
Each one must be checkable by a human or a command. No "works well", no "is fast".
Each one starts with a unique ID `AC-<feature>-<slug>` (lowercase, kebab). The test that proves it names the ID in its title or a comment.
Tick a box only when that test exists and passes: `scripts/trace.sh` fails otherwise.

- [ ] `AC-<feature>-<slug>` <Given X, when Y, then Z>
- [ ] `AC-<feature>-<slug>` <…>

## Success metrics
| Metric | Today | Target | Measured how |
|---|---|---|---|
| <…> | <…> | <…> | <…> |

## Risks
| Risk | Impact | Mitigation |
|---|---|---|
| <…> | low/med/high | <…> |
