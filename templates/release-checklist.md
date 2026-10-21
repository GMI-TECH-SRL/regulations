# Release checklist — <product> <vX.Y.Z>

Gate of phase 7 (`process.md`). Every box ticked, or the item is in `debt.md` with an owner and accepted by both devs.

Date: <YYYY-MM-DD> · Checked by: <name> · Tag: <vX.Y.Z>

## Build & tests
- [ ] CI green on the exact commit being tagged
- [ ] Release built from the semver tag by its own target, not by hand
- [ ] Slow suites (load, soak, long integration) run against this build

## Security
- [ ] Code touching auth / crypto / PII / payments reviewed by a human (rule 6)
- [ ] Dependency audit clean, or every open finding in `debt.md`
- [ ] No secrets in repo or logs; production secrets differ from dev/staging

## Performance
- [ ] Benchmark run against the spec's targets, numbers recorded: <link>

## Operations
- [ ] Runbook written: deploy, rollback, where logs are, who is called
- [ ] Rollback rehearsed: previous tag redeployed successfully
- [ ] Backup restored at least once into a non-prod environment
- [ ] Health check / monitoring in place and alerting a person
- [ ] Maintenance checklist: recurring tasks, owner, frequency

## Debt
- [ ] `debt.md` reviewed: nothing open that this release makes worse
