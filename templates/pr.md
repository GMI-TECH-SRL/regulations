# <type>: <what changed>

Spec: <link or path> · ADR: <link, if a structural decision was made>

## What changed
- <…>

## Files touched
| File | Why |
|---|---|
| <path> | <…> |

Files outside this list were not modified.

## Evidence
Paste real terminal output. A PR without output is not reviewable.

| Check | Command | Result |
|---|---|---|
| Tests | `<…>` | <pass/fail + counts> |
| Lint | `<…>` | <…> |
| Typecheck | `<…>` | <…> |

```
<paste the output here>
```

## Residual risk
- <What could still break, what is untested, what was assumed.>
- <"None" is a valid answer only if you actually looked.>

## Human review required
- [ ] Touches auth / crypto / PII / payments (rule 6)
- [ ] Adds a dependency (rule 12)
- [ ] Changes the data model or a public API (rule 4)
