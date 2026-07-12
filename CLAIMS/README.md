# CLAIMS 目录

> **状态：强烈建议（v1.1）** | 长任务建议先获取 ClaimLease，TTL 过期后 WATCHDOG 会扫描提示，但协议本身无运行时强制执行。

根目录 `CLAIMS/` 是全局占位目录，不承接具体项目任务认领记录。

正常项目任务应使用：

```text
PROJECTS/{project_id}/CLAIMS/
```

任何具体项目 ClaimLease 都必须写入对应项目空间。根目录不再保留具体项目情况。

如果这里出现非 README 文件，WATCHDOG 可标记为结构偏差，并建议迁移到 `PROJECTS/{project_id}/CLAIMS/`。

## 命名规则

`{STAGE}_CLAIM_{CLAIM_ID}.md`

- STAGE: 阶段标识
- CLAIM_ID: 唯一标识，如 IMPL_001

## 认领记录格式

见 ACTIONS.md 第3.1节 ClaimTask。

## 租约规则

ClaimTask 同时也是 ClaimLease。详细字段和续租规则见：

- `SCHEMAS/claim.schema.json`（ClaimLease 字段定义与续租规则的单一权威来源）
- `..\TIMER_LOOP.md`
- `..\WATCHDOG.md`

建议 AI IDE 先获得有效 ClaimLease 再执行长时间任务或修改共享文件范围。

## file_scope 填写规范（v1.1 补丁）

ClaimLease 的 `file_scope` 字段用于标识认领的文件范围，使冲突检测可机器化检查。

**填写要求**：

- `file_scope` 必须填**具体文件路径列表**（相对项目根的路径），不得使用自由文本 stage 描述。
- 多个文件用逗号分隔。

**正确示例**：
```
file_scope: D7/impl/vectorstore.py, D7/impl/hybrid_retriever.rs, D7/tests/test_vectorstore.py
```

**错误示例**（禁止）：
```
file_scope: <模块/路径> 实现说明（示例：某检索模块的实现）
```

**理由**：`SCHEMAS/claim.schema.json` 已支持 file_scope 级冲突检测（"Active exclusive claims with overlapping file_scope conflict"），但只有填结构化路径，AI IDE 才能一行比对出两个租约是否覆盖同一文件。自由文本 scope 无法机检，冲突全靠自觉。
