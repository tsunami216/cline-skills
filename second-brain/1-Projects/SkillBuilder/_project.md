---
type: project
created: 2026-09-24
updated: 2026-09-24
tags: [skill-builder, fastapi, ollama, local-web]
project: SkillBuilder
---

# Skill Builder — current status

**Repo:** `/Users/philipkim/Documents/Skill_builder`  
**App root:** `Skill_builder/` (nested)  
**Branch:** `main` @ `62d2a29` (Windows compatibility)

## Versions

| Component | Version |
|-----------|---------|
| App | **V1.4** (`Skill_builder/VERSION`) |
| UI | Local FastAPI + HTML pages on `http://127.0.0.1:8000` |

## What it is

Local web app to:

1. Author Cursor/VS Code **skills**
2. Scaffold **MCP** servers and deploy to Cursor/Cline
3. Run an Ollama **App Agent** that plans, edits a sandbox workspace, verifies, and serves a localhost preview

## Shipped (as of 2026-09-24)

- Apps: intake chat → `task_pack.json` checklist → sandboxed edits → preview on `127.0.0.1:81xx`
- Public web research (`web_search` / `web_fetch`) with SSRF guards
- LLM backends: Ollama native `/api/chat`, OpenAI, LM Studio, OpenAI-compat
- Windows install path (`install.bat`) in addition to `install.sh`

## Open / next

- Keep agent models capable (`qwen3.6:35b` or similar); flash models struggle with tool loops
- Workspaces under `workspaces/` are gitignored — do not commit jail/demo sandboxes

## Do not

- Run long App Agent jobs under uvicorn `--reload` (drops in-flight tasks)
- Bind previews off localhost
- Call `Base.metadata.create_all()` before importing **all** SQLAlchemy models

## Related

- [[architecture]] → `architecture.md`
- Repo has **no** `memory-bank/`; this vault holds the distilled architecture
- Lessons under `../../3-Resources/Lessons/`
