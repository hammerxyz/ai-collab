# AUDIT 目录

根目录 `AUDIT/` 是全局占位目录，不承接具体项目审计日志。

正常项目任务应使用：

```text
PROJECTS/{project_id}/AUDIT/
```

任何具体项目 audit 都必须写入对应项目空间。根目录不再保留具体项目情况。

如果这里出现非 README 文件，WATCHDOG 应标记为结构偏差，并要求迁移到 `PROJECTS/{project_id}/AUDIT/`。

## 命名规则

`{TIMESTAMP}_{ACTION}_{ACTOR}.md`

- TIMESTAMP: ISO8601紧凑格式
- ACTION: 动作名（AcceptStage, RejectStage, DeclareBlock等）
- ACTOR: 操作方（SPEC, IMPL, TEST）

## 审计日志格式

见 PROTOCOL.md 第六节。

## 必须审计的操作

- AcceptStage / RejectStage（High）
- DeclareBlock / ResolveBlock（Medium）
- DeclareConflict（High）
- Frozen（High）
- Superseded / Withdrawn（Medium，当影响活跃任务时）
- Expired Claim with side effects（Medium/High）
- Human override（High）

## 建议索引

当审计文件变多时，维护 `AUDIT_INDEX.md` 或 `AUDIT_LEDGER.jsonl`，至少记录：

- audit_id
- timestamp
- actor
- action
- stage
- risk_level
- related_envelopes
- evidence_refs
