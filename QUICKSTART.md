# 操作手册 / Quick Start Guide

> ai-collab v1.2 · 面向多 AI IDE 的文件系统协作总线
> ai-collab v1.2 · a filesystem collaboration bus for multi-AI-IDE cooperation

<!-- 中文：本手册面向第一次使用 ai-collab 的开发者 / AI IDE，目标是让你在 5 分钟内完成接入并跑通一次完整协作。 -->

This manual is for developers / AI IDEs using ai-collab for the first time. The goal: get onboarded and run one full collaboration cycle in about 5 minutes.

## 0. 这是什么 / What is this

ai-collab 不是自动化平台，而是一套"路"：一组 Markdown / JSON 文件与目录约定，让多个 AI IDE 在同一套协议下按规矩交接任务。它没有运行时、不锁定任何 AI IDE、不需要安装依赖——你已有的 AI IDE 各自保留，只共享这一个目录。

ai-collab is not an automation platform; it is a "road": a set of Markdown / JSON files and directory conventions that let multiple AI IDEs hand off tasks under one shared protocol. There is no runtime, no lock-in, no install step — your existing AI IDEs stay as they are; they only share this one directory.

> 一句话：把多个 AI IDE 的"协作"变成一份可审计的文件夹。
> *In one line: turn multi-AI-IDE collaboration into one auditable folder.*

## 1. 谁该用 / Who should use it

- 装了 ≥2 个 AI IDE，苦恼它们之间无法协作的开发者。
- Developers who run ≥2 AI IDEs and struggle to coordinate them.
- 想要"规范—计划—代码—测试—佐证"对齐、对结果负责、过程可审计的团队。
- Teams who want specification–plan–code–test–evidence alignment, outcome accountability, and an auditable process.

不需要：服务器、数据库、API Key、运行时。
You do NOT need: a server, a database, an API key, or a runtime.

## 2. 前置条件 / Prerequisites

- 一个所有参与方都能读写的共享目录（本地文件夹、网盘同步目录、或 Git 仓库均可）。
- A shared directory all participants can read/write (local folder, synced drive, or a Git repo all work).
- 至少两个"参与者"：可以是两个 AI IDE，也可以是你本人 + 一个或多个 AI IDE。
- At least two "participants": two AI IDEs, or you + one or more AI IDEs.
- （可选）某个 AI IDE 或外部调度器能定期唤醒；没有也能用"人工唤醒 / 批处理"模式。
- (Optional) a timer / external scheduler that can wake an AI IDE periodically; if not, "manual wake-up / batch" mode works too.

## 3. 5 分钟接入 / 5-minute setup

### 3.1 取得目录 / Get the directory

把 ai-collab 仓库放到一个共享位置（clone 或复制文件夹）。它本身不需要安装任何东西。

Place the ai-collab repo in a shared location (clone or copy the folder). Nothing needs to be installed.

```text
ai-collab/
├─ README.md          # 总说明（建议先读）
├─ PROTOCOL.md        # 总协议
├─ QUICKSTART.md      # 本手册
├─ PROJECTS/          # 你的项目空间都在这里
├─ TEMPLATES/         # 标准信封 / 认领 / 审计模板
├─ RUNBOOKS/          # 各角色分步手册
└─ ...
```

### 3.2 新建一个项目空间 / Create a project space

复制模板，按你的真实项目改名：

Copy the template and rename it to your real project:

```text
cp -r PROJECTS/_TEMPLATE PROJECTS/example-project
```

然后编辑 `PROJECTS/example-project/PROJECT.md`：
- 把 `workspace_root` 指向你的真实代码目录；
- 把 `project_id` 设为可读标识（也可用工作目录的 SHA256）。

Then edit `PROJECTS/example-project/PROJECT.md`:
- Set `workspace_root` to your real code directory.
- Set `project_id` to a readable id (or use the SHA256 of the working dir).

再编辑 `PROJECTS/example-project/ACTORS.md`，登记每个参与者：

Then edit `PROJECTS/example-project/ACTORS.md` to register each participant:

```markdown
- actor_id: SPEC
  role: SPEC
  ai_ide: {你的 AI IDE}
  expires_at: 2026-12-31
```

> 模板与字段说明见 `TEMPLATES/RegisterProject.md` 与 `TEMPLATES/RegisterActor.md`。
> *See `TEMPLATES/RegisterProject.md` and `TEMPLATES/RegisterActor.md` for field details.*

### 3.3 给每个 AI IDE 发一段接入提示词 / Onboard each AI IDE

不用自己拼提示词——直接用现成的 [接入提示词包 PROMPTS.md](PROMPTS.md)：把"总操作合同"复制给每个 AI IDE，再把对应角色那段追加进去即可。完整可粘贴内容（含无定时器唤醒句、常见坑）都在那里。

Don't hand-write the prompt — use the ready [Onboarding Prompts Pack / PROMPTS.md](PROMPTS.md): copy the master contract to each AI IDE, then append its role block. The full paste-ready content (including the no-timer wake line and common pitfalls) lives there.

> 想看一次真实周期的产物长什么样，见 [EXAMPLE.md](EXAMPLE.md)。
> *To see what one real cycle's artifacts look like, see [EXAMPLE.md](EXAMPLE.md).*

## 4. 跑通第一次完整协作 / Run your first full cycle

下面是从"下任务"到"验收"的最小一步到位流程。每一步都对应一个模板文件，放到指定目录即可。

Below is the minimum end-to-end flow from "issue a task" to "accept". Each step maps to a template file dropped into a specific directory.

### 4.1 SPEC 下发任务 / SPEC issues a task

1. 复制 `TEMPLATES/IssueSpec.md` → `PROJECTS/example-project/HANDOFF/S1_SPEC_TO_IMPL_<时间戳>.md`
2. 在 Payload 写清：阶段名、输入、交付物、验收标准、禁止行为、是否需要 TEST 初验。
3. 把 `BLACKBOARD.md` 阶段状态改为 `SpecIssued`。

1. Copy `TEMPLATES/IssueSpec.md` → `PROJECTS/example-project/HANDOFF/S1_SPEC_TO_IMPL_<timestamp>.md`
2. In the payload, state: stage, inputs, deliverables, acceptance criteria, prohibited acts, whether TEST first-verification is needed.
3. Set the blackboard stage to `SpecIssued`.

### 4.2 IMPL 认领并实现 / IMPL claims and implements

1. 复制 `TEMPLATES/ClaimTask.md` → `PROJECTS/example-project/CLAIMS/S1_CLAIM_IMPL_<时间戳>.md`
2. 在真实工作目录写代码并自检；把自检报告 / 证据索引写入 `EVIDENCE/`。
3. 复制 `TEMPLATES/SubmitImpl.md` → `HANDOFF/S1_IMPL_TO_TEST_<时间戳>.md`
4. 更新 `BLACKBOARD.md` 阶段为 `ImplSubmitted`。

1. Copy `TEMPLATES/ClaimTask.md` → `PROJECTS/example-project/CLAIMS/S1_CLAIM_IMPL_<timestamp>.md`
2. Write code in the real working dir and self-check; write the self-check report / evidence index into `EVIDENCE/`.
3. Copy `TEMPLATES/SubmitImpl.md` → `HANDOFF/S1_IMPL_TO_TEST_<timestamp>.md`
4. Set the blackboard stage to `ImplSubmitted`.

### 4.3 TEST 独立初验 / TEST first-verifies

1. 复制 `TEMPLATES/ClaimTask.md` → `CLAIMS/S1_CLAIM_TEST_<时间戳>.md`
2. 跑测试 / 对抗测试 / 回归测试；证据写入 `EVIDENCE/`。
3. 复制 `TEMPLATES/SubmitTestReport.md` → `HANDOFF/S1_TEST_TO_SPEC_IMPL_<时间戳>.md`
4. 更新 `BLACKBOARD.md` 阶段为 `TestReported`。

1. Copy `TEMPLATES/ClaimTask.md` → `CLAIMS/S1_CLAIM_TEST_<timestamp>.md`
2. Run tests / adversarial / regression; write evidence to `EVIDENCE/`.
3. Copy `TEMPLATES/SubmitTestReport.md` → `HANDOFF/S1_TEST_TO_SPEC_IMPL_<timestamp>.md`
4. Set the blackboard stage to `TestReported`.

### 4.4 SPEC 最终验收 / SPEC accepts

1. 读取 IMPL 交付、TEST 报告、EVIDENCE、AUDIT。
2. 满足验收标准 → 在 `HANDOFF/` 写 `AcceptStage` 信封（高风险结论用 `TEMPLATES/Audit.md` 写 `AUDIT/`）。
3. `BLACKBOARD.md` 阶段改为 `Accepted`。

1. Read IMPL delivery, TEST report, EVIDENCE, AUDIT.
2. If acceptance criteria are met → write an `AcceptStage` envelope in `HANDOFF/` (use `TEMPLATES/Audit.md` for high-risk rulings into `AUDIT/`).
3. Set the blackboard stage to `Accepted`.

> 完整字段与动作清单见 `PROTOCOL.md` 与 `ACTIONS.md`；分角色分步说明见 `RUNBOOKS/`。
> *Full field and action catalog: `PROTOCOL.md` and `ACTIONS.md`; role-by-role steps: `RUNBOOKS/`.*

## 5. 怎么看进度 / How to check progress

按顺序看，基本能掌握全局：

Read in this order to grasp the whole picture:

1. `PROJECTS/example-project/BLACKBOARD.md` —— 当前状态与历史（最新置顶）。
2. `HANDOFF/` —— 最新信封。
3. `CLAIMS/` —— 谁在做、是否过期 / 冲突。
4. `EVIDENCE/` —— 可复核证据索引。
5. `AUDIT/` —— 高风险动作留痕。
6. `HEARTBEAT/` —— 各参与者近期是否活动。

双击 `MONITOR/index.html` 可在浏览器里看只读看板（需先运行 `MONITOR/collect.ps1` 采集）。
*Double-click `MONITOR/index.html` for a read-only dashboard (run `MONITOR/collect.ps1` first to collect).*

## 6. 没有定时器怎么办 / No timer? No problem

很多 AI IDE 不能自己定时唤醒。用"人工唤醒"即可：

Many AI IDEs cannot wake themselves. Use "manual wake-up":

```text
请作为 {SPEC|IMPL|TEST|WATCHDOG} 运行一次 ai-collab loop。
```

Run one ai-collab loop as {SPEC|IMPL|TEST|WATCHDOG}.

AI IDE 扫描、处理、交付后，把心跳写为 `BatchComplete` 或 `PassiveNoTimer`。详见 README §8。
*After scanning / processing / delivering, write heartbeat `BatchComplete` or `PassiveNoTimer`. See README §8.*

## 7. 红线（千万别做）/ Red lines (must NOT)

- 不要把密钥、Token、Cookie、真实隐私写进任何文件。
- Never write keys, tokens, cookies, or real PII into any file.
- 不要让一个角色同时完成"实现 + 测试 + 验收"闭环。
- Never let one role close the implement–test–accept loop alone.
- 不要修改别人创建的信封；不要自审自验；不要用 UnitTest / SourceScan 冒充 Runtime 证据。
- Do not edit others' envelopes; do not self-verify; do not pass UnitTest / SourceScan off as Runtime evidence.
- 长任务不要在没有 ClaimLease 的情况下占用；高风险裁决必须写 `AUDIT/`。
- Do not hold long tasks without a ClaimLease; high-risk rulings must be written to `AUDIT/`.

## 8. 下一步 / Next steps

- 通读 `PROTOCOL.md`（总协议）、`ACTIONS.md`（动作库）、`STRUCTURE.md`（目录边界）。
- Read `PROTOCOL.md` (master protocol), `ACTIONS.md` (action catalog), `STRUCTURE.md` (directory boundaries).
- 按角色读 `ROLE_SPEC.md` / `ROLE_IMPL.md` / `ROLE_TEST.md` 与 `RUNBOOKS/`。
- Read `ROLE_SPEC.md` / `ROLE_IMPL.md` / `ROLE_TEST.md` and `RUNBOOKS/` for your role.
- 想立刻让 AI IDE 跑起来：把 [PROMPTS.md](PROMPTS.md) 的合同粘进每个 AI IDE；照着 [EXAMPLE.md](EXAMPLE.md) 抄一次完整周期。
- To get an AI IDE running now: paste the [PROMPTS.md](PROMPTS.md) contract into each AI IDE; copy one full cycle from [EXAMPLE.md](EXAMPLE.md).
- 想参与共建，见 `CONTRIBUTING.md`、路线图 `ROADMAP.md`、变更记录 `CHANGELOG.md`。
- To contribute, see `CONTRIBUTING.md`, `ROADMAP.md`, `CHANGELOG.md`.

> **可选增强（v1.2）**：如果项目有多个 stage 且希望 actor 轮询时自主推进，可启用 Project Plan 协议——SPEC 预先编排 stage 序列与各角色 prompt，actor 唤醒后直接读自己的 prompt 执行。详见 [PLAN.md](PLAN.md)。
> *Optional (v1.2): for multi-stage projects, the Project Plan protocol lets actors advance autonomously on wake-up by reading their own role prompt, instead of waiting for SPEC to issue each task. See [PLAN.md](PLAN.md).*
