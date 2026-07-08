# AI-COLLAB 原子写入约定

> **状态：非核心附录** | 本文件为原子写入操作参考，无自动执行机制。v1.1 整改已将原子写入从"强制机制"降级为"操作参考"。

> 版本：1.0 | 日期：2026-06-14

---

## 规则

多 AI IDE 并发写文件时，可能出现半写入文件。所有写入方必须遵守以下约定：

### 写入流程

```text
1. 写入目标文件时，先写入 {filename}.{actor_id}.{timestamp}.tmp
2. .tmp 必须写在目标文件同目录（保证同一文件系统内 rename）
3. 内容完整后（如可能则 fsync），rename 为最终文件名
4. rename 必须在同一文件系统内
```

### 示例

```text
目标文件：PROJECTS/example-project/HANDOFF/PLAN_SPEC_TO_IMPL_20260614.md
临时文件：PROJECTS/example-project/HANDOFF/PLAN_SPEC_TO_IMPL_20260614.IMPL.20260614T101500.tmp
```

### 读取方规则

- 读取方不得处理 `.tmp` 文件
- 发现 `.tmp` 文件时跳过，不报错

### WATCHDOG 规则

- WATCHDOG 发现超过 1 小时的 `.tmp` 文件，报告 `OrphanTempFile`
- WATCHDOG 不删除 `.tmp`，只报告
- 由 HUMAN/SPEC 授权清理

### 命名格式

```text
{filename}.{actor_id}.{ISO8601_timestamp}.tmp

其中：
- filename: 目标文件名（含扩展名）
- actor_id: 写入方 actor 标识（如 IMPL）
- ISO8601_timestamp: 写入开始时间（如 20260614T101500）
- .tmp: 固定后缀
```
