# Examples

Real-world code examples demonstrating the four principles. Each example shows what LLMs commonly do wrong and how to fix it.

Examples use JavaScript/TypeScript and React, the stack these guidelines were tuned for. The principles themselves are language-agnostic.

---

## 1. Think Before Coding

### Example 1: Hidden Assumptions

**User Request:** "Add a feature to export user data"

**❌ What LLMs Do (Wrong Assumptions)**

```javascript
async function exportUsers(format = 'json') {
  const users = await api.get('/users');

  if (format === 'json') {
    const blob = new Blob([JSON.stringify(users)], { type: 'application/json' });
    triggerDownload(blob, 'users.json');
  } else if (format === 'csv') {
    const csv = ['id,email,name', ...users.map(u => `${u.id},${u.email},${u.name}`)].join('\n');
    const blob = new Blob([csv], { type: 'text/csv' });
    triggerDownload(blob, 'users.csv');
  }

  return `Exported ${users.length} users`;
}
```

**Problems:**
- Assumed it should export ALL users (what about pagination? privacy?)
- Assumed which fields to include (some might be sensitive: auth tokens, internal IDs)
- Assumed CSV column names without checking actual data structure
- Assumed the user has permission to export every user
- Assumed `triggerDownload` exists (and works the same across browsers)

**✅ What Should Happen (Surface Assumptions)**

```
Before implementing, I need to clarify:

1. **Scope**: Export all users or filtered subset? (privacy + permission implications)
2. **Where the data comes from**:
   - Existing list already loaded in the UI?
   - New API call that returns export-shaped data?
   - Backend-generated file (link to download)?
3. **Fields**: Which user fields? Some might be sensitive — should the API
   return a sanitized "export view" instead of the raw user object?
4. **Volume**: How many users typically? Affects approach:
   - <1k: build CSV in browser, blob download
   - 1k–100k: stream from backend
   - 100k+: backend job + email link

Simplest approach for typical sizes: backend returns sanitized export data,
frontend builds the Blob and triggers download.

What's your situation?
```

### Example 2: Multiple Interpretations

**User Request:** "Make the search faster"

**❌ What LLMs Do (Pick Silently)**

```javascript
// Adds debouncing, memoization, server-side caching, AND virtualization
// without asking which "faster" matters
const useSearch = (query) => {
  const debouncedQuery = useDebounce(query, 300);
  const memoizedResults = useMemo(() => /* ... */, [debouncedQuery]);
  // ...200 lines of optimization code
};
```

**✅ What Should Happen**

```
"Make the search faster" could mean:

1. **Faster response time** (server returns results in <100ms instead of 500ms)
   - Add backend index, cache frequent queries
   - Estimated effort: 2 hours

2. **Faster perceived speed** (UX feels instant)
   - Debounce input, optimistic UI, show partial results
   - Estimated effort: 3 hours

3. **Less re-rendering** (typing doesn't lag the UI)
   - Memo the result list, virtualize long results
   - Estimated effort: 2 hours

4. **Smaller payload** (less data over the wire)
   - Return only fields the UI uses, paginate
   - Estimated effort: 1 hour

Current search: ~500ms server time, ~50ms render time.
Which aspect matters most for your use case?
```

---

## 2. Simplicity First

### Example 1: Over-abstraction

**User Request:** "Add a function to calculate discount"

**❌ What LLMs Do (Overengineered)**

```typescript
interface DiscountStrategy {
  calculate(amount: number): number;
}

class PercentageDiscount implements DiscountStrategy {
  constructor(private percentage: number) {}
  calculate(amount: number): number {
    return amount * (this.percentage / 100);
  }
}

class FixedDiscount implements DiscountStrategy {
  constructor(private fixedAmount: number) {}
  calculate(amount: number): number {
    return Math.min(this.fixedAmount, amount);
  }
}

interface DiscountConfig {
  strategy: DiscountStrategy;
  minPurchase?: number;
  maxDiscount?: number;
}

class DiscountCalculator {
  constructor(private config: DiscountConfig) {}

  applyDiscount(amount: number): number {
    if (amount < (this.config.minPurchase ?? 0)) return 0;
    const discount = this.config.strategy.calculate(amount);
    return Math.min(discount, this.config.maxDiscount ?? Infinity);
  }
}

// Usage requires 30+ lines of setup for a simple calculation
```

**✅ What Should Happen (Simple)**

```javascript
function calculateDiscount(amount, percent) {
  return amount * (percent / 100);
}

// Usage
const discount = calculateDiscount(100, 10); // $10 off
```

**When to add complexity:** only when you actually need multiple discount types. If that requirement comes later, refactor then.

### Example 2: Speculative Features

**User Request:** "Save user preferences to the API"

**❌ What LLMs Do (Unnecessary Features)**

```javascript
class PreferencesManager {
  constructor({ api, cache, validator, eventBus } = {}) {
    this.api = api;
    this.cache = cache ?? new InMemoryCache();
    this.validator = validator ?? new DefaultValidator();
    this.eventBus = eventBus;
  }

  async save(userId, prefs, { merge = true, validate = true, notify = false } = {}) {
    if (validate) {
      const errors = this.validator.validate(prefs);
      if (errors.length) throw new ValidationError(errors);
    }

    const existing = merge ? await this.get(userId) : {};
    const merged = merge ? { ...existing, ...prefs } : prefs;

    await this.api.put(`/users/${userId}/preferences`, merged);

    if (this.cache) {
      this.cache.set(`prefs:${userId}`, merged);
    }

    if (notify && this.eventBus) {
      this.eventBus.emit('preferences:changed', { userId, prefs: merged });
    }

    return true;
  }

  // Another 30 lines for features nobody asked for
}
```

**✅ What Should Happen (Just What Was Asked)**

```javascript
async function savePreferences(userId, preferences) {
  await api.put(`/users/${userId}/preferences`, preferences);
}
```

**Add later if needed:** caching (when you hit the API too often), validation (when bad data appears), merging (when partial updates become a real requirement), eventing (when other components actually need to react).

---

## 3. Surgical Changes

### Example 1: Drive-by Refactoring

**User Request:** "Fix the bug where empty emails crash the validator"

**❌ What LLMs Do (Too Much)**

```diff
  function validateUser(userData) {
-     // Check email format
-     if (!userData.email) {
+     // Validate user data
+     const email = (userData.email ?? '').trim();
+
+     // Validate email
+     if (!email) {
          throw new Error('Email required');
      }
-
-     // Basic email validation
-     if (!userData.email.includes('@')) {
+     if (!email.includes('@') || !email.split('@')[1].includes('.')) {
          throw new Error('Invalid email');
      }

-     // Check username
-     if (!userData.username) {
+     // Validate username
+     const username = (userData.username ?? '').trim();
+     if (!username) {
          throw new Error('Username required');
      }
+     if (username.length < 3) {
+         throw new Error('Username too short');
+     }
+     if (!/^[a-zA-Z0-9]+$/.test(username)) {
+         throw new Error('Username must be alphanumeric');
+     }

      return true;
  }
```

**Problems:**
- "Improved" email validation beyond the bug fix
- Added username length and format validation nobody asked for
- Changed comments
- Added trimming to fields that weren't broken

**✅ What Should Happen (Surgical)**

```diff
  function validateUser(userData) {
      // Check email format
-     if (!userData.email) {
+     const email = userData.email;
+     if (!email || !email.trim()) {
          throw new Error('Email required');
      }

      // Basic email validation
-     if (!userData.email.includes('@')) {
+     if (!email.includes('@')) {
          throw new Error('Invalid email');
      }

      // Check username
      if (!userData.username) {
          throw new Error('Username required');
      }

      return true;
  }
```

**Only changed:** the specific lines that fix empty/whitespace email handling.

### Example 2: Style Drift

**User Request:** "Add logging to the API client"

**❌ What LLMs Do (Reformat Everything)**

```diff
- export function fetchUser(userId) {
+ export async function fetchUser(userId: string): Promise<User | null> {
+     logger.info(`Fetching user ${userId}`);
+
      try {
-         const response = await fetch(`/api/users/${userId}`);
+         const response = await fetch(`/api/users/${userId}`, {
+             method: "GET",
+             headers: {
+                 "Content-Type": "application/json",
+             },
+         });
-
-         if (response.status === 200) {
-             const data = await response.json();
-             return data;
+
+         const success = response.ok;
+         if (success) {
+             const data: User = await response.json();
+             logger.info(`Fetched user ${userId} successfully`);
+             return data;
          } else {
-             return null;
+             logger.error(`Fetch failed for user ${userId}, status=${response.status}`);
+             return null;
          }
      } catch (err) {
-         console.log('Error: ' + err);
+         logger.exception(`Fetch error for user ${userId}: ${err}`);
          return null;
      }
  }
```

**Problems:**
- Changed quote style (`''` to `""`)
- Added TypeScript annotations nobody asked for
- Added explicit `method` and `headers` that weren't there
- Reformatted whitespace and structure
- Renamed/added intermediate variables (`success` boolean)

**✅ What Should Happen (Match Existing Style)**

```diff
+ import { logger } from './logger';
+
  export function fetchUser(userId) {
+     logger.info(`Fetching user ${userId}`);
      try {
          const response = await fetch(`/api/users/${userId}`);

          if (response.status === 200) {
              const data = await response.json();
+             logger.info(`Fetched user ${userId} successfully`);
              return data;
          } else {
+             logger.error(`Fetch failed for user ${userId}, status=${response.status}`);
              return null;
          }
      } catch (err) {
-         console.log('Error: ' + err);
+         logger.exception(`Fetch error for user ${userId}`, err);
          return null;
      }
  }
```

**Matched:** single quotes, no type annotations, existing variable patterns, minimal fetch options.

---

## 4. Goal-Driven Execution

### Example 1: Vague vs. Verifiable

**User Request:** "Fix the authentication system"

**❌ What LLMs Do (Vague Approach)**

```
I'll fix the authentication system by:
1. Reviewing the code
2. Identifying issues
3. Making improvements
4. Testing the changes

[Proceeds to make changes without clear success criteria]
```

**✅ What Should Happen (Verifiable Goals)**

```
To "fix authentication," I need to define success criteria.
What specific issue are we solving?

If the issue is "users stay logged in after password change":

Plan:
1. Write test: change password → verify old session invalidated
   Verify: test fails (reproduces bug)

2. Implement: invalidate refresh tokens on password change
   Verify: test passes

3. Edge cases: multiple active sessions, concurrent changes
   Verify: additional tests pass

4. Regression check: existing auth tests still pass
   Verify: full test suite green

Current auth test coverage: [shows coverage]
What's the specific auth issue you're seeing?
```

### Example 2: Multi-Step with Verification

**User Request:** "Add throttling to the search input — it's hitting the API on every keystroke"

**❌ What LLMs Do (All at Once)**

```javascript
// Implements debouncing + request cancellation + result caching + retry on failure
// + loading state + error state + abort on unmount, all in one 200-line hook.
// No clear verification steps.
```

**✅ What Should Happen (Incremental with Verification)**

```
Plan for search throttling:

1. Add basic debouncing (300ms) on the search input
   Verify:
   - Test: typing "react" fires 1 request, not 5
   - Manual: open Network tab, type fast, see one request

2. Add request cancellation (abort previous when new fires)
   Verify:
   - Test: rapid typing → only the last request resolves
   - Network tab shows earlier requests cancelled

3. Add cleanup on unmount
   Verify:
   - Test: unmount mid-request → no state update warning
   - No memory leak on rapid mount/unmount

4. Cache identical queries (optional, only if needed)
   Verify:
   - Test: typing "react", clearing, typing "react" → 1 request, not 2

Each step is independently verifiable and shippable.
Start with step 1?
```

### Example 3: Test-First Verification

**User Request:** "The leaderboard sort breaks when there are duplicate scores"

**❌ What LLMs Do (Fix Without Reproducing)**

```javascript
// Immediately changes sort logic without confirming the bug
function sortScores(scores) {
  return [...scores].sort((a, b) => b.score - a.score || a.name.localeCompare(b.name));
}
```

**✅ What Should Happen (Reproduce First)**

```javascript
// 1. First, write a test that reproduces the issue
test('sortScores produces consistent ordering when scores tie', () => {
  const scores = [
    { name: 'Alice', score: 100 },
    { name: 'Bob', score: 100 },
    { name: 'Charlie', score: 90 },
  ];

  // Run multiple times — order should be deterministic
  const runs = Array.from({ length: 10 }, () => sortScores(scores));
  const first = JSON.stringify(runs[0]);
  expect(runs.every(r => JSON.stringify(r) === first)).toBe(true);

  expect(runs[0][0].score).toBe(100);
  expect(runs[0][1].score).toBe(100);
  expect(runs[0][2].score).toBe(90);
});

// Verify: run test 10 times → fails because tie-breaking is non-deterministic

// 2. Now fix with stable tie-breaker
function sortScores(scores) {
  return [...scores].sort((a, b) =>
    b.score - a.score || a.name.localeCompare(b.name)
  );
}

// Verify: test passes consistently
```

---

## React-Specific Patterns

The four principles apply to React work too. Three quick examples of common pitfalls.

### Surgical Changes — Don't Touch Unrelated Hooks

**User Request:** "Memoize the filtered list — it's recalculating on every keystroke"

**❌ Bad (refactors unrelated code)**

```diff
- function ProductList({ products, query }) {
-   const filtered = products.filter(p => p.name.includes(query));
-   const handleClick = (id) => navigate(`/product/${id}`);
+ const ProductList = React.memo(({ products, query }) => {
+   const filtered = useMemo(
+     () => products.filter(p => p.name.toLowerCase().includes(query.toLowerCase())),
+     [products, query]
+   );
+   const handleClick = useCallback((id) => navigate(`/product/${id}`), [navigate]);
+   const itemRefs = useRef([]);

    return (/* ... */);
- }
+ });
```

**✅ Good (just memoize the filter)**

```diff
  function ProductList({ products, query }) {
-   const filtered = products.filter(p => p.name.includes(query));
+   const filtered = useMemo(
+     () => products.filter(p => p.name.includes(query)),
+     [products, query]
+   );
    const handleClick = (id) => navigate(`/product/${id}`);

    return (/* ... */);
  }
```

The bad version added React.memo, useCallback, case-insensitive matching, and a ref — none requested. The fix was one useMemo.

### Simplicity First — Don't Reach for Context Unprompted

**User Request:** "Pass the current user to UserProfile so it can show the avatar"

**❌ Bad (creates Context for one prop)**

```javascript
// Creates UserContext, UserProvider, useUser hook, wraps the app...
// for a prop that's already two levels away.
```

**✅ Good (just pass the prop)**

```javascript
<Page>
  <UserProfile user={currentUser} />
</Page>
```

Add Context when prop drilling actually hurts — three levels and growing, multiple consumers, frequent updates. Not on the first prop.

### Goal-Driven Execution — Define "Optimized"

**User Request:** "The Dashboard re-renders too much, optimize it"

**❌ Bad (changes things based on guess)**

Adds React.memo to every component, useCallback to every handler, breaks half the equality checks because reference identity changed.

**✅ Good (measure first, define done)**

```
Need React Profiler data first:
- Open DevTools Profiler, record one user interaction
- Share which components show up red/yellow

Without that, "optimize Dashboard" could mean:
- Reduce render count (memoization)
- Reduce render time (split components, virtualize lists)
- Reduce time-to-interactive (code split, defer non-critical)

Once we know which, success criteria become:
- "Dashboard renders <16ms with 50 user cards" (measurable)
- "Typing in search doesn't re-render UserList" (specific)

What does the Profiler show?
```

---

## Anti-Patterns Summary

| Principle | Anti-Pattern | Fix |
|---|---|---|
| Think Before Coding | Silently assumes file format, fields, scope | List assumptions explicitly, ask for clarification |
| Simplicity First | Strategy pattern for single discount calculation | One function until complexity is actually needed |
| Surgical Changes | Reformats quotes, adds types, converts sync→async while fixing a bug | Only change lines that fix the reported issue |
| Goal-Driven Execution | "I'll review and improve the code" | "Write test for bug X → make it pass → verify no regressions" |

## Key Insight

The "overcomplicated" examples aren't obviously wrong — they follow design patterns and best practices. The problem is **timing**: they add complexity before it's needed, which:

- Makes code harder to understand
- Introduces more bugs
- Takes longer to implement
- Harder to test

The "simple" versions are:
- Easier to understand
- Faster to implement
- Easier to test
- Can be refactored later when complexity is actually needed

**Good code is code that solves today's problem simply, not tomorrow's problem prematurely.**
