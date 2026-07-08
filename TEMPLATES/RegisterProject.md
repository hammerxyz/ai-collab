<!-- 中文说明：新项目登记模板。首次接入项目时填入 PROJECTS/INDEX.md 与 PROJECTS/{project_id}/。 -->

# Envelope: {ENVELOPE_ID}

## Header
- envelope_id: {ENVELOPE_ID}
- project_id: {project_id}
- stage: PROJECT_REGISTRATION
- from: {HUMAN | SPEC}
- to: ALL
- action: RegisterProject
- priority: P0
- risk_level: Medium
- created_at: {ISO8601}
- expires_at: {ISO8601 or none}

## Payload
### Project
- project_name: {name}
- workspace_root: {absolute canonical path}
- path_fingerprint: {sha256:...}
- artifact_policy: WorkspaceOnly
- artifact_root: {workspace-relative folder or "."}

### Scope
- allowed_roots:
  - {absolute canonical path}
- forbidden_roots:
  - {none or path}

### Initial Actors
- SPEC: {actor_id or TBD}
- IMPL: {actor_id or TBD}
- TEST: {actor_id or TBD}

## Evidence
- none

## Status
- current: Submitted
- updated_at: {ISO8601}
- updated_by: {HUMAN | SPEC}

## Audit
- {timestamp} project registration requested

