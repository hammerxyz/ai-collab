# AI-COLLAB Collaboration Protocol (CCP — Collaboration Communication Protocol)

> Version: 1.3 | Effective Date: 2026-07-30 (v1.3: formalization of core invariants / Direction 3 Phase 1 risk annotation; v1.1 remediation upgrade; core protocol unchanged in v1.2, plan is an optional extension)
> Design Reference: CCP collaboration bus architecture, purely prompt-driven, file system as the bus

---

## I. General Provisions

### 1.1 Purpose

Establish a structured collaboration protocol among multiple AI IDEs, enabling multi-party AI IDEs via the file system to achieve:

- Task allocation and claiming
- Deliverable handoff and acceptance
- State synchronization and audit traceability
- Conflict detection and resolution

### 1.2 Core Principles

| Principle | Description | Design Reference |
|------|------|-----------|
| Bus Uniqueness | All collaboration MUST go through the `ai-collab/` directory; direct private connections are prohibited | CCP Iron Law |
| Envelope Structure | All deliverables MUST use the standard Envelope format | CBB Standard Actions |
| State Traceability | actor state transitions and the close of each work round MUST be recorded in the project BLACKBOARD.md, with the newest entry placed at the top | Ghost State Prohibition |
| Audit Without Gaps | High-risk operations MUST be written to the AUDIT/ directory | Audit Enforcement |
| Separation of Three Powers | Specification/implementation/acceptance MUST be handled by different parties; self-acceptance is prohibited | Execution/Goal/Oversight Separation |

### 1.2.1 Core Invariants

> Confirmed in v1.5 (seven-step method adjudication; vacuum-period decisions pending community review). Core invariants are the irreducible kernel of the 5 core principles above. An actor only needs to uphold 3 first-order invariants to be compliant; the remaining rules are downgraded to recommended patterns (see `PATTERNS.md`).

**Adjudication Criterion**: Does verifying a violation of this invariant require global state?
- No global state needed (locally decidable) → First-order invariant (used directly by actors when making decisions)
- Global state needed → Verification framework (used by WATCHDOG post-hoc)

**3 first-order invariants + 1 verification framework**:

| # | Invariant | Type | Locally Decidable? | Meaning |
|---|--------|------|-----------|------|
| 1 | **Control Plane Purity** | First-order | Yes | All control-plane messages MUST go through HANDOFF, with no bypass; the control plane stores only pointers, while deliverables reside in the workspace |
| 2 | **Permission Isolation** | First-order | Yes | SPEC/IMPL/TEST MUST NOT be held by the same actor concurrently; HUMAN is the top of the arbitration chain |
| 3 | **Evidence Traceability** | First-order | Yes | All conclusions MUST have evidence chains, with graded strength |
| 4 | **State Machine Monotonicity** | Verification framework | No (requires global state) | Any legitimate operation may only move the system state "closer to the goal" or to a "known safe zone"; irreversible entropy increase is strictly prohibited (unless an explicit rollback mechanism exists) |

**Relationship to the existing 5 core principles**: Invariants are the irreducible kernel of the principles. Principle 1 (Bus Uniqueness) + Principle 2 (Envelope Structure) → Invariant 1; Principle 5 (Separation of Three Powers) → Invariant 2; Principle 3 (State Traceability) + Principle 4 (Audit Without Gaps) → Invariant 3. Invariant 4 (Monotonicity) is a newly added verification framework, used to check whether other invariants are violated and for regression verification when old rules are downgraded.

**Falsifiable Adjudication Executor**: Layered execution — first-order invariants are self-adjudicated by actors (at decision time, because locally decidable); the monotonicity framework is executed by WATCHDOG (post-hoc, because it requires global state).

**Old Rule Downgrade Mechanism**: Downgraded rules are "relocated" to `PATTERNS.md` rather than "deleted". Three-way triage: derivable from invariants → delete; not derivable but useful → recommended pattern; not derivable and useless → deprecate. Three gates: ① Announcement period (deprecated lives for one version cycle, default 3 months); ② Data proof (violation detection never triggered or derivable from invariants); ③ Regression verification (state machine monotonicity rescan).

### 1.3 Collaborator Definitions

| Role | AI IDE | Responsibility Domain | Abbreviation |
|------|--------|--------|------|
| Specification Planning + Acceptance | AI IDE | Specification writing, plan formulation, final acceptance, cross-stage interface definition | SPEC |
| Code Implementation + Self-Check | AI IDE | Code implementation, unit testing, self-check reports, STUB elimination | IMPL |
| Test Preliminary Acceptance | AI IDE | Black-box/white-box testing, stage preliminary acceptance, adversarial testing, regression testing | TEST |

> **v1.1 Extended Roles**:
>
> | Role | Executor | Responsibility | Abbreviation |
> |------|--------|------|------|
> | Trend Control | AI IDE / Human | Review architectural direction, prevent deviation from goals | CONSULTANT |
> | Process Quality | AI IDE / Human | Review process compliance and evidence integrity | QA |
> | Health Check | AI IDE / Human | Scan blackboard, heartbeats, leases; flag structural deviations and conflicts | WATCHDOG |
> | Final Adjudication | Human | Conflict adjudication, irreversible operations such as Accept/Reject/Frozen | HUMAN |

---

## II. Directory Structure

```
<ai-collab>
├── PROTOCOL.md          # This file — collaboration protocol
├── ACTIONS.md           # Standard collaboration actions (CBB)
├── STRUCTURE.md         # Directory structure boundaries: root manages protocol, project subdirectories manage operations
├── PROJECTS/            # Multi-project space, project registration, actor registration
│   └── {project_id}/
│       ├── PROJECT.md
│       ├── ACTORS.md
│       ├── BLACKBOARD.md
│       ├── HANDOFF/
│       ├── CLAIMS/
│       ├── HEARTBEAT/
│       ├── EVIDENCE/
│       └── AUDIT/
├── HANDOFF/             # Root-level placeholder directory, does not accept specific project tasks
├── CLAIMS/              # Root-level placeholder directory, does not accept specific project tasks
├── HEARTBEAT/           # Root-level placeholder directory, does not accept specific project tasks
├── EVIDENCE/            # Root-level placeholder directory, does not accept specific project tasks
├── AUDIT/               # Root-level placeholder directory, does not accept specific project tasks
├── RUNBOOKS/            # Role runbooks
├── TEMPLATES/           # Standard envelope/lease/audit templates
├── TIMER_LOOP.md        # Timer-driven collaboration loop
├── ORDERING.md          # Read/write ordering, dependencies, revision control
├── MONITOR/             # Optional browser read-only monitoring mechanism
└── WATCHDOG.md          # Timeout, conflict, orphan-task checks
```

### 2.1 Multi-Project Space

The root-level `HANDOFF/`, `CLAIMS/`, `HEARTBEAT/`, `EVIDENCE/`, and `AUDIT/` directories are global placeholders and do not retain specific project context. All specific project tasks MUST use `PROJECTS/{project_id}/`.

`project_id` consists of the project short name and the working directory path fingerprint. Before processing a task, an AI IDE MUST confirm:

1. The current working directory is under the `workspace_root` declared in `PROJECTS/{project_id}/PROJECT.md`;
2. The current actor is registered in `PROJECTS/{project_id}/ACTORS.md`;
3. The actor's role, expiration time, and path fingerprint match the current task;
4. Only scan and process envelopes, leases, heartbeats, evidence, and audits within that project space.

Project deliverables MUST be retained in the actual `workspace_root`. The blackboard may only record file names, relative paths, hashes, statuses, and short summaries; storing full deliverable content is prohibited.

The project blackboard is a mandatory write point on the control plane. When an actor completes work, submits results, finishes testing/adjudication, discovers a blocker, or only performs state synchronization, it MUST update `BLACKBOARD.md`. The newest blackboard entry MUST be placed at the top using newest-first ordering; appending new state only to the end of the file, causing other roles to miss it, is prohibited.

### 2.2 Root Directory and Project Directory Boundary

| Level | Allowed Content | Disallowed Content |
|---|---|---|
| Root directory | Protocol, actions, templates, role manuals, global monitoring, empty placeholder directories | Any specific project's active handoff, claim, evidence, audit, blackboard |
| `PROJECTS/{project_id}/` | Project registration, actor registration, project blackboard, project handoff/claim/heartbeat/evidence/audit | Complete code, complete reports, large logs, secrets |
| Actual project working directory | Code, plans, reports, test outputs, benchmarks, real runtime evidence | Cross-AI-IDE control-plane state |

If an AI IDE discovers specific project files in the root directory, it SHOULD stop processing root directory files, require migration to the corresponding `PROJECTS/{project_id}/`, and record the structural deviation via the project WATCHDOG or SPEC/HUMAN.

---

## III. Envelope Format

All cross-party deliverables MUST use the following Markdown envelope format:

Envelopes SHALL only be created when there are important matters requiring another role to process, confirm, re-verify, adjudicate, or be notified. The envelope Header's `to` and each request paragraph in the body MUST clearly specify the target; if the body mentions a todo for a given actor/role, that actor/role MUST process it when reading the envelope, and MUST NOT ignore it on the grounds that "it was not sent to me alone". If an actor's own work is complete and there is nothing further to notify, updating only `BLACKBOARD.md` is permitted, without creating an empty envelope.

```markdown
# Envelope: {ENVELOPE_ID}

## Header
- protocol_version: {protocol version, e.g. v1.1}
- envelope_id: {UUID or unique identifier}
- trace_id: {task-level trace ID; all envelopes of the same task share it}
- causation_id: {upstream envelope_id; fill "none" if absent}
- project_id: {project space ID; optional, required in multi-project mode}
- sequence_no: {per-project incrementing sequence number; optional}
- depends_on: {list of prerequisite envelope IDs; optional}
- supersedes: {list of superseded envelope IDs; optional}
- requires_blackboard_revision: {blackboard revision at read time; optional}
- stage: {e.g. S2_3A / S2_4 / S3_1}
- from: {SPEC / IMPL / TEST}
- to: {SPEC / IMPL / TEST}
- action: {standard action name, see ACTIONS.md}
- message_type: {Command / Response / Event / Query / Veto / ApprovalRequest / ApprovalDecision}
- priority: {P0 / P1 / P2}
- risk_level: {Low / Medium / High}
- reversibility: {Reversible / Irreversible / NeedsHuman}
- requires_audit: {false / true}
- created_at: {ISO8601 timestamp}
- expires_at: {ISO8601; optional}
- summary: {one-sentence natural-language summary, for the receiver to grasp at a glance}

## Payload
{deliverable body}

## Evidence
- list of supporting file paths

## Status
- current: {Draft / Submitted / Accepted / Rejected / Conditional / Blocked}
- updated_at: {ISO8601}
- updated_by: {SPEC / IMPL / TEST}

## Audit
- list of change records
```

> **Backward Compatibility Statement**: New fields are optional for historical envelopes (fill "none" if missing); backfilling is not enforced. New envelopes MUST comply with all fields from the publication of this specification onward.
>
> **Version Self-Healing Rule (v1.1 patch)**: An envelope without a `protocol_version` field is treated as a legacy v1.0 envelope. When an actor next rewrites or forwards the matter, it re-issues the envelope with all fields per the current protocol version (v1.1) and references the original envelope ID in the `supersedes` field. This rule turns upgrades from "prompted by humans" into "self-healing" — no runtime or scanning script is needed; the next actor touching it completes the upgrade automatically.

### 3.1 Envelope Naming Rule

File name format: `{STAGE}_{FROM}_TO_{TO}_{TIMESTAMP}.md`

Examples:
- `S2_3A_IMPL_TO_TEST_20260613T193000.md` — IMPL submits S2_3A implementation to TEST
- `S2_4_SPEC_TO_IMPL_20260613T200000.md` — SPEC issues S2_4 specification to IMPL

### 3.2 Envelope Lifecycle

```
Draft → Submitted → Accepted / Rejected / Conditional / Blocked
                         │
                         ├→ Accepted → delivery complete
                         ├→ Rejected → returns to Draft, with rejection reason
                         ├→ Conditional → with conditions; resubmit after supplementation
                         └→ Blocked → blocked by external dependency; record the blocking reason
```

### 3.3 message_type Semantic Constraints

The `message_type` field of the envelope Header constrains the envelope's semantic role and flow behavior. The meaning of each type:

| Type | Meaning | Response Required | Typical Actions |
|------|------|------------|---------|
| Command | Require the other party to perform an action | Yes | IssueSpec, SubmitImpl, SubmitTestReport |
| Response | Receipt to a Command | No | AcceptStage, RejectStage, Conditional |
| Event | Notify that a fact "has occurred" | No | ResolveBlock, DeclareConflict, announcement-type |
| Query | Read-only query, no side effects | Yes (read-only answer) | RequestSpecClarification |
| Veto | Veto/block | No (taking effect is terminal) | DeclareConflict |
| ApprovalRequest | Request human/SPEC approval | Yes (pending approval) | High-risk change request |
| ApprovalDecision | Approval decision | No | AcceptStage, human adjudication |

**Hard Constraints**:
- Query MUST NOT produce any side effects;
- Event MUST NOT bear action approval;
- Command MUST have an explicit `to`;
- Veto takes priority over ordinary Command;
- ApprovalRequest MUST carry a risk reason and a change preview.

---

## IV. Collaboration Flow

### 4.1 Standard Flow (Specification → Implementation → Testing → Acceptance)

```
┌─────────┐   ①Issue Spec   ┌─────────┐  ②Submit Impl  ┌─────────┐
│  SPEC   │ ──────────────→ │  IMPL   │ ──────────────→ │  TEST   │
│(AI IDE) │                  │(AI IDE) │                  │(AI IDE) │
└─────────┘                  └─────────┘                  └─────────┘
     ↑                            │                            │
     │   ④Final Acceptance        │   ③Preliminary Report     │
     └────────────────────────────┴────────────────────────────┘
```

**① SPEC Issues Specification**
- SPEC creates an envelope in `HANDOFF/` with action=`IssueSpec`
- IMPL reads the envelope and creates a claim record in `CLAIMS/`

**② IMPL Submits Implementation**
- IMPL completes code + unit tests + self-check report
- IMPL creates an envelope in `HANDOFF/` with action=`SubmitImpl`
- TEST reads the envelope and executes tests

**③ TEST Preliminary Acceptance Report**
- TEST executes black-box + white-box tests
- TEST creates an envelope in `HANDOFF/` with action=`SubmitTestReport`
- TEST updates the corresponding stage status in BLACKBOARD.md

**④ SPEC Final Acceptance**
- SPEC reads the IMPL deliverables + TEST preliminary report
- SPEC creates an envelope in `HANDOFF/` with action=`AcceptStage` or `RejectStage`
- SPEC updates BLACKBOARD.md

### 4.2 Exception Flow

**Blocked**
- Any party discovering a missing external dependency creates an envelope with action=`DeclareBlock`
- Mark the stage as Blocked in BLACKBOARD.md
- Once the blocker is resolved, the discovering party creates an envelope with action=`ResolveBlock`

**Conditional**
- TEST discovers a non-critical gap and gives a Conditional assessment
- IMPL supplements it within the agreed time, or SPEC explicitly accepts the conditions

**Conflict**
- Two parties have contradictory judgments on the same deliverable
- Create an envelope with action=`DeclareConflict`
- Adjudicated by a human; SPEC executes the adjudication result

### 4.3 Rollback Flow

- IMPL discovers the implementation cannot satisfy the specification and creates an envelope with action=`RequestSpecClarification`
- TEST discovers tests cannot be executed and creates an envelope with action=`RequestImplFix`
- Any rollback MUST record the reason and impact scope in AUDIT/

---

## V. BLACKBOARD.md State Model

### 5.1 Stage States

| State | Meaning | Can Transition To |
|------|------|---------|
| Planned | Planning, no code | SpecIssued, Blocked |
| SpecIssued | Specification issued | InProgress, Blocked |
| InProgress | Implementation in progress | ImplSubmitted, Blocked |
| ImplSubmitted | Implementation submitted for testing | Testing, Blocked |
| Testing | Testing in progress | TestReported, Blocked |
| TestReported | Test report submitted | Accepted, Conditional, Rejected |
| Accepted | Acceptance passed | Frozen |
| Conditional | Conditional pass | Accepted, Rejected |
| Rejected | Acceptance failed | InProgress (rollback) |
| Blocked | Blocked | Any non-Frozen state |
| Frozen | Frozen (immutable) | — |
| Superseded | Superseded by a new envelope/human instruction | — |
| Withdrawn | Withdrawn by the initiator; reason must be recorded | — |
| Expired | TTL timed out and not renewed | SpecIssued, Blocked |
| NeedsClarification | Awaiting specification clarification | SpecIssued, Blocked |

### 5.2 BLACKBOARD.md Update Rules

- Any state change MUST immediately update BLACKBOARD.md
- The close of each work round MUST also update BLACKBOARD.md, even if there is no new envelope.
- The latest update MUST be written at the top of the file header; the blackboard uses newest-first. Writing the latest state only to the end of the file is prohibited.
- Updates MUST include a timestamp and the operating party
- Deleting historical state records is prohibited; only appending is allowed
- High-risk state changes (Accepted/Rejected/Frozen) MUST also be written to AUDIT/
- The top state overview is an updatable snapshot; the state change history MUST be appended, and existing historical lines MUST NOT be deleted or rewritten.
- Timer-driven collaboration MUST comply with `TIMER_LOOP.md`, `HEARTBEAT/README.md`, `SCHEMAS/claim.schema.json`, and `WATCHDOG.md`.
- In multi-project mode, the project blackboard MUST include `project_id` and `blackboard_revision`. Before writing, the latest revision MUST be re-read; if the revision has changed, re-judge or declare a conflict per `ORDERING.md`.
- The blackboard is a control-plane index and may only record project deliverable file names, relative paths, hashes, statuses, and short summaries. Complete deliverables MUST be retained in the project working directory.
- For matters requiring no other role to process, updating only the blackboard without an envelope is permitted; if an envelope is sent, the target and expected action for each processing item MUST be specified.

### 5.3 Blackboard Three-Section Format Specification (added in v1.1)

The blackboard MUST adopt a three-section structure to ensure uniform writing across actors and efficient scanning by receivers:

```markdown
# BLACKBOARD — {project_id}

## Current State (state overview, updatable snapshot)
- project_id: {ID}
- blackboard_revision: {incrementing integer}
- current_stage: {current stage}
- current_status: {current status}
- updated_at: {ISO8601}
- updated_by: {actor}
- active_claims: {list of active lease IDs, or none}
- blockers: {current blockers, or none}

## Latest Entries (newest entries, top, keep at most 20)

### [{ISO8601}] {actor} — {action} — {message_type}
- envelope_id: {associated envelope ID, or BLACKBOARD_ONLY}
- trace_id: {task trace ID}
- stage: {stage}
- status: {status}
- summary: {one-sentence summary, ≤120 chars}
- evidence_ref: {evidence path + sha8, or none}
- audit_ref: {audit path, or none}

### [{previous entry}] ...

## History (historical archive index, append-only, no deletion)
- [{ISO8601}] {actor} {action} {stage} → {status} | env:{envelope_id} | see BLACKBOARD_ARCHIVE/{file} for details
- ...
```

**Hard Format Constraints**:

1. The Latest Entries section keeps at most 20 entries; the excess MUST be migrated to the project-level `BLACKBOARD_ARCHIVE/` to keep the blackboard lean.
2. Each entry MUST have a fixed set of 8 fields: envelope_id/trace_id/stage/status/summary/evidence_ref/audit_ref + the timestamp line. Free-form variation is prohibited. Fill missing fields with `none`; do not leave blanks.
3. summary ≤ 120 chars: write only keywords and semantic anchors, not body text.
4. evidence_ref writes only path + sha8; do not copy evidence content.
5. Current State is a snapshot and may be overwritten; Latest Entries and History are append-only and MUST NOT be deleted.
6. Archiving rule: when Latest Entries exceeds 20 entries, the oldest MUST be migrated to `BLACKBOARD_ARCHIVE/{start}_{end}_{sha8}.md`, and an index line MUST be appended to History.
7. **Cap Self-Enforcement Rule (v1.1 patch)**: When an actor reads the blackboard and finds Latest Entries exceeds 20 entries, it MUST first archive the oldest entries to `BLACKBOARD_ARCHIVE/` before writing new entries. This rule turns the blackboard cap from "relying on conscious compliance" into "automatically maintained by the next actor touching the blackboard" — no runtime or scheduled scan is needed; the upgrade occurs naturally and does not regress.

> Note: Slimming down existing blackboards for each project is a project-level affair, with timing decided by each project's SPEC. The platform only defines the format specification.

---

## VI. Audit Rules

### 6.1 Operations Requiring Audit

| Operation | Risk Level | Audit Requirement |
|------|---------|---------|
| AcceptStage | High | MUST be written to AUDIT/, with SPEC signature |
| RejectStage | High | MUST be written to AUDIT/, with rejection reason |
| DeclareBlock | Medium | MUST be written to AUDIT/, with blocking reason |
| ResolveBlock | Medium | MUST be written to AUDIT/, with resolution method |
| DeclareConflict | High | MUST be written to AUDIT/, with conflict description |
| Frozen | High | MUST be written to AUDIT/, with frozen scope |

### 6.2 Audit Log Format

```markdown
# Audit: {AUDIT_ID}

- timestamp: {ISO8601}
- actor: {SPEC / IMPL / TEST / CONSULTANT / QA / WATCHDOG / HUMAN}
- action: {action name}
- stage: {stage name}
- risk_level: {Low / Medium / High}
- details: {detailed description}
- evidence_refs: {list of supporting file paths}
```

---

## VII. Prohibited Behaviors

### 7.1 Absolutely Prohibited

| # | Prohibited Behavior | Reason |
|---|---------|------|
| 1 | Skipping envelopes to deliver directly | Bypasses the bus, untraceable |
| 2 | Self-acceptance (IMPL accepting its own implementation) | Separation of powers |
| 3 | Deleting records in AUDIT/ | Audit must be tamper-proof |
| 4 | Deleting historical states in BLACKBOARD.md | State must be irreversible |
| 5 | Modifying envelope content created by others | Immutable identifier |
| 6 | Passing sensitive information (keys/tokens) outside envelopes | Security red line |
| 7 | Modifying specification definitions without SPEC approval | Specification authority belongs to SPEC |
| 8 | Marking as Accepted without TEST preliminary acceptance | Acceptance authority belongs to SPEC + TEST |
| 9 | Timer bypassing role permissions to auto-accept/freeze | Separation of powers |
| 10 | Holding a task for a long time without declaration (ClaimLease recommended, downgraded to optional in v1.1) | Prevents ghost execution |
| 11 | Processing project tasks without confirming project_id and actor registration | Prevents cross-project mishandling |
| 12 | Writing full project deliverable content into BLACKBOARD.md | Separation of control plane and deliverables |
| 13 | Skipping depends_on / sequence_no / revision ordering requirements | Prevents out-of-order execution |

### 7.2 Strongly Discouraged

| # | Behavior | Reason |
|---|------|------|
| 1 | IMPL starting implementation before SPEC issues the specification | May deviate from the specification |
| 2 | TEST starting testing before IMPL submits | Wastes compute |
| 3 | Modifying the same file simultaneously | Conflict risk |
| 4 | Conditional unresolved for more than 3 rounds | Efficiency loss |

---

## VIII. Conflict Resolution

### 8.1 Conflict Types

| Type | Example | Resolver |
|------|------|--------|
| Specification conflict | Two SPEC specifications contradict each other | Human adjudication |
| Implementation conflict | IMPL implementation inconsistent with specification | SPEC judgment |
| Test conflict | TEST preliminary result inconsistent with IMPL self-check | Human adjudication |
| State conflict | BLACKBOARD state inconsistent with reality | Discoverer corrects + AUDIT record |

### 8.2 Resolution Flow

1. The discoverer creates a `DeclareConflict` envelope
2. Record conflict details in AUDIT/
3. Human adjudication (if necessary)
4. Write the adjudication result into the envelope and AUDIT/
5. Relevant parties execute per the adjudication

### 8.3 Arbitration Priority Chain

Conflict adjudication is executed per the following eight-layer priority chain, where higher priority overrides lower priority:

```
L1  HUMAN human instruction            ← highest priority; human decision is a first-class fact
L2  Veto explicit veto envelope        ← blocks the flow
L3  CONSULTANT consultant adjudication ← controls project direction, helps resolve complex issues
L4  SPEC acceptance adjudication       ← specification authority belongs to SPEC
L5  TEST independent preliminary conclusion ← testing authority belongs to TEST
L6  IMPL self-check report             ← implementer self-report, lowest weight
L7  QA quality inspection report       ← reviews process to ensure quality
L8  blackboard historical state        ← established fact, cannot be unilaterally rewritten
```

**Arbitration Rules**:
- Lower priority MUST NOT override higher priority;
- Same-level conflicts escalate via DeclareConflict to L1;
- Self-check (L6) MUST NOT impersonate TEST (L5) or SPEC (L4);
- When CONSULTANT (L3) conflicts with SPEC (L4), L3 prevails, but SPEC may appeal to L1 for arbitration;
- When QA (L7) discovers an issue, it may escalate to a Veto to invoke L2;
- HUMAN (L1) feedback MUST be written to AUDIT and the blackboard updated.

---

## IX. Version and Evolution

- This protocol version: 1.1
- Modification authority: Human
- Modification method: Append revision records at the end of this document
- Revision record format: `| Date | Version | Changes | Modifier |`

### Revision Records

| Date | Version | Changes | Modifier |
|------|------|---------|--------|
| 2026-06-13 | 1.0 | Initial version | Example Model/AI IDE |
| 2026-07-07 | 1.0.1 | Clarified that the blackboard is mandatory and the newest entry must be on top; envelope processing items must specify targets; recipient roles must process items concerning themselves; when there is nothing to notify, updating only the blackboard without an empty envelope is permitted | SPEC (per HUMAN instruction) |

## v1.1 — 2026-07-07

- Envelope Header upgrade: 14 fields → 21 fields (added protocol_version/trace_id/causation_id/message_type/reversibility/requires_audit/summary)
- Added message_type semantic constraints (7 types)
- Added arbitration priority chain (8 layers: HUMAN/Veto/CONSULTANT/SPEC/TEST/IMPL/QA/blackboard history)
- Added blackboard three-section format specification (§5.3: Current State + Latest Entries ≤20 entries + History index)
- Backward compatibility: new fields optional for historical envelopes
- **v1.1 Patch (Self-Healing Mechanism)**:
  - Envelope added `protocol_version` field + version self-healing rule (envelopes without a version field are treated as v1.0 legacy and auto-upgraded on next rewrite)
  - Blackboard §5.3 added cap self-enforcement rule (on reading >20 entries, archive first then write; the next actor automatically maintains the cap)
  - CLAIMS lease `file_scope` must be a concrete list of file paths (not free text, making conflict detection machine-readable)
- **v1.2 (Optional Extension)**:
  - Added optional Project Plan protocol (PLAN.md): SPEC pre-orchestrates the stage sequence + each role's prompts; actors poll and advance autonomously; added IssuePlan/RevisePlan actions; does not modify the core envelope format or iron law
