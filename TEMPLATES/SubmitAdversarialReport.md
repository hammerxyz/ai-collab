<!-- 中文说明：对抗性测试报告信封模板。TEST 完成对抗性测试后填入并交付。 -->

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
- action: SubmitAdversarialReport
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
- test_type: adversarial
- attack_vector: {描述对抗手段，如边界输入 / 异常负载 / 竞态 / 提示注入}
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

- {ISO8601} | TEST | Submitted adversarial test report

## 提交前自检  *(Pre-submit checklist)*

> 写入 HANDOFF/（或对应目录）前逐项确认。发现任一项不满足，先修正再提交。

- [ ] Header 全部字段已填写，无 `{...}` 占位符残留
- [ ] `envelope_id` / `trace_id` / `causation_id` 与实际协作链路一致
- [ ] `requires_blackboard_revision` 与 BLACKBOARD.md 顶部当前 revision 一致（如该字段适用）
- [ ] Payload 中引用的所有文件路径真实存在
- [ ] `requires_audit: true` 时，AUDIT/ 记录已同步写入
- [ ] 写入顺序符合 ORDERING.md §4：产出物 → 证据 → 本信封 → 最后更新黑板
- [ ] 对抗用例数、通过数、失败清单三项齐全
