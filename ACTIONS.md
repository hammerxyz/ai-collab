# AI-COLLAB Standard Collaboration Actions

> Version: 1.3 | Effective Date: 2026-07-30 (v1.3: Direction 3 Phase 1 static risk annotation; v1.2: add IssuePlan/RevisePlan actions; v1.1: message_type annotation, CONSULTANT/QA roles)
> Design reference: CBB standard actions; each action corresponds to one envelope type

---

## 0. Risk Grading and Auto Closed-Loop (v1.3 New / Direction 3 Phase 1)

> v1.5 confirmed (seven-step adjudication; vacuum-period decision pending community review). Phase 1 is pure annotation, does not alter existing flows; benefits land immediately.

Each action is annotated with `reversible` (whether reversible) + `blast_radius` (impact scope), from which the risk grade is derived to decide whether human approval is required:

| reversible | blast_radius | risk grade | behavior |
|-----------|--------------|---------|------|
| true | local | Low | actor auto closed-loop, no human required |
| true | cross-file | Medium | actor closed-loop, AUDIT trail left |
| false | * | High | escalate to human |
| * | cross-repo | High | escalate to human |

**Design goal**: Low-risk, reversible actions may let actor auto close the loop without human endorsement; only irreversible, high-risk actions escalate to human. Protects human attention, prevents rubber-stamp.

**Phase 1 scope**: Pure static annotation, no dynamic trust value computation introduced. Phase 2 (dynamic decay + circuit breaker) pending community experimental data; see EVOLUTION.md Direction 3.

### Action Risk Annotation Table (v1.3 New)

| Action | risk_level (original) | reversible | blast_radius | grade | assessment rationale |
|------|-------------------|-----------|--------------|------|---------|
| IssuePlan | High | false | cross-file | High | plan affects global stage sequence, cannot be silently retracted |
| RevisePlan | High | false | cross-file | High | supersedes old plan, history is irreversible |
| IssueSpec | Medium | true | cross-file | Medium | spec is revisable but affects multiple roles |
| DefineInterface | High | false | cross-file | High | interface definition constrains subsequent implementation, irreversible |
| AcceptStage | High | false | cross-file | High | acceptance pass = stage frozen, irreversible |
| RejectStage | Medium | true | local | Low | rejection allows resubmission, impact only current stage |
| ClaimTask | Low | true | local | Low | claim is releasable, impact only self |
| SubmitImpl | Medium | true | cross-file | Medium | submission can be reworked, but affects TEST work |
| SubmitSelfCheck | Low | true | local | Low | self-check report can be updated |
| RequestSpecClarification | Low | true | local | Low | read-only query, no side effects |
| SubmitTestReport | Medium | true | cross-file | Medium | test report affects SPEC acceptance decision |
| RequestImplFix | Medium | true | cross-file | Medium | requires rework, affects IMPL |
| SubmitAdversarialReport | Low | true | local | Low | notification event, can be supplemented |
| SubmitRegressionReport | Low | true | local | Low | notification event, can be supplemented |
| DeclareBlock | Medium | true | local | Low | block can be released |
| ResolveBlock | Low | true | local | Low | block release can be redeclared |
| DeclareConflict | High | true | cross-file | Medium | conflict can be arbitrated, but affects multiple parties |
| EscalateToHuman | High | true | local | Low | escalation requests human, retractable |
| SyncStatus | Low | true | local | Low | status sync can be resent |
| RegisterProject | Medium | false | cross-repo | High | project registration affects global state, cannot be silently deleted |
| RegisterActor | Medium | false | cross-file | High | actor registration affects permission matrix |
| Heartbeat | Low | true | local | Low | heartbeat can be resent |
| RenewClaim | Low | true | local | Low | renewal is revocable |
| ReleaseClaim | Low | true | local | Low | release allows re-claim |
| WatchdogSync | Low | true | local | Low | sync can be resent |
| RecordDecision | Medium | false | cross-file | High | audit record is immutable |
| RecordRisk | Medium | false | cross-file | High | audit record is immutable |
| RecordDeviation | Medium | false | cross-file | High | audit record is immutable |

**Annotation summary**: Low 14 / Medium 5 / High 9 (28 actions total). Low grade may auto close loop; High grade requires human approval.

---

## 1. Action Classification

| Category | Action count | Description |
|------|--------|------|
| Spec | 4 | SPEC initiates; defines specs and interfaces |
| Implementation | 4 | IMPL initiates; submits code and self-check |
| Testing | 4 | TEST initiates; executes tests and preliminary acceptance |
| Coordination | 7 | Any party initiates; handles exceptions, conflicts, project/actor registration |
| Audit | 3 | Any party initiates; records key decisions |
| Timer | 4 | Scheduled scan, heartbeat, lease renewal, watchdog sync |

### Action message_type Index (v1.1 New)

Each action is annotated with message semantic type, by which the receiver decides whether a response is required:

| Action | message_type | Description |
|------|-------------|------|
| IssuePlan | Command | SPEC issues project plan (plan mode, optional) |
| RevisePlan | Command | SPEC revises project plan (supersedes old plan) |
| IssueSpec | Command | Requires IMPL/TEST to perform implementation |
| DefineInterface | Command | Requires IMPL to implement per interface |
| AcceptStage | ApprovalDecision | SPEC acceptance-pass decision |
| RejectStage | ApprovalDecision | SPEC acceptance-fail decision |
| ClaimTask | Event | Notifies claim made (no response required) |
| SubmitImpl | Command | Requires TEST to perform preliminary acceptance |
| SubmitSelfCheck | Event | Notifies self-check complete (for TEST reference) |
| RequestSpecClarification | Query | Read-only query of spec doubts |
| SubmitTestReport | Response | Preliminary acceptance receipt for SubmitImpl |
| RequestImplFix | Command | Requires IMPL to fix defects |
| SubmitAdversarialReport | Event | Notifies adversarial test result |
| SubmitRegressionReport | Event | Notifies regression test result |
| DeclareBlock | Event | Notifies block occurred |
| ResolveBlock | Event | Notifies block resolved |
| DeclareConflict | Veto | Veto / blocks flow |
| EscalateToHuman | ApprovalRequest | Requests human approval |
| SyncStatus | Event | Notifies status sync |
| RegisterProject | Event | Notifies project registration |
| RegisterActor | Event | Notifies actor registration |
| Heartbeat | Event | Notifies heartbeat (optional) |
| RenewClaim | Event | Notifies lease renewal (optional) |
| ReleaseClaim | Event | Notifies claim release (optional) |
| WatchdogSync | Event | Notifies watchdog sync (optional) |
| RecordDecision | Event | Records decision to audit |
| RecordRisk | Event | Records risk to audit |
| RecordDeviation | Event | Records deviation to audit |

---

## 2. Spec Actions (SPEC -> IMPL / TEST)

### 2.1 IssueSpec — Issue Specification

| Field | Value |
|------|-----|
| from | SPEC |
| to | IMPL, TEST |
| risk_level | Medium |
| required payload | spec doc path, stage identifier, acceptance criteria, dependency list |

**Envelope payload template**:
```markdown
## Payload
### Spec Source
- Spec file path: {L2.5_xx path}
- Stage: {S2_4 etc.}
- Priority: {P0/P1/P2}

### Acceptance Criteria
1. {specific verifiable criteria}
2. ...

### Dependencies
- Preceding stage: {S2_3E etc.}
- Preceding envelope: {ENVELOPE_ID}
- External dependencies: {none / specific description}

### Constraints
- Forbidden behaviors: {specific prohibition}
- Resource limits: {time/file count/test count}
```

**IMPL shall, upon receipt**:
1. Create a `ClaimTask` record in `CLAIMS/`
2. Assess feasibility, mark `Accepted` / `Conditional` / `Blocked`
3. Update BLACKBOARD.md

### 2.2 DefineInterface — Define Cross-Stage Interface

| Field | Value |
|------|-----|
| from | SPEC |
| to | IMPL |
| risk_level | High |
| required payload | interface Schema, input/output types, version number |

**Purpose**: Defines the handoff interface between stages (e.g., CapabilityReception for S2_3 -> S2_4)

**Envelope payload template**:
```markdown
## Payload
### Interface Name
{InterfaceName}

### Interface Schema
```rust
pub struct {InterfaceName} {
    // field definitions
}
```

### Version
- schema_version: "1.0"

### Compatibility
- Backward compatible: yes/no
- Migration path: {description}
```

### 2.3 AcceptStage — Acceptance Pass

| Field | Value |
|------|-----|
| from | SPEC |
| to | IMPL, TEST |
| risk_level | High |
| required payload | stage identifier, acceptance conclusion, conditions list (if any) |

**Preconditions**:
- IMPL has submitted implementation (SubmitImpl)
- TEST has submitted preliminary acceptance report (SubmitTestReport)
- No unresolved P0 blockers

**Must be written to AUDIT/**

### 2.4 RejectStage — Acceptance Fail

| Field | Value |
|------|-----|
| from | SPEC |
| to | IMPL |
| risk_level | High |
| required payload | stage identifier, rejection reason, fix requirements, rollback target state |

**Must be written to AUDIT/**

---

## 3. Implementation Actions (IMPL -> TEST / SPEC)

### 3.1 ClaimTask — Claim Task

| Field | Value |
|------|-----|
| from | IMPL |
| to | SPEC (notification) |
| risk_level | Low |
| required payload | stage identifier, claimer, expected deliverables, estimated effort |

**File location**: `CLAIMS/{STAGE}_CLAIM_{CLAIM_ID}.md`

**payload template**:
```markdown
## Payload
### Claim Info
- Stage: {S2_4 etc.}
- Claimer: IMPL (AI IDE)
- Linked spec envelope: {ENVELOPE_ID}

### Expected Deliverables
1. Code files: {path list}
2. Unit tests: {path list}
3. Self-check report: {path}

### Feasibility Assessment
- Blockers: {none / specific description}
- Risks: {none / specific description}
- Conditions: {none / specific description}
```

### 3.2 SubmitImpl — Submit Implementation

| Field | Value |
|------|-----|
| from | IMPL |
| to | TEST |
| risk_level | Medium |
| required payload | stage identifier, code change list, test results, self-check report |

**Envelope payload template**:
```markdown
## Payload
### Implementation Summary
- Stage: {S2_4 etc.}
- Added files: {count and paths}
- Modified files: {count and paths}
- Deleted files: {count and paths}

### Test Results
- Total unit tests: {N}
- Passed: {N}
- Failed: {N}
- Skipped: {N}

### Self-Check Report
- Path: {plans/S2_4_TEST_RESULT_SUMMARY.md etc.}
- Key findings: {summary}

### Known Limitations
1. {limitation description}
2. ...

### Evidence
- Evidence path list
```

### 3.3 SubmitSelfCheck — Submit Self-Check Report

| Field | Value |
|------|-----|
| from | IMPL |
| to | TEST, SPEC |
| risk_level | Low |
| required payload | self-check report path, coverage data, STUB list |

**Purpose**: IMPL submits self-check before or together with SubmitImpl, for TEST reference

### 3.4 RequestSpecClarification — Request Spec Clarification

| Field | Value |
|------|-----|
| from | IMPL |
| to | SPEC |
| risk_level | Low |
| required payload | stage identifier, doubt points, IMPL proposed solution |

**Purpose**: When IMPL finds spec ambiguous, requests SPEC clarification

---

## 4. Testing Actions (TEST -> SPEC / IMPL)

### 4.1 SubmitTestReport — Submit Test Report

| Field | Value |
|------|-----|
| from | TEST |
| to | SPEC, IMPL |
| risk_level | Medium |
| required payload | stage identifier, test type, test results, preliminary acceptance conclusion |

**Envelope payload template**:
```markdown
## Payload
### Test Summary
- Stage: {S2_4 etc.}
- Linked implementation envelope: {ENVELOPE_ID}
- Test type: {black-box/white-box/adversarial/regression}

### Test Results
- Total test cases: {N}
- Passed: {N}
- Failed: {N}
- Blocked: {N}

### Preliminary Acceptance Conclusion
- Rating: {PASS / CONDITIONAL / FAIL}
- Conditions list (if Conditional):
  1. {condition description}
- Failure reason (if FAIL):
  1. {reason description}

### Evidence
- Evidence path list
```

### 4.2 RequestImplFix — Request Implementation Fix

| Field | Value |
|------|-----|
| from | TEST |
| to | IMPL |
| risk_level | Medium |
| required payload | stage identifier, defect list, severity, reproduction steps |

### 4.3 SubmitAdversarialReport — Submit Adversarial Test Report

| Field | Value |
|------|-----|
| from | TEST |
| to | SPEC, IMPL |
| risk_level | High |
| required payload | attack vectors, test results, vulnerability rating, fix suggestions |

**Must be written to AUDIT/**

### 4.4 SubmitRegressionReport — Submit Regression Test Report

| Field | Value |
|------|-----|
| from | TEST |
| to | SPEC, IMPL |
| risk_level | Medium |
| required payload | regression scope, test results, whether new defects introduced |

---

## 5. Coordination Actions (Any party -> Relevant parties)

### 5.1 DeclareBlock — Declare Block

| Field | Value |
|------|-----|
| from | Any party |
| to | Relevant parties |
| risk_level | Medium |
| required payload | stage identifier, block reason, block source, expected release conditions |

**Must update BLACKBOARD.md status to Blocked**

### 5.2 ResolveBlock — Resolve Block

| Field | Value |
|------|-----|
| from | Block discoverer |
| to | Relevant parties |
| risk_level | Medium |
| required payload | stage identifier, release method, post-release state |

**Must be written to AUDIT/**

### 5.3 DeclareConflict — Declare Conflict

| Field | Value |
|------|-----|
| from | Any party |
| to | Relevant parties + human |
| risk_level | High |
| required payload | conflict description, involved parties, involved envelopes, suggested resolution |

**Must be written to AUDIT/**

### 5.4 EscalateToHuman — Escalate to Human

| Field | Value |
|------|-----|
| from | Any party |
| to | Human |
| risk_level | High |
| required payload | problem description, attempted solutions, content needing human decision |

### 5.5 SyncStatus — Sync Status

| Field | Value |
|------|-----|
| from | Any party |
| to | All |
| risk_level | Low |
| required payload | current work status, progress percentage, next-step plan |

**Purpose**: Periodic sync to prevent information asymmetry

### 5.6 RegisterProject — Register Project Space

| Field | Value |
|------|-----|
| from | HUMAN / SPEC |
| to | ALL |
| risk_level | Medium |
| required payload | project_id, workspace_root, path_fingerprint, artifact_policy, allowed_roots |

**Purpose**: Lets actual development projects create a `PROJECTS/{project_id}/` collaboration space.

**Rules**:
- `artifact_policy` shall be `WorkspaceOnly`; project artifacts remain in the working directory.
- `BLACKBOARD.md` records only file name, relative path, hash, and short summary.
- After project registration, AI IDE shall process corresponding tasks within that project space.

### 5.7 RegisterActor — Register Project Participant

| Field | Value |
|------|-----|
| from | Any actor / HUMAN |
| to | SPEC / HUMAN |
| risk_level | Medium |
| required payload | actor_id, role, ai_ide, workspace_root_seen, path_fingerprint_seen, expires_at |

**Purpose**: Declares that an AI IDE or human role participates in a project space.

**Rules**:
- Unregistered or expired actors shall not process project tasks.
- Actor registration is soft authentication; it does not replace system permissions or Git permissions.
- Roles shall still comply with the `ACTIONS.md` permission matrix.

---

## 5.5 Timer Actions (Timer / Lease / Watchdog)

### 5.8 Heartbeat — Heartbeat

| Field | Value |
|------|-----|
| from | Any actor |
| to | HEARTBEAT/ |
| risk_level | Low |
| required payload | actor_id, role, timer_profile, status, current_stage, active_claim_id, last_heartbeat_at, next_tick_at |

Heartbeat format see `HEARTBEAT/README.md`.

### 5.9 RenewClaim — Renew Lease

| Field | Value |
|------|-----|
| from | Claim owner |
| to | CLAIMS/ |
| risk_level | Low / Medium |
| required payload | claim_id, old_expires_at, new_expires_at, heartbeat_at, continuation status |

Renewal shall occur before expiry. Post-expiry renewal shall record a gap, and WATCHDOG or SPEC shall decide whether to continue.

### 5.10 ReleaseClaim — Release Claim

| Field | Value |
|------|-----|
| from | Claim owner |
| to | CLAIMS/ + BLACKBOARD |
| risk_level | Low |
| required payload | claim_id, release_reason, handoff/evidence paths |

### 5.11 WatchdogSync — Watchdog Sync

| Field | Value |
|------|-----|
| from | WATCHDOG / any executor |
| to | ALL |
| risk_level | Low / Medium / High |
| required payload | stale claims, stale heartbeat, state conflicts, missing audit/evidence, recommended action |

Watchdog rules see `WATCHDOG.md`.

---

## 6. Audit Actions (Any party -> AUDIT/)

### 6.1 RecordDecision — Record Decision

| Field | Value |
|------|-----|
| from | Any party |
| to | AUDIT/ |
| risk_level | per actual |
| required payload | decision content, decision rationale, impact scope |

### 6.2 RecordRisk — Record Risk

| Field | Value |
|------|-----|
| from | Any party |
| to | AUDIT/ |
| risk_level | Medium+ |
| required payload | risk description, risk level, mitigation measures, responsible person |

### 6.3 RecordDeviation — Record Deviation

| Field | Value |
|------|-----|
| from | Any party |
| to | AUDIT/ |
| risk_level | Medium+ |
| required payload | deviation description, difference from spec, rationale, impact assessment |

### 6.4 IssuePlan — Issue Project Plan

| Field | Value |
|------|-----|
| action | IssuePlan |
| message_type | Command |
| from -> to | SPEC -> ALL |
| risk_level | High |
| reversibility | NeedsHuman |
| requires_audit | true |
| required payload | plan_id, plan_version, requirements_ref, stage list summary, plan_path, plan_sha256 |
| filename | PLAN_SPEC_TO_ALL_{TS}.md |

**Purpose**: After SPEC finishes writing the plan in the plan-generation stage, it issues the plan to all roles via this envelope. CONSULTANT/QA review responds via SyncStatus envelope; HUMAN Accepts on this envelope to make the plan effective. See PLAN.md §5.1.

### 6.5 RevisePlan — Revise Project Plan

| Field | Value |
|------|-----|
| action | RevisePlan |
| message_type | Command |
| from -> to | SPEC -> ALL |
| risk_level | High |
| reversibility | NeedsHuman |
| requires_audit | true |
| required payload | plan_id, supersedes, revision reason, impact scope, plan_path, plan_sha256 |
| filename | PLAN_REVISE_SPEC_TO_ALL_{TS}.md |

**Purpose**: SPEC issues via this envelope when revising an existing plan. The supersedes field references the old IssuePlan envelope ID. Already-Accepted stages are not affected by the revision. See PLAN.md §5.2.

---

## 7. Action and Role Permission Matrix

| Action | SPEC | IMPL | TEST | CONSULTANT | QA | Human |
|------|------|------|------|------------|-----|------|
| IssuePlan | **Initiate** | Receive | Receive | Reference | Reference | Approve |
| RevisePlan | **Initiate** | Receive | Receive | Reference | Reference | Approve |
| IssueSpec | **Initiate** | Receive | Receive | Reference | — | Adjudicate |
| DefineInterface | **Initiate** | Receive | Reference | Reference | — | Adjudicate |
| AcceptStage | **Initiate** | Receive | Receive | Reference | Reference | Approve |
| RejectStage | **Initiate** | Receive | Receive | Reference | Reference | Approve |
| ClaimTask | Notify | **Initiate** | Reference | — | — | — |
| SubmitImpl | Reference | **Initiate** | Receive | — | — | — |
| SubmitSelfCheck | Reference | **Initiate** | Reference | — | — | — |
| RequestSpecClarification | **Receive** | Initiate | — | Reference | — | — |
| SubmitTestReport | Receive | Receive | **Initiate** | Reference | Reference | — |
| RequestImplFix | — | **Receive** | Initiate | — | — | — |
| SubmitAdversarialReport | Receive | Receive | **Initiate** | Reference | Reference | — |
| SubmitRegressionReport | Receive | Receive | **Initiate** | — | Reference | — |
| DeclareBlock | Initiate/Receive | Initiate/Receive | Initiate/Receive | Initiate/Receive | Initiate/Receive | Adjudicate |
| ResolveBlock | Initiate/Receive | Initiate/Receive | Initiate/Receive | Initiate/Receive | Initiate/Receive | Approve |
| DeclareConflict | Initiate/Receive | Initiate/Receive | Initiate/Receive | Initiate/Receive | Initiate/Receive | **Adjudicate** |
| EscalateToHuman | — | — | — | — | — | **Receive** |
| SyncStatus | Initiate | Initiate | Initiate | Initiate | Initiate | — |
| RegisterProject | Initiate | Receive | Receive | — | — | Initiate/Approve |
| RegisterActor | Receive/Approve | Initiate | Initiate | Initiate | Initiate | Initiate/Approve |
| Heartbeat | Initiate | Initiate | Initiate | Initiate (optional) | Initiate (optional) | — |
| RenewClaim | Receive/Initiate | Initiate | Initiate | — | — | — |
| ReleaseClaim | Receive/Initiate | Initiate | Initiate | — | — | — |
| WatchdogSync | Initiate/Receive | Initiate/Receive | Initiate/Receive | Initiate/Receive | **Initiate** | Adjudicate |
| RecordDecision | Initiate | Initiate | Initiate | Initiate | Initiate | Initiate |
| RecordRisk | Initiate | Initiate | Initiate | Initiate | Initiate | Initiate |
| RecordDeviation | Initiate | Initiate | Initiate | Initiate | Initiate | Initiate |

**CONSULTANT role permission notes**: May initiate SyncStatus/DeclareBlock/DeclareConflict/RecordDecision/RecordRisk/RecordDeviation/WatchdogSync/Heartbeat; may reference SPEC/TEST acceptance and testing actions; shall not initiate IssueSpec/SubmitImpl/SubmitTestReport/AcceptStage/RejectStage (does not replace core responsibilities of SPEC/IMPL/TEST).

**QA role permission notes**: May initiate WatchdogSync/DeclareBlock/DeclareConflict/RecordDecision/RecordRisk/RecordDeviation/SyncStatus/Heartbeat; may reference AcceptStage/RejectStage/SubmitTestReport; shall not initiate implementation and testing actions (QA does process-quality review, not functional testing).

---

## 8. Action Execution Checklist

Each AI IDE shall check before executing an action:

1. [ ] Do I have permission to initiate this action? (see permission matrix)
2. [ ] Is the envelope format complete? (Header + Payload + Evidence + Status + Audit)
3. [ ] Does the file naming comply with the rules?
4. [ ] Does BLACKBOARD.md need updating?
5. [ ] Does AUDIT/ need recording?
6. [ ] Are there preceding envelopes not yet complete?
7. [ ] Does it conflict with existing envelopes?

---

## 9. Action Template Quick Index

| Action | from->to | Envelope filename template |
|------|---------|---------------|
| IssueSpec | SPEC->IMPL,TEST | `{STAGE}_SPEC_TO_IMPL_{TS}.md` |
| DefineInterface | SPEC->IMPL | `{STAGE}_SPEC_TO_IMPL_{TS}.md` |
| AcceptStage | SPEC->IMPL,TEST | `{STAGE}_SPEC_TO_IMPL_TEST_{TS}.md` |
| RejectStage | SPEC->IMPL | `{STAGE}_SPEC_TO_IMPL_{TS}.md` |
| ClaimTask | IMPL->SPEC | `CLAIMS/{STAGE}_CLAIM_{ID}.md` |
| SubmitImpl | IMPL->TEST | `{STAGE}_IMPL_TO_TEST_{TS}.md` |
| SubmitSelfCheck | IMPL->TEST,SPEC | `{STAGE}_IMPL_TO_TEST_SPEC_{TS}.md` |
| RequestSpecClarification | IMPL->SPEC | `{STAGE}_IMPL_TO_SPEC_{TS}.md` |
| SubmitTestReport | TEST->SPEC,IMPL | `{STAGE}_TEST_TO_SPEC_IMPL_{TS}.md` |
| RequestImplFix | TEST->IMPL | `{STAGE}_TEST_TO_IMPL_{TS}.md` |
| SubmitAdversarialReport | TEST->SPEC,IMPL | `{STAGE}_TEST_TO_SPEC_IMPL_{TS}.md` |
| SubmitRegressionReport | TEST->SPEC,IMPL | `{STAGE}_TEST_TO_SPEC_IMPL_{TS}.md` |
| DeclareBlock | Any->Relevant | `{STAGE}_{FROM}_TO_{TO}_{TS}.md` |
| ResolveBlock | Any->Relevant | `{STAGE}_{FROM}_TO_{TO}_{TS}.md` |
| DeclareConflict | Any->Relevant+Human | `{STAGE}_{FROM}_TO_ALL_{TS}.md` |
| EscalateToHuman | Any->Human | `{STAGE}_{FROM}_TO_HUMAN_{TS}.md` |
| SyncStatus | Any->All | `SYNC_{FROM}_{TS}.md` |
| RegisterProject | HUMAN/SPEC->ALL | `PROJECT_REGISTER_{PROJECT_ID}_{TS}.md` |
| RegisterActor | Any->SPEC/HUMAN | `PROJECT_ACTOR_REGISTER_{ACTOR}_{TS}.md` |
| Heartbeat | Any->HEARTBEAT | `HEARTBEAT/{ACTOR}.json` |
| RenewClaim | Claim owner->CLAIMS | `{STAGE}_CLAIM_{ACTOR}_{TS}.md` |
| ReleaseClaim | Claim owner->CLAIMS | `{STAGE}_CLAIM_{ACTOR}_{TS}.md` |
| WatchdogSync | WATCHDOG->ALL | `SYNC_WATCHDOG_{TS}.md` |
