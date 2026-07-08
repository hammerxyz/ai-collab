# 完整周期样例  *(A full-cycle example)*

> 用一个小任务演示 SPEC → IMPL → TEST → Accept 全周期的真实落盘产物。形状都可直接照抄，字段说明见 `TEMPLATES/`。
> *A small task demonstrates the real artifacts of a full SPEC → IMPL → TEST → Accept cycle. The shapes are copy-ready; field details are in `TEMPLATES/`.*

<!-- 中文：新手照着这一节，就能知道每个阶段该往哪个目录丢什么文件。所有信封从 TEMPLATES/ 对应模板复制后填写。 -->
<!-- English: By following this section a newcomer learns what file to drop where at each stage. Every envelope is copied from the matching TEMPLATES/ file then filled in. -->

---

## 场景  *(Scenario)*

给 `example-project`（一个 Python CLI 工具）新增 `health` 子命令，打印项目三项关键健康指标（文件数、测试通过率、最近改动数）。

*Add a `health` subcommand to `example-project` (a Python CLI) that prints three key health metrics (file count, test pass rate, recent change count).*

阶段码统一用 `S1_`，便于在黑板与信封间追踪。

*Stage code `S1_` is used throughout to trace across board and envelopes.*

---

## 1. SPEC 下发任务  *(SPEC issues the task)*

文件：`PROJECTS/example-project/HANDOFF/S1_ISSUE_SPEC_20260708T100000.md`（从 `TEMPLATES/IssueSpec.md` 复制）

```markdown
# Envelope: S1_ISSUE_SPEC_20260708T100000
## Header
- envelope_id: S1_ISSUE_SPEC_20260708T100000
- project_id: example-project
- sequence_no: 1
- depends_on: []
- stage: S1_spec
- from: SPEC
- to: IMPL
- action: IssueSpec
- priority: P1
- risk_level: Low
- created_at: 2026-07-08T10:00:00+08:00
- expires_at: none

## Payload
### Goal
新增 `health` 子命令，打印文件数、测试通过率、最近 7 天改动数。
### Required Reading
- PROJECTS/example-project/PROJECT.md
### Scope
仅新增子命令，不改已有命令行为。
### Acceptance Criteria
1. `cli.py` 含 `health` 子命令且可被 `python -m example_project health` 调用。
2. 输出包含上述三项指标。
3. 新增 `tests/test_health.py` 且 `pytest` 全绿。
4. IMPL 自检通过并附 Runtime 证据。
### Constraints
- 不引入新依赖。
- 不修改其他子命令。
### Output Artifacts
- artifact_policy: WorkspaceOnly
- expected_workspace_outputs:
  - src/example_project/cli.py
  - tests/test_health.py
- blackboard_may_record_only:
  - filename
  - workspace-relative path
  - sha256
  - short summary

## Evidence
- none
## Status
- current: Submitted
- updated_at: 2026-07-08T10:00:00+08:00
- updated_by: SPEC
## Audit
- 2026-07-08T10:00:00+08:00 | SPEC | Created IssueSpec
```

黑板阶段更新为 `SpecIssued`。
*Blackboard stage → `SpecIssued`.*

---

## 2. IMPL 认领并实现  *(IMPL claims and implements)*

认领：`PROJECTS/example-project/CLAIMS/S1_CLAIM_IMPL_20260708T101500.md`（从 `TEMPLATES/ClaimTask.md` 复制，节选）

```markdown
# ClaimLease: S1_CLAIM_IMPL_20260708T101500
## Header
- claim_id: S1_CLAIM_IMPL_20260708T101500
- project_id: example-project
- stage: S1_spec
- actor_id: IMPL
- role: IMPL
- action: ClaimTask
- related_envelope: S1_ISSUE_SPEC_20260708T100000
- blackboard_revision_seen: 1
- status: Active
## Scope
- workspace_root: <example-project 真实目录>
- file_scope:
  - src/example_project/cli.py
  - tests/test_health.py
- exclusive: true
## Safety
- destructive_actions: none
- secrets_required: none
```

提交：`PROJECTS/example-project/HANDOFF/S1_SUBMIT_IMPL_20260708T110000.md`（从 `TEMPLATES/SubmitImpl.md` 复制，节选）

```markdown
# Envelope: S1_SUBMIT_IMPL_20260708T110000
## Header
- envelope_id: S1_SUBMIT_IMPL_20260708T110000
- stage: S1_spec
- from: IMPL
- to: TEST
- action: SubmitImpl
- risk_level: Low
## Payload
### Implementation Summary
在 cli.py 增加 health 子命令；新增 tests/test_health.py。
### Tests
- command: pytest tests/test_health.py
- result: PASS
- passed: 5
- failed: 0
### Self Check
- tests/self_check_impl.md
## Evidence
- EVIDENCE/E1_runtime_pytest.md
## Status
- current: Submitted
- updated_by: IMPL
```

黑板阶段更新为 `ImplSubmitted`。
*Blackboard stage → `ImplSubmitted`.*

---

## 3. TEST 独立初验  *(TEST first-verifies)*

认领：`CLAIMS/S1_CLAIM_TEST_20260708T111000.md`（同 ClaimTask 模板，`role: TEST`）。

提交：`PROJECTS/example-project/HANDOFF/S1_SUBMIT_TEST_20260708T113000.md`（从 `TEMPLATES/SubmitTestReport.md` 复制，节选）

```markdown
# Envelope: S1_SUBMIT_TEST_20260708T113000
## Header
- envelope_id: S1_SUBMIT_TEST_20260708T113000
- stage: S1_spec
- from: TEST
- to: SPEC, IMPL
- action: SubmitTestReport
## Payload
### Test Summary
- related_impl_envelope: S1_SUBMIT_IMPL_20260708T110000
- test_type: unit
- result: PASS
- total: 9
- passed: 9
- failed: 0
### Findings
1. 边界 case（空仓库、0 文件）已覆盖。
### Recommendation
PASS
## Evidence
- EVIDENCE/E2_runtime_pytest.md
## Status
- current: Submitted
- updated_by: TEST
```

黑板阶段更新为 `TestReported`。
*Blackboard stage → `TestReported`.*

---

## 4. SPEC 最终验收  *(SPEC accepts)*

文件：`PROJECTS/example-project/HANDOFF/S1_ACCEPT_20260708T114500.md`

```markdown
# Envelope: S1_ACCEPT_20260708T114500
## Header
- envelope_id: S1_ACCEPT_20260708T114500
- stage: S1_spec
- from: SPEC
- to: IMPL, TEST
- action: AcceptStage
- risk_level: Low
## Payload
### Decision
满足全部验收标准：子命令可用、输出三项指标、单测全绿、Runtime 证据可复核。
### Accepted Criteria
- all four acceptance criteria met
## Status
- current: Accepted
- updated_at: 2026-07-08T11:45:00+08:00
- updated_by: SPEC
## Audit
- 2026-07-08T11:45:00+08:00 | SPEC | Accepted stage S1_spec
```

黑板阶段更新为 `Accepted`，本周期结束。
*Blackboard stage → `Accepted`; cycle complete.*

---

## 黑板阶段时间线  *(Blackboard stage timeline)*

| 顺序 | 阶段 | 触发动作 |
|---|---|---|
| 1 | `SpecIssued` | SPEC 下发 IssueSpec |
| 2 | `ImplClaimed` | IMPL 创建 ClaimLease |
| 3 | `ImplSubmitted` | IMPL 提交 SubmitImpl |
| 4 | `TestClaimed` | TEST 创建 ClaimLease |
| 5 | `TestReported` | TEST 提交 SubmitTestReport |
| 6 | `Accepted` | SPEC 提交 AcceptStage |

| # | Stage | Trigger |
|---|---|---|
| 1 | `SpecIssued` | SPEC issues IssueSpec |
| 2 | `ImplClaimed` | IMPL creates ClaimLease |
| 3 | `ImplSubmitted` | IMPL submits SubmitImpl |
| 4 | `TestClaimed` | TEST creates ClaimLease |
| 5 | `TestReported` | TEST submits SubmitTestReport |
| 6 | `Accepted` | SPEC submits AcceptStage |

---

## 关键提醒  *(Key reminders)*

- 每个信封从 `TEMPLATES/` 对应模板复制，不要凭空造字段——`SCHEMAS/` 会校验。
- *Copy every envelope from the matching `TEMPLATES/` file; don't invent fields — `SCHEMAS/` validates them.*
- `sequence_no` 在同一项目内递增，便于依赖追踪。
- *`sequence_no` increments within a project for dependency tracking.*
- 想看全局进度：先读 `BLACKBOARD.md`，再看 `HANDOFF/` 最新信封。
- *To see overall progress: read `BLACKBOARD.md` first, then the latest envelope in `HANDOFF/`.*
