---
type: lesson
created: 2026-09-20
updated: 2026-09-20
tags: [cursor, cloud-agents, pdf, google-drive, oauth]
project: CursorChat
---

# Cloud Agents cannot take PDFs; private Drive needs in-app OAuth

## Context
Wanted phone-app LLM review of PDFs / Google Drive links.

## What went wrong / what we learned
- Agents API prompt: **text + ≤5 raster images** only. Skills/MCP in Cursor Desktop **do not** run inside no-repo Cloud Agents.
- A Drive URL is fetchable without login only if **anyone-with-link**. Restricted files need **Google Sign-In + Drive API** in the **Android app**, then extract/render locally, then send text/images.
- GIS **AuthorizationClient** + `drive.readonly` — ID-token-only “Sign in with Google” is not enough.
- Split **short Room bubble** vs **full extract in cloud prompt** or compact seeds explode.

## Rule for next time
Plan PDF as convert-then-prompt. Private Drive = product OAuth, not a skill. Cap extract (~32k chars). Local PDF can ship before GCP clients exist.

## Related
- Plan: `pdf_drive_analysis_3e33715d.plan.md` (reviewed, not implemented)
- Project: `../../1-Projects/CursorChat/_project.md`
