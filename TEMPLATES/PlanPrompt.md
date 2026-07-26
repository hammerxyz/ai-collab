<!-- 中文说明：plan 各角色 prompt 模板说明。SPEC 编写 plan 时按此结构为每个 stage 生成 impl_prompt.md / test_prompt.md / acceptance.md，并生成全局 consultant_guide.md / qa_checklist.md。文件存放在 {workspace_root}/plans/S{N}/ 和 {workspace_root}/plans/。 -->

# Plan Prompt 模板说明  *(Plan Prompt Templates)*

> 版本：1.0 | 配套协议：PLAN.md v1.0（ai-collab v1.2 可选扩展）
> 本文件只定义模板结构，不规定具体业务内容。

---

## 一、文件清单  *(I. File inventory)*

每个有 plan 的项目，SPEC 应在 `{workspace_root}/plans/` 下创建以下文件：

| 文件 | 写入方 | 读取方 | 模板章节 |
|------|--------|--------|----------|
| `PLAN.md` | SPEC | ALL | PLAN.md §三 |
| `consultant_guide.md` | SPEC | CONSULTANT | §二.1 |
| `qa_checklist.md` | SPEC | QA | §二.2 |
| `S{N}/spec.md` | SPEC | ALL | §二.3 |
| `S{N}/impl_prompt.md` | SPEC | IMPL | §二.4 |
| `S{N}/test_prompt.md` | SPEC | TEST | §二.5 |
| `S{N}/acceptance.md` | SPEC | SPEC | §二.6 |

---

## 二、模板结构  *(II. Template structures)*

### 2.1 consultant_guide.md（全局顾问指南）

```markdown
# Consultant Guide: {project_id}

## 研判维度
1. 架构走向：是否符合 requirements.md 的项目目标
2. 跨 stage 一致性：接口、数据流、依赖关系
3. 风险预警：技术风险、外部依赖、可行性
4. 资源匹配：stage 难度与 actor 能力

## 介入节点
- plan 生成/修订时：必签字（PLAN.md §五.1/§五.2）
- risk_level=High 的 stage：AcceptStage 前必签字
- 其他 stage：可选审视，发现问题发 DeclareConflict

## Veto 权
- 走势偏离 -> Veto 信封（L3，覆盖 SPEC L4）
- SPEC 不服 -> 升级 HUMAN L1

## Audit
- {ISO8601} | CONSULTANT | Reviewed plan v1, Pass
```

### 2.2 qa_checklist.md（全局 QA 清单）

```markdown
# QA Checklist: {project_id}

## 全局检查项
1. 证据等级是否被虚标（如用 UnitTest 冒充 Runtime）
2. 高风险动作是否写 AUDIT/
3. 信封 21 字段是否完整
4. 黑板是否被污染（写正文违反铁律）
5. file_scope 是否越界
6. ClaimLease 是否过期未续

## 每 stage 检查项
1. SubmitImpl 是否附 evidence_ref
2. SubmitTestReport 是否含测试数和 verdict
3. AcceptStage 前置是否齐全（TEST 报告 + QA Pass + 必要时 CONSULTANT 签字）
4. HANDOFF/EVIDENCE/AUDIT 引用是否真实存在

## Veto 权
- 严重合规问题 -> Veto 信封（L2，阻断 AcceptStage）
- SPEC 不得在 QA Veto 未解除时发 AcceptStage

## Audit
- {ISO8601} | QA | Reviewed plan v1, Pass
```

### 2.3 S{N}/spec.md（stage 规范正文）

```markdown
# Spec: {stage_id} {stage_name}

## 目标
{本 stage 要解决什么问题}

## 背景
{上游 stage 产出、约束、相关决策}

## 接口定义
{输入/输出、数据结构、API 契约}

## 约束
{技术约束、合规约束、风格约束}

## 验收要点
{SPEC 自己验收时关注的关键点，详细 checklist 见 acceptance.md}

## References
- 上游 stage 的 acceptance.md
- requirements.md 相关章节
```

### 2.4 S{N}/impl_prompt.md（IMPL 详细 prompt）

```markdown
# IMPL Prompt: {stage_id}

## Role Context
你是 IMPL。本 stage 你的职责是实现代码并自检，不负责验收。

## Goal
{从 spec.md 提取的具体目标}

## Required Reading
- {workspace_relative_path}  # 必读规范
- {上游 stage 的 acceptance.md}  # 了解上游约束

## Scope
- file_scope:
  - {具体文件路径列表}  # 直接复制到 ClaimTask
- 禁止改动: {列表}

## Acceptance Criteria
1. {可验证标准}
2. ...

## Implementation Hints
{SPEC 给的实现提示，可选}

## Output Artifacts
- expected:
  - {文件列表}
- evidence_required: {证据等级，如 Runtime}

## Handoff Contract
完成后必须：
1. 在工作目录写代码 + 自检报告
2. 在 EVIDENCE/ 写证据索引
3. 写 SubmitImpl 信封 -> to: TEST
4. evidence_ref 引用本 prompt 路径
5. 更新 BLACKBOARD.md（只动本 stage 行）
```

### 2.5 S{N}/test_prompt.md（TEST 详细 prompt）

```markdown
# TEST Prompt: {stage_id}

## Role Context
你是 TEST。本 stage 你做独立初验，不实现代码，不抄 IMPL 的 hints。

## Goal
{从 spec.md 提取的测试目标}

## Required Reading
- plans/S{N}/spec.md           # 验收依据
- plans/S{N}/impl_prompt.md    # 仅了解 IMPL 的 scope，不抄 hints
- IMPL 的 SubmitImpl 信封       # 看实际改动

## Scope
- file_scope:
  - {TEST 新增的测试文件}
- 禁止改动: src/ 下的实现代码

## Test Plan
1. 黑盒：{测试点}
2. 边界：{边界 case}
3. 回归：{回归范围}

## Verdict Criteria
- PASS: {条件}
- CONDITIONAL: {条件}
- FAIL: {条件}

## Handoff Contract
完成后必须：
1. 在工作目录写测试报告
2. 在 EVIDENCE/ 写测试证据索引
3. 写 SubmitTestReport 信封 -> to: SPEC,IMPL
4. verdict 明确 PASS/CONDITIONAL/FAIL
5. 更新 BLACKBOARD.md（只动本 stage 行）
```

### 2.6 S{N}/acceptance.md（SPEC 验收 checklist）

```markdown
# Acceptance Checklist: {stage_id}

## Role Context
你是 SPEC。本 stage 你做最终验收，不实现代码，不替 TEST 测试。

## Pre-acceptance Gates
1. [ ] IMPL 的 SubmitImpl 信封存在且 status=Submitted
2. [ ] TEST 的 SubmitTestReport 信封存在且 verdict != FAIL
3. [ ] QA 检查通过（如 qa_gate=required）
4. [ ] CONSULTANT 签字（如 consultant_gate=required 且 risk_level=High）
5. [ ] Runtime 证据可复核
6. [ ] file_scope 与 plan 一致（无越界改动）
7. [ ] 无 P0 阻塞项

## Decision Rules
- 全满足 -> AcceptStage 信封
- 缺非关键项 -> Conditional 信封
- 缺关键项或证据造假 -> RejectStage 信封

## Audit
- 验收必须写 AUDIT/（对齐 PROTOCOL.md §6.1）
- 记录：{ISO8601} | SPEC | AcceptStage S{N}, all gates passed
```

---

## 三、使用规则  *(III. Usage rules)*

### 3.1 模板填充责任
- 所有 prompt 文件由 SPEC 在 plan 生成阶段一次性编写
- IMPL/TEST/CONSULTANT/QA 不得自行修改 prompt 文件；发现问题走 RequestSpecClarification 或 DeclareConflict
- prompt 文件修改等同 plan 修订，必须走 RevisePlan 流程

### 3.2 与信封的关系
- prompt 文件是产出物，不是信封
- actor 按 prompt 执行后，仍必须写标准信封（SubmitImpl/SubmitTestReport/AcceptStage 等）
- 信封的 payload 可引用 prompt 文件路径作为 trace

### 3.3 与 IssueSpec 的关系
- 有 plan 的 stage：SPEC 不必再发 IssueSpec，IMPL/TEST 直接读 prompt 文件
- 无 plan 的 stage：SPEC 仍发 IssueSpec（向后兼容）
- 同一 stage 不可同时有 prompt 文件和 IssueSpec，避免双源

### 3.4 文件命名
- stage 目录用 S1, S2, ... 编号，与 PLAN.md 的 stage_id 一致
- 文件名固定为 spec.md / impl_prompt.md / test_prompt.md / acceptance.md
- 全局文件固定为 consultant_guide.md / qa_checklist.md

---

## 四、修订记录  *(IV. Revision history)*

| 日期 | 版本 | 修改内容 | 修改人 |
|------|------|---------|--------|
| 2026-07-25 | 1.0 | 初始版本，定义 6 类 prompt 模板 | SPEC |
