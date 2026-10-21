# 0003 — Phone revealed only after donor accepts
Status: Accepted (2026-10-13)

**Context:** Need fastest possible coordination with no cost; must protect donors' numbers.
**Decision:** Donor taps "I can donate" → both sides see each other's number and call normally. Numbers live only in `user_phones` / `request_contacts` (no client select) and are returned only by `get_request_contact` / `get_accepted_donors`.
**Consequences:** No in-app chat/call in MVP. Contact RPCs are the most security-critical code; always reviewed by `security-reviewer`.
