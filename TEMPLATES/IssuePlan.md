<!-- 中文说明：plan 下发/修订信封模板。SPEC 编写完 plan 后复制此模板填入并交付，存放到 PROJECTS/{project_id}/HANDOFF/。 -->

# Envelope: {ENVELOPE_ID}

## Header
- protocol_version: v1.1
- envelope_id: {ENVELOPE_ID}
- trace_id: {PLAN-{UUID}}
- causation_id: {上游信封ID或none}
- project_id: {PROJECT_ID}
- sequence_no: {INTEGER}
- depends_on:
  - {ENVELOPE_ID or none}
- supersedes:
  - {ENVELOPE_ID or none}        # 修订时引用旧 IssuePlan 信封
- requires_blackboard_revision: {REVISION or none}
- stage: PLAN                    # plan 不属于具体 stage，用 PLAN 标识
- from: SPEC
- to: ALL                        # plan 影响所有角色
- action: IssuePlan | RevisePlan
- message_type: Command
- priority: P0                   # plan 是项目级编排，默认 P0
- risk_level: High               # plan 修订属高风险
- reversibility: NeedsHuman      # plan 生效/修订需 HUMAN 签字
- requires_audit: true
- created_at: {ISO8601}
- expires_at: {ISO8601 or none}
- summary: {一句话 plan 摘要，如 v1 plan 含 5 个 stage linear 序列}

## Payload

### Plan Reference
- plan_id: PLAN-{UUID}
- plan_version: v1
- supersedes_plan: none | {PLAN-old-UUID}
- plan_path: plans/PLAN.md       # workspace-relative
- plan_sha256: {hash}
- requirements_ref: requirements.md
- requirements_sha256: {hash}

### Sequencing
- mode: linear | dag | parallel_groups
- total_stages: {N}

### Stages Summary
| stage_id | name | depends_on | risk_level | qa_gate | consultant_gate |
|----------|------|------------|------------|---------|-----------------|
| S1 | {name} | [] | Low | required | optional |
| S2 | {name} | [S1] | Medium | required | optional |
| S3 | {name} | [S2] | High | required | required |
| ... | ... | ... | ... | ... | ... |

### Prompt Files Index
| stage_id | spec_ref | impl_prompt_ref | test_prompt_ref | acceptance_ref |
|----------|----------|-----------------|-----------------|----------------|
| S1 | plans/S1/spec.md | plans/S1/impl_prompt.md | plans/S1/test_prompt.md | plans/S1/acceptance.md |
| S2 | ... | ... | ... | ... |

### Cross-cutting Guides
- consultant_guide_ref: plans/consultant_guide.md
- qa_checklist_ref: plans/qa_checklist.md

### Revision Reason（仅 RevisePlan 填写）
- 修订原因: {text}
- 影响范围: {哪些 stage 受影响}
- 已 Accepted stage 不受影响声明: true

### Review Gates
- consultant_review_required: true
- qa_review_required: true
- human_accept_required: true

### Artifact Policy
- artifact_policy: WorkspaceOnly
- plan 正文保留在 {workspace_root}/plans/
- 信封 payload 只含索引和 sha256，不内联 plan 正文

## Evidence
- {workspace-relative plan 路径 + sha256，或 none}

## Status
- current: Submitted              # Draft -> Submitted -> UnderReview -> Accepted | Rejected
- updated_at: {ISO8601}
- updated_by: SPEC

## Audit
- {ISO8601} | SPEC | Created IssuePlan v1
- {ISO8601} | CONSULTANT | Reviewed, Pass/Veto   # 复核后追加
- {ISO8601} | QA | Reviewed, Pass/Veto            # 复核后追加
- {ISO8601} | HUMAN | Accepted/Rejected           # HUMAN 签字后追加

## 提交前自检  *(Pre-submit checklist)*

> 写入 HANDOFF/（或对应目录）前逐项确认。发现任一项不满足，先修正再提交。

- [ ] Header 全部字段已填写，无 `{...}` 占位符残留
- [ ] `envelope_id` / `trace_id` / `causation_id` 与实际协作链路一致
- [ ] `requires_blackboard_revision` 与 BLACKBOARD.md 顶部当前 revision 一致（如该字段适用）
- [ ] Payload 中引用的所有文件路径真实存在
- [ ] `requires_audit: true` 时，AUDIT/ 记录已同步写入
- [ ] 写入顺序符合 ORDERING.md §4：产出物 → 证据 → 本信封 → 最后更新黑板
- [ ] plan_sha256 与 {workspace_root}/plans/PLAN.md 实际文件哈希一致
- [ ] review gates 三项（consultant/qa/human）与 PLAN.md §五.1 流程一致
