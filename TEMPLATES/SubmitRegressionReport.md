<!-- 中文说明：回归测试报告信封模板。TEST 完成回归测试后填入并交付。 -->

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
- from: TEST
- to: SPEC, IMPL
- action: SubmitRegressionReport
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
  - {workspace-relative path or none}
- removed_files:
  - {workspace-relative path or none}
- excluded:
  - target/
  - .git/
- artifact_refs:
  - {workspace-relative report path}

### Test Summary

- related_impl_envelope: {ENVELOPE_ID}
- test_type: regression
- baseline_ref: {git commit hash 或基线标识}
- result: {PASS | CONDITIONAL | FAIL | BLOCKED}
- total: {N}
- passed: {N}
- failed: {N}
- blocked: {N}
- skipped: {N}

### Findings

1. {finding or none}

### Recommendation

{PASS | CONDITIONAL | FAIL | BLOCKED}

## Evidence

- {evidence_id or workspace-relative evidence path}

## Artifacts

- report_file: {workspace-relative path}
- artifact_policy: WorkspaceOnly
- blackboard_summary_only: true

## Status

- current: Submitted
- updated_at: {ISO8601}
- updated_by: TEST

## Audit

- {ISO8601} | TEST | Submitted regression test report
