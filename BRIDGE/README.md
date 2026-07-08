# BRIDGE — 外部 LLM 调用能力接口

> ai-collab platform version: v1.1
> 状态：接口化（历史实现已废弃，仅保留接口契约）

---

## 定位

BRIDGE 是 ai-collab 平台与外部 LLM 调用能力之间的接口层。ai-collab 只约定输入输出格式和约束（见 `BRIDGE_INTERFACE.md`），不提供实现。

历史实现（基于浏览器自动化的外部 LLM / Web 服务桥接）已在 v1.1 整改中废弃，相关代码和数据已清理。后续将以独立模块形式重新插接。

---

## 目录内容

| 文件 | 说明 |
|---|---|
| `BRIDGE_INTERFACE.md` | 接口契约：输入/输出格式、调用方式、硬规则约束 |
| `README.md` | 本文件 |

---

## 后续模块接入方式

1. 实现方按 `BRIDGE_INTERFACE.md` 定义的输入输出格式开发独立模块。
2. 模块自行管理浏览器/API 连接、认证、会话、日志，不写入 ai-collab 目录。
3. 历史经验文档不随仓库发布，实现方需自行积累各 Web LLM 的接入经验。
4. 模块接入后，ai-collab 的 actor 可通过约定格式调用外部 LLM，但 LLM 输出只能作为 `Inference` 级参考，不得冒充验收结论或更高证据等级。

---

## 安全约束

- LLM 输出不得直接作为 ai-collab 的验收结论（验收权归 SPEC）
- LLM 输出不得冒充 `Runtime`、`RealProvider` 等证据等级
- 调用日志不写入 ai-collab 的 HANDOFF/EVIDENCE/AUDIT 目录
- 认证凭据（cookie/token/登录态）由模块安全存储，不写入 ai-collab 目录
