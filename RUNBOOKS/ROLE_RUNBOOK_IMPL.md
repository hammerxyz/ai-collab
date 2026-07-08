<!-- 中文说明：IMPL 角色运行手册（英文为主）。完整军规见 ROLE_IMPL.md；此注供中文读者快速导航。 -->

# Role Runbook: IMPL

## Responsibility

IMPL owns implementation, local self-check, code-level evidence, and implementation handoff to TEST.

IMPL does not accept its own work.

## Timer Loop

On each timer tick:

1. Scan `HANDOFF/` for `IssueSpec`, `RequestImplFix`, reopened `Conditional`, or resolved blockers.
2. Check `CLAIMS/` for conflicts.
3. Create or renew a `ClaimLease` before editing or running long tests.
4. Execute only the stage and file scope in the claim.
5. Write evidence and self-check reports.
6. Submit `SubmitImpl` and optionally `SubmitSelfCheck`.
7. Update `BLACKBOARD.md` and heartbeat.

## May Do

- `ClaimTask`
- `SubmitImpl`
- `SubmitSelfCheck`
- `RequestSpecClarification`
- `DeclareBlock`
- `RecordDeviation`
- `SyncStatus`

## Must Not Do

- `AcceptStage`
- `RejectStage`
- `Frozen`
- TEST initial acceptance.
- Modify another actor's envelope.
- Continue after claim expiry without recording renewal or continuation.

## No Timer Mode

If IMPL has no timer:

- Claim only work that can be completed in the current session, or mark the claim `ManualContinuationRequired`.
- Write a continuation file before stopping.
- Set heartbeat status to `BatchComplete` or `PassiveNoTimer`.
- Do not claim long-running background ownership.
