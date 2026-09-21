---
name: execution-review
description: >-
  Critically reviews the current implementation plan for gaps, risks, and
  mitigations, then validates plan steps against the repository source code.
  Always patches the same original plan file in place — never CreatePlan or a
  new plan file. Use when the user says "execution review", asks for a plan
  risk review, plan gap analysis, or pre-implementation plan validation.
---

# Execution Review

When the user says **execution review** (or equivalent), review the **current plan** before implementation. Do not implement the plan unless the user explicitly asks after the review.

## 1. Locate the current plan

Find the plan in this order:

1. Plan attached to / discussed in this conversation (including CreatePlan output or a `.plan.md` path cited in chat)
2. Most recently modified plan under `.cursor/plans/` in the workspace
3. Most recently modified plan under `~/.cursor/plans/`

If multiple candidates exist, prefer the one matching the active conversation topic. If no plan is found, ask the user which plan to review and stop.

Read the full plan before analyzing. **Lock the plan file path** from this step — every write must target that exact file.

## 1.5 Check for API involvement (if applicable)

**Before gap/risk analysis, determine if the plan involves any API integration:**

- Third-party APIs (Cursor Cloud Agents, Ollama, weather, payments, etc.)
- MCP server tools or resources
- HTTP clients making network requests
- Endpoints for create/read/update/delete

**If ANY API is involved, apply the API Verification Protocol** (`api-verification` rule / `.cursor/rules/api-verification.md`):

1. Verify endpoints against existing repo HTTP client code
2. Check tests that cover API behavior
3. Cross-reference official docs before claiming endpoint behavior
4. Mark unverified endpoints with `[UNVERIFIED]` and `⚠️`
5. Document verification status in the execution review section

**Failure to verify APIs is a blocker risk.**

## 2. Gap and risk analysis

Analyze the plan for:

- **Gaps**: missing steps, unowned files, undefined interfaces, incomplete settings/UI/export paths, missing tests, packaging/deps, migration/rollback
- **Risks**: wrong abstractions, API/SDK mismatches (see 1.5), latency/cost, security (secrets/API keys), breaking existing behavior, PyInstaller/frozen-app issues, concurrency/UI thread hazards
- **Assumptions**: anything the plan treats as true but does not verify
- **Scope creep / under-scope**: work implied by the goal but absent from todos, or todos that do not deliver the stated goal

For each material issue, give:

| Item | Severity | Why it matters | Mitigation options |
|------|----------|----------------|--------------------|
| … | blockers / high / medium / low | … | 1–3 concrete options |

Prefer mitigations that fit the existing codebase style and the plan’s stated defaults. Do not expand into a rewrite unless a blocker requires it.

## 3. API Verification Status (if applicable)

If step 1.5 identified API involvement, document:

| API/Endpoint | Verification Status | Source of Truth | Notes |
|-------------|---------------------|-----------------|-------|
| … | ✅ Verified / ❌ Unverified / ⚠️ Partial | code path, docs URL, or test | … |

If none: `API verification: not applicable (no external APIs in this plan)`

## 4. Source-code validation

**If the workspace has relevant source code** (application/library code the plan would change or depend on):

1. Map each plan step / todo to concrete paths, types, and call sites
2. Verify cited files, functions, and settings fields exist and behave as the plan assumes
3. Flag plan claims that contradict the code (wrong API shapes, missing hooks, dead ends)
4. Flag code realities the plan ignores (extra call sites, dual paths, hard-coded types)
5. Summarize **validated**, **invalid / needs plan fix**, and **unverified** (needs runtime or external API)

Use search/read tools; do not guess file contents.

**If there is no relevant source code**:

- Skip source-code validation entirely
- State clearly: `Source validation: skipped (no relevant source code)`
- Still complete the gap/risk analysis

## 5. Write results back to the **same** plan file (required)

After the analysis, update the plan **in place**. Chat-only reviews are not enough.

### Hard rules (do not violate)

- **Edit only the locked path from step 1.** Same filename, same directory.
- **Never** call `CreatePlan` during an execution review (that creates a *new* plan URI and orphans the original).
- **Never** write a new `*.plan.md`, copy the plan elsewhere, or save under a different name/id.
- **Never** treat a rewritten chat draft as the plan — the on-disk original is the source of truth.
- Use `StrReplace` / in-place `Write` to that exact path only.

### What to change in that file

1. **Fold accepted mitigations into the plan body and todos**
2. **Add or replace an `## Execution review` section** near the end. Mandatory contents:
   - Date of review
   - Verdict (`ready` / `ready with fixes` / `not ready`)
   - Safe to execute? (`yes` / `yes after edits` / `no`)
   - **`### Gaps and risks`** — full severity table
   - **`### API Verification Status`** — when APIs are involved
   - **`### Source validation`** — validated / invalid / unverified / skipped
3. If a previous `## Execution review` exists, **replace it**
4. Preserve YAML frontmatter identity; update `todos` / `overview` when required
5. In chat, state the **exact path** edited and confirm no new plan file was created

## 6. Sync Memory Bank (required)

After updating the plan file, synchronize the project's **Memory Bank**:

1. If `memory-bank/` is missing, initialize the six core files from the codebase + plan
2. If present, update at least `activeContext.md` and `progress.md`; refresh other files when architecture/deps change

## 7. Chat output format

```markdown
# Execution review: [plan title]

Updated plan (same file): [exact path from step 1]
(No new plan created.)

## Verdict
[ready / ready with fixes / not ready]

## Gaps and risks
[table]

## API Verification Status
[table or not applicable]

## Source validation
[skipped OR validated / conflicts / missing coverage]

## Plan updates applied
[short list]

## Safe to execute?
[yes / yes after edits / no]
```

Do **not** start implementing during an execution review. Wait for an explicit execute/implement request.
