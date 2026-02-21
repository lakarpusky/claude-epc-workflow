---
name: testing-patterns
description: |
  Jest, React Testing Library, and MSW testing patterns.
  Use when writing tests, fixing flaky tests, improving coverage, or user mentions
  "test", "jest", "RTL", "mock", "coverage", "flaky", "integration test".
  Complements test-sentinel agent with ready-to-use patterns.
metadata:
  author: Gabo
  version: 1.0.0
  companion-agent: test-sentinel
---

# Testing Patterns

Production-grade patterns for Jest + React Testing Library + MSW.

---

## Test Structure (AAA Pattern)

```javascript
test('user can add item to cart', async () => {
  // ARRANGE - Setup
  const { user } = render(<CartPage />);
  
  // ACT - User interaction
  await user.click(screen.getByRole('button', { name: /add to cart/i }));
  
  // ASSERT - Expected outcome
  expect(screen.getByText(/1 item/i)).toBeInTheDocument();
});
```

---

## React Testing Library Queries

### Priority Order (Use First Available)

1. **getByRole** - Accessible roles (button, link, textbox)
2. **getByLabelText** - Form inputs
3. **getByPlaceholderText** - Input placeholders
4. **getByText** - Non-interactive elements
5. **getByDisplayValue** - Current input value
6. **getByAltText** - Images
7. **getByTitle** - Title attribute
8. **getByTestId** - Last resort

### Query Types

| Query | Returns | Throws | Async |
|-------|---------|--------|-------|
| `getBy` | Element | Yes | No |
| `queryBy` | Element/null | No | No |
| `findBy` | Promise | Yes | Yes |
| `getAllBy` | Array | Yes | No |
| `queryAllBy` | Array | No | No |
| `findAllBy` | Promise | Yes | Yes |

### Examples

```javascript
// Buttons
screen.getByRole('button', { name: /submit/i })
screen.getByRole('button', { name: /delete item/i })

// Links
screen.getByRole('link', { name: /home/i })

// Form inputs
screen.getByLabelText(/email/i)
screen.getByRole('textbox', { name: /search/i })
screen.getByRole('checkbox', { name: /agree/i })

// Headings
screen.getByRole('heading', { name: /dashboard/i, level: 1 })

// Async (wait for element)
await screen.findByText(/success/i)
await screen.findByRole('alert')
```

---

## User Events

```javascript
import userEvent from '@testing-library/user-event';

test('form submission', async () => {
  const user = userEvent.setup();
  render(<LoginForm />);
  
  // Type in inputs
  await user.type(screen.getByLabelText(/email/i), 'test@example.com');
  await user.type(screen.getByLabelText(/password/i), 'password123');
  
  // Click submit
  await user.click(screen.getByRole('button', { name: /log in/i }));
  
  // Keyboard
  await user.keyboard('{Enter}');
  await user.keyboard('{Tab}');
  
  // Select dropdown
  await user.selectOptions(screen.getByRole('combobox'), 'option1');
  
  // Clear and type
  await user.clear(screen.getByLabelText(/email/i));
  await user.type(screen.getByLabelText(/email/i), 'new@example.com');
});
```

---

## MSW (Mock Service Worker)

### Setup

```javascript
// mocks/handlers.js
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/users', () => {
    return HttpResponse.json([
      { id: 1, name: 'John' },
      { id: 2, name: 'Jane' }
    ]);
  }),
  
  http.post('/api/users', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({ id: 3, ...body }, { status: 201 });
  }),
];

// mocks/server.js
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);

// jest.setup.js
import { server } from './mocks/server';

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

### Override Handler in Test

```javascript
import { server } from '../mocks/server';
import { http, HttpResponse } from 'msw';

test('displays error when API fails', async () => {
  server.use(
    http.get('/api/users', () => {
      return new HttpResponse(null, { status: 500 });
    })
  );
  
  render(<UserList />);
  
  expect(await screen.findByText(/failed to load/i)).toBeInTheDocument();
});
```

### Simulate Network Delay

```javascript
http.get('/api/users', async () => {
  await delay(2000); // 2 second delay
  return HttpResponse.json(users);
})
```

---

## Custom Render

```javascript
// test-utils.js
import { render } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { Provider } from 'react-redux';
import { configureStore } from '@reduxjs/toolkit';
import userEvent from '@testing-library/user-event';

function renderWithProviders(
  ui,
  {
    preloadedState = {},
    store = configureStore({
      reducer: rootReducer,
      preloadedState
    }),
    route = '/',
    ...renderOptions
  } = {}
) {
  window.history.pushState({}, 'Test page', route);
  
  function Wrapper({ children }) {
    return (
      <Provider store={store}>
        <BrowserRouter>
          {children}
        </BrowserRouter>
      </Provider>
    );
  }
  
  return {
    user: userEvent.setup(),
    store,
    ...render(ui, { wrapper: Wrapper, ...renderOptions })
  };
}

export { renderWithProviders };
```

### Usage

```javascript
import { renderWithProviders } from '../test-utils';

test('shows user dashboard', async () => {
  const { user } = renderWithProviders(<Dashboard />, {
    preloadedState: { user: { name: 'John' } },
    route: '/dashboard'
  });
  
  expect(screen.getByText(/welcome, john/i)).toBeInTheDocument();
});
```

---

## Accessibility Testing

```javascript
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

test('has no accessibility violations', async () => {
  const { container } = render(<UserCard user={mockUser} />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

---

## Performance Testing

```javascript
test('Dashboard renders within 16ms budget', async () => {
  const startTime = performance.now();
  render(<Dashboard users={generateUsers(100)} />);
  const endTime = performance.now();
  
  expect(endTime - startTime).toBeLessThan(16);
});
```

---

## Anti-Patterns

### Testing Implementation Details

```javascript
// ❌ Tests internal state
test('sets isLoading to true', () => {
  const { result } = renderHook(() => useUsers());
  expect(result.current.isLoading).toBe(true);
});

// ✅ Tests user-visible behavior
test('shows loading spinner while fetching', () => {
  render(<UserList />);
  expect(screen.getByRole('progressbar')).toBeInTheDocument();
});
```

### Mocking Internal Modules

```javascript
// ❌ Mocks internal hook
jest.mock('../hooks/useUsers');

// ✅ Mock at network boundary with MSW
server.use(
  http.get('/api/users', () => HttpResponse.json(mockUsers))
);
```

### Not Waiting for Async

```javascript
// ❌ Race condition
render(<UserList />);
expect(screen.getByText(/john/i)).toBeInTheDocument();

// ✅ Wait for element
render(<UserList />);
expect(await screen.findByText(/john/i)).toBeInTheDocument();
```

### Flaky Timing

```javascript
// ❌ Arbitrary wait
await new Promise(r => setTimeout(r, 1000));

// ✅ Wait for condition
await waitFor(() => {
  expect(screen.getByText(/complete/i)).toBeInTheDocument();
});

// ✅ Or use findBy (auto-waits)
expect(await screen.findByText(/complete/i)).toBeInTheDocument();
```

---

## Jest Matchers for DOM

```javascript
// Element existence
expect(element).toBeInTheDocument();
expect(element).not.toBeInTheDocument();

// Visibility
expect(element).toBeVisible();
expect(element).not.toBeVisible();

// Content
expect(element).toHaveTextContent(/welcome/i);
expect(element).toHaveValue('test@example.com');

// Attributes
expect(element).toHaveAttribute('href', '/home');
expect(element).toHaveClass('active');
expect(element).toBeDisabled();
expect(element).toBeChecked();

// Focus
expect(element).toHaveFocus();

// Form validation
expect(element).toBeInvalid();
expect(element).toBeValid();
```

---

## Coverage Configuration

```javascript
// jest.config.js
module.exports = {
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 80,
      statements: 80
    },
    './src/auth/**/*.{js,jsx}': {
      lines: 95
    },
    './src/payments/**/*.{js,jsx}': {
      lines: 95
    }
  }
};
```

---

## Test File Organization

```
src/
├── components/
│   ├── UserCard.jsx
│   └── UserCard.test.jsx      # Co-located tests
├── __tests__/
│   └── integration/
│       └── checkout.test.jsx  # Integration tests
└── test-utils/
    ├── renderWithProviders.js
    └── mocks/
        ├── handlers.js
        └── server.js
```

---

## Checklist

- [ ] Tests describe user behavior, not implementation
- [ ] Using findBy for async assertions
- [ ] MSW for API mocking (not jest.mock)
- [ ] Custom render with providers
- [ ] Accessibility tests with jest-axe
- [ ] No flaky tests (no arbitrary waits)
- [ ] Coverage on critical paths (80%+)
- [ ] Test file <300 lines
- [ ] Full test suite <5 minutes
