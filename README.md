# Claude EPC Workflow

Multi-agent system for frontend development in Claude Code. Specialized agents for JavaScript, React, unit/integration testing, Playwright E2E, Progressive Web Apps, and Git — coordinated by an orchestrator command.

Tested daily on Claude Code Pro — Sonnet 5 for the session and specialists, Explore on Haiku. Opus 5 is available if you want it; specialists stay on Sonnet so a fan-out doesn't drain Pro's shared pool (see [Tuning by model](#tuning-by-model)).

## Install

```bash
git clone https://github.com/lakarpusky/claude-epc-workflow.git /tmp/claude-epc
mkdir -p ~/.claude/agents ~/.claude/commands ~/.claude/hooks
cp /tmp/claude-epc/agents/*.md ~/.claude/agents/
cp /tmp/claude-epc/commands/*.md ~/.claude/commands/
cp /tmp/claude-epc/hooks/verify-frontend.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/verify-frontend.sh
```

Then in Claude Code: `/agents` to verify they loaded, `/effort high` to set the session reasoning level.

The code agents reference an optional `code-comments` skill — install it for the comment discipline (they run fine without it). That plus the other personal-setup files live in [COMPANIONS.md](./COMPANIONS.md).

## Permissions baseline

The repo ships a sanitized `settings.json` (user scope) and `settings.local.json` (project scope) as a reference to diff against your own — not to copy wholesale. They lean cautious (force-push and installs gated, a commit-scope warning hook), with project-specific rules stripped. Lift what fits, adapt the rest.

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

When the domain is obvious, skip `/epc` and call a specialist directly:

```
/epc architect redesign state management
@react-virtuoso fix re-renders in Dashboard
@test-sentinel write integration tests for the cart flow
@e2e-pilot write a Playwright test for the checkout journey
@pwa-architect make the app installable and work offline
@git-wizard squash the last 5 commits
```

## Agents

| Agent | Domain |
|---|---|
| `git-wizard` | Commits, conflicts, rebases, branch strategy, recovery |
| `javascript-specialist` | Algorithms, performance, memory, async, bundle analysis |
| `react-virtuoso` | Components, renders, state, hooks, accessibility |
| `test-sentinel` | Jest, RTL, integration tests, coverage, flaky-test triage |
| `e2e-pilot` | Playwright E2E — journeys, locators, flake stabilization, CI/CD |
| `pwa-architect` | Service workers, Workbox caching, manifest, offline/installability, iOS Safari limits |

Each runs in its own context window at `effort: high` with `memory: local` (per-project, uncommitted). `javascript-specialist` and `react-virtuoso` add a `SubagentStop` gate that blocks their output on `tsc --noEmit` / `eslint` failure. The five code-writing agents preload the `code-comments` discipline skill. Specialists run on Sonnet 5, Explore on Haiku, the orchestrator on your session model; agents return text summaries that the orchestrator restates when chaining them.

## Project commands

Two standalone, manual-invoke commands for project health — independent of `/epc`:

- **`/analyze-codebase`** — scans the repo and generates a `CLAUDE.md` with the tech stack, architecture, critical paths, conventions, and a file-risk map. Run once per project to give future sessions deep context. Owns `CLAUDE.md`.
- **`/debt-audit`** `[category | quick | compare]` — scans technical debt across seven categories, scores findings by impact, and writes a prioritized report to `tasks/debt-audit-report.md`. Reads `CLAUDE.md` for context; read-only, never edits code.

Run `/analyze-codebase` first; `/debt-audit` then uses its file-risk map and known-issues table to weight severity.

## Tuning by model

| Setup | Adjustment |
|---|---|
| **Pro** (default) | Sonnet 5 is the default for the session, orchestrator, and specialists; Explore on Haiku. Opus 5 is available, but it shares one usage pool with Sonnet on Pro — keep specialists on Sonnet so a fan-out doesn't drain your limits, and run the orchestrator on Opus only when the routing judgment is worth the spend. |
| **Max** | More Opus headroom than Pro — run the session/orchestrator on Opus 5 for routing judgment, and keep specialists on Sonnet 5 (still the efficient default). Escalate one specialist to `model: opus` + `effort: xhigh` only for hard architecture. |
| **Cost-sensitive** | Drop mechanical agents to `effort: medium`; skip `/epc` for one-domain tasks. |

`effort: high` is the ceiling on Sonnet 5 (`xhigh`/`max` need Opus). Slash commands can't carry `effort`, so set it per session with `/effort high` or persist it: `{ "effortLevel": "high" }` in `~/.claude/settings.json`.

## Scope

**Covered:** Frontend JS/TS, React, Jest/RTL, Playwright E2E (incl. CI/CD: GitHub Actions, Jenkins, Azure DevOps), Progressive Web Apps, and Git workflows.

**Not covered:** Backend (beyond JS basics), Vue/Svelte/Angular, Cypress, infrastructure/DevOps, native & cross-platform mobile (iOS, Android, React Native/Flutter), games.

## Credits & license

Agents, the `/epc` orchestrator, and the project commands are original to this repo. MIT for the core system; companion skills retain their upstream licenses — see [COMPANIONS.md](./COMPANIONS.md).
