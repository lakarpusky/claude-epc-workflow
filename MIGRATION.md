# Migration — April 2026

This release rewrites every file in this repo against the current Claude Code documentation. The previous version of the workflow was tuned for fixed thinking budgets; Anthropic has since shipped adaptive reasoning, which silently degraded the quality of the old configuration.

This document explains what changed, why, and links each change to the official doc that justifies it.

## The regression

Two changes from Anthropic in early 2026 broke the previous version:

1. **Adaptive reasoning replaced fixed thinking budgets.** Sonnet 4.6 and Opus 4.6 now decide per-turn whether and how much to think. Per the [Effort docs](https://platform.claude.com/docs/en/build-with-claude/effort): *"At lower effort levels, Claude will still think on sufficiently difficult problems, but it will think less than it would at higher effort levels for the same problem."*

2. **The default effort level was lowered from `high` to `medium`** ([changelog discussion](https://github.com/anthropics/claude-code/issues/25669)). Combined with adaptive reasoning, this caused Claude to skip thinking entirely on turns it judged "easy" — sometimes [allocating zero reasoning tokens](https://github.com/anthropics/claude-code/issues/31536), which Anthropic's Boris Cherny publicly acknowledged.

The previous version of this workflow leaned on terseness instructions (`Token Budget: 100 tokens`, `BANNED PHRASES`, `ASSUME KNOWN (never explain)`). Under fixed thinking budgets these only affected output. Under adaptive reasoning, the model interprets *"be terse, skip explanations"* as *"think less"* — so all that terseness now suppresses reasoning quality, not just verbosity.

## Per-file changes

Every change below is contracted against the current official docs.

### 1. Added `effort: high` to every subagent

[Subagent frontmatter `effort` field](https://code.claude.com/docs/en/sub-agents#supported-frontmatter-fields) overrides the session's effort level, restoring deep reasoning regardless of what the global default is. This is the single highest-leverage change.

**Doc:** [Model configuration → Adjust effort level](https://code.claude.com/docs/en/model-config#adjust-effort-level)

### 2. Added `memory: user` to every subagent

Replaces the previous custom XML `<analysis_context>` handoff schema. That schema was prompt-engineering convention only — subagents return text summaries to the parent, not structured state. Memory provides actual persistence: each agent maintains a `MEMORY.md` file in `~/.claude/agent-memory/<name>/` and accumulates codebase knowledge across sessions.

**Doc:** [Enable persistent memory](https://code.claude.com/docs/en/sub-agents#enable-persistent-memory)

### 3. Added `maxTurns` per agent (15–20)

Hard stop on pathological loops. Values are well above typical task lengths (3–10 turns), so they only fire on genuine runaway, never on legitimate work. Quality-neutral as a circuit breaker.

### 4. Removed token-budget enforcement and reasoning-suppression instructions

**Removed:** `<reasoning_control>`, `<master_mode>`, "Token Budget: 100/300/600", "ASSUME KNOWN (never explain)", "Skip explanations unless confidence <7", "Anti-pattern: Long explanations before taking action".

**Kept:** Output format templates, measurement-over-adjective discipline, definitive language, structured handoff briefs.

The model responds to natural-language guidance about thinking depth. Output-shaping rules ("use this format") are safe; reasoning-shaping rules ("don't explain", "skip analysis") suppress thinking under adaptive reasoning.

### 5. Replaced custom XML handoff with plain-English orchestration

Subagents run in isolated context windows and return only a summary. The XML schema couldn't actually flow between them; the orchestrator (`/epc`) had to manually parse and re-paste it. Plain English is closer to what the mechanism actually does.

### 6. Fixed invalid frontmatter values

- `tools: fd, rg, ast-grep, fzf, jq, yq, MultiEdit` → omitted. Those CLI binaries aren't Claude Code tools; access them via `Bash`. `MultiEdit` is no longer a separate tool.
- `color: gold` / `color: white` → `yellow`. The valid set is `red, blue, green, yellow, purple, orange, pink, cyan`.
- Descriptions rewritten as delegation triggers ("Use proactively when...") instead of LinkedIn-style bios.

### 7. /epc converted to a proper slash command

The previous file had agent-style frontmatter but was invoked as a slash command. Now structured as a [legacy slash command](https://code.claude.com/docs/en/slash-commands) at `~/.claude/commands/epc.md` with correct fields and `$ARGUMENTS` interpolation.

### 8. Added Explore agent reconnaissance to /epc

The [built-in Explore agent](https://code.claude.com/docs/en/sub-agents#built-in-subagents) is read-only and runs on Haiku — designed for "where is X / find usages of Y" work. Routing reconnaissance there before invoking specialists saves 1–2 specialist turns per task.

## References

**Official Anthropic docs:**

- [Create custom subagents](https://code.claude.com/docs/en/sub-agents)
- [Model configuration](https://code.claude.com/docs/en/model-config)
- [Effort](https://platform.claude.com/docs/en/build-with-claude/effort)
- [Skills](https://code.claude.com/docs/en/skills)
- [Slash commands](https://code.claude.com/docs/en/commands)
- [Best practices for Claude Code](https://code.claude.com/docs/en/best-practices)

**Community references on the regression:**

- GitHub: [Per-subagent effortLevel feature request](https://github.com/anthropics/claude-code/issues/31536)
- GitHub: [Effort/thinking config for Task tool subagents](https://github.com/anthropics/claude-code/issues/25669)
- [Claude Code effort levels explained](https://www.mindstudio.ai/blog/claude-code-effort-levels-explained)
- [Claude Opus 4.7 best practices](https://claudefa.st/blog/guide/development/opus-4-7-best-practices)
- [Writing a good CLAUDE.md (HumanLayer)](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
