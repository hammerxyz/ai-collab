# ACTOR_PROFILES

> 本目录存放 Agent 能力声明 JSON 文件
> ACTORS.md 是人类可读索引（授权源），本目录是机器可读 profile

## 规则

- 文件命名：`{ROLE}_{IDE}_{MODEL}.json`
- 结构遵循 `SCHEMAS/actor.schema.json`
- 能力声明只用于推荐路由、环境识别、人工提示
- 禁止用于自动授权、自动绕过 claim、自动 accept/reject、自动冻结
