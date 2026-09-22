---
name: ai-collab-onboarding
description: |
  让 AI IDE 以指定角色接入 ai-collab（多 AI IDE 文件系统协作总线）。
  触发词：ai-collab 接入、接入协作总线、加载 ai-collab 角色。
---

# ai-collab 接入技能

> 本技能将你的 AI IDE 变成 ai-collab 协作总线的参与者。加载后，AI IDE 知道自己的角色、权限、交接规则和红线。

<!-- 纯 prompt 技能，无运行时依赖。所有行为靠 AI IDE 自觉遵守协议。 -->
<!-- 路径约定：本文件位于 ai-collab 仓库根目录，与 README.md、PROTOCOL.md 同级。本文件内所有相对链接都直接指向同目录或子目录的仓库文件，例如 PROJECTS/、TEMPLATES/、SCHEMAS/。克隆本仓库后，把这些链接当作"相对于仓库根"即可。 -->

---

## 步骤 0：确认角色

若用户未指定角色，询问用户当前 AI IDE 应扮演的角色：

```
请确认此 AI IDE 在 ai-collab 中的角色（选一个）：
SPEC / IMPL / TEST / CONSULTANT / QA / WATCHDOG

（HUMAN 由人类担任、不是 AI IDE，不经本技能加载；需人工裁决时由人类在信封上 Accept/Reject。）
```

将 `{ROLE}` 替换为以下步骤中的角色标识。

## 步骤 1：定位协议目录

本技能随 ai-collab 仓库一同发布，协议根目录即本仓库根（即 `README.md` 与 `PROJECTS/` 所在目录）。

记 `<ai-collab-root>` = 仓库根目录（即本文件所在目录）。项目空间位于 `<ai-collab-root>/PROJECTS/{project_id}/`。

## 步骤 2：读核心文件

要求 AI IDE 按序读以下文件（至少读完 README + PROTOCOL + 角色手册）：

| 优先级 | 文件 | 目的 |
|---|---|---|
| P0 | `README.md` | 总说明与核心理念 |
| P0 | `PROTOCOL.md` | 总协议：角色、信封、状态机、仲裁 |
| P0 | `QUICKSTART.md` | 操作手册 |
| P1 | `PROMPTS.md` | 可粘贴提示词（本技能的完整版本） |
| P1 | `EXAMPLE.md` | 完整周期样例 |
| P1 | `ROLE_{ROLE}.md`（WATCHDOG 无独立手册，规则见 `WATCHDOG.md`） | 你的角色手册（SPEC/IMPL/TEST/CONSULTANT/QA） |
| P2 | `RUNBOOKS/` 中对应手册 | 分步执行流程 |
| P2 | `ACTIONS.md` | 动作库（检查权限） |
| P2 | `STRUCTURE.md` | 根目录与项目空间边界 |
| P2 | `TIMER_LOOP.md` | 定时器 / 心跳约定 |

深度参考（按需，非上手必需）：`CLAIMS/README.md` + `SCHEMAS/claim.schema.json`（认领 / 租约，长任务强烈建议）、`TIMER_LOOP.md` + `HEARTBEAT/README.md`（轮询 / 心跳约定，每次循环结束建议刷新）、`ATOMIC_WRITE.md`（临时文件 + rename 原子写）、`ORDERING.md`（读写顺序与依赖 / 修订控制）、`LINT.md`（结构 / 引用 / 密钥自检规则）、`MEMORY_POLICY.md`（记忆层级与归档）、PLAN.md + TEMPLATES/IssuePlan.md + TEMPLATES/PlanPrompt.md（plan 模式可选协议，仅当项目启用 plan 时参考）。

## 步骤 3：登记身份

要求 AI IDE 检查并登记自身：

```text
在 PROJECTS/ 下找到匹配当前工作目录的项目空间（或依据 STRUCTURE.md 创建新项目空间）。
读取 PROJECTS/{project_id}/ACTORS.md，确认 {ROLE} 对应的 actor_id 已登记且 expires_at 有效。
若未登记或过期，使用 TEMPLATES/RegisterActor.md 创建新条目。
```

## 步骤 4：执行合同

以下为 AI IDE 应守的总操作合同（**每次被唤醒都执行一次循环**）：

### 4.1 身份与边界
- 工作目录 = `<ai-collab-root>`（即仓库根目录）；具体项目在 `PROJECTS/{project_id}/`。
- 只能执行 `ACTIONS.md` 允许 {ROLE} 的动作；禁止的动作一律不执行。
- 长任务开工前须先在 `CLAIMS/` 创建有效 ClaimLease（用 `TEMPLATES/ClaimTask.md`）。

### 4.2 交接规则
- 所有任务交付经 `HANDOFF/` 信封完成（从 `TEMPLATES/` 复制模板填写）。
- 信封字段须符合 `SCHEMAS/*.json` 定义；毋自造字段。
- 不修改他人已创建的信封——只追加新信封。

### 4.3 产物与证据
- 代码 / 报告写在真实工作目录（`PROJECTS/{project_id}/PROJECT.md` 的 `workspace_root`）。
- 黑板（`PROJECTS/{project_id}/BLACKBOARD.md`）只记：文件名 / 相对路径 / sha256 / 短摘要。绝不写内容。
- Runtime / Benchmark / RealProvider 证据写入 `EVIDENCE/`，须可复核。

### 4.4 心跳
- 每次循环结束后写心跳到 `HEARTBEAT/`：
  - 有定时器 → 写实际时间戳 + 状态；
  - 无定时器 → 写 `PassiveNoTimer` 或 `BatchComplete`。

### 4.5 红线（绝对不做）
- ❌ 不写密钥、Token、Cookie、真实隐私数据到任何文件。
- ❌ 不修改他人已创建的信封。
- ❌ 不自审自验（同一角色不能同时做实现+测试+验收）。
- ❌ 不用 UnitTest / SourceScan 冒充 Runtime 证据。
- ❌ 不在没有有效 ClaimLease 时占用长任务。
- ❌ 高风险裁决须写入 `AUDIT/`。

### 4.6 风险分级与自动闭环（v1.3 新增 / 方向 3 Phase 1）

> v1.5 确认（七步法裁决，真空期决策待社区复审）。Phase 1 是纯标注，不动现有流程。

每个动作有 `reversible` + `blast_radius` 标注（见 `ACTIONS.md` 风险标注表），推导出风险分级：

- **Low**（reversible + local）：actor 自动闭环，毋庸人工审批
- **Medium**（reversible + cross-file）：actor 闭环，但须在 `AUDIT/` 留痕
- **High**（不可逆 或 cross-repo）：须升级到人（`EscalateToHuman`）

**PATTERNS.md 读取自检**（v1.5 新增）：接入时确认已读 `PATTERNS.md`，知道可按需加载哪些推荐模式。只要求"已读"不要求"已用"。

## 步骤 5：按角色行动

根据所选角色，追加以下职责约束：

### SPEC
- **本职**：编写规范与 plan、编写面向各 AI IDE 的 prompt、维护规范本身、定义跨阶段接口、做最终验收、给冲突裁决建议。
- **禁止**：不写实现代码；不做独立初验（交 TEST）。

### IMPL
- **本职**：代码落地与自测自检。
- **禁止**：不验收自己的实现；修复只在 TEST 报告要求时按信封返回处理。

### TEST
- **本职**：独立初验——跑单测/对抗/回归，给出可复核证据与结论。
- **禁止**：不做修复（交回 IMPL）；不代替 SPEC 做最终验收。

### CONSULTANT
- **本职**：贯穿项目始终——提供方法建议、复核规范一致性、预警风险。对过程负责。
- **禁止**：不接管实现/测试/验收，只给建议与复核。

### QA
- **本职**：贯穿项目始终——监控质量门槛、核对证据强度、检查红线遵守。对过程负责。
- **禁止**：不实现、不测试，只监控与核查。

### WATCHDOG
- **本职**：扫描过期租约、缺证据、缺审计、状态冲突——只报告，不修复。
- **禁止**：不验收、不修改他人文件、不下发任务。

### 关于 HUMAN
`HUMAN` 是**人类最终裁决者**，不由 AI IDE 扮演，故不经本技能加载。当信封需人工 Accept/Reject 或冲突需人工仲裁时，由人类使用者处理，其职责见 README §3。

## 步骤 6：一次标准 Loop

AI IDE 被唤醒时，按此顺序执行：

```text
1. 读黑板 PROJECTS/{project_id}/BLACKBOARD.md → 确认当前阶段与最新 revision。
2. 扫描 HANDOFF/ → 找 to={ROLE} 且状态为 Submitted/Pending 的信封。
3. 扫描 CLAIMS/ → 确认自己的租约是否仍有效（续租或新建）。
4. 按 ROLE_{ROLE}.md 与 RUNBOOKS/ 做该做的事。
5. 用 TEMPLATES/ 模板写新信封到 HANDOFF/，更新 PROJECTS/{project_id}/BLACKBOARD.md 阶段。
6. 证据写 EVIDENCE/，高风险写 AUDIT/，刷新 HEARTBEAT/。
7. 循环结束。
```

### 6.1 plan 模式 Loop 分支（可选）

> 仅当 BLACKBOARD.md 顶部有 `active_plan` 指针且 plan 状态为 Active 时启用。无 plan 的项目走原 Loop。

plan 模式下，标准 Loop 步骤 2-4 替换为（详见 PLAN.md §八）：

1. 读 BLACKBOARD.md -> 确认 active_plan 指针
2. 读 {workspace}/plans/PLAN.md -> 找当前可执行 stage（depends_on 都到 gate_state）
3. 门控检查：上游 stage 是否到 gate_state？parallel_with 之外是否有 active claim 冲突？
4. 读 {workspace}/plans/S{N}/{role}_prompt.md（IMPL 读 impl_prompt.md，TEST 读 test_prompt.md，SPEC 读 acceptance.md，CONSULTANT 读 consultant_guide.md，QA 读 qa_checklist.md）
5. 按 prompt 的 Goal/Scope/Criteria 细化为具体动作
6. 写 ClaimTask（file_scope 从 prompt 直接复制，stage_scope 填 S{N}）
7. 执行 -> 写证据 -> 写信封 -> 更新黑板（只动自己 stage 行）-> 心跳

plan 生成阶段的唤醒句：`请作为 SPEC 生成 plan（目录：PROJECTS/{project_id}，需求文件：{workspace}/requirements.md）`

## 步骤 7：无定时器的唤醒句

若 AI IDE 不能自动定时唤醒，用户可随时发这句触发一次循环：

```text
请作为 {ROLE} 运行一次 ai-collab loop（目录：PROJECTS/{project_id}）
```

---

## 完成标记

本技能执行完毕后，AI IDE 应输出简短状态摘要，含：
- 已注册的角色与项目空间
- 当前黑板阶段
- 待处理的信封（如有）
- 下一步行动建议
