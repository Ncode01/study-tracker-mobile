# 03 Current Status (Verified)

## 1. Diagnostics Snapshot

Latest command results captured after Phase 6 stabilization:

- `flutter analyze`: no issues
- `flutter test`: pass

Previous audit notes still applicable:

- `dart analyze`: 2 included-file lint warnings from `lints-5.1.1` rule recognition
- `flutter pub outdated`: multiple direct/transitive dependencies behind latest versions

## 2. Phase 6 Completed

### 2.1 Data Integrity and Persistence

- SQLite migration pipeline is now active (`timeflow.db` v2 with `onUpgrade`).
- Session query indexes added (`endedAt`, `categoryId`).
- Timer snapshot now persists absolute session anchors (`sessionStartTime`, `sessionStartElapsed`).
- Cold-start continuity uses real elapsed recomputation from persisted absolute start time.

### 2.2 Home Stabilization

- stale Home nav state removed (`selectedBottomNav`)
- unused derived timer providers removed
- side-effect orchestration extracted into `TimerService` (ticker, wakelock, notifications, sensory)
- `HomeViewNotifier` now coordinates state/persistence while delegating side effects

### 2.3 Analytics Truth Alignment

- period dropdown now maps to concrete date boundaries (`since`)
- repository enforces period boundaries in SQL (`WHERE endedAt >= ?`)
- totals/distribution/productivity are now computed from period-filtered rows

## 3. What Is Still Mock-Backed or Incomplete

- Calendar: static day/event data in notifier
- Hub: static countdown/subject/session data in notifier
- Daily Truth sheet: mostly placeholder blocks/metrics
- Clubs: read-only task board (no create/edit/move/complete flow)

## 4. Residual Risks

1. Test depth remains low:
	coverage is still mostly smoke/reachability, with no deep notifier/repository regression suites for new timer and analytics paths.
2. Dependency lag remains:
	multiple direct/transitive packages are still behind latest versions.
3. Performance risk remains:
	heavy glass/blur rendering can become expensive on lower-end devices.

## 5. Phase 7 Priority Backlog

- repository-backed Calendar and Hub state
- Daily Truth computed from persisted sessions
- Clubs task mutation flows
- notifier/repository-focused automated tests
- dependency upgrade wave
