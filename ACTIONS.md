# AI-COLLAB 标准协作动作（CBB — Collaboration Building Blocks）

> 版本：1.2 | 生效日期：2026-07-26（v1.2：新增 IssuePlan/RevisePlan 动作；v1.1：message_type 标注、CONSULTANT/QA 角色）
> 设计参考：CBB 标准动作，每个动作对应一个信封类型

---

## 一、动作分类

| 类别 | 动作数 | 说明 |
|------|--------|------|
| 规范类 | 4 | SPEC 发起，定义规范和接口 |
| 实现类 | 4 | IMPL 发起，提交代码和自检 |
| 测试类 | 4 | TEST 发起，执行测试和初验 |
| 协调类 | 7 | 任意方发起，处理异常、冲突、项目/actor登记 |
| 审计类 | 3 | 任意方发起，记录关键决策 |
| 定时类 | 4 | 定时扫描、心跳、租约续期、看门狗同步 |

### 动作 message_type 索引（v1.1 新增）

每个动作标注消息语义类型，接收方据此判断是否必须回应：

| 动作 | message_type | 说明 |
|------|-------------|------|
| IssuePlan | Command | SPEC 下发项目计划（plan 模式，可选） |
| RevisePlan | Command | SPEC 修订项目计划（supersedes 旧 plan） |
| IssueSpec | Command | 要求 IMPL/TEST 执行实现 |
| DefineInterface | Command | 要求 IMPL 按接口实现 |
| AcceptStage | ApprovalDecision | SPEC 验收通过的决定 |
| RejectStage | ApprovalDecision | SPEC 验收不通过的决定 |
| ClaimTask | Event | 通知已认领（不要求回应） |
| SubmitImpl | Command | 要求 TEST 执行初验 |
| SubmitSelfCheck | Event | 通知自检完成（供 TEST 参考） |
| RequestSpecClarification | Query | 只读查询规范疑问 |
| SubmitTestReport | Response | 对 SubmitImpl 的初验回执 |
| RequestImplFix | Command | 要求 IMPL 修复缺陷 |
| SubmitAdversarialReport | Event | 通知对抗性测试结果 |
| SubmitRegressionReport | Event | 通知回归测试结果 |
| DeclareBlock | Event | 通知阻塞发生 |
| ResolveBlock | Event | 通知阻塞解除 |
| DeclareConflict | Veto | 否决/阻断流转 |
| EscalateToHuman | ApprovalRequest | 请求人类审批 |
| SyncStatus | Event | 通知状态同步 |
| RegisterProject | Event | 通知项目登记 |
| RegisterActor | Event | 通知 actor 登记 |
| Heartbeat | Event | 通知心跳（可选） |
| RenewClaim | Event | 通知续租（可选） |
| ReleaseClaim | Event | 通知释放认领（可选） |
| WatchdogSync | Event | 通知看门狗同步（可选） |
| RecordDecision | Event | 记录决策到审计 |
| RecordRisk | Event | 记录风险到审计 |
| RecordDeviation | Event | 记录偏差到审计 |

---

## 二、规范类动作（SPEC → IMPL / TEST）

### 2.1 IssueSpec — 下发规范

| 字段 | 值 |
|------|-----|
| from | SPEC |
| to | IMPL, TEST |
| risk_level | Medium |
| 必需payload | 规范文档路径、阶段标识、验收标准、依赖列表 |

**信封payload模板**：
```markdown
## Payload
### 规范来源
- 规范文件路径：{L2.5_xx路径}
- 阶段：{S2_4等}
- 优先级：{P0/P1/P2}

### 验收标准
1. {具体可验证的标准}
2. ...

### 依赖
- 前置阶段：{S2_3E等}
- 前置信封：{ENVELOPE_ID}
- 外部依赖：{无/具体说明}

### 约束
- 禁止行为：{具体禁止}
- 资源限制：{时间/文件数/测试数}
```

**IMPL收到后必须**：
1. 在 `CLAIMS/` 创建 `ClaimTask` 记录
2. 评估可行性，标记 `Accepted` / `Conditional` / `Blocked`
3. 更新 BLACKBOARD.md

### 2.2 DefineInterface — 定义跨阶段接口

| 字段 | 值 |
|------|-----|
| from | SPEC |
| to | IMPL |
| risk_level | High |
| 必需payload | 接口Schema、输入输出类型、版本号 |

**用途**：定义阶段间移交接口（如S2_3→S2_4的CapabilityReception）

**信封payload模板**：
```markdown
## Payload
### 接口名称
{InterfaceName}

### 接口Schema
```rust
pub struct {InterfaceName} {
    // 字段定义
}
```

### 版本
- schema_version: "1.0"

### 兼容性
- 向后兼容：是/否
- 迁移路径：{描述}
```

### 2.3 AcceptStage — 验收通过

| 字段 | 值 |
|------|-----|
| from | SPEC |
| to | IMPL, TEST |
| risk_level | High |
| 必需payload | 阶段标识、验收结论、条件列表（如有） |

**前置条件**：
- IMPL已提交实现（SubmitImpl）
- TEST已提交初验报告（SubmitTestReport）
- 无未解决的P0阻塞项

**必须写入AUDIT/**

### 2.4 RejectStage — 验收不通过

| 字段 | 值 |
|------|-----|
| from | SPEC |
| to | IMPL |
| risk_level | High |
| 必需payload | 阶段标识、拒绝理由、修复要求、回退目标状态 |

**必须写入AUDIT/**

---

## 三、实现类动作（IMPL → TEST / SPEC）

### 3.1 ClaimTask — 认领任务

| 字段 | 值 |
|------|-----|
| from | IMPL |
| to | SPEC（通知） |
| risk_level | Low |
| 必需payload | 阶段标识、认领方、预期交付物、预估工作量 |

**文件位置**：`CLAIMS/{STAGE}_CLAIM_{CLAIM_ID}.md`

**payload模板**：
```markdown
## Payload
### 认领信息
- 阶段：{S2_4等}
- 认领方：IMPL (AI IDE)
- 关联规范信封：{ENVELOPE_ID}

### 预期交付物
1. 代码文件：{路径列表}
2. 单元测试：{路径列表}
3. 自检报告：{路径}

### 可行性评估
- 阻塞项：{无/具体说明}
- 风险项：{无/具体说明}
- 条件项：{无/具体说明}
```

### 3.2 SubmitImpl — 提交实现

| 字段 | 值 |
|------|-----|
| from | IMPL |
| to | TEST |
| risk_level | Medium |
| 必需payload | 阶段标识、代码变更列表、测试结果、自检报告 |

**信封payload模板**：
```markdown
## Payload
### 实现概要
- 阶段：{S2_4等}
- 新增文件：{数量和路径}
- 修改文件：{数量和路径}
- 删除文件：{数量和路径}

### 测试结果
- 单元测试总数：{N}
- 通过：{N}
- 失败：{N}
- 跳过：{N}

### 自检报告
- 路径：{plans/S2_4_TEST_RESULT_SUMMARY.md等}
- 关键发现：{摘要}

### 已知限制
1. {限制描述}
2. ...

### 佐证
- 佐证路径列表
```

### 3.3 SubmitSelfCheck — 提交自检报告

| 字段 | 值 |
|------|-----|
| from | IMPL |
| to | TEST, SPEC |
| risk_level | Low |
| 必需payload | 自检报告路径、覆盖率数据、STUB清单 |

**用途**：IMPL在SubmitImpl之前或同时提交自检，供TEST参考

### 3.4 RequestSpecClarification — 请求规范澄清

| 字段 | 值 |
|------|-----|
| from | IMPL |
| to | SPEC |
| risk_level | Low |
| 必需payload | 阶段标识、疑问点、IMPL建议方案 |

**用途**：IMPL发现规范不明确时，请求SPEC澄清

---

## 四、测试类动作（TEST → SPEC / IMPL）

### 4.1 SubmitTestReport — 提交测试报告

| 字段 | 值 |
|------|-----|
| from | TEST |
| to | SPEC, IMPL |
| risk_level | Medium |
| 必需payload | 阶段标识、测试类型、测试结果、初验结论 |

**信封payload模板**：
```markdown
## Payload
### 测试概要
- 阶段：{S2_4等}
- 关联实现信封：{ENVELOPE_ID}
- 测试类型：{黑盒/白盒/对抗性/回归}

### 测试结果
- 测试用例总数：{N}
- 通过：{N}
- 失败：{N}
- 阻塞：{N}

### 初验结论
- 评定：{PASS / CONDITIONAL / FAIL}
- 条件列表（如Conditional）：
  1. {条件描述}
- 失败原因（如FAIL）：
  1. {原因描述}

### 佐证
- 佐证路径列表
```

### 4.2 RequestImplFix — 请求实现修复

| 字段 | 值 |
|------|-----|
| from | TEST |
| to | IMPL |
| risk_level | Medium |
| 必需payload | 阶段标识、缺陷列表、严重程度、复现步骤 |

### 4.3 SubmitAdversarialReport — 提交对抗性测试报告

| 字段 | 值 |
|------|-----|
| from | TEST |
| to | SPEC, IMPL |
| risk_level | High |
| 必需payload | 攻击向量、测试结果、漏洞评级、修复建议 |

**必须写入AUDIT/**

### 4.4 SubmitRegressionReport — 提交回归测试报告

| 字段 | 值 |
|------|-----|
| from | TEST |
| to | SPEC, IMPL |
| risk_level | Medium |
| 必需payload | 回归范围、测试结果、是否引入新缺陷 |

---

## 五、协调类动作（任意方 → 相关方）

### 5.1 DeclareBlock — 声明阻塞

| 字段 | 值 |
|------|-----|
| from | 任意方 |
| to | 相关方 |
| risk_level | Medium |
| 必需payload | 阶段标识、阻塞原因、阻塞源、预期解除条件 |

**必须更新BLACKBOARD.md状态为Blocked**

### 5.2 ResolveBlock — 解除阻塞

| 字段 | 值 |
|------|-----|
| from | 阻塞发现方 |
| to | 相关方 |
| risk_level | Medium |
| 必需payload | 阶段标识、解除方式、解除后状态 |

**必须写入AUDIT/**

### 5.3 DeclareConflict — 声明冲突

| 字段 | 值 |
|------|-----|
| from | 任意方 |
| to | 相关方 + 人类 |
| risk_level | High |
| 必需payload | 冲突描述、涉及方、涉及信封、建议解决方式 |

**必须写入AUDIT/**

### 5.4 EscalateToHuman — 升级至人类

| 字段 | 值 |
|------|-----|
| from | 任意方 |
| to | 人类 |
| risk_level | High |
| 必需payload | 问题描述、已尝试方案、需要人类决策的内容 |

### 5.5 SyncStatus — 同步状态

| 字段 | 值 |
|------|-----|
| from | 任意方 |
| to | 全体 |
| risk_level | Low |
| 必需payload | 当前工作状态、进度百分比、下一步计划 |

**用途**：定期同步，防止信息不对称

### 5.6 RegisterProject — 登记项目空间

| 字段 | 值 |
|------|-----|
| from | HUMAN / SPEC |
| to | ALL |
| risk_level | Medium |
| 必需payload | project_id、workspace_root、path_fingerprint、artifact_policy、allowed_roots |

**用途**：为实际开发项目创建 `PROJECTS/{project_id}/` 协作空间。

**规则**：
- `artifact_policy` 必须为 `WorkspaceOnly`，项目产出物保留在工作目录。
- `BLACKBOARD.md` 只记录文件名、相对路径、hash 和短摘要。
- 项目登记后，AI IDE 必须在该项目空间内处理对应任务。

### 5.7 RegisterActor — 登记项目参与方

| 字段 | 值 |
|------|-----|
| from | 任意 actor / HUMAN |
| to | SPEC / HUMAN |
| risk_level | Medium |
| 必需payload | actor_id、role、ai_ide、workspace_root_seen、path_fingerprint_seen、expires_at |

**用途**：声明某个 AI IDE 或人类角色参与某个项目空间。

**规则**：
- 未登记或过期 actor 不得处理项目任务。
- actor 登记是软鉴权，不替代系统权限或 Git 权限。
- 角色仍必须遵守 `ACTIONS.md` 权限矩阵。

---

## 五.5、定时类动作（Timer / Lease / Watchdog）

### 5.8 Heartbeat — 心跳

| 字段 | 值 |
|------|-----|
| from | 任意 actor |
| to | HEARTBEAT/ |
| risk_level | Low |
| 必需payload | actor_id、role、timer_profile、status、current_stage、active_claim_id、last_heartbeat_at、next_tick_at |

心跳格式见 `HEARTBEAT/README.md`。

### 5.9 RenewClaim — 续租

| 字段 | 值 |
|------|-----|
| from | Claim owner |
| to | CLAIMS/ |
| risk_level | Low / Medium |
| 必需payload | claim_id、old_expires_at、new_expires_at、heartbeat_at、continuation status |

续租必须发生在过期前。过期后续做必须记录 gap，并由 WATCHDOG 或 SPEC 判定是否可继续。

### 5.10 ReleaseClaim — 释放认领

| 字段 | 值 |
|------|-----|
| from | Claim owner |
| to | CLAIMS/ + BLACKBOARD |
| risk_level | Low |
| 必需payload | claim_id、release_reason、handoff/evidence paths |

### 5.11 WatchdogSync — 看门狗同步

| 字段 | 值 |
|------|-----|
| from | WATCHDOG / 任意执行方 |
| to | ALL |
| risk_level | Low / Medium / High |
| 必需payload | stale claims、stale heartbeat、state conflicts、missing audit/evidence、recommended action |

看门狗规则见 `WATCHDOG.md`。

---

## 六、审计类动作（任意方 → AUDIT/）

### 6.1 RecordDecision — 记录决策

| 字段 | 值 |
|------|-----|
| from | 任意方 |
| to | AUDIT/ |
| risk_level | 按实际 |
| 必需payload | 决策内容、决策理由、影响范围 |

### 6.2 RecordRisk — 记录风险

| 字段 | 值 |
|------|-----|
| from | 任意方 |
| to | AUDIT/ |
| risk_level | Medium+ |
| 必需payload | 风险描述、风险级别、缓解措施、责任人 |

### 6.3 RecordDeviation — 记录偏差

| 字段 | 值 |
|------|-----|
| from | 任意方 |
| to | AUDIT/ |
| risk_level | Medium+ |
| 必需payload | 偏差描述、与规范的差异、理由、影响评估 |

### 6.4 IssuePlan — 下发项目计划

| 字段 | 值 |
|------|-----|
| action | IssuePlan |
| message_type | Command |
| from -> to | SPEC -> ALL |
| risk_level | High |
| reversibility | NeedsHuman |
| requires_audit | true |
| 必需payload | plan_id, plan_version, requirements_ref, stage 列表摘要, plan_path, plan_sha256 |
| 文件名 | PLAN_SPEC_TO_ALL_{TS}.md |

**用途**：SPEC 在 plan 生成阶段编写完 plan 后，通过此信封下发计划给所有角色。CONSULTANT/QA 复核通过 SyncStatus 信封响应，HUMAN 在本信封上 Accept 后 plan 生效。详见 PLAN.md §五.1。

### 6.5 RevisePlan — 修订项目计划

| 字段 | 值 |
|------|-----|
| action | RevisePlan |
| message_type | Command |
| from -> to | SPEC -> ALL |
| risk_level | High |
| reversibility | NeedsHuman |
| requires_audit | true |
| 必需payload | plan_id, supersedes, 修订原因, 影响范围, plan_path, plan_sha256 |
| 文件名 | PLAN_REVISE_SPEC_TO_ALL_{TS}.md |

**用途**：SPEC 修订已有 plan 时通过此信封下发。supersedes 字段引用旧 IssuePlan 信封 ID。已 Accepted 的 stage 不受修订影响。详见 PLAN.md §五.2。

---

## 七、动作与角色权限矩阵

| 动作 | SPEC | IMPL | TEST | CONSULTANT | QA | 人类 |
|------|------|------|------|------------|-----|------|
| IssuePlan | **发起** | 接收 | 接收 | 参考 | 参考 | 批准 |
| RevisePlan | **发起** | 接收 | 接收 | 参考 | 参考 | 批准 |
| IssueSpec | **发起** | 接收 | 接收 | 参考 | — | 裁决 |
| DefineInterface | **发起** | 接收 | 参考 | 参考 | — | 裁决 |
| AcceptStage | **发起** | 接收 | 接收 | 参考 | 参考 | 批准 |
| RejectStage | **发起** | 接收 | 接收 | 参考 | 参考 | 批准 |
| ClaimTask | 通知 | **发起** | 参考 | — | — | — |
| SubmitImpl | 参考 | **发起** | 接收 | — | — | — |
| SubmitSelfCheck | 参考 | **发起** | 参考 | — | — | — |
| RequestSpecClarification | **接收** | 发起 | — | 参考 | — | — |
| SubmitTestReport | 接收 | 接收 | **发起** | 参考 | 参考 | — |
| RequestImplFix | — | **接收** | 发起 | — | — | — |
| SubmitAdversarialReport | 接收 | 接收 | **发起** | 参考 | 参考 | — |
| SubmitRegressionReport | 接收 | 接收 | **发起** | — | 参考 | — |
| DeclareBlock | 发起/接收 | 发起/接收 | 发起/接收 | 发起/接收 | 发起/接收 | 裁决 |
| ResolveBlock | 发起/接收 | 发起/接收 | 发起/接收 | 发起/接收 | 发起/接收 | 批准 |
| DeclareConflict | 发起/接收 | 发起/接收 | 发起/接收 | 发起/接收 | 发起/接收 | **裁决** |
| EscalateToHuman | — | — | — | — | — | **接收** |
| SyncStatus | 发起 | 发起 | 发起 | 发起 | 发起 | — |
| RegisterProject | 发起 | 接收 | 接收 | — | — | 发起/批准 |
| RegisterActor | 接收/批准 | 发起 | 发起 | 发起 | 发起 | 发起/批准 |
| Heartbeat | 发起 | 发起 | 发起 | 发起（可选） | 发起（可选） | — |
| RenewClaim | 接收/发起 | 发起 | 发起 | — | — | — |
| ReleaseClaim | 接收/发起 | 发起 | 发起 | — | — | — |
| WatchdogSync | 发起/接收 | 发起/接收 | 发起/接收 | 发起/接收 | **发起** | 裁决 |
| RecordDecision | 发起 | 发起 | 发起 | 发起 | 发起 | 发起 |
| RecordRisk | 发起 | 发起 | 发起 | 发起 | 发起 | 发起 |
| RecordDeviation | 发起 | 发起 | 发起 | 发起 | 发起 | 发起 |

**CONSULTANT 角色权限说明**：可发起 SyncStatus/DeclareBlock/DeclareConflict/RecordDecision/RecordRisk/RecordDeviation/WatchdogSync/Heartbeat；可参考 SPEC/TEST 的验收和测试动作；不发起 IssueSpec/SubmitImpl/SubmitTestReport/AcceptStage/RejectStage（不替代 SPEC/IMPL/TEST 的核心职责）。

**QA 角色权限说明**：可发起 WatchdogSync/DeclareBlock/DeclareConflict/RecordDecision/RecordRisk/RecordDeviation/SyncStatus/Heartbeat；可参考 AcceptStage/RejectStage/SubmitTestReport；不发起实现和测试类动作（QA 做过程质量审视，不做功能测试）。

---

## 八、动作执行检查清单

每个AI IDE在执行动作前必须检查：

1. [ ] 我是否有权限发起此动作？（见权限矩阵）
2. [ ] 信封格式是否完整？（Header + Payload + Evidence + Status + Audit）
3. [ ] 文件命名是否符合规则？
4. [ ] BLACKBOARD.md是否需要更新？
5. [ ] AUDIT/是否需要记录？
6. [ ] 是否有前置信封未完成？
7. [ ] 是否与现有信封冲突？

---

## 九、动作模板快速索引

| 动作 | from→to | 信封文件名模板 |
|------|---------|---------------|
| IssueSpec | SPEC→IMPL,TEST | `{STAGE}_SPEC_TO_IMPL_{TS}.md` |
| DefineInterface | SPEC→IMPL | `{STAGE}_SPEC_TO_IMPL_{TS}.md` |
| AcceptStage | SPEC→IMPL,TEST | `{STAGE}_SPEC_TO_IMPL_TEST_{TS}.md` |
| RejectStage | SPEC→IMPL | `{STAGE}_SPEC_TO_IMPL_{TS}.md` |
| ClaimTask | IMPL→SPEC | `CLAIMS/{STAGE}_CLAIM_{ID}.md` |
| SubmitImpl | IMPL→TEST | `{STAGE}_IMPL_TO_TEST_{TS}.md` |
| SubmitSelfCheck | IMPL→TEST,SPEC | `{STAGE}_IMPL_TO_TEST_SPEC_{TS}.md` |
| RequestSpecClarification | IMPL→SPEC | `{STAGE}_IMPL_TO_SPEC_{TS}.md` |
| SubmitTestReport | TEST→SPEC,IMPL | `{STAGE}_TEST_TO_SPEC_IMPL_{TS}.md` |
| RequestImplFix | TEST→IMPL | `{STAGE}_TEST_TO_IMPL_{TS}.md` |
| SubmitAdversarialReport | TEST→SPEC,IMPL | `{STAGE}_TEST_TO_SPEC_IMPL_{TS}.md` |
| SubmitRegressionReport | TEST→SPEC,IMPL | `{STAGE}_TEST_TO_SPEC_IMPL_{TS}.md` |
| DeclareBlock | 任意→相关 | `{STAGE}_{FROM}_TO_{TO}_{TS}.md` |
| ResolveBlock | 任意→相关 | `{STAGE}_{FROM}_TO_{TO}_{TS}.md` |
| DeclareConflict | 任意→相关+人类 | `{STAGE}_{FROM}_TO_ALL_{TS}.md` |
| EscalateToHuman | 任意→人类 | `{STAGE}_{FROM}_TO_HUMAN_{TS}.md` |
| SyncStatus | 任意→全体 | `SYNC_{FROM}_{TS}.md` |
| RegisterProject | HUMAN/SPEC→ALL | `PROJECT_REGISTER_{PROJECT_ID}_{TS}.md` |
| RegisterActor | 任意→SPEC/HUMAN | `PROJECT_ACTOR_REGISTER_{ACTOR}_{TS}.md` |
| Heartbeat | 任意→HEARTBEAT | `HEARTBEAT/{ACTOR}.json` |
| RenewClaim | Claim owner→CLAIMS | `{STAGE}_CLAIM_{ACTOR}_{TS}.md` |
| ReleaseClaim | Claim owner→CLAIMS | `{STAGE}_CLAIM_{ACTOR}_{TS}.md` |
| WatchdogSync | WATCHDOG→ALL | `SYNC_WATCHDOG_{TS}.md` |
