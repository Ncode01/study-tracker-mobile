> [ARCHIVED] Out of date as of Phase 11. This document is retained for historical context and does not represent the current source of truth.

# 02 State Management Plan - Current Snapshot + Refactor Path

## 1. Current State Topology (Verified)

### 1.1 Global Foundation

- `ProviderScope` is active at app root (`main.dart`).
- Navigation is handled by `go_router` shell, not by Home-local nav state.

### 1.2 Feature-Level Providers

Home:

- `AsyncNotifier<HomeViewState>` (`homeViewNotifierProvider`)
- combines timer runtime, lifecycle observer, persistence orchestration, notifications, wakelock, and sensory triggers

Calendar:

- `Notifier<CalendarViewState>` with static seeded days/events (no repository)

Hub:

- `Notifier<HubViewState>` with static seeded countdowns/subjects/sessions

Clubs:

- `AsyncNotifier<ClubsViewState>` loading tasks from SQLite once; club selection updates local state

Analytics:

- `AsyncNotifier<AnalyticsViewState>` loading bundle data from repository and supporting export/share

## 2. Source-of-Truth Reality

### 2.1 Data-Backed

- categories (`categories` table)
- tasks (`tasks` table, read-only through current UI)
- sessions (`sessions` table)
- timer snapshot + selected category (`SharedPreferences`)

### 2.2 Mock/Static

- calendar events
- hub countdowns/sessions
- daily truth timeline blocks and key sink metrics
- many analytics insight texts/cards

## 3. Key State-Management Defects

1. Session continuity bug on cold start:
  running timer state restores elapsed time, but active-session start metadata is not persisted; stopping after restart can under-record session duration.
2. Analytics period mismatch:
  period selector updates state, but repository currently always filters as last 7 days.
3. Redundant/unused Home state:
  `selectedBottomNav` and some derived providers remain from pre-shell design and are not driving current UI flow.
4. Overloaded notifier responsibilities:
  Home notifier handles too many concerns (domain, infra, lifecycle side effects) in one class.

## 4. What Is Working Well

- immutable model objects with `copyWith`
- consistent notifier patterns across features
- explicit async loading/error rendering in Home/Clubs/Analytics
- lifecycle-aware timer ticker pause/resume handling while app stays alive
- pragmatic persistence layer (SQLite + shared prefs)

## 5. Refactor Plan

### Phase P0 (next sprint)

1. Fix timer session continuity across process restarts.
2. Make analytics period filtering truly period-aware (`week/month/term`) in repository queries.
3. Remove or wire dead Home state (`selectedBottomNav`, unused derived providers).
4. Add DB indexes for heavy reads (`sessions.endedAt`, `sessions.categoryId`) and prepare migration scaffolding.

### Phase P1

1. Split `HomeViewNotifier` into composable units:
  timer coordinator, persistence adapter, side-effect services.
2. Introduce repository-backed Calendar and Hub states.
3. Replace hardcoded Daily Truth blocks with computed data from sessions.

### Phase P2

1. Add optimistic mutations for Clubs tasks (status change/create/edit).
2. Add app settings state (audio on/off, haptics on/off, target duration).
3. Add structured telemetry and error reporting hooks for async notifiers.

## 6. Test Strategy Required For This Plan

Mandatory additions before large feature expansion:

- unit tests for Home timer transitions and cold-start recovery
- repository tests for analytics period filtering and CSV formatting
- notifier tests for Clubs/Analytics state transitions
- integration flows that assert real data changes (not only screen reachability)
