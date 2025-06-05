# Study Tracker Mobile 📚⏱️

A beautiful, feature-rich Flutter mobile application for tracking study sessions, managing projects, and monitoring productivity. Built with a modern dark theme and intuitive user interface.

![Flutter](https://img.shields.io/badge/Flutter-3.29.0-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.7.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## ✨ Features

### 📁 Project Management
- Create and manage study projects with custom colors
- Set goal durations and track progress
- Monitor completion percentages
- Organize projects with due dates

### ⏲️ Time Tracking
- Built-in timer for study sessions
- Real-time session tracking
- Automatic session recording
- Visual progress indicators

### ✅ Task Management
- Create tasks linked to projects
- Mark tasks as completed
- Filter between open and completed tasks
- Set due dates for tasks

### 📊 Session History
- Detailed session logs
- Duration tracking
- Project-based session grouping
- Historical data visualization

### 🎨 Modern UI/UX
- Dark theme optimized for long study sessions
- Intuitive bottom navigation
- Smooth animations and transitions
- Material Design principles

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.29.0 or higher
- Dart SDK 3.7.0 or higher
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Ncode01/study-tracker-mobile.git
   cd study-tracker-mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                 # Application entry point
├── src/
    ├── app.dart              # Root widget configuration
    ├── constants/            # Theme and color constants
    │   ├── app_colors.dart
    │   └── app_theme.dart
    ├── features/             # Feature-based modules
    │   ├── core_ui/          # Main navigation
    │   ├── projects/         # Project management
    │   ├── tasks/            # Task management
    │   ├── timer/            # Timer functionality
    │   ├── sessions/         # Session tracking
    │   ├── stats/            # Statistics (future)
    │   └── add_item/         # Modal for adding items
    ├── models/               # Data models
    │   ├── project_model.dart
    │   ├── task_model.dart
    │   └── session_model.dart
    ├── services/             # Business logic services
    │   └── database_helper.dart
    └── utils/                # Utility functions
        └── formatters.dart
```

### Design Patterns
- **Feature-First Architecture**: Organized by features for scalability
- **Provider Pattern**: State management using `provider` package
- **Repository Pattern**: Database operations abstracted through DatabaseHelper
- **Singleton Pattern**: Single database instance management

## 📦 Dependencies

### Core Dependencies
- **flutter**: ^3.29.0 - Flutter framework
- **provider**: ^6.1.5 - State management
- **sqflite**: ^2.4.2 - SQLite database
- **uuid**: ^4.5.1 - Unique ID generation
- **intl**: ^0.20.2 - Internationalization and date formatting
- **path_provider**: ^2.1.5 - File system paths
- **path**: ^1.9.1 - Path manipulation utilities

### Development Dependencies
- **flutter_test**: SDK - Testing framework
- **flutter_lints**: ^5.0.0 - Dart linting rules

## 🗄️ Database Schema

### Projects Table
```sql
CREATE TABLE projects (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  color INTEGER NOT NULL,
  goalMinutes INTEGER NOT NULL,
  loggedMinutes INTEGER DEFAULT 0,
  dueDate TEXT
);
```

### Tasks Table
```sql
CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  projectId TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  dueDate TEXT,
  isCompleted INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY(projectId) REFERENCES projects(id) ON DELETE CASCADE
);
```

### Sessions Table
```sql
CREATE TABLE sessions (
  id TEXT PRIMARY KEY,
  projectId TEXT NOT NULL,
  projectName TEXT NOT NULL,
  startTime TEXT NOT NULL,
  endTime TEXT NOT NULL,
  durationMinutes INTEGER NOT NULL
);
```

## 🎯 Usage Examples

### Creating a Project
```dart
final project = Project(
  id: uuid.v4(),
  name: 'Flutter Development',
  color: Colors.teal,
  goalMinutes: 120,
  loggedMinutes: 0,
  dueDate: DateTime.now().add(Duration(days: 7)),
);
await projectProvider.addProject(project);
```

### Starting a Timer
```dart
final timerProvider = Provider.of<TimerServiceProvider>(context);
timerProvider.startTimer(project, context);
```

### Adding a Task
```dart
final task = Task(
  id: uuid.v4(),
  projectId: selectedProject.id,
  title: 'Complete Chapter 5',
  description: 'Read and take notes on Flutter widgets',
  dueDate: DateTime.now().add(Duration(days: 3)),
);
await taskProvider.addTask(task);
```

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

Run widget tests:
```bash
flutter test test/widget_test.dart
```

## 📱 Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

### Development Workflow
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass (`flutter test`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## 📋 Roadmap

### Upcoming Features
- [ ] Statistics and analytics dashboard
- [ ] Data export functionality
- [ ] Cloud synchronization
- [ ] Study streak tracking
- [ ] Notification system
- [ ] Dark/Light theme toggle
- [ ] Widget customization

### Known Issues
- Stats screen is currently a placeholder
- No data backup/restore functionality
- Limited filtering options in project list

## 🛠️ Troubleshooting

### Common Issues

**Build Issues**
```bash
flutter clean
flutter pub get
flutter run
```

**Database Issues**
- Clear app data if experiencing database corruption
- Check SQLite version compatibility

**Performance Issues**
- Use `flutter run --profile` for performance analysis
- Monitor widget rebuilds using Flutter Inspector

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for UI guidelines
- Community contributors and feedback

## 📚 Documentation

For comprehensive project documentation, visit the [`docs/`](docs/) folder:

- **[📋 Documentation Index](docs/INDEX.md)** - Complete documentation navigation
- **[🏗️ Architecture Guide](docs/ARCHITECTURE.md)** - System design and patterns
- **[📖 API Documentation](docs/API_DOCUMENTATION.md)** - Complete code reference
- **[🤝 Contributing Guide](docs/CONTRIBUTING.md)** - Development workflow
- **[🚀 Deployment Guide](docs/DEPLOYMENT.md)** - Build and release process
- **[🔧 Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[🔒 Security Audit](docs/SECURITY_AUDIT.md)** - Security assessment
- **[⚡ Performance Analysis](docs/PERFORMANCE_ANALYSIS.md)** - Optimization guide
- **[📊 Executive Summary](docs/EXECUTIVE_SUMMARY.md)** - Strategic overview

## 📞 Support

- Create an issue for bug reports
- Start a discussion for feature requests
- Check [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for common solutions

---

**Made with ❤️ and Flutter**
