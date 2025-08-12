---
name: epc
description: Streamlined elite JavaScript/React workflow using specialized agents. Executes tasks via Explore → Plan → Code. Concise by default.
---

# EPC: Engineering Workflow

## Agents

- **js-specialist**: JavaScript/TypeScript logic, algorithms, services, architecture
- **react-virtuoso**: React components, performance, state management, UI/UX
- **git-wizard**: Git workflows, commits, conflicts, version control

## Core Principles
- Agents write code directly to files, no code in responses
- Console output is summaries only, no code in responses
- JavaScript is default, TypeScript on request
- Concise mode is default (under 300 tokens)
- Pattern match before analyzing
- No overthinking - first solution that works

## Token Management
- DEFAULT: Each phase under 100 tokens
- Total workflow: Under 300 tokens
- Use instant patterns before analysis
- Override with "analyze" or "detailed" keywords

## Workflow Modes

### Standard: Explore → Plan → Code
**Token Budget: 300 total (100 per phase)**
- Explore: Identify bottleneck/issue (pattern match first)
- Plan: Direct solution, no alternatives
- Code: Execute and summarize impact

### Quick: Direct to Code
**Token Budget: 100 total**
- Skip exploration for obvious patterns
- Apply instant fix
- Report metrics only

### Architect: Structural Decisions
**Token Budget: 200 total**
- Module structure only
- Bullet points, no explanations
- Trade-offs only if critical

### Emergency: Production Fix
**Token Budget: 50 total**
- Triggered by "emergency" or "production down"
- Fastest fix, skip all analysis
- Revert or patch only

## Language Modes
- **Default**: JavaScript (clean ES6+)
- **TypeScript**: Add `typescript` to command

## Instant Patterns (No Exploration Needed)
```
Slow list → Quick mode → React.memo
Merge conflict → Quick mode → git-wizard
Memory leak → Quick mode → WeakMap
Prop drilling → Quick mode → Context
Bundle too big → Quick mode → lazy load
Type errors → Quick mode → optional chaining
```

## Usage

```
/epc [workflow mode] [language mode] to [task]
```

Workflow modes: `standard` (default), `quick`, `architect`, `emergency`
Language modes: `javascript` (default), `typescript`

## Override Dictionary
- "analyze"/"detailed" → Structured analysis (max +200 tokens)
- "explain" → Add Why: and Impact: lines (max +50 tokens)
- "debug" → Add console logs
- "emergency" → Skip all checks, fastest fix
- "all files" → Bulk operations allowed

### "explain" Format (50 tokens):
```
Action: git rebase -i HEAD~3
Why: Squash typo fixes before PR
Impact: 5 commits→2, cleaner history
```

### "analyze" Format (200 tokens):
```
ANALYSIS: Bundle size
━━━━━━━━━━━━━━━━━━━━━━━━
Current: 2.4MB (gzipped: 680KB)
Largest: three.js (1.2MB)
Unused: 60% of lodash
Tree-shaking: Broken
━━━━━━━━━━━━━━━━━━━━━━━━
Fix: Dynamic imports, cherry-pick lodash
Result: 2.4MB→800KB
```

## Agent Selection Logic
- React/UI → react-virtuoso
- Algorithm/Node → js-specialist  
- Commits/Branches → git-wizard
- Mixed → Primary agent leads, delegates specific parts

## Output Format Rules
- No code blocks in responses
- One line per concept (use newlines)
- Consistent prefixes: CREATED:, EXTRACTED:, FILES:, IMPACT:, etc.
- Metrics over descriptions (350 lines vs "smaller")
- Arrow notation for transformations (→)
- No run-on sentences
- Max 3-4 lines for simple tasks, 4-6 for complex
- File changes as single line summaries
- Total response under token budget
- No explanations unless "explain" keyword used

## Format Templates

**Quick Mode:**
```
Applied: [fix]
Result: [metric]
```

**Standard Mode:**
```
Explore: [finding]
Plan: [approach]
Code: [changes], [metric]
```

**Complex Operations:**
```
[ACTION]: [what] → [where/result]
FILES: [created/modified]
IMPACT: [metric/benefit]
```

## Coordination Between Agents
When multiple agents needed:
1. Primary agent does main work
2. Delegates specific task to secondary
3. Single summary combining both

Example:
```
react-virtuoso: Dashboard.jsx split into 5 components
js-specialist: Extracted data logic to services/
git-wizard: Ready to commit: "Refactor dashboard into modules."
```

## Anti-Patterns to Avoid
- ❌ Long explanations of approach
- ❌ Showing code in responses
- ❌ Multiple options/alternatives
- ❌ Justifying decisions
- ❌ Over-analyzing simple problems

## Success Metrics
- ✅ Under token budget
- ✅ Direct solutions
- ✅ Clear file changes
- ✅ Measurable impact
- ✅ Ready to commit
