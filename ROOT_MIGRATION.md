# AI-COLLAB Root 迁移策略

> **状态：非核心附录** | 本文件为根迁移历史记录，迁移已完成。v1.1 整改将其归入附录层。

> 版本：1.0 | 日期：2026-06-14

---

## 背景

ai-collab 的结构边界要求：根目录只管协议/模板/工具，具体项目操作写入 `PROJECTS/{project_id}/`。根目录的占位目录（HANDOFF/CLAIMS/HEARTBEAT/EVIDENCE/AUDIT）不应出现具体项目文件。

当 WATCHDOG 发现根占位目录出现项目文件时，触发 RootProjectStateViolation 处理流程。

---

## 处理流程

```text
1. WATCHDOG 发现根占位目录出现项目文件
2. WATCHDOG 报告 RootProjectStateViolation（写 SyncStatus / RecordRisk）
3. SPEC 或 HUMAN 发起 MigrateRootState 动作
4. 迁移由 HUMAN 或被授权 actor 执行
5. 迁入 PROJECTS/{project_id}/_MIGRATED_FROM_ROOT/
6. 活跃文件迁入正式项目目录
7. 历史原件保留迁移归档
8. 迁移动作写入项目 AUDIT/
9. WATCHDOG 复核迁移结果
```

---

## 硬规则

- **WATCHDOG 不执行任何有副作用的文件操作**（迁移、删除、修改），只检查和报告
- 迁移必须由 SPEC 或 HUMAN 发起
- 迁移后原文件不删除，保留在 `_MIGRATED_FROM_ROOT/` 归档
- 迁移动作必须写入项目 `AUDIT/`

---

## 迁移目标目录

```text
PROJECTS/{project_id}/_MIGRATED_FROM_ROOT/
├── HANDOFF/          # 从根 HANDOFF/ 迁入的项目信封
├── CLAIMS/           # 从根 CLAIMS/ 迁入的项目租约
├── BLACKBOARD.md     # 从根迁入的黑板内容
└── README.md         # 迁移说明
```

---

## 审计记录格式

迁移完成后，在 `PROJECTS/{project_id}/AUDIT/` 中写入：

```markdown
# RootMigration

- 时间：{ISO8601}
- 执行方：{SPEC / HUMAN}
- 迁移文件列表：
  - HANDOFF/{file} → _MIGRATED_FROM_ROOT/HANDOFF/{file}
  - CLAIMS/{file} → _MIGRATED_FROM_ROOT/CLAIMS/{file}
- 活跃文件迁入：
  - {file} → HANDOFF/{file}
- 复核状态：WATCHDOG 复核通过 / 待复核
```
