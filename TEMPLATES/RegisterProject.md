<!-- 中文说明：新项目登记模板。首次接入项目时填入 PROJECTS/INDEX.md 与 PROJECTS/{project_id}/。 -->

# Envelope: {ENVELOPE_ID}

## Header
- envelope_id: {ENVELOPE_ID}
- project_id: {project_id}
- stage: PROJECT_REGISTRATION
- from: {HUMAN | SPEC | CONSULTANT}
- to: ALL
- action: RegisterProject
- priority: P0
- risk_level: Medium
- created_at: {ISO8601}
- expires_at: {ISO8601 or none}

## Payload
### Project
- project_name: {name}
- workspace_root: {absolute canonical path}
- path_fingerprint: {sha256:...}
- artifact_policy: WorkspaceOnly
- artifact_root: {workspace-relative folder or "."}

### Scope
- allowed_roots:
  - {absolute canonical path}
- forbidden_roots:
  - {none or path}

### Initial Actors
- SPEC: {actor_id or TBD}
- IMPL: {actor_id or TBD}
- TEST: {actor_id or TBD}

## Evidence
- none

## Status
- current: Submitted
- updated_at: {ISO8601}
- updated_by: {HUMAN | SPEC}

## Audit
- {timestamp} project registration requested

## 提交前自检  *(Pre-submit checklist)*

> 写入 HANDOFF/（或对应目录）前逐项确认。发现任一项不满足，先修正再提交。

- [ ] Header 全部字段已填写，无 `{...}` 占位符残留
- [ ] `envelope_id` / `trace_id` / `causation_id` 与实际协作链路一致
- [ ] `requires_blackboard_revision` 与 BLACKBOARD.md 顶部当前 revision 一致（如该字段适用）
- [ ] Payload 中引用的所有文件路径真实存在
- [ ] `requires_audit: true` 时，AUDIT/ 记录已同步写入
- [ ] 写入顺序符合 ORDERING.md §4：产出物 → 证据 → 本信封 → 最后更新黑板
- [ ] project_id 命名符合"短名 + 工作目录指纹"约定
- [ ] workspace_root 路径真实存在且可读

