# HANDOFF 目录

根目录 `HANDOFF/` 是全局占位目录，不承接具体项目交付信封。

正常项目任务应使用：

```text
PROJECTS/{project_id}/HANDOFF/
```

任何具体项目任务都必须写入对应项目空间。根目录不再保留具体项目情况。

如果这里出现非 README 文件，WATCHDOG 应标记为结构偏差，并要求迁移到 `PROJECTS/{project_id}/HANDOFF/`。

## 命名规则

`{STAGE}_{FROM}_TO_{TO}_{TIMESTAMP}.md`

- STAGE: 阶段标识，如 S2_3A, S2_4, S3_1
- FROM: 发起方，SPEC / IMPL / TEST
- TO: 接收方，SPEC / IMPL / TEST / ALL / HUMAN
- TIMESTAMP: ISO8601紧凑格式，如 20260613T193000

## 示例

- `S2_3A_SPEC_TO_IMPL_20260613T193000.md` — SPEC向IMPL下发S2_3A规范
- `S2_3A_IMPL_TO_TEST_20260614T100000.md` — IMPL向TEST提交S2_3A实现
- `S2_3A_TEST_TO_SPEC_IMPL_20260614T150000.md` — TEST向SPEC和IMPL提交测试报告

## 信封格式

见 PROTOCOL.md 第三节。

## 处理对象规则

- 信封 `to` 字段必须列出需要处理或知会的角色/actor；正文中每个请求、裁决、复验、实现、确认事项也必须明确处理对象。
- 任何 actor/role 在浏览信封时看到属于自己的处理项，必须处理或明确回信说明阻塞；不得因为信封不是单独一对一发送而忽略。
- 如果发起方本轮工作已完成，且没有需要其他角色处理、确认、复验或裁决的事项，允许只更新项目 `BLACKBOARD.md`，不发空信封。

## 多项目字段

在 `PROJECTS/{project_id}/HANDOFF/` 中的新信封，Header 必须包含：

- `project_id`
- `sequence_no`
- `depends_on`
- `supersedes`
- `requires_blackboard_revision`

处理顺序见 `..\ORDERING.md`。

## 产出物引用

信封正文只应引用项目工作目录中的产出物文件名、相对路径、artifact_id、evidence_id 或 hash。不要把完整报告、大段日志或代码正文直接粘贴到信封中，除非该信封本身就是一个短规范或短裁决。

## 不可变规则

- 原始信封视为不可变事件。
- 状态变化优先通过新信封、BLACKBOARD 历史或 AUDIT 记录表达。
- 不要修改其他 actor 创建的信封。
- 如果信封被后续指令替代，在 BLACKBOARD 中标记 `Superseded`，并创建新的替代信封。
