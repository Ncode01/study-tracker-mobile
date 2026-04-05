# 01 UI Architecture - Current Reality (Verified)

## 1. App-Level Shell Structure

The app is now a 5-branch shell built with `go_router` and `StatefulShellRoute.indexedStack`.

Actual branch routing:

- `/` -> Home
- `/calendar` -> Calendar
- `/hub` -> A/Level Hub
- `/clubs` -> Clubs
- `/analytics` -> Analytics

`AppShell` wraps `navigationShell` and overlays a shared bottom control (`BottomActionsNav`) with:

- a global `Switch Category...` button (opens `SwitchContextSheet`)
- branch switching icons (`goBranch(index)`)

Important: `BottomActionsNav` is the real navigation source. Home-local `selectedBottomNav` state is not used by this shell.

## 2. Core UI System

Shared design primitives are centralized in `lib/core`:

- `core/theme`: `AppColors`, `AppTypography`, `AppTheme`
- `core/widgets`: `GlassContainer`, `GlassPanel`, `GlassButton`

Glass implementation uses:

1. rounded clipping (`ClipRRect`)
2. backdrop blur (`BackdropFilter`)
3. translucent fill + border

This is consistent across all feature screens.

## 3. Screen Composition by Feature

### 3.1 Home

Home is the most complete interactive screen.

Main UI stack:

- animated `AmbientBackground` (breathing orb)
- `TopStatsBar`
- `CategoryContextRow`
- `TimerRing` (tap starts/stops timer)
- `QuickSwitchChips`

`SwitchContextSheet` is sectioned and searchable, and category taps update notifier state.

### 3.2 Calendar

Calendar UI is polished, but data is static and hardcoded in notifier state (`DateTime(2026, 4, 12)` and nearby dates). No repository-backed events yet.

### 3.3 Hub

Hub has rich UI (countdowns, expandable cards, custom ring), but all subject/session/countdown data is static in `HubViewNotifier`.

### 3.4 Clubs

Clubs UI is functional (selector + kanban sections). Data is loaded from SQLite `tasks` table, but currently read-only from the app UI (no create/update/drag/status mutation flows).

### 3.5 Analytics

Analytics UI includes charts, period dropdown, smart cards, and export CTA.

Real vs placeholder split:

- real: session CSV export pipeline and weekly session aggregation from DB
- placeholder: key insight cards and Daily Truth timeline/metrics are mostly static text/sample blocks

## 4. Responsiveness and Rendering

What is in place:

- widespread `SafeArea`
- `LayoutBuilder` on Home
- constrained chart/ring areas
- `RepaintBoundary` around animated areas (`AmbientBackground`, `TimerRing`)

Current rendering risk:

- heavy stacked `BackdropFilter` usage across full-screen compositions can become GPU-expensive on lower-end devices.

## 5. UI Architecture Gaps

1. Shell and feature state are not fully harmonized:
   Home still carries a local bottom-nav field that no longer drives navigation.
2. Mock-heavy screens:
   Calendar and Hub are presentation-complete but data-incomplete.
3. Analytics truth gap:
   visual sophistication exceeds data fidelity in Daily Truth/insight blocks.
4. Missing user customization flows:
   `Create New` category card is visual-only, not wired to persistence.
