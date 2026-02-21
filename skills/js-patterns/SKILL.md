---
name: js-patterns
description: |
  JavaScript/TypeScript performance patterns and anti-patterns reference.
  Use when optimizing code, fixing memory leaks, improving algorithms, or 
  user mentions "slow", "performance", "O(n)", "memory", "optimization".
  Complements javascript-specialist agent with ready-to-use patterns.
metadata:
  author: Gabo
  version: 1.0.0
  companion-agent: javascript-specialist
---

# JavaScript Performance Patterns

Quick reference for production-grade JavaScript patterns.

---

## Algorithm Complexity Fixes

### O(n²) → O(1) Array Lookup

```javascript
// ❌ O(n²) - nested loops with includes
const common = arr1.filter(a => arr2.includes(a.id));

// ✅ O(n) - Set index
const idSet = new Set(arr2.map(b => b.id));
const common = arr1.filter(a => idSet.has(a.id));
```

### O(n) → O(1) Object Property Access

```javascript
// ❌ O(n) - find in array
const user = users.find(u => u.id === targetId);

// ✅ O(1) - Map index
const userMap = new Map(users.map(u => [u.id, u]));
const user = userMap.get(targetId);
```

### O(n) → O(1) Frequency Count

```javascript
// ❌ Multiple passes
const count = arr.filter(x => x === target).length;

// ✅ Single pass with Map
const freq = arr.reduce((m, x) => m.set(x, (m.get(x) || 0) + 1), new Map());
const count = freq.get(target) || 0;
```

---

## Async Patterns

### Parallel Execution (Independent Tasks)

```javascript
// ❌ Sequential - slow
const user = await getUser(id);
const posts = await getPosts(id);
const comments = await getComments(id);

// ✅ Parallel - fast
const [user, posts, comments] = await Promise.all([
  getUser(id),
  getPosts(id),
  getComments(id)
]);
```

### Serial Execution (Dependent Tasks)

```javascript
// ✅ When order matters
const user = await getUser(id);
const permissions = await getPermissions(user.role);
const data = await getData(permissions.scope);
```

### Retry with Exponential Backoff

```javascript
async function fetchWithRetry(url, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fetch(url);
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      await new Promise(r => setTimeout(r, Math.pow(2, i) * 1000));
    }
  }
}
```

### Cancellable Fetch

```javascript
function createCancellableFetch(url) {
  const controller = new AbortController();
  const promise = fetch(url, { signal: controller.signal });
  return { promise, cancel: () => controller.abort() };
}

// Usage: const { promise, cancel } = createCancellableFetch('/api');
// On unmount: cancel();
```

### Debounce

```javascript
function debounce(fn, delay) {
  let timeoutId;
  return (...args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  };
}

// Usage: const debouncedSearch = debounce(search, 300);
```

### Throttle

```javascript
function throttle(fn, limit) {
  let inThrottle;
  return (...args) => {
    if (!inThrottle) {
      fn(...args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
}

// Usage: const throttledScroll = throttle(onScroll, 100);
```

---

## Memory Leak Prevention

### Event Listener Cleanup

```javascript
// ❌ Leak - no cleanup
useEffect(() => {
  window.addEventListener('resize', handler);
}, []);

// ✅ Cleanup
useEffect(() => {
  window.addEventListener('resize', handler);
  return () => window.removeEventListener('resize', handler);
}, []);
```

### Timer Cleanup

```javascript
// ❌ Leak - interval never cleared
useEffect(() => {
  setInterval(poll, 1000);
}, []);

// ✅ Cleanup
useEffect(() => {
  const id = setInterval(poll, 1000);
  return () => clearInterval(id);
}, []);
```

### AbortController for Fetch

```javascript
useEffect(() => {
  const controller = new AbortController();
  
  fetch('/api/data', { signal: controller.signal })
    .then(setData)
    .catch(e => {
      if (e.name !== 'AbortError') throw e;
    });
  
  return () => controller.abort();
}, []);
```

---

## Anti-Patterns

### delete on Objects (Hidden Class Deopt)

```javascript
// ❌ Changes hidden class, slows V8
delete obj.property;

// ✅ Keeps shape
obj.property = undefined;
// or
const { property, ...rest } = obj;
```

### JSON.parse Without Try-Catch

```javascript
// ❌ Crashes on malformed JSON
const data = JSON.parse(response);

// ✅ Safe parsing
let data;
try {
  data = JSON.parse(response);
} catch {
  data = null;
}
```

### Functions in Loops

```javascript
// ❌ Creates new function each iteration
elements.forEach(el => {
  el.addEventListener('click', () => handleClick(el));
});

// ✅ Event delegation
container.addEventListener('click', e => {
  if (e.target.matches('.item')) handleClick(e.target);
});
```

### Synchronous localStorage in Hot Path

```javascript
// ❌ Blocks main thread
const data = JSON.parse(localStorage.getItem('data'));

// ✅ Cache in memory
let cache = null;
function getData() {
  if (!cache) cache = JSON.parse(localStorage.getItem('data'));
  return cache;
}
```

---

## Data Structure Selection

| Use Case | Structure | Why |
|----------|-----------|-----|
| Unique values | `Set` | O(1) has/add/delete |
| Key-value with any key type | `Map` | O(1) get/set, preserves order |
| Key-value with string keys | `Object` | Slightly faster for string keys |
| Ordered collection | `Array` | Index access, iteration |
| FIFO queue | `Array` with shift/push | Built-in, good for small queues |
| LIFO stack | `Array` with pop/push | Built-in |
| Priority queue | Custom heap | No built-in, implement or use library |

---

## Performance Budgets

| Metric | Target | Investigate | Critical |
|--------|--------|-------------|----------|
| Bundle (initial) | <200KB | >300KB | >500KB |
| Bundle (chunk) | <50KB | >75KB | >100KB |
| Interaction | <100ms | >200ms | >500ms |
| Animation frame | <16ms | >33ms | >100ms |
| Memory (app) | <100MB | >200MB | >500MB |
| Memory (heap growth) | 0 | >10MB/min | >50MB/min |

---

## Profiling Checklist

- [ ] Chrome DevTools Performance tab recording
- [ ] Identify longest tasks (>50ms)
- [ ] Check for forced synchronous layouts
- [ ] Memory heap snapshots before/after
- [ ] Network waterfall for request chaining
- [ ] Lighthouse score baseline

---

## When NOT to Optimize

- Arrays <50 items: O(n²) is fine
- Code that runs once at startup
- Development-only code
- Code without profiler evidence of bottleneck
- Premature optimization without measurements
