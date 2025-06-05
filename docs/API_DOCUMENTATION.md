# API Documentation 📚

Complete documentation for all models, providers, services, and widgets in the Study Tracker Mobile application.

## 📋 Table of Contents

- [Data Models](#-data-models)
- [Provider Classes](#-provider-classes)
- [Database Services](#-database-services)
- [Utility Functions](#-utility-functions)
- [Custom Widgets](#-custom-widgets)

---

## 🗃️ Data Models

### Project Model

**File**: `lib/src/models/project_model.dart`

Represents a study project with tracking capabilities.

```dart
class Project {
  final String id;           // Unique identifier (UUID)
  final String name;         // Project name
  final Color color;         // Project color for UI
  final int loggedMinutes;   // Total minutes logged
  final int goalMinutes;     // Target minutes to achieve
  final DateTime? dueDate;   // Optional deadline
}
```

#### Methods

```dart
// Convert to database map
Map<String, dynamic> toMap()

// Create from database map
factory Project.fromMap(Map<String, dynamic> map)
```

#### Usage Example

```dart
final project = Project(
  id: const Uuid().v4(),
  name: 'Flutter Development',
  color: Colors.teal,
  goalMinutes: 120,
  loggedMinutes: 45,
  dueDate: DateTime.now().add(Duration(days: 7)),
);

// Save to database
await DatabaseHelper.instance.insertProject(project);
```

---

### Task Model

**File**: `lib/src/models/task_model.dart`

Represents a task linked to a specific project.

```dart
class Task {
  final String id;           // Unique identifier (UUID)
  final String projectId;    // Foreign key to project
  final String title;        // Task title
  final String description;  // Task description
  final DateTime dueDate;    // Task deadline
  final bool isCompleted;    // Completion status
}
```

#### Methods

```dart
// Create a copy with updated values
Task copyWith({
  String? id,
  String? projectId,
  String? title,
  String? description,
  DateTime? dueDate,
  bool? isCompleted,
})

// Convert to database map
Map<String, dynamic> toMap()

// Create from database map
factory Task.fromMap(Map<String, dynamic> map)
```

#### Usage Example

```dart
final task = Task(
  id: const Uuid().v4(),
  projectId: project.id,
  title: 'Complete Chapter 5',
  description: 'Read and understand Flutter widgets',
  dueDate: DateTime.now().add(Duration(days: 3)),
  isCompleted: false,
);

// Toggle completion
final updatedTask = task.copyWith(isCompleted: true);
```

---

### Session Model

**File**: `lib/src/models/session_model.dart`

Represents a completed study session.

```dart
class Session {
  final String id;              // Unique identifier (UUID)
  final String projectId;       // Foreign key to project
  final String projectName;     // Project name for display
  final DateTime startTime;     // Session start time
  final DateTime endTime;       // Session end time
  final int durationMinutes;    // Session duration in minutes
}
```

#### Methods

```dart
// Convert to database map
Map<String, dynamic> toMap()

// Create from database map
factory Session.fromMap(Map<String, dynamic> map)
```

---

## 🔄 Provider Classes

### ProjectProvider

**File**: `lib/src/features/projects/providers/project_provider.dart`

Manages project state and database operations.

#### Properties

```dart
List<Project> get projects           // Current project list
```

#### Methods

```dart
// Fetch all projects from database
Future<void> fetchProjects()

// Add new project
Future<void> addProject(Project project)

// Update project logged time
Future<void> updateProjectLoggedTime({
  required String projectId,
  required int newLoggedMinutes,
})
```

#### Usage Example

```dart
// Get provider instance
final projectProvider = Provider.of<ProjectProvider>(context);

// Add new project
await projectProvider.addProject(newProject);

// Access projects
final projects = projectProvider.projects;
```

---

### TaskProvider

**File**: `lib/src/features/tasks/providers/task_provider.dart`

Manages task state and operations.

#### Properties

```dart
List<Task> get tasks                 // All tasks
List<Task> get openTasks            // Incomplete tasks only
List<Task> get completedTasks       // Completed tasks only
bool get isLoading                  // Loading state
```

#### Methods

```dart
// Fetch all tasks from database
Future<void> fetchTasks()

// Add new task
Future<void> addTask(Task task)

// Toggle task completion status
Future<void> toggleTaskCompleted(Task task)
```

#### Usage Example

```dart
// Get provider instance
final taskProvider = Provider.of<TaskProvider>(context);

// Listen to loading state
if (taskProvider.isLoading) {
  return CircularProgressIndicator();
}

// Display open tasks
return ListView.builder(
  itemCount: taskProvider.openTasks.length,
  itemBuilder: (context, index) => TaskListItem(
    task: taskProvider.openTasks[index],
  ),
);
```

---

### TimerServiceProvider

**File**: `lib/src/features/timer/providers/timer_service_provider.dart`

Manages timer functionality and session creation.

#### Properties

```dart
String? get activeProjectId         // Currently active project ID
bool get isTimerRunning            // Timer running status
Duration get elapsedTime           // Current elapsed time
```

#### Methods

```dart
// Start timer for a project
void startTimer(Project project, BuildContext context)

// Stop timer and create session
Future<void> stopTimer(BuildContext context)
```

#### Usage Example

```dart
// Get provider instance
final timerProvider = Provider.of<TimerServiceProvider>(context);

// Start timer
timerProvider.startTimer(selectedProject, context);

// Check if timer is running
if (timerProvider.isTimerRunning) {
  // Show elapsed time
  Text(formatDuration(timerProvider.elapsedTime.inMinutes));
}

// Stop timer
await timerProvider.stopTimer(context);
```

---

### SessionProvider

**File**: `lib/src/features/sessions/providers/session_provider.dart`

Manages session history and retrieval.

#### Properties

```dart
List<Session> get sessions          // All recorded sessions
```

#### Methods

```dart
// Fetch all sessions from database
Future<void> fetchSessions()
```

---

## 🗄️ Database Services

### DatabaseHelper

**File**: `lib/src/services/database_helper.dart`

Singleton service for SQLite database operations.

#### Instance Access

```dart
DatabaseHelper.instance              // Get singleton instance
```

#### Project Operations

```dart
// Insert new project
Future<void> insertProject(Project project)

// Get all projects
Future<List<Project>> getAllProjects()

// Update existing project
Future<void> updateProject(Project project)
```

#### Task Operations

```dart
// Insert new task
Future<void> insertTask(Task task)

// Update existing task
Future<void> updateTask(Task task)

// Get all tasks
Future<List<Task>> getAllTasks()
```

#### Session Operations

```dart
// Insert new session
Future<void> insertSession(Session session)

// Get all sessions
Future<List<Session>> getAllSessions()

// Get sessions for specific date
Future<List<Session>> getSessionsForDate(DateTime date)
```

#### Usage Example

```dart
// Get database instance
final db = DatabaseHelper.instance;

// Insert project
await db.insertProject(project);

// Fetch all projects
final projects = await db.getAllProjects();

// Get today's sessions
final todaySessions = await db.getSessionsForDate(DateTime.now());
```

---

## 🛠️ Utility Functions

### Formatters

**File**: `lib/src/utils/formatters.dart`

#### Duration Formatting

```dart
// Convert minutes to "Xh YYm" format
String formatDuration(int totalMinutes)
```

**Usage Example:**

```dart
print(formatDuration(125));    // Output: "2h 05m"
print(formatDuration(45));     // Output: "0h 45m"
print(formatDuration(60));     // Output: "1h 00m"
```

---

## 🎨 Custom Widgets

### ProjectListItem

**File**: `lib/src/features/projects/widgets/project_list_item.dart`

Displays individual project in the project list with timer controls.

#### Properties

```dart
final Project project              // Project to display
```

#### Features

- Play/Stop timer button
- Project color indicator
- Progress percentage
- Logged time vs goal time
- Real-time elapsed time display (when timer active)

#### Usage Example

```dart
ProjectListItem(project: project)
```

---

### TaskListItem

**File**: `lib/src/features/tasks/widgets/task_list_item.dart`

Displays individual task with completion toggle.

#### Properties

```dart
final Task task                   // Task to display
```

#### Features

- Checkbox for completion toggle
- Strike-through for completed tasks
- Due date display
- Automatic provider integration

#### Usage Example

```dart
TaskListItem(task: task)
```

---

### SessionListItem

**File**: `lib/src/features/sessions/widgets/session_list_item.dart`

Displays session information in the session history.

#### Properties

```dart
final Session session            // Session to display
```

#### Features

- Project name display
- Formatted duration
- Start/End time display
- Timer icon indicator

#### Usage Example

```dart
SessionListItem(session: session)
```

---

### HorizontalDateScroller

**File**: `lib/src/features/projects/widgets/date_scroller.dart`

Horizontal scrolling date selector for project filtering.

#### Features

- Scrollable date selection
- Highlighted selected date
- Study time display per date
- Day/Date/Time format

#### Usage Example

```dart
const HorizontalDateScroller()
```

---

### AddOptionsModalSheet

**File**: `lib/src/features/add_item/widgets/add_options_modal_sheet.dart`

Modal bottom sheet for creating new items.

#### Features

- Project creation option
- Task creation option
- Dark theme styling
- Navigation integration

#### Usage Example

```dart
showModalBottomSheet(
  context: context,
  builder: (context) => const AddOptionsModalSheet(),
);
```

---

## 🔧 Constants and Themes

### AppColors

**File**: `lib/src/constants/app_colors.dart`

```dart
class AppColors {
  static const Color primaryColor = Colors.teal;
  static const Color backgroundColor = Color(0xFF121212);
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color accentColor = Colors.tealAccent;
  static const Color textColor = Colors.white;
  static final Color? secondaryTextColor = Colors.grey[400];
}
```

### AppTheme

**File**: `lib/src/constants/app_theme.dart`

Complete dark theme configuration including:
- Text themes
- App bar styling
- Bottom navigation styling
- Card themes
- Button themes
- Color schemes

---

## 📱 Navigation Structure

### MainScreen

**File**: `lib/src/features/core_ui/screens/main_screen.dart`

Root navigation controller with bottom navigation bar.

#### Features

- IndexedStack for state preservation
- 5-tab navigation (Projects, Sessions, Add, Tasks, Stats)
- Modal integration for Add functionality
- Smart index management

#### Navigation Flow

```
MainScreen
├── ProjectsScreen (Index 0)
├── SessionsScreen (Index 1)
├── AddOptionsModalSheet (Modal)
├── TasksScreen (Index 2)
├── StatsScreen (Index 3)
└── DailyStudyPlannerScreen (Named Route)
```

#### Named Routes System

**Implementation**: `lib/src/app.dart`

The app now uses a comprehensive named routes system for navigation with deep linking support:

**Available Routes**:
- `/` - MainScreen (Home)
- `/projects/add` - AddProjectScreen
- `/tasks/add` - AddTaskScreen
- `/study-planner` - DailyStudyPlannerScreen
- `/study-planner/add` - AddStudyPlanEntryScreen
- `/study-planner/date/{date}` - DailyStudyPlannerScreen with specific date

**Deep Linking Support**:
- URL parameters: `/study-planner/add?date=2024-01-15&entryId=uuid`
- Path segments: `/study-planner/date/2024-01-15`
- Arguments passing: `Navigator.pushNamed('/route', arguments: {...})`

**Route Generation**:
```dart
Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
  final uri = Uri.parse(settings.name ?? '');
  final pathSegments = uri.pathSegments;
  
  // Dynamic route handling with parameter parsing
  // Supports both query parameters and path segments
}
```

---

## 🚨 Error Handling

### Common Patterns

1. **Database Operations**: All database operations are wrapped in try-catch blocks
2. **Form Validation**: Form validation with user feedback
3. **Provider State**: Loading states and error handling in providers
4. **Navigation Guards**: Context mounting checks before navigation
5. **Deep Link Validation**: Invalid route parameters fall back to default behavior

### Example Error Handling

```dart
try {
  await DatabaseHelper.instance.insertProject(project);
  await projectProvider.fetchProjects();
  if (mounted) {
    Navigator.pop(context);
  }
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

---

## 🔄 State Management Flow

### Provider Integration

1. **MultiProvider Setup** in `main.dart`
2. **ChangeNotifier** classes for state management
3. **Consumer** widgets for reactive UI updates
4. **Provider.of** for actions without rebuilds

### Data Flow

```
UI Widget → Provider Method → Database Service → UI Update
    ↑                                              ↓
    └─────────── notifyListeners() ←──────────────┘
```

This documentation covers all public APIs and usage patterns in the Study Tracker Mobile application.
