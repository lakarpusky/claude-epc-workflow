---
name: code-comments
description: Enforces minimal, high-signal code comments in any language. This skill should be used whenever writing new code or editing existing code, and before adding or leaving any comment or docstring. It keeps comments to the why (not the what), documents public APIs and non-obvious rationale or constraints, and removes restatements, commented-out code, and comments that would go stale. Applies to TypeScript, JavaScript, Swift, Lua, and any other language.
---

# Code comment discipline

Apply whenever you write or edit code, in any language. The goal: minimal, high-signal comments — real documentation where it earns its place, and nothing that restates the code or will rot.

## Core principle

Comment the **why**, never the **what**. The code already shows what it does; a comment earns its place only by saying something the code cannot — intent, reason, constraint, or a warning. If a comment merely restates the code, don't write it (or delete it).

## Comment these — when the case applies

- **Rationale** for a non-obvious choice or tradeoff (e.g. "Map index over `.find` — O(n) on large inputs").
- **Workarounds / hacks**: what, why, and a ticket or issue link. Tag `HACK:` or `WORKAROUND:`.
- **Non-obvious constraints and invariants** the caller or next editor must honor (threading/isolation, ordering, preconditions).
- **Public / exported API**: a one-line doc comment on intent; document params, returns, and errors only where the signature doesn't already make them clear.
- **Magic values**: the meaning or source of a constant that isn't self-evident.
- **Edge cases and gotchas** a reader would otherwise trip over.
- **`TODO:` / `FIXME:`** with enough context (ideally a ticket) to act on — never a bare marker.

## Never write these — remove on sight

- Restatements of the code (`// increment counter`, `// set the name`).
- Commented-out code — delete it; version control is the history.
- Type or parameter info the language's types already carry.
- Decorative banners, dividers, or ASCII art.
- Author / date / changelog lines — that's what version history is for.
- Doc comments on trivial internal helpers whose name already says it.

## Format & hygiene

- Terse: one line where one line does; reserve paragraphs for genuinely complex logic.
- Place comments above the code they describe; short clarifiers may trail.
- Use standard tags only, consistently: `TODO`, `FIXME`, `NOTE`, `HACK`, `WARNING`.
- A comment that will go stale is a liability — keep it in sync with the code, or delete it. A wrong comment is worse than none.
- Follow the language's doc convention only where it adds value: doc comments on public/exported API, not on every internal function; never duplicate type information the language already expresses.

## Two-question test

- Before **writing** a comment: does this say something the code cannot? If no, don't write it.
- Before **leaving** a comment: will it still be true after a plausible edit? If it will rot, make it robust or drop it.
