# EVIDENCE 目录

根目录 `EVIDENCE/` 是全局占位目录，不承接具体项目佐证索引。

正常项目任务应使用：

```text
PROJECTS/{project_id}/EVIDENCE/
```

任何具体项目 evidence 都必须写入对应项目空间。根目录不再保留具体项目情况。

如果这里出现非 README 文件，WATCHDOG 应标记为结构偏差，并要求迁移到 `PROJECTS/{project_id}/EVIDENCE/`。

## 命名规则

`{STAGE}_{EVIDENCE_ID}.json`

- STAGE: 阶段标识
- EVIDENCE_ID: 佐证唯一标识

## 佐证格式

每个佐证文件必须包含以下字段：

```json
{
  "evidence_id": "唯一标识",
  "project_id": "项目空间ID或default",
  "stage": "阶段标识",
  "type": "unit_test | integration_test | benchmark | adversarial | regression | report",
  "producer": "SPEC | IMPL | TEST",
  "evidence_level": "SourceScan | SchemaOnly | UnitTest | IntegrationTest | Runtime | RealProvider | Benchmark | Adversarial | Regression | ManualReview",
  "produced_at": "ISO8601时间戳",
  "workspace_root_label": "项目名或脱敏根目录标签",
  "artifact_path": "workspace-relative artifact路径",
  "artifact_filename": "文件名",
  "command": "产生该佐证的命令或 none",
  "exit_code": 0,
  "repo_commit": "git commit hash or unknown",
  "env_redaction": "secrets redacted / none",
  "verified_by": "SPEC | IMPL | TEST | WATCHDOG | HUMAN | none",
  "failure_semantics": "PASS | FAIL | CONDITIONAL | BLOCKED | SKIPPED",
  "sha256": "文件内容哈希",
  "content": {}
}
```

## 规则

- `Runtime`、`RealProvider`、`Benchmark`、`Adversarial`、`Regression` 必须指向可复核 artifact 或命令输出。
- 没有真实 provider key 时只能写 `CONDITIONAL` 或 `SKIPPED`，不能写 `PASS`。
- 证据文件不得包含真实密钥、token、cookie、raw PII 或未脱敏日志。
- 原始产出物必须留在项目工作目录中。`EVIDENCE/` 只保存索引、相对路径、hash、命令摘要和短结构化内容。
- 多项目模式下，`project_id` 必须与 `PROJECTS/{project_id}/PROJECT.md` 匹配。
