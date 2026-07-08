# AI-COLLAB Schemas

> **状态：非核心附录** | 本目录 Schema 为信封字段参考，无运行时校验器。v1.1 整改已将 Schema 校验从"强制机制"降级为"可选参考"。

> 版本：1.0 | 日期：2026-06-14 | 状态：规范态

本目录包含 ai-collab 关键数据结构的 JSON Schema 定义。

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
