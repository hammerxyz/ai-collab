<!-- 中文说明：任务认领 / ClaimLease 模板。长任务开工前必须先创建有效租约。 -->

# ClaimLease: {CLAIM_ID}

## Header
- claim_id: {CLAIM_ID}
- project_id: {PROJECT_ID or default}
- stage: {STAGE}
- actor_id: {ACTOR_ID}
- role: {SPEC | IMPL | TEST | CONSULTANT | QA}
- action: ClaimTask
- related_envelope: {ENVELOPE_ID}
- related_sequence_no: {INTEGER or none}
- blackboard_revision_seen: {REVISION}
- priority: {P0 | P1 | P2}
- created_at: {ISO8601}
- expires_at: {ISO8601}
- heartbeat_at: {ISO8601}
- status: Active

## Scope
- workspace_root: {absolute canonical path}
- path_fingerprint: {sha256:...}
- file_scope:
  - {path-or-scope}
- stage_scope:
  - {STAGE}
- exclusive: true

## Work Plan
- expected_outputs:
  - {workspace-relative path}
- expected_tests:
  - {command-or-test}
- estimated_effort: {text}

## Safety
- destructive_actions: none
- secrets_required: none
- rollback_plan: {text}
- artifact_policy: WorkspaceOnly

## Continuation
- continuation_file: none
- resume_instruction: {text}

## Audit
- created_by: {ACTOR_ID}
- updates:
  - {ISO8601} {ACTOR_ID} created claim
