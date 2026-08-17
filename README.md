# Claude EPC Workflow

Multi-agent system for frontend development in Claude Code. Specialized agents for JavaScript, React, testing, and Git — coordinated by an orchestrator command.

Tested daily on Claude Code Pro (Opus 5 session, Sonnet 5 specialists).

## Install

```bash
git clone https://github.com/lakarpusky/claude-epc-workflow.git /tmp/claude-epc
mkdir -p ~/.claude/agents ~/.claude/commands ~/.claude/hooks
cp /tmp/claude-epc/agents/*.md ~/.claude/agents/
cp /tmp/claude-epc/commands/epc.md ~/.claude/commands/
cp /tmp/claude-epc/hooks/verify-frontend.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/verify-frontend.sh
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

Each runs in its own context window with `effort: high` and persistent memory: `memory: local` for the three specialists (per-project, kept out of version control), `memory: user` for `git-wizard` (portable git conventions). The two implementation agents (`javascript-specialist`, `react-virtuoso`) also run a `SubagentStop` gate that blocks their output on `tsc --noEmit` / `eslint` failure. All four specialists are pinned to `model: sonnet` (Sonnet 5) and a bundled `Explore` override keeps reconnaissance on Sonnet too, while the orchestrator runs on your session model — so a full fan-out doesn't drain your Opus 5 headroom on Pro's shared pool. Agents return text summaries to the orchestrator, which restates relevant findings in plain English when chaining specialists.

## Tuning by model

| Setup | Adjustment |
|---|---|
| Sonnet 5 / Pro | Default. Specialists pinned `model: sonnet`, `effort: high`. |
| Opus 5 session / Pro | Keep specialists on Sonnet 5 — Opus and Sonnet share one Pro pool, so an Opus fan-out drains your interactive headroom. Escalate a single specialist to `model: opus` + `effort: xhigh` only for hard architecture. |
| Max | Sonnet and Opus draw from separate pools; running specialists on Opus 5 is affordable there. |
| Cost / limit-sensitive | Drop mechanical agents to `effort: medium`; skip `/epc` for one-domain tasks. |
| Legacy 4.6 models | `export CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1` restores fixed thinking — 4.6 / Opus 4.6 only; no effect on Sonnet 5 or Opus 4.7+. |

Slash commands can't carry `effort` in frontmatter. Set the session level once with `/effort high` or persist in `~/.claude/settings.json`:

```json
{ "effortLevel": "high" }
```

## What changed in August 2026

Synced against the current Claude Code docs. Specialist memory is now scoped per project (`memory: user` → `local`) to keep codebase notes out of version control; a `SubagentStop` verification gate (`tsc --noEmit` + `eslint`) was added to `javascript-specialist` and `react-virtuoso` so broken code never folds back into the orchestrator; the stale note that the built-in Explore agent runs on Haiku was corrected (it inherits the session model as of v2.1.198); `/epc` was locked to manual invocation with `disable-model-invocation: true`; and all four specialists were pinned to Sonnet 5 (with a Sonnet-pinned `Explore` override) so a multi-agent fan-out doesn't drain the shared Opus/Sonnet usage pool on Pro.

Full rationale, citations, and per-file changes in [MIGRATION.md](./MIGRATION.md).

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
