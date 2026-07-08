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
