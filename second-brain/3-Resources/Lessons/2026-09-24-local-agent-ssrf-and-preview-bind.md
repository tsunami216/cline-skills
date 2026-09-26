---
type: lesson
created: 2026-09-24
updated: 2026-09-24
tags: [ssrf, localhost, ollama, agent]
project: SkillBuilder
---

# Local coding agents: SSRF-guard fetch, bind previews to localhost

## Context

Skill Builder App Agent can `web_fetch` and start HTML/FastAPI previews. Unrestricted fetch + `0.0.0.0` bind would expose the LAN and hit metadata/private IPs.

## What we learned

- Block private/LAN/metadata in `web_fetch`
- Previews on `127.0.0.1:81xx` only
- `uvicorn --reload` kills long agent runs — use it for UI tweaks, not App Agent sessions

## Rule for next time

Any tool that fetches URLs or spawns a server from an LLM: default **deny** private nets and **localhost-only** bind. Document reload vs long-job separately.

## Related

- `Skill_builder/app/services/web_tools.py`, `preview_manager.py`
- SCCAnalyzer ntfy attachment **allowlist** is the same class of bug (SSRF)
