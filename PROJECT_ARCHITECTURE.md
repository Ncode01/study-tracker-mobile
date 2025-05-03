# Project Architecture

This document outlines the architectural design of the ByteLearn Study Tracker application, including the system design, data models, and component structure.

## Architecture Overview

ByteLearn Study Tracker follows the MVVM (Model-View-ViewModel) architecture pattern to ensure separation of concerns, testability, and maintainability.

### Architecture Layers

1. **Models**
   - Represents the data and business logic
   - Immutable data classes with serialization/deserialization capabilities
   - Repository pattern for data access

2. **Views**
   - UI components and screens
   - Organized by feature
   - Only responsible for displaying data and capturing user input

3. **ViewModels**
   - Mediates between Model and View
   - Transforms Model data for View consumption
   - Handles UI-related logic and state

4. **Services**
   - Encapsulates external dependencies like local storage
   - Provides abstract interfaces to the rest of the application
   - Handles background processes like timer tracking

## Data Models

### Core Entities

#### Project
```dart
class Project {
  final String id;
  final String title;
  final String description;
  final DateTime? deadline;
  final String category;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relationships
  final List<String> sessionIds;
  final List<String> goalIds;
}
```

#### Timer Session
```dart
class Session {
  final String id;
  final String projectId;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final String notes;
  final bool isCompleted;
}
```

#### Goal
```dart
enum GoalType { TIME, TASK }
enum GoalPeriod { DAILY, WEEKLY, MONTHLY }

class Goal {
  final String id;
  final String title;
  final String projectId;
  final GoalType type;
  final GoalPeriod period;
  final int targetValue;
  final int currentValue;
  final DateTime createdAt;
  final DateTime deadline;
}
```

#### User Settings
```dart
class Settings {
  final bool darkMode;
  final bool notificationsEnabled;
  final List<String> notificationTypes;
  final Map<String, dynamic> timerSettings;
}
```

## Component Structure

### UI Components

1. **Main Navigation**
   - Bottom navigation bar with tabs
   - Navigation state management
   - Screen transitions

2. **Timer Screen**
   - Timer display component
   - Start/Pause/Stop controls
   - Project selection dropdown
   - Session metadata input

3. **Projects Screen**
   - Project list/grid view
   - Project creation form
   - Project detail view
   - Progress visualization

4. **Statistics Screen**
   - Time tracking charts
   - Project breakdown visualizations
   - Goal progress indicators
   - Date range filters

5. **Settings Screen**
   - Preference toggles
   - Theme selection
   - Notification settings
   - Data management options

### Application Flow

```
App Initialization
│
├── Load User Settings
│   └── Apply Theme
│
├── Initialize Storage
│   ├── Load Projects
│   ├── Load Sessions
│   └── Load Goals
│
└── Render Main Navigation
    ├── Timer Tab
    │   └── Display Active or New Timer
    │
    ├── Projects Tab
    │   └── Display Project List
    │
    ├── Statistics Tab
    │   └── Display Recent Statistics
    │
    └── Settings Tab
        └── Display User Preferences
```

## State Management

Provider is used for state management with the following key providers:

1. **AppStateProvider**
   - Global application state
   - Current navigation state
   - Theme and settings

2. **TimerProvider**
   - Active timer state
   - Background timer service connection
   - Session recording

3. **ProjectProvider**
   - Project CRUD operations
   - Project filtering and sorting
   - Project progress tracking

4. **GoalProvider**
   - Goal CRUD operations
   - Goal progress tracking
   - Goal notifications

## Data Persistence

Hive database is used for local storage with the following boxes:

1. **ProjectBox**
   - Stores Project entities
   - Indexed by project ID

2. **SessionBox**
   - Stores Session entities
   - Indexed by session ID
   - Secondary index by project ID

3. **GoalBox**
   - Stores Goal entities
   - Indexed by goal ID
   - Secondary index by project ID

4. **SettingsBox**
   - Stores application settings
   - Single record for user preferences