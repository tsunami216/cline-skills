---
name: validate-changes
description: >-
  After code is updated, validates that the changes actually work as the user
  requested: map acceptance criteria, run targeted tests/smoke checks, fix
  failures, and report proven vs untested. Use when finishing an implementation,
  after substantive edits, or when the user asks to validate, verify, test,
  smoke-check, or confirm the Mac/app/feature works.
---

# Validate Changes

Run this **after** substantive code changes in the same turn whenever possible.
Do not claim “done / fixed / works” until validation has been attempted and the
report below is honest about what was proven.

## When to apply

- Implementation or bugfix just landed in the working tree
- User asks to validate, verify, test, smoke-check, or “make sure it works”
- User asks whether the Mac/app/GUI/API change actually functions

Skip only for pure docs/comments with no behavior change, or when the user
explicitly says not to test.

## Workflow

Copy and track:

```
Validate Progress:
- [ ] 1. Restate acceptance criteria from the user request
- [ ] 2. Diff the change set (what could break)
- [ ] 3. Choose validation tier (unit / integration / smoke / manual-only)
- [ ] 4. Run targeted automated checks
- [ ] 5. Fix failures or add missing regression coverage
- [ ] 6. Re-run until green or blocked
- [ ] 7. Report Proven / Untested / Blocked
```

### 1. Acceptance criteria

From the latest user request (not your assumptions), list 2–6 concrete checks.
Each check must be falsifiable (“X returns Y”, “button Z starts action A”).

### 2. Change-set scope

Inspect `git status` / `git diff` (or the files you just edited). Note:

- Entry points (CLI, API, GUI handlers, chat/tools, workers)
- Data/contract risks (wrong ticker, bad cache, auth, migrations)
- Cross-surface paths (desktop + mobile + remote) if this repo has them

### 3. Validation tier (pick the strongest feasible)

| Tier | Use when | Examples |
|------|----------|----------|
| **Unit / focused tests** | Pure logic, parsers, registries | `pytest path/to/test_*.py`, `gradle test`, `vitest` |
| **Integration / script** | Multi-module paths with fixtures or local services | project `scripts/validate_*.py`, package test suites |
| **Smoke (headless)** | Need live-ish proof without full GUI | import wiring, dispatch callbacks, one real cached/IO path |
| **Manual-only** | Requires GUI click, device, or secrets you lack | list exact steps for the user; do not fake PASS |

Prefer project-native commands. Discover them from `package.json`, `pyproject.toml`,
`Makefile`, `scripts/`, CI configs — do not invent a parallel stack.

### 4. Execute

- Run the **smallest** suite that covers the acceptance criteria first.
- Then widen if risk is high (shared modules, security, data correctness).
- If no test exists for a new behavior, **add a focused regression test** (or a
  small `scripts/validate_*.py` smoke) before declaring success.
- On failure: fix the product code or the test (whichever is wrong), then re-run.
- Never dismiss a failing check as “probably fine.”

### 5. Honesty rules

- **Proven**: command/output you ran in this session supports the criterion
- **Untested**: not exercised (e.g. Tk/GUI click-through, physical device)
- **Blocked**: missing creds, device offline, network denied — say what blocked it

Do not imply GUI/E2E proof from unit tests alone.

## Report format (required)

End validation with:

```markdown
### Validation report
**Request:** <one-line restatement>

| Criterion | Result | Evidence |
|-----------|--------|----------|
| … | Proven / Failed / Untested / Blocked | test name, script, or why |

**Commands run:**
- `…`

**Gaps / manual follow-up:**
- …
```

If anything **Failed**, keep fixing or clearly stop with the failure — do not
move on to commit/push/“shipped” language unless the user overrides.

## Project hooks (optional)

If the repo has a validate script for this feature area, prefer it:

```bash
# examples — only if present
python3 scripts/validate_*.py
npm test -- <touched package>
pytest tests/test_<area>.py -q
```

## Anti-patterns

- Saying “fixed” after edit with no run
- Running the entire monorepo suite when 1–2 focused files suffice (unless CI-equivalent was requested)
- Treating compile/install success as behavioral proof
- Skipping regression tests for bugs you just fixed
