# PROJECTS：项目空间、登记与软鉴权

`PROJECTS/` 用来区分不同开发项目的协作空间。它解决一个核心问题：多个 AI IDE 被定时器唤醒后，必须先确认“我现在服务的是哪个项目、和哪些 actor 协作、允许处理哪些信封”，而不是在全局 `ai-collab/` 中混扫所有任务。

---

## 1. 核心原则

1. **按实际项目路径绑定协作空间**：项目身份以真实工作目录为根，不以聊天上下文或模型自称为准。
2. **控制面和产出物分离**：`ai-collab` 只保存协作控制信息；代码、报告、测试结果、计划文档等项目产出物必须保留在实际工作目录中。
3. **黑板只放索引，不放正文**：项目黑板只能记录文件名、状态、阶段、actor、时间戳和短摘要；不得粘贴完整产出物内容。
4. **登记鉴权是软约束**：本目录能做路径绑定、角色登记和冲突检查，但不能替代 OS 权限、Git 权限、CI 权限或人类审批。

---

## 2. 推荐目录结构

新项目推荐使用项目空间：

```text
PROJECTS/
└── {project_id}/
    ├── PROJECT.md          # 项目登记、路径绑定、产出物策略
    ├── ACTORS.md           # 本项目允许参与的 AI IDE / 人类角色
    ├── BLACKBOARD.md       # 本项目黑板，只写文件名/索引/状态
    ├── HANDOFF/            # 本项目交付信封
    ├── CLAIMS/             # 本项目任务认领
    ├── HEARTBEAT/          # 本项目 actor 心跳
    ├── EVIDENCE/           # 本项目证据索引，不存大段原始输出
    └── AUDIT/              # 本项目审计日志
```

根目录下的 `HANDOFF/`、`CLAIMS/`、`HEARTBEAT/`、`EVIDENCE/`、`AUDIT/` 只作为全局占位目录。正常项目操作必须由 `PROJECTS/{project_id}/` 承接。

### 2.1 根目录职责

根目录只承接：

- 协议文档；
- 动作定义；
- 模板；
- 角色手册；
- 全局监控；
- 空占位目录，用于发现误写根目录的结构偏差。

根目录不应承接：

- 新项目的活跃任务；
- 新项目的 ClaimLease；
- 新项目的测试证据索引；
- 新项目的高风险审计；
- 新项目的完整产出物。

### 2.2 项目目录职责

每个实际开发项目必须有自己的项目目录：

```text
PROJECTS/{project_id}/
```

项目级任务只扫描、认领、交付、测试和审计该目录下的文件。

---

## 3. project_id 规则

`project_id` 应稳定、可读、低冲突：

```text
{project_slug}-{path_hash8}
```

示例：

```text
example-project-xxxxxxxx
ai-collab-9f8e7d6c
```

其中：

- `project_slug`：项目目录名或人类指定短名。
- `path_hash8`：规范化绝对路径的 SHA256 前 8 位。

路径哈希不是秘密，只用于降低误接入风险。

---

## 4. PROJECT.md 必需字段

每个项目空间必须有：

```markdown
# Project: {project_id}

## Header
- project_id: {project_id}
- project_name: {human readable name}
- workspace_root: {absolute canonical path}
- path_fingerprint: {sha256:...}
- artifact_policy: WorkspaceOnly
- artifact_root: {workspace-relative folder or "."}
- created_at: {ISO8601}
- status: {Active | Paused | Archived}

## Scope
- allowed_roots:
  - {absolute canonical path}
- forbidden_roots:
  - {path or none}

## Collaboration
- blackboard: PROJECTS/{project_id}/BLACKBOARD.md
- handoff_dir: PROJECTS/{project_id}/HANDOFF
- claims_dir: PROJECTS/{project_id}/CLAIMS
- heartbeat_dir: PROJECTS/{project_id}/HEARTBEAT
- evidence_dir: PROJECTS/{project_id}/EVIDENCE
- audit_dir: PROJECTS/{project_id}/AUDIT

## Artifact Rule
- project outputs stay under workspace_root.
- blackboard stores filenames/indexes only.
- full content must live in workspace artifacts, evidence artifacts, or source files.
```

---

## 5. ACTORS.md 必需字段

每个项目空间必须有：

```markdown
# Actors: {project_id}

| actor_id | role | ai_ide | authorized | workspace_root_seen | path_fingerprint_seen | expires_at | notes |
|---|---|---|---|---|---|---|---|
| SPEC | SPEC | AI IDE | true | C:\path\project | sha256:... | 2026-06-14T00:00:00+08:00 | human approved |
```

AI IDE 只有在以下条件同时满足时，才能处理项目内信封：

1. `actor_id` 已登记；
2. `authorized` 为 `true`；
3. 当前工作目录规范化后位于 `workspace_root` 下；
4. 当前路径指纹与 `path_fingerprint_seen` 或项目 `path_fingerprint` 匹配；
5. 当前时间未超过 `expires_at`；
6. 角色权限允许执行目标动作。

如果不满足，应写 `RequestProjectRegistration` 或 `EscalateToHuman`，不得继续执行。

---

## 6. 项目空间选择流程

AI IDE 每次启动或定时唤醒时，先执行：

```text
1. 取得当前工作目录 canonical path。
2. 扫描 PROJECTS/*/PROJECT.md。
3. 找到 workspace_root 能覆盖当前路径的项目。
4. 如果多个项目匹配，选择路径最长的 workspace_root。
5. 校验 path_fingerprint。
6. 校验 ACTORS.md 中自身 actor_id、role、expires_at。
7. 只处理该 project_id 下的 HANDOFF/、CLAIMS/、HEARTBEAT/、EVIDENCE/、AUDIT/。
```

找不到项目时，不应自动落到其它项目空间；应请求人类或 SPEC 注册项目。

## 6.1 创建项目空间步骤

1. 计算 `project_id`。
2. 创建 `PROJECTS/{project_id}/`。
3. 从 `PROJECTS/_TEMPLATE/` 复制 `PROJECT.md`、`ACTORS.md`、`BLACKBOARD.md`。
4. 创建 `HANDOFF/`、`CLAIMS/`、`HEARTBEAT/`、`EVIDENCE/`、`AUDIT/`。
5. 填写 `workspace_root`、`path_fingerprint` 和初始 actor。
6. 后续所有该项目协作都写入该项目目录。

---

## 7. 产出物位置规则

所有项目产出物必须保留在实际工作目录中，例如：

```text
{workspace_root}/plans/...
{workspace_root}/target/...
{workspace_root}/docs/...
{workspace_root}/tests/...
{workspace_root}/reports/...
```

项目黑板中只能写：

- 文件名；
- workspace-relative 短路径；
- artifact_id；
- evidence_id；
- sha256；
- 1~2 句短摘要；
- 状态、时间戳、actor。

项目黑板中不得写：

- 完整报告正文；
- 大段日志；
- 大段代码；
- 密钥或 token；
- 真实隐私数据；
- 可执行脚本正文。

---

## 8. 软鉴权边界

本机制能防止大多数“模型误扫项目、误处理信封、误接入角色”的协作错误，但它不是强安全边界。

| 能做到 | 做不到 |
|---|---|
| 基于路径和 actor 登记筛选任务 | 阻止恶意进程直接改文件 |
| 发现 actor 角色越权 | 替代系统 ACL |
| 发现跨项目写入 | 替代 Git branch protection |
| 发现过期登记或心跳 | 保证定时器一定运行 |
| 记录人类 override | 替代人类真实审批 |

如需硬鉴权，应由外部 wrapper、CI、Git 权限、文件 ACL 或专用服务实现。
