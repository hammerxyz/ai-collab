# AI-COLLAB 协作协议（CCP — Collaboration Communication Protocol）  *(Collaboration Protocol)*

> 版本：1.1 | 生效日期：2026-07-07（v1.1 整改升级）
> Version: 1.1 | Effective: 2026-07-07 (v1.1 remediation upgrade)
> 设计参考：CCP协作总线架构，纯 prompt 驱动，文件系统为总线
> Design: CCP collaboration-bus architecture, pure-prompt driven, filesystem as the bus

---

## 一、总则  *(I. General provisions)*

### 1.1 目的  *(Purpose)*

建立多 AI IDE 之间的结构化协作协议，使多方 AI IDE 能通过文件系统实现：

Establish a structured collaboration protocol among multiple AI IDEs, so they can, via the filesystem, achieve:

- 任务分配与认领
- task allocation and claiming
- 产出交付与验收
- deliverable handoff and acceptance
- 状态同步与审计追溯
- state sync and audit traceability
- 冲突检测与解决
- conflict detection and resolution

### 1.2 核心原则  *(Core principles)*

| 原则 | 说明 | 设计参照 |
|------|------|-----------|
| 总线唯一 | 所有协作必须通过 `ai-collab/` 目录，禁止私下直连 | CCP铁律 |
| 信封结构 | 所有交付物必须使用标准 Envelope 格式 | CBB标准动作 |
| 状态可追踪 | 任何状态变迁和每轮工作收尾必须在项目 BLACKBOARD.md 中记录，最新条目置顶 | 幽灵状态禁止 |
| 审计无死角 | 高风险操作必须写入 AUDIT/ 目录 | 审计强制 |
| 三权分离 | 规范/实现/验收由不同方负责，禁止自审自 | 执行/目标/监管分离 |

| Principle | Description | Design reference |
|-----------|-------------|------------------|
| Single bus | All collaboration must go through the `ai-collab/` directory; no private peer-to-peer | CCP iron rule |
| Envelope structure | All deliverables must use the standard Envelope format | CBB standard action |
| Traceable state | Any state change and every round's wrap-up must be recorded in the project BLACKBOARD.md, newest on top | No ghost state |
| Audit everywhere | High-risk operations must be written to AUDIT/ | Mandatory audit |
| Three powers separated | Spec / implement / accept owned by different parties; no self-verify | Execute / goal / oversee separated |

### 1.3 协作方定义  *(Collaborator definitions)*

| 角色 | AI IDE | 职责域 | 简称 |
|------|--------|--------|------|
| 规范规划+验收 | AI IDE | 规范编写、计划制定、最终验收、跨阶段接口定义 | SPEC |
| 代码实现+自检 | AI IDE | 代码实现、单元测试、自检报告、STUB消除 | IMPL |
| 测试初验 | AI IDE | 黑盒白盒测试、阶段初验、对抗性测试、回归测试 | TEST |

| Role | AI IDE | Duty scope | Short |
|------|--------|-----------|-------|
| Spec & acceptance | AI IDE | Spec writing, planning, final acceptance, cross-stage interface definition | SPEC |
| Implement & self-check | AI IDE | Code implementation, unit tests, self-check report, STUB removal | IMPL |
| Test first-verification | AI IDE | Black/white-box tests, stage first-verification, adversarial & regression tests | TEST |

> 注：v1.1 另增 `CONSULTANT`（把控走势）、`QA`（过程质量审视）、`WATCHDOG`（健康检查）、`HUMAN`（最终裁决），详见 README §3。
> *Note: v1.1 also adds `CONSULTANT` (steering), `QA` (process quality), `WATCHDOG` (health check), `HUMAN` (final ruling); see README §3.*

---

## 二、目录结构  *(II. Directory structure)*

```
<ai-collab>
├── PROTOCOL.md          # 本文件 — 协作协议
├── ACTIONS.md           # 标准协作动作（CBB）
├── STRUCTURE.md         # 目录结构边界：根目录管协议，项目子目录管操作
├── PROJECTS/            # 多项目空间、项目登记、actor登记
│   └── {project_id}/
│       ├── PROJECT.md
│       ├── ACTORS.md
│       ├── BLACKBOARD.md
│       ├── HANDOFF/
│       ├── CLAIMS/
│       ├── HEARTBEAT/
│       ├── EVIDENCE/
│       └── AUDIT/
├── HANDOFF/             # 根级占位目录，不承接具体项目任务
├── CLAIMS/              # 根级占位目录，不承接具体项目任务
├── HEARTBEAT/           # 根级占位目录，不承接具体项目任务
├── EVIDENCE/            # 根级占位目录，不承接具体项目任务
├── AUDIT/               # 根级占位目录，不承接具体项目任务
├── RUNBOOKS/            # 角色运行手册
├── TEMPLATES/           # 标准信封/租约/审计模板
├── TIMER_LOOP.md        # 定时器驱动协作循环
├── ORDERING.md          # 读写顺序、依赖、revision控制
├── MONITOR/             # 可选browser只读监控机制
└── WATCHDOG.md          # 超时、冲突、孤儿任务检查
```

```
<ai-collab>
├── PROTOCOL.md          # This file — collaboration protocol
├── ACTIONS.md           # Standard collaboration actions (CBB)
├── STRUCTURE.md         # Directory boundary: root owns protocol; project subdirs own ops
├── PROJECTS/            # Multi-project space, project & actor registry
│   └── {project_id}/
│       ├── PROJECT.md
│       ├── ACTORS.md
│       ├── BLACKBOARD.md
│       ├── HANDOFF/
│       ├── CLAIMS/
│       ├── HEARTBEAT/
│       ├── EVIDENCE/
│       └── AUDIT/
├── HANDOFF/             # Root-level placeholder; holds no concrete project tasks
├── CLAIMS/              # Root-level placeholder; holds no concrete project tasks
├── HEARTBEAT/           # Root-level placeholder; holds no concrete project tasks
├── EVIDENCE/            # Root-level placeholder; holds no concrete project tasks
├── AUDIT/               # Root-level placeholder; holds no concrete project tasks
├── RUNBOOKS/            # Role runbooks
├── TEMPLATES/           # Standard envelope / lease / audit templates
├── TIMER_LOOP.md        # Timer-driven collaboration loop
├── ORDERING.md          # Read/write order, dependencies, revision control
├── MONITOR/             # Optional browser read-only monitor
└── WATCHDOG.md          # Timeout, conflict, orphan-task checks
```

### 2.1 多项目空间  *(Multi-project space)*

根目录下的 `HANDOFF/`、`CLAIMS/`、`HEARTBEAT/`、`EVIDENCE/`、`AUDIT/` 是全局占位目录，不保留具体项目情况。所有具体项目任务必须使用 `PROJECTS/{project_id}/`。

The root-level `HANDOFF/`, `CLAIMS/`, `HEARTBEAT/`, `EVIDENCE/`, `AUDIT/` are global placeholders holding no concrete project state. All concrete project tasks must use `PROJECTS/{project_id}/`.

`project_id` 由项目短名和工作目录路径指纹组成。AI IDE 在处理任务前必须确认：

`project_id` is composed of the project short name and a working-directory path fingerprint. Before handling a task, an AI IDE must confirm:

1. 当前工作目录位于 `PROJECTS/{project_id}/PROJECT.md` 声明的 `workspace_root` 下；
1. The current working directory is under `workspace_root` declared in `PROJECTS/{project_id}/PROJECT.md`;
2. 当前 actor 已登记在 `PROJECTS/{project_id}/ACTORS.md`；
2. The current actor is registered in `PROJECTS/{project_id}/ACTORS.md`;
3. actor 的角色、过期时间、路径指纹与当前任务匹配；
3. The actor's role, expiry, and path fingerprint match the current task;
4. 只扫描和处理该项目空间中的信封、租约、心跳、证据和审计。
4. Only scan and process that project space's envelopes, leases, heartbeats, evidence, and audit.

项目产出物必须保留在实际 `workspace_root` 中。黑板只能记录文件名、相对路径、hash、状态和短摘要，不得保存完整产出物正文。

Project deliverables must stay in the real `workspace_root`. The blackboard may only record file name, relative path, hash, state, and short summary — never full deliverable bodies.

项目黑板是必写控制面入口。任何角色完成工作、提交结果、完成测试/裁决、发现阻塞或只做状态同步时，都必须更新 `BLACKBOARD.md`。最新黑板条目必须置顶，采用 newest-first；不得把新状态只追加到文件尾部导致其他角色漏读。

The project blackboard is the mandatory control-plane entry. Any role finishing work, submitting a result, completing a test/ruling, finding a block, or just syncing state must update `BLACKBOARD.md`. Newest entries on top (newest-first); never append new state only to the file tail where later roles would miss it.

### 2.2 根目录与项目目录边界  *(Root vs. project boundary)*

| 层级 | 允许内容 | 不应内容 |
|---|---|---|
| 根目录 | 协议、动作、模板、角色手册、全局监控、空占位目录 | 任何具体项目的活跃 handoff、claim、evidence、audit、blackboard |
| `PROJECTS/{project_id}/` | 项目登记、actor登记、项目黑板、项目 handoff/claim/heartbeat/evidence/audit | 完整代码、完整报告、大段日志、密钥 |
| 实际项目工作目录 | 代码、计划、报告、测试输出、benchmark、真实运行证据 | 跨 AI IDE 控制面状态 |

| Tier | Allowed | Not allowed |
|---|---|---|
| Root | Protocols, actions, templates, role runbooks, global monitor, empty placeholders | Any active project handoff/claim/evidence/audit/blackboard |
| `PROJECTS/{project_id}/` | Project & actor registry, project blackboard, project handoff/claim/heartbeat/evidence/audit | Full code, full reports, long logs, secrets |
| Real project working dir | Code, plans, reports, test output, benchmark, real runtime evidence | Cross-AI-IDE control-plane state |

AI IDE 如果发现根目录存在具体项目文件，应停止处理根目录文件，要求迁移到对应 `PROJECTS/{project_id}/`，并通过项目 WATCHDOG 或 SPEC/HUMAN 记录结构偏差。

If an AI IDE finds concrete project files at the root, it should stop processing root files, ask for migration to the proper `PROJECTS/{project_id}/`, and record the structural deviation via the project WATCHDOG or SPEC/HUMAN.

---

## 三、信封格式（Envelope）  *(III. Envelope format)*

所有跨方交付物必须使用以下 Markdown 信封格式：

All cross-party deliverables must use the following Markdown envelope format:

信封只在有需要其他角色处理、确认、复验、裁决或知会的重要事项时创建。信封 Header 的 `to` 和正文每个请求段落必须明确处理对象；如果正文提到某个 actor/role 的待办，该 actor/role 读取信封时必须处理，不得以"不是单独发给我"为由忽略。若自身工作已完成且没有更多通知内容，允许只更新 `BLACKBOARD.md`，不创建空信封。

Create an envelope only when there is an important item needing another role to handle / confirm / re-verify / rule / be notified. The header `to` and each request paragraph in the body must name the handler; if the body mentions a todo for an actor/role, that actor/role must handle it on reading and may not ignore it as "not sent only to me". If your own work is done and there is nothing more to notify, updating `BLACKBOARD.md` alone is allowed — no empty envelope.

```markdown
# Envelope: {ENVELOPE_ID}

## Header
- protocol_version: {协议版本，如 v1.1}
- envelope_id: {UUID或唯一标识}
- trace_id: {任务级追踪ID，同一任务所有信封共享}
- causation_id: {上游信封envelope_id，无则填none}
- project_id: {项目空间ID，可选；多项目模式必填}
- sequence_no: {项目内递增序号，可选}
- depends_on: {前置信封ID列表，可选}
- supersedes: {被替代信封ID列表，可选}
- requires_blackboard_revision: {读取时的黑板revision，可选}
- stage: {S2_3A / S2_4 / S3_1 等}
- from: {SPEC / IMPL / TEST}
- to: {SPEC / IMPL / TEST}
- action: {标准动作名，见ACTIONS.md}
- message_type: {Command / Response / Event / Query / Veto / ApprovalRequest / ApprovalDecision}
- priority: {P0 / P1 / P2}
- risk_level: {Low / Medium / High}
- reversibility: {Reversible / Irreversible / NeedsHuman}
- requires_audit: {false / true}
- created_at: {ISO8601时间戳}
- expires_at: {ISO8601，可选}
- summary: {一句话自然语言摘要，供接收方一眼理解}

## Payload
{交付物正文}

## Evidence
- 佐证文件路径列表

## Status
- current: {Draft / Submitted / Accepted / Rejected / Conditional / Blocked}
- updated_at: {ISO8601}
- updated_by: {SPEC / IMPL / TEST}

## Audit
- 变更记录列表
```

```markdown
# Envelope: {ENVELOPE_ID}

## Header
- protocol_version: {protocol version, e.g. v1.1}
- envelope_id: {UUID or unique id}
- trace_id: {task-level trace id, shared by all envelopes of one task}
- causation_id: {upstream envelope_id, or none}
- project_id: {project space id, optional; required in multi-project mode}
- sequence_no: {in-project incrementing sequence, optional}
- depends_on: {list of prerequisite envelope ids, optional}
- supersedes: {list of superseded envelope ids, optional}
- requires_blackboard_revision: {blackboard revision at read time, optional}
- stage: {S2_3A / S2_4 / S3_1 etc.}
- from: {SPEC / IMPL / TEST}
- to: {SPEC / IMPL / TEST}
- action: {standard action name, see ACTIONS.md}
- message_type: {Command / Response / Event / Query / Veto / ApprovalRequest / ApprovalDecision}
- priority: {P0 / P1 / P2}
- risk_level: {Low / Medium / High}
- reversibility: {Reversible / Irreversible / NeedsHuman}
- requires_audit: {false / true}
- created_at: {ISO8601 timestamp}
- expires_at: {ISO8601, optional}
- summary: {one-line natural-language summary for the receiver}

## Payload
{deliverable body}

## Evidence
- list of evidence file paths

## Status
- current: {Draft / Submitted / Accepted / Rejected / Conditional / Blocked}
- updated_at: {ISO8601}
- updated_by: {SPEC / IMPL / TEST}

## Audit
- list of change records
```

> **向后兼容声明**：新字段对历史信封可选（字段缺失填 none），不强制回填。新信封自本规范发布后强制遵守全部字段。
> *Backward-compatibility: new fields are optional for legacy envelopes (use `none` when missing); no forced backfill. New envelopes must comply with all fields from this spec's release.*
>
> **版本自愈规则（v1.1 补丁）**：读取到不含 `protocol_version` 字段的信封，视为 v1.0 遗留信封。actor 在下次改写或转发该事项时，按当前协议版本（v1.1）全字段重新发出，并在 `supersedes` 字段引用原信封 ID。此规则使升级从"靠人提示"变为"自愈"——无需运行时或扫描脚本，下一个碰它的 actor 自动完成升级。
> *Version self-heal (v1.1 patch): an envelope without `protocol_version` is treated as a v1.0 legacy. When an actor next rewrites or forwards that item, it re-emits it with all fields at the current version (v1.1) and references the original id in `supersedes`. This turns upgrades from "human-reminded" into "self-healing" — no runtime or scanner needed; the next actor to touch it upgrades automatically.*

### 3.1 信封命名规则  *(Envelope naming)*

文件名格式：`{STAGE}_{FROM}_TO_{TO}_{TIMESTAMP}.md`

File name format: `{STAGE}_{FROM}_TO_{TO}_{TIMESTAMP}.md`

示例：
Examples:
- `S2_3A_IMPL_TO_TEST_20260613T193000.md` — IMPL向TEST提交S2_3A实现
- `S2_3A_IMPL_TO_TEST_20260613T193000.md` — IMPL submits S2_3A implementation to TEST
- `S2_4_SPEC_TO_IMPL_20260613T200000.md` — SPEC向IMPL下发S2_4规范
- `S2_4_SPEC_TO_IMPL_20260613T200000.md` — SPEC issues S2_4 spec to IMPL

### 3.2 信封生命周期  *(Envelope lifecycle)*

```
Draft → Submitted → Accepted / Rejected / Conditional / Blocked
                         │
                         ├→ Accepted → 交付完成
                         ├→ Rejected → 回到Draft，附拒绝理由
                         ├→ Conditional → 附条件，需补充后重新提交
                         └→ Blocked → 外部依赖阻塞，记录阻塞原因
```

```
Draft → Submitted → Accepted / Rejected / Conditional / Blocked
                         │
                         ├→ Accepted → delivery done
                         ├→ Rejected → back to Draft with reason
                         ├→ Conditional → conditional; resubmit after supplement
                         └→ Blocked → external dependency blocks; record cause
```

### 3.3 message_type 语义约束  *(message_type semantics)*

信封 Header 的 `message_type` 字段约束信封的语义角色与流转行为。各类型含义如下：

The header `message_type` constrains an envelope's semantic role and flow. Meanings:

| 类型 | 含义 | 是否必须回应 | 典型动作 |
|------|------|------------|---------|
| Command | 要求对方执行动作 | 是 | IssueSpec, SubmitImpl, SubmitTestReport |
| Response | 对 Command 的回执 | 否 | AcceptStage, RejectStage, Conditional |
| Event | 通知"已发生"的事实 | 否 | ResolveBlock, DeclareConflict, 通告类 |
| Query | 只读查询，不产生副作用 | 是（只读回答） | RequestSpecClarification |
| Veto | 否决/阻断 | 否（生效即终态） | DeclareConflict |
| ApprovalRequest | 请求人类/SPEC 审批 | 是（待审批） | 高风险变更请求 |
| ApprovalDecision | 审批决定 | 否 | AcceptStage, 人类裁决 |

| Type | Meaning | Must respond? | Typical actions |
|------|---------|---------------|-----------------|
| Command | demands the receiver act | Yes | IssueSpec, SubmitImpl, SubmitTestReport |
| Response | receipt for a Command | No | AcceptStage, RejectStage, Conditional |
| Event | notifies a fact that "happened" | No | ResolveBlock, DeclareConflict, notices |
| Query | read-only, no side effects | Yes (read-only answer) | RequestSpecClarification |
| Veto | veto / block | No (terminal once effective) | DeclareConflict |
| ApprovalRequest | asks human/SPEC to approve | Yes (pending) | high-risk change request |
| ApprovalDecision | approval decision | No | AcceptStage, human ruling |

**硬约束** *(Hard constraints)*：
- Query 绝不允许写副作用；
- Query must never have side effects;
- Event 不承担动作审批；
- Event carries no action approval;
- Command 必须有明确 `to`；
- Command must have an explicit `to`;
- Veto 优先级高于普通 Command；
- Veto outranks a normal Command;
- ApprovalRequest 必须带风险理由和变更预览。
- ApprovalRequest must carry a risk reason and a change preview.

---

## 四、协作流程  *(IV. Collaboration flow)*

### 4.1 标准流程（规范→实现→测试→验收）  *(Standard flow: spec → implement → test → accept)*

```
┌─────────┐    ①下发规范     ┌─────────┐    ②提交实现     ┌─────────┐
│  SPEC   │ ──────────────→ │  IMPL   │ ──────────────→ │  TEST   │
│(AI IDE)  │                  │ (AI IDE)  │                  │ (AI IDE)  │
└─────────┘                  └─────────┘                  └─────────┘
     ↑                            │                            │
     │       ④最终验收            │     ③初验报告              │
     └────────────────────────────┴────────────────────────────┘
```

```
┌─────────┐  ① issue spec   ┌─────────┐  ② submit impl  ┌─────────┐
│  SPEC   │ ──────────────→ │  IMPL   │ ──────────────→ │  TEST   │
└─────────┘                  └─────────┘                  └─────────┘
     ↑                            │                            │
     │     ④ final accept         │     ③ test report          │
     └────────────────────────────┴────────────────────────────┘
```

**① SPEC 下发规范** *(SPEC issues spec)*
- SPEC 在 `HANDOFF/` 创建信封，action=`IssueSpec`
- SPEC creates an envelope in `HANDOFF/`, action=`IssueSpec`
- IMPL 读取信封，在 `CLAIMS/` 创建认领记录
- IMPL reads it and creates a claim in `CLAIMS/`

**② IMPL 提交实现** *(IMPL submits implementation)*
- IMPL 完成代码+单元测试+自检报告
- IMPL completes code + unit tests + self-check report
- IMPL 在 `HANDOFF/` 创建信封，action=`SubmitImpl`
- IMPL creates an envelope in `HANDOFF/`, action=`SubmitImpl`
- TEST 读取信封，执行测试
- TEST reads it and runs tests

**③ TEST 初验报告** *(TEST first-verification report)*
- TEST 执行黑盒+白盒测试
- TEST runs black + white box tests
- TEST 在 `HANDOFF/` 创建信封，action=`SubmitTestReport`
- TEST creates an envelope in `HANDOFF/`, action=`SubmitTestReport`
- TEST 更新 BLACKBOARD.md 中对应阶段状态
- TEST updates the stage state in BLACKBOARD.md

**④ SPEC 最终验收** *(SPEC final acceptance)*
- SPEC 读取 IMPL 交付物 + TEST 初验报告
- SPEC reads IMPL deliverable + TEST first-verification report
- SPEC 在 `HANDOFF/` 创建信封，action=`AcceptStage` 或 `RejectStage`
- SPEC creates an envelope in `HANDOFF/`, action=`AcceptStage` or `RejectStage`
- SPEC 更新 BLACKBOARD.md
- SPEC updates BLACKBOARD.md

### 4.2 异常流程  *(Exception flow)*

**阻塞（Blocked）** *(Blocked)*
- 任何方发现外部依赖缺失，创建 action=`DeclareBlock` 信封
- Any party finding a missing external dependency creates an action=`DeclareBlock` envelope
- BLACKBOARD.md 中标记阶段为 Blocked
- Mark the stage Blocked in BLACKBOARD.md
- 阻塞解除后，由发现方创建 action=`ResolveBlock` 信封
- After unblocking, the finder creates an action=`ResolveBlock` envelope

**条件通过（Conditional）** *(Conditional pass)*
- TEST 发现非关键缺失，给出 Conditional 评定
- TEST finds a non-critical gap and gives a Conditional rating
- IMPL 在约定时间内补充，或 SPEC 明确接受条件
- IMPL supplements within the agreed time, or SPEC explicitly accepts the condition

**冲突（Conflict）** *(Conflict)*
- 两方对同一交付物有矛盾判断
- Two parties disagree on the same deliverable
- 创建 action=`DeclareConflict` 信封
- Create an action=`DeclareConflict` envelope
- 由人类裁决，SPEC 执行裁决结果
- Human rules; SPEC executes the ruling

### 4.3 回退流程  *(Rollback flow)*

- IMPL 发现实现无法满足规范，创建 action=`RequestSpecClarification` 信封
- IMPL finds the implementation cannot meet the spec; creates action=`RequestSpecClarification`
- TEST 发现测试无法执行，创建 action=`RequestImplFix` 信封
- TEST finds tests cannot run; creates action=`RequestImplFix`
- 任何回退必须在 AUDIT/ 中记录原因和影响范围
- Any rollback must record cause and impact scope in AUDIT/

---

## 五、BLACKBOARD.md 状态模型  *(V. BLACKBOARD.md state model)*

### 5.1 阶段状态  *(Stage states)*

| 状态 | 含义 | 可转换到 |
|------|------|---------|
| Planned | 规划中，无代码 | SpecIssued, Blocked |
| SpecIssued | 规范已下发 | InProgress, Blocked |
| InProgress | 实现进行中 | ImplSubmitted, Blocked |
| ImplSubmitted | 实现已提交测试 | Testing, Blocked |
| Testing | 测试进行中 | TestReported, Blocked |
| TestReported | 测试报告已提交 | Accepted, Conditional, Rejected |
| Accepted | 验收通过 | Frozen |
| Conditional | 条件通过 | Accepted, Rejected |
| Rejected | 验收不通过 | InProgress（回退） |
| Blocked | 阻塞 | 任何非Frozen状态 |
| Frozen | 冻结（不可修改） | — |
| Superseded | 被新信封/人类指令取代 | — |
| Withdrawn | 发起方撤回，需记录原因 | — |
| Expired | TTL 超时且未续约 | SpecIssued, Blocked |
| NeedsClarification | 等待规范澄清 | SpecIssued, Blocked |

| State | Meaning | Transitions to |
|-------|---------|----------------|
| Planned | planned, no code | SpecIssued, Blocked |
| SpecIssued | spec issued | InProgress, Blocked |
| InProgress | implementing | ImplSubmitted, Blocked |
| ImplSubmitted | implementation submitted to test | Testing, Blocked |
| Testing | testing | TestReported, Blocked |
| TestReported | test report submitted | Accepted, Conditional, Rejected |
| Accepted | accepted | Frozen |
| Conditional | conditional pass | Accepted, Rejected |
| Rejected | not accepted | InProgress (rollback) |
| Blocked | blocked | any non-Frozen state |
| Frozen | frozen (immutable) | — |
| Superseded | replaced by newer envelope / human instruction | — |
| Withdrawn | withdrawn by issuer, reason required | — |
| Expired | TTL elapsed, not renewed | SpecIssued, Blocked |
| NeedsClarification | awaiting spec clarification | SpecIssued, Blocked |

### 5.2 BLACKBOARD.md 更新规则  *(Update rules)*

- 任何状态变更必须立即更新 BLACKBOARD.md
- Any state change must immediately update BLACKBOARD.md
- 每轮工作收尾也必须更新 BLACKBOARD.md，即使没有新信封。
- Every round's wrap-up must update BLACKBOARD.md, even with no new envelope.
- 最新更新必须置顶写在文件头部；黑板采用 newest-first。不得把最新状态只写到文件尾部。
- Newest updates go on top (newest-first); never write new state only to the file tail.
- 更新必须附时间戳和操作方
- Updates must carry a timestamp and the actor
- 禁止删除历史状态记录，只允许追加
- Never delete historical state; append only
- High risk 状态变更（Accepted/Rejected/Frozen）必须同步写入 AUDIT/
- High-risk changes (Accepted/Rejected/Frozen) must also be written to AUDIT/
- 顶部状态总览是可更新快照；状态变更历史必须追加，不能删除或改写既有历史行。
- The top overview is an updatable snapshot; history is append-only, never deleted or rewritten.
- 定时器驱动协作必须遵守 `TIMER_LOOP.md`、`HEARTBEAT/README.md`、`SCHEMAS/claim.schema.json` 和 `WATCHDOG.md`。
- Timer-driven collaboration must follow `TIMER_LOOP.md`, `HEARTBEAT/README.md`, `SCHEMAS/claim.schema.json`, and `WATCHDOG.md`.
- 多项目模式下，项目黑板必须包含 `project_id` 和 `blackboard_revision`。写入前必须重新读取最新 revision；如果 revision 变化，应按 `ORDERING.md` 重新判断或声明冲突。
- In multi-project mode the blackboard must include `project_id` and `blackboard_revision`. Re-read the latest revision before writing; if it changed, re-judge per `ORDERING.md` or declare a conflict.
- 黑板是控制面索引，只能记录项目产出物文件名、相对路径、hash、状态和短摘要。完整产出物必须保留在项目工作目录中。
- The blackboard is a control-plane index; it may only record deliverable file name, relative path, hash, state, short summary. Full deliverables stay in the project working dir.
- 如果没有需要其他角色处理的事项，允许只挂黑板，不发信封；如果发信封，则必须明确每个处理事项的对象和期望动作。
- If nothing needs other roles, update the board only, no envelope; if you send an envelope, name each item's handler and expected action.

### 5.3 黑板三段式格式规范（v1.1 新增）  *(Three-part blackboard format — new in v1.1)*

黑板必须采用三段式结构，确保各 actor 写法统一、接收方扫描高效：

The blackboard must use a three-part structure so every actor writes uniformly and receivers scan efficiently:

```markdown
# BLACKBOARD — {project_id}

## Current State（状态总览，可更新快照）
- project_id: {ID}
- blackboard_revision: {递增整数}
- current_stage: {当前阶段}
- current_status: {当前状态}
- updated_at: {ISO8601}
- updated_by: {actor}
- active_claims: {活跃租约ID列表，或none}
- blockers: {当前阻塞项，或none}

## Latest Entries（最新条目，置顶，最多保留 20 条）

### [{ISO8601}] {actor} — {action} — {message_type}
- envelope_id: {关联信封ID，或BLACKBOARD_ONLY}
- trace_id: {任务追踪ID}
- stage: {阶段}
- status: {状态}
- summary: {一句话摘要，≤120字}
- evidence_ref: {证据路径 + sha8，或none}
- audit_ref: {审计路径，或none}

### [{上一条}] ...

## History（历史归档索引，只追加不删）
- [{ISO8601}] {actor} {action} {stage} → {status} | env:{envelope_id} | 详情见 BLACKBOARD_ARCHIVE/{file}
- ...
```

```markdown
# BLACKBOARD — {project_id}

## Current State (overview, updatable snapshot)
- project_id: {ID}
- blackboard_revision: {incrementing integer}
- current_stage: {current stage}
- current_status: {current status}
- updated_at: {ISO8601}
- updated_by: {actor}
- active_claims: {active lease id list, or none}
- blockers: {current blockers, or none}

## Latest Entries (newest on top, max 20)
### [{ISO8601}] {actor} — {action} — {message_type}
- envelope_id: {related envelope id, or BLACKBOARD_ONLY}
- trace_id: {task trace id}
- stage: {stage}
- status: {status}
- summary: {one-line summary, ≤120 chars}
- evidence_ref: {evidence path + sha8, or none}
- audit_ref: {audit path, or none}

### [{previous entry}] ...

## History (archive index, append-only)
- [{ISO8601}] {actor} {action} {stage} → {status} | env:{envelope_id} | details in BLACKBOARD_ARCHIVE/{file}
- ...
```

**格式硬约束** *(Hard format constraints)*：

1. Latest Entries 区最多保留 20 条：超过的迁移到项目级 `BLACKBOARD_ARCHIVE/`，黑板保持精简。
1. Latest Entries keeps at most 20; overflow migrates to project-level `BLACKBOARD_ARCHIVE/`, keeping the board concise.
2. 每条 entry 必须有固定 8 个字段：envelope_id/trace_id/stage/status/summary/evidence_ref/audit_ref + 时间戳行。不允许自由发挥。字段缺失填 `none`，不留空。
2. Each entry must have the fixed 8 fields: envelope_id/trace_id/stage/status/summary/evidence_ref/audit_ref + a timestamp line. No free-form. Missing field = `none`, never blank.
3. summary ≤ 120 字：只写关键词和语义锚点，不写正文。
3. summary ≤ 120 chars: keywords and semantic anchors only, no body.
4. evidence_ref 只写路径+sha8：不抄证据内容。
4. evidence_ref is path + sha8 only: never copy evidence content.
5. Current State 是快照可覆盖；Latest Entries 和 History 是追加式不可删。
5. Current State is an overwritable snapshot; Latest Entries and History are append-only.
6. 归档规则：Latest Entries 超 20 条时，最旧的迁入 `BLACKBOARD_ARCHIVE/{start}_{end}_{sha8}.md`，并在 History 追加索引行。
6. Archive rule: when Latest Entries exceeds 20, the oldest moves to `BLACKBOARD_ARCHIVE/{start}_{end}_{sha8}.md` and History gains an index line.
7. **上限自执行规则（v1.1 补丁）**：actor 读取黑板时若发现 Latest Entries 超过 20 条，必须先归档最旧条目到 `BLACKBOARD_ARCHIVE/` 再写入新条目。此规则使黑板上限从"靠自觉遵守"变为"下一个碰黑板的 actor 自动维持"——无需运行时或定时扫描，升级自然发生且不反弹。
7. **Self-enforcing cap (v1.1 patch)**: when an actor reads the board and finds Latest Entries over 20, it must archive the oldest to `BLACKBOARD_ARCHIVE/` before writing the new entry. This turns the cap from "voluntary" into "the next actor to touch the board maintains it automatically" — no runtime or timer scan, upgrades happen naturally and don't regress.

> 注：各项目现有黑板的瘦身执行属于项目层事务，由各项目 SPEC 决策时机。平台只定义格式规范。
> *Note: slimming down each project's existing blackboard is a project-layer matter, timed by each project's SPEC. The platform only defines the format.*

---

## 六、审计规则  *(VI. Audit rules)*

### 6.1 必须审计的操作  *(Operations that must be audited)*

| 操作 | 风险级别 | 审计要求 |
|------|---------|---------|
| AcceptStage | High | 必须写入AUDIT/，附SPEC签名 |
| RejectStage | High | 必须写入AUDIT/，附拒绝理由 |
| DeclareBlock | Medium | 必须写入AUDIT/，附阻塞原因 |
| ResolveBlock | Medium | 必须写入AUDIT/，附解除方式 |
| DeclareConflict | High | 必须写入AUDIT/，附冲突描述 |
| Frozen | High | 必须写入AUDIT/，附冻结范围 |

| Operation | Risk | Audit requirement |
|-----------|------|-------------------|
| AcceptStage | High | Must write AUDIT/ with SPEC signature |
| RejectStage | High | Must write AUDIT/ with rejection reason |
| DeclareBlock | Medium | Must write AUDIT/ with block cause |
| ResolveBlock | Medium | Must write AUDIT/ with resolution method |
| DeclareConflict | High | Must write AUDIT/ with conflict description |
| Frozen | High | Must write AUDIT/ with freeze scope |

### 6.2 审计日志格式  *(Audit log format)*

```markdown
# Audit: {AUDIT_ID}

- timestamp: {ISO8601}
- actor: {SPEC / IMPL / TEST}
- action: {动作名}
- stage: {阶段名}
- risk_level: {Low / Medium / High}
- details: {详细描述}
- evidence_refs: {佐证文件路径列表}
```

```markdown
# Audit: {AUDIT_ID}

- timestamp: {ISO8601}
- actor: {SPEC / IMPL / TEST}
- action: {action name}
- stage: {stage name}
- risk_level: {Low / Medium / High}
- details: {detailed description}
- evidence_refs: {list of evidence file paths}
```

---

## 七、禁止行为  *(VII. Prohibited acts)*

### 7.1 绝对禁止  *(Absolutely forbidden)*

| # | 禁止行为 | 理由 |
|---|---------|------|
| 1 | 跳过信封直接交付 | 绕过总线，无法追踪 |
| 2 | 自审自（IMPL自己验收自己的实现） | 三权分离 |
| 3 | 删除AUDIT/中的记录 | 审计不可篡改 |
| 4 | 删除BLACKBOARD.md中的历史状态 | 状态不可逆 |
| 5 | 修改他人创建的信封内容 | 不可变标识 |
| 6 | 在信封外传递敏感信息（密钥/Token） | 安全红线 |
| 7 | 未经SPEC批准修改规范定义 | 规范权归SPEC |
| 8 | 未经TEST初验直接标记Accepted | 验收权归SPEC+TEST |
| 9 | 定时器绕过角色权限自动验收/冻结 | 三权分离 |
| 10 | 长时间占用任务不声明（建议写 ClaimLease，v1.1 降级为可选） | 防止幽灵执行 |
| 11 | 未确认 project_id 和 actor 登记就处理项目任务 | 防止跨项目误处理 |
| 12 | 将完整项目产出物正文写入 BLACKBOARD.md | 控制面与产出物分离 |
| 13 | 跳过 depends_on / sequence_no / revision 顺序要求 | 防止乱序执行 |

| # | Prohibited act | Reason |
|---|----------------|--------|
| 1 | Deliver without an envelope | Bypasses the bus, untraceable |
| 2 | Self-verify (IMPL accepts its own implementation) | Three powers separated |
| 3 | Delete records in AUDIT/ | Audit is immutable |
| 4 | Delete historical state in BLACKBOARD.md | State is irreversible |
| 5 | Modify another actor's envelope content | Immutable identity |
| 6 | Pass sensitive info (keys/tokens) outside envelopes | Security red line |
| 7 | Change spec definition without SPEC approval | Spec authority belongs to SPEC |
| 8 | Mark Accepted without TEST first-verification | Acceptance belongs to SPEC+TEST |
| 9 | Timer bypasses role permission to auto-accept/freeze | Three powers separated |
| 10 | Hold a task long without declaring (write a ClaimLease; downgraded to optional in v1.1) | Prevent ghost execution |
| 11 | Handle project tasks before confirming project_id and actor registration | Prevent cross-project mishandling |
| 12 | Write full deliverable bodies into BLACKBOARD.md | Control plane separate from deliverables |
| 13 | Skip depends_on / sequence_no / revision ordering | Prevent out-of-order execution |

### 7.2 强烈不建议  *(Strongly discouraged)*

| # | 行为 | 原因 |
|---|------|------|
| 1 | IMPL在SPEC下发规范前开始实现 | 可能偏离规范 |
| 2 | TEST在IMPL提交前开始测试 | 浪费算力 |
| 3 | 同时修改同一文件 | 冲突风险 |
| 4 | Conditional超过3轮未解决 | 效率损失 |

| # | Behavior | Cause |
|---|---------|-------|
| 1 | IMPL starts implementing before SPEC issues the spec | May diverge from spec |
| 2 | TEST starts testing before IMPL submits | Wastes compute |
| 3 | Editing the same file concurrently | Conflict risk |
| 4 | Conditional unresolved beyond 3 rounds | Efficiency loss |

---

## 八、冲突解决  *(VIII. Conflict resolution)*

### 8.1 冲突类型  *(Conflict types)*

| 类型 | 示例 | 解决方 |
|------|------|--------|
| 规范冲突 | SPEC两份规范互相矛盾 | 人类裁决 |
| 实现冲突 | IMPL实现与规范不一致 | SPEC判定 |
| 测试冲突 | TEST初验结果与IMPL自检不一致 | 人类裁决 |
| 状态冲突 | BLACKBOARD状态与实际不符 | 发现方修正+AUDIT记录 |

| Type | Example | Resolver |
|------|---------|----------|
| Spec conflict | Two SPEC specs contradict | Human ruling |
| Impl conflict | IMPL implementation mismatches spec | SPEC judgment |
| Test conflict | TEST first-verification disagrees with IMPL self-check | Human ruling |
| State conflict | BLACKBOARD state mismatches reality | Finder corrects + AUDIT record |

### 8.2 解决流程  *(Resolution flow)*

1. 发现方创建 `DeclareConflict` 信封
1. Finder creates a `DeclareConflict` envelope
2. 在 AUDIT/ 记录冲突详情
2. Record conflict details in AUDIT/
3. 人类裁决（必要时）
3. Human ruling (if needed)
4. 裁决结果写入信封和 AUDIT/
4. Write the ruling into the envelope and AUDIT/
5. 相关方按裁决执行
5. Parties execute per the ruling

### 8.3 仲裁优先级链  *(Arbitration priority chain)*

冲突裁决按以下八层优先级链执行，高优先级覆盖低优先级：

Conflict rulings follow this eight-layer priority chain; higher overrides lower:

```
L1  HUMAN 人类指令               ← 最高优先级，人类决策是一级事实
L2  Veto 显式否决信封            ← 阻断流转
L3  CONSULTANT 顾问裁决          ← 把控项目走势，协助解决复杂问题
L4  SPEC 验收裁决                ← 规范权归 SPEC
L5  TEST 独立初验结论            ← 测试权归 TEST
L6  IMPL 自检报告                ← 实现方自述，权重最低
L7  QA 质量检查报告              ← 审视过程确保质量
L8  黑板历史状态                 ← 既有事实，不可单方改写
```

```
L1  HUMAN  human instruction          ← highest; human decision is primary fact
L2  Veto   explicit veto envelope      ← blocks flow
L3  CONSULTANT consultant ruling       ← steers project, helps with hard problems
L4  SPEC   acceptance ruling           ← spec authority belongs to SPEC
L5  TEST   independent first-verification ← test authority belongs to TEST
L6  IMPL   self-check report           ← implementer's own words, lowest weight
L7  QA     quality-check report        ← reviews process for quality
L8  blackboard history state           ← existing fact, not unilaterally rewritable
```

**仲裁规则** *(Arbitration rules)*：
- 低优先级不能覆盖高优先级；
- Lower priority cannot override higher.
- 同级冲突 DeclareConflict 升级 L1；
- Same-level conflict: DeclareConflict escalates to L1.
- 不得用自检(L6)冒充 TEST(L5)或 SPEC(L4)；
- Never pass self-check (L6) off as TEST (L5) or SPEC (L4).
- 顾问(L3)与 SPEC(L4)冲突以 L3 为准但 SPEC 可提请 L1 仲裁；
- CONSULTANT (L3) vs SPEC (L4): L3 wins, but SPEC may escalate to L1.
- QA(L7)发现问题可升级为 Veto 提请 L2；
- QA (L7) may escalate a finding to a Veto at L2.
- HUMAN(L1)回流必须写 AUDIT 并更新黑板。
- HUMAN (L1) feedback must be written to AUDIT and update the board.

---

## 九、版本与演进  *(IX. Version and evolution)*

- 本协议版本：1.1
- Protocol version: 1.1
- 修改权归：人类
- Right to modify: human
- 修改方式：在本文档末尾追加修订记录
- How to modify: append a revision record at the end of this document
- 修订记录格式：`| 日期 | 版本 | 修改内容 | 修改人 |`
- Revision format: `| date | version | change | author |`

### 修订记录  *(Revision history)*

| 日期 | 版本 | 修改内容 | 修改人 |
|------|------|---------|--------|
| 2026-06-13 | 1.0 | 初始版本 | 示例模型/AI IDE |
| 2026-07-07 | 1.0.1 | 明确黑板必写且最新条目置顶；信封处理事项必须指明对象；收件角色看到自身事项必须处理；无通知事项时允许只挂黑板不发空信封 | SPEC（按 HUMAN 指令） |

| Date | Version | Change | Author |
|------|---------|--------|--------|
| 2026-06-13 | 1.0 | Initial version | example model / AI IDE |
| 2026-07-07 | 1.0.1 | Clarified blackboard must be written with newest on top; envelope items must name handlers; a receiving role must handle its own items; no-notify cases may update board only, no empty envelope | SPEC (per HUMAN instruction) |

## v1.1 — 2026-07-07

- 信封 Header 升级：14 字段 → 21 字段（新增 protocol_version/trace_id/causation_id/message_type/reversibility/requires_audit/summary）
- Envelope header upgrade: 14 → 21 fields (added protocol_version/trace_id/causation_id/message_type/reversibility/requires_audit/summary)
- 新增 message_type 语义约束（7 种类型）
- New message_type semantics (7 types)
- 新增仲裁优先级链（8 层：HUMAN/Veto/CONSULTANT/SPEC/TEST/IMPL/QA/黑板历史）
- New arbitration priority chain (8 layers: HUMAN/Veto/CONSULTANT/SPEC/TEST/IMPL/QA/blackboard history)
- 新增黑板三段式格式规范（§5.3：Current State + Latest Entries ≤20 条 + History 索引）
- New three-part blackboard format (§5.3: Current State + Latest Entries ≤20 + History index)
- 向后兼容：历史信封新字段可选
- Backward compatible: new fields optional for legacy envelopes
- **v1.1 补丁（自愈机制）** *(v1.1 patch — self-healing)*：
  - 信封新增 `protocol_version` 字段 + 版本自愈规则（无版本字段的信封视为 v1.0 遗留，下次改写时自动升级）
  - Envelope gains `protocol_version` + version self-heal (no-version envelope = v1.0 legacy, auto-upgraded on next rewrite)
  - 黑板 §5.3 新增上限自执行规则（读到 >20 条先归档再写入，下一个 actor 自动维持上限）
  - Blackboard §5.3 gains a self-enforcing cap (>20 → archive then write; next actor maintains it)
  - CLAIMS 租约 `file_scope` 要求填具体文件路径列表（非自由文本，使冲突检测可机器化）
  - CLAIMS lease `file_scope` must list concrete file paths (not free text), making conflict detection machine-checkable
