<!-- 中文说明：实现提交信封模板。IMPL 完成代码与自检后填入并交付。 -->

# Envelope: {ENVELOPE_ID}

## Header
- envelope_id: {ENVELOPE_ID}
- project_id: {PROJECT_ID or default}
- sequence_no: {INTEGER}
- depends_on:
  - {ENVELOPE_ID or none}
- supersedes:
  - {ENVELOPE_ID or none}
- requires_blackboard_revision: {REVISION}
- stage: {STAGE}
- from: IMPL
- to: TEST
- action: SubmitImpl
- priority: {P0 | P1 | P2}
- risk_level: {Low | Medium | High}
- created_at: {ISO8601}
- expires_at: {ISO8601 or none}

## Payload
### Workspace Projection

- project_id: {PROJECT_ID}
- workspace_root_ref: PROJECT.md#workspace_root
- projection_type: {git_diff | file_set | directory_snapshot}
- base_ref: {git commit hash or unknown}
- changed_files:
  - {workspace-relative path}
- added_files:
  - {workspace-relative path}
- removed_files:
  - {workspace-relative path or none}
- excluded:
  - target/
  - .git/
- artifact_refs:
  - {workspace-relative report path}

### Implementation Summary

### Tests

- command: {command}
- result: {PASS | FAIL | SKIPPED | CONDITIONAL}
- passed: {N}
- failed: {N}
- skipped: {N}

### Known Limits

- {limit or none}

### Self Check

- {workspace-relative path}

### Artifact Policy

- artifact_policy: WorkspaceOnly
- blackboard_summary_only: true

## Evidence

- {evidence_id or workspace-relative evidence path}

## Status

- current: Submitted
- updated_at: {ISO8601}
- updated_by: IMPL

## Audit

- {ISO8601} | IMPL | Submitted implementation
