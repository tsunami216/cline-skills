# Memory Bank

Maintains a project's Memory Bank by **scanning all six core files** on every
update (not just `activeContext` / `progress`).

## The six files

1. `memory-bank/projectbrief.md` — goals and scope
2. `memory-bank/productContext.md` — why it exists / UX goals
3. `memory-bank/systemPatterns.md` — architecture and patterns
4. `memory-bank/techContext.md` — stack, setup, constraints
5. `memory-bank/activeContext.md` — current focus and next steps
6. `memory-bank/progress.md` — what works, what’s left, known issues

## Commands

- **initialize memory bank** — rebuild all six from the repo
- **update memory bank** — open and scan **all six**, refresh any that are stale
- **follow memory bank** — re-read **all six**, then continue from `activeContext.md`

## Update checklist (required)

```
- [ ] projectbrief.md
- [ ] productContext.md
- [ ] systemPatterns.md
- [ ] techContext.md
- [ ] activeContext.md
- [ ] progress.md
```

Report which were edited vs confirmed unchanged. Prefer short factual bullets;
do not invent status.

## Anti-patterns

- Updating only activeContext/progress while skipping the other four
- Claiming “updated” without opening all six
