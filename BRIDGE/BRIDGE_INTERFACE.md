# BRIDGE 接口契约

> ai-collab platform version: v1.1
> 本文件定义 ai-collab 平台与外部 LLM 调用能力之间的接口契约。
> 能力实现不在 ai-collab 内，由后续独立模块插接。

---

## 定位

ai-collab 通过此接口挂接外部 LLM 调用能力（如浏览器自动化操控 Web LLM、API 调用等）。ai-collab 只约定输入输出格式和约束，不提供实现。

历史实现（基于浏览器自动化的外部 LLM / Web 服务桥接）已在 v1.1 整改中废弃，相关代码和数据已清理，历史经验文档不随仓库发布。

---

## 输入

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| prompt | string | 是 | 自然语言 prompt |
| target_model | string | 否 | 目标模型标识（如 service-a/service-b/service-c），不填则由模块自选 |
| max_tokens | int | 否 | 最大输出 token 数 |

---

## 输出

| 字段 | 类型 | 说明 |
|---|---|---|
| response | string | LLM 回复正文 |
| model | string | 实际使用的模型标识 |
| evidence_level | enum | `SourceScan` 或 `Inference`（LLM 输出默认 Inference） |

---

## 调用方式

由后续独立模块实现，ai-collab 只约定输入输出格式。模块自行管理：
- 浏览器/API 连接和认证
- 会话和上下文管理
- 调用日志（不写入 ai-collab）
- 错误处理和重试

---

## 约束（硬规则）

1. **LLM 输出不得直接作为验收结论**：ai-collab 的验收权归 SPEC（L4），LLM 输出只能作为参考信息。
2. **LLM 输出不得冒充证据等级**：LLM 输出的 evidence_level 只能是 `Inference`，不得标记为 `RuntimePASS`、`RealProviderPASS` 等更高等级。
3. **调用日志不写入 ai-collab**：模块自行管理日志，不污染 ai-collab 的 HANDOFF/EVIDENCE/AUDIT 目录。
4. **敏感数据不残留**：模块的认证凭据（cookie/token/登录态）由模块自行安全存储，不得写入 ai-collab 目录。
