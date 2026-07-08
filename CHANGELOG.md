<!-- 中文：本文件记录 ai-collab 的版本变更。当前版本 v1.1。尚无自动发布流水线。 -->

# Changelog

All notable changes to ai-collab are documented here. The project follows a simple `vMAJOR.MINOR` scheme; there is no automated release pipeline yet.

## [v1.1] — current

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
