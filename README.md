# Claude EPC Workflow

FAANG-caliber engineering workflow for Claude Code with aggressive token efficiency. Execute complex tasks via specialized agents while avoiding rate limits.

> **"FAANG-caliber" = Production Reality**  
> Not about working at big tech, but thinking like you deploy to millions. It means:
> - Every decision has trade-offs
> - Performance matters at scale  
> - Simple solutions beat clever ones
> - Ship working code, not perfect code

## Why EPC?

Traditional AI coding assistants overthink, over-explain, and hit rate limits fast. EPC solves this with:
- **Pattern matching over analysis** - Instant fixes for common issues
- **Token budgets** - Each response stays under 300 tokens
- **Specialized agents** - Right tool for each job
- **No overthinking** - First working solution wins

## Quick Start

```bash
# Standard workflow (Explore → Plan → Code)
/epc optimize user search performance

# Quick mode (skip exploration)
/epc quick fix memory leak

# Emergency mode (production down)
/epc emergency fix payment crash

# With TypeScript
/epc typescript add type-safe event emitter

# With analysis
/epc analyze investigate slow checkout
```

## Agents

### 🟡 js-specialist
FAANG-level JavaScript/TypeScript engineer. Handles algorithms, performance, and architecture.
- Default: JavaScript ES6+
- TypeScript on request
- Instant patterns for common issues
- Token budget: 300 per response

### 🔵 react-virtuoso  
Senior React specialist. Optimizes components, state management, and rendering.
- Modern patterns (RSC, Suspense)
- Performance-first approach
- Framework-aware (Next.js, Vite)
- Token budget: 300 per response

### ⚪ git-wizard
Elite Git workflow engineer. Handles commits, conflicts, and emergencies.
- Professional commit messages
- Conflict resolution patterns
- Emergency procedures
- Token budget: 300 per response

## Workflow Modes

### Standard Mode (Default)
```
/epc [task]
```
**Token Budget:** 300 total (100 per phase)
- **Explore:** Identify issue via pattern matching
- **Plan:** Direct solution, no alternatives  
- **Code:** Execute and show metrics

**Output:**
```
Explore: O(n²) search, 3s blocking
Plan: Map lookup, Web Worker
Code: userSearch.js, 3s→50ms
```

### Quick Mode
```
/epc quick [task]
```
**Token Budget:** 100 total
- Skip exploration
- Apply instant pattern
- Report metrics only

**Output:**
```
Applied: React.memo to ProductList
Impact: 1000 rerenders→1
```

### Architect Mode
```
/epc architect [task]
```
**Token Budget:** 200 total
- Structure decisions only
- Bullet points
- Critical trade-offs only

**Output:**
```
Structure:
→ /services (api, transforms)
→ /components (ui)
→ /hooks (logic)
Start: services
```

### Emergency Mode
```
/epc emergency [task]
```
**Token Budget:** 50 total
- Triggered by "emergency" or "production down"
- Revert or patch only
- Skip all analysis

**Output:**
```
Reverted: commit a3f2b1
Deployed: hotfix
```

## Override Dictionary

Magic words that modify behavior:

| Keyword | Effect | Token Cost |
|---------|--------|------------|
| `explain` | Add Why: and Impact: lines | +50 |
| `analyze` | Structured analysis box | +200 |
| `debug` | Add console.log statements | +0 |
| `typescript` | Use TypeScript mode | +0 |
| `emergency` | Skip all checks | -200 |
| `all`/`everything` | Allow bulk operations | +0 |

### Explain Format (50 tokens)
```
Added: Virtual scrolling
Why: Rendered all 500 items
Impact: 4s→200ms initial load
```

### Analyze Format (200 tokens)
```
ANALYSIS: Memory leak
━━━━━━━━━━━━━━━━━━━━━━━━
Heap: 50MB→500MB over 5min
Leak: Event listeners
Location: useEffect (6 components)
━━━━━━━━━━━━━━━━━━━━━━━━
Fix: Add cleanup functions
Result: Stable 50MB
```

## Instant Patterns

Common issues resolved without exploration:

| Pattern | Solution | Agent |
|---------|----------|-------|
| Slow list | React.memo + key | react-virtuoso |
| `undefined is not a function` | Optional chaining | js-specialist |
| Merge conflict | Keep current, continue | git-wizard |
| Memory leak | WeakMap/cleanup | js-specialist |
| Props drilling | Context/composition | react-virtuoso |
| `Maximum call stack` | Remove recursion | js-specialist |
| Too many renders | useMemo/useCallback | react-virtuoso |

## Token Efficiency Rules

1. **No code in responses** - Write directly to files
2. **Summaries only** - File: change, metric
3. **Pattern first** - Check instant patterns before analyzing
4. **One solution** - First working solution, not best
5. **No justification** - Unless "explain" keyword used

## Examples

### Performance Optimization
```bash
/epc optimize dashboard loading time

Explore: Bundle 2.4MB, React 247 renders/min
Plan: Code split, memo selectors  
Code: 5 lazy routes, 3 memoized contexts, 2.4MB→800KB
```

### Bug Fix
```bash
/epc quick fix "Cannot read property 'map' of undefined"

Applied: Optional chaining to all array.map calls
Files: UserList.jsx, Products.jsx, Cart.jsx
```

### Architecture
```bash
/epc architect typescript restructure monolithic api.js

Structure:
→ /endpoints (routes)
→ /services (business)
→ /validators (schemas)
→ /types (interfaces)
Migration: No breaking changes
```

### Production Emergency
```bash
/epc emergency fix payment processing crash

Reverted: Latest deploy
Rolled back: DB migration
Status: System stable
```

### With Analysis
```bash
/epc analyze investigate slow checkout

ANALYSIS: Checkout performance
━━━━━━━━━━━━━━━━━━━━━━━━
API calls: 6 sequential (3s)
Renders: 47/interaction
Blocking: Tax calculation
━━━━━━━━━━━━━━━━━━━━━━━━
Fix: Parallel APIs, memo cart
Result: 3s→500ms, 47→3 renders
```

## Setup

1. Copy all `.md` files to your Claude Code project
2. Each agent operates independently
3. EPC coordinates multi-agent workflows
4. Agents write code directly to files

## Philosophy

- **Speed over perfection** - First working solution
- **Patterns over analysis** - Common problems have common fixes
- **Metrics over explanations** - Show impact, not reasoning
- **Token efficiency over completeness** - Stay under limits

## Anti-Patterns

Things EPC explicitly avoids:

❌ Long explanations of approach  
❌ Showing code in responses  
❌ Multiple options/alternatives  
❌ Justifying decisions  
❌ Over-analyzing simple problems  
❌ Perfect architecture on first try  
❌ Comprehensive documentation  
❌ Premature optimization

## Rate Limit Management

With EPC's token efficiency:
- **Standard workflow:** ~300 tokens = 100+ interactions before limit
- **Quick mode:** ~100 tokens = 300+ interactions  
- **Without EPC:** ~2000-5000 tokens = 10-20 interactions

## Contributing

This workflow is optimized for Claude Code. Contributions should maintain:
- Token efficiency (300 per response max)
- Pattern-first approach
- Clear override triggers
- No overthinking principle

## License

MIT - Use freely in your Claude Code projects

---

*Built for developers who value speed over philosophy, results over explanations, and staying under rate limits.*
