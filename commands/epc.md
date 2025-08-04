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
- Agents write code directly to files
- Console output is summaries only (no code)
- JavaScript is default, TypeScript on request
- Concise mode is default

## Workflow Modes

### Standard: Explore → Plan → Code
Complete workflow with concise output

### Quick: Direct to Code
Skip exploration for straightforward tasks

### Architect: Structural Decisions
Module structure, patterns, trade-offs (bullet points only)

## Language Modes
- **Default**: JavaScript (clean ES6+)
- **TypeScript**: Add `typescript` to command

## Usage

```
Follow EPC [workflow mode] [language mode] to [task]
```

Workflow modes: `standard` (default), `quick`, `architect`
Language modes: `javascript` (default), `typescript`

## Examples

**Standard Mode (Default - Concise)**
```
Follow EPC to optimize user search timing out with 50k users

Explore: O(n) search, memory leak, 3s blocking
Plan: Map lookup, WeakMap, Web Worker
Code: userSearch.js, searchWorker.js, 3s→50ms
```

**Quick Mode**
```
Follow EPC quick to add infinite scroll

ProductList.jsx: Added intersection observer, virtual list, 20 items/scroll
useInfiniteScroll.js: Reusable hook with cleanup
```

**Architect Mode**
```
Follow EPC architect to restructure dashboard.js (3000 lines)

Current: Monolithic file, mixed concerns
Proposed:
→ /widgets (components)
→ /data (API, transforms)
→ /hooks (business logic)
→ /utils (helpers)
Migration: Start data layer, no breaking changes
```

**TypeScript Mode**
```
Follow EPC typescript to build type-safe event emitter

Explore: Need strict event typing with autocomplete
Plan: Generic EventMap, typed emit/on/off, class for inference
Code: EventEmitter.ts (generics), types.ts (event map)
```

**Combined Modes**
```
Follow EPC quick typescript to add retry logic

apiClient.ts: Exponential backoff, AbortSignal support
Chose recursion over loop: cleaner async flow
```

## Output Policy
- No code in console outputs
- File changes summarized only
- Metrics and impact highlighted
- Concise unless explicitly requested otherwise
