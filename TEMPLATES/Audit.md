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

## 提交前自检  *(Pre-submit checklist)*

> 写入 HANDOFF/（或对应目录）前逐项确认。发现任一项不满足，先修正再提交。

- [ ] Header 全部字段已填写，无 `{...}` 占位符残留
- [ ] `envelope_id` / `trace_id` / `causation_id` 与实际协作链路一致
- [ ] `requires_blackboard_revision` 与 BLACKBOARD.md 顶部当前 revision 一致（如该字段适用）
- [ ] Payload 中引用的所有文件路径真实存在
- [ ] `requires_audit: true` 时，AUDIT/ 记录已同步写入
- [ ] 写入顺序符合 ORDERING.md §4：产出物 → 证据 → 本信封 → 最后更新黑板
- [ ] 关联的高风险动作信封 ID 引用完整
- [ ] 本记录为 append-only，未修改任何既有条目
