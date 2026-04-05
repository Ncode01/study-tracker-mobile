# 04 Project Audit and Health Report

## Audit Scope

This report is based on direct inspection of:

- `lib/`
- `test/`
- `integration_test/`
- `doc/`

and live diagnostics:

- `flutter analyze`
- `dart analyze`
- `flutter pub outdated`
- `flutter test`
- `flutter test integration_test/app_flow_test.dart`

## 1. Executive Summary

Overall status: stabilized and materially improved in data correctness, with remaining delivery risk now concentrated in mock-backed domains and test depth.

High-level rating (0-10):

- UI/UX quality: 8.5
- Architecture clarity: 7.5
- Data integrity: 7.5
- Test maturity: 4.0
- Delivery readiness for real users: 6.8

Primary conclusion:

Phase 6 stabilization closed the highest-risk data integrity issues (timer continuity, analytics period truth, session indexing/migration, and stale Home state drift). Remaining reliability work is mainly Phase 7: converting mock-backed domains and increasing deep automated test coverage.

## 2. Diagnostics and Build Health

### 2.1 Analyzer/Tests

- `flutter analyze`: clean
- `flutter test`: pass

Context from earlier audit still relevant:

- `dart analyze`: 2 `included_file_warning` lint-rule recognition warnings
- integration test file run: pass

### 2.2 Dependency Health

`flutter pub outdated` shows notable lag on direct dependencies. Examples:

- `flutter_riverpod` 2.x while 3.x is available
- `share_plus` pinned below latest major
- `flutter_local_notifications`, `google_fonts`, `go_router`, `timezone` behind latest
- many transitive dependencies behind latest

Impact:

- rising upgrade risk over time
- delayed security and bugfix uptake
- increasing migration blast radius if postponed

## 3. Completed vs Missing Features

### 3.1 Completed (real behavior)

- shell routing and multi-tab app structure
- Home timer runtime with persistence and side-effect integrations
- SQLite schema, first-run seeding, and migration/index pipeline (`categories`, `tasks`, `sessions`)
- Clubs task loading from DB (read-only)
- Analytics period-aware session aggregation and CSV export/share
- baseline widget + integration test files that execute successfully

### 3.2 Missing or Incomplete

- Calendar repository-backed data (currently static hardcoded events)
- Hub repository/API-backed data (currently static hardcoded content)
- Clubs write paths (create/edit/move/complete tasks)
- Daily Truth calculations from real data (currently mostly static)
- settings/profile/auth/sync flows

## 4. Critical Findings (Severity Ordered)

### High

1. Mock-vs-real boundary is not explicit in app UX.
   Root cause: Calendar/Hub and Daily Truth are designed as premium/real views despite placeholder data.
   Risk: expectation mismatch and future integration complexity.

2. Test depth is still shallow for critical transitions.
   Root cause: current automated suite is primarily smoke/reachability.
   Risk: lifecycle/data regressions can ship without early detection.

### Medium

3. Clubs remains read-only despite persistent backing store.
   Root cause: task mutation flows are not implemented.
   Risk: feature incompleteness and reduced engagement.

4. Dependency lag can accumulate upgrade risk.
   Root cause: several direct/transitive packages are behind latest releases.
   Risk: larger future migration and slower bugfix/security uptake.

### Low

5. Optional audio cues are referenced but no declared asset pack exists yet.
   Risk: feature appears implemented but is effectively no-op in many runs.

## 5. Phase 6 Closures

Completed from stabilization backlog:

1. Timer continuity across cold starts fixed using persisted absolute start anchors.
2. Analytics period semantics aligned with SQL-level boundary filtering.
3. Session indexes and DB migration version bump implemented.
4. Stale Home nav state and unused derived providers removed.
5. Timer side effects extracted into `TimerService` to reduce notifier responsibility concentration.

## 6. Performance and Scalability Observations

1. Rendering cost risk from layered blur/glass surfaces:
   many screens use stacked `BackdropFilter` + animated elements.

2. Analytics still aggregates in Dart after SQL boundary filtering:
   acceptable for current scale, but SQL aggregation would be preferable as session volume grows.

3. Migration strategy exists now, but future changes still need explicit versioned migrations.

## 7. Testing Reality Check

Current coverage profile:

- one widget smoke-style test
- one integration reachability-style test
- no deep notifier transition tests
- no repository logic tests
- no regression tests for lifecycle edge cases (cold start mid-session, DST/timezone boundaries, large data)

Confidence impact:

UI stability confidence is moderate-high; domain correctness confidence is now moderate.

## 8. Prioritized Next Plan (Phase 7)

### P1 (Next sprint)

1. Implement repository-backed Calendar state.
2. Implement repository-backed Hub state.
3. Convert Daily Truth to computed metrics from persisted sessions.
4. Add notifier/repository regression tests for timer continuity and analytics period boundaries.

Expected outcome: reduced architecture risk and improved trust in analytics views.

### P2 (Hardening)

1. Add task mutations to Clubs (CRUD/status transitions).
2. Introduce settings toggles for sensory/audio behavior.
3. Expand automated test suite (notifier/repository/integration edge cases).
4. Perform dependency upgrade wave with compatibility checks.

Expected outcome: maintainability and release confidence uplift.

## 9. Recommended Acceptance Gate Before Next Major Feature Wave

Proceed to new feature work only after:

- at least one notifier test suite and one repository test suite are in CI for Home timer and analytics domains
- mock domains are clearly labeled or replaced with real data sources

## Final Verdict

The project has moved from transitional-risk to stabilized-foundation. Core data integrity blockers are now addressed, and the next quality jump depends on replacing remaining mock domains and expanding deep automated coverage.