---
type: lesson
created: 2026-09-20
updated: 2026-09-20
tags: [agents, memory-bank, second-brain, git]
project: SCCAnalyzer
---

# Two memory layers: repo Memory Bank vs personal Second Brain

## Context
Needed both tip-accurate project status and durable lessons reusable outside one repo.

## Lesson
| Layer | Where | What |
|-------|-------|------|
| **Memory Bank** | `repo/memory-bank/` (git) | Current focus, versions, plan status for **this** codebase |
| **Second Brain** | `~/Documents/SecondBrain` | Cross-project lessons, architecture distillations, capture inbox |

- Update Memory Bank when shipping product changes on a branch  
- Distill **reusable** lessons into Second Brain so other programs/agents can find them  
- Don’t dump entire memory-bank copies into Second Brain — link + distill

## Rule for next time
After a painful bug or architectural decision: write a short lesson note here the same day.

## Related
- Vault: `AGENTS.md`, Cursor skill `~/.cursor/skills/second-brain`
- Portable skills hub: `tsunami216/cline-skills`
- Cursor Chat project notes: `../../1-Projects/CursorChat/_project.md`
