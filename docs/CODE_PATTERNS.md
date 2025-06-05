# Code Patterns - Study Tracker Mobile

This document outlines the established code patterns, conventions, and best practices used in the Study Tracker Mobile Flutter application.

## Table of Contents

- [Architecture Patterns](#architecture-patterns)
- [State Management Patterns](#state-management-patterns)
- [Database Patterns](#database-patterns)
- [UI Patterns](#ui-patterns)
- [Navigation Patterns](#navigation-patterns)
- [Error Handling Patterns](#error-handling-patterns)
- [Testing Patterns](#testing-patterns)
- [Performance Patterns](#performance-patterns)
- [Naming Conventions](#naming-conventions)

## Architecture Patterns

### Feature-First Organization
```
lib/src/features/feature_name/
├── screens/          # UI screens for this feature
├── widgets/          # Feature-specific widgets
├── providers/        # State management for this feature
└── models/           # Feature-specific models (if any)
```

**Example Implementation:**
```dart
// lib/src/features/projects/
├── screens/
│   ├── project_list_screen.dart
│   ├── project_detail_screen.dart
│   └── add_project_screen.dart
├── widgets/
│   ├── project_card.dart
│   └── project_form.dart
└── providers/
    └── project_provider.dart
```

### Dependency Injection Pattern
```dart
// main.dart - Provider registration
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ProjectProvider()),
    ChangeNotifierProvider(create: (_) => TaskProvider()),
    ChangeNotifierProxyProvider<ProjectProvider, TaskProvider>(
      create: (_) => TaskProvider(),
      update: (_, projectProvider, taskProvider) {
        taskProvider?.updateProjects(projectProvider.projects);
        return taskProvider!;
      },
    ),
  ],
  child: StudyTrackerApp(),
)
```

## State Management Patterns

### Provider Class Structure
```dart
class FeatureProvider extends ChangeNotifier {
  // Private state variables
  List<Model> _items = [];
  bool _isLoading = false;
  String? _error;
  
  // Public getters (immutable access)
  List<Model> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Public methods for state changes
  Future<void> loadItems() async {
    _setLoading(true);
    _clearError();
    
    try {
      final items = await DatabaseHelper.instance.getItems();
      _items = items;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
}
```

### Consumer Pattern for UI Updates
```dart
// Single provider consumption
Consumer<ProjectProvider>(
  builder: (context, projectProvider, child) {
    if (projectProvider.isLoading) {
      return const CircularProgressIndicator();
    }
    
    if (projectProvider.error != null) {
      return ErrorWidget(projectProvider.error!);
    }
    
    return ListView.builder(
      itemCount: projectProvider.projects.length,
      itemBuilder: (context, index) {
        return ProjectCard(project: projectProvider.projects[index]);
      },
    );
  },
)

// Multiple provider consumption
Consumer2<ProjectProvider, TaskProvider>(
  builder: (context, projectProvider, taskProvider, child) {
    return SomeWidget(
      projects: projectProvider.projects,
      tasks: taskProvider.tasks,
    );
  },
)
```

### Selector Pattern for Performance
```dart
// Only rebuild when specific data changes
Selector<ProjectProvider, List<Project>>(
  selector: (context, provider) => provider.projects,
  builder: (context, projects, child) {
    return ProjectList(projects: projects);
  },
)

// Only rebuild when loading state changes
Selector<ProjectProvider, bool>(
  selector: (context, provider) => provider.isLoading,
  builder: (context, isLoading, child) {
    return isLoading 
      ? const CircularProgressIndicator()
      : child!;
  },
  child: ProjectList(),
)
```

## Database Patterns

### Singleton Database Helper
```dart
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;
  
  DatabaseHelper._internal();
  
  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }
  
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'study_tracker.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
}
```

### CRUD Operations Pattern
```dart
class DatabaseHelper {
  // Create
  Future<int> insertItem(Map<String, dynamic> item, String table) async {
    final db = await database;
    try {
      return await db.insert(table, item);
    } catch (e) {
      throw DatabaseException('Failed to insert item: $e');
    }
  }
  
  // Read
  Future<List<Map<String, dynamic>>> getAllItems(String table) async {
    final db = await database;
    try {
      return await db.query(table, orderBy: 'created_at DESC');
    } catch (e) {
      throw DatabaseException('Failed to fetch items: $e');
    }
  }
  
  // Update
  Future<int> updateItem(int id, Map<String, dynamic> item, String table) async {
    final db = await database;
    try {
      return await db.update(
        table,
        item,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to update item: $e');
    }
  }
  
  // Delete
  Future<int> deleteItem(int id, String table) async {
    final db = await database;
    try {
      return await db.delete(
        table,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete item: $e');
    }
  }
}
```

### Transaction Pattern
```dart
Future<void> performComplexOperation() async {
  final db = await database;
  await db.transaction((txn) async {
    try {
      // Multiple related operations
      await txn.insert('projects', projectData);
      await txn.insert('tasks', taskData);
      await txn.update('sessions', sessionData, where: 'id = ?', whereArgs: [sessionId]);
    } catch (e) {
      // Transaction will automatically rollback on error
      rethrow;
    }
  });
}
```

## UI Patterns

### Screen Structure Pattern
```dart
class FeatureScreen extends StatefulWidget {
  const FeatureScreen({Key? key}) : super(key: key);
  
  @override
  State<FeatureScreen> createState() => _FeatureScreenState();
}

class _FeatureScreenState extends State<FeatureScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize screen-specific state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeatureProvider>(context, listen: false).loadData();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Feature Screen'),
      actions: [
        _buildActionButton(),
      ],
    );
  }
  
  Widget _buildBody() {
    return Consumer<FeatureProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState();
        }
        
        if (provider.error != null) {
          return _buildErrorState(provider.error!);
        }
        
        return _buildSuccessState(provider.items);
      },
    );
  }
  
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Theme.of(context).errorColor),
          const SizedBox(height: 16),
          Text(error),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Provider.of<FeatureProvider>(context, listen: false).retry(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
```

### Custom Widget Pattern
```dart
class CustomCard extends StatelessWidget {
  const CustomCard({
    Key? key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  }) : super(key: key);
  
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
```

### Form Pattern
```dart
class FeatureForm extends StatefulWidget {
  const FeatureForm({Key? key, this.initialData}) : super(key: key);
  
  final FeatureModel? initialData;
  
  @override
  State<FeatureForm> createState() => _FeatureFormState();
}

class _FeatureFormState extends State<FeatureForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _initializeForm();
  }
  
  void _initializeForm() {
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!.name;
      _descriptionController.text = widget.initialData!.description ?? '';
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Name is required';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text(widget.initialData == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final data = FeatureModel(
        id: widget.initialData?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );
      
      Navigator.of(context).pop(data);
    }
  }
}
```

## Navigation Patterns

### Named Routes Pattern
```dart
// app.dart - Route definitions
class StudyTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Tracker',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/projects': (context) => const ProjectListScreen(),
        '/projects/add': (context) => const AddProjectScreen(),
        '/projects/detail': (context) => const ProjectDetailScreen(),
        '/tasks': (context) => const TaskListScreen(),
        '/timer': (context) => const TimerScreen(),
      },
      onGenerateRoute: _onGenerateRoute,
    );
  }
  
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    // Handle dynamic routes with parameters
    if (settings.name?.startsWith('/projects/') == true) {
      final projectId = int.tryParse(settings.name!.split('/').last);
      if (projectId != null) {
        return MaterialPageRoute(
          builder: (context) => ProjectDetailScreen(projectId: projectId),
        );
      }
    }
    return null;
  }
}
```

### Navigation Helper Pattern
```dart
class NavigationHelper {
  static void navigateToProjectDetail(BuildContext context, int projectId) {
    Navigator.of(context).pushNamed('/projects/$projectId');
  }
  
  static void navigateToAddProject(BuildContext context) {
    Navigator.of(context).pushNamed('/projects/add');
  }
  
  static Future<T?> navigateToScreen<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(builder: (context) => screen),
    );
  }
  
  static void navigateAndReplace(BuildContext context, String routeName) {
    Navigator.of(context).pushReplacementNamed(routeName);
  }
  
  static void navigateAndClearStack(BuildContext context, String routeName) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
    );
  }
}
```

## Error Handling Patterns

### Custom Exception Classes
```dart
class StudyTrackerException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  const StudyTrackerException(
    this.message, {
    this.code,
    this.originalError,
  });
  
  @override
  String toString() => 'StudyTrackerException: $message';
}

class DatabaseException extends StudyTrackerException {
  const DatabaseException(String message) : super(message, code: 'DATABASE_ERROR');
}

class ValidationException extends StudyTrackerException {
  const ValidationException(String message) : super(message, code: 'VALIDATION_ERROR');
}
```

### Error Handling in Providers
```dart
class FeatureProvider extends ChangeNotifier {
  String? _error;
  bool _hasError = false;
  
  String? get error => _error;
  bool get hasError => _hasError;
  
  Future<void> performOperation() async {
    _clearError();
    
    try {
      // Perform operation
      await someAsyncOperation();
    } on DatabaseException catch (e) {
      _setError('Database error: ${e.message}');
    } on ValidationException catch (e) {
      _setError('Validation error: ${e.message}');
    } catch (e) {
      _setError('Unexpected error: $e');
    }
  }
  
  void _setError(String error) {
    _error = error;
    _hasError = true;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    _hasError = false;
  }
  
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
```

### Global Error Handler
```dart
class ErrorHandler {
  static void handleError(dynamic error, StackTrace? stackTrace) {
    // Log error
    debugPrint('Error: $error');
    debugPrint('Stack trace: $stackTrace');
    
    // Report to crash analytics (if implemented)
    // CrashReporting.recordError(error, stackTrace);
  }
  
  static String getUserFriendlyMessage(dynamic error) {
    if (error is DatabaseException) {
      return 'There was a problem accessing your data. Please try again.';
    } else if (error is ValidationException) {
      return error.message;
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}
```

## Testing Patterns

### Unit Testing Pattern
```dart
void main() {
  group('FeatureProvider', () {
    late FeatureProvider provider;
    late MockDatabaseHelper mockDatabase;
    
    setUp(() {
      mockDatabase = MockDatabaseHelper();
      provider = FeatureProvider(database: mockDatabase);
    });
    
    tearDown(() {
      provider.dispose();
    });
    
    test('should load items successfully', () async {
      // Arrange
      final mockItems = [FeatureModel(name: 'Test Item')];
      when(mockDatabase.getAllItems('table')).thenAnswer((_) async => mockItems);
      
      // Act
      await provider.loadItems();
      
      // Assert
      expect(provider.items, equals(mockItems));
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });
    
    test('should handle errors gracefully', () async {
      // Arrange
      when(mockDatabase.getAllItems('table')).thenThrow(DatabaseException('Test error'));
      
      // Act
      await provider.loadItems();
      
      // Assert
      expect(provider.items, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.error, isNotNull);
    });
  });
}
```

### Widget Testing Pattern
```dart
void main() {
  group('FeatureScreen', () {
    late MockFeatureProvider mockProvider;
    
    setUp(() {
      mockProvider = MockFeatureProvider();
    });
    
    testWidgets('should display loading indicator when loading', (WidgetTester tester) async {
      // Arrange
      when(mockProvider.isLoading).thenReturn(true);
      when(mockProvider.items).thenReturn([]);
      when(mockProvider.error).thenReturn(null);
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<FeatureProvider>.value(
            value: mockProvider,
            child: const FeatureScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('should display items when loaded', (WidgetTester tester) async {
      // Arrange
      final items = [FeatureModel(name: 'Test Item')];
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.items).thenReturn(items);
      when(mockProvider.error).thenReturn(null);
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<FeatureProvider>.value(
            value: mockProvider,
            child: const FeatureScreen(),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Test Item'), findsOneWidget);
    });
  });
}
```

## Performance Patterns

### Lazy Loading Pattern
```dart
class LazyListView extends StatefulWidget {
  const LazyListView({Key? key}) : super(key: key);
  
  @override
  State<LazyListView> createState() => _LazyListViewState();
}

class _LazyListViewState extends State<LazyListView> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Load more items
      Provider.of<FeatureProvider>(context, listen: false).loadMoreItems();
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<FeatureProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          controller: _scrollController,
          itemCount: provider.items.length + (provider.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < provider.items.length) {
              return ItemWidget(item: provider.items[index]);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }
}
```

### Memoization Pattern
```dart
class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({Key? key, required this.data}) : super(key: key);
  
  final List<DataModel> data;
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _ExpensiveItem(data: data[index]);
      },
    );
  }
}

class _ExpensiveItem extends StatelessWidget {
  const _ExpensiveItem({Key? key, required this.data}) : super(key: key);
  
  final DataModel data;
  
  @override
  Widget build(BuildContext context) {
    // Expensive calculation - will only run when data changes
    final processedData = _processData(data);
    
    return Card(
      child: ListTile(
        title: Text(processedData.title),
        subtitle: Text(processedData.subtitle),
      ),
    );
  }
  
  ProcessedData _processData(DataModel data) {
    // Expensive processing here
    return ProcessedData(
      title: data.name.toUpperCase(),
      subtitle: data.description?.substring(0, 50) ?? '',
    );
  }
}
```

## Naming Conventions

### File Naming
- **Screens**: `feature_screen.dart` (e.g., `project_list_screen.dart`)
- **Widgets**: `feature_widget.dart` (e.g., `project_card.dart`)
- **Providers**: `feature_provider.dart` (e.g., `project_provider.dart`)
- **Models**: `feature_model.dart` (e.g., `project_model.dart`)
- **Services**: `feature_service.dart` (e.g., `database_helper.dart`)
- **Utils**: `feature_utils.dart` (e.g., `formatters.dart`)

### Class Naming
```dart
// Screens
class ProjectListScreen extends StatefulWidget {}

// Widgets
class ProjectCard extends StatelessWidget {}

// Providers
class ProjectProvider extends ChangeNotifier {}

// Models
class Project {}

// Services
class DatabaseHelper {}

// Exceptions
class DatabaseException extends StudyTrackerException {}
```

### Variable Naming
```dart
// Private variables
String _privateVariable;
List<Project> _projects;

// Public getters
List<Project> get projects => List.unmodifiable(_projects);

// Boolean variables
bool isLoading;
bool hasError;
bool canEdit;

// Collections
List<Project> projects;
Map<int, Task> taskMap;
Set<String> uniqueNames;
```

### Method Naming
```dart
// Actions/operations
void addProject();
Future<void> loadProjects();
void deleteProject();
void updateProject();

// Getters/queries
Project? getProjectById(int id);
List<Task> getTasksForProject(int projectId);

// Validators
bool isValidProjectName(String name);
bool canDeleteProject(Project project);

// Private helpers
void _notifyListeners();
void _setError(String error);
void _clearCache();
```

### Constants Naming
```dart
// File: constants/app_constants.dart
class AppConstants {
  static const String appName = 'Study Tracker';
  static const int defaultSessionDuration = 25;
  static const Duration animationDuration = Duration(milliseconds: 300);
}

// File: constants/database_constants.dart
class DatabaseConstants {
  static const String projectsTable = 'projects';
  static const String tasksTable = 'tasks';
  static const String sessionsTable = 'sessions';
  static const int databaseVersion = 1;
}
```

These patterns should be followed consistently throughout the codebase to maintain readability, maintainability, and consistency across the Study Tracker Mobile application.
