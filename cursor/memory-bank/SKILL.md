---
name: memory-bank
description: >-
  Maintains a project's Memory Bank by reading and updating all six core files
  (projectbrief, productContext, systemPatterns, techContext, activeContext,
  progress). Use when the user says initialize/update/follow memory bank, or
  when starting meaningful work in a repo that has a memory-bank/ folder.
---

# Memory Bank

For any repo with a `memory-bank/` directory, keep the six core files accurate
across sessions. **Never update only `activeContext.md` and `progress.md`
without opening the other four.**

## The six files (always)

1. `memory-bank/projectbrief.md` — goals and scope
2. `memory-bank/productContext.md` — why it exists / UX goals
3. `memory-bank/systemPatterns.md` — architecture and patterns
4. `memory-bank/techContext.md` — stack, setup, constraints
5. `memory-bank/activeContext.md` — current focus and next steps
6. `memory-bank/progress.md` — what works, what’s left, known issues

If `memory-bank/plans/` exists, skim the plans index when following or updating.

## Commands

| User says | Do this |
|-----------|---------|
| **initialize memory bank** | Create/rebuild all six from the repo |
| **update memory bank** | **Scan all six**, refresh every stale file |
| **follow memory bank** | **Re-read all six**, then continue from `activeContext.md` |

## Update workflow (required)

When the user says **update memory bank** (or after significant work that needs a bank refresh):

1. Open **each** of the six files (full read, not titles only).
2. Walk the checklist and edit any file whose facts are stale:

```
Memory Bank update:
- [ ] projectbrief.md
- [ ] productContext.md
- [ ] systemPatterns.md
- [ ] techContext.md
- [ ] activeContext.md
- [ ] progress.md
```

3. Prefer short, factual bullets. Do not invent status.
4. Report which files were **edited** vs **confirmed unchanged**.

## Session start / follow

At the start of meaningful work, or on **follow memory bank**: read **all six**
before acting. After that full read, use `activeContext.md` + `progress.md` for
immediate next steps.

## Anti-patterns

- Updating only `activeContext.md` / `progress.md` and skipping the other four
- Claiming the memory bank is updated without opening all six
- Inventing milestones or status not supported by the repo or conversation
