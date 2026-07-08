<!-- 中文说明：项目 actor 登记表模板。每个参与的 AI IDE 在此登记 role 与过期时间。 -->

# Actors: {project_id}

| actor_id | role | ai_ide | authorized | workspace_root_seen | path_fingerprint_seen | expires_at | notes |
|---|---|---|---|---|---|---|---|
| SPEC | SPEC | AI IDE | true | {absolute canonical path} | {sha256:...} | {ISO8601} | specification/planning/final acceptance |
| IMPL | IMPL | AI IDE | false | {absolute canonical path} | {sha256:...} | {ISO8601} | implementation/self-check |
| TEST | TEST | AI IDE | false | {absolute canonical path} | {sha256:...} | {ISO8601} | independent testing |
| WATCHDOG_GENERIC | WATCHDOG | Any/Human | false | {absolute canonical path} | {sha256:...} | {ISO8601} | deterministic health-check only |

## Rules

- Actor registration is a soft coordination guard, not OS-level authorization.
- Actors must still obey `ACTIONS.md`, `RUNBOOKS/`, `ORDERING.md`, and project `PROJECT.md`.
- New actor ids must be added here before processing project-specific envelopes.
- Expired actor registrations cannot authorize project work.

