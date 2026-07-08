<!-- 中文说明：心跳目录说明。心跳只证明最近活动，不证明任务成功。 -->

# HEARTBEAT Directory

> **状态：可选信息（v1.1 降级）** | 心跳是 actor 自愿写的状态提示，不作为协作依赖。协作依赖黑板和信封。过期心跳不影响协作，仅作信息参考。

Root `HEARTBEAT/` is a global placeholder directory. It does not store concrete project actor liveness.

Normal project work should use:

```text
PROJECTS/{project_id}/HEARTBEAT/
```

Any concrete project heartbeat must be written under the matching project space. Root no longer stores concrete project state.

If non-README files appear here, WATCHDOG may flag a structure deviation and suggest migration to `PROJECTS/{project_id}/HEARTBEAT/`.

## File Naming

`{ACTOR}.json`

Examples:

- `SPEC.json`
- `IMPL.json`
- `TEST.json`

## Schema

```json
{
  "actor_id": "IMPL",
  "role": "IMPL",
  "project_id": "example-project-xxxxxxxx",
  "workspace_root_seen": "C:\\path\\project",
  "path_fingerprint_seen": "sha256:...",
  "timer_profile": "normal",
  "timer_supported": true,
  "status": "Idle | Scanning | Claimed | Working | Blocked | Paused | PassiveNoTimer | BatchComplete | NeedsHuman",
  "current_stage": "S2_PRE_S2_2L_BACKFILL",
  "active_claim_id": "S2_PRE_S2_2L_BACKFILL_CLAIM_IMPL_001",
  "last_heartbeat_at": "2026-06-13T21:30:00+08:00",
  "next_tick_at": "2026-06-13T21:40:00+08:00",
  "last_envelope_seen": "ENV-D2-PRE-D2-2L-BACKFILL-20260613T203100",
  "last_action": "ClaimTask",
  "notes": "No secrets. Short status only."
}
```

## Rules

- Heartbeat files are owned by their actor.
- In multi-project mode, heartbeat files live under `PROJECTS/{project_id}/HEARTBEAT/` and must include `project_id`.
- Do not put secrets, raw logs, or large output in heartbeat files.
- If the IDE has no timer, set `timer_supported` to `false` and `status` to `PassiveNoTimer` or `BatchComplete`.
- A stale heartbeat does not prove failure by itself; it may be referred to WATCHDOG attention (non-mandatory).
- A heartbeat with mismatched `workspace_root_seen` or `path_fingerprint_seen` does not authorize project work.
