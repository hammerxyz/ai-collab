# Project Index

`ai-collab` uses strict project spaces. Concrete project state must live under `PROJECTS/{project_id}/`.

| project_id | project_name | workspace_root | status | notes |
|---|---|---|---|---|
| `example-project-1a2b3c4d` | example-project | `<workspace_root>` | Demo | 示例项目；目录结构与脚手架见 `PROJECTS/_TEMPLATE/`（请勿在仓库中提交真实项目数据） |
| `example-project-2b3c4d5e` | example-project-2 | `<workspace_root>` | Archived | 示例项目（已归档示例），演示归档后索引的标注方式 |

## Rules

- Root-level placeholder directories do not contain concrete project state.
- AI IDEs must resolve `project_id` before scanning handoff/claim/evidence/audit files.
- If a project is missing from this index but has a project directory, use `PROJECTS/{project_id}/PROJECT.md` as source of truth and update this index.

