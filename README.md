# AI-COLLAB 使用说明  *(AI-COLLAB Usage Guide)*

> ai-collab platform version: v1.1 | 最后更新：2026-07-11
> ai-collab platform version: v1.1 | Last updated: 2026-07-11

`AI-COLLAB` 是一个零运行时、纯文件系统的多 AI IDE 协作总线。它用 Markdown / JSON 文件模拟轻量级 `CCP/CBB`（协作控制面 / 协作黑板），让不同 AI IDE 在 SPEC→IMPL→TEST→SPEC 的标准流水线上按统一协议交接工作。

`AI-COLLAB` is a zero-runtime, filesystem-based collaboration bus for multiple AI IDEs. It uses Markdown / JSON files to emulate a lightweight `CCP/CBB` (Collaboration Control Plane / Collaboration Blackboard), letting different AI IDEs hand off work on the standard SPEC→IMPL→TEST→SPEC pipeline under one shared protocol.

> **一句话**：它不是一个自动化平台，而是一套让多个人类/AI IDE"按同一套规矩交接工作"的协作协议与目录结构。
> *In one line: it is not an automation platform, but a collaboration protocol and directory structure that lets multiple humans / AI IDEs "hand off work by the same rules".*

![ai-collab 协作循环动画](assets/ai-collab-demo.gif)
*SPEC 下发规范 → IMPL 实现并自测 → TEST 独立初验 → SPEC 验收（无限循环）*
*SPEC issues spec → IMPL implements & self-checks → TEST first-verifies → SPEC accepts (looping)*

---

## 它是什么 / 不是什么  *(What it is, and is not)*

- **文件系统协作总线**：根目录保存协议和模板，具体项目操作写入 `PROJECTS/{project_id}/`。
- **多角色协作协议**：SPEC、IMPL、TEST、CONSULTANT、QA、WATCHDOG、HUMAN 各司其职。
- **可审计交付机制**：通过 `HANDOFF/`、`CLAIMS/`、`EVIDENCE/`、`AUDIT/` 追踪每次交付。
- **不依赖任何 AI IDE 内部运行时或专有架构**。
- **不引入中央调度器**。协作由文件系统 + 定时器或人工唤醒驱动。

> 完整定义见 [PROTOCOL.md](PROTOCOL.md)。

---

## 5 分钟上手  *(5-minute quick start)*

1. **放仓库到共享位置** — 让所有 AI IDE 能读写同一仓库。
2. **每个 AI IDE 加载 [SKILL.md](SKILL.md)** — 这是可直接交给 AI IDE 执行的接入合同。
3. **选择角色，登记 Actor** — 用 `TEMPLATES/RegisterActor.md`。
4. **SPEC 下发任务** — 用 `TEMPLATES/RegisterProject.md` 创建项目 + `TEMPLATES/AssignTask.md` 分发。
5. **IMPL 认领并实现** — 用 `TEMPLATES/ClaimTask.md`，然后产出代码。
6. **TEST 独立初验** — 跑测试，写 `EVIDENCE/`。
7. **SPEC 验收** — 用 `TEMPLATES/AcceptStage.md` 通过后推进阶段。

详细操作手册：[QUICKSTART.md](QUICKSTART.md) | 可复制提示词：[PROMPTS.md](PROMPTS.md) | 完整样例：[EXAMPLE.md](EXAMPLE.md)

---

## 目录结构  *(Directory structure)*

```
<ai-collab>/
├── PROTOCOL.md              # 协作协议（权威规范）
├── ACTIONS.md               # 标准协作动作（CBB）
├── STRUCTURE.md             # 目录边界说明
├── SKILL.md                 # AI IDE 接入合同
├── QUICKSTART.md            # 操作手册
├── PROMPTS.md               # 可复制提示词
├── EXAMPLE.md               # 完整样例
├── README.md                # 本文件
├── PROJECTS/                # 多项目空间
│   ├── INDEX.md             #   项目索引
│   └── {project_id}/
│       ├── PROJECT.md
│       ├── ACTORS.md
│       ├── BLACKBOARD.md
│       ├── HANDOFF/         #   信封交接
│       ├── CLAIMS/          #   租约
│       ├── HEARTBEAT/       #   心跳
│       ├── EVIDENCE/        #   证据
│       └── AUDIT/           #   审计
├── TEMPLATES/               # 标准模板（信封/租约/审计）
├── SCHEMAS/                 # JSON Schema（单一事实源）
├── RUNBOOKS/                # 角色运行手册
├── MONITOR/                 # 只读浏览器看板
├── TIMER_LOOP.md            # 定时器驱动协作循环
└── ORDERING.md              # 读写顺序与依赖控制
```

---

## 文档索引  *(Document index)*

| 想看什么 | 读哪个 |
|----------|--------|
| 完整协议规范（角色、信封、黑板、审计、冲突） | [PROTOCOL.md](PROTOCOL.md) |
| 所有可用动作及调用规范 | [ACTIONS.md](ACTIONS.md) |
| 目录边界与职责划分 | [STRUCTURE.md](STRUCTURE.md) |
| AI IDE 接入合同（可直接交给 AI IDE） | [SKILL.md](SKILL.md) |
| 5 分钟操作手册 | [QUICKSTART.md](QUICKSTART.md) |
| 可复制粘贴的提示词 | [PROMPTS.md](PROMPTS.md) |
| 从头到尾的完整协作样例 | [EXAMPLE.md](EXAMPLE.md) |
| 定时器驱动协作循环 | [TIMER_LOOP.md](TIMER_LOOP.md) |
| 读写顺序与 revision 控制 | [ORDERING.md](ORDERING.md) |
| 标准模板（信封/ClaimLease/审计/登记） | `TEMPLATES/` |
| JSON Schema（字段权威定义） | `SCHEMAS/` |
| 角色运行手册（SPEC/IMPL/TEST/WATCHDOG） | `RUNBOOKS/` |
| 只读浏览器看板 | `MONITOR/README.md` |
| 如何贡献 | [CONTRIBUTING.md](CONTRIBUTING.md) |
| 行为准则 | [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) |
| 安全漏洞报告 | [SECURITY.md](SECURITY.md) |
| 许可证 | [LICENSE](LICENSE) |

---

## 限制与风险  *(Limits and risks)*

- 文件系统协作的并发上限受制于底层文件系统（Windows 锁、网络共享延迟）。
- 没有中央吊销机制——恶意或故障 AI IDE 可以写入任何 Markdown；信任边界在协议层。
- 当前没有自动化 CI 门禁；建议在发布流程中增加 JSON 校验、链接检查、PowerShell 语法检查。
- 安全模型说明见 [SECURITY.md](SECURITY.md)。
