<!-- 中文说明：项目登记表模板。声明 project_id 与 workspace_root。 -->

# Project: {project_id}

## Header
- project_id: {project_id}
- project_name: {project_name}
- workspace_root: {absolute canonical path}
- path_fingerprint: {sha256:...}
- artifact_policy: WorkspaceOnly
- artifact_root: .
- created_at: {ISO8601}
- status: Active

## Scope
- allowed_roots:
  - {absolute canonical path}
- forbidden_roots:
  - none

## Collaboration
- blackboard: PROJECTS/{project_id}/BLACKBOARD.md
- handoff_dir: PROJECTS/{project_id}/HANDOFF
- claims_dir: PROJECTS/{project_id}/CLAIMS
- heartbeat_dir: PROJECTS/{project_id}/HEARTBEAT
- evidence_dir: PROJECTS/{project_id}/EVIDENCE
- audit_dir: PROJECTS/{project_id}/AUDIT

## Artifact Rule
- project outputs stay under workspace_root.
- blackboard stores filenames, workspace-relative paths, hashes, statuses, timestamps, actor ids, and short summaries only.
- full content must live in workspace artifacts, evidence artifacts, source files, or project reports under workspace_root.

