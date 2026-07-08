<!-- 中文：本文件是 ai-collab 的方向性路线图，非承诺。核心北极星：保持纯 prompt、无运行时。 -->

# Roadmap

Directional only — not a commitment. The North Star stays the same: **prompt-only, no runtime, no lock-in**.

## Near-term (P0)
- **Automated `lint` script** — turn `LINT.md` rules into a runnable checker (optional, not required to use the protocol).
- **Demo asset** — a short GIF / asciinema showing one full SPEC→IMPL→TEST→Accept cycle.
- **One-click onboarding pack** — ship the onboarding prompt + role constitutions as a loadable skill / paste-ready prompt pack.
- **A second worked example** — a small real project walked end-to-end.

## Mid-term (P1)
- **External scheduler examples** — Windows Task Scheduler / cron / CI wrappers for timer-less IDEs.
- **`EVIDENCE_INDEX.json`** — unified, hash-addressed evidence index.
- **`AUDIT_LEDGER.jsonl`** — append-only audit ledger.
- **Template generator** — quickly scaffold IssueSpec / ClaimLease / SubmitImpl / SubmitTestReport.

## Direction (North Star)
- Stay a **convention, not a platform**: any "runtime" capability must remain strictly optional and never a prerequisite.
- Broaden coverage across more AI IDEs and human-in-the-loop setups.
- Community translations and more language facades.
- If a verification CLI appears, it validates only; it never orchestrates.

See [CONTRIBUTING.md](CONTRIBUTING.md) to help with any of the above.
