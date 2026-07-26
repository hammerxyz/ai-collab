<!-- 中文说明：标准“下发规范”信封模板。复制后填入 stage / from / to / action 等字段，存放到 PROJECTS/{project_id}/HANDOFF/。 -->

# Envelope: {ENVELOPE_ID}

## Header
- envelope_id: {ENVELOPE_ID}
- project_id: {PROJECT_ID or default}
- sequence_no: {INTEGER}
- depends_on:
  - {ENVELOPE_ID or none}
- supersedes:
  - {ENVELOPE_ID or none}
- requires_blackboard_revision: {REVISION or none}
- stage: {STAGE}
- from: SPEC
- to: IMPL
- action: IssueSpec
- priority: {P0 | P1 | P2}
- risk_level: {Low | Medium | High}
- created_at: {ISO8601}
- expires_at: {ISO8601 or none}

## Payload
### Goal

{goal}

### Required Reading

- {path}

### Scope

{scope}

### Acceptance Criteria

1. {criterion}

### Constraints

- {constraint}

### Output Artifacts

- artifact_policy: WorkspaceOnly
- expected_workspace_outputs:
  - {workspace-relative path}
- blackboard_may_record_only:
  - filename
  - workspace-relative path
  - sha256
  - short summary

## Evidence

- {path or none}

## Status

- current: Submitted
- updated_at: {ISO8601}
- updated_by: SPEC

## Audit

- {ISO8601} | SPEC | Created IssueSpec

## 提交前自检  *(Pre-submit checklist)*

> 写入 HANDOFF/（或对应目录）前逐项确认。发现任一项不满足，先修正再提交。

- [ ] Header 全部字段已填写，无 `{...}` 占位符残留
- [ ] `envelope_id` / `trace_id` / `causation_id` 与实际协作链路一致
- [ ] `requires_blackboard_revision` 与 BLACKBOARD.md 顶部当前 revision 一致（如该字段适用）
- [ ] Payload 中引用的所有文件路径真实存在
- [ ] `requires_audit: true` 时，AUDIT/ 记录已同步写入
- [ ] 写入顺序符合 ORDERING.md §4：产出物 → 证据 → 本信封 → 最后更新黑板
- [ ] Scope 中的 file_scope 与本 stage 实际改动范围一致，无越界授权
