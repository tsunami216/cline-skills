# Execution Review

<!-- Description: Critically reviews the current implementation plan for gaps, risks, and mitigations, then validates plan steps against the repository source code. Always patches the same original plan file in place — never create a new plan file. Use when the user says "execution review", "execution ready", asks for a plan risk review, plan gap analysis, or pre-implementation plan validation. -->

## Role

You run an **execution review** on the current implementation plan before coding. Critically find gaps and risks, validate the plan against the real repository, then update **that same plan file in place**. Do not implement the plan unless the user explicitly asks after the review.

## When to use

Trigger when the user says any of:

- "execution review"
- "execution ready"
- plan risk review / gap analysis / pre-implementation plan validation

## 1. Locate the current plan

Find the plan in this order:

1. Plan attached to / discussed in this conversation (including a `.plan.md` path cited in chat)
2. Most recently modified plan under `.cursor/plans/` in the workspace
3. Most recently modified plan under `~/.cursor/plans/`

If multiple candidates exist, prefer the one matching the active conversation topic. If no plan is found, ask the user which plan to review and stop.

Read the full plan before analyzing. **Lock the plan file path** from this step — every write must target that exact file.

## 2. Gap and risk analysis

Analyze the plan for:

- **Gaps**: missing steps, unowned files, undefined interfaces, incomplete settings/UI/export paths, missing tests, packaging/deps, migration/rollback
- **Risks**: wrong abstractions, API/SDK mismatches, latency/cost, security (secrets in settings), breaking existing behavior, PyInstaller/frozen-app issues, concurrency/UI thread hazards
- **Assumptions**: anything the plan treats as true but does not verify
- **Scope creep / under-scope**: work implied by the goal but absent from todos, or todos that do not deliver the stated goal

For each material issue, give:

| Item | Severity | Why it matters | Mitigation options |
|------|----------|----------------|-------------------|
| … | blockers / high / medium / low | … | 1–3 concrete options |

Prefer mitigations that fit the existing codebase style and the plan’s stated defaults. Do not expand into a rewrite unless a blocker requires it.

## 3. Source-code validation

**If the workspace has relevant source code** (application/library code the plan would change or depend on):

1. Map each plan step / todo to concrete paths, types, and call sites
2. Verify cited files, functions, and settings fields exist and behave as the plan assumes
3. Flag plan claims that contradict the code (wrong API shapes, missing hooks, dead ends)
4. Flag code realities the plan ignores (extra call sites, dual paths, hard-coded types)
5. Summarize **validated**, **invalid / needs plan fix**, and **unverified** (needs runtime or external API)

Use search/read tools; do not guess file contents.

**If there is no relevant source code** (empty repo, docs-only, greenfield with nothing to inspect, or the plan is purely external/process):

- Skip source-code validation entirely
- State clearly: `Source validation: skipped (no relevant source code)`
- Still complete the gap/risk analysis

## 4. Write results back to the **same** plan file (required)

After the analysis, update the plan **in place**. Chat-only reviews are not enough.

### Hard rules (do not violate)

- **Edit only the locked path from step 1.** Same filename, same directory.
- **Never** create a *new* plan file / URI during an execution review (that orphans the original). Do not call CreatePlan or equivalent “new plan” actions.
- **Never** write a new `*.plan.md`, copy the plan elsewhere, or save under a different name/id.
- **Never** treat a rewritten chat draft as the plan — the on-disk original is the source of truth.
- Use in-place edit / overwrite of **that** exact file only.

### What to change in that file

1. **Fold accepted mitigations into the plan body and todos** — edit sections, add/adjust todos, and fix incorrect assumptions so *this* plan becomes the revised source of truth.
2. **Add or replace an `## Execution review` section** near the end (before or after Out of scope). This section is **mandatory and must be complete** — not a one-line summary. It must include all of:
   - Date of review
   - Verdict (`ready` / `ready with fixes` / `not ready`)
   - Safe to execute? (`yes` / `yes after edits` / `no`)
   - **`### Gaps and risks`** — the full severity table (Item | Severity | Why it matters | Chosen mitigation). Do not omit or collapse this into a single bullet.
   - **`### Source validation`** — validated / invalid / unverified (or `skipped` if no source). Do not omit this.
3. If a previous `## Execution review` exists, **replace it** (one current section only).
4. Preserve YAML frontmatter identity (`name`, and any plan id in the filename); update `todos` / `overview` when the review adds required work.
5. In chat, state the **exact path** that was edited and confirm no new plan file was created.

Folding mitigations into the plan body does **not** replace the Execution review table — both are required.

If the plan file is not writable, report that in chat, deliver the full review there, and do **not** create a substitute plan file.

## 5. Chat output format

Keep the chat response pointed. Structure:

```markdown
# Execution review: [plan title]

Updated plan (same file): [exact path from step 1]
(No new plan created.)

## Verdict
[ready / ready with fixes / not ready] — one or two sentences

## Gaps and risks
[table or bullets with severity + mitigations]

## Source validation
[skipped note OR validated / conflicts / missing coverage]

## Plan updates applied
[short list of what was written into the plan file]

## Safe to execute?
[yes / yes after edits / no] — what must change first
```

Do **not** start implementing the feature during an execution review. Wait for an explicit execute/implement request.
