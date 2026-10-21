# Legal — using AI tools at GMI (EU / Italy)

For humans. Not legal advice: a checklist of known obligations and open questions.
Items marked **verify** come from secondary sources — confirm with counsel before relying on them.
Last reviewed: 2026-10-21.

## 1. AI literacy — EU AI Act, Art. 4

- Applies since 2025-02-02 to every company that **uses** AI systems, coding assistants included. Not delayed by later amendments to the Act (**verify** current wording).
- Minimum evidence, cheap: this repo, read by everyone who uses AI tools, plus a short yearly session.
- Keep a log: `<date> · <person> · <what was covered>`, in the company drive or here.
- Coding assistants are not high-risk systems: no conformity assessment, no risk classification paperwork.

## 2. Personal data — GDPR

- **No personal data in prompts** (`rules.md` "Untrusted input"). Synthetic or anonymized data only.
- Use only business/commercial plans or the API under commercial terms, never personal consumer accounts: different data-use and training terms.
- For each AI provider record: plan, whether inputs are used for training (must be **off**), retention period, DPA signed. **Verify** the current defaults in the provider's settings, they change.
- AI tool reading production data (logs, DB, MCP to prod) = the provider processes that data → it needs the DPA and to be in the records of processing.

## 3. Italian AI law — Legge 132/2025

- In force since 2025-10-10. Responsibility for AI-assisted output stays with the human who uses it: "the AI wrote it" is not a defence.
- Worker information duties concern AI used in decisions about workers (hiring, evaluation), not coding assistants (**verify** if AI is ever used for HR).
- Duty to inform clients about AI use is written for intellectual professions; whether it reaches a software company's deliveries is **open — ask counsel**. If yes: one clause in client contracts.

## 4. Copyright of AI-generated code

- Code produced only by AI, with no meaningful human creative contribution, may not be protected by copyright (US Copyright Office, Jan 2025; Italian law 132/2025 protects works "created with AI assistance" only as the result of the author's intellectual work — **verify**).
- Consequence: an IP assignment to a client is weaker on purely generated code. Mitigation is what `rules.md` already requires: human review, understanding and edits of every change; provenance kept via `Co-Authored-By` in commits.
- Client contracts: don't warrant "all code is original human work". **Ask counsel** for a standard clause.
- Open-source licence contamination: an AI may reproduce licensed code. Large verbatim-looking blocks → check before committing.

## Open questions for counsel

- [ ] Does the client-information duty (§3) apply to our software deliveries?
- [ ] Standard contract clause on AI-assisted development and IP (§4).
- [ ] Confirm current Art. 4 wording and whether our literacy log is sufficient evidence (§1).
