---
name: plan
description: >-
  Create an adversarial implementation plan using dual agents (Architect + Auditor).
  Starts with a codebase research phase (reads lib/ and test/), then
  the Architect proposes a plan while the Auditor challenges every decision against
  Flutter architecture rules, BLoC patterns, and FACTS criteria. Produces a validated
  atomic task checklist saved to ai/plans/. Use after /research, before any implementation
  commands. Trigger when the user wants to plan a feature, needs a task breakdown,
  wants an implementation roadmap, or asks "how should I implement X", "plan X",
  "break down X into tasks", "what steps for X". Does NOT write any implementation code.
user-invocable: true
argument-hint: "[TaskDescription]"
model: sonnet
---

# Senior Engineer — Plan Mode

**Task:** $ARGUMENTS

## Context
- Branch: !`git branch --show-current`
- Ticket: !`git branch --show-current | grep -oE 'LAS-[0-9]+' | head -1`
- Date: !`date +%Y-%m-%d`
- Recent commits: !`git log --oneline -3`
- Research doc: !`ls ai/research/ 2>/dev/null | grep -i "$ARGUMENTS" | head -3 || echo "none found"`
- Existing features: !`ls lib/ 2>/dev/null | head -20 || echo "none found"`

---

## Initial Check

If `$ARGUMENTS` is empty or unclear:
> "What would you like to plan? Describe the feature or task in a sentence or two."

Do not proceed until the task is clear.

---

## Phase 0 — Codebase Research

Before creating any plan, spawn a research agent to understand the current state:

```
You are a Staff Engineer researching the codebase before planning: "$ARGUMENTS"

Read these files to understand the context:
- /ai/context.md
- /ai/docs/flutter-architecture-rules.md
- /ai/docs/bloc-patterns.md
- /ai/docs/testing_guidelines.md

Then explore the actual codebase:
- List and read relevant files in lib/
- Check existing pages in lib/
- Check for any existing patterns in main.dart
- Look for any existing tests in test/

Answer:
1. What files are directly affected?
2. What existing patterns can be reused (don't reinvent)?
3. What are the constraints (existing state shape, API contracts)?
4. Are there any architecture violations or risks in the current code we should avoid replicating?

Output format:

## Affected Files
[list with brief description of each]

## Reusable Patterns Found
[list with file paths and what to reuse]

## Constraints
[list]

## Risks / Anti-patterns to Avoid
[list]
```

Wait for research output before proceeding to Phase 1.

---

## Change Size Assessment

After research, determine change size:

**BIG change indicators:**
- Multiple files/components affected (>5)
- New architectural patterns introduced
- Cross-cutting concerns (auth, security, performance)
- Breaking changes to existing APIs
- Complex state management changes

**SMALL change indicators:**
- Single component or utility function
- Bug fix with clear scope
- UI text or styling updates
- Adding a single API endpoint

For **SMALL changes**: agents run the same dual-agent process but with shorter output (3–5 sentences per section, 1–2 key decisions).

---

## Engineering Principles

Apply these to ALL tasks — both agents must check against them:

1. **DRY** — Aggressively flag duplication (even small repetitions)
2. **Testing** — Well-tested code is mandatory (better too many tests than too few)
3. **Engineered Code** — Not fragile or hacky, but not over-engineered
4. **Correctness > Speed** — Optimize for correctness and edge cases first
5. **Explicit > Clever** — Prefer explicit solutions over clever one-liners

---

## Phase 1 — Launch Both Agents in Parallel

Spawn both agents **simultaneously** in a single message using the Agent tool, providing the research findings as context:

---

### Agent 1 — Architect (Proposer)

```
You are a Staff Engineer creating an implementation plan for:
"$ARGUMENTS"

Context from codebase research:
[paste Phase 0 research findings here]

Read these docs before proposing anything:
- /ai/context.md
- /ai/docs/flutter-architecture-rules.md
- /ai/docs/bloc-patterns.md
- /ai/docs/testing_guidelines.md

Engineering principles to apply to ALL decisions:
1. DRY — flag any duplication, even small ones
2. Testing is mandatory — plan tests for every public API
3. Correctness > Speed — optimize for correctness and edge cases
4. Explicit > Clever — no clever one-liners

For each architectural decision output:
1. What you propose
2. Why (concrete reasoning, not generic)
3. Which files are affected
4. What could go wrong

Output format:

## Architectural Decisions
[Each: Proposal → Rationale → Files → Risk]

## Atomic Task Plan
- [ ] Phase 1: [Name]
  - [ ] Task 1.1: [Single action] — `path/to/file.ts`
  - [ ] Task 1.2: [Single action] — `path/to/file.ts`
- [ ] Phase 2: [Name]
  - [ ] Task 2.1: [Single action] — `path/to/file.ts`
- [ ] Phase 3: Tests
  - [ ] Task 3.1: Unit tests — `tests/unit/...`

## Success Criteria
### Automated
- [ ] [test/lint/type-check condition that can be run in CI]
### Manual
- [ ] [observable user behavior or UI state]

## What We Are NOT Doing
[Explicit scope boundary — what was considered but excluded, and why]

## Key Risks
[Top 3 risks with mitigations]
```

---

### Agent 2 — Auditor (Challenger)

```
You are a skeptical Senior Engineer auditing an implementation plan for:
"$ARGUMENTS"

Read these to validate against:
- /ai/context.md
- /ai/docs/flutter-architecture-rules.md
- /ai/docs/bloc-patterns.md
- /ai/docs/testing_guidelines.md

For EACH architectural decision you find or infer, evaluate:
1. Does it violate Flutter architecture rules? (feature-first, layer order)
2. Does it introduce unnecessary complexity?
3. Is it consistent with existing patterns (found in Phase 0 research)?
4. Are there simpler alternatives?
5. Does it violate DRY or introduce duplication?
6. Does it follow FACTS? (Feasible, Atomic, Clear, Testable, Scoped)

Verdict per decision:
- ✅ CONFIRM — sound, documentation supports it
- ❌ REJECT — violates project conventions (cite the doc source)
- ⚠️ MODIFY — right direction, needs adjustment (provide concrete alternative)

Output format:

## Audit Findings
### Decision: [Name]
**Verdict:** ✅/❌/⚠️
**Reasoning:** [cite /ai/docs/* if relevant]
**Alternative (if ⚠️ or ❌):** [concrete alternative]

## Missing Considerations
[What the Architect didn't consider that they should have]

## FACTS Validation
- [ ] Feasible: [assessment]
- [ ] Atomic: [assessment]
- [ ] Clear: [assessment]
- [ ] Testable: [assessment]
- [ ] Scoped: [assessment]
```

---

## Phase 2 — Synthesize Results

| Status | Rule |
|--------|------|
| ✅ Confirmed (both agree) | Include as-is |
| ❌ Rejected (Auditor with doc evidence) | Exclude — note why with doc reference |
| ⚠️ Modified (Auditor proposes change) | Use Auditor's version with explanation |
| 🔄 Disputed (no clear winner) | Present both views — ask user to decide |

**No open questions policy**: All ambiguities must be resolved before presenting the plan. If something is unclear, ask the user now — not during implementation.

---

## For Each Issue Found

```markdown
### Issue: [Short Description]

**Problem:** [Clear description of what's wrong]

**Why it matters:** [Impact on the system — maintenance, performance, bugs]

**Options:**

| Option | Effort | Risk | Impact | Maintenance |
|--------|--------|------|--------|-------------|
| Option 1: [Description] | S/M/L | Low/Med/High | Low/Med/High | Low/Med/High |
| Option 2: [Description] | S/M/L | Low/Med/High | Low/Med/High | Low/Med/High |
| Do nothing | — | — | — | — |

**Recommendation:** [Opinionated choice]

**Why:** [Reasoning — tradeoffs]
```

---

## Phase 3 — Present Final Plan

```markdown
## Final Implementation Plan — [Task Name]

### Synthesis Summary
[Brief: what was confirmed / modified / rejected]

### Atomic Task Plan (Validated)
- [ ] Phase 1: [Name]
  - [ ] Task 1.1: [action] — `path/to/file.ts`
  - [ ] Task 1.2: [action] — `path/to/file.ts`
- [ ] Phase 2: [Name]
  - [ ] Task 2.1: [action] — `path/to/file.ts`
- [ ] Phase 3: Tests
  - [ ] Task 3.1: Unit tests — `tests/unit/...`

### Success Criteria
#### Automated
- [ ] `flutter analyze` passes with no new errors
- [ ] `flutter test` passes
- Unit tests pass with coverage for all new BLoC/Cubit public APIs

#### Manual
- [ ] [User-visible behavior works correctly]
- [ ] [Edge cases handled as expected]

### What We Are NOT Doing
- [Explicitly excluded item] — [reason it was excluded]

### Disputed Items (Need User Decision)
[Present both sides clearly — do not proceed until resolved]
```

**Do not start implementation until the user approves the plan.**

---

## Phase 4 — Save Plan to File

After user approves the plan, save it:

```
mkdir -p ai/plans
```

File path: `ai/plans/[YYYY-MM-DD]-[task-slug].md`
Example: `ai/plans/2026-04-24-add-scanner-history.md`

Write the full approved plan to that file.

---

## Phase 5 — Review & Iterate

After saving, ask:
> "Does this plan look correct? Any adjustments before we start implementation?"

If the user requests changes — update the plan, re-save the file, and ask again.

---

## After Approval

Suggest the appropriate implementation skill:

- `/scanner` — Scanner feature
- `/bloc [Feature]` — BLoC pattern
- `/cubit [Feature]` — Cubit pattern
- `/widget [Component]` — Flutter widget
- `/test [Name]` — Tests

⚠️ Load the approved plan in a **fresh context** before implementing.
