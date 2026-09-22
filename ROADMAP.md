<!-- 中文：本文件是 ai-collab 的方向性路线图，非承诺。核心北极星：保持纯 prompt、无运行时。 -->

# Roadmap

Directional only — not a commitment. The North Star stays the same: **prompt-only, no runtime, no lock-in**.

## Near-term (P0)
- **Automated `lint` script** — turn `LINT.md` rules into a runnable checker (optional, not required to use the protocol).
- **Demo asset** — a short GIF / asciinema showing one full SPEC→IMPL→TEST→Accept cycle.
- **One-click onboarding pack** — ship the onboarding prompt + role constitutions as a loadable skill / paste-ready prompt pack.
- **A second worked example** — a small real project walked end-to-end.
- **社区实验**（v1.5 确认，真空期启动）——选 3 个不同复杂度任务，让 ≥2 个 AI IDE 用 v1.2 协议执行，记录违规数据。对照组"内核-only"= actor 只读 3 条不变量 + PATTERNS.md。周期 2 周。

## Mid-term (P1)
- **External scheduler examples** — Windows Task Scheduler / cron / CI wrappers for timer-less IDEs.
- **`EVIDENCE_INDEX.json`** — unified, hash-addressed evidence index.
- **`AUDIT_LEDGER.jsonl`** — append-only audit ledger.
- **Template generator** — quickly scaffold IssueSpec / ClaimLease / SubmitImpl / SubmitTestReport.
- **方向 3 Phase 2**（动态衰减 + 熔断）——待社区实验数据。trust_log.jsonl + 读取时计算 + per-actor 熔断。见 EVOLUTION.md 方向 3。
- **方向 1**（意图同步）——reason_code 待实验数据挖掘。见 EVOLUTION.md 方向 1。

## Completed (v1.3)
- ✅ **核心不变量正式化**（方向 2）——3 条一阶不变量 + 1 条验证框架。`PROTOCOL.md` §1.2.1。
- ✅ **方向 3 Phase 1 风险静态标注**——26 个动作标注 reversible + blast_radius。`ACTIONS.md` §〇。
- ✅ **违规事件日志 schema v0.2**（共同地基）——`SCHEMAS/violation.schema.json` + `VIOLATIONS/`。
- ✅ **PATTERNS.md**——推荐模式的家，旧规则降级落点。
- ✅ **WATCHDOG 检查项 21-24**——核心不变量违反检查。

## Direction (North Star)
- Stay a **convention, not a platform**: any "runtime" capability must remain strictly optional and never a prerequisite.
- Broaden coverage across more AI IDEs and human-in-the-loop setups.
- Community translations and more language facades.
- If a verification CLI appears, it validates only; it never orchestrates.

See [CONTRIBUTING.md](CONTRIBUTING.md) to help with any of the above.
