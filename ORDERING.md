# AI-COLLAB 读写顺序与依赖控制

多 AI IDE 协作时，很多错误不是能力问题，而是顺序问题：先看了旧黑板、跳过了前置信封、先更新状态后写证据、或两个 actor 同时改同一范围。`ORDERING.md` 定义最小顺序机制，确保 AI IDE 按正确顺序处理文件。

---

## 1. 基本规则

1. **先识别项目，再读任务**：没有确定 `project_id` 前，不处理任何项目任务。
2. **先读状态，再认领任务**：没有读取最新 `BLACKBOARD.md` 和 `CLAIMS/` 前，不创建新 claim。
3. **先产出物，再证据，再信封，最后黑板**：状态永远在证据之后更新。
4. **先依赖，后执行**：`depends_on` 未满足时，不得处理后续信封。
5. **先冲突检查，后写入**：发现 revision 或 claim 冲突时，先写冲突，不强行覆盖。

---

## 2. 标准读取顺序

AI IDE 每次 tick 或人工唤醒时，按顺序读取：

```text
1. README.md
2. PROTOCOL.md
3. ACTIONS.md
4. TIMER_LOOP.md
5. PROJECTS/README.md
6. PROJECTS/{project_id}/PROJECT.md
7. PROJECTS/{project_id}/ACTORS.md
8. RUNBOOKS/ROLE_RUNBOOK_{ROLE}.md
9. PROJECTS/{project_id}/BLACKBOARD.md
10. PROJECTS/{project_id}/HANDOFF/ 按 sequence_no、created_at 排序
11. PROJECTS/{project_id}/CLAIMS/
12. PROJECTS/{project_id}/HEARTBEAT/
13. PROJECTS/{project_id}/EVIDENCE/
14. PROJECTS/{project_id}/AUDIT/
15. 读取信封引用的工作目录产出物
```

根目录不承接具体项目任务。正常项目任务不得省略 `PROJECTS/{project_id}/` 前缀。

---

## 3. 信封顺序字段

新信封建议在 Header 中增加：

```markdown
- project_id: {project_id}
- sequence_no: {integer, monotonic within project}
- depends_on:
  - {envelope_id or none}
- supersedes:
  - {envelope_id or none}
- requires_blackboard_revision: {revision id or timestamp}
- read_order_version: 1
```

处理规则：

- `sequence_no` 小的先处理。
- `depends_on` 未到终态时，后续信封只能标记为 `Blocked` 或 `NeedsClarification`。
- `supersedes` 指向旧信封时，旧信封应在黑板中标记 `Superseded`。
- `requires_blackboard_revision` 与当前黑板不匹配时，必须重新读取，不得基于旧状态写入。

---

## 4. 标准写入顺序

### 4.1 IMPL 写入顺序

```text
1. 在工作目录中写代码/报告/测试结果。
2. 在工作目录中生成自检报告或 artifact。
3. 在 EVIDENCE/ 写证据索引，引用工作目录文件名/相对路径/hash。
4. 在 HANDOFF/ 写 SubmitImpl / SubmitSelfCheck 信封。
5. 如有风险或偏差，写 AUDIT/。
6. 最后更新 BLACKBOARD.md 快照和追加历史。
7. 更新 HEARTBEAT/。
```

### 4.2 TEST 写入顺序

```text
1. 读取 IMPL 信封和 evidence。
2. 在工作目录中生成测试报告/对抗报告/回归报告。
3. 在 EVIDENCE/ 写测试证据索引。
4. 在 HANDOFF/ 写 SubmitTestReport / SubmitAdversarialReport / RequestImplFix。
5. 如有高风险缺陷，写 AUDIT/。
6. 最后更新 BLACKBOARD.md。
7. 更新 HEARTBEAT/。
```

### 4.3 SPEC 写入顺序

```text
1. 读取 IMPL 信封、TEST 信封、EVIDENCE、AUDIT。
2. 如需补充规范，在工作目录中写规范/计划/验收文件。
3. 在 HANDOFF/ 写 AcceptStage / RejectStage / Conditional / IssueSpec。
4. 高风险结论写 AUDIT/。
5. 最后更新 BLACKBOARD.md。
6. 更新 HEARTBEAT/。
```

### 4.4 WATCHDOG 写入顺序

```text
1. 读取项目登记、黑板、信封、claim、heartbeat、evidence、audit。
2. 只生成 SyncStatus / DeclareConflict / RecordRisk。
3. 不修改他人信封，不写验收结论。
4. 更新 WATCHDOG 自身 heartbeat。
```

---

## 5. 黑板 revision 机制

项目黑板顶部建议包含：

```markdown
> project_id: {project_id}
> blackboard_revision: {YYYYMMDDTHHMMSS}-{actor_id}
> last_updated: {ISO8601}
```

AI IDE 写黑板前必须：

1. 记录读取时的 `blackboard_revision`；
2. 写入前重新读取最新黑板；
3. 如果 revision 变化，重新判断是否仍可写；
4. 最多重试一次；
5. 仍冲突则写 `DeclareConflict`，不得强行覆盖。

---

## 6. 依赖阻塞语义

遇到顺序缺口时使用这些状态：

| 情况 | 推荐状态 |
|---|---|
| 前置信封未完成 | `Blocked` |
| 依赖证据缺失 | `Conditional` |
| 黑板 revision 已变化 | `DeclareConflict` 或重新读取 |
| 认领范围冲突 | `DeclareConflict` |
| 项目路径不匹配 | `NeedsProjectRegistration` |
| actor 未授权 | `EscalateToHuman` |

---

## 7. 禁止行为

- 不得先更新黑板再补证据。
- 不得跳过 `depends_on` 执行后续任务。
- 不得在项目路径不匹配时处理信封。
- 不得用旧黑板状态覆盖新黑板状态。
- 不得把完整项目产出物写进黑板。
- 不得跨项目读取或处理无关信封，除非人类明确要求做全局 WATCHDOG 扫描。
- 不得把任何具体项目任务写入根目录占位区。
