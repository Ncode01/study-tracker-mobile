# Troubleshooting Guide

This guide helps resolve common issues encountered while developing, building, or using the Study Tracker Mobile application.

## Table of Contents

- [General Issues](#general-issues)
- [Development Environment](#development-environment)
- [Build Issues](#build-issues)
- [Runtime Issues](#runtime-issues)
- [Database Issues](#database-issues)
- [Performance Issues](#performance-issues)
- [Platform-Specific Issues](#platform-specific-issues)
- [Testing Issues](#testing-issues)
- [Debug Tools and Techniques](#debug-tools-and-techniques)

## General Issues

### App Won't Start

#### Symptoms
- App crashes immediately on launch
- White screen or blank display
- Loading indicator never disappears

#### Diagnosis
```bash
# Check logs for errors
flutter logs

# Run in debug mode for detailed output
flutter run --debug --verbose
```

#### Solutions
1. **Clear app data and restart**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Check for initialization errors**
   - Verify database initialization in `main.dart`
   - Check provider setup in `app.dart`
   - Ensure all required permissions are granted

3. **Database corruption**
   ```bash
   # Clear app data (will lose all user data)
   # Android
   adb shell pm clear com.example.study_tracker
   
   # iOS Simulator
   # Device Settings > General > iPhone Storage > Study Tracker > Offload App
   ```

### Data Not Persisting

#### Symptoms
- Data disappears between app sessions
- Settings reset to defaults
- Projects/tasks not saved

#### Diagnosis
```dart
// Add debug logging to database operations
print('Saving project: ${project.toJson()}');
print('Database path: ${await DatabaseHelper.getDatabasePath()}');
```

#### Solutions
1. **Check database initialization**
   ```dart
   // Verify in database_helper.dart
   Future<Database> get database async {
     if (_database != null) return _database!;
     _database = await _initDatabase();
     return _database!;
   }
   ```

2. **Verify write permissions**
   - Check app has storage permissions (Android)
   - Verify database directory is writable

3. **Check for transaction errors**
   ```dart
   // Wrap database operations in try-catch
   try {
     await db.insert('projects', project.toJson());
   } catch (e) {
     print('Database insert error: $e');
   }
   ```

## Development Environment

### Flutter Doctor Issues

#### Common Flutter Doctor Warnings
```bash
flutter doctor -v
```

1. **Android License Not Accepted**
   ```bash
   flutter doctor --android-licenses
   ```

2. **Android SDK Command-line Tools Missing**
   ```bash
   # Install via Android Studio SDK Manager
   # Or via command line
   $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "cmdline-tools;latest"
   ```

3. **Xcode Issues (macOS)**
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

### IDE Configuration Issues

#### VS Code Flutter Extension
```json
// .vscode/settings.json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.debugExternalPackageLibraries": true,
  "dart.debugSdkLibraries": true
}
```

#### Android Studio Setup
- Ensure Flutter and Dart plugins are installed
- Configure Flutter SDK path in settings
- Enable Dart analysis server

## Build Issues

### Android Build Failures

#### Gradle Build Failed
```bash
# Common Gradle issues
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### Dependency Version Conflicts
```bash
# Check dependency tree
flutter pub deps

# Update dependencies
flutter pub upgrade
```

#### Missing Android SDK
```bash
# Set ANDROID_HOME environment variable
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

#### Build Tools Version Issues
```kotlin
// android/app/build.gradle
android {
    compileSdkVersion 34
    buildToolsVersion "34.0.0"
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### iOS Build Failures

#### CocoaPods Issues
```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install --repo-update
cd ..
flutter clean
flutter pub get
```

#### Code Signing Issues
```bash
# Check available signing identities
security find-identity -v -p codesigning

# Clear derived data
rm -rf ~/Library/Developer/Xcode/DerivedData
```

#### Deployment Target Issues
```ruby
# ios/Podfile
platform :ios, '12.0'
```

### Web Build Issues

#### CanvasKit Loading Issues
```bash
# Use HTML renderer instead
flutter build web --web-renderer html
```

#### CORS Issues During Development
```bash
# Run with CORS disabled (development only)
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

## Runtime Issues

### Provider State Issues

#### State Not Updating
```dart
// Ensure proper notifyListeners() calls
class ProjectProvider extends ChangeNotifier {
  void addProject(Project project) {
    _projects.add(project);
    notifyListeners(); // Don't forget this!
  }
}
```

#### Provider Not Found Error
```dart
// Ensure provider is properly registered
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ProjectProvider()),
    ChangeNotifierProvider(create: (_) => TaskProvider()),
    // Add all required providers
  ],
  child: MyApp(),
)
```

### Navigation Issues

#### Navigation Stack Problems
```dart
// Clear navigation stack
Navigator.of(context).pushNamedAndRemoveUntil(
  '/home',
  (Route<dynamic> route) => false,
);
```

#### Route Not Found
```dart
// Check route definitions in app.dart
routes: {
  '/': (context) => const HomeScreen(),
  '/projects': (context) => const ProjectListScreen(),
  // Ensure all routes are defined
}
```

### Timer Issues

#### Timer Not Stopping
```dart
// Ensure proper timer disposal
class TimerService extends ChangeNotifier {
  Timer? _timer;
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
```

#### Background Timer Issues
```dart
// Use WidgetsBindingObserver for app lifecycle
class TimerService extends ChangeNotifier with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Save timer state
    } else if (state == AppLifecycleState.resumed) {
      // Restore timer state
    }
  }
}
```

## Database Issues

### SQLite Connection Problems

#### Database Locked Error
```dart
// Ensure proper database closing
Future<void> closeDatabase() async {
  if (_database != null) {
    await _database!.close();
    _database = null;
  }
}
```

#### Concurrent Access Issues
```dart
// Use database mutex for concurrent operations
import 'package:synchronized/synchronized.dart';

class DatabaseHelper {
  static final _lock = Lock();
  
  Future<List<Map<String, dynamic>>> query(String table) async {
    return await _lock.synchronized(() async {
      final db = await database;
      return await db.query(table);
    });
  }
}
```

### Migration Issues

#### Schema Migration Failed
```dart
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  // Add proper error handling
  try {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE projects ADD COLUMN description TEXT');
    }
  } catch (e) {
    print('Migration error: $e');
    // Handle migration failure
  }
}
```

#### Data Loss During Migration
```dart
// Create backup before migration
Future<void> _createBackup() async {
  final dbPath = await getDatabasesPath();
  final backupPath = join(dbPath, 'backup_${DateTime.now().millisecondsSinceEpoch}.db');
  
  final originalDb = File(join(dbPath, 'study_tracker.db'));
  if (await originalDb.exists()) {
    await originalDb.copy(backupPath);
  }
}
```

## Performance Issues

### Memory Leaks

#### Provider Memory Leaks
```dart
// Always dispose providers
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late ProjectProvider _projectProvider;
  
  @override
  void initState() {
    super.initState();
    _projectProvider = ProjectProvider();
  }
  
  @override
  void dispose() {
    _projectProvider.dispose();
    super.dispose();
  }
}
```

#### Stream Subscription Leaks
```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  StreamSubscription? _subscription;
  
  @override
  void initState() {
    super.initState();
    _subscription = someStream.listen((data) {
      // Handle data
    });
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
```

### Slow List Performance

#### Large List Rendering
```dart
// Use ListView.builder for large lists
ListView.builder(
  itemCount: projects.length,
  itemBuilder: (context, index) {
    return ProjectCard(project: projects[index]);
  },
)
```

#### Unnecessary Rebuilds
```dart
// Use const constructors where possible
class ProjectCard extends StatelessWidget {
  const ProjectCard({Key? key, required this.project}) : super(key: key);
  
  final Project project;
  
  // Use const for static widgets
  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        title: Text('Static content'),
      ),
    );
  }
}
```

### Database Performance

#### Slow Queries
```dart
// Add indexes for frequently queried columns
Future<void> _createIndexes(Database db) async {
  await db.execute('CREATE INDEX idx_project_name ON projects(name)');
  await db.execute('CREATE INDEX idx_task_project_id ON tasks(project_id)');
}
```

#### Too Many Database Calls
```dart
// Batch database operations
Future<void> addMultipleProjects(List<Project> projects) async {
  final db = await database;
  final batch = db.batch();
  
  for (final project in projects) {
    batch.insert('projects', project.toJson());
  }
  
  await batch.commit();
}
```

## Platform-Specific Issues

### Android Issues

#### Permission Denied Errors
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

#### App Not Installing
```bash
# Check available storage
adb shell df

# Clear app data
adb shell pm clear com.example.study_tracker

# Reinstall
flutter install
```

#### Background Processing Issues
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

### iOS Issues

#### App Store Rejection
```xml
<!-- ios/Runner/Info.plist -->
<key>NSUserTrackingUsageDescription</key>
<string>This app does not track users.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app does not use location.</string>
```

#### Background App Refresh
```xml
<!-- ios/Runner/Info.plist -->
<key>UIBackgroundModes</key>
<array>
  <string>background-processing</string>
</array>
```

### Web Issues

#### Local Storage Not Working
```dart
// Check if storage is available
import 'dart:html' as html;

bool get isStorageAvailable {
  try {
    html.window.localStorage['test'] = 'test';
    html.window.localStorage.remove('test');
    return true;
  } catch (e) {
    return false;
  }
}
```

#### Service Worker Issues
```bash
# Clear service worker cache
# In browser DevTools: Application > Storage > Clear Storage
```

## Testing Issues

### Unit Test Failures

#### Provider Testing
```dart
// test/providers/project_provider_test.dart
void main() {
  group('ProjectProvider', () {
    late ProjectProvider provider;
    
    setUp(() {
      provider = ProjectProvider();
    });
    
    tearDown(() {
      provider.dispose();
    });
    
    test('should add project', () {
      final project = Project(name: 'Test Project');
      provider.addProject(project);
      
      expect(provider.projects.length, 1);
      expect(provider.projects.first.name, 'Test Project');
    });
  });
}
```

#### Database Testing
```dart
// Use in-memory database for testing
Future<Database> createTestDatabase() async {
  return await openDatabase(
    ':memory:',
    version: 1,
    onCreate: (db, version) {
      // Create test schema
    },
  );
}
```

### Widget Test Issues

#### Provider Testing in Widgets
```dart
testWidgets('should display projects', (WidgetTester tester) async {
  final provider = ProjectProvider();
  provider.addProject(Project(name: 'Test Project'));
  
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(
        home: ProjectListScreen(),
      ),
    ),
  );
  
  expect(find.text('Test Project'), findsOneWidget);
});
```

## Debug Tools and Techniques

### Flutter Inspector

#### Using Flutter Inspector
```bash
# Open Flutter Inspector
flutter run --debug
# Then open DevTools in browser
```

#### Memory Profiling
- Monitor widget rebuilds
- Check for memory leaks
- Analyze performance metrics

### Logging and Debug Output

#### Custom Logging
```dart
import 'dart:developer' as developer;

class Logger {
  static void log(String message, {String? name}) {
    developer.log(
      message,
      name: name ?? 'StudyTracker',
      time: DateTime.now(),
    );
  }
  
  static void error(String message, Object? error, StackTrace? stackTrace) {
    developer.log(
      message,
      name: 'StudyTracker-Error',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
```

#### Debug Flags
```dart
// lib/src/config/debug_config.dart
class DebugConfig {
  static const bool enableDebugLogging = true;
  static const bool enablePerformanceLogging = false;
  static const bool enableDatabaseLogging = true;
  
  static void log(String message) {
    if (enableDebugLogging) {
      print('[DEBUG] $message');
    }
  }
}
```

### Performance Monitoring

#### Custom Performance Tracking
```dart
class PerformanceTracker {
  static final Map<String, DateTime> _startTimes = {};
  
  static void start(String operation) {
    _startTimes[operation] = DateTime.now();
  }
  
  static void end(String operation) {
    final startTime = _startTimes[operation];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      print('$operation took ${duration.inMilliseconds}ms');
      _startTimes.remove(operation);
    }
  }
}
```

### Network Debugging (if applicable)

#### HTTP Request Logging
```dart
import 'package:dio/dio.dart';

final dio = Dio();

void setupLogging() {
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
  ));
}
```

## Getting Help

### Before Seeking Help

1. **Check this troubleshooting guide**
2. **Search existing issues** in the repository
3. **Check Flutter documentation** for platform-specific issues
4. **Review recent changes** that might have caused issues

### Creating Bug Reports

Include the following information:
- Flutter version (`flutter --version`)
- Platform and version (Android API level, iOS version, etc.)
- Device information
- Steps to reproduce
- Expected vs actual behavior
- Error logs and stack traces
- Screenshots if applicable

### Debug Information Collection
```bash
# Collect comprehensive debug info
flutter doctor -v > debug_info.txt
flutter analyze >> debug_info.txt
flutter test --reporter=json >> debug_info.txt
```

### Useful Commands for Debugging
```bash
# Clear everything and start fresh
flutter clean
flutter pub cache repair
flutter pub get

# Verbose output
flutter run --verbose

# Profile mode for performance issues
flutter run --profile

# Check for unused dependencies
flutter pub deps | grep "unused"

# Analyze code for issues
flutter analyze

# Check app size
flutter build apk --analyze-size
```

---

If you encounter an issue not covered in this guide, please check the [project issues](https://github.com/Ncode01/study-tracker-mobile/issues) or create a new issue with detailed information about the problem.
