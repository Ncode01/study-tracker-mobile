# 01 UI Architecture - Current Reality (Verified)

## 1. App-Level Shell Structure

The app remains a 5-branch shell built with `go_router` and `StatefulShellRoute.indexedStack`.

Actual branch routing:

- `/` -> Home
- `/calendar` -> Calendar
- `/hub` -> A/Level Hub
- `/clubs` -> Clubs
- `/analytics` -> Analytics

`AppShell` is now adaptive:

- compact widths: floating `BottomActionsNav` + `Switch Category...`
- larger widths: `NavigationRail` layout with preserved branch state and rail-level `Switch Category...`

Important: branch switching is shell-driven (`goBranch(index)`), not Home-local navigation state.

## 2. Core UI System

Shared design primitives are centralized in `lib/core`:

- `core/theme`: `AppColors`, `AppTypography`, `AppTheme`
- `core/widgets`: `GlassContainer`, `GlassPanel`, `GlassButton`

Glass composition remains consistent:

1. rounded clipping (`ClipRRect`)
2. backdrop blur (`BackdropFilter`)
3. translucent fill + border

## 3. Screen Composition by Feature

### 3.1 Home

Home remains the primary interaction loop with:

- animated `AmbientBackground`
- `TopStatsBar`
- `CategoryContextRow`
- `TimerRing`
- `QuickSwitchChips`

Home text is now localization-backed and timer/settings affordances include stronger semantics.

### 3.2 Calendar

Calendar UI is polished, but event content is still mostly static/hardcoded and not fully repository-driven.

### 3.3 Hub

Hub remains presentation-rich (countdowns, expandable cards, custom ring) with static/mock-heavy subject data, now with merged semantic containers on key cards.

### 3.4 Clubs

Clubs still reads from SQLite `tasks`, but now adapts between:

- stacked Kanban sections on compact screens
- multi-column Kanban board on larger screens

Task cards now expose merged semantic summaries for screen readers.

### 3.5 Analytics

Analytics now adapts by width:

- compact: insight carousel + stacked chart cards
- larger widths: insight grid + side-by-side distribution/trend chart cards

Data fidelity caveat remains: portions of insight storytelling still contain placeholders.

## 4. Adaptive Layout Strategy

Current breakpoint behavior:

- `< 600`: compact shell controls
- `>= 600`: rail shell controls
- wider analytics/clubs breakpoints: multi-column content layouts

This reduces tablet/foldable dead space while preserving existing mobile interaction flows.

## 5. Localization and Accessibility Architecture

Localization foundation now includes:

- `flutter_localizations` integration
- generated localizations (`l10n.yaml`, `app_en.arb`)
- app-level delegates + supported locales in `MaterialApp.router`

Accessibility updates include:

- explicit semantics for nav controls
- `ExcludeSemantics` on decorative visuals
- merged semantics on Hub and Clubs card containers

## 6. Rendering and Quality Risks

1. Heavy blur/layer composition can still be GPU-expensive on lower-end devices.
2. Calendar/Hub data realism remains behind UI maturity.
3. Clubs interaction model is still read-only from the user perspective.
4. Localization currently ships with English only; multi-locale rollout is pending.
