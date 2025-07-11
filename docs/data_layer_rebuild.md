# Data Layer Rebuild Documentation

## Overview
This document describes the complete rebuild of the data persistence layer for the Project Atlas study tracker app. The rebuild replaced in-memory storage with robust Hive-based local persistence to solve data loss issues on app restarts.

## Architecture Changes

### Before (Broken Implementation)
- **Storage**: In-memory `List<T>` collections
- **Persistence**: None - data lost on app restart
- **Repositories**: `LocalSubjectRepositoryImpl`, `LocalStudySessionRepositoryImpl`
- **Data Models**: Basic Freezed models without persistence annotations

### After (Rebuilt Implementation)
- **Storage**: Hive NoSQL database with type-safe adapters
- **Persistence**: Automatic with app lifecycle integration
- **Repositories**: `HiveSubjectRepositoryImpl`, `HiveStudySessionRepositoryImpl`
- **Data Models**: Enhanced with `@HiveType` and `@HiveField` annotations

## Key Components

### 1. HiveDataService
**Location**: `lib/features/study/data/hive_data_service.dart`

**Purpose**: Centralized service for Hive initialization and box management

**Features**:
- Automatic adapter registration
- Error handling with detailed logging
- Backup/restore functionality for data migration
- Development helpers for debugging

**Usage**:
```dart
// Initialize once in main()
await HiveDataService.initialize();

// Access boxes anywhere in the app
final subjectsBox = HiveDataService.subjectsBox;
final sessionsBox = HiveDataService.studySessionsBox;
```

### 2. Enhanced Data Models
**Location**: `lib/features/study/domain/models/`

**Changes**:
- Added `@HiveType(typeId: X)` annotations
- Added `@HiveField(X)` annotations to properties
- Maintained existing JSON serialization
- Generated adapters via build_runner

**Type IDs**:
- Subject: typeId = 0
- StudySession: typeId = 1

### 3. Persistent Repositories
**Location**: `lib/features/study/data/`

**HiveSubjectRepositoryImpl Features**:
- CRUD operations with automatic persistence
- Default subjects initialization on first launch
- Additional utility methods (count, exists, getById)
- Bulk operations support

**HiveStudySessionRepositoryImpl Features**:
- Advanced querying (by subject, date range, time periods)
- Analytics helpers (total study time calculations)
- Study session aggregation methods
- Performance optimizations

### 4. Updated Providers
**Location**: `lib/features/study/providers/study_providers.dart`

**Enhancements**:
- Replaced in-memory repositories with Hive implementations
- Added new providers for analytics and insights
- Enhanced active session management with persistence
- Added time-based query providers (today, this week)

## Data Flow

```
UI Layer (Screens/Widgets)
    ↓
Riverpod Providers
    ↓
Repository Layer (Hive*RepositoryImpl)
    ↓
HiveDataService
    ↓
Hive Boxes (Local Storage)
```

## Initialization Sequence

1. **App Startup** (`main.dart`):
   - `HiveDataService.initialize()` called
   - Hive adapters registered
   - Boxes opened

2. **First Launch**:
   - Default subjects auto-created
   - Empty study sessions box initialized
   - User preferences box created

3. **Subsequent Launches**:
   - Existing data automatically loaded
   - Providers refresh with persisted data
   - App state restored

## Error Handling

### Initialization Errors
- Hive initialization failures logged and rethrown as `Exception`
- Graceful degradation with error state in UI
- Detailed error messages for debugging

### Runtime Errors
- Box access errors caught and logged
- State errors for uninitialized service
- Data corruption protection with backup/restore

### Recovery Mechanisms
- Manual data clearing for corrupted state
- Backup/restore for data migration
- Reinitialize boxes if needed

## Performance Optimizations

### Read Performance
- Hive boxes cached in memory after first access
- Direct box access without async overhead
- Efficient querying with indexed lookups

### Write Performance
- Batch operations for bulk updates
- Asynchronous writes to prevent UI blocking
- Optimistic updates in UI with background persistence

### Memory Management
- Lazy loading of large datasets
- Automatic box closing on app termination
- Memory-efficient iteration over large collections

## Migration Strategy

### From Old Implementation
1. **Automatic Migration**: Default subjects recreated on first launch
2. **Zero Data Loss**: No existing persistent data to migrate
3. **Seamless Transition**: Same repository interfaces maintained

### Future Migrations
- Data backup/restore functionality built-in
- Version management through Hive adapters
- Schema evolution support for model changes

## Testing

### Unit Tests
**Location**: `test/features/study/study_repository_test.dart`

**Coverage**:
- Repository CRUD operations
- Data persistence verification
- Error handling scenarios
- Bulk operation tests

### Integration Tests
- App startup with persistence
- Data retention across app restarts
- Provider state management
- Error recovery flows

## Maintenance Guidelines

### Regular Tasks
1. **Monitor Storage Usage**: Use `HiveDataService.getStorageInfo()`
2. **Check Data Integrity**: Verify box contents periodically
3. **Update Type IDs**: When adding new models, assign unique typeIds
4. **Test Persistence**: Include persistence tests in CI/CD

### Code Quality
- Use repository pattern for all data access
- Maintain single responsibility in data services
- Add logging for all data operations
- Handle errors gracefully with user feedback

### Performance Monitoring
- Track box sizes and growth
- Monitor read/write performance
- Optimize queries for large datasets
- Consider data archiving for old sessions

## Troubleshooting

### Common Issues

**1. Adapter Registration Errors**
```dart
// Solution: Ensure adapters are registered before opening boxes
if (!Hive.isAdapterRegistered(typeId)) {
  Hive.registerAdapter(YourAdapter());
}
```

**2. Box Access Errors**
```dart
// Solution: Initialize HiveDataService first
await HiveDataService.initialize();
```

**3. Data Not Persisting**
```dart
// Solution: Use repository methods, not direct box access
await repository.addSubject(subject); // ✓ Correct
subjectsBox.add(subject);            // ✗ Avoid
```

### Debug Tools
- `HiveDataService.getStorageInfo()` - Storage statistics
- `HiveDataService.backupData()` - Data export for debugging
- Flutter Inspector for provider state
- Hive Inspector for box contents (development only)

## Security Considerations

### Data Protection
- Local storage only (no cloud sync in current implementation)
- No encryption in MVP (add HiveCipher for production)
- User data stays on device
- Standard app sandbox protection

### Privacy
- No analytics or telemetry on data usage
- Data clearing available for user privacy
- No data sharing between users
- Offline-first approach

## Future Enhancements

### Planned Features
1. **Cloud Sync**: Firebase integration for cross-device sync
2. **Data Encryption**: Add HiveCipher for sensitive data
3. **Export/Import**: CSV/JSON data export for users
4. **Advanced Analytics**: Complex queries and insights
5. **Data Archiving**: Automatic old data cleanup

### Scalability
- Database size monitoring and management
- Query optimization for large datasets
- Background sync for cloud integration
- Incremental data loading for performance

## Resources

### Documentation
- [Hive Documentation](https://docs.hivedb.dev/)
- [Riverpod Guide](https://riverpod.dev/)
- [Flutter State Management](https://flutter.dev/docs/development/data-and-backend/state-mgmt)

### Code Examples
- Repository implementations in `/lib/features/study/data/`
- Provider usage in `/lib/features/study/providers/`
- Model definitions in `/lib/features/study/domain/models/`

### Build Commands
```bash
# Generate adapters and serialization
flutter packages pub run build_runner build

# Clean and regenerate
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Build and verify
flutter build apk --debug
```

---

**Last Updated**: July 11, 2025  
**Version**: 1.0.0  
**Author**: Data Layer Rebuild Team  
**Status**: ✅ Complete and Tested
