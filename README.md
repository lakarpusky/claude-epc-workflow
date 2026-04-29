# Claude EPC Workflow

Multi-agent system for frontend development in Claude Code. Specialized agents for JavaScript, React, testing, and Git — coordinated by an orchestrator command.

> **Update — April 2026.** Anthropic shipped two changes that broke this workflow's quality (adaptive reasoning + a lowered default effort), and added a new official mechanism that fixes it (`effort:` and `memory:` frontmatter on subagents). This release rewrites every file against the current docs. **See [What Changed and Why](#what-changed-and-why) for the full breakdown with citations.** A new [Recommended Companions](#recommended-companions) section documents the personal setup files (global CLAUDE.md, project template, karpathy-guidelines skill) that pair well with this system.

## What this is

Five markdown files you drop into `~/.claude/` that give Claude Code domain expertise:

| File | Type | Role |
|---|---|---|
| `commands/epc.md` | Slash command | Routes tasks to the right specialist; defines workflow modes |
| `agents/javascript-specialist.md` | Subagent | Algorithms, performance, memory, async patterns, bundle analysis |
| `agents/react-virtuoso.md` | Subagent | Components, renders, state, hooks, accessibility |
| `agents/test-sentinel.md` | Subagent | Jest, RTL, integration tests, coverage, flaky-test triage |
| `agents/git-wizard.md` | Subagent | Commits, conflicts, rebases, branch strategy, recovery |

Tested daily on Sonnet 4.6 / Pro. Should also work on Opus 4.6 / 4.7 with `effort` adjusted (see [Tuning](#tuning-by-model-and-tier)).

## Install

```bash
# Clone into your personal Claude config
git clone https://github.com/lakarpusky/claude-epc-workflow.git /tmp/claude-epc
mkdir -p ~/.claude/agents ~/.claude/commands
cp /tmp/claude-epc/agents/*.md ~/.claude/agents/
cp /tmp/claude-epc/commands/epc.md ~/.claude/commands/
```

```markdown
The above installs only the core system — orchestrator and agents. For optional companion files (global CLAUDE.md, project template, karpathy-guidelines skill), see [Recommended Companions](#recommended-companions) below.
```

Then in Claude Code:

```
/agents       # verify agents loaded
/effort high  # set session reasoning level (see Tuning section)
```

## Usage

```
/epc [mode] [task]
```

Modes (analytical depth, not token caps):

| Mode | Use when |
|---|---|
| `quick` | Pattern is obvious; instant fix |
| `standard` (default) | Unknown problem; explore → plan → code |
| `architect` | Structural decision; multiple files |
| `unbounded` | Deep architectural exploration; comprehensive analysis |
| `emergency` | Production down; revert first, investigate after |

Examples:

```
/epc quick fix the null check in UserCard
/epc standard add a filter to the product list
/epc architect redesign state management
/epc unbounded evaluate Redux vs Zustand for this codebase
/epc emergency revert last commit
```

You can also bypass `/epc` and call a specialist directly when the domain is obvious — saves an orchestration turn:

```
@git-wizard squash the last 5 commits
@react-virtuoso fix re-renders in Dashboard
@test-sentinel write integration tests for the cart flow
@javascript-specialist optimize this O(n²) loop
```

## How it works

```
You → /epc orchestrator → Specialist subagent → Code change
              ↓
       Routes by:
       - File extension (.jsx → react-virtuoso, .test.* → test-sentinel)
       - Domain keyword (commit/rebase → git-wizard, render/hook → react-virtuoso)
       - Profiler data (React Profiler → react-virtuoso, Chrome DevTools → js-specialist)
       - Explore agent for codebase reconnaissance before specialist routing
```

Each subagent runs in its own context window and returns a text summary. The orchestrator extracts what's relevant and restates it in plain English when chaining specialists. There is no automatic state-sharing between subagents — that's a [documented mechanic](https://code.claude.com/docs/en/sub-agents#manage-subagent-context), not a limitation of this workflow.

For persistent project knowledge, each agent has `memory: user` enabled — they accumulate codebase patterns and conventions in `~/.claude/agent-memory/<agent-name>/` across sessions.

## What changed and why

### The regression that prompted the rewrite

Two changes from Anthropic in early 2026 silently degraded the previous version of this workflow:

1. **Adaptive reasoning replaced fixed thinking budgets.** Sonnet 4.6 and Opus 4.6 now decide per-turn whether and how much to think. Per the [Effort docs](https://platform.claude.com/docs/en/build-with-claude/effort): *"At lower effort levels, Claude will still think on sufficiently difficult problems, but it will think less than it would at higher effort levels for the same problem."*

2. **The default effort level was lowered from `high` to `medium`** ([changelog discussion](https://github.com/anthropics/claude-code/issues/25669)). Combined with adaptive reasoning, this caused Claude to skip thinking entirely on turns it judged "easy" — sometimes [allocating zero reasoning tokens](https://github.com/anthropics/claude-code/issues/31536), which Anthropic's Boris Cherny publicly acknowledged.

The previous version of this workflow leaned heavily on terseness (`Token Budget: 100 tokens`, `BANNED PHRASES`, `ASSUME KNOWN (never explain)`). Under fixed thinking budgets these only affected output. Under adaptive reasoning, the model interprets *"be terse, skip explanations"* as *"think less"* — so all that terseness now suppresses reasoning quality, not just verbosity.

### What got fixed

Every change below is contracted against the current official docs.

#### 1. Added `effort: high` to every subagent

**Why:** [Subagent frontmatter `effort` field](https://code.claude.com/docs/en/sub-agents#supported-frontmatter-fields) overrides the session's effort level, restoring deep reasoning regardless of what the global default is. This is the single highest-leverage change.

**Doc:** [Model configuration → Adjust effort level](https://code.claude.com/docs/en/model-config#adjust-effort-level)

#### 2. Added `memory: user` to every subagent

**Why:** Replaces the previous custom XML `<analysis_context>` handoff schema. That schema was prompt-engineering convention only — subagents return text summaries to the parent, not structured state, per the [docs](https://code.claude.com/docs/en/sub-agents#manage-subagent-context). Memory provides actual persistence: each agent maintains a `MEMORY.md` file in `~/.claude/agent-memory/<name>/` and accumulates codebase knowledge across sessions.

**Doc:** [Enable persistent memory](https://code.claude.com/docs/en/sub-agents#enable-persistent-memory)

#### 3. Added `maxTurns` per agent (15–20)

**Why:** Hard stop on pathological loops. Values are well above typical task lengths (3–10 turns) so they only fire on genuine runaway, never on legitimate work. Quality-neutral as a circuit breaker.

**Doc:** [Frontmatter reference → maxTurns](https://code.claude.com/docs/en/sub-agents#supported-frontmatter-fields)

#### 4. Removed token-budget enforcement and reasoning-suppression instructions

**Removed:** `<reasoning_control>`, `<master_mode>`, "Token Budget: 100/300/600", "ASSUME KNOWN (never explain)", "Skip explanations unless confidence <7", "Anti-pattern: Long explanations before taking action".

**Kept:** Output format templates (AGENT/ACTION/RESULT/CONFIDENCE), measurement-over-adjective discipline, definitive language, structured handoff briefs.

**Why:** Per the [Effort docs](https://code.claude.com/docs/en/model-config#adaptive-reasoning-and-fixed-thinking-budgets), the model responds to natural-language guidance about thinking depth. Output-shaping rules ("use this format") are safe; reasoning-shaping rules ("don't explain", "skip analysis") suppress thinking under adaptive reasoning. The surgical edit preserves the senior-engineer terseness aesthetic without gagging the model.

#### 5. Replaced custom XML handoff with plain-English orchestration

**Why:** Subagents [run in isolated context windows](https://code.claude.com/docs/en/sub-agents) and return only a summary. The XML schema couldn't actually flow between them; the orchestrator (`/epc`) had to manually parse and re-paste it. Plain English is closer to what the mechanism actually does.

**Doc:** [Common patterns → Chain subagents](https://code.claude.com/docs/en/sub-agents#chain-subagents)

#### 6. Fixed invalid frontmatter values

- `tools: fd, rg, ast-grep, fzf, jq, yq, MultiEdit` → omitted (those CLI binaries aren't Claude Code tools; access them via `Bash`. Omitting `tools` inherits the full set per the [docs](https://code.claude.com/docs/en/sub-agents#available-tools).) `MultiEdit` is no longer a separate tool.
- `color: gold` / `color: white` → `yellow` (gold/white aren't accepted; valid set is `red, blue, green, yellow, purple, orange, pink, cyan` per the [docs](https://code.claude.com/docs/en/sub-agents#supported-frontmatter-fields)).
- Descriptions rewritten as delegation triggers ("Use proactively when...") instead of LinkedIn-style bios. The [routing mechanism](https://code.claude.com/docs/en/sub-agents#understand-automatic-delegation) uses the description to decide when to delegate, so action language matters.

#### 7. /epc converted to a proper slash command

**Why:** The previous file had agent-style frontmatter (`name:`, `tools:`) but was invoked as a slash command. This was a category mix-up — agents and commands have different frontmatter schemas. Now structured as a [legacy slash command](https://code.claude.com/docs/en/slash-commands) at `~/.claude/commands/epc.md` with the correct fields (`description`, `argument-hint`, `model`) and `$ARGUMENTS` interpolation.

#### 8. Added Explore agent reconnaissance to /epc

**Why:** The [built-in Explore agent](https://code.claude.com/docs/en/sub-agents#built-in-subagents) is read-only and runs on Haiku — designed exactly for "where is X / find usages of Y" work. Routing reconnaissance there before invoking specialists saves 1–2 specialist turns per task and keeps search noise out of the orchestrator's context. Explicit guardrails in /epc prevent misuse on analytical work (Haiku misses subtleties).

### Why no skills (yet)

Skills add real value for stable domain knowledge that doesn't fit in agent bodies — but only when used at the session level. Preloading skills into subagents via the [`skills:` frontmatter field](https://code.claude.com/docs/en/sub-agents#preload-skills-into-subagents) injects full content at every invocation, bypassing progressive disclosure. For Pro tier where messages-per-window is the binding constraint, that's a bad trade.

If you find yourself pasting the same playbook repeatedly, that's the signal to extract a skill — start at the session level with `paths:` scoping to limit when it activates. The Anthropic [Skills docs](https://code.claude.com/docs/en/skills) and the [Equipping agents with skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) post cover the design principles.

## Tuning by model and tier

The agent files target Sonnet 4.6 / Pro. To tune for other configurations:

| Setup | Adjustment |
|---|---|
| Sonnet 4.6 / Pro | Default. `effort: high` on agents. `/effort high` session-wide. |
| Opus 4.6 / Max | Same as default. `high` and `max` are the only meaningful levels on this model. |
| Opus 4.7 / Max | Optionally bump agents to `effort: xhigh` per [Opus 4.7 best practices](https://claudefa.st/blog/guide/development/opus-4-7-best-practices). |
| Quality still degraded | Set `export CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1` on Opus 4.6 / Sonnet 4.6 (not available on Opus 4.7, which always uses adaptive). [Doc](https://code.claude.com/docs/en/model-config#adaptive-reasoning-and-fixed-thinking-budgets). |
| Cost-sensitive | Drop `effort` on individual agents to `medium`. Skip /epc for one-domain tasks (call specialists directly). |

Slash commands cannot carry `effort` in frontmatter (skill/subagent-only field). Set the session level once with `/effort high` or persist in `~/.claude/settings.json`:

```json
{ "effortLevel": "high" }
```

## Performance triage

"Slow" is ambiguous. /epc asks before routing:

```
1. UI feels janky/stuttery     → react-virtuoso (rendering)
2. Operations take too long    → javascript-specialist (algorithms)
3. Page loads slowly           → javascript-specialist (bundle/network)
4. Memory grows over time      → javascript-specialist (leaks)
```

If you have profiler data, share it and routing skips the questionnaire:

- React Profiler → react-virtuoso
- Chrome DevTools Performance → javascript-specialist
- Heap snapshot → javascript-specialist
- Lighthouse / Web Vitals → javascript-specialist initially

## Confidence scoring

Every non-trivial decision gets 1–10 with risk factors when below 9:

- 8–10: proceeds autonomously
- 5–7: proceeds with stated assumptions
- Below 5: stops and asks

Automatic escalation triggers regardless of base score: ambiguous requirements, public API changes, auth/encryption/access-control involvement, performance trade-offs across metrics, large dependencies, irreversible operations.

## File structure

```
~/.claude/
├── agents/
│   ├── git-wizard.md
│   ├── javascript-specialist.md
│   ├── react-virtuoso.md
│   └── test-sentinel.md
└── commands/
    └── epc.md
```

## Scope

**Covered:** Frontend JS/TS, React, Jest/RTL, Git workflows.

**Not covered:** Backend (Node/Express beyond JS basics), Vue/Svelte/Angular, E2E (Playwright/Cypress), infrastructure/DevOps, mobile/native.

## What this is NOT

- Not a build system or installer
- Not magic — agents need real context (profiler data, file paths, requirements) to produce real value
- Not a replacement for understanding what Claude Code is doing — read the [official docs](https://code.claude.com/docs)
- Not a guarantee — Anthropic ships changes; expect to re-tune periodically

````markdown
## Recommended Companions

The files below are not part of the core system but pair well with it. They are independent: the agents + /epc work without them, and they work in any Claude Code setup without the agents.

```
~/.claude/
├── CLAUDE.md                                         ← personal defaults (~30 lines)
├── templates/
│   └── PROJECT-CLAUDE.md                             ← copy to projects, fill in
└── skills/
    └── karpathy-guidelines/                          ← on-demand coding behavior
        ├── SKILL.md
        └── EXAMPLES.md
```

| File | Purpose | Loads when |
|---|---|---|
| `CLAUDE.md` (global) | Personal defaults: direct-mode rules, debugging discipline, bash hygiene | Every session |
| `templates/PROJECT-CLAUDE.md` | Fillable template for per-project CLAUDE.md (tech stack, critical paths, conventions) | When you copy it to a project root |
| `skills/karpathy-guidelines/` | Four principles that prevent common LLM coding mistakes | On code-writing tasks (description match) |

### Global CLAUDE.md

A lean (~30 line) personal defaults file: direct-mode rules, debugging discipline, bash hygiene. Every line answers Anthropic's [official test](https://code.claude.com/docs/en/best-practices): *"Would removing this cause Claude to make mistakes?"*

The previous version of this file (in earlier iterations of this workflow) was 656 lines and duplicated content that now lives correctly in agent files. Per [Anthropic's guidance](https://code.claude.com/docs/en/best-practices): *"Bloated CLAUDE.md files cause Claude to ignore your actual instructions."* The official recommendation is under 200 lines.

### Project template

`templates/PROJECT-CLAUDE.md` is copied to each project's root and filled in. ~80% comments and prompts that guide what to include (tech stack, architecture, critical paths, file risk map) and explicit reminders to cut anything generic.

### karpathy-guidelines skill

A third-party skill that encodes four behavioral principles distilled from [Andrej Karpathy's observations on LLM coding pitfalls](https://x.com/karpathy/status/2015883857489522876) by [Forrest Chang](https://github.com/forrestchang) ([andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills), MIT licensed):

1. **Think Before Coding** — surface assumptions, present interpretations, push back when warranted
2. **Simplicity First** — minimum code that solves the problem, no speculative abstractions
3. **Surgical Changes** — touch only what the request requires, match existing style
4. **Goal-Driven Execution** — define verifiable success criteria, write tests that reproduce bugs first

**This is a derivative work** of Forrest Chang's upstream skill. Two adaptations:

- **Tightened skill description** for more reliable activation — explicit `MUST ACTIVATE` directive plus trigger verbs (implement, fix, refactor, build, etc.).
- **EXAMPLES.md ported to JavaScript/TypeScript and React** — the upstream uses Python. All examples were rewritten in JS/TS for stack alignment, plus 3 React-specific examples added (don't refactor unrelated hooks while memoizing, don't reach for Context unprompted, don't optimize without Profiler data).

The four principles themselves are unchanged from the upstream. Credit for the principles goes to Karpathy and Forrest Chang.

### Install

```bash
mkdir -p ~/.claude/templates ~/.claude/skills/karpathy-guidelines

# Global CLAUDE.md
cp /tmp/claude-epc/CLAUDE.md ~/.claude/CLAUDE.md

# Project template
cp /tmp/claude-epc/templates/PROJECT-CLAUDE.md ~/.claude/templates/

# karpathy-guidelines skill
cp /tmp/claude-epc/skills/karpathy-guidelines/* ~/.claude/skills/karpathy-guidelines/
```

For new projects, copy the template into the repo root and fill in what applies:

```bash
cd ~/code/my-project
cp ~/.claude/templates/PROJECT-CLAUDE.md ./CLAUDE.md
$EDITOR ./CLAUDE.md
```

### Why these aren't part of the core system

These files address different problems than the agents and /epc:

- **Agents + /epc** = domain expertise and multi-domain task orchestration
- **Global CLAUDE.md** = personal defaults across all Claude Code work
- **Project template** = per-project context (tech stack, conventions, gotchas)
- **karpathy-guidelines skill** = general-purpose behavioral nudges for code work

You can adopt any subset independently. The agents work without the companions; the companions work without the agents. Bundling them in this repo is a convenience, not a requirement.
````

## References

**Official Anthropic docs (primary sources):**

- [Create custom subagents](https://code.claude.com/docs/en/sub-agents) — frontmatter reference, scopes, memory, hooks, skills preloading
- [Model configuration](https://code.claude.com/docs/en/model-config) — effort levels, adaptive reasoning, model aliases, environment variables
- [Effort](https://platform.claude.com/docs/en/build-with-claude/effort) — adaptive reasoning details, per-model levels
- [Skills](https://code.claude.com/docs/en/skills) — progressive disclosure, frontmatter, subagent integration
- [Slash commands / commands reference](https://code.claude.com/docs/en/commands) — built-in commands and bundled skills
- [Equipping agents for the real world with Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) — Anthropic engineering blog on Skills design

**Community references on the regression:**

- GitHub: [Per-subagent effortLevel feature request](https://github.com/anthropics/claude-code/issues/31536)
- GitHub: [Effort/thinking config for Task tool subagents](https://github.com/anthropics/claude-code/issues/25669)
- GitHub: [Configurable reasoning effort level for subagents](https://github.com/anthropics/claude-code/issues/43083)
- [Claude Code effort levels explained](https://www.mindstudio.ai/blog/claude-code-effort-levels-explained) — practical breakdown of low/medium/high/max
- [Claude Opus 4.7 best practices](https://claudefa.st/blog/guide/development/opus-4-7-best-practices) — `xhigh` defaults, adaptive thinking on 4.7

**Background reading:**

- [Claude Code Subagents complete guide](https://medium.com/@sathishkraju/claude-code-subagents-the-complete-guide-to-ai-agent-delegation-d0a9aba419d0)
- [Mental model for Claude Code: Skills, Subagents, Plugins](https://levelup.gitconnected.com/a-mental-model-for-claude-code-skills-subagents-and-plugins-3dea9924bf05)


```markdown
## License

MIT for the core system (agents and /epc orchestrator), all original work.

The optional `karpathy-guidelines` companion skill is a derivative of [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) (MIT); modifications retain the same license. See [Recommended Companions](#recommended-companions) for attribution details.
```

---

If you find this workflow useful, the highest-leverage thing you can do is verify each change against the docs above and adapt it to your stack. The configuration values here are tuned for Sonnet 4.6 + Pro and a frontend/JS workload. Other setups will want different `effort` and `maxTurns` values.

Issues and PRs welcome.
