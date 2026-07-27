<!-- 中文：本文件记录 ai-collab 的版本变更。当前版本 v1.2。尚无自动发布流水线。 -->

# Changelog

All notable changes to ai-collab are documented here. The project follows a simple `vMAJOR.MINOR` scheme; there is no automated release pipeline yet.

## [v1.2] — current

**Plan protocol (optional, zero-runtime)**

- New optional **Project Plan Protocol** (`PLAN.md`): SPEC pre-arranges the stage sequence plus per-role prompt sources, so actors can advance autonomously on poll wake-up instead of waiting for SPEC to issue `IssueSpec` on demand for every stage.
- New actions **`IssuePlan`** and **`RevisePlan`** (`ACTIONS.md`). CONSULTANT/QA review results reuse the existing `SyncStatus` action with a `review_type` payload field — no new review actions introduced.
- New templates `TEMPLATES/IssuePlan.md` (plan envelope) and `TEMPLATES/PlanPrompt.md` (per-role prompt structures: impl_prompt / test_prompt / acceptance / consultant_guide / qa_checklist).
- `stage_scope` extension field on ClaimTask for stage-level mutual exclusion (documented in `CLAIMS/README.md`; rides on the existing `additionalProperties: true` in `claim.schema.json`, no schema change).
- Three-layer concurrency gating: plan-level `depends_on` / `gate_state` / `parallel_with`, claim-level `stage_scope`, and blackboard segmented revision (each actor updates only its own stage row).
- Machine-readable gates: `qa_gate` / `consultant_gate` / `gate_state` / `risk_level` fields in plan; WATCHDOG checks 15–20 added as optional reference (`WATCHDOG.md`).
- Plan generation flow: HUMAN writes `requirements.md` → SPEC drafts plan → CONSULTANT + QA review → HUMAN accepts. Revision via `RevisePlan` with `supersedes` + mandatory `AUDIT/`; already-Accepted stages are immutable history.
- Docs updated: plan-mode section in all `ROLE_*.md`, plan Loop branch in `SKILL.md` (step 6.1), `plans/` directory section in `STRUCTURE.md` (§4.1), plan-driven scenario 2 in `EXAMPLE.md`.
- Pre-submit self-check sections added to all envelope templates in `TEMPLATES/`.

**Compatibility**

- Fully backward compatible: plan is **opt-in**. Envelope schema and `protocol_version: v1.1` are unchanged — the two new actions do not alter the envelope field structure. Projects without a plan run the original SPEC→IssueSpec flow unchanged.
- No runtime introduced: the plan protocol is pure Markdown convention; all progress still depends on actors voluntarily following the protocol after wake-up.

## [v1.1]

**Protocol**
- Envelope upgraded from the legacy 9-field envelope to a **20-field envelope** (`SCHEMAS/envelope.schema.json`).
- Added **eight-layer arbitration** and **ten-level evidence strength** (SourceScan → RealProvider → Adversarial …).
- Added the **CONSULTANT** and **QA** roles (process stewardship & quality review); the core principle is now separation of three powers + consultant judgment + quality review.

**Structure & tooling**
- `PROJECTS/{project_id}/` project-space model with `PROJECT.md`, `ACTORS.md`, `BLACKBOARD.md`, `BLACKBOARD_ARCHIVE/`, `EVIDENCE/`, `AUDIT/`, `MEMORY/`, `ACTOR_PROFILES/`.
- `SCHEMAS/` JSON Schema for envelope / claim / evidence / actor / project / heartbeat / monitor-status.
- `MONITOR/` read-only browser dashboard (`index.html` + `collect.ps1`).
- `ATOMIC_WRITE.md` atomic-write convention to reduce concurrent-write conflicts.
- `MEMORY_POLICY.md` four-tier memory (Working / Episodic / Semantic / Procedural).
- `TIMER_LOOP.md` four timer profiles (`interactive` / `normal` / `long_running` / `manual_only`) with graceful degradation.
- `LINT.md` structure-validation rules (reference integrity, secret scan, root-boundary).

**Philosophy**
- Explicitly **prompt-only, no runtime, no lock-in**; the bus is a "road", not a platform.

## [v1.0] — legacy

- Initial collaboration bus with a **9-field envelope** and the core SPEC / IMPL / TEST roles.
- Basic `HANDOFF/` + `BLACKBOARD.md` handoff; no CONSULTANT / QA, no JSON Schema, no monitor.
