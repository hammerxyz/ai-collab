<!-- 中文说明：项目黑板模板（三段式）。Current State + Latest Entries(≤20) + History，详见 PROTOCOL §5.3。 -->

# Project Blackboard: {project_id}

> project_id: {project_id}
> blackboard_revision: {YYYYMMDDTHHMMSS}-{actor_id}
> last_updated: {ISO8601}
> updated_by: {actor_id}
>
> Rule: snapshot sections may be updated; history is append-only. Store filenames, relative paths, hashes, statuses, timestamps, actor ids, and short summaries only.

---

## Current State

| stage | status | owner | last_updated | key_envelope | notes |
|---|---|---|---|---|---|
| {stage} | Planned | — | — | — | — |

---

## Active Envelopes

| envelope_id | stage | from→to | action | status | created_at |
|---|---|---|---|---|---|
| — | — | — | — | — | — |

---

## Active Claims

| claim_id | stage | actor | status | expires_at | file_scope |
|---|---|---|---|---|---|
| — | — | — | — | — | — |

---

## History

| time | stage | old_status | new_status | actor | notes |
|---|---|---|---|---|---|
| {ISO8601} | project | — | initialized | {actor_id} | project blackboard created |

