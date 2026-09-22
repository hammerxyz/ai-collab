# 完整周期样例

> 用小任务演示 SPEC → IMPL → TEST → Accept 全周期的真实落盘产物。形状可直接照抄，字段说明见 `TEMPLATES/`。

<!-- 新手照此节即可知每阶段该往哪个目录丢什么文件。所有信封从 TEMPLATES/ 对应模板复制后填写。 -->

---

## 场景

给 `example-project`（Python CLI 工具）新增 `health` 子命令，打印三项关键健康指标（文件数、测试通过率、最近改动数）。

阶段码统一用 `S1_`，便于在黑板与信封间追踪。

---

## 1. SPEC 下发任务

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

---

## 2. IMPL 认领并实现

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

---

## 3. TEST 独立初验

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

---

## 4. SPEC 最终验收

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

---

## 黑板阶段时间线

| 顺序 | 阶段 | 触发动作 |
|---|---|---|
| 1 | `SpecIssued` | SPEC 下发 IssueSpec |
| 2 | `ImplClaimed` | IMPL 创建 ClaimLease |
| 3 | `ImplSubmitted` | IMPL 提交 SubmitImpl |
| 4 | `TestClaimed` | TEST 创建 ClaimLease |
| 5 | `TestReported` | TEST 提交 SubmitTestReport |
| 6 | `Accepted` | SPEC 提交 AcceptStage |

---

## 关键提醒

- 每个信封从 `TEMPLATES/` 对应模板复制，禁凭空造字段——`SCHEMAS/` 会校验。
- `sequence_no` 在同一项目内递增，便于依赖追踪。
- 想看全局进度：先读 `BLACKBOARD.md`，再看 `HANDOFF/` 最新信封。

---

## 场景二：plan 驱动模式

> 同一需求（给 CLI 加 health 子命令）用 plan 模式跑一遍，对比场景一可看出差异。
> 详见 PLAN.md 协议。

### plan 文件结构

```text
{workspace_root}/
├── requirements.md                   # HUMAN 写的项目需求
└── plans/
    ├── PLAN.md                       # 总编排：2 个 stage
    ├── consultant_guide.md
    ├── qa_checklist.md
    ├── S1/
    │   ├── spec.md
    │   ├── impl_prompt.md
    │   ├── test_prompt.md
    │   └── acceptance.md
    └── S2/                           # 假设 S2 是文档 stage，结构类似
```

### 步骤 1：HUMAN 写需求

HUMAN 在 `{workspace_root}/requirements.md` 写：

```markdown
# 项目需求

## 目标
给 example_project CLI 增加 health 子命令，输出文件数、测试通过率、最近 7 天改动数。

## 约束
- 不引入新依赖
- 复用现有 scan_repo() 函数
- 附 Runtime 证据
```

HUMAN 在 PROJECT.md 加 `requirements_ref: requirements.md`，唤醒 SPEC："读 requirements，生成 plan"。

### 步骤 2：SPEC 生成 plan

SPEC 读 requirements.md，在 plans/ 下编写：
- PLAN.md（含 S1: health 子命令实现，S2: 文档更新）
- S1/spec.md（规范正文）
- S1/impl_prompt.md（IMPL 的详细 prompt，file_scope 含 cli.py 和 test_health.py）
- S1/test_prompt.md（TEST 的测试计划，file_scope 含 test_health_edge.py）
- S1/acceptance.md（SPEC 的验收 checklist）
- consultant_guide.md + qa_checklist.md

SPEC 发 IssuePlan 信封到 HANDOFF/PLAN_SPEC_TO_ALL_20260725T1030.md：

```yaml
# Envelope: ENV-20260725-001
## Header
- action: IssuePlan
- from: SPEC
- to: ALL
- message_type: Command
- risk_level: High
- requires_audit: true
## Payload
- plan_id: PLAN-20260725-001
- plan_version: v1
- plan_path: plans/PLAN.md
- plan_sha256: {hash}
- requirements_ref: requirements.md
- total_stages: 2
- stages_summary:
  - S1: health_cli | depends_on: [] | risk: Medium | qa_gate: required | consultant_gate: optional
  - S2: docs | depends_on: [S1] | risk: Low | qa_gate: optional | consultant_gate: skipped
- review_gates:
  - consultant_review_required: true
  - qa_review_required: true
  - human_accept_required: true
```

### 步骤 3：CONSULTANT + QA 复核

CONSULTANT 读 consultant_guide.md + PLAN.md，复核走势，发 SyncStatus 信封：

```yaml
# Envelope: ENV-20260725-002
- action: SyncStatus
- from: CONSULTANT
- to: SPEC
- message_type: Event
## Payload
- review_type: ConsultantReview
- verdict: Pass
- comment: stage 序列合理，S1 风险适中，S2 文档 stage 可并行但建议串行
```

QA 读 qa_checklist.md + PLAN.md，复核合规性，发 SyncStatus 信封：

```yaml
# Envelope: ENV-20260725-003
- action: SyncStatus
- from: QA
- to: SPEC
- message_type: Event
## Payload
- review_type: QAReview
- verdict: Pass
- comment: plan 字段完整，file_scope 无重叠，门控配置合理
```

### 步骤 4：HUMAN Accept

HUMAN 收齐 CONSULTANT + QA 签字，在 IssuePlan 信封上 Accept：

```yaml
# ENV-20260725-001 的 Status 段更新
- current: Accepted
- updated_by: HUMAN
## Audit
- 2026-07-25T10:35 | HUMAN | Accepted IssuePlan, CONSULTANT+QA passed
```

SPEC 在 BLACKBOARD.md 顶部写 `active_plan: PLAN-20260725-001`。plan 生效。

### 步骤 5：IMPL 按 plan 推进 S1

IMPL 轮询唤醒：
1. 读 BLACKBOARD.md -> active_plan=PLAN-20260725-001，plan 状态 Active
2. 读 plans/PLAN.md -> S1 的 depends_on=[] 已满足（无前置）
3. 门控检查：S1 上游无依赖，parallel_with=[]，无冲突
4. 读 plans/S1/impl_prompt.md -> Goal: 实现 health 子命令；Scope: cli.py + test_health.py
5. 写 ClaimTask（file_scope 从 impl_prompt.md 复制，stage_scope=S1）
6. 实现 cli.py + test_health.py + 自检
7. 写 SubmitImpl 信封（to: TEST，evidence_ref 引用 EVIDENCE/E1.md）
8. 更新 BLACKBOARD.md（只动 S1 行，revision+1）

IMPL 毋庸等 SPEC 发 IssueSpec——prompt 文件即任务源。

### 步骤 6：TEST 按 plan 推进 S1

TEST 轮询唤醒：
1. 读 BLACKBOARD.md -> S1 状态=ImplSubmitted
2. 读 plans/S1/test_prompt.md -> Test Plan: 黑盒+边界+回归；file_scope: test_health_edge.py
3. 写 ClaimTask（stage_scope=S1）
4. 执行测试：黑盒（调用 health 命令）+ 边界（空仓库）+ 回归（其他子命令）
5. 写 SubmitTestReport 信封（to: SPEC,IMPL，verdict=PASS）
6. 更新 BLACKBOARD.md（只动 S1 行）

TEST 不抄 IMPL 的 Implementation Hints，保持独立性。

### 步骤 7：QA stage 门控

qa_gate=required，QA 读 qa_checklist.md + S1 的信封/证据：
- 检查 SubmitImpl 是否附 evidence_ref ✓
- 检查 SubmitTestReport verdict != FAIL ✓
- 检查证据等级是否虚标（Runtime 证据真实）✓
- 检查 file_scope 是否越界（与 impl_prompt.md 一致）✓

QA 发 SyncStatus 信封：

```yaml
- action: SyncStatus
- from: QA
- to: SPEC
## Payload
- review_type: QAStagePass
- stage: S1
- verdict: Pass
```

### 步骤 8：SPEC AcceptStage

SPEC 读 plans/S1/acceptance.md 的 Pre-acceptance Gates：
1. [x] IMPL 的 SubmitImpl 信封存在且 status=Submitted
2. [x] TEST 的 SubmitTestReport 信封存在且 verdict=PASS
3. [x] QA 检查通过（qa_gate=required，已收到 QAStagePass）
4. [N/A] CONSULTANT 签字（consultant_gate=optional，S1 非 High risk）
5. [x] Runtime 证据可复核
6. [x] file_scope 与 plan 一致
7. [x] 无 P0 阻塞项

全满足，SPEC 发 AcceptStage 信封：

```yaml
# Envelope: ENV-20260725-010
- action: AcceptStage
- from: SPEC
- to: ALL
- stage: S1
## Payload
- verdict: Accepted
- gates_passed: [IMPL, TEST, QA, evidence, scope]
## Audit
- 2026-07-25T11:20 | SPEC | AcceptStage S1, all gates passed
```

S1 完成，BLACKBOARD.md 中 S1 状态=Accepted。S2（文档 stage）自动可推进（depends_on=[S1] 已满足 gate_state=Accepted）。

### 场景一 vs 场景二对比

| 维度 | 场景一（IssueSpec） | 场景二（plan 模式） |
|------|--------------------|--------------------|
| 任务源 | SPEC 现写 IssueSpec 信封 | IMPL/TEST 直接读 prompt 文件 |
| 多角色 prompt | 单一 IssueSpec 共享 | 每 role 独立 prompt 文件 |
| 推进方式 | SPEC 主动下发 | actor 轮询自主推进 |
| 门控 | SPEC 自行判断 | qa_gate/consultant_gate 显式字段 |
| 启动成本 | 低（SPEC 直接发） | 高（须生成 plan + 复核 + HUMAN Accept） |
| 适合场景 | 单次任务、探索性 | 多 stage 项目、可编排 |
