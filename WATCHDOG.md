<!-- English note: Health-check rules. WATCHDOG only checks; it MUST NOT accept / implement / test / freeze. -->

# AI-COLLAB Watchdog

> **Status: Optional reference (downgraded in v1.1)** | WATCHDOG is a human-triggered review reference, not automated monitoring. Checks are available for AI IDEs or humans to consult as needed.

## Purpose

WATCHDOG is a deterministic review role. It can be performed by any AI IDE or by a human, but it does not implement, test, or accept work. It checks collaboration health.

## Scan Interval

Recommended:

- interactive: every 10 minutes;
- normal: every 30 minutes;
- long-running: every 2 hours;
- manual-only: when a human asks for a sync.

## Checks

1. Active claim expired.
2. Heartbeat stale beyond timer profile.
3. `BLACKBOARD.md` active state conflicts with latest envelope.
4. Envelope status uses a state not defined by `PROTOCOL.md`.
5. High-risk status change lacks `AUDIT/` record.
6. `SubmitImpl` lacks evidence path.
7. `SubmitTestReport` lacks test count or result.
8. `AcceptStage` lacks TEST report.
9. Two active claims overlap in file scope.
10. An actor modified another actor's envelope.
11. Project task is processed without matching `project_id` or actor registration.
12. Blackboard contains full artifact content instead of filename/index/hash.
13. Envelope dependency or sequence order is violated.
14. Blackboard revision was overwritten from stale state.

### Plan-protocol checks (optional, only when project uses plan mode)

| # | Check | Recommended state |
|---|-------|-------------------|
| 15 | Upstream of actor-claimed stage has not reached `gate_state` | `DeclareConflict` |
| 16 | Two active claims for same stage and role (stage_scope conflict) | `DeclareConflict` |
| 17 | Plan body written to `PROJECTS/{project_id}/` control plane | `PlanLocationViolation` + move to workspace |
| 18 | actor advances per plan but plan status is not `Active` | `Blocked` |
| 19 | At `AcceptStage`, `qa_gate=required` but no QA Pass envelope | `DeclareConflict` |
| 20 | `risk_level=High` and `consultant_gate=required` but no CONSULTANT signature | `DeclareConflict` |

### Core invariant checks (added in v1.3 / Direction 2 verification framework)

> Confirmed in v1.5 (seven-step arbitration; vacuum-period decision pending community review). State-machine monotonicity is a verification framework that requires global state and is executed by WATCHDOG post hoc. First-order invariants are self-judged by actors and are not listed here.

| # | Check | Recommended state |
|---|-------|-------------------|
| 21 | **Control-plane purity violation**: control-plane message did not go through HANDOFF (bypassing the bus), or control plane wrote artifact content instead of a pointer | `DeclareConflict` + log to `VIOLATIONS/` |
| 22 | **Permission-isolation violation**: the same actor holds multiple roles among SPEC/IMPL/TEST | `DeclareConflict` + log to `VIOLATIONS/` |
| 23 | **Evidence-traceability violation**: conclusion lacks an evidence chain, or evidence strength is not graded | `DeclareConflict` + log to `VIOLATIONS/` |
| 24 | **State-machine monotonicity violation** (verification framework): operation caused irreversible entropy increase with no rollback mechanism — e.g., stage regression, tampering with an accepted stage, or overwriting blackboard history | `DeclareConflict` + `EscalateToHuman` + log to `VIOLATIONS/` |

**Violation logging**: when checks 21-24 fire, WATCHDOG writes a violation log entry to `VIOLATIONS/` (schema in `SCHEMAS/violation.schema.json`); `detected_by` is recorded as `WATCHDOG`.

## Outputs

WATCHDOG writes one of:

- `PROJECTS/{project_id}/HANDOFF/SYNC_WATCHDOG_{TS}.md` for ordinary status sync.
- `PROJECTS/{project_id}/HANDOFF/{STAGE}_WATCHDOG_TO_ALL_{TS}.md` for conflict or block.
- `AUDIT/{TS}_RecordRisk_WATCHDOG.md` for medium/high risk.

## Status Recommendations

| Finding | Recommended state |
|---|---|
| expired claim, no side effects | `SpecIssued` |
| expired claim, partial side effects | `Blocked` |
| missing evidence | `Conditional` |
| illegal state transition | `DeclareConflict` |
| missing high-risk audit | `Blocked` until audit is written |
| project registration mismatch | `NeedsProjectRegistration` or `EscalateToHuman` |
| ordering violation | `DeclareConflict` |
| artifact stored in blackboard | `RecordDeviation` and move artifact to workspace |
| plan gate violation (check 15) | `DeclareConflict` |
| plan stage_scope conflict (check 16) | `DeclareConflict` |
| plan location violation (check 17) | `PlanLocationViolation` and move artifact to workspace |
| plan not active (check 18) | `Blocked` |
| missing qa gate pass (check 19) | `DeclareConflict` |
| missing consultant sign on high-risk stage (check 20) | `DeclareConflict` |

## Prohibited Behavior

- WATCHDOG should not accept, reject, freeze, implement, or test.
- WATCHDOG should not delete stale files.
- WATCHDOG should not infer a passing result from silence.
- WATCHDOG should not expose secrets from logs or evidence.
