# AI-COLLAB 项目计划协议

> 版本：1.0 | 生效日期：2026-07-25 | 状态：可选扩展（随 ai-collab v1.2 发布；不修改 v1.1 核心协议）
> 依赖：PROTOCOL.md v1.1、ACTIONS.md、ORDERING.md、STRUCTURE.md

---

## 一、定位与边界

### 1.1 一句话定位

Plan 是 SPEC 预先编排的"stage 序列 + 各角色 prompt 源"，让多 actor 轮询唤醒时基于详细 prompt 自主推进，毋庸每次等 SPEC 现写 IssueSpec。

### 1.2 是什么 / 不是什么

- **是产出物**：plan 正文存放在 {workspace_root}/plans/，归属产出物层（对齐 PROTOCOL.md §2.2、PROJECTS/README.md §7）。
- **是可选机制**：无 plan 的项目继续走原 SPEC->IssueSpec 流程；有 plan 的项目可由 actor 轮询推进。
- **是编排层，非执行层**：plan 描述 stage 期望序列及角色 prompt，不替代信封、状态机、AcceptStage 验收。
- **非运行时**：plan 不引入调度器、脚本、自动推进；所有推进仍由 actor 唤醒后自觉按协议执行。
- **非规范替代物**：plan 引用 spec，不替代 spec。每个 stage 仍须 S{N}/spec.md 作规范正文。

### 1.3 与现有协议的关系

| 现有机制 | plan 与之的关系 |
|---------|----------------|
| Envelope（信封） | plan 经 IssuePlan / RevisePlan 信封下发，不绕过总线 |
| BLACKBOARD.md（黑板） | 黑板顶部加 active_plan 指针，不新增控制面文件 |
| IssueSpec（下发规范） | plan 的 S{N}/spec.md 等价于 IssueSpec 的 payload 源；有 plan 时 SPEC 毋庸每 stage 现写 IssueSpec |
| ClaimLease（租约） | plan 的 file_scope 直接复制到 ClaimTask，复用现有冲突检测 |
| AcceptStage（验收） | plan 不自动推进 stage，验收权仍归 SPEC，门控见 §6 |
| 仲裁链 L1-L8 | plan 修订/冲突仍走仲裁链，CONSULTANT/QA 有阻塞权 |

---

## 二、目录结构与文件职责

### 2.1 plan 文件布局

```text
{workspace_root}/                         # 产出物层
├── requirements.md                       # HUMAN 写的项目需求（plan 输入）
└── plans/
    ├── PLAN.md                           # 总编排：stage 序列 + 依赖 + 门控
    ├── consultant_guide.md               # CONSULTANT 全局研判要点
    ├── qa_checklist.md                   # QA 全局检查清单
    └── S{N}/                             # 每个 stage 一个子目录
        ├── spec.md                       # stage 规范正文（SPEC 维护）
        ├── impl_prompt.md                # IMPL 的详细 prompt
        ├── test_prompt.md                # TEST 的详细 prompt
        └── acceptance.md                 # SPEC 自己的验收 checklist

PROJECTS/{project_id}/                    # 控制面层
├── PROJECT.md                            # 加 requirements_ref / active_plan 字段
├── BLACKBOARD.md                         # 顶部加 active_plan 指针
└── HANDOFF/                              # plan 通过 IssuePlan 信封下发
```

### 2.2 文件职责

| 文件 | 写入方 | 读取方 | 内容 |
|------|--------|--------|------|
| requirements.md | HUMAN | SPEC | 项目目标、约束、优先级 |
| plans/PLAN.md | SPEC | ALL | stage 序列、依赖、门控、角色 prompt 引用 |
| plans/S{N}/spec.md | SPEC | ALL | 该 stage 的规范正文 |
| plans/S{N}/impl_prompt.md | SPEC | IMPL | IMPL 的目标、scope、验收标准、handoff 契约 |
| plans/S{N}/test_prompt.md | SPEC | TEST | TEST 的测试计划、scope、verdict 契约 |
| plans/S{N}/acceptance.md | SPEC | SPEC | SPEC 的验收 checklist |
| plans/consultant_guide.md | SPEC | CONSULTANT | 全局走势研判要点 |
| plans/qa_checklist.md | SPEC | QA | 全局合规检查清单 |
| PROJECT.md 新增字段 | HUMAN/SPEC | ALL | requirements_ref、active_plan 指针 |
| BLACKBOARD.md 顶部 | SPEC | ALL | active_plan 指针（已有 revision 机制不变） |

### 2.3 控制面与产出物分离铁律

- plan 正文（PLAN.md、S{N}/*.md、requirements.md）**须**在 {workspace_root}/plans/，禁写入 PROJECTS/{project_id}/。
- PROJECTS/{project_id}/ 只保留**薄索引**：PROJECT.md 加 2 个指针字段，BLACKBOARD.md 顶部加 active_plan 指针。
- 信封 IssuePlan / RevisePlan 的 payload 只引用 workspace-relative 路径 + sha256，不内联 plan 正文。
- 违反此铁律等同 PROTOCOL.md §7.2 第 12 条，由 WATCHDOG 标记 PlanLocationViolation。

---

## 三、PLAN.md 主文档结构

```markdown
# Project Plan: {project_id}

## Header
- plan_id: PLAN-{UUID}
- project_id: {project_id}
- plan_version: v1
- supersedes: none | {PLAN-old-UUID}
- created_by: SPEC
- reviewed_by: [CONSULTANT, QA]
- accepted_by: HUMAN
- created_at: {ISO8601}
- accepted_at: {ISO8601 or pending}
- status: Draft | UnderReview | Active | Superseded | Withdrawn
- requirements_ref: requirements.md

## Sequencing
- mode: linear | dag | parallel_groups
- total_stages: {N}

## Stages

### S1: {stage_name}
- stage_id: S1
- depends_on: []
- gate_state: Accepted            # 前置 stage 必须到此状态才能开工
- parallel_with: []               # 可并行的 stage_id 列表，空=严格串行
- risk_level: Low | Medium | High
- qa_gate: required | optional | skipped
- consultant_gate: required | optional | skipped   # required 仅当 risk_level=High
- spec_ref: plans/S1/spec.md
- impl_prompt_ref: plans/S1/impl_prompt.md
- test_prompt_ref: plans/S1/test_prompt.md
- acceptance_ref: plans/S1/acceptance.md
- on_reject: retry | rollback_to | escalate
- max_retries: 2

### S2: {stage_name}
- stage_id: S2
- depends_on: [S1]
- ...

## Rollback Policy
- 已 Accepted 的 stage 不因 plan 修订回滚
- HUMAN 强烈要求回滚已 Accepted stage 时走 DeclareConflict 升级 L1
- plan 修订只影响 Planned/SpecIssued/InProgress 状态的 stage

## Audit
- {ISO8601} | SPEC | Created plan v1
- {ISO8601} | CONSULTANT | Reviewed, Pass
- {ISO8601} | QA | Reviewed, Pass
- {ISO8601} | HUMAN | Accepted
```

---

## 四、各角色 prompt 标准结构

详细模板见 TEMPLATES/PlanPrompt.md。本节只列概要：

### 4.1 impl_prompt.md
给 IMPL 读，含 Role Context / Goal / Required Reading / Scope（file_scope）/ Acceptance Criteria / Implementation Hints / Output Artifacts / Handoff Contract。

### 4.2 test_prompt.md
给 TEST 读，结构同 impl_prompt 但面向测试，含 Test Plan / Verdict Criteria。明确禁抄 IMPL 的 Implementation Hints。

### 4.3 acceptance.md
给 SPEC 自己读，含 Pre-acceptance Gates / Decision Rules / Audit。门控项包括 IMPL/TEST 信封、QA Pass、CONSULTANT 签字（如需）、证据、file_scope 一致性。

### 4.4 consultant_guide.md / qa_checklist.md
横向角色用，不阻塞主线时作参考，门控触发时作签字依据。

---

## 五、plan 生命周期

### 5.1 生成流程（选项 1.5）

```text
1. HUMAN 写 {workspace_root}/requirements.md
2. HUMAN 在 PROJECT.md 加 requirements_ref 指针
3. HUMAN 唤醒 SPEC："读 requirements，生成 plan"
4. SPEC 读 requirements.md
5. SPEC 在 {workspace_root}/plans/ 编写：
   - PLAN.md（总编排）
   - S{N}/spec.md + impl_prompt.md + test_prompt.md + acceptance.md
   - consultant_guide.md + qa_checklist.md
6. SPEC 发 IssuePlan 信封（action=IssuePlan, to=ALL, message_type=Command）
7. CONSULTANT 复核走势 -> 通过 SyncStatus 信封（payload review_type=ConsultantReview, verdict=Pass/Veto）
8. QA 复核 plan 合规性 -> 通过 SyncStatus 信封（payload review_type=QAReview, verdict=Pass/Veto）
9. HUMAN 收齐 CONSULTANT + QA 签字 -> 在 IssuePlan 信封上 Accept
10. SPEC 在 BLACKBOARD.md 顶部写 active_plan 指针
11. plan 生效，actor 可按 plan 轮询推进
```

### 5.2 修订流程

修订触发场景（覆盖协议调研中的 7 种场景）：

| 场景 | 触发方 | 流程 |
|------|--------|------|
| SPEC 自查有误 | SPEC | 直接发 RevisePlan |
| CONSULTANT/QA 复核有异议 | CONSULTANT/QA | DeclareConflict -> SPEC 发 RevisePlan |
| HUMAN 改目标 | HUMAN（L1） | 指令 SPEC -> SPEC 发 RevisePlan |
| 漏 stage 要插入 | IMPL/TEST | RequestSpecClarification -> SPEC 决定是否 RevisePlan |
| plan 整体作废 | HUMAN | 指令 SPEC -> RevisePlan 标 Withdrawn 或重写 |

**plan 整体作废的特殊处理**：

plan 作废（场景 7）不等于 stage 作废。已 Accepted stage 的代码、证据、审计保留为历史事实，不删除、不回滚。plan 作废只影响未执行 stage（Planned / SpecIssued / InProgress 状态）。HUMAN 若需回滚已 Accepted stage 的代码，须走 DeclareConflict 升级 L1 单独裁决，与 plan 作废是两个独立动作。

**修订硬规则**：

1. 修订须发 RevisePlan 信封，supersedes 引用旧 plan_id
2. 修订须写 AUDIT/（plan 修订属高风险）
3. **已 Accepted 的 stage 不受 plan 修订影响**（已 Accepted = 历史事实）
4. 修订只影响 Planned / SpecIssued / InProgress 状态的 stage
5. 修订需 CONSULTANT + QA 复核 + HUMAN Accept（同生成流程）
6. BLACKBOARD.md 更新 active_plan 指针到新 plan_id

### 5.3 stage 回退（不修改 plan）

- stage 层的 RejectStage **不修改 plan**——plan 里 stage 序列不变
- 只是某 stage 状态从 Accepted/Testing 回到 InProgress
- plan 的 on_reject 字段（retry/rollback_to/escalate）是**建议**，实际回退由 SPEC 经 RejectStage 信封决定
- 回退须写 AUDIT（对齐 PROTOCOL.md §6.1）

### 5.4 stage 阻塞（不修改 plan）

- DeclareBlock 标记某 stage 为 Blocked
- plan 里下游 stage 自动滞留：actor 轮询时检查 gate_state，Blocked 的上游未到 gate_state -> 跳过下游
- 阻塞解除 ResolveBlock 后，下游 stage 自动可推进
- plan 不变

---

## 六、并发控制：3 层门控

### 6.1 第 1 层：plan 的 stage 门控

每个 stage 在 PLAN.md 里有：
- depends_on: [stage_id列表]
- gate_state: Accepted（前置 stage 须到此状态）
- parallel_with: []（可并行的 stage）

**actor 轮询时的门控规则**：

```text
读到 plan 里 S{N} 的 prompt ->
  检查 BLACKBOARD 中 S{N}.depends_on 的每个 stage 是否到 gate_state
    -> 任一未到 -> 跳过 S{N}，不认领
    -> 全部到 -> 检查 parallel_with 之外的 stage 是否有 active claim
      -> 有冲突 -> 跳过
      -> 无冲突 -> 认领
```

这是软门控（actor 自觉遵守），对齐 0 运行时原则。WATCHDOG 扫描门控违反，新增检查项见 §6.4。

### 6.2 第 2 层：claim 的 stage_scope 扩展

在 ClaimTask 信封中**新增** stage_scope 字段（claim.schema.json 当前无此字段，但 additionalProperties: true 允许扩展；CLAIMS/README.md 应注明此扩展）：

- 一个 stage 同时最多 1 个 IMPL active claim + 1 个 TEST active claim
- 同 stage 同角色 2 个 active claim -> WATCHDOG 报 ClaimStageConflict
- 不同 stage 的 claim 可并行（如 plan 的 parallel_with 允许）
- file_scope 须从 plan 的 impl_prompt.md / test_prompt.md 直接复制，禁自造
- stage_scope 字段值等于 plan 的 stage_id（如 S1、S2）

### 6.3 第 3 层：黑板分段 revision

BLACKBOARD.md 的 Current State 段已有按 stage 分行表格。规则扩展：

- actor 更新黑板时，**只动自己 stage 那一行**，不动其他 stage 行
- blackboard_revision 仍全局递增
- 冲突检测细化：只有改同一 stage 行才算冲突，改不同 stage 行不算
- 这降低假冲突率，让并行更顺

写入顺序仍遵守 ORDERING.md §4：产出物 -> 证据 -> 信封 -> 最后黑板。

### 6.4 WATCHDOG 新增检查项

在 WATCHDOG.md 现有 14 项检查基础上新增：

| 编号 | 检查项 | 推荐状态 |
|------|--------|---------|
| 15 | actor 认领的 stage 上游未到 gate_state | DeclareConflict |
| 16 | 同 stage 同角色 2 个 active claim | DeclareConflict |
| 17 | plan 正文写入 PROJECTS/ 控制面 | PlanLocationViolation |
| 18 | actor 按 plan 推进但 plan 状态非 Active | Blocked |
| 19 | AcceptStage 时 qa_gate=required 但无 QA Pass 信封 | DeclareConflict |
| 20 | risk_level=High 且 consultant_gate=required 但无 CONSULTANT 签字 | DeclareConflict |

---

## 七、门控：CONSULTANT 与 QA 的阻塞权

### 7.1 CONSULTANT 战略门控

| 节点 | 触发 | 阻塞方式 |
|------|------|---------|
| plan 生成 | IssuePlan 后 | 不签字 -> plan 不生效 |
| plan 修订 | RevisePlan 后 | 不签字 -> 修订不生效 |
| High risk stage | AcceptStage 前 | 不签字 -> SPEC 禁 Accept |

CONSULTANT 复核结果**复用 SyncStatus 信封**（不是新动作），在 payload 加 review_type: ConsultantReview 和 verdict: Pass/Veto 字段；不通过时也可发 DeclareConflict（Veto, L3）。

### 7.2 QA 战术门控

| 节点 | 触发 | 阻塞方式 |
|------|------|---------|
| plan 生成 | IssuePlan 后 | 不签字 -> plan 不生效 |
| plan 修订 | RevisePlan 后 | 不签字 -> 修订不生效 |
| 每 stage AcceptStage 前 | TEST 报告提交后 | 不发 QA Pass -> SPEC 禁 Accept |

QA 复核结果**复用 SyncStatus 信封**（不是新动作），在 payload 加 review_type 字段区分三种场景：QAReview（plan 级复核）、QAStagePass（stage 级门控）；不通过时也可发 DeclareConflict（Veto, L2）。

### 7.3 stage 推进的完整门控链

```text
IMPL: SubmitImpl -> TEST
TEST: SubmitTestReport -> SPEC, IMPL
QA:   (qa_gate=required) 检查 -> SyncStatus(review_type=QAStagePass) / Veto
CONSULTANT: (consultant_gate=required 且 risk=High) 复核 -> SyncStatus(review_type=ConsultantReview) / Veto
SPEC: 收齐 TEST 报告 + QA Pass + (如需) CONSULTANT 签字 -> AcceptStage
```

SPEC 在任一 required 门控未通过时发 AcceptStage，WATCHDOG 报 GateViolation（检查项 19/20）。

---

## 八、actor 轮询标准 Loop（plan 模式）

在 SKILL.md / ROLE_*.md 现有 Loop 基础上，plan 模式下追加：

```text
0. 读 BLACKBOARD.md -> 确认 active_plan 指针和 plan 状态
   -> 无 active_plan -> 走原 IssueSpec 流程（向后兼容）
   -> 有 active_plan 且状态 Active -> 进入 plan 模式 Loop

1. 读 {workspace}/plans/PLAN.md -> 找当前可执行 stage
   -> 遍历 stages，找 depends_on 都到 gate_state 且自己角色有 prompt 的 stage

2. 门控检查
   -> 上游 stage 是否到 gate_state？没到 -> 跳过
   -> parallel_with 之外是否有 active claim 冲突？有 -> 跳过

3. 读 {workspace}/plans/S{N}/{role}_prompt.md
   -> IMPL 读 impl_prompt.md
   -> TEST 读 test_prompt.md
   -> SPEC 读 acceptance.md
   -> CONSULTANT 读 consultant_guide.md + 当前 stage spec.md
   -> QA 读 qa_checklist.md + 当前 stage 信封/证据

4. 按 prompt 的 Goal/Scope/Criteria 细化为具体动作

5. 写 ClaimTask（file_scope 从 prompt 直接复制，stage_scope 填 S{N}）

6. 执行 -> 写证据 -> 写信封 -> 更新黑板（只动自己 stage 行） -> 心跳
```

---

## 九、向后兼容

- plan 是**可选**机制，老项目无 plan 不受影响，继续走 SPEC->IssueSpec 流程
- 项目可在任意时刻引入 plan：HUMAN 写 requirements.md -> SPEC 出 plan -> 生效
- 项目可在任意时刻退出 plan：HUMAN 在 BLACKBOARD 移除 active_plan 指针 -> 回到原流程
- plan 与 IssueSpec 可共存：某 stage 无 prompt 时，SPEC 仍可发 IssueSpec
- plan 不修改 PROTOCOL.md 任何现有铁律，只增加新字段、新动作、新模板

---

## 十、新增动作

在 ACTIONS.md 新增 2 个动作：

| 动作 | from->to | message_type | risk_level | 必需 payload |
|------|---------|--------------|-----------|-------------|
| IssuePlan | SPEC->ALL | Command | High | plan_id, plan_version, requirements_ref, stage 列表摘要 |
| RevisePlan | SPEC->ALL | Command | High | plan_id, supersedes, 修订原因, 影响范围 |

复核响应动作（复用现有 SyncStatus，不是新动作）：
- CONSULTANT 复核 -> SyncStatus（payload 标 review_type=ConsultantReview, verdict=Pass/Veto）
- QA 复核 -> SyncStatus（payload 标 review_type=QAReview, verdict=Pass/Veto）
- QA stage 门控 -> SyncStatus（payload 标 review_type=QAStagePass, verdict=Pass/Veto）
- HUMAN 接受 -> 在 IssuePlan/RevisePlan 信封上 Accept（信封 status -> Accepted）

---

## 十一、禁止行为

在 PROTOCOL.md §7 基础上新增 plan 专属禁止：

| # | 禁止行为 | 理由 |
|---|---------|------|
| 14 | plan 正文写入 PROJECTS/{project_id}/ | 控制面与产出物分离 |
| 15 | actor 在 plan 状态非 Active 时按 plan 推进 | plan 未生效 |
| 16 | SPEC 在 qa_gate/consultant_gate 未通过时发 AcceptStage | 门控铁律 |
| 17 | actor 认领 stage 时上游未到 gate_state | 顺序铁律 |
| 18 | 修改已 Accepted stage 的 plan 定义而不发 RevisePlan | plan 不可变 |
| 19 | plan 修订不写 AUDIT | 审计铁律 |
| 20 | plan 修订回滚已 Accepted stage | 历史不可逆 |

### 修订本协议时的同步检查清单

凡修改本文件的以下章节，须同步检查对应文件，防止跨文档漂移：

| 修改章节 | 须同步检查的文件 |
|---------|------------------|
| §三 stage 字段结构 | TEMPLATES/IssuePlan.md、TEMPLATES/PlanPrompt.md、EXAMPLE.md 场景二 |
| §五 生命周期流程 | ROLE_SPEC.md plan 模式章节、SKILL.md §6.1 |
| §六 并发门控 | WATCHDOG.md 检查项 15-20、CLAIMS/README.md stage_scope 小节 |
| §七 CONSULTANT/QA 门控 | ROLE_CONSULTANT.md plan 模式章节、ROLE_QA.md plan 模式章节 |
| §八 轮询 Loop | SKILL.md §6.1、各 ROLE_*.md plan 模式章节 |
| §十 动作定义 | ACTIONS.md 动作总表 + 权限矩阵 + 动作详情小节 |
| §十一 禁止行为 | WATCHDOG.md、对应 ROLE_*.md 的禁止行为条目 |

修改后在本文件 §十二 修订记录中追加一行，并在 CHANGELOG.md 中记录。

---

## 十二、修订记录

| 日期 | 版本 | 修改内容 | 修改人 |
|------|------|---------|--------|
| 2026-07-25 | 1.0 | 初始版本，定义 plan 协议、生命周期、门控、并发控制 | SPEC（按 HUMAN 指令） |
| 2026-07-26 | 1.0 | 随 ai-collab v1.2 发布；新增修订同步清单；TEMPLATES 增加提交前自检 | SPEC |
