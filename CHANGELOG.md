<!-- 中文：本文件记录 ai-collab 的版本变更。当前版本 v1.3。尚无自动发布流水线。 -->

# Changelog

All notable changes to ai-collab are documented here. The project follows a simple `vMAJOR.MINOR` scheme; there is no automated release pipeline yet.

## [v1.3] — current

**Core invariants formalized (方向 2) + Risk tagging Phase 1 (方向 3) + Violation log shared foundation**

- **核心不变量正式化**（`PROTOCOL.md` §1.2.1 新增）：3 条一阶不变量（控制面纯净性、权限隔离、证据可追溯）+ 1 条验证框架（状态机单调性）。裁决标准：是否需要全局状态。一阶不变量 actor 自判，单调性 WATCHDOG 事后执行。
- **方向 3 Phase 1 风险静态标注**（`ACTIONS.md` §〇 新增）：26 个动作标注 `reversible` + `blast_radius`，推导风险分级（Low 14 / Medium 5 / High 9，共 28 个动作含 plan 新增的 2 个）。Low 自动闭环，Medium 闭环+AUDIT，High 升级到人。纯标注，不动现有流程。
- **违规事件日志 schema v0.2**（共同地基）：新增 `SCHEMAS/violation.schema.json` + `VIOLATIONS/` 目录。9 字段（含 timestamp/severity/near_miss）+ 违规分类法（真违规/误报/兜底大类）。写入权归验收方。
- **PATTERNS.md** 新增：推荐模式的家，旧规则降级落点。初始含 3 条降级模式（P-001 心跳频率、P-002 证据强度分级、P-003 租约续期提前量）。actor 接入时确认已读。
- **WATCHDOG 检查项 21-24** 新增：核心不变量违反检查 + 违规日志记录。
- **SKILL.md / PROMPTS.md** 更新：加风险分级规则 + PATTERNS.md 读取自检。

**Compatibility**

- 完全向后兼容：所有改动都是"新增 + 标注"，不删除/重命名现有字段。现有项目无需改动即可运行。
- 真空期决策：v1.5 七步法裁决，标注"待社区复审"。社区出现后可追溯复审。

## [v1.2]

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
