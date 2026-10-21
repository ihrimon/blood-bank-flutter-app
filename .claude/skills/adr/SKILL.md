---
name: adr
description: Record a new product or technical decision as a short ADR in docs/decisions. Use when a choice changes or adds to PRD §৫ decisions, the schema contract, or the architecture.
---

1. Next number = highest `docs/decisions/NNNN-*.md` + 1. File: `NNNN-kebab-title.md`.
2. Content (English, ≤ 12 lines):

```markdown
# NNNN — <Decision title>
Status: Proposed | Accepted (YYYY-MM-DD) · Supersedes: NNNN (if any)

**Context:** <why a decision is needed, 1–3 lines>
**Decision:** <what we do, concrete names/tables/files>
**Consequences:** <trade-offs, follow-ups>
```

3. Status is `Proposed` unless the user explicitly agreed in this session — then `Accepted`.
4. If it supersedes an ADR, set the old one's Status to `Superseded by NNNN`.
5. Add a row to `docs/decisions/README.md`. If it changes a PRD decision (D1–D10) or MVP section, update that text in one or two lines and link the ADR.
