# AI-COLLAB 目录结构边界

`AI-COLLAB` 采用"根目录管协议，项目子目录管操作"的结构。

---

## 1. 推荐结构

```text
ai-collab/
├── README.md                 # 总入口
├── PROTOCOL.md               # 协议
├── ACTIONS.md                # 动作定义
├── ORDERING.md               # 读写顺序
├── TIMER_LOOP.md             # 定时循环
├── WATCHDOG.md               # 看门狗规则
├── STRUCTURE.md              # 目录结构边界（本文件）
├── ROLE_SPEC.md        # SPEC 角色手册
├── ROLE_IMPL.md     # IMPL 角色手册
├── ROLE_TEST.md   # TEST 角色手册
├── ROLE_CONSULTANT.md        # CONSULTANT 角色手册（v1.1 新增）
├── ROLE_QA.md                # QA 角色手册（v1.1 新增）
├── LINT.md                   # 结构校验规则（非核心附录）
├── ATOMIC_WRITE.md           # 原子写入约定（非核心附录）
├── MEMORY_POLICY.md          # 记忆策略（非核心附录）
├── ROOT_MIGRATION.md         # 根迁移策略（非核心附录）
├── RUNBOOKS/                 # 角色手册
├── TEMPLATES/                # 通用模板
├── SCHEMAS/                  # JSON Schema 定义（非核心附录）
├── BRIDGE/                   # 桥接接口
├── MONITOR/                  # 可选只读监控
├── PROJECTS/                 # 项目空间主入口
│   ├── _TEMPLATE/            # 新项目空间模板
│   └── {project_id}/
│       ├── PROJECT.md        # 项目登记
│       ├── ACTORS.md         # actor登记
│       ├── README.md         # 项目入口
│       ├── BLACKBOARD.md     # 项目黑板
│       ├── HANDOFF/          # 项目信封
│       ├── CLAIMS/           # 项目租约
│       ├── HEARTBEAT/        # 项目心跳
│       ├── EVIDENCE/         # 项目证据索引
│       ├── AUDIT/            # 项目审计
│       └── VIOLATIONS/       # 项目违规日志（v1.5 新增，非核心附录）
├── HANDOFF/                  # 根级占位目录，不承接具体项目任务
├── CLAIMS/                   # 根级占位目录，不承接具体项目任务
├── HEARTBEAT/                # 根级占位目录，不承接具体项目任务
├── EVIDENCE/                 # 根级占位目录，不承接具体项目任务
├── AUDIT/                    # 根级占位目录，不承接具体项目任务
└── VIOLATIONS/               # 根级占位目录，违规日志说明（v1.5 新增）
```

---

## 2. 根目录职责

根目录是控制协议层，负责：

- 说明工具用法；
- 定义动作和角色权限；
- 提供模板；
- 提供项目空间创建规则；
- 提供定时器和顺序规则；
- 提供可选只读监控；
- 提供空占位目录，供 WATCHDOG 发现误写根目录的结构偏差。

根目录不应承接新项目活跃任务。

---

## 3. 项目子目录职责

每个实际开发项目须用独立子目录：

```text
PROJECTS/{project_id}/
```

项目子目录负责：

- 绑定实际工作目录；
- 登记参与 actor；
- 存项目黑板；
- 存项目信封；
- 存项目 ClaimLease；
- 存项目心跳；
- 存项目证据索引；
- 存项目审计。

---

## 4. 实际项目工作目录职责

实际开发项目目录负责保存完整产出物：

- 代码；
- 计划；
- prompt；
- 测试报告；
- benchmark 输出；
- 运行日志；
- 构建产物；
- 真实 evidence artifact。

`ai-collab` 中只存索引、相对路径、hash、状态和短摘要。

### 4.1 plans/ 目录（plan 模式可选）

> 仅当项目启用 plan 模式时存在（详见 PLAN.md）。无 plan 的项目毋庸此目录。

`{workspace_root}/plans/` 存放 plan 正文（产出物层，禁写入 PROJECTS/{project_id}/ 控制面）：

```text
{workspace_root}/plans/
├── PLAN.md                           # 总编排：stage 序列 + 依赖 + 门控
├── consultant_guide.md               # CONSULTANT 全局研判要点
├── qa_checklist.md                   # QA 全局检查清单
├── requirements.md                   # HUMAN 写的项目需求（plan 输入，可在 plans/ 上级）
└── S{N}/                             # 每个 stage 一个子目录
    ├── spec.md                       # stage 规范正文
    ├── impl_prompt.md                # IMPL 的详细 prompt
    ├── test_prompt.md                # TEST 的详细 prompt
    └── acceptance.md                 # SPEC 的验收 checklist
```

控制面只保留薄索引：PROJECT.md 加 `requirements_ref` / `active_plan` 指针，BLACKBOARD.md 顶部加 `active_plan` 指针。

---

## 5. 新项目创建流程

1. 规范化实际项目路径。
2. 计算路径 SHA256，取前 8 位作 `path_hash8`。
3. 创建 `project_id = {project_slug}-{path_hash8}`。
4. 创建 `PROJECTS/{project_id}/`。
5. 复制 `PROJECTS/_TEMPLATE/PROJECT.md`、`ACTORS.md`、`BLACKBOARD.md`。
6. 创建 `HANDOFF/`、`CLAIMS/`、`HEARTBEAT/`、`EVIDENCE/`、`AUDIT/`。
7. 填写项目路径、路径指纹、actor 登记。
8. 后续该项目所有协作操作都写入该项目子目录。

---

## 6. 根级占位目录

根目录的 `HANDOFF/`、`CLAIMS/`、`HEARTBEAT/`、`EVIDENCE/`、`AUDIT/` 只作占位目录，不保留具体项目情况。

若这些目录中出现非 `README.md` 文件，视为结构偏差：

- 停止处理该根目录文件；
- 据项目路径或信封 `project_id` 判断目标项目空间；
- 迁移或请求人类迁移到 `PROJECTS/{project_id}/`；
- 在项目 `AUDIT/` 或 WATCHDOG 同步中记录。

项目空间已存在时，AI IDE 须只用项目空间。
