<!-- 中文：ai-collab 是纯文件协议，无服务器、无网络、无运行时。安全重点是不泄露密钥、不误用协议。 -->

# Security Policy

## Supported versions

| Version | Supported |
|---|---|
| v1.1 (latest) | ✅ |
| v1.0 | ❌ (legacy, 9-field envelope) |

## Security model

ai-collab is a **filesystem protocol** — there is no server, no network endpoint, and no mandatory runtime dependency in the repo — optional local tooling (PowerShell monitor, static HTML dashboard) is provided for convenience but is not required for protocol operation. Security therefore centers on two things:

1. **Never commit secrets.** No keys, tokens, cookies, or real PII belong in this directory. The `.gitignore` already excludes common secret paths; review it before committing.
2. **Protocol misuse.** Because cooperation relies on participants following the rules, the main risks are evidence forgery (e.g. passing `SourceScan` off as `Runtime`) and one role closing the implement–test–accept loop alone. These are governance issues, not code vulnerabilities.

## Reporting a vulnerability

Please **do not open a public issue** for security-sensitive reports. Instead, use **GitHub Private Vulnerability Reporting** to submit security vulnerability reports.

We will acknowledge within a few days and coordinate a fix / disclosure timeline with you.

## Out of scope

There is no daemon to exploit and no dependency to patch. Reports about "RCE" in ai-collab itself are almost certainly misapplied — point us to the exact file and misuse scenario so we can clarify the docs or add a guardrail.
