<!-- 中文说明：高风险操作审计记录模板。AcceptStage / RejectStage / DeclareConflict / Frozen 等必须写入 AUDIT/。 -->

# Audit: {AUDIT_ID}

- timestamp: {ISO8601}
- project_id: {PROJECT_ID or default}
- actor: {SPEC | IMPL | TEST | WATCHDOG | CONSULTANT | QA | HUMAN}
- action: {ACTION}
- stage: {STAGE}
- risk_level: {Low | Medium | High}
- details: {details}
- evidence_refs:
  - {path}
- related_envelopes:
  - {ENVELOPE_ID}
- decision: {decision or none}
- blackboard_revision_seen: {revision or none}
