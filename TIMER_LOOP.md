<!-- 中文说明：定时器驱动协作循环定义（四种模式 + 降级规则）。无定时器的 AI IDE 见 README §8。 -->

# AI-COLLAB Timer Loop

> **状态：可选参考（v1.1 降级）** | 本文件为定时循环操作参考，无自动定时器。AI IDE 在需要时参考执行，非强制。

> Scope: generic multi-AI-IDE collaboration. This is not tied to any specific agent or IDE.
> Purpose: let AI IDE, AI IDE, AI IDE or other AI IDEs cooperate through the filesystem bus even when humans are not constantly watching.

## 1. Model

`ai-collab` is a filesystem-based collaboration bus. Root files define protocol and templates; project work should live under `PROJECTS/{project_id}/`:

- `PROJECTS/{project_id}/HANDOFF/` is the project message queue.
- `PROJECTS/{project_id}/CLAIMS/` is the project lease table.
- `PROJECTS/{project_id}/HEARTBEAT/` is project actor liveness.
- `PROJECTS/{project_id}/EVIDENCE/` is project shared proof index.
- `PROJECTS/{project_id}/AUDIT/` is project high-risk and exception logging.
- `PROJECTS/{project_id}/BLACKBOARD.md` is the project human-readable status snapshot plus history.

Root-level `HANDOFF/`, `CLAIMS/`, `HEARTBEAT/`, `EVIDENCE/`, and `AUDIT/` are placeholder directories only. Timers must not write concrete project work there.

Timers do not grant authority. A timer only wakes an AI IDE so it can scan, claim, execute its role, and write structured artifacts.

## 2. Timer Profiles

| Profile | Poll interval | Lease TTL | Heartbeat interval | Use case |
|---|---:|---:|---:|---|
| `interactive` | 2 min | 20 min | 5 min | human actively supervising |
| `normal` | 10 min | 90 min | 15 min | ordinary async collaboration |
| `long_running` | 30 min | 6 h | 30 min | build, soak, large review |
| `manual_only` | none | none | none | IDE has no scheduler |

Each actor writes its selected profile into `HEARTBEAT/{ACTOR}.json`.

## 3. Common Loop

Every timer tick, an actor must:

1. Read `PROTOCOL.md`, `ACTIONS.md`, `STRUCTURE.md`, `TIMER_LOOP.md`, `PROJECTS/README.md`, `ORDERING.md`, role runbook, and current project `BLACKBOARD.md`.
2. Resolve the active project space from the current workspace path. In multi-project mode, use `PROJECTS/{project_id}/`.
3. Validate actor registration in `PROJECTS/{project_id}/ACTORS.md` when a project space is used.
4. Read project `HEARTBEAT/` to understand active actors.
5. Read project `CLAIMS/` and identify active, expired, or conflicting claims.
6. Read project `HANDOFF/` for envelopes addressed to its role or `ALL`, ordered by `sequence_no`, `depends_on`, and `created_at`.
7. Ignore envelopes with terminal status: `Accepted`, `Rejected`, `Frozen`, `Superseded`, `Withdrawn`, `Expired`.
8. If work is available and no valid claim conflicts, create or refresh a `ClaimLease`.
9. Execute only actions allowed for its role in `ACTIONS.md`.
10. Keep project outputs in the real workspace; write only filenames/indexes/hashes into blackboard/evidence indexes.
11. Write evidence before submitting implementation/test/acceptance claims.
12. Append or create a new envelope instead of mutating another actor's envelope.
13. Update `BLACKBOARD.md` snapshot and append history when state changes.
14. Update its heartbeat.

## 4. Role-Specific Dispatch

| Role | Timer scans for | Typical action |
|---|---|---|
| SPEC | `RequestSpecClarification`, `SubmitTestReport`, `DeclareConflict`, expired high-risk claims | clarify, accept, reject, escalate |
| IMPL | `IssueSpec`, `RequestImplFix`, reopened `Conditional` tasks | claim, implement, self-check, submit |
| TEST | `SubmitImpl`, `SubmitSelfCheck`, adversarial test requests | test, report, request fix |

An actor must not process work for another role unless the envelope explicitly names it and role permissions allow the action.

## 5. Claim Lease Rules

Before doing non-trivial work, IMPL or TEST must create a claim file:

`CLAIMS/{STAGE}_CLAIM_{ACTOR}_{YYYYMMDDTHHMMSS}.md`

A claim is active only when:

- `status` is `Active`;
- `expires_at` is in the future;
- `heartbeat_at` is recent enough for the selected profile;
- `file_scope` does not conflict with another active claim.

Expired claims do not authorize continued work. The actor may renew the claim by writing a new claim or updating its own claim with a new heartbeat and expiry.

## 6. Heartbeat Rules

Each actor writes:

`HEARTBEAT/{ACTOR}.json`

The heartbeat records:

- actor id and role;
- profile;
- current stage;
- active claim id;
- heartbeat time;
- next planned tick;
- current status.

If an actor cannot safely continue, heartbeat status must become `Blocked`, `Paused`, or `NeedsHuman`.

## 7. Timeout Handling

When a claim exceeds its TTL:

1. WATCHDOG records `ClaimExpired`.
2. `BLACKBOARD.md` marks the stage `Blocked` or returns it to `SpecIssued`, depending on whether partial side effects exist.
3. A new `SyncStatus` or `DeclareBlock` envelope is created.
4. Another actor may claim only after the expired claim is recorded.

No actor may silently continue from another actor's expired workspace state.

## 8. No Native Timer Fallback

Some AI IDEs cannot self-wake on a timer. They must use one of these patterns:

| Pattern | Description | Required artifact |
|---|---|---|
| Human wakeup | Human periodically opens the IDE and says "run your ai-collab loop" | updated heartbeat |
| External scheduler | OS Task Scheduler, cron, CI, or automation launches the IDE/task wrapper | scheduler note in heartbeat |
| Watchdog-only passive mode | IDE does no background work; WATCHDOG detects pending tasks and humans reassign | `status: PassiveNoTimer` |
| Batch handoff mode | IDE works only on explicitly handed files and exits after submitting artifacts | `status: BatchComplete` |

If an IDE has no timer, it must not claim long-running work with an auto-renewing lease. It can claim only work that it can complete in the current session, or it must mark the claim `ManualContinuationRequired`.

In multi-project mode, a no-timer IDE must also write which `project_id` it handled in heartbeat or continuation notes. It must not claim a task from one project and write outputs into another project workspace.

## 9. Persistence for Long Tasks

For work expected to exceed one timer tick, the actor must write a continuation note:

`CLAIMS/{STAGE}_CONTINUATION_{ACTOR}_{TS}.md`

It must include:

- completed steps;
- current file scope;
- remaining steps;
- risks;
- next resume command or prompt;
- evidence already produced;
- rollback or cleanup notes.

This prevents context loss when an AI IDE restarts.

## 10. Prohibited Timer Behavior

- A timer must not auto-accept implementation without TEST and SPEC gates.
- A timer must not auto-freeze any stage.
- A timer must not mutate another actor's envelope or claim.
- A timer must not hide expired claims by renewing after a long silence without recording the gap.
- A timer must not run destructive commands unless the role runbook and human authorization allow it.
- A timer must not store secrets in heartbeat, claim, evidence, or handoff files.
- A timer must not process a project task before project and actor registration are validated.
- A timer must not write full project artifacts into `BLACKBOARD.md`; only indexes and short summaries are allowed.
- A timer must not bypass `ORDERING.md` dependency or revision checks.
- A timer must not write concrete project work into root-level placeholder directories.

## 11. Minimum Ready-To-Run Check

Before enabling timer-driven collaboration, verify:

- `HEARTBEAT/README.md` exists.
- `SCHEMAS/claim.schema.json` exists.
- `WATCHDOG.md` exists.
- role runbooks exist under `RUNBOOKS/`.
- templates exist under `TEMPLATES/`.
- `STRUCTURE.md` exists for root/project directory boundaries.
- `PROJECTS/README.md` exists for multi-project mode.
- `ORDERING.md` exists for read/write ordering.
- project `PROJECTS/{project_id}/BLACKBOARD.md` has a clear current-state snapshot and append-only history.
