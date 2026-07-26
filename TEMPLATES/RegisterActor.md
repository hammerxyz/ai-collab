<!-- 中文说明：actor 登记模板。登记 actor_id / role / expires_at / path_fingerprint。 -->

# Envelope: {ENVELOPE_ID}

## Header
- envelope_id: {ENVELOPE_ID}
- project_id: {project_id}
- stage: ACTOR_REGISTRATION
- from: {SPEC | IMPL | TEST | WATCHDOG | CONSULTANT | QA | HUMAN}
- to: SPEC,HUMAN
- action: RegisterActor
- priority: P1
- risk_level: Medium
- created_at: {ISO8601}
- expires_at: {ISO8601}

## Payload
### Actor
- actor_id: {SPEC | IMPL | TEST | ...}
- role: {SPEC | IMPL | TEST | WATCHDOG | CONSULTANT | QA | HUMAN}
- ai_ide: {AI IDE | Other}
- timer_supported: {true | false}
- timer_profile: {interactive | normal | long_running | manual_only}

### Project Binding
- workspace_root_seen: {absolute canonical path}
- path_fingerprint_seen: {sha256:...}
- requested_scope:
  - {stage or path scope}

### Safety
- secrets_required: none
- destructive_actions_allowed: false

## Evidence
- none

## Status
- current: Submitted
- updated_at: {ISO8601}
- updated_by: {actor_id}

## Audit
- {timestamp} actor registration requested

## 提交前自检  *(Pre-submit checklist)*

> 写入 HANDOFF/（或对应目录）前逐项确认。发现任一项不满足，先修正再提交。

- [ ] Header 全部字段已填写，无 `{...}` 占位符残留
- [ ] `envelope_id` / `trace_id` / `causation_id` 与实际协作链路一致
- [ ] `requires_blackboard_revision` 与 BLACKBOARD.md 顶部当前 revision 一致（如该字段适用）
- [ ] Payload 中引用的所有文件路径真实存在
- [ ] `requires_audit: true` 时，AUDIT/ 记录已同步写入
- [ ] 写入顺序符合 ORDERING.md §4：产出物 → 证据 → 本信封 → 最后更新黑板
- [ ] actor_id / role / ide 标识与 SCHEMAS/actor.schema.json 字段一致

