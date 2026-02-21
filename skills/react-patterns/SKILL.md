---
name: react-patterns
description: |
  React performance, accessibility, and state management patterns.
  Use when optimizing renders, fixing re-render issues, implementing accessibility,
  or user mentions "re-render", "React.memo", "useCallback", "context", "a11y", "WCAG".
  Complements react-virtuoso agent with ready-to-use patterns.
metadata:
  author: Gabo
  version: 1.0.0
  companion-agent: react-virtuoso
---

# React Optimization Patterns

Production-grade patterns for performance and accessibility.

---

## Render Optimization

### React.memo with Custom Comparator

```javascript
// Standard memo (shallow compare)
const UserCard = React.memo(({ user, onSelect }) => (
  <div onClick={() => onSelect(user.id)}>{user.name}</div>
));

// Custom comparator (deep control)
const UserCard = React.memo(
  ({ user, onSelect }) => (
    <div onClick={() => onSelect(user.id)}>{user.name}</div>
  ),
  (prev, next) => prev.user.id === next.user.id
);
```

### useCallback for Stable References

```javascript
// ❌ New function every render
<UserCard onSelect={(id) => handleSelect(id)} />

// ✅ Stable reference
const handleSelect = useCallback((id) => {
  setSelected(id);
}, []);

<UserCard onSelect={handleSelect} />
```

### useMemo for Expensive Computations

```javascript
// ❌ Recomputes every render
const filtered = users.filter(u => u.active);

// ✅ Memoized
const filtered = useMemo(
  () => users.filter(u => u.active),
  [users]
);
```

### Derived State (No useEffect)

```javascript
// ❌ Extra render cycle
const [items, setItems] = useState([]);
const [filtered, setFiltered] = useState([]);

useEffect(() => {
  setFiltered(items.filter(i => i.active));
}, [items]);

// ✅ Derive during render
const [items, setItems] = useState([]);
const filtered = useMemo(() => items.filter(i => i.active), [items]);
```

---

## Context Optimization

### Split Context by Update Frequency

```javascript
// ❌ Single context - everything re-renders
const AppContext = createContext({ user, theme, settings });

// ✅ Split contexts
const UserContext = createContext(null);      // Rarely changes
const ThemeContext = createContext(null);     // User toggles
const SettingsContext = createContext(null);  // Settings page only
```

### Context + Memo Pattern

```javascript
// Provider
function UserProvider({ children }) {
  const [user, setUser] = useState(null);
  const value = useMemo(() => ({ user, setUser }), [user]);
  
  return (
    <UserContext.Provider value={value}>
      {children}
    </UserContext.Provider>
  );
}

// Consumer (memoized)
const UserCard = React.memo(function UserCard() {
  const { user } = useContext(UserContext);
  return <div>{user.name}</div>;
});
```

### Selector Pattern (Avoid Re-renders)

```javascript
// Custom hook with selector
function useUser(selector) {
  const context = useContext(UserContext);
  return useMemo(() => selector(context), [context, selector]);
}

// Usage - only re-renders when user.name changes
const userName = useUser(ctx => ctx.user.name);
```

---

## State Management Patterns

### useReducer for Complex State

```javascript
const initialState = { items: [], filter: 'all', page: 1 };

function reducer(state, action) {
  switch (action.type) {
    case 'SET_FILTER':
      return { ...state, filter: action.payload, page: 1 };
    case 'SET_PAGE':
      return { ...state, page: action.payload };
    case 'ADD_ITEM':
      return { ...state, items: [...state.items, action.payload] };
    default:
      return state;
  }
}

const [state, dispatch] = useReducer(reducer, initialState);
```

### State Colocation

```javascript
// ❌ Lifted too high
function App() {
  const [searchInput, setSearchInput] = useState(''); // Only SearchBox needs this
  return <SearchBox value={searchInput} onChange={setSearchInput} />;
}

// ✅ Colocated
function App() {
  return <SearchBox />; // SearchBox owns its input state
}

function SearchBox() {
  const [input, setInput] = useState('');
  return <input value={input} onChange={e => setInput(e.target.value)} />;
}
```

---

## Accessibility Patterns

### Semantic HTML First

```javascript
// ❌ Div with click handler
<div onClick={handleClick}>Click me</div>

// ✅ Button
<button onClick={handleClick}>Click me</button>
```

### ARIA Labels

```javascript
// Icon-only button
<button aria-label="Close modal" onClick={onClose}>
  <CloseIcon />
</button>

// Expandable section
<button 
  aria-expanded={isOpen} 
  aria-controls="panel-1"
  onClick={toggle}
>
  Details
</button>
<div id="panel-1" hidden={!isOpen}>Content</div>
```

### Focus Management

```javascript
function Modal({ isOpen, onClose, children }) {
  const closeRef = useRef();
  
  useEffect(() => {
    if (isOpen) closeRef.current?.focus();
  }, [isOpen]);
  
  return isOpen ? (
    <div role="dialog" aria-modal="true">
      <button ref={closeRef} onClick={onClose}>Close</button>
      {children}
    </div>
  ) : null;
}
```

### Keyboard Navigation

```javascript
function Menu({ items }) {
  const [activeIndex, setActiveIndex] = useState(0);
  
  const handleKeyDown = (e) => {
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        setActiveIndex(i => Math.min(i + 1, items.length - 1));
        break;
      case 'ArrowUp':
        e.preventDefault();
        setActiveIndex(i => Math.max(i - 1, 0));
        break;
      case 'Enter':
        items[activeIndex].onClick();
        break;
    }
  };
  
  return (
    <ul role="menu" onKeyDown={handleKeyDown}>
      {items.map((item, i) => (
        <li 
          key={item.id}
          role="menuitem"
          tabIndex={i === activeIndex ? 0 : -1}
        >
          {item.label}
        </li>
      ))}
    </ul>
  );
}
```

### Skip Link

```javascript
// At top of app
<a href="#main-content" className="skip-link">
  Skip to main content
</a>

// CSS
.skip-link {
  position: absolute;
  left: -10000px;
}
.skip-link:focus {
  left: 0;
}
```

---

## Anti-Patterns

### useEffect for Derived State

```javascript
// ❌ Extra render, stale state possible
useEffect(() => {
  setTotal(items.reduce((sum, i) => sum + i.price, 0));
}, [items]);

// ✅ useMemo
const total = useMemo(
  () => items.reduce((sum, i) => sum + i.price, 0),
  [items]
);
```

### Prop Drilling >3 Levels

```javascript
// ❌ Props passed through 4+ components
<App user={user}>
  <Layout user={user}>
    <Sidebar user={user}>
      <UserMenu user={user} />
    </Sidebar>
  </Layout>
</App>

// ✅ Context
<UserContext.Provider value={user}>
  <App>
    <Layout>
      <Sidebar>
        <UserMenu /> {/* useContext(UserContext) */}
      </Sidebar>
    </Layout>
  </App>
</UserContext.Provider>
```

### Missing Error Boundaries

```javascript
// ✅ Wrap feature routes
class ErrorBoundary extends Component {
  state = { hasError: false };
  
  static getDerivedStateFromError() {
    return { hasError: true };
  }
  
  componentDidCatch(error, info) {
    logError(error, info);
  }
  
  render() {
    if (this.state.hasError) {
      return <ErrorFallback onRetry={() => this.setState({ hasError: false })} />;
    }
    return this.props.children;
  }
}
```

---

## Virtualization (Large Lists)

```javascript
import { FixedSizeList } from 'react-window';

function VirtualList({ items }) {
  return (
    <FixedSizeList
      height={400}
      width="100%"
      itemCount={items.length}
      itemSize={50}
    >
      {({ index, style }) => (
        <div style={style}>
          <UserCard user={items[index]} />
        </div>
      )}
    </FixedSizeList>
  );
}
```

---

## Performance Checklist

- [ ] React Profiler flamegraph
- [ ] Identify components with >16ms renders
- [ ] Check for unnecessary re-renders (Profiler Ranked view)
- [ ] Verify memo'd components have stable props
- [ ] Audit context usage for over-subscription
- [ ] Test with React.StrictMode double-render

---

## WCAG 2.1 AA Checklist

- [ ] All interactive elements keyboard accessible
- [ ] Color contrast ratio ≥4.5:1 (text), ≥3:1 (large text)
- [ ] Focus indicators visible
- [ ] ARIA labels on icon-only buttons
- [ ] Form inputs have associated labels
- [ ] Error messages announced to screen readers
- [ ] Skip link for main content
- [ ] No keyboard traps
- [ ] axe DevTools shows 0 violations
