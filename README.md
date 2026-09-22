# AI-COLLAB 使用说明

> ai-collab platform version: v1.3 | 最后更新：2026-07-30

`AI-COLLAB` 是零运行时、纯文件系统的多 AI IDE 协作总线。用 Markdown / JSON 文件模拟轻量级 `CCP/CBB`（协作控制面 / 协作黑板），让不同 AI IDE 在 SPEC→IMPL→TEST→SPEC 流水线上按统一协议交接工作。

> **一句话**：非自动化平台，而是让多个人类/AI IDE"按同一套规矩交接工作"的协作协议与目录结构。

![ai-collab 协作循环动画](assets/ai-collab-demo.gif)
*SPEC 下发规范 → IMPL 实现并自测 → TEST 独立初验 → SPEC 验收（循环）*

---

## 它是什么 / 不是什么

- **文件系统协作总线**：根目录存协议和模板，项目操作写入 `PROJECTS/{project_id}/`。
- **多角色协作协议**：SPEC、IMPL、TEST、CONSULTANT、QA、WATCHDOG、HUMAN 各司其职。
- **可审计交付机制**：经 `HANDOFF/`、`CLAIMS/`、`EVIDENCE/`、`AUDIT/` 追踪每次交付。
- **不依赖任何 AI IDE 内部运行时或专有架构**。
- **不引入中央调度器**。协作由文件系统 + 定时器或人工唤醒驱动。

> 完整定义见 [PROTOCOL.md](PROTOCOL.md)。

---

## 5 分钟上手

1. **放仓库到共享位置** — 让所有 AI IDE 能读写同一仓库。
2. **每个 AI IDE 加载 [SKILL.md](SKILL.md)** — 可直接交给 AI IDE 执行的接入合同。
3. **选择角色，登记 Actor** — 用 `TEMPLATES/RegisterActor.md`。
4. **SPEC 下发任务** — 用 `TEMPLATES/RegisterProject.md` 创建项目 + `TEMPLATES/AssignTask.md` 分发。
5. **IMPL 认领并实现** — 用 `TEMPLATES/ClaimTask.md`，产出代码。
6. **TEST 独立初验** — 跑测试，写 `EVIDENCE/`。
7. **SPEC 验收** — 用 `TEMPLATES/AcceptStage.md` 通过后推进阶段。

详细操作手册：[QUICKSTART.md](QUICKSTART.md) | 可复制提示词：[PROMPTS.md](PROMPTS.md) | 完整样例：[EXAMPLE.md](EXAMPLE.md)

---

## 目录结构

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
├── ORDERING.md              # 读写顺序与依赖控制
├── PLAN.md                  # 可选 Project Plan 协议（v1.2，轮询自主推进）
├── PATTERNS.md              # 推荐模式（v1.3 新增，旧规则降级落点）
└── VIOLATIONS/              # 违规事件日志（v1.3 新增，非核心附录）
```

---

## 文档索引

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
| 可选 Project Plan 协议（多 stage 预编排 + 分角色 prompt） | [PLAN.md](PLAN.md) |
| 推荐模式（旧规则降级落点，v1.3 新增） | [PATTERNS.md](PATTERNS.md) |
| 违规事件日志（非核心附录，v1.3 新增） | [VIOLATIONS/README.md](VIOLATIONS/README.md) |
| 标准模板（信封/ClaimLease/审计/登记） | `TEMPLATES/` |
| JSON Schema（字段权威定义） | `SCHEMAS/` |
| 角色运行手册（SPEC/IMPL/TEST/WATCHDOG） | `RUNBOOKS/` |
| 只读浏览器看板 | `MONITOR/README.md` |
| 如何贡献 | [CONTRIBUTING.md](CONTRIBUTING.md) |
| 行为准则 | [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) |
| 安全漏洞报告 | [SECURITY.md](SECURITY.md) |
| 许可证 | [LICENSE](LICENSE) |

---

## 限制与风险

- 文件系统协作并发上限受底层文件系统制约（Windows 锁、网络共享延迟）。
- 无中央吊销机制——恶意或故障 AI IDE 可写入任何 Markdown；信任边界在协议层。
- 当前无自动化 CI 门禁；建议发布流程中增加 JSON 校验、链接检查、PowerShell 语法检查。
- 安全模型见 [SECURITY.md](SECURITY.md)。
