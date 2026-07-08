# MONITOR：只读浏览器看板

`MONITOR/` 提供一个零依赖的浏览器看板，让人类和 AI IDE 快速查看多项目协作状态。

---

## 1. 快速使用

### 1.1 生成数据

```powershell
# 在 MONITOR/ 目录下运行
powershell -ExecutionPolicy Bypass -File collect.ps1

# 或指定项目
powershell -ExecutionPolicy Bypass -File collect.ps1 -ProjectId example-project-xxxxxxxx

# 或采集全部项目
powershell -ExecutionPolicy Bypass -File collect.ps1 -All
```

> **跨平台说明**：`collect.ps1` 是 PowerShell 脚本，**默认在 Windows 上直接运行**；在 macOS / Linux 上需先安装 PowerShell（`pwsh`）再执行同样的命令。未运行采集时看板为空（不影响协议本身，信封/证据仍按 Markdown 正常写入）。HTTP 模式下可用任意平台的 `python -m http.server` 起服务。
> *Cross-platform: `collect.ps1` runs natively on Windows; on macOS/Linux install PowerShell (`pwsh`) first. Without collection the dashboard is empty, but the protocol itself is unaffected — envelopes/evidence are still written as Markdown.*

脚本会生成两个文件：
- `PROJECTS/{project_id}/MONITOR/status.json` — 项目级状态数据
- `MONITOR/status_data.js` — 聚合数据（供 file:// 协议使用）

### 1.2 打开看板

**方式一：直接双击（推荐，无需开端口）**

双击 `MONITOR/index.html`，浏览器通过 `status_data.js` 内嵌数据渲染看板。

**方式二：HTTP 服务（支持自动刷新）**

```powershell
cd MONITOR
python -m http.server 8765
# 访问 http://localhost:8765
```

HTTP 模式下点击"刷新"按钮可实时拉取最新 status.json。

### 1.3 更新数据

每次想看最新状态时，重新运行 `collect.ps1`，然后刷新浏览器。

---

## 2. 文件清单

| 文件 | 用途 | 生成方式 |
|---|---|---|
| `index.html` | 只读浏览器看板 | 手动维护 |
| `collect.ps1` | 状态采集脚本 | 手动维护 |
| `status_data.js` | 聚合数据（file:// 协议用） | collect.ps1 自动生成 |
| `status.example.json` | 示例数据（开发参考） | 手动维护 |

项目级数据：
| 文件 | 用途 |
|---|---|
| `PROJECTS/{project_id}/MONITOR/status.json` | 单项目状态数据 |

---

## 3. collect.ps1 采集范围

脚本只读扫描以下位置，**不修改任何项目文件**：

| 数据源 | 路径 | 采集内容 |
|---|---|---|
| 项目定义 | `PROJECTS/{id}/PROJECT.md` | project_name, current_stage |
| 黑板 | `PROJECTS/{id}/BLACKBOARD.md` | 阶段状态流水线 |
| 信封 | `PROJECTS/{id}/HANDOFF/*.md` | envelope_id, from, to, action, status |
| 证据 | `PROJECTS/{id}/EVIDENCE/*.json` | verdict 统计 (PASS/CONDITIONAL/FAIL/...) |
| 审计 | `PROJECTS/{id}/AUDIT/*.md` | 审计条目计数 |
| 租约 | `PROJECTS/{id}/CLAIMS/*.md` | 活跃 ClaimLease |
| 心跳 | `PROJECTS/{id}/HEARTBEAT/*.json` | actor 状态和最近活动 |

---

## 4. 看板功能

看板包含以下区域：

- **汇总栏**：项目数、阶段数、已验收、进行中、证据数、审计数、冲突、缺证据、缺审计
- **阶段流水线**：可视化各阶段状态（绿=已验收，蓝=进行中，灰=待开始）
- **信封流**：按 SPEC/IMPL/TEST 泳道展示活跃信封
- **Actor 表**：各角色当前状态和最近活动
- **证据图表**：按等级和结果分布的条形图
- **审计表**：高风险操作记录
- **差距追踪**：gap 卡片列表
- **租约表**：活跃 ClaimLease 及过期时间

---

## 5. 只读原则

看板严格遵守只读：

- 不直接 Accept / Reject / Frozen
- 不修改 `BLACKBOARD.md`
- 不修改信封、claim、evidence、audit
- 不展示密钥、token、raw PII
- 不把"无红色告警"展示成通过

如需写操作，必须通过标准协议（信封、claim、audit）完成。

---

## 6. 数据格式

### 6.1 项目级 status.json

```json
{
  "project_id": "example-project-xxxxxxxx",
  "project_name": "example-project",
  "generated_at": "2026-06-14T10:00:00+08:00",
  "current_stage": "S2_PRE_S2_2L_BACKFILL",
  "stages": [
    { "name": "S2_0A", "status": "completed", "actor": "IMPL" },
    { "name": "S2_2L", "status": "in_progress", "actor": "TEST" }
  ],
  "envelopes": [...],
  "evidence_summary": { "total": 12, "pass": 7, "conditional": 5 },
  "audit_count": 1,
  "active_claims": [...],
  "actors": [...]
}
```

### 6.2 聚合 status_data.js

```javascript
window.STATUS_DATA = {
  "generated_at": "2026-06-14T10:00:00+08:00",
  "projects": [ /* 项目级 status.json 数组 */ ]
};
```

index.html 同时兼容两种格式：有 `projects` 数组时按全局级渲染，有 `project_id` 时按项目级渲染。

---

## 7. 维护指南

### 7.1 新增项目

1. 在 `PROJECTS/{new_id}/` 下创建标准目录结构
2. 运行 `collect.ps1 -ProjectId {new_id}`
3. 看板自动识别新项目

### 7.2 修改看板样式

编辑 `index.html` 顶部的 CSS 变量：

```css
:root {
  --bg: #f8fafc;        /* 页面背景 */
  --surface: #ffffff;    /* 卡片背景 */
  --text: #1e293b;       /* 主文字 */
  --ok: #16a34a;         /* 通过/验收 */
  --warn: #d97706;       /* 警告/条件通过 */
  --bad: #dc2626;        /* 失败/冲突 */
}
```

### 7.3 修改采集逻辑

编辑 `collect.ps1` 中的 `Collect-Project` 函数。注意：
- 脚本必须保持只读，不修改任何项目文件
- 输出必须写入 `PROJECTS/{id}/MONITOR/status.json`
- 聚合数据必须同步写入 `MONITOR/status_data.js`

### 7.4 状态值映射

看板识别以下状态值并着色：

| 状态 | 颜色 | 含义 |
|---|---|---|
| `Accepted` / `completed` | 绿 | 已验收 |
| `ImplSubmitted` / `in_progress` / `active` | 蓝 | 进行中 |
| `Planned` / `pending` | 灰 | 待开始 |
| `Conditional` | 黄 | 条件通过 |
| `Blocked` / `blocked` | 红 | 阻塞 |
| `Frozen` | 紫 | 冻结 |
