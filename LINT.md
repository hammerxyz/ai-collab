# AI-COLLAB 结构校验规则（LINT）

> **状态：非核心附录** | 本文件为 AI IDE prompt 自检参考，无自动校验脚本。v1.1 整改已将 LINT 从"强制机制"降级为"可选参考"。

> 版本：1.0 | 日期：2026-06-14 | 状态：规范态
> 说明：本文件定义 ai-collab 的结构守卫规则。当前为规范态，由人和AI IDE在prompt中遵守；P1阶段将实现 `lint.ps1` 自动校验。

---

## 规则清单

### [STRUCT] 目录结构

| ID | 规则 | 严重级别 | 说明 |
|----|------|---------|------|
| S01 | 根目录占位目录（HANDOFF/CLAIMS/HEARTBEAT/EVIDENCE/AUDIT）不得出现非 README 文件 | HIGH | 具体项目文件必须放在 PROJECTS/{id}/ 下 |
| S02 | 根目录 MONITOR/ 不得保存含具体项目状态的持久文件 | HIGH | status.json 归项目，根目录只放 UI/工具/schema |
| S03 | 每个项目必须有 PROJECT.md、ACTORS.md、BLACKBOARD.md | HIGH | 缺一则项目不完整 |
| S04 | 项目信封必须带 project_id | HIGH | 无 project_id 的信封无法路由 |
| S05 | project_id 必须与项目目录名一致 | MEDIUM | 防止路由错误 |

### [REF] 引用完整性

| ID | 规则 | 严重级别 | 说明 |
|----|------|---------|------|
| R01 | depends_on 引用的信封必须存在或已终态 | HIGH | 防止悬空依赖 |
| R02 | requires_blackboard_revision 不得指向过旧版本 | MEDIUM | 防止基于过期状态操作 |
| R03 | evidence/audit 引用路径必须存在 | HIGH | 证据不可虚指 |

### [CONTENT] 内容约束

| ID | 规则 | 严重级别 | 说明 |
|----|------|---------|------|
| C01 | blackboard 不得包含大段 artifact 正文 | MEDIUM | 只写索引和摘要，正文放 EVIDENCE/ |
| C02 | 信封 payload 不得包含完整文件内容 | LOW | 只引用路径，不内联代码 |

### [AUTH] 权限

| ID | 规则 | 严重级别 | 说明 |
|----|------|---------|------|
| A01 | actor 未在 ACTORS.md 登记不得处理项目任务 | HIGH | 未登记 = 无权操作 |
| A02 | WATCHDOG 不得执行有副作用的文件操作 | HIGH | 只检查和报告，不迁移/删除/修改 |

### [ROOT] 根目录边界

| ID | 规则 | 严重级别 | 说明 |
|----|------|---------|------|
| RT01 | 根目录出现项目文件时报告 RootProjectStateViolation | HIGH | 由 WATCHDOG 报告，SPEC/HUMAN 执行迁移 |
| RT02 | 迁移由 SPEC 或 HUMAN 发起，WATCHDOG 只复核 | HIGH | 防止 WATCHDOG 越权 |

### [SECRET] 安全扫描

| ID | 规则 | 严重级别 | 说明 |
|----|------|---------|------|
| SC01 | 禁止包含 token/key/password/cookie/.env 内容 | CRITICAL | 命中即 BLOCKED |
| SC02 | 命中后只引用文件名、行号、pattern，不回显原 secret | CRITICAL | 防止二次泄漏 |
| SC03 | AI IDE 不得自行判定误报并继续 | HIGH | 误报需走 FalsePositiveClaimed → ClearedByHuman 流程 |

### [KNOWLEDGE] 全局知识边界

> 注：KNOWLEDGE/ 目录暂未建立，本规则暂不生效。

| ID | 规则 | 严重级别 | 说明 |
|----|------|---------|------|
| K01 | KNOWLEDGE/ 不得包含项目名称、路径、完整报告、代码、测试输出 | HIGH | 只收通用协作模式 |
| K02 | 进入 KNOWLEDGE/ 必须有 HUMAN 或 SPEC 审核 | HIGH | 防止自动沉淀 |
| K03 | 项目细节进入 KNOWLEDGE/ 时报告 KnowledgeScopeViolation | MEDIUM | WATCHDOG 检查 |

---

## Secret Scan 检测模式

```text
检测目标：
- 常见 token pattern: ghp_, gho_, sk-, xox[bpas]-
- .env 文件内容引用
- private key header: -----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----
- cookie/session 值: session_id=, connect.sid=
- API key 高熵字符串（连续20+字符的 base64/hex）
```

### 误报处理状态链

```text
SecretDetected 状态流转：
- BLOCKED: 默认状态，禁止继续提交
- FalsePositiveClaimed: actor 声称误报，但不能自行解除
- ClearedByHuman: HUMAN/SPEC 审核解除

规则：
- AI IDE 不能自行把 secret 判断为误报并继续
- 命中后只引用文件名、行号、pattern，不回显原 secret
- 清理后需要重新跑 lint 或 WATCHDOG 复核
```

---

## 执行方式

### 规范态（当前）

- AI IDE 提交信封前应按本文件自检
- WATCHDOG 每次扫描时按本文件做 prompt 检查
- 命中 CRITICAL/HIGH 规则时必须阻塞或报告

### 执行态（P1 未来）

- `LINT_ENGINE.md`：定义 `lint.ps1` 的行为规范
- `lint.ps1`：自动化校验脚本
- schema parser：自动校验
- 自动 report

当前不实现运行时校验器，不暗示已有自动校验能力。
