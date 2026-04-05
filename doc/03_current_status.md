# 03 Current Status (Phase 14 Timeline Verified)

## 1. Validation Snapshot

Latest verification after Phase 14 timeline integration:

- `flutter analyze`: no issues
- `flutter test`: pass (18 tests)

## 2. Phase 13 Completed

### 2.1 Continuous Flow Core

- Timer architecture now models real time as continuous and unbounded.
- Manual timer controls (play, pause, stop, target duration completion) were removed from Home domain behavior.
- Home ticker starts at initialization and continuously updates elapsed time while app process is alive.
- Elapsed time is computed mathematically from active session start time:
  - `elapsed = DateTime.now().difference(sessionStartTime)`

### 2.2 Session Persistence Contract

- `TimerSnapshot` now contains only:
  - `DateTime sessionStartTime`
  - `Duration elapsed`
- Active session continuity survives force-kill/restart by persisting:
  - active category id
  - active session start timestamp
- Legacy timer prefs keys from target/running era are cleaned up.

### 2.3 Switch Context Commit Hook

- `switchCategory` is now the single commit boundary.
- On context switch:
  1. outgoing session duration is finalized from previous `sessionStartTime`
  2. outgoing session is inserted into SQLite `sessions`
  3. new active category id and fresh `sessionStartTime` are persisted
  4. UI timer resets to zero for the new context
  5. same-category switches early return with no-op behavior

### 2.4 Sensory and Wakelock Rules

- Wakelock policy now follows category productivity semantics:
  - disable for `idle`, `break`, `sleep`
  - enable for productive categories (when keep-awake setting is enabled)
- Session-start feedback now fires on context switch only:
  - `SensoryService.playSessionStart()`
  - `HapticFeedback.heavyImpact()` (gated by haptics setting)

### 2.5 Home UI Ring Semantics

- Timer ring no longer toggles play/pause.
- Ring progress now behaves as an hourly cycle:
  - `(elapsed.inSeconds % 3600) / 3600.0`
- Tapping the ring now opens context switching UX instead of controlling run-state.

### 2.6 Daily Truth / Analytics Alignment

- Non-productive filtering now consistently excludes `idle`, `break`, and `sleep`.
- Analytics daily aggregation treats each day as a full 24-hour envelope, inferring unlogged remainder as idle time.
- Daily Truth metrics now include inferred idle time and explicitly report productive-only time.

## 3. Post-Shift Risk Posture

- Manual timer state-machine complexity has been removed from core runtime behavior.
- Session boundary correctness is now concentrated in one auditable path (`switchCategory`).
- Remaining future work should prioritize richer validation coverage for edge cases around category switching and day-boundary analytics.

## 4. Current Verdict

Continuous Flow paradigm has been successfully implemented and validated.
Manual pause/stop target-era tech debt in Home timer runtime has been eradicated.

Phase 14 Calendar timeline architecture is now implemented with day-accurate rendering,
live-session continuity, and deterministic time-to-pixel mapping.

## 5. Plan vs Reality (Calendar)

- Calendar now supports dual streams:
  - planned timeline blocks from `planned_items`
  - actual timeline blocks from persisted `sessions`
- Daily summary now reports:
  - planned duration
  - actual duration
  - variance (`actual - planned`)
  - per-category breakdown
  - aligned overlap time between planned and actual blocks
- Planner CRUD is now available directly from Calendar:
  - create, edit, delete planned items
  - validation enforces non-empty title and `end > start`
  - overlaps are allowed but explicitly surfaced in the form and timeline

### 5.1 Architectural Guardrail

- Home timer philosophy remains unchanged:
  - no manual play/pause/stop controls
  - context switching remains the only session commit boundary
  - continuous elapsed timing remains anchored to persisted `sessionStartTime`

## 6. Phase 14 Completed (Pixel-Perfect Calendar)

### 6.1 Day-Scoped Data Pipeline

- Calendar loading is now selected-day scoped.
- SQLite queries now include cross-midnight overlap logic for both streams:
  - actual sessions: `startedAt < dayEnd` and `(endedAt IS NULL OR endedAt > dayStart)`
  - planned blocks: `startAt < dayEnd` and `endAt > dayStart`
- Rendered start/end values are clamped to the selected day envelope (`00:00` to `24:00`).

### 6.2 Active Session Integration

- Active continuous timer session is injected into calendar actual sessions using persisted:
  - selected category id
  - timer session start timestamp
- Active session renders as a live block with dynamic end time (`now`) and breathing visual state.

### 6.3 Timeline Rendering Contract

- Timeline now uses strict fixed geometry:
  - `hourHeight = 96.0`
  - 24-hour canvas = `2304 px`
- Block positioning now follows exact math:
  - `top = minutesFromMidnight(start) * (hourHeight / 60)`
  - `height = (durationMinutes) * (hourHeight / 60)`
- Current-time indicator renders on top of the stack and updates every minute.

### 6.4 Calendar UX Shell

- Sticky schedule header and add button are now fixed above the timeline viewport.
- Horizontal date carousel supports `today - 7` to `today + 7` with selected-day highlighting.
- Timeline mode filtering supports Planned, Actual, and Both.
- Timeline scroll area includes bottom padding to prevent clipping behind floating navigation.

### 6.5 Validation

- Updated calendar repository and notifier tests for day-scoped API contracts.
- `flutter analyze` clean after refactor.
- `flutter test` green after refactor.
