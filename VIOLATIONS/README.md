# AI-COLLAB Violation Event Log

> Version: 0.2 | Date: 2026-07-30 | Status: Non-core appendix, reference state
> Added in v1.5 (seven-step arbitration; vacuum-period decision pending community review)
> Common foundation: regression verification of Direction 2, circuit-breaker threshold calibration of Direction 3, the corpus of reason_code, and data collection for community experiments — four tasks consume the same data.

---

## 1. What this is

The violation event log (`VIOLATIONS/`) records rule violations occurring in ai-collab collaboration. It is the shared data foundation for both the "minimal falsifiable kernel" (Direction 2) and "trust tiering" (Direction 3).

Each project space has its own `VIOLATIONS/` directory, holding JSONL-formatted violation records (one entry per line).

---

## 2. Schema v0.2

Field definitions (see `SCHEMAS/violation.schema.json`):

| Field | Required | Description |
|------|------|------|
| `violation_id` | Yes | Unique identifier; recommended format `V-{YYYYMMDD}-{seq}` |
| `actor` | Yes | actor_id of the violating actor |
| `rule_ref` | Yes | Reference to the violated rule; format `invariant://` / `pattern://` / `action://` |
| `context_hash` | No | Context snapshot hash at the time of violation (for retrospective tracing) |
| `detected_by` | Yes | Detector: WATCHDOG / HUMAN / TEST / QA / SELF_CHECK |
| `outcome` | Yes | Outcome: corrected / arbitrated / circuit_broken / escalated / false_positive |
| `timestamp` | Yes | Violation timestamp (ISO 8601) — circuit-breaker threshold N calibration requires violation frequency |
| `severity` | No | Severity: low / medium / high — derived from reversible + blast_radius |
| `near_miss` | No | Whether a near-miss violation. When true, only existence is recorded, not content |
| `category` | No | Violation category (see taxonomy below) |

---

## 3. Violation taxonomy

A violation taxonomy MUST be defined before experimentation; otherwise the "violations" reported by multiple IDEs will be inconsistent and the data cannot be merged.

### True violations
- `field_omission`: envelope field omitted
- `stage_skip`: stage skipped
- `arbitration_bypass`: arbitration chain bypassed
- `reason_chain_missing`: reason chain missing

### False positives (highest-value noise source)
- `false_positive`: AI behavior that appears to violate but is actually reasonable
- `protocol_ambiguity`: reasonable behavior caused by ambiguous protocol text — such "false positives" point directly to ambiguity in the protocol text and are the noise source that MUST be eliminated first when Direction 2 compresses invariants

### Catch-all categories (for cold start)
Used during the early experimental period when data volume is insufficient to ensure aggregability; refine after data accumulates:
- `logic_error`: logic error
- `permission_error`: permission error
- `format_error`: format error
- `hallucination`: hallucination

---

## 4. Write-authority rules (confirmed in v1.5, seven-step arbitration)

**The `outcome` entry of the trust_log is written by the acceptor** (TEST/QA/WATCHDOG/human — i.e., "the party that determines the result"). An actor has only read access to its own log.

This is a direct extension of the permission-isolation invariant — the executor does not grade itself. This is a structural matter, not a moral one.

---

## 5. Near-miss violation logging (confirmed in v1.5)

Near-miss violations (near_miss) record only existence, not content.

When an actor catches itself on the verge of a violation, it appends a one-line count to its own log (`near_miss: true` + `rule_ref`) at the cost of a single sentence, without recording the reason chain.

**Known limitation**: near-miss data is inherently self-reported and necessarily undercounted. When analyzing, stratify by `detected_by`; do not mix with WATCHDOG-detected data.

---

## 6. JSONL format example

```jsonl
{"violation_id":"V-20260730-001","actor":"IMPL-A","rule_ref":"action://SubmitImpl","detected_by":"TEST","outcome":"corrected","timestamp":"2026-07-30T10:30:00Z","severity":"low","category":"field_omission"}
{"violation_id":"V-20260730-002","actor":"IMPL-B","rule_ref":"invariant://permission-isolation","detected_by":"WATCHDOG","outcome":"escalated","timestamp":"2026-07-30T11:15:00Z","severity":"high","category":"arbitration_bypass"}
{"violation_id":"V-20260730-003","actor":"TEST-A","rule_ref":"pattern://evidence-strength","detected_by":"SELF_CHECK","outcome":"corrected","timestamp":"2026-07-30T14:00:00Z","near_miss":true,"category":"format_error"}
```

---

## 7. Consumers

| Consumer | Use |
|--------|------|
| Direction 2 regression verification | Before deleting an old rule, use violation data to prove that the rule's violation detection never fired or is derivable from invariants |
| Direction 3 circuit-breaker threshold N | Calibrate the circuit-breaker threshold using violation frequency (timestamp) + severity |
| reason_code corpus | Mine the reason_code encoding system from the violation taxonomy |
| Community experiment data collection | Record the type, cause, and involved fields/rules of each violation |
