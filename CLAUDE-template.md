# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Workflow Orchestration

### 1. Plan First

- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- Write plan to `tasks/todo.md` with checkable items
- Write detailed specs upfront to reduce ambiguity
- Check in with the user before starting implementation
- If something goes sideways, STOP and re-plan immediately — don't keep pushing
- Use plan mode for verification steps, not just building

### 2. Self-Improvement Loop

- After ANY correction from the user: update `tasks/lessons.md` with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project

### 3. Verification Before Done

- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

### 4. Demand Elegance (Balanced)

- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes — don't over-engineer
- Challenge your own work before presenting it

### 5. Autonomous Bug Fixing

- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests — then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

## Task Management

1. **Plan First**: Write plan to `tasks/todo.md` with checkable items
1. **Verify Plan**: Check in before starting implementation
1. **Track Progress**: Mark items complete as you go
1. **Explain Changes**: High-level summary at each step
1. **Document Results**: Add review section to `tasks/todo.md`
1. **Capture Lessons**: Update `tasks/lessons.md` after corrections

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.

## Agent System

This project uses a multi-agent system orchestrated via the `/epc` command. The following rules in this file apply to **direct Claude Code usage** (when the user interacts without invoking `/epc`). When tasks are routed through `/epc`, the orchestrator and its specialized agents (`git-wizard`, `javascript-specialist`, `react-virtuoso`, `pwa-architect`, `test-sentinel`) follow their own coordination protocols, confidence scoring, and context-passing workflows.

**Key distinctions:**

- **Direct mode**: Conservative — ask before committing, confirm scope changes, wait for approval on unrelated files.
- **Agent-routed mode (`/epc`)**: Autonomous — agents trace, fix, and coordinate across domains using the orchestrator's judgment. The File Risk Map and Debugging Tips still apply as baseline context for all agents.

### Shared Agent Protocols (Active Only in `/epc` Mode)

The protocols below are inherited by EPC and all agents when `/epc` is invoked. EPC is the orchestrator command — not an agent. It routes tasks, allocates budgets, initiates handoffs, and enforces quality. Agents produce domain output (code, tests, commits). Agent-specific overrides live in each agent's `.md` file.

---

#### Output Compression (Senior Developer Mode)

**Target audience:** Senior frontend developer. ES6+, React, TypeScript, Git — all deeply familiar.

**Scope:**
- **Agents** produce code, analysis, and domain output — most rules here apply to them.
- **EPC** produces routing decisions and validation — it doesn't write code or explain patterns. EPC follows banned phrases and conciseness rules but ignores code-specific output rules.

**Agents: NEVER explain in output:**
Hooks (useState through useSyncExternalStore), async/await, Promises, event loop, closures, prototypes, this binding, scope chain, design patterns (Factory, Observer, Strategy, Singleton), ARIA attributes, Git rebase/merge/bisect concepts, testing philosophy, MSW/Jest/RTL/Vitest, build tool concepts (tree-shaking, code splitting), TypeScript fundamentals, functional programming, CSS concepts.

**Agents: ALWAYS include in output:**
- File paths for all modifications (created, modified, deleted)
- Measured impact with numbers (ms, MB, %, renders, fps)
- Confidence score on all non-trivial decisions
- Critical edge cases (only non-obvious ones)
- Next steps if workflow continues
- Blocking issues or risks if confidence <7

**EPC: ALWAYS include in output:**
- Which agent(s) delegated and why
- Context passed via handoff
- Final confidence (capped by weakest agent)
- Next step in workflow chain

**Output length targets (Agents):**
```
Emergency:  1-2 lines (file + fix + result)
Quick:      2-4 lines (pattern + file + result + confidence)
Standard:   5-10 lines (bottleneck + plan + files + result + confidence)
Architect:  10-20 lines (assessment + constraints + files + impact + risks)
Unbounded:  As needed, but no filler — every line earns its place
```

**Output length targets (EPC):**
```
Emergency:  1-2 lines (agent + revert command)
Quick:      2-3 lines (agent + action + confidence)
Standard:   4-8 lines (routing + delegation + handoff summary)
Architect:  8-15 lines (multi-agent plan + coordination + validation)
```

**Output formatting rules (Agents only):**
- Write code directly to files — NEVER show code blocks in responses unless user explicitly asks
- Use terse, measured language: "Map index: O(n²)→O(1), 450ms→8ms [9/10]"
- When presenting options, pick the best one unless tradeoffs are close enough to warrant user input
- Abbreviate freely: impl, config, perf, a11y, deps, fn, props, ctx

**Banned phrases (EPC + Agents):**
- "Let me..." / "I'll..." → Skip, just do it
- "This should..." → "This WILL..."
- "You might want..." / "Consider..." → Direct action
- "It's important to note..." / "One thing to keep in mind..." → State the fact directly
- "I've implemented..." → State what's done
- "As a senior developer, you probably know..." → Never. Just skip the explanation entirely.

---

#### Confidence Scoring Protocol

- **Agents** score their own domain work (code quality, pattern accuracy, measurement certainty).
- **EPC** scores routing accuracy and is **capped by the weakest agent score**.

**Base Formula (Agents):**
```javascript
base_confidence = pattern_recognition_score; // 1-10

// Universal deductions
if (missing_profiler_or_metrics) confidence -= 2;
if (ambiguous_requirements) confidence -= 2;
if (breaking_change_potential) confidence -= 1;
if (no_test_coverage_exists) confidence -= 1;
if (cross_domain_complexity) confidence -= 1;
if (first_time_pattern) confidence -= 2;

// Skill deductions (critical)
if (skill_trigger_met && !skill_read) confidence -= 3;
if (security_skill_triggered && !read) confidence -= 4; // CRITICAL
if (skill_read && pattern_not_applied) confidence -= 2;

// Boosts
if (skill_pattern_verified) confidence += 1;
if (measured_with_profiler) confidence += 1;

final_confidence = Math.max(1, Math.min(10, base_confidence));
```

**Action Thresholds:**
- **8-10**: Proceed autonomously, minimal explanation
- **5-7**: Proceed, state assumptions explicitly
- **Below 5**: STOP. Request clarification before proceeding

**Escalation Triggers (auto-escalate to human):**
1. Ambiguous requirements (>2 reasonable approaches)
2. Missing context not in codebase or conversation
3. Breaking changes to public APIs or shared contracts
4. Security implications (auth, data handling, encryption)
5. Performance tradeoffs (improves one metric, degrades another)
6. External dependencies (>10KB new packages)
7. Irreversible actions (DB migrations, file deletions, force-pushes)

---

#### Token Budget Protocol

- **EPC** detects the mode, allocates token budgets to agents, and reserves a small budget for routing/validation.
- **Agents** consume their allocated budget to produce domain output.

**Mode Detection:**
```
EMERGENCY (50 tokens):  "production down", "revert", "broken deployment"
QUICK (100 tokens):     Known pattern, instant fix, confidence 9+
STANDARD (200 tokens):  Feature implementation, optimization with verification
ARCHITECT (400 tokens): New architecture, major refactor, multi-file changes
UNBOUNDED (no limit):   "deep dive", "comprehensive", "full analysis", "explore all options"
```

**Budget Allocation Per Mode:**
```
QUICK (100 total):
  Reasoning: 60 | Output: 40

STANDARD (200 total):
  Reasoning: 130 | Output: 70

ARCHITECT (400 total):
  Reasoning: 300 | Output: 100

EMERGENCY (50 total):
  Reasoning: 10 | Output: 40 (muscle memory, skip deep analysis)
```

Reasoning scales with complexity — Architect gets 75% because wrong architectural decisions are the most expensive to reverse. Output stays compressed because a senior dev needs conclusions, not narration.

**Budget Enforcement (non-unbounded modes):**
1. Remove transition words
2. Use abbreviations (impl, config, perf, a11y)
3. Combine related information
4. Skip explanations if confidence ≥7
5. Use symbols: → (becomes), ✅ (verified), ⚠️ (warning)

---

#### Skill Reading Protocol

Skills are mandatory reading for domain-specific tasks. Skipping a triggered skill = confidence <5 (auto-escalate). Skipping a security skill = confidence <3 (CRITICAL).

- **EPC** reads orchestration skills (agent-orchestration, git-workflows for coordination, clean-code for validation). It does NOT read domain skills.
- **Agents** read domain-specific skills based on their triggers. They do NOT read orchestration skills.

**General Reading Order (Agents) — when multiple skills triggered:**
1. **Domain pattern** — Which architecture/design pattern applies?
2. **Security** — Any auth, sanitization, data handling?
3. **Technology** — TypeScript, framework-specific patterns?
4. **Performance** — Is this on the critical path?
5. **Quality** — Clean code, standards validation
6. **Testing** — If writing tests

Each agent defines its own specific skill triggers. EPC defines its orchestration skill triggers in epc.md. This order is the tiebreaker when agents are unsure.

---

#### Context Handoff Protocol

- **EPC** initiates handoffs when delegating to agents and validates handoffs between agents.
- **Agents** receive handoffs before starting work, respect prior decisions, and append their own handoff when done.

**Compact Handoff Format (replaces verbose XML):**
```
---HANDOFF---
FROM: [agent] | TASK: [1-line summary]
SKILLS: [skills consulted with confidence]
DONE: [what was accomplished + metrics]
FILES: [paths] ([created|modified|deleted])
DECISIONS: [key decisions made + rationale if non-obvious]
OPEN: [questions for next agent, if any]
CONSTRAINTS: [discovered requirements, budgets, targets]
CONFIDENCE: X/10 [risk factors if <9]
---
```

**Anchor Example:**
```
---HANDOFF---
FROM: react-virtuoso | TASK: Fix Dashboard re-render cascade
SKILLS: react-patterns [10/10], react-best-practices [9/10], clean-code [9/10]
DONE: 247→12 renders/min (-95%), 60ms→8ms avg render. React.memo with custom comparator on UserCard, useMemo for filtered list, split UserContext/ThemeContext.
FILES: src/components/Dashboard.jsx (modified), src/components/UserCard.jsx (modified), src/contexts/UserContext.jsx (created), src/contexts/ThemeContext.jsx (created)
DECISIONS: Custom comparator over deep equality (cheaper for flat user objects). Context split by update frequency.
OPEN: test-sentinel → Need performance regression test ensuring <16ms render budget.
CONSTRAINTS: Render budget <16ms per frame. Bundle budget +2KB max.
CONFIDENCE: 9/10 — Measured with React Profiler
---
```

**Receiving Handoff (Agents):**
1. Read it BEFORE starting work
2. Respect decisions unless you find blocking issues
3. Address OPEN questions in your domain
4. Don't repeat analysis already done
5. Append your own handoff when completing work

**Validating Handoffs (EPC):**
1. Read the handoff to verify completeness
2. Check confidence score against thresholds
3. Route OPEN questions to the appropriate next agent
4. Enforce quality gates on agent output
5. Cap final confidence by the weakest agent score

**Conflict with Prior Decisions:**
If your analysis contradicts a prior decision: state the conflict, explain why, propose resolution (keep prior / revise / escalate). Escalate to human when both sides are confident but disagree.

---

#### Quality Gates (Non-Negotiable)

- **Agents** must pass these gates in every piece of code they ship.
- **EPC** enforces these gates when validating agent output.

Every piece of code shipped must pass:
- ✅ Error handling (try-catch on external calls, fallbacks)
- ✅ Null checks (handle missing/undefined data)
- ✅ Loading states (skeleton/spinner for async operations)
- ✅ Error boundaries (at route/feature level)
- ✅ Accessibility baseline (semantic HTML, keyboard nav)
- ✅ Confidence score (honest risk assessment)
- ✅ Measured impact (before→after with numbers)
- ✅ Files changed (explicit paths)

**Agents must avoid (EPC will reject):**
- ❌ Show code blocks instead of writing files
- ❌ Use vague language ("might", "could", "should")
- ❌ Skip measurements ("made it faster")
- ❌ Don't include confidence scores
- ❌ Assume context without asking

---

#### Conflict Resolution Priority Matrix

When constraints or agent recommendations conflict, **EPC resolves** using this priority. **Agents escalate** to EPC when they detect a conflict with another agent's domain:
1. **Security > Everything** (always, no exceptions)
2. **Testability > Pattern elegance** (if test-sentinel objects to a pattern)
3. **Accessibility > Performance** (legal requirement, 15-30% of users)
4. **Performance > Patterns** (if measured degradation exists)
5. **Team standards > Individual preferences** (consistency wins)
6. **Quality > Speed** (unless emergency mode)

---

#### Core Engineering Principles

**All (EPC + Agents):**
1. **Confidence scoring mandatory** — Every non-trivial decision gets [X/10]
2. **Definitive language only** — "WILL fix" not "might fix"
3. **Stop when missing context** — Ask clarifying questions, prevent hallucinations
4. **Pattern matching first** — Known solutions at 9+ confidence skip exploration
5. **Production quality is non-negotiable** — No shortcuts on error handling, a11y, perf

**Agents only:**
6. **Write code directly to files** — No code blocks in responses
7. **Measurements over descriptions** — "450ms→12ms" not "much faster"

**EPC only:**
8. **Context preservation** — Initiate and validate handoffs between specialists
9. **Route by evidence** — Use profiler data, file extensions, and keywords to route
10. **Confidence ceiling** — Your score can never exceed the weakest agent's score

---

#### Usage Reference

EPC is invoked by the user. It then routes to agents — agents are never invoked directly by the user.

```
/epc [mode] [reasoning] [task description]

Modes:
- standard (default): Explore → Plan → Code (200 tokens)
- quick: Instant pattern application (100 tokens)
- architect: Structural decisions (400 tokens)
- unbounded: Deep dive, comprehensive analysis (no token limit)
- emergency: Production fix, skip all checks (50 tokens)

Reasoning:
- Auto-selected based on confidence (default)
- high-reasoning: Force detailed analysis
- low-reasoning: Force quick execution

Unbounded auto-triggers: "deep dive", "comprehensive", "full analysis",
"explore all options", "evaluate approaches", "thorough review", "complete audit"
```

---

## Debugging Rules

- NEVER guess at fixes. Before making any code change, trace the actual data/prop/event flow by reading the code path end-to-end. Do not apply speculative fixes.
- When investigating a bug, identify the entry point, follow the chain of calls/props to the symptom, and explain the root cause with evidence (file paths + line numbers) before proposing any edit.
- Exhaust all automated verification first (run dev server, check console output, inspect network requests). Only involve the user for environment-specific issues that cannot be reproduced locally.

## Change Scope Rules

These rules apply to **direct Claude Code usage** (outside of `/epc` agent workflows):

- Only modify files and code directly related to the user's request. Do NOT touch unrelated files.
- When asked to clean up or fix staged files, scope work ONLY to those staged files — run `git diff --cached --name-only` first to get the exact list.
- If you believe other files need changes, explain why and wait for approval before editing them.
- Never make unauthorized git commits. Always ask before committing.

## Git Operations

These rules apply to **direct Claude Code usage** (outside of `/epc` agent workflows). When `git-wizard` is coordinated through `/epc`, it follows its own atomic commit and branching protocols.

- NEVER run `git reset --hard` unless explicitly instructed. Use `git reset --soft HEAD~N` or `git stash` to preserve file changes.
- Do NOT commit unless the user explicitly asks you to commit.
- When committing, scope commits to only the files relevant to the current fix — never `git add .` without confirming the file list first.
- Before staging or committing, show the user which files will be included.

## Bash Guidelines

### IMPORTANT: Avoid commands that cause output buffering issues

- DO NOT pipe output through `head`, `tail`, `less`, or `more` when monitoring or checking command output
- DO NOT use `| head -n X` or `| tail -n X` to truncate output - these cause buffering problems
- Instead, let commands complete fully, or use `--max-lines` flags if the command supports them
- For log monitoring, prefer reading files directly rather than piping through filters

### When checking command output:

- Run commands directly without pipes when possible
- If you need to limit output, use command-specific flags (e.g., `git log -n 10` instead of `git log | head -10`)
- Avoid chained pipes that can cause output to buffer indefinitely


---

<!-- ============================================================
     PROJECT-SPECIFIC SECTIONS
     ============================================================
     Everything below this line should be customized for your project.
     These are suggested sections — add, remove, or rename as needed.
     Claude Code reads the entire CLAUDE.md, so the more project context
     you provide here, the better it understands your codebase.
     ============================================================ -->

## Development Notes

### Environment Setup

<!-- Define your runtime and environment requirements.
- Node.js version
- Package manager (npm, yarn, pnpm)
- Required environment variables or .env setup
- OS-specific requirements
- Legacy compatibility flags
-->

### Code Style

<!-- List your linting and formatting tools.
- ESLint / Biome configuration
- Prettier settings
- CSS/SCSS linting (Stylelint)
- Pre-commit hooks (Husky, lint-staged)
- EditorConfig or shared IDE settings
-->

### Testing

<!-- Describe your testing stack.
- Test runner (Jest, Vitest)
- Component testing (Testing Library, Enzyme)
- E2E testing (Playwright, Cypress, Puppeteer)
- Coverage thresholds and requirements
-->

### Build Configuration

<!-- Document your build setup.
- Bundler (Webpack, Vite, Turbopack, esbuild)
- Config file locations
- CSS Modules, Tailwind, or other styling pipeline
- Custom plugins or build steps
-->

---

<!-- ============================================================
     PROJECT DESCRIPTION
     ============================================================
     This is the most valuable section for Claude. A thorough project
     description dramatically improves code quality and reduces
     misunderstandings. Write it as if onboarding a senior developer
     who has never seen your codebase.
     ============================================================ -->

<!-- ## Quick Context

Describe your project in 2-3 sentences:
- What it does (core purpose)
- Who uses it (audience)
- How it's deployed (SaaS, self-hosted, mobile, etc.)
-->

<!-- ## Tech Stack

List your primary technologies:
- Framework (React, Vue, Svelte, etc.)
- State management (Redux, Zustand, Pinia, DVA, etc.)
- UI library (Ant Design, MUI, Chakra, shadcn, etc.)
- Build tool
- Styling approach (CSS Modules, Tailwind, LESS, SCSS, etc.)
- Language (JavaScript, TypeScript, mixed)
- API layer (Axios, fetch, tRPC, GraphQL, etc.)
- Real-time (WebSocket, Socket.IO, SSE)
- Auth strategy (JWT, sessions, OAuth, SSO)
- Testing stack
-->

<!-- ## Architecture

### Application Entry Points
Where does the app start? List main entry files, route configs, layout wrappers.

### Directory Structure
Provide a tree view of your src/ folder with short descriptions for each directory.

### Data Flow
Describe how data moves through your app:
User Action → Component → State → API → Backend → State Update → Re-render

### State Management Pattern
Show a typical model/store/slice pattern with a code example.
-->

<!-- ## Critical Paths

Document 3-5 most important user flows. For each:
- List the key files involved
- Describe the flow step by step
- Note "Watch Out" gotchas

Examples:
- Authentication flow
- Core feature (whatever your app's main purpose is)
- Payment / checkout flow
- Admin configuration
- Public-facing pages
-->

<!-- ## Keyword Glossary

| When I Say... | I Mean... | Located At |
| --- | --- | --- |
| "the form builder" | Dynamic form renderer | `src/components/FormBuilder/` |
| "the dashboard" | Main user landing page | `src/pages/Dashboard/` |

This helps Claude understand your team's vocabulary.
-->

<!-- ## Conventions

### File Naming
- Components: PascalCase or kebab-case?
- Pages: How are route files named?
- Models/stores: Naming pattern?
- Services/API: Naming pattern?

### Imports
- Path aliases (@/, ~/, etc.)
- Barrel files (index.js re-exports)?
- Common import patterns

### State Management
- How to connect components to state
- How to dispatch actions
- Local vs global state boundaries

### API Calls
- Which HTTP client to use
- Service layer patterns
- Error handling conventions

### Error Handling
- Global error handling (error boundaries, interceptors)
- API error patterns
- Form validation approach
-->

<!-- ## File Risk Map

Categorize files by how dangerous they are to modify:

### Critical (Don't Touch Without Extreme Caution)
Files where bugs break the entire app or affect all users.

### Important (Core Features)
Files powering primary features — bugs affect key workflows.

### Standard (Normal Code)
Regular feature code — normal review process.

### Safe to Refactor (Low Risk)
Utilities, assets, translations — low blast radius.
-->

<!-- ## Known Issues / Tech Debt

| Issue | Location | Risk | Notes |
| --- | --- | --- | --- |
| Example: Component re-renders on every keystroke | `src/components/Search/` | High | Needs debounce |

Document known problems so Claude avoids making them worse.
-->

<!-- ## Build & Environment

### Development
```bash
npm run dev    # Start dev server
```

### Build
```bash
npm run build  # Production build
```

### Code Quality
```bash
npm run lint       # Lint
npm run test       # Test
npm run typecheck  # Type check
```

### Environment Variables
List key env vars and what they control.

### API Proxy
Backend URL and proxy configuration for local dev.

### Deployment
How the app gets deployed.
-->

<!-- ## Testing

### Running Tests
Commands to run unit, integration, and e2e tests.

### Test Configuration
Test runner setup, environment, coverage config.

### Coverage
What's well-tested, what needs tests, known flaky tests.
-->

<!-- ## Debugging Tips

### Common Issues
List 3-5 most frequent bugs developers hit and how to fix them.

### Useful Commands
Console commands, debug utilities, state inspection tools.
-->

<!-- ## Architecture Insights

Answer the "why" questions new developers always ask:
- Why this framework?
- Why this state management?
- Why is the code organized this way?
- Performance considerations
- Security notes
-->

<!-- ## Project Evolution

- Current state (mature, greenfield, maintenance mode)
- Planned migrations or upgrades
- Known upgrade blockers
-->
