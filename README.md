# Claude EPC Workflow

Multi-agent system for frontend development in Claude Code. Specialized agents for JavaScript, React, testing, and Git—coordinated by a central orchestrator.

## What This Is

Six markdown files you drop into `.claude/` that give Claude Code domain expertise:

| Agent | Does |
|-------|------|
| `epc` | Routes tasks to the right specialist, manages handoffs |
| `javascript-specialist` | Algorithms, performance, memory, async patterns |
| `react-virtuoso` | Components, renders, state, accessibility |
| `test-sentinel` | Jest, RTL, integration tests, coverage |
| `git-wizard` | Commits, conflicts, rebases, branches |
| `pwa-architect` | Converts existing apps to PWAs (standalone) |

## Install

```bash
# Clone to your Claude config
git clone https://github.com/lakarpusky/claude-epc-workflow.git ~/.claude/agents

# Or copy individual agents
cp agents/*.md ~/.claude/
```

## Usage

```bash
# In Claude Code
/epc [mode] [task]

# Modes
/epc quick fix the null check in UserCard        # 100 tokens, instant
/epc standard add filter to product list         # 300 tokens, explore→plan→code
/epc architect redesign state management         # 600 tokens, full analysis
/epc unbounded evaluate Redux vs Zustand         # No limit, deep dive
/epc emergency revert last commit                # 50 tokens, fast

# Or call specialists directly
/javascript-specialist optimize this O(n²) loop
/react-virtuoso fix re-renders in Dashboard
/test-sentinel write tests for checkout flow
/git-wizard squash last 5 commits
```

## How It Works

```
You → EPC (orchestrator) → Specialist → Code
                ↓
         Routes by context:
         - .jsx files → react-virtuoso
         - .js utils → javascript-specialist  
         - .test.js → test-sentinel
         - git operations → git-wizard
         - "slow" + profiler data → appropriate specialist
```

**Multi-agent tasks** pass context between specialists:
```
react-virtuoso optimizes component
       ↓ passes context
test-sentinel writes tests for the optimization
       ↓ passes context  
git-wizard commits with proper message
```

## Key Features

**Performance triage** — "Slow" is ambiguous. EPC asks:
- React Profiler data → react-virtuoso
- Chrome DevTools data → javascript-specialist
- No data → asks which type before routing

**Confidence scoring** — Every decision gets 1-10 rating:
- 8-10: Proceeds automatically
- 5-7: Proceeds with stated assumptions
- <5: Stops and asks for clarification

**Unbounded mode** — For complex architecture decisions when 600 tokens isn't enough. Triggered by "deep dive", "comprehensive", or explicit `/epc unbounded`.

**Shared context** — Specialists pass findings to each other. React optimization context flows to test-sentinel so tests verify the actual changes made.

## File Structure

```
~/.claude/
├── epc.md                    # Orchestrator
├── javascript-specialist.md  # JS/algorithms
├── react-virtuoso.md         # React/components
├── test-sentinel.md          # Testing
├── git-wizard.md             # Git
└── pwa-architect.md          # PWA conversion (standalone)
```

## What This Is NOT

- Not a build system
- Not a CLI tool with installers
- Not a dashboard or GUI
- Not magic—agents need context to work well

## Scope

**Covered:** Frontend JS/TS, React, Jest/RTL, Git workflows, PWA conversion

**Not covered:** Backend (Node/Express beyond JS basics), Vue/Svelte/Angular, E2E (Playwright/Cypress depth), infrastructure/DevOps

## Requirements

- Claude Code
- Frontend project (JS/TS, React preferred)

## License

MIT
