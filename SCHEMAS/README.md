# AI-COLLAB Schemas

> **状态：非核心附录** | 本目录 Schema 为信封字段参考，无运行时校验器。v1.1 整改已将 Schema 校验从"强制机制"降级为"可选参考"。

> 版本：1.0 | 日期：2026-06-14 | 状态：规范态

本目录包含 ai-collab 关键数据结构的 JSON Schema 定义。

> **字段名映射说明**：ai-collab 在盘上的信封是 **Markdown** 文件（`HANDOFF/*.md`，结构见 `TEMPLATES/`），而非 JSON。本目录的 schema 是这些 Markdown 信封的**逻辑参考**，其字段名对应 Markdown 表头名：
> - `from` ↔ 信封表头 `from:`
> - `to` ↔ 信封表头 `to:`
> - `created_at` ↔ 信封表头 `created_at:`
> - `payload` ↔ 信封的 `## Payload` 段落
> 写信封时请以 `TEMPLATES/` 模板与 `EXAMPLE.md` 为准；本 schema 仅作可选核对，非强制。

## 使用方式

### 规范态（当前）

- Schema 作为 AI IDE 写文件时的参考约束
- 写入 RUNBOOKS 启动指令，AI IDE 按此结构生成文件
- 不实现运行时校验器

### 执行态（P1 未来）

- `lint.ps1` 可引用 schema 做自动校验
- schema parser 自动检查字段完整性

## Schema 清单

| 文件 | 对应结构 | 说明 |
|------|---------|------|
| project.schema.json | PROJECT.md | 项目定义结构约束 |
| actor.schema.json | ACTOR_PROFILES/*.json | Agent 能力声明结构约束 |
| envelope.schema.json | 信封 | 信封必填/选填字段 |
| claim.schema.json | ClaimLease | 租约结构约束 |
| heartbeat.schema.json | 心跳 | 心跳结构约束 |
| evidence.schema.json | 证据 | 证据结构约束 |
| monitor-status.schema.json | MONITOR/status.json | 看板状态结构约束 |
