<!-- 中文说明：健康检查规则。WATCHDOG 只检查，不能验收 / 实现 / 测试 / 冻结。 -->

# AI-COLLAB Watchdog

> **状态：可选参考（v1.1 降级）** | WATCHDOG 为人工触发的检查参考，非自动监控。检查项供 AI IDE 或人类在需要时参考执行。

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
| 15 | actor 认领的 stage 上游未到 `gate_state` | `DeclareConflict` |
| 16 | 同 stage 同角色 2 个 active claim（stage_scope 冲突） | `DeclareConflict` |
| 17 | plan 正文写入 `PROJECTS/{project_id}/` 控制面 | `PlanLocationViolation` + 移动到 workspace |
| 18 | actor 按 plan 推进但 plan 状态非 `Active` | `Blocked` |
| 19 | `AcceptStage` 时 `qa_gate=required` 但无 QA Pass 信封 | `DeclareConflict` |
| 20 | `risk_level=High` 且 `consultant_gate=required` 但无 CONSULTANT 签字 | `DeclareConflict` |

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
