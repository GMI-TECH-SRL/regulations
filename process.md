# Process

Two separate things: **company phases** (humans, per product) and **the session protocol** (AI, per task). Read the part that applies to you.

---

## Part 1 — Company phases (human governance)

One product moves through these. Each gate is a yes/no question or a command that must pass. No gate, no next phase.

| # | Phase | Output | Gate (yes/no) |
|---|-------|--------|---------------|
| 0 | **Validation** | ≥5 interviews with potential customers: real problem, what they spend today, willingness to pay | ≥3 written confirmations of intent to use or buy |
| 1 | **Planning** | `spec.md` filled: goals, target users, scope, non-scope, metrics, risks | Spec signed off by 1 dev + 1 sales |
| 2 | **Budgeting** | Hour estimate (raw × 1.5-2.0 to absorb the review bottleneck), cloud cost, third-party API cost | Budget approved; re-reviewed at every phase change |
| 3 | **GTM** | Positioning, acquisition channel, pricing, launch plan (owned by sales; AI only supports analysis) | GTM plan approved |
| 4 | **Fundamentals** | Clean repo, blocking CI (test + lint + typecheck before merge), conventions, ADR #0 (stack), dev/staging/prod | CI green on `main` AND an automated deploy has run successfully |
| 5 | **First release (MVP)** | Minimum shippable core driven by the spec's success metrics | Deployed to prod AND N real users active |
| 6 | **Iteration** | Feedback, analytics, reprioritization → back to phase 1 with a mini-spec, or on to 7 | Target metric improving, or a documented pivot |
| 7 | **Finishing & stability** | Security hardening, perf benchmark, runbook, maintenance checklist | `release-checklist.md` fully ticked + operations plan signed |

### Metrics — only two

Track nothing else. Both come from git and the incident log, zero extra tooling.

| Metric | Definition | Read it from |
|---|---|---|
| **Lead time for changes** | First commit on the branch → PR merged | Git timestamps |
| **MTTR** | Production breakage detected → rollback or hotfix live | Incident note in `debt.md` |

### Change management

| Action | Who approves |
|---|---|
| Merge to `main` | 1 dev |
| Production deploy | 1 dev |
| Spending / infrastructure | 1 dev + 1 sales |
| Data deletion / schema drop | **both devs** |

### Rollback runbook

Production is broken. Three steps, in this order. Do not debug live.

1. **Revert the commit** — `git revert <sha>` on `main`.
2. **Deploy the last stable tag.**
3. **Postmortem** — what broke, why the tests missed it, what check gets added. Written within 24h, into `debt.md`.

---

## Part 2 — Session protocol (AI, per task)

Every code task follows these five steps in order. Do not skip. Do not reorder.

### 1. Context & verification
Read the spec. Identify which files are involved. Check how the repo already solves this — an existing pattern beats a new one. Report what you found before writing anything.

### 2. Plan & gate
- Task touches **architecture, dependencies or the data model** → present 2 options with pros/cons and **stop**. Wait for a human decision. Record it in an ADR.
- Otherwise → state a 3-5 point plan of what you will change, then proceed.

### 3. Atomic execution
Edit only the target files. Respect the style rules. No drive-by refactoring (rule 11). If you find debt outside scope, note it — do not fix it.

### 4. Evidence gathering
Run the repo's unified check target. Capture the terminal output verbatim. Failing output gets reported, not hidden and not worked around.

### 5. PR handover
Fill `templates/pr.md`: what changed, which files, test evidence, residual risk.
