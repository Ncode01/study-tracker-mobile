# Contributing to Study Tracker Mobile 🤝

Thank you for your interest in contributing to Study Tracker Mobile! This document provides guidelines and information for contributors.

## 📋 Table of Contents

- [Code of Conduct](#-code-of-conduct)
- [Getting Started](#-getting-started)
- [Development Workflow](#-development-workflow)
- [Code Style Guidelines](#-code-style-guidelines)
- [Testing Requirements](#-testing-requirements)
- [Pull Request Process](#-pull-request-process)
- [Issue Guidelines](#-issue-guidelines)
- [Feature Requests](#-feature-requests)

---

---

## 🚀 Getting Started

### Prerequisites

Before contributing, ensure you have:

- Flutter SDK 3.29.0 or higher
- Dart SDK 3.7.0 or higher
- Git installed and configured
- Your preferred IDE (VS Code, Android Studio, IntelliJ)
- Android/iOS development tools set up

### Setting Up Development Environment

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/study-tracker-mobile.git
   cd study-tracker-mobile
   ```

2. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/Ncode01/study-tracker-mobile.git
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Verify setup**
   ```bash
   flutter doctor
   flutter test
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

---

## 🔄 Development Workflow

### Branch Strategy

We use **Git Flow** with the following branch types:

- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: New features or enhancements
- `bugfix/*`: Bug fixes
- `hotfix/*`: Critical fixes for production
- `release/*`: Release preparation

### Workflow Steps

1. **Create a feature branch**
   ```bash
   git checkout develop
   git pull upstream develop
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow code style guidelines
   - Add tests for new functionality
   - Update documentation if needed

3. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add new timer functionality"
   ```

4. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Create a Pull Request**
   - From your fork to the upstream `develop` branch
   - Fill out the PR template completely
   - Link any related issues

### Commit Message Convention

We follow the **Conventional Commits** specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

#### Examples

```bash
feat(timer): add pause functionality to study timer
fix(database): resolve session duration calculation bug
docs(readme): update installation instructions
style(projects): format project list item widget
refactor(providers): simplify state management logic
test(models): add unit tests for project model
chore(deps): update flutter dependencies
```

---

## 🎨 Code Style Guidelines

### Dart/Flutter Conventions

#### 1. Naming Conventions

```dart
// Classes: PascalCase
class ProjectProvider extends ChangeNotifier { }

// Variables and methods: camelCase
String projectName = 'Flutter Study';
void fetchProjects() { }

// Constants: lowerCamelCase with const
const Color primaryColor = Colors.teal;

// Private members: leading underscore
String _privateVariable;
void _privateMethod() { }

// Files: snake_case
project_provider.dart
add_project_screen.dart
```

#### 2. Code Organization

```dart
// Import order: Dart, Flutter, packages, relative
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/project_model.dart';
import '../services/database_helper.dart';
```

#### 3. Widget Structure

```dart
class ProjectListItem extends StatelessWidget {
  /// Documentation for the widget purpose
  const ProjectListItem({
    super.key,
    required this.project,
  });

  /// The project to display
  final Project project;

  @override
  Widget build(BuildContext context) {
    // Implementation
  }
}
```

#### 4. Documentation

```dart
/// A comprehensive description of the class or method.
///
/// Provide usage examples if helpful:
/// ```dart
/// final project = Project(
///   id: 'uuid',
///   name: 'Flutter Development',
/// );
/// ```
class Project {
  /// Creates a new [Project] instance.
  const Project({
    required this.id,
    required this.name,
  });

  /// The unique identifier for this project.
  final String id;

  /// The display name of the project.
  final String name;
}
```

### Code Formatting

- Use `dart format` to format code automatically
- Line length: 80 characters (can extend to 100 for readability)
- Use trailing commas for better diffs
- Prefer `const` constructors when possible

```bash
# Format all Dart files
dart format .

# Check formatting without changing files
dart format --output=none --set-exit-if-changed .
```

### Widget Best Practices

1. **Prefer StatelessWidget** when possible
2. **Use const constructors** for performance
3. **Extract complex widgets** into separate classes
4. **Use meaningful names** for widgets and variables
5. **Avoid deep widget nesting** (max 3-4 levels)

```dart
// Good: Extracted widget
class ProjectProgressIndicator extends StatelessWidget {
  const ProjectProgressIndicator({
    super.key,
    required this.progress,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(value: progress);
  }
}

// Usage
const ProjectProgressIndicator(progress: 0.75)
```

---

## 🧪 Testing Requirements

### Testing Strategy

1. **Unit Tests**: Business logic, models, utilities
2. **Widget Tests**: UI components and interactions
3. **Integration Tests**: End-to-end workflows

### Test Structure

```
test/
├── unit/
│   ├── models/
│   │   ├── project_model_test.dart
│   │   ├── task_model_test.dart
│   │   └── session_model_test.dart
│   ├── providers/
│   │   ├── project_provider_test.dart
│   │   └── task_provider_test.dart
│   ├── services/
│   │   └── database_helper_test.dart
│   └── utils/
│       └── formatters_test.dart
├── widget/
│   ├── project_list_item_test.dart
│   ├── task_list_item_test.dart
│   └── timer_controls_test.dart
└── integration/
    ├── app_test.dart
    └── project_workflow_test.dart
```

### Writing Tests

#### Unit Test Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:study/src/models/project_model.dart';

void main() {
  group('Project Model', () {
    test('should create project with required fields', () {
      // Arrange
      const project = Project(
        id: 'test-id',
        name: 'Test Project',
        color: Colors.blue,
        goalMinutes: 120,
        loggedMinutes: 60,
      );

      // Assert
      expect(project.id, 'test-id');
      expect(project.name, 'Test Project');
      expect(project.goalMinutes, 120);
      expect(project.loggedMinutes, 60);
    });

    test('should convert to map correctly', () {
      // Arrange
      const project = Project(
        id: 'test-id',
        name: 'Test Project',
        color: Colors.blue,
        goalMinutes: 120,
        loggedMinutes: 60,
      );

      // Act
      final map = project.toMap();

      // Assert
      expect(map['id'], 'test-id');
      expect(map['name'], 'Test Project');
      expect(map['goalMinutes'], 120);
      expect(map['loggedMinutes'], 60);
    });
  });
}
```

#### Widget Test Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:study/src/features/projects/widgets/project_list_item.dart';
import 'package:study/src/models/project_model.dart';

void main() {
  group('ProjectListItem Widget', () {
    testWidgets('should display project name and progress', (tester) async {
      // Arrange
      const project = Project(
        id: 'test-id',
        name: 'Test Project',
        color: Colors.blue,
        goalMinutes: 120,
        loggedMinutes: 60,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProjectListItem(project: project),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Project'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });
  });
}
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/models/project_model_test.dart

# Run tests with coverage
flutter test --coverage

# Generate coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
```

### Test Requirements for PRs

- All new features must have corresponding tests
- Existing tests must continue to pass
- Aim for >80% code coverage for new code
- Integration tests for complete user workflows

---

## 📝 Pull Request Process

### Before Creating a PR

1. **Ensure your code follows style guidelines**
   ```bash
   dart format .
   dart analyze
   ```

2. **Run all tests**
   ```bash
   flutter test
   ```

3. **Update documentation** if needed

4. **Rebase on latest develop**
   ```bash
   git checkout develop
   git pull upstream develop
   git checkout feature/your-feature
   git rebase develop
   ```

### PR Template

Use the following template when creating a pull request:

```markdown
## Description
Brief description of changes and motivation.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Changes Made
- List key changes
- Include any breaking changes
- Mention new dependencies

## Testing
- [ ] Added unit tests for new functionality
- [ ] Added widget tests for UI changes
- [ ] All existing tests pass
- [ ] Manual testing completed

## Screenshots (if applicable)
Include screenshots for UI changes.

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] No new warnings or errors
```

### Review Process

1. **Automated checks** must pass (CI/CD pipeline)
2. **Code review** by at least one maintainer
3. **Testing** of new functionality
4. **Documentation review** if applicable
5. **Final approval** and merge

### Feedback and Revisions

- Address all review comments
- Make requested changes in new commits
- Update tests if functionality changes
- Re-request review after changes

---

## 🐛 Issue Guidelines

### Before Creating an Issue

1. **Search existing issues** to avoid duplicates
2. **Check documentation** for common solutions
3. **Update to latest version** if possible
4. **Gather relevant information** (device, OS, Flutter version)

### Bug Report Template

```markdown
## Bug Description
A clear and concise description of the bug.

## Steps to Reproduce
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

## Expected Behavior
What you expected to happen.

## Actual Behavior
What actually happened.

## Screenshots
If applicable, add screenshots to help explain your problem.

## Environment
- Device: [e.g., Pixel 6, iPhone 13]
- OS: [e.g., Android 12, iOS 15]
- Flutter Version: [e.g., 3.29.0]
- App Version: [e.g., 1.0.0]

## Additional Context
Add any other context about the problem here.
```

### Issue Labels

- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Improvements or additions to documentation
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention is needed
- `question`: Further information is requested
- `wontfix`: This will not be worked on

---

## 💡 Feature Requests

### Feature Request Template

```markdown
## Feature Description
A clear and concise description of the feature you'd like to see.

## Problem Statement
What problem does this feature solve?

## Proposed Solution
Describe your preferred solution.

## Alternatives Considered
Describe any alternative solutions you've considered.

## Additional Context
Add any other context, mockups, or examples.

## Implementation Notes
Any technical considerations or constraints.
```

### Feature Development Process

1. **Create feature request issue**
2. **Community discussion** and feedback
3. **Design and architecture planning**
4. **Implementation in feature branch**
5. **Testing and review**
6. **Documentation updates**
7. **Release planning**

---

## 🏆 Recognition

### Contributors

All contributors will be recognized in:
- `CONTRIBUTORS.md` file
- Release notes
- Project documentation

### Types of Contributions

- Code contributions (features, bug fixes)
- Documentation improvements
- Issue reports and feedback
- Testing and quality assurance
- Design and UX improvements
- Community support and moderation

---

## 📞 Getting Help

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and community chat
- **Email**: [maintainer-email] for private matters

### Quick Help

- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Review [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for usage examples
- Look at existing code for patterns and examples

---

## 📄 License

By contributing to this project, you agree that your contributions will be licensed under the same license as the project (MIT License).

---

**Thank you for contributing to Study Tracker Mobile! 🚀**
