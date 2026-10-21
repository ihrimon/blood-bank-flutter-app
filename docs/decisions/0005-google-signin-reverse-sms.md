# 0005 — Google Sign-In + reverse-SMS phone verification
Status: Accepted (2026-10-14) · Open item: webhook signing support (S0-T7)

**Context:** OTP SMS costs money; zero budget (0004). Phone numbers still must be real for donor/requester contact.
**Decision:** Login via Google (Supabase Auth). Phone verified by the user sending `RB <code>` to our gateway SIM; an old Android phone running SMS Gateway for Android (capcom6, Apache-2.0) posts `sms:received` to Edge Function `sms-verify-webhook` (MVP §৫.৬). Fallback: moderator verifies manually. Verified phone required to be a donor, create, or answer requests.
**Consequences:** Gateway phone is a single point of failure for *new* verifications only (heartbeat + moderator fallback). Sender spoofing is possible but rare; club "Verified" badge remains the main trust signal. Rare-group SMS alerts are optional/off by default.
