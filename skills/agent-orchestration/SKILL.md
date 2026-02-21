---
name: agent-orchestration
description: |
  Multi-agent context protocol for coordinating specialist agents.
  Use when implementing features that span multiple domains, need handoffs
  between agents, or require the analysis_context XML protocol.
  Reference for EPC orchestration of javascript-specialist, react-virtuoso, 
  test-sentinel, git-wizard, and pwa-architect agents.
metadata:
  author: Gabo
  version: 1.0.0
  agents:
    - javascript-specialist
    - react-virtuoso
    - test-sentinel
    - git-wizard
    - pwa-architect
---

# Agent Orchestration Protocol

Coordination patterns for multi-agent Claude Code workflows.

---

## Agent Capabilities Matrix

| Agent | Expertise | Primary Tasks |
|-------|-----------|---------------|
| **javascript-specialist** | Performance, algorithms, async | O(n) optimization, memory leaks, profiling |
| **react-virtuoso** | React, a11y, state | Render optimization, WCAG, component architecture |
| **test-sentinel** | Jest, RTL, MSW | Integration tests, coverage, TDD |
| **git-wizard** | Git, workflows, CI/CD | Commits, conflicts, releases |
| **pwa-architect** | PWA, Service Workers, offline | Caching, installability, Workbox |

---

## Context Handoff Protocol

### Analysis Context XML Structure

```xml
<analysis_context>
  <prior_analysis>
    <specialist>[agent-name]</specialist>
    <task_summary>[1-line description]</task_summary>
    <findings>
      - [Key finding 1]
      - [Key finding 2]
    </findings>
    <decisions>
      - [Decision made + rationale]
    </decisions>
    <open_questions>
      - [Question for next specialist]
    </open_questions>
  </prior_analysis>
  <files_touched>
    - path/to/file.js (created|modified|deleted)
  </files_touched>
  <constraints_identified>
    - [Constraint that must be respected]
  </constraints_identified>
</analysis_context>
```

### When Receiving Context

1. Read `<prior_analysis>` BEFORE starting work
2. Address `<open_questions>` in your domain
3. Respect `<decisions>` unless blocking issue found
4. Follow `<conventions_detected>` in code
5. Don't re-analyze what prior specialist already profiled

### When Completing Work

Always append your analysis for the next specialist:
- Summarize what you did
- Document decisions and rationale
- Ask questions for next domain
- List files touched
- Note constraints discovered

---

## Routing Decision Tree

```
User Request
    │
    ├─ Performance issue?
    │   ├─ Algorithm/memory → javascript-specialist
    │   └─ React renders → react-virtuoso
    │
    ├─ React component?
    │   ├─ State architecture → react-virtuoso
    │   ├─ Accessibility → react-virtuoso
    │   └─ Pure JS logic inside → javascript-specialist first
    │
    ├─ Testing needed?
    │   └─ test-sentinel
    │
    ├─ Git/deployment?
    │   └─ git-wizard
    │
    ├─ Offline/installable?
    │   └─ pwa-architect
    │
    └─ Multi-domain feature?
        └─ Follow handoff chain below
```

---

## Common Handoff Chains

### Feature Implementation

```
javascript-specialist → react-virtuoso → test-sentinel → git-wizard
      │                      │                │              │
      ▼                      ▼                ▼              ▼
  Algorithm           Component          Tests          Commits
  Data structures     State mgmt         Coverage       PR
  Performance         Accessibility      Mocking        Deploy
```

### Performance Fix

```
javascript-specialist → react-virtuoso → test-sentinel
      │                      │                │
      ▼                      ▼                ▼
  Profile              Apply to React    Regression tests
  Optimize             Memoization       Performance assertions
  Document             Context splits    Coverage
```

### PWA Feature

```
pwa-architect → javascript-specialist → test-sentinel → git-wizard
      │                  │                    │              │
      ▼                  ▼                    ▼              ▼
  Strategy          Implement SW          Test offline    Deploy
  Manifest          Caching logic         Mock SW         Release
  Platform check    Storage APIs          Coverage        Changelog
```

---

## Conflict Resolution

When specialists disagree:

```
⚠️ CONFLICT WITH PRIOR DECISION

PRIOR DECISION: [What previous agent decided]
MY FINDING: [Why my expertise suggests different approach]

Example:
PRIOR: "Use Map for O(1) lookup in component"
MY FINDING: "Map in render creates new reference each time, 
             causing React.memo to fail. Need useMemo wrapper."

RESOLUTION: Enhance prior decision with domain-specific wrapper
CONFIDENCE: 9/10
```

### Resolution Options

1. **Enhance** - Add domain-specific wrapper (most common)
2. **Override** - Replace with better approach (document why)
3. **Escalate** - Ask EPC/user when tradeoff is unclear

---

## Bug Discovery Protocol

When finding bugs while working:

```
🐛 BUG DISCOVERED

COMPONENT: [Where the bug is]
DISCOVERED BY: [Which agent, during what task]
EXPECTED: [What should happen]
ACTUAL: [What actually happens]

SEVERITY: [Critical/High/Medium/Low]
RECOMMENDATION: 
- [ ] Fix before merging (if critical)
- [ ] Create ticket for follow-up (if medium/low)
- [ ] Notify [relevant-agent]

TEST STATUS: Written as failing test (TDD style)
```

---

## Commit Organization (git-wizard)

When receiving context with multiple files:

```
FILES FROM CONTEXT:
- src/components/Dashboard.jsx (modified)     → feat commit
- src/components/Dashboard.test.jsx (created) → test commit
- src/utils/cache.js (created)                → refactor commit
- src/contexts/UserContext.jsx (created)      → refactor commit

PROPOSED COMMITS:
1. refactor(context): split UserContext from app context
   - src/contexts/UserContext.jsx
   
2. refactor(utils): add cache utility
   - src/utils/cache.js

3. feat(dashboard): optimize render performance
   - src/components/Dashboard.jsx

4. test(dashboard): add integration tests
   - src/components/Dashboard.test.jsx

Each commit: atomic, deployable, reviewable
```

---

## Output Format Standards

### Conciseness Protocol (All Agents)

**BANNED:**
- "This will..." → State action directly
- "The solution..." → State solution directly
- "I've implemented..." → State what's done
- Explanations unless confidence <7

**FORMAT:**
```
Action: result, metric [confidence]
Example: "Map index: O(n²)→O(1), 450ms→8ms [9/10]"
```

### Master Mode (All Agents)

**ASSUME KNOWN:**
- Core language/framework fundamentals
- Standard tooling and patterns
- Testing libraries
- Build tools

**OUTPUT ONLY:**
- Exact changes/commands
- Measured impact
- Confidence score if <9/10
- Edge cases
- Context for next agent

---

## Agent-Specific Protocols

### javascript-specialist

**Ask when missing:**
- Performance profile (Chrome DevTools)
- Data volume (10 vs 10k items)
- Target environment
- Current measurements (not "slow")

**Pass to react-virtuoso:**
- Algorithm decisions
- Data structure choices
- Performance constraints

### react-virtuoso

**Ask when missing:**
- React Profiler data
- List sizes
- Accessibility requirements
- Current state management

**Pass to test-sentinel:**
- Component architecture
- State decisions
- A11y requirements
- Performance budgets

### test-sentinel

**Ask when missing:**
- What user behavior to test
- Framework details
- Unit vs integration vs e2e
- API contracts

**Pass to git-wizard:**
- Files created/modified
- Coverage achieved
- Bugs discovered

### git-wizard

**Ask when missing:**
- Current branch/status
- Team vs solo repo
- Deploy frequency
- CI/CD checks

**Final in chain:**
- Organize commits
- Answer commit structure questions
- Prepare PR

### pwa-architect

**Ask when missing:**
- Offline requirements
- Target platforms
- Install importance
- Storage needs

**Pass to javascript-specialist:**
- SW implementation details
- Caching requirements
- Storage patterns

---

## Success Metrics

### Handoff Quality

- [ ] Context XML complete and accurate
- [ ] Open questions are actionable
- [ ] Files touched list is exhaustive
- [ ] Constraints are explicit

### Chain Completion

- [ ] All agents addressed relevant open questions
- [ ] No orphaned TODOs
- [ ] Tests cover implementation
- [ ] Commits are atomic and reviewable
