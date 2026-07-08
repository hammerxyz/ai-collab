# AI-COLLAB 记忆策略与衰减规则

> **状态：非核心附录** | 本文件为记忆管理参考规范，无自动衰减算法。v1.1 整改已将 MEMORY 从"四层衰减机制"简化为"项目记忆目录"。

> 版本：1.0 | 日期：2026-06-14

---

## 一、记忆层级

| 层级 | 目录 | 生命周期 | 内容 | 写入方 |
|------|------|---------|------|--------|
| WORKING | `MEMORY/WORKING/{actor_id}/` | 会话级 | 会话恢复摘要 | 各 actor |
| EPISODIC | `MEMORY/EPISODIC/` | 阶段级（90天） | 阶段事件摘要 + evidence refs | IMPL/TEST |
| SEMANTIC | `MEMORY/SEMANTIC/` | 项目级（永久） | 项目约束、决策、约定 | SPEC/HUMAN |
| PROCEDURAL | `MEMORY/PROCEDURAL_INDEX.md` | 跨项目（索引） | 跨项目过程知识索引 | HUMAN 审核 |

---

## 二、WORKING 层规则

### 目录结构

```text
MEMORY/WORKING/
├── INDEX.md                    # 指针和短摘要
├── SPEC/
│   ├── latest.md               # 最近一次会话摘要
│   └── {session_id}.md         # 历史会话摘要
├── IMPL/
│   ├── latest.md
│   └── {session_id}.md
└── TEST/
    ├── latest.md
    └── {session_id}.md
```

### 规则

- actor 只能写自己的 `WORKING/{actor_id}/`
- `INDEX.md` 只保存指针和短摘要
- `latest.md` 只指向最近会话摘要，不存完整上下文 dump
- 会话结束后归档到 EPISODIC

---

## 三、EPISODIC 层规则

- 只存阶段事件摘要和 evidence refs，不存完整产出物
- 保留 90 天
- 阶段完成时由 IMPL/TEST 写入

---

## 四、SEMANTIC 层规则

- 由 SPEC/HUMAN 审核，永久保留
- 包含：命名规范、架构约束、设计决策
- 修改必须经 SPEC/HUMAN 审批

---

## 五、PROCEDURAL 层规则

- 项目内只放 `PROCEDURAL_INDEX.md`（索引）
- 跨项目知识沉淀另设全局 `KNOWLEDGE/`（注：KNOWLEDGE/ 目录暂未建立，全局知识层暂不生效）
- 不自动跨项目沉淀

---

## 六、衰减规则

| 对象 | 规则 | 执行方 |
|------|------|--------|
| 活跃信封 | 7天无更新 → 标记 Stale | WATCHDOG |
| ClaimLease | 过期后24小时 → 降级为 Expired | WATCHDOG |
| 黑板历史 | 超过30条状态变更 → 折叠为摘要 | HUMAN/SPEC |
| 黑板膨胀 | 超过阈值 → 归档到 BLACKBOARD_ARCHIVE/ | HUMAN/SPEC |
| PASS 证据 | 可从当前快照隐藏，索引保留 | WATCHDOG |
| CONDITIONAL/FAIL/BLOCKED/SECURITY 证据 | 保持可见直到显式解决 | 不可衰减 |
| evidence/audit 文件 | 永不因衰减删除 | 硬规则 |
| 衰减动作 | 必须写入项目 AUDIT/ | 硬规则 |

---

## 七、BLACKBOARD_ARCHIVE 归档规则

### 目录结构

```text
PROJECTS/{id}/BLACKBOARD_ARCHIVE/
├── INDEX.md                        # 归档索引
└── {start}_{end}_{sha8}.md         # 归档内容
```

### 归档时必须

1. 在 `BLACKBOARD_ARCHIVE/INDEX.md` 记录范围、hash、actor、时间
2. 在项目 `AUDIT/` 记录 `ArchiveBlackboard`
3. 在当前 `BLACKBOARD.md` 历史区追加一条归档摘要
4. 不删除 evidence/audit
5. 不把 unresolved risk 归档到不可见位置

---

## 八、记忆注入（启动必读）

AI IDE 会话启动时，按顺序读取：

```text
1. PROJECT.md                              # 项目定义
2. ACTORS.md                               # 角色登记
3. MEMORY/SEMANTIC/                        # 项目约束和决策
4. MEMORY/WORKING/{actor_id}/latest.md     # 本actor上次会话上下文
5. BLACKBOARD.md                           # 当前阶段状态
6. 当前信封及 depends_on                    # 待处理任务链
```

**边界**：记忆只能辅助理解，不得覆盖 `PROTOCOL.md`、`ACTIONS.md`、`PROJECT.md`、`ACTORS.md` 和用户最新指令。

---

## 九、全局 KNOWLEDGE 准入规则

> 注：KNOWLEDGE/ 目录暂未建立，全局知识层暂不生效。以下规则为预留规范，待目录建立后生效。

- `KNOWLEDGE/` 只保存人工审核后的通用协作模式
- 不保存项目名称、项目路径、完整报告、代码、测试输出
- 进入 `KNOWLEDGE/` 必须有 `HUMAN` 或 `SPEC` 审核
- 项目内只能通过 `MEMORY/PROCEDURAL_INDEX.md` 引用
- WATCHDOG 发现项目细节进入 `KNOWLEDGE/` 时报告 `KnowledgeScopeViolation`
