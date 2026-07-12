<!-- 中文说明：actor 登记模板。登记 actor_id / role / expires_at / path_fingerprint。 -->

# Envelope: {ENVELOPE_ID}

## Header
- envelope_id: {ENVELOPE_ID}
- project_id: {project_id}
- stage: ACTOR_REGISTRATION
- from: {SPEC | IMPL | TEST | WATCHDOG | CONSULTANT | QA | HUMAN}
- to: SPEC,HUMAN
- action: RegisterActor
- priority: P1
- risk_level: Medium
- created_at: {ISO8601}
- expires_at: {ISO8601}

## Payload
### Actor
- actor_id: {SPEC | IMPL | TEST | ...}
- role: {SPEC | IMPL | TEST | WATCHDOG | CONSULTANT | QA | HUMAN}
- ai_ide: {AI IDE | Other}
- timer_supported: {true | false}
- timer_profile: {interactive | normal | long_running | manual_only}

### Project Binding
- workspace_root_seen: {absolute canonical path}
- path_fingerprint_seen: {sha256:...}
- requested_scope:
  - {stage or path scope}

### Safety
- secrets_required: none
- destructive_actions_allowed: false

## Evidence
- none

## Status
- current: Submitted
- updated_at: {ISO8601}
- updated_by: {actor_id}

## Audit
- {timestamp} actor registration requested

