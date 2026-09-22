# AI-COLLAB Recommended Patterns

> Version: 1.0 | Date: 2026-07-30 | Status: Recommended convention (non-mandatory)
> Added in v1.5 (seven-step arbitration; vacuum-period decision pending community review)
> The "home" for downgraded rules — downgraded rules are moved here rather than deleted. On onboarding, actors confirm they have read this file and load patterns on demand.

---

## 1. What this is

`PATTERNS.md` is the home for recommended patterns. The core invariants (see `PROTOCOL.md` §1.2.1) are the minimum compliance requirements; recommended patterns are practices of the "better to do but not doing so is not a violation" kind.

**Read self-check** (added in v1.5): on onboarding, actors confirm they have read this file and know which recommended patterns may be loaded on demand. Only "has read" is required, not "has used" — preventing the self-check from degrading into "checkbox compliance", while ensuring actors are aware of the recommended patterns.

---

## 2. Pattern catalog

### P-001: Heartbeat frequency convention

**Origin**: Downgraded from the v1.1 HEARTBEAT rule
**Trigger**: `context.includes('long_running_task')`
**Pattern**: For long tasks, a heartbeat every 30 minutes is recommended; for short tasks, write on completion. With no timer, write `PassiveNoTimer` or `BatchComplete`.
**Rationale**: Heartbeat frequency does not affect invariant compliance, but it does affect WATCHDOG liveness detection. Downgraded to a recommended pattern so actors can adjust to actual scenarios.

### P-002: Evidence-strength grading

**Origin**: Downgraded from the v1.1 evidence rule
**Trigger**: `context.includes('evidence_submission')`
**Pattern**: Evidence is recommended to be graded by strength — Runtime > Benchmark > UnitTest > SourceScan. Higher-strength evidence takes precedence.
**Rationale**: Invariant 3 (evidence traceability) only requires "an evidence chain with strength grading". The specific strength ordering is a recommended pattern and may vary by project type.

### P-003: Lease-renewal lead time

**Origin**: Downgraded from the v1.1 CLAIMS rule
**Trigger**: `context.includes('claim_lease')`
**Pattern**: Lease renewal is recommended within the 20% time window before expiry to avoid boundary conflicts.
**Rationale**: Invariant 1 (control-plane purity) requires going through HANDOFF, but does not specify renewal timing. Renewal lead time is an efficiency optimization, not a compliance requirement.

---

## 3. Downgrade process

Old rules downgraded here MUST pass three gates (see `PROTOCOL.md` §1.2.1):
1. **Announcement period**: marked deprecated for one version cycle (default 3 months)
2. **Data proof**: violation detection never fired, or is derivable from invariants
3. **Regression verification**: state-machine monotonicity, re-scan historical cases

Format of a downgraded pattern:
```
### P-{number}: {pattern name}
**Origin**: Downgraded from {version} {rule}
**Trigger**: {atomic predicate}
**Pattern**: {recommended practice}
**Rationale**: {why downgraded}
```
