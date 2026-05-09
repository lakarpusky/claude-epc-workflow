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

For attribution of the optional `karpathy-guidelines` companion skill, see [COMPANIONS.md](./COMPANIONS.md#karpathy-guidelines-skill).

## License

MIT for the core system. The companion skill retains the original MIT license of the upstream work.
