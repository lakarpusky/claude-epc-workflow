---
name: pwa-patterns
description: |
  Progressive Web App patterns for Service Workers, caching, and installability.
  Use when implementing offline support, service workers, web manifests, or user
  mentions "PWA", "offline", "service worker", "cache", "installable", "Workbox".
  Complements pwa-architect agent with ready-to-use patterns.
metadata:
  author: Gabo
  version: 1.0.0
  companion-agent: pwa-architect
---

# PWA Implementation Patterns

Production-grade patterns for Progressive Web Apps.

---

## Caching Strategies

| Resource Type | Strategy | Rationale |
|---------------|----------|-----------|
| App Shell (HTML) | Network First | Fresh updates, offline fallback |
| CSS/JS | Stale While Revalidate | Fast load, background update |
| Images | Cache First | Bandwidth saving, rarely change |
| Fonts | Cache First | Never change, instant load |
| API Data | Network First | Need fresh data |
| User Uploads | Network Only | Must reach server |
| Offline Page | Cache Only | Precached, always available |

---

## Service Worker Lifecycle

```javascript
// 1. REGISTER (in main app)
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js')
      .then(reg => console.log('SW registered:', reg.scope))
      .catch(err => console.error('SW registration failed:', err));
  });
}

// 2. INSTALL (in sw.js) - Precache app shell
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open('app-shell-v1').then(cache => {
      return cache.addAll([
        '/',
        '/index.html',
        '/app.css',
        '/app.js',
        '/offline.html'
      ]);
    })
  );
  self.skipWaiting(); // Activate immediately
});

// 3. ACTIVATE - Clean old caches
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys => {
      return Promise.all(
        keys.filter(key => key !== 'app-shell-v1')
            .map(key => caches.delete(key))
      );
    })
  );
  self.clients.claim(); // Take control immediately
});

// 4. FETCH - Intercept requests
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(cached => cached || fetch(event.request))
  );
});
```

---

## Workbox Patterns

### Basic Setup

```javascript
import { precacheAndRoute } from 'workbox-precaching';
import { registerRoute } from 'workbox-routing';
import { CacheFirst, NetworkFirst, StaleWhileRevalidate } from 'workbox-strategies';
import { ExpirationPlugin } from 'workbox-expiration';

// Precache build assets (Webpack/Vite generates manifest)
precacheAndRoute(self.__WB_MANIFEST);

// Images: Cache First
registerRoute(
  ({ request }) => request.destination === 'image',
  new CacheFirst({
    cacheName: 'images',
    plugins: [
      new ExpirationPlugin({
        maxEntries: 60,
        maxAgeSeconds: 30 * 24 * 60 * 60 // 30 days
      })
    ]
  })
);

// HTML: Network First
registerRoute(
  ({ request }) => request.destination === 'document',
  new NetworkFirst({
    cacheName: 'pages',
    plugins: [
      new ExpirationPlugin({ maxEntries: 50 })
    ]
  })
);

// API: Stale While Revalidate
registerRoute(
  ({ url }) => url.pathname.startsWith('/api/'),
  new StaleWhileRevalidate({
    cacheName: 'api-cache'
  })
);
```

### Offline Fallback

```javascript
import { setCatchHandler } from 'workbox-routing';

setCatchHandler(async ({ event }) => {
  if (event.request.destination === 'document') {
    return caches.match('/offline.html');
  }
  return Response.error();
});
```

### Background Sync (Offline Queue)

```javascript
import { BackgroundSyncPlugin } from 'workbox-background-sync';
import { NetworkOnly } from 'workbox-strategies';

const bgSyncPlugin = new BackgroundSyncPlugin('formQueue', {
  maxRetentionTime: 24 * 60 // 24 hours
});

registerRoute(
  ({ url }) => url.pathname === '/api/submit',
  new NetworkOnly({
    plugins: [bgSyncPlugin]
  }),
  'POST'
);
```

---

## Web App Manifest

```json
{
  "name": "My App Name (45 chars max)",
  "short_name": "App (12 chars)",
  "description": "Required for rich install dialog on Android",
  "start_url": "/",
  "scope": "/",
  "id": "my-app-v1",
  "display": "standalone",
  "orientation": "portrait",
  "theme_color": "#2196F3",
  "background_color": "#ffffff",
  "icons": [
    {
      "src": "/icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    },
    {
      "src": "/icons/icon-maskable-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    }
  ],
  "screenshots": [
    {
      "src": "/screenshots/home.png",
      "sizes": "1280x720",
      "type": "image/png"
    }
  ],
  "shortcuts": [
    {
      "name": "New Note",
      "url": "/new?source=shortcut",
      "icons": [{ "src": "/icons/new.png", "sizes": "192x192" }]
    }
  ]
}
```

### Link in HTML

```html
<link rel="manifest" href="/manifest.json">
<meta name="theme-color" content="#2196F3">
```

---

## iOS-Specific Setup

```html
<!-- iOS ignores manifest icons - use apple-touch-icon -->
<link rel="apple-touch-icon" href="/icons/icon-180.png">

<!-- Enable standalone mode -->
<meta name="apple-mobile-web-app-capable" content="yes">

<!-- Status bar style -->
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">

<!-- App title -->
<meta name="apple-mobile-web-app-title" content="My App">

<!-- Splash screens (device-specific) -->
<link rel="apple-touch-startup-image" 
      href="/splash/iphone-x.png"
      media="(device-width: 375px) and (device-height: 812px)">
```

---

## Install Prompt (Chrome/Android)

```javascript
let deferredPrompt;

window.addEventListener('beforeinstallprompt', (e) => {
  e.preventDefault();
  deferredPrompt = e;
  showInstallButton();
});

async function handleInstallClick() {
  if (!deferredPrompt) return;
  
  deferredPrompt.prompt();
  const { outcome } = await deferredPrompt.userChoice;
  
  console.log(`User ${outcome === 'accepted' ? 'accepted' : 'dismissed'} install`);
  deferredPrompt = null;
}

window.addEventListener('appinstalled', () => {
  console.log('PWA installed');
  hideInstallButton();
});
```

---

## Update Strategy

```javascript
// In app
navigator.serviceWorker.addEventListener('controllerchange', () => {
  // New SW took control
  if (confirm('New version available. Reload?')) {
    window.location.reload();
  }
});

// Check for updates
async function checkForUpdates() {
  const reg = await navigator.serviceWorker.getRegistration();
  if (reg) {
    await reg.update();
  }
}

// In SW
self.addEventListener('message', event => {
  if (event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});
```

---

## Storage APIs

### IndexedDB (Structured Data)

```javascript
import { openDB } from 'idb';

const db = await openDB('my-db', 1, {
  upgrade(db) {
    const store = db.createObjectStore('items', { 
      keyPath: 'id', 
      autoIncrement: true 
    });
    store.createIndex('status', 'status');
  }
});

// CRUD
await db.add('items', { name: 'Item 1', status: 'active' });
const item = await db.get('items', 1);
const all = await db.getAll('items');
await db.put('items', { id: 1, name: 'Updated', status: 'active' });
await db.delete('items', 1);
```

### Cache Storage (Network Resources)

```javascript
// Open cache
const cache = await caches.open('my-cache-v1');

// Add resources
await cache.addAll(['/', '/app.css', '/app.js']);

// Match request
const response = await caches.match(request);

// Delete cache
await caches.delete('my-cache-v1');
```

### Storage Persistence

```javascript
// Request persistent storage (Chrome auto-grants for installed PWAs)
const persistent = await navigator.storage.persist();

// Check quota
const { usage, quota } = await navigator.storage.estimate();
console.log(`Using ${usage} of ${quota} bytes`);
```

---

## Platform Compatibility Matrix

| Feature | Chrome/Android | Safari/iOS | Firefox | Desktop |
|---------|----------------|------------|---------|---------|
| Install | ✓ WebAPK | ✓ Manual | ✓ | ✓ |
| beforeinstallprompt | ✓ | ✗ | ✓ | ✓ |
| Push Notifications | ✓ | ✓ (16.4+) | ✓ | ✓ |
| Badging | ✓ | ✗ | ✗ | ✓ |
| Shortcuts | ✓ | ✗ | ✗ | ✓ |
| Background Sync | ✓ | ✗ | ✗ | ✗ |
| Share Target | ✓ | ✗ | ✗ | ✗ |
| Persistent Storage | ✓ | Limited | ✓ | ✓ |

---

## Installability Requirements

### Chrome/Edge
- HTTPS (or localhost)
- Valid manifest (name, icons ≥192px, start_url, display ≠ browser)
- Service Worker with fetch handler
- User engagement (≥1 click)

### Safari iOS
- HTTPS
- Valid manifest
- apple-touch-icon meta tag
- **Manual install only** (Share → Add to Home Screen)

---

## Performance Checklist

- [ ] Service Worker registered
- [ ] App shell precached
- [ ] Offline page available
- [ ] Images use Cache First
- [ ] HTML uses Network First
- [ ] Manifest has all required fields
- [ ] Icons: 192px, 512px, maskable
- [ ] iOS meta tags present
- [ ] Lighthouse PWA score >90
- [ ] Core Web Vitals green (LCP <2.5s, INP <200ms, CLS <0.1)

---

## iOS Gotchas

1. **No beforeinstallprompt** - Show manual install instructions
2. **Aggressive termination** - App reloads on every switch
3. **Storage eviction** - 7 days of inactivity on Safari
4. **OAuth breaks** - Cross-domain issues in Web.app
5. **Multiple installs** - Same PWA can be installed multiple times (isolated storage)
6. **No push (pre-16.4)** - Push notifications require iOS 16.4+ and PWA-only

---

## File Structure

```
public/
├── manifest.json
├── sw.js (or generated by Workbox)
├── offline.html
├── icons/
│   ├── icon-192.png
│   ├── icon-512.png
│   └── icon-maskable-512.png
└── screenshots/
    └── home.png

src/
├── index.html (manifest link, iOS meta tags)
└── registerSW.js (registration logic)
```
