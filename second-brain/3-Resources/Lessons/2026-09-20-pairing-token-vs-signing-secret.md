---
type: lesson
created: 2026-09-20
updated: 2026-09-20
tags: [security, pairing, ntfy, hmac]
project: SCCAnalyzer
---

# Never conflate channel auth token with signing secret

## Context
Linux cutover copied ntfy settings; phone commands failed with `signature_mismatch` when `android_signing_secret` equaled `android_ntfy_token`.

## Lesson
- **ntfy token** = ACL to publish/subscribe on the topic  
- **signing_secret** = HMAC over command/report bodies (proves desktop/phone identity)  
- They must be **different** high-entropy values  
- Pairing material belongs in a dedicated store (`alerts.db`), not casually regenerated on a second machine

## Rule for next time
On machine cutover: copy the **existing** signing secret; do not “Generate Pairing” unless intentionally re-pairing the phone. Fail loudly if token == secret.

## Related
- SCCAnalyzer: `alerts/ntfy_security.py`, pairing fields in `alerts.db`
