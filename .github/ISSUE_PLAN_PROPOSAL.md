# Proposal: Project Plan Protocol (optional enhancement for polling-based autonomous advancement)

## Summary

Propose an optional `plan` protocol on top of v1.1 platform. Plan is a stage sequence plus per-role prompt sources pre-arranged by SPEC, so multiple actors can autonomously advance on poll wake-up based on detailed prompts, instead of waiting for SPEC to write IssueSpec on demand each time.

**Zero-runtime preserved.** Plan is pure Markdown; no scheduler, no script, no auto-advance.

## Motivation

Current v1.1 flow requires SPEC to issue IssueSpec envelope for each stage. This creates a bottleneck when:
- Multiple AI IDEs poll concurrently but have nothing to do until SPEC wakes up
- Multi-stage projects need predictable sequencing without SPEC's real-time coordination
- Each role (IMPL/TEST) reads the same IssueSpec, leading to scope leakage (IMPL sees test plan, TEST sees impl hints)

Plan solves this by:
1. Pre-arranging stage sequence + per-role prompts before execution starts
2. Letting actors read their role-specific prompt file on wake-up
3. Adding explicit gates (qa_gate / consultant_gate) so CONSULTANT/QA blocking rights are machine-readable

## Design

### Core invariants (unchanged)
- Zero runtime: plan is Markdown only
- Backward compatible: plan is optional; projects without plan keep original SPEC->IssueSpec flow
- Three-power separation: acceptance still belongs to SPEC; CONSULTANT/QA gate but don't replace
- Bus uniqueness: plan delivered via IssuePlan/RevisePlan envelopes, never bypasses bus
- Control-plane/artifact separation: plan body in `{workspace_root}/plans/`, control plane only has thin pointer

### Key design decisions
1. **Plan source**: HUMAN writes requirements.md -> SPEC transforms into plan -> CONSULTANT+QA review -> HUMAN accepts
2. **Plan location**: plan body is artifact (workspace), NOT control plane (PROJECTS/{id}/). Blackboard top gets `active_plan` pointer only.
3. **Per-role prompts**: each stage has `impl_prompt.md` / `test_prompt.md` / `acceptance.md` so roles see only their own duties
4. **Concurrency**: 3-layer gating — plan-level stage gates (depends_on/gate_state/parallel_with) + claim stage_scope extension + blackboard segmented revision
5. **CONSULTANT/QA blocking**: strategic gates (plan issue/revise + High-risk stage) for CONSULTANT; tactical gates (every AcceptStage) for QA. Both via SyncStatus envelope (not new action).
6. **Revision**: RevisePlan envelope with supersedes + AUDIT. Accepted stages are immutable history.
7. **No auto-advance**: plan does not auto-advance stages. SPEC still issues AcceptStage.

### New actions (2)
- `IssuePlan` (SPEC->ALL, Command, High risk)
- `RevisePlan` (SPEC->ALL, Command, High risk, supersedes old)

### New WATCHDOG checks (6)
Checks 15-20 for plan gate violations, stage_scope conflicts, plan location violations, missing QA/CONSULTANT gates.

## Files changed (14 files, ~30KB increment)

| Category | Files |
|----------|-------|
| New protocol doc | PLAN.md (19.6KB) |
| New templates | TEMPLATES/IssuePlan.md (3.1KB), TEMPLATES/PlanPrompt.md (7.1KB) |
| Action table | ACTIONS.md (+1.5KB: IssuePlan/RevisePlan) |
| Mechanism docs | CLAIMS/README.md (+1KB: stage_scope), WATCHDOG.md (+1KB: checks 15-20) |
| Role docs | ROLE_SPEC/IMPL/TEST/CONSULTANT/QA.md (+5KB: plan mode section) |
| Onboarding | SKILL.md (+1.2KB: plan Loop branch), STRUCTURE.md (+1.2KB: plans/ dir) |
| Example | EXAMPLE.md (+6.8KB: plan-driven scenario) |

## What is NOT changed
- PROTOCOL.md (no iron rules modified)
- Existing 24 actions (no removal/rename)
- Existing 14 WATCHDOG checks (no modification)
- claim.schema.json (stage_scope uses existing additionalProperties:true)
- SCHEMAS/* (no new required schemas)

## Risks and mitigations

| Risk | Mitigation |
|------|-----------|
| Plan bloat (too many stages) | CONSULTANT review catches at plan generation |
| Prompt file divergence from actual impl | RevisePlan flow + AUDIT |
| Concurrent blackboard writes | Segmented revision (only own stage row) |
| Actor ignores gates | WATCHDOG checks 15-20 + DeclareConflict |
| Plan mode becomes mandatory | Explicit "optional" in all docs + backward compat section |

## Open questions for discussion

1. Should plan support `auto_advance: true` for low-risk P2 stages (skip SPEC AcceptStage)? **Current proposal: NO** (violates three-power separation). Open for community input.
2. Should there be a plan-mode-specific schema in SCHEMAS/? **Current proposal: NO** (v1.1 downgraded schemas to optional reference; plan follows same convention).
3. Should EXAMPLE.md scenario 2 be split into its own file? **Current proposal: NO** (keeps comparison visible).

## Compliance with CONTRIBUTING.md

- [x] No central runtime/scheduler/server introduced
- [x] No AI IDE vendor lock-in
- [x] No specific model/Web AI names
- [x] Bilingual convention followed (Facade docs use section-level CN/EN interleaving; others use EN with CN header note)
- [x] No-runtime boundary documented (plan is explicitly optional, never a prerequisite)
- [x] Issue opened before PR (this issue)

## Next steps after discussion

1. Incorporate feedback
2. Open PR referencing this issue
3. Update CHANGELOG.md
4. Tag as v1.2-plan-protocol (optional extension, does not bump core v1.1)
