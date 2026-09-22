 操作手册

> ai-collab v1.2 · 面向多 AI IDE 的文件系统协作总线

<!-- 中文：本手册面向第一次使用 ai-collab 的开发者 / AI IDE，目标是让你在 5 分钟内完成接入并跑通一次完整协作。 -->

## 0. 这是什么

ai-collab 非自动化平台，而是一套"路"：一组 Markdown / JSON 文件及目录约定，让多个 AI IDE 在同一套协议下按规矩交接任务。它没有运行时、不锁定任何 AI IDE、毋庸安装依赖——你已有的 AI IDE 各自保留，只共享这一个目录。

> 一句话：把多个 AI IDE 的"协作"变成一份可审计的文件夹。

## 1. 谁该用

- 装了 ≥2 个 AI IDE，苦恼它们之间无法协作的开发者。
- 想要"规范—计划—代码—测试—佐证"对齐、对结果负责、过程可审计的团队。

毋庸：服务器、数据库、API Key、运行时。

## 2. 前置条件

- 一个所有参与方都能读写的共享目录（本地文件夹、网盘同步目录、或 Git 仓库均可）。
- 至少两个"参与者"：可两个 AI IDE，也可你本人 + 一个或多个 AI IDE。
- （可选）某个 AI IDE 或外部调度器能定期唤醒；没有也能用"人工唤醒 / 批处理"模式。

## 3. 5 分钟接入

### 3.1 取得目录

把 ai-collab 仓库放到一个共享位置（clone 或复制文件夹）。它本身毋庸安装任何东西。

```text
ai-collab/
├─ README.md          # 总说明（建议先读）
├─ PROTOCOL.md        # 总协议
├─ QUICKSTART.md      # 本手册
├─ PROJECTS/          # 你的项目空间都在这里
├─ TEMPLATES/         # 标准信封 / 认领 / 审计模板
├─ RUNBOOKS/          # 各角色分步手册
├─ ...
```

### 3.2 新建一个项目空间

复制模板，按真实项目改名：

```text
cp -r PROJECTS/_TEMPLATE PROJECTS/example-project
```

然后编辑 `PROJECTS/example-project/PROJECT.md`：
- 把 `workspace_root` 指向真实代码目录；
- 把 `project_id` 设为可读标识（也可用工作目录的 SHA256）。

再编辑 `PROJECTS/example-project/ACTORS.md`，登记每个参与者：

```markdown
- actor_id: SPEC
  role: SPEC
  ai_ide: {你的 AI IDE}
  expires_at: 2026-12-31
```

> 模板与字段说明见 `TEMPLATES/RegisterProject.md` 与 `TEMPLATES/RegisterActor.md`。

### 3.3 给每个 AI IDE 发一段接入提示词

毋庸自己拼提示词——直接用现成的 [接入提示词包 PROMPTS.md](PROMPTS.md)：把"总操作合同"复制给每个 AI IDE，再把对应角色那段追加进去即可。完整可粘贴内容（含无定时器唤醒句、常见坑）都在那里。

> 想看一次真实周期的产物长什么样，见 [EXAMPLE.md](EXAMPLE.md)。

## 4. 跑通第一次完整协作

下面是从"下任务"到"验收"的最小一步到位流程。每一步都对应一个模板文件，放到指定目录即可。

### 4.1 SPEC 下发任务

1. 复制 `TEMPLATES/IssueSpec.md` → `PROJECTS/example-project/HANDOFF/S1_SPEC_TO_IMPL_<时间戳>.md`
2. 在 Payload 写清：阶段名、输入、交付物、验收标准、禁止行为、是否需 TEST 初验。
3. 把 `BLACKBOARD.md` 阶段状态改为 `SpecIssued`。

### 4.2 IMPL 认领并实现

1. 复制 `TEMPLATES/ClaimTask.md` → `PROJECTS/example-project/CLAIMS/S1_CLAIM_IMPL_<时间戳>.md`
2. 在真实工作目录写代码并自检；把自检报告 / 证据索引写入 `EVIDENCE/`。
3. 复制 `TEMPLATES/SubmitImpl.md` → `HANDOFF/S1_IMPL_TO_TEST_<时间戳>.md`
4. 更新 `BLACKBOARD.md` 阶段为 `ImplSubmitted`。

### 4.3 TEST 独立初验

1. 复制 `TEMPLATES/ClaimTask.md` → `CLAIMS/S1_CLAIM_TEST_<时间戳>.md`
2. 跑测试 / 对抗测试 / 回归测试；证据写入 `EVIDENCE/`。
3. 复制 `TEMPLATES/SubmitTestReport.md` → `HANDOFF/S1_TEST_TO_SPEC_IMPL_<时间戳>.md`
4. 更新 `BLACKBOARD.md` 阶段为 `TestReported`。

### 4.4 SPEC 最终验收

1. 读取 IMPL 交付、TEST 报告、EVIDENCE、AUDIT。
2. 满足验收标准 → 在 `HANDOFF/` 写 `AcceptStage` 信封（高风险结论用 `TEMPLATES/Audit.md` 写 `AUDIT/`）。
3. `BLACKBOARD.md` 阶段改为 `Accepted`。

> 完整字段与动作清单见 `PROTOCOL.md` 与 `ACTIONS.md`；分角色分步说明见 `RUNBOOKS/`。

## 5. 怎么看进度

按顺序看，基本能掌握全局：

1. `PROJECTS/example-project/BLACKBOARD.md` —— 当前状态与历史（最新置顶）。
2. `HANDOFF/` —— 最新信封。
3. `CLAIMS/` —— 谁在做、是否过期 / 冲突。
4. `EVIDENCE/` —— 可复核证据索引。
5. `AUDIT/` —— 高风险动作留痕。
6. `HEARTBEAT/` —— 各参与者近期是否活动。

双击 `MONITOR/index.html` 可在浏览器里看只读看板（需先运行 `MONITOR/collect.ps1` 采集）。

## 6. 没有定时器怎么办

很多 AI IDE 不能自己定时唤醒。用"人工唤醒"即可：

```text
请作为 {SPEC|IMPL|TEST|WATCHDOG} 运行一次 ai-collab loop。
```

AI IDE 扫描、处理、交付后，把心跳写为 `BatchComplete` 或 `PassiveNoTimer`。详见 README §8。

## 7. 红线（千万别做）

- 禁把密钥、Token、Cookie、真实隐私写进任何文件。
- 禁让一个角色同时完成"实现 + 测试 + 验收"闭环。
- 禁修改别人创建的信封；禁自审自验；禁用 UnitTest / SourceScan 冒充 Runtime 证据。
- 长任务禁无 ClaimLease 占用；高风险裁决须写 `AUDIT/`。

## 8. 下一步

- 通读 `PROTOCOL.md`（总协议）、`ACTIONS.md`（动作库）、`STRUCTURE.md`（目录边界）。
- 按角色读 `ROLE_SPEC.md` / `ROLE_IMPL.md` / `ROLE_TEST.md` 与 `RUNBOOKS/`。
- 想立刻让 AI IDE 跑起来：把 [PROMPTS.md](PROMPTS.md) 的合同粘进每个 AI IDE；照着 [EXAMPLE.md](EXAMPLE.md) 抄一次完整周期。
- 想参与共建，见 `CONTRIBUTING.md`、路线图 `ROADMAP.md`、变更记录 `CHANGELOG.md`。

> **可选增强（v1.2）**：若项目有多个 stage 且希望 actor 轮询时自主推进，可启用 Project Plan 协议——SPEC 预先编排 stage 序列与各角色 prompt，actor 唤醒后直接读自己的 prompt 执行。详见 [PLAN.md](PLAN.md)。

