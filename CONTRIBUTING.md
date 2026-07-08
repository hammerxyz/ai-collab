<!-- 中文：欢迎参与 ai-collab。本项目的核心哲学是"路"——纯 prompt、无运行时、不锁定任何 AI IDE。提交前请确认你的改动符合这一哲学。 -->

# Contributing to ai-collab

Thank you for considering a contribution. ai-collab is deliberately **prompt-only and runtime-free**: it is a set of Markdown / JSON conventions that let multiple AI IDEs cooperate through a shared folder. Keep that "road" philosophy in mind for every change.

## What we welcome

- **Protocol & prompt refinements** — clearer role constitutions, better envelope field guidance, sharper arbitration rules.
- **Templates & schemas** — new `TEMPLATES/*.md`, JSON Schema additions in `SCHEMAS/`.
- **Role runbooks** — improvements to `RUNBOOKS/` and `ROLE_*.md`.
- **Tooling that stays optional** — a lint script, a template generator, a monitor collector. These must *never* become a required runtime.
- **Docs & translations** — clearer explanations, more examples, more languages.
- **Examples** — walkthroughs of real multi-AI-IDE collaboration.

## What we will not accept

- Any code that introduces a **central runtime, scheduler, server, or dependency** that participants must run. ai-collab is a convention, not a platform.
- Changes that **lock users into one AI IDE or vendor**.
- Commits that reintroduce **specific model / Web AI names** (we scrub them on purpose — see README).
- Secrets, tokens, cookies, or real PII in any file.

## How to propose a change

1. **Open an issue first** for anything beyond a typo: describe the problem and your proposed direction. This avoids wasted effort.
2. **Fork → branch → PR.** Keep branches small and focused. Reference the issue number in the PR.
3. **Follow the bilingual convention:**
   - Facade docs (`README.md`, `PROTOCOL.md`, `QUICKSTART.md`) use **section-level Chinese/English interleaving**.
   - Other docs are written in English with a short Chinese header note (`<!-- 中文：... -->`).
   - `SCHEMAS/*.json` stay JSON; Chinese descriptions already live inside them.
4. **Keep the no-runtime boundary.** If you add a script, document it as optional and never make it a prerequisite for using the protocol.
5. By submitting a PR you agree to the [Code of Conduct](CODE_OF_CONDUCT.md).

## Good first contributions

Look for issues labeled `good first issue`. Typical starters: clarify a template, add a missing schema field, improve a runbook step, or write a small example.

## Where to look next

- Roadmap: [ROADMAP.md](ROADMAP.md)
- Changelog: [CHANGELOG.md](CHANGELOG.md)
- Protocol: [PROTOCOL.md](PROTOCOL.md)
