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

## 提交前自检  *(Pre-submit checklist)*

> 写入 HANDOFF/（或对应目录）前逐项确认。发现任一项不满足，先修正再提交。

- [ ] Header 全部字段已填写，无 `{...}` 占位符残留
- [ ] `envelope_id` / `trace_id` / `causation_id` 与实际协作链路一致
- [ ] `requires_blackboard_revision` 与 BLACKBOARD.md 顶部当前 revision 一致（如该字段适用）
- [ ] Payload 中引用的所有文件路径真实存在
- [ ] `requires_audit: true` 时，AUDIT/ 记录已同步写入
- [ ] 写入顺序符合 ORDERING.md §4：产出物 → 证据 → 本信封 → 最后更新黑板
- [ ] file_scope 与任务源一致（plan 模式：与 impl_prompt.md/test_prompt.md 一致；传统模式：与 IssueSpec 一致）
- [ ] plan 模式下 stage_scope 已填写且与 plan stage_id 一致
