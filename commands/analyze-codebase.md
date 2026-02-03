---
name: analyze-codebase
description: Deep analysis of the entire codebase to generate a comprehensive CLAUDE.md file with project-specific context, critical paths, and keyword mappings.
---

# Codebase Analysis for CLAUDE.md

Analyze this entire codebase and generate a comprehensive CLAUDE.md file that gives future Claude sessions deep context about this specific project.

## Analysis Steps

### Step 1: Dependency Scan
```bash
# Read package.json for tech stack
cat package.json

# Check for monorepo
ls -la packages/ 2>/dev/null || ls -la apps/ 2>/dev/null

# Find config files
fd -t f -d 1 "config|rc|.env"
```

### Step 2: Entry Point Trace
```bash
# Find entry points
fd -t f "(index|main|app)\.(js|ts|jsx|tsx)$" src/

# Check for framework-specific entries
ls -la src/pages/_app.* 2>/dev/null  # Next.js
ls -la src/App.* 2>/dev/null          # CRA/Vite
ls -la src/main.* 2>/dev/null         # Vite
```

### Step 3: Architecture Discovery
```bash
# Folder structure (2 levels)
tree -L 2 -d src/ 2>/dev/null || find src -type d -maxdepth 2

# Find all components
fd -t f "\.(jsx|tsx)$" src/components/ | head -30

# Find services/API layer
fd -t f "\.(js|ts)$" src/services/ src/api/ src/lib/ 2>/dev/null

# Find state management
rg -l "createContext|createStore|createSlice|atom\(|create\(" src/ --type ts --type js | head -10

# Find hooks
fd -t f "use[A-Z].*\.(js|ts)$" src/
```

### Step 4: Critical Path Detection
```bash
# Auth-related files
rg -l "login|logout|auth|token|session" src/ --type ts --type js | head -10

# Payment/checkout
rg -l "payment|checkout|stripe|cart|order" src/ --type ts --type js | head -10

# API calls
rg -l "fetch\(|axios|useSWR|useQuery" src/ --type ts --type js | head -10
```

### Step 5: Complexity Hotspots
```bash
# Largest files (often complex)
find src -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" | xargs wc -l 2>/dev/null | sort -rn | head -15

# Most imported files (high dependency = high risk)
rg "^import.*from ['\"]\.\.?/" src/ --type ts --type js -o | sed "s/.*from ['\"]//;s/['\"].*//" | sort | uniq -c | sort -rn | head -10

# Files with many imports (complex dependencies)
for f in $(fd -e ts -e tsx -e js -e jsx . src/); do echo "$(rg "^import" "$f" | wc -l) $f"; done | sort -rn | head -10
```

### Step 6: Test Coverage Map
```bash
# Find test files
fd -t f "\.(test|spec)\.(js|ts|jsx|tsx)$" 

# Check test config
cat jest.config.* 2>/dev/null || cat vitest.config.* 2>/dev/null

# Find untested critical files (components without .test file)
for f in $(fd -e tsx -e jsx . src/components/); do
  testfile="${f%.*}.test.${f##*.}"
  [ ! -f "$testfile" ] && echo "NO TEST: $f"
done | head -10
```

### Step 7: Convention Detection
```bash
# Import style (barrel files?)
ls src/components/index.* 2>/dev/null && echo "Uses barrel files"

# Path aliases
rg "paths|alias" tsconfig.json vite.config.* 2>/dev/null

# Naming conventions (sample)
ls src/components/ | head -10
```

## What to Extract

### 1. Architecture Map
- Entry points (where the app starts)
- Core modules and their responsibilities
- Data flow (where state lives, how it moves)
- API boundaries (what talks to backend)
- Shared utilities (what gets imported everywhere)

### 2. Critical Paths (break these = break the app)
- Authentication flow (files, functions, edge cases)
- Payment/checkout (if exists)
- Core business logic (the thing this app actually does)
- Data mutations (what writes to DB/API)

### 3. Fragile Areas (known pain points)
- Files with lots of dependencies
- Complex state management
- Race conditions or async complexity
- Large files (>300 lines)
- Files imported by many others

### 4. Project Conventions
- File naming patterns
- Import style (barrel files, path aliases)
- State management approach
- Error handling patterns
- Testing patterns

### 5. Keyword → Context Triggers
Create mappings for project-specific terms:

```markdown
## Keyword Glossary

| Term | Means | Location |
|------|-------|----------|
| "the form" | Main checkout form | `src/components/CheckoutForm.jsx` |
| "user state" | Auth context + hooks | `src/contexts/UserContext.tsx` |
| "the API" | Axios instance | `src/services/api.ts` |
| "dashboard" | Main analytics view | `src/pages/Dashboard.jsx` |
```

### 6. File Risk Ranking
- **Critical** (breaks app if wrong)
- **Important** (core features)
- **Standard** (normal code)
- **Safe** (low risk to refactor)

## Output: CLAUDE.md

Generate this file at project root:

```markdown
# Project: [Name from package.json]

## Quick Context
[What this app does in 2-3 sentences. Main framework. Key dependencies.]

## Tech Stack
- Framework: [React/Next/Vue/etc]
- State: [Redux/Zustand/Context/etc]
- Styling: [Tailwind/CSS Modules/styled-components/etc]
- Testing: [Jest/Vitest + RTL/etc]
- Build: [Vite/Webpack/Next/etc]

## Architecture

```
src/
├── components/    # UI components
├── pages/         # Route pages
├── hooks/         # Custom hooks
├── contexts/      # React contexts
├── services/      # API layer
├── utils/         # Helpers
└── types/         # TypeScript types
```

[Describe how data flows: User action → Component → Hook/Context → API → State update]

## Critical Paths

### Authentication
- Files: [list actual files]
- Flow: [describe login/logout/session flow]
- Watch out: [edge cases, token refresh, etc]

### [Core Feature Name]
- Files: [list actual files]
- Flow: [describe the flow]
- Watch out: [known issues]

## Keyword Glossary

When I say... | I mean... | Located at
--------------|-----------|------------
"the form" | [specific form] | `path/to/file`
"user state" | [auth/user context] | `path/to/file`
"slow page" | [known perf issue] | `path/to/file`
[add project-specific terms]

## Conventions

### File Naming
- Components: [PascalCase.tsx / kebab-case.tsx]
- Hooks: [useFeatureName.ts]
- Utils: [camelCase.ts]

### Imports
- Path aliases: [@ → src/, etc]
- Barrel files: [yes/no, where]

### State Management
- Global state: [tool + location]
- Server state: [React Query/SWR/etc]
- Local state: [useState patterns]

### Error Handling
- API errors: [how they're caught]
- UI errors: [error boundaries location]

## Known Issues / Tech Debt

| Issue | Location | Risk | Notes |
|-------|----------|------|-------|
| [describe issue] | `path/to/file` | High/Med/Low | [context] |

## Testing

### Running Tests
```bash
[actual test command]
```

### Coverage
- Well tested: [list files/folders]
- Needs tests: [list files/folders]
- Known flaky: [list if any]

## File Risk Map

### Critical (don't touch without tests)
- `path/to/critical/file.ts` - [why it's critical]

### Important (core features)
- `path/to/important/file.ts` - [what it does]

### Safe to Refactor
- `path/to/safe/file.ts` - [low dependencies]

## Build & Environment

### Scripts
```bash
npm run dev      # [what it does]
npm run build    # [what it does]
npm run test     # [what it does]
```

### Environment Variables
- `VITE_API_URL` - [what it's for]
- [list others from .env.example]
```

## Execution

1. Run all analysis commands above
2. Read key files identified
3. Generate CLAUDE.md with actual paths, actual file names, actual patterns
4. Be specific—this should read like notes from a senior dev who knows this codebase

**Do not generalize. Use real file paths. Name real functions. Be specific to THIS project.**
