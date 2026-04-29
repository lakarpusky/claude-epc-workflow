# Claude EPC Workflow

Multi-agent system for frontend development in Claude Code. Specialized agents for JavaScript, React, testing, and Git — coordinated by an orchestrator command.

Tested daily on Sonnet 4.6 / Pro.

## Install

```bash
git clone https://github.com/lakarpusky/claude-epc-workflow.git /tmp/claude-epc
mkdir -p ~/.claude/agents ~/.claude/commands
cp /tmp/claude-epc/agents/*.md ~/.claude/agents/
cp /tmp/claude-epc/commands/epc.md ~/.claude/commands/
```

Then in Claude Code:

```
/agents       # verify agents loaded
/effort high  # set session reasoning level
```

For the optional personal-setup files (global CLAUDE.md, project template, karpathy-guidelines skill), see [COMPANIONS.md](./COMPANIONS.md).

## Usage

```
/epc [mode] [task]
```

Modes are analytical depth, not token caps:

| Mode | Use when |
|---|---|
| `quick` | Pattern is obvious; instant fix |
| `standard` (default) | Unknown problem; explore → plan → code |
| `architect` | Structural decision; multiple files |
| `unbounded` | Deep architectural exploration |
| `emergency` | Production down; revert first, investigate after |

Examples:

```
/epc quick fix the null check in UserCard
/epc standard add a filter to the product list
/epc architect redesign state management
/epc emergency revert last commit
```

When the domain is obvious, skip `/epc` and call a specialist directly to save an orchestration turn:

```
@git-wizard squash the last 5 commits
@react-virtuoso fix re-renders in Dashboard
@test-sentinel write integration tests for the cart flow
@javascript-specialist optimize this O(n²) loop
```

## Agents

| Agent | Domain |
|---|---|
| `git-wizard` | Commits, conflicts, rebases, branch strategy, recovery |
| `javascript-specialist` | Algorithms, performance, memory, async, bundle analysis |
| `react-virtuoso` | Components, renders, state, hooks, accessibility |
| `test-sentinel` | Jest, RTL, integration tests, coverage, flaky-test triage |

Each runs in its own context window with `effort: high` and persistent `memory: user`. Agents return text summaries to the orchestrator, which restates relevant findings in plain English when chaining specialists.

## Tuning by model

| Setup | Adjustment |
|---|---|
| Sonnet 4.6 / Pro | Default. `effort: high` on agents. `/effort high` session-wide. |
| Opus 4.6 / Max | Same as default — `high` and `max` are the meaningful levels. |
| Opus 4.7 / Max | Optionally bump agents to `effort: xhigh`. |
| Quality still degraded | `export CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1` (Opus 4.6 / Sonnet 4.6 only). |
| Cost-sensitive | Drop agents to `effort: medium`. Skip `/epc` for one-domain tasks. |

Slash commands can't carry `effort` in frontmatter. Set the session level once with `/effort high` or persist in `~/.claude/settings.json`:

```json
{ "effortLevel": "high" }
```

## What changed in April 2026

Adaptive reasoning + a lowered default effort silently degraded the previous version's quality. Fixed by adding `effort: high` and `memory: user` frontmatter to every subagent, removing token-budget instructions that suppressed thinking under the new model behavior, and restructuring `/epc` as a proper slash command.

Full rationale, citations, and per-file changes in [MIGRATION.md](./MIGRATION.md).

## Scope

**Covered:** Frontend JS/TS, React, Jest/RTL, Git workflows.

**Not covered:** Backend (beyond JS basics), Vue/Svelte/Angular, E2E (Playwright/Cypress), infrastructure/DevOps, mobile/native.

## Credits

Agents and `/epc` orchestrator are original to this repo.

## Recommended Companions

The optional `karpathy-guidelines` companion skill is derived from [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) (MIT), which distills four principles from [Andrej Karpathy's tweet](https://x.com/karpathy/status/2015883857489522876) on LLM coding pitfalls. See [COMPANIONS.md](./COMPANIONS.md) for attribution details.

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

## License

MIT for the core system (agents and /epc orchestrator), all original work.

The optional `karpathy-guidelines` companion skill is a derivative of [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) (MIT); modifications retain the same license. See [Recommended Companions](#recommended-companions) for attribution details.

---

If you find this workflow useful, the highest-leverage thing you can do is verify each change against the docs above and adapt it to your stack. The configuration values here are tuned for Sonnet 4.6 + Pro and a frontend/JS workload. Other setups will want different `effort` and `maxTurns` values.

Issues and PRs welcome.
