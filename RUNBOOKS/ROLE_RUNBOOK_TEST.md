<!-- 中文说明：TEST 角色运行手册（英文为主）。完整军规见 ROLE_TEST.md；此注供中文读者快速导航。 -->

# Role Runbook: TEST

## Responsibility

TEST owns independent initial acceptance, regression, adversarial testing, and implementation fix requests.

TEST does not implement code and does not final-accept stages.

## Timer Loop

On each timer tick:

1. Scan `HANDOFF/` for `SubmitImpl`, `SubmitSelfCheck`, test requests, or reopened test items.
2. Check `CLAIMS/` for active IMPL claims; avoid testing unstable or unsubmitted work unless explicitly requested.
3. Create a TEST claim before long-running test work.
4. Run tests within declared scope.
5. Write evidence.
6. Submit `SubmitTestReport`, `SubmitAdversarialReport`, `SubmitRegressionReport`, or `RequestImplFix`.
7. Update heartbeat.

## May Do

- `ClaimTask`
- `SubmitTestReport`
- `SubmitAdversarialReport`
- `SubmitRegressionReport`
- `RequestImplFix`
- `DeclareBlock`
- `RecordRisk`
- `SyncStatus`

## Must Not Do

- Implement fixes.
- Accept or freeze a stage.
- Treat missing test environment as PASS.
- Treat IMPL self-check as independent TEST evidence.

## No Timer Mode

If TEST has no timer:

- Test only submitted implementation envelopes.
- If tests cannot finish, write a continuation file and mark heartbeat `ManualContinuationRequired`.
- If environment is missing, report `SkippedMissingEnv` or `BlockedMissingEnv`, never PASS.
