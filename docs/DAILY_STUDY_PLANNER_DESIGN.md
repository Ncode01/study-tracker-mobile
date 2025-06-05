# Daily Study Planner - Data Model Design & Database Schema

## Overview

This document details the design rationale, data model structure, and database schema for the **Daily Study Planner** feature in the Study Tracker Mobile application.

## Data Model: StudyPlanEntry

### Design Rationale

The `StudyPlanEntry` model has been carefully designed to integrate seamlessly with the existing Study Tracker Mobile architecture while providing the flexibility needed for comprehensive daily study planning.

#### Key Design Decisions

1. **Feature-First Architecture Compliance**: 
   - Located in `lib/src/models/study_plan_entry_model.dart` following existing patterns
   - Maintains consistency with other models (`ProjectModel`, `TaskModel`, `SessionModel`)

2. **Immutability Pattern**: 
   - All fields are `final` to ensure immutable objects
   - Provides `copyWith()` method for creating modified copies
   - Follows established patterns from existing models

3. **UUID-based Identification**:
   - Uses UUID v4 for unique identification, consistent with `ProjectModel`
   - Ensures no ID collisions across distributed usage scenarios

4. **Optional Project Association**:
   - `projectId` is nullable to allow standalone study entries
   - When linked to a project, enables color inheritance and progress tracking
   - Foreign key relationship with `SET NULL` on project deletion

5. **Flexible Time Scheduling**:
   - Supports both all-day entries and specific time slots
   - `isAllDay` boolean flag for different scheduling modes
   - Optional start/end times for granular scheduling

6. **Completion Tracking**:
   - `isCompleted` field for progress monitoring
   - Supports analytics and productivity tracking
   - Consistent with existing task completion patterns

7. **Audit Trail**:
   - `createdAt` and `updatedAt` timestamps for data integrity
   - Automatic timestamp management in `copyWith()` method

### Model Attributes

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `id` | `String` | No | Unique identifier (UUID v4) |
| `subjectName` | `String` | No | Name of subject/topic to study |
| `projectId` | `String?` | Yes | Optional reference to existing project |
| `date` | `DateTime` | No | Scheduled date for study session |
| `startTime` | `DateTime?` | Yes | Optional start time |
| `endTime` | `DateTime?` | Yes | Optional end time |
| `isAllDay` | `bool` | No | Whether this is an all-day entry (default: false) |
| `notes` | `String?` | Yes | Additional notes or details |
| `reminderDateTime` | `DateTime?` | Yes | Optional reminder time |
| `isCompleted` | `bool` | No | Completion status (default: false) |
| `createdAt` | `DateTime` | No | Creation timestamp |
| `updatedAt` | `DateTime` | No | Last update timestamp |

### Computed Properties

- `durationMinutes`: Calculates duration from start/end times (returns `null` if times not set)
- `hasTimeSlot`: Boolean indicating if both start and end times are set
- `isToday`: Boolean indicating if entry is scheduled for today
- `isOverdue`: Boolean indicating if entry is past due and not completed

## Database Schema

### Table Definition

```sql
CREATE TABLE study_plan_entries (
  id TEXT PRIMARY KEY,
  subjectName TEXT NOT NULL,
  projectId TEXT,
  date TEXT NOT NULL,
  startTime TEXT,
  endTime TEXT,
  isAllDay INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  reminderDateTime TEXT,
  isCompleted INTEGER NOT NULL DEFAULT 0,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL,
  FOREIGN KEY(projectId) REFERENCES projects(id) ON DELETE SET NULL
);
```

### Indexes for Performance

```sql
CREATE INDEX idx_study_plan_entries_date ON study_plan_entries(date);
CREATE INDEX idx_study_plan_entries_project_id ON study_plan_entries(projectId);
CREATE INDEX idx_study_plan_entries_completed ON study_plan_entries(isCompleted);
```

### Schema Design Rationale

#### Column Types and Constraints

1. **Text Fields**:
   - `id`, `subjectName`, `projectId`, `notes`: Standard `TEXT` type
   - `subjectName` is `NOT NULL` as it's required for meaningful entries
   - `projectId` is nullable to support standalone entries

2. **Date/Time Fields**:
   - All DateTime fields stored as `TEXT` in ISO8601 format
   - Provides human-readable storage and proper sorting capabilities
   - `date` is `NOT NULL` as every entry must have a scheduled date
   - `startTime`, `endTime`, `reminderDateTime` are nullable for flexible scheduling

3. **Boolean Fields**:
   - Stored as `INTEGER` (0/1) following SQLite conventions
   - `isAllDay` and `isCompleted` have `DEFAULT 0` for consistency
   - Both are `NOT NULL` with sensible defaults

4. **Foreign Key Relationship**:
   - `projectId` references `projects(id)` table
   - `ON DELETE SET NULL` policy preserves study plan entries when projects are deleted
   - This prevents data loss while maintaining referential integrity

#### Index Strategy

1. **Date Index**: Optimizes queries for daily/weekly views and date range filtering
2. **Project ID Index**: Accelerates project-specific study plan queries
3. **Completion Index**: Speeds up filtered views (completed vs. incomplete entries)

### Database Operations Provided

The `DatabaseHelper` class has been extended with comprehensive CRUD operations:

#### Basic CRUD
- `insertStudyPlanEntry(StudyPlanEntry entry)`
- `updateStudyPlanEntry(StudyPlanEntry entry)`
- `deleteStudyPlanEntry(String id)`
- `getAllStudyPlanEntries()`

#### Specialized Queries
- `getStudyPlanEntriesForDate(DateTime date)`: Daily view support
- `getStudyPlanEntriesForDateRange(DateTime start, DateTime end)`: Weekly/monthly views
- `getStudyPlanEntriesForProject(String projectId)`: Project-specific planning
- `getIncompleteStudyPlanEntries()`: Active planning items
- `getCompletedStudyPlanEntries()`: Historical tracking
- `getOverdueStudyPlanEntries()`: Urgent items requiring attention

#### Convenience Methods
- `markStudyPlanEntryCompleted(String id)`: Quick completion toggle
- `markStudyPlanEntryIncomplete(String id)`: Revert completion status

## Migration Considerations

### Database Version Management

The new table creation is included in the existing `_onCreate` method. For production deployment with existing users, a migration strategy would be needed:

```sql
-- Migration from version 1 to version 2
ALTER TABLE study_plan_entries ADD COLUMN 
  -- (Create table and indexes as shown above)
```

### Data Migration

No existing data migration is required as this is a new feature. However, future enhancements might include:
- Migrating existing tasks to study plan entries
- Importing calendar events as study plans
- Bulk creation from academic schedules

## Integration Points

### Existing System Integration

1. **Project Colors**: When `projectId` is set, UI can inherit project color for visual consistency
2. **Session Tracking**: Completed study plan entries could create corresponding session records
3. **Statistics**: Study plan completion rates can contribute to productivity analytics
4. **Notifications**: `reminderDateTime` provides foundation for notification system

### Future Extensibility

The model and schema are designed to support future enhancements:
- **Recurring Entries**: Could add `recurrencePattern` field
- **Attachments**: Could add `attachmentPaths` JSON field
- **Categories**: Could add `categoryId` foreign key
- **Priority Levels**: Could add `priority` integer field
- **Estimated Duration**: Could add `estimatedMinutes` field

## Security Considerations

### Input Validation

Following the security audit recommendations, the model should implement:
- Input sanitization for `subjectName` and `notes` fields
- Length limits to prevent excessive data storage
- Validation of date/time relationships (end after start, etc.)

### Data Protection

- All sensitive user data remains local in SQLite database
- No external API calls or data transmission required
- Standard app-private directory storage maintains data security

## Documentation Updates Required

The following existing documentation files will need updates in subsequent implementation steps:

1. **API_DOCUMENTATION.md**:
   - Add `StudyPlanEntry` model documentation
   - Document new DatabaseHelper methods
   - Add usage examples and patterns

2. **ARCHITECTURE.md**:
   - Update database schema section
   - Add study planner to feature overview
   - Update dependency graph

3. **CODE_PATTERNS.md**:
   - Add study planner provider patterns (when implemented)
   - Document UI consumption patterns for daily planning

4. **.ai-context.md**:
   - Update project structure with new model
   - Add study planner to business logic section
   - Update database schema information

## Testing Strategy

### Unit Tests Required

1. **Model Tests**:
   - `toMap()` and `fromMap()` serialization accuracy
   - `copyWith()` method functionality
   - Computed properties (`durationMinutes`, `isOverdue`, etc.)
   - Edge cases for nullable fields

2. **Database Tests**:
   - CRUD operations with mock database
   - Foreign key constraint behavior
   - Index performance verification
   - Date range query accuracy

3. **Integration Tests**:
   - End-to-end study plan creation and retrieval
   - Project deletion impact on study plan entries
   - Performance under various data loads

## Performance Considerations

### Query Optimization

1. **Indexed Queries**: Date, project ID, and completion status indexes ensure fast filtering
2. **Batch Operations**: Future provider implementation should use database transactions
3. **Memory Management**: Large date ranges should use pagination for UI display

### Storage Efficiency

1. **Compact Schema**: Minimal required fields reduce storage footprint
2. **Normalized Design**: Project association via foreign key prevents data duplication
3. **Index Strategy**: Strategic indexing balances query performance with storage overhead

---

This completes the foundational data model and database schema design for the Daily Study Planner feature. The design prioritizes consistency with existing architecture while providing the flexibility needed for comprehensive study planning functionality.
