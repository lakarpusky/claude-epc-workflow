---
name: karpathy-guidelines
description: MUST ACTIVATE for any task involving writing, modifying, refactoring, debugging, or reviewing code. Triggers on requests like "implement", "add", "fix", "refactor", "write", "create", "build", "change", or any code change. Encodes four principles that prevent common LLM coding mistakes: surface assumptions explicitly before coding, write minimum code (no speculative abstractions), make surgical changes (don't touch unrelated code), define verifiable success criteria. Skip only for pure conversation, explanations of existing code, or trivial one-line edits.
license: MIT
---

# Karpathy Guidelines

Four principles derived from [Andrej Karpathy's observations on LLM coding pitfalls](https://x.com/karpathy/status/2015883857489522876). Original collation by Forrest Chang ([andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills)).

For pairwise good vs. bad code examples that illustrate each principle, see `EXAMPLES.md` in this skill directory. Consult it when you're about to produce a non-trivial diff and want to check your output against known anti-patterns.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Self-test: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**Tradeoff:** these guidelines bias toward caution over speed. For trivial tasks (one-line edits, obvious typos), use judgment.

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
