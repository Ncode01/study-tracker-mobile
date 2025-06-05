# Deployment Guide

This guide covers building, configuring, and deploying the Study Tracker Mobile application across different platforms.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Build Configurations](#build-configurations)
- [Platform-Specific Deployment](#platform-specific-deployment)
- [Release Process](#release-process)
- [Environment Management](#environment-management)
- [Performance Optimization](#performance-optimization)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Development Environment
- Flutter SDK 3.29.0 or higher
- Dart SDK 3.7.0 or higher
- Android Studio or VS Code with Flutter extensions
- Git for version control

### Platform-Specific Requirements

#### Android
- Android SDK 34
- Java JDK 17 or higher
- Android Studio with Android SDK Tools
- Android NDK (for native dependencies)

#### iOS
- Xcode 15.0 or higher
- macOS 12.0 or higher
- iOS deployment target 12.0+
- Apple Developer Account (for App Store deployment)

#### Web
- Chrome browser for testing
- Web server for hosting (optional)

#### Desktop (Windows/Linux/macOS)
- Platform-specific build tools
- CMake 3.10 or higher (Linux/Windows)

## Build Configurations

### Debug Build
```bash
# Clean previous builds
flutter clean
flutter pub get

# Debug build for testing
flutter run --debug
```

### Release Build
```bash
# Generate release builds
flutter build apk --release                 # Android APK
flutter build appbundle --release           # Android App Bundle (recommended)
flutter build ios --release                 # iOS
flutter build web --release                 # Web
flutter build windows --release             # Windows
flutter build linux --release               # Linux
flutter build macos --release               # macOS
```

### Profile Build (Performance Testing)
```bash
flutter build apk --profile
flutter run --profile
```

## Platform-Specific Deployment

### Android Deployment

#### 1. Configure App Signing
Create `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=path/to/your/keystore.jks
```

#### 2. Update `android/app/build.gradle.kts`
```kotlin
android {
    signingConfigs {
        release {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

#### 3. Build Release APK/AAB
```bash
# APK for direct installation
flutter build apk --release

# App Bundle for Play Store (recommended)
flutter build appbundle --release
```

#### 4. Google Play Store Deployment
1. Create Play Console account
2. Upload AAB file to Play Console
3. Complete store listing information
4. Set up app signing by Google Play
5. Release to internal testing first
6. Proceed to production after testing

### iOS Deployment

#### 1. Configure Xcode Project
```bash
# Open iOS project in Xcode
open ios/Runner.xcworkspace
```

#### 2. Set Bundle Identifier and Team
- Select Runner project
- Update Bundle Identifier: `com.yourcompany.studytracker`
- Select Development Team

#### 3. Build and Archive
```bash
# Build iOS release
flutter build ios --release

# Create archive in Xcode
# Product > Archive
```

#### 4. App Store Deployment
1. Use Xcode Organizer to upload to App Store Connect
2. Complete app metadata in App Store Connect
3. Submit for review
4. Release after approval

### Web Deployment

#### 1. Build Web Release
```bash
flutter build web --release
```

#### 2. Deploy to Web Server
```bash
# Copy build/web contents to your web server
# Example: Deploy to Firebase Hosting
firebase deploy

# Example: Deploy to GitHub Pages
# Copy build/web/* to gh-pages branch
```

#### 3. Configure Web Server
Ensure your web server serves `index.html` for all routes (SPA routing).

### Desktop Deployment

#### Windows
```bash
# Build Windows executable
flutter build windows --release

# Package with installer (optional)
# Use tools like Inno Setup or NSIS
```

#### Linux
```bash
# Build Linux executable
flutter build linux --release

# Create AppImage or snap package (optional)
```

#### macOS
```bash
# Build macOS app
flutter build macos --release

# Code sign and notarize for distribution
codesign --deep --force --verify --verbose --sign "Developer ID Application: Your Name" build/macos/Build/Products/Release/study_tracker.app
```

## Release Process

### Version Management

#### 1. Update Version Numbers
In `pubspec.yaml`:
```yaml
version: 1.2.0+3  # version+build_number
```

#### 2. Update Changelog
Create/update `CHANGELOG.md`:
```markdown
## [1.2.0] - 2024-XX-XX
### Added
- New feature descriptions

### Changed
- Modified feature descriptions

### Fixed
- Bug fix descriptions
```

#### 3. Git Tagging
```bash
git add .
git commit -m "Release version 1.2.0"
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin main --tags
```

### Automated Release Pipeline

#### GitHub Actions Example
Create `.github/workflows/release.yml`:
```yaml
name: Release Build
on:
  push:
    tags:
      - 'v*'

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.0'
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk --release
      - run: flutter build appbundle --release
      - uses: actions/upload-artifact@v3
        with:
          name: android-release
          path: |
            build/app/outputs/flutter-apk/app-release.apk
            build/app/outputs/bundle/release/app-release.aab

  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.0'
      - run: flutter pub get
      - run: flutter test
      - run: flutter build ios --release --no-codesign
      - uses: actions/upload-artifact@v3
        with:
          name: ios-release
          path: build/ios/iphoneos/Runner.app
```

## Environment Management

### Configuration Files

#### 1. Environment-Specific Configs
Create environment configuration files:
- `lib/src/config/dev_config.dart`
- `lib/src/config/prod_config.dart`

```dart
// lib/src/config/app_config.dart
class AppConfig {
  static const String environment = String.fromEnvironment('ENV', defaultValue: 'dev');
  static const bool isProduction = environment == 'production';
  static const bool enableLogging = !isProduction;
  
  // Database configuration
  static const String databaseName = isProduction ? 'study_tracker.db' : 'study_tracker_dev.db';
  
  // API endpoints (if any)
  static const String baseUrl = isProduction 
    ? 'https://api.studytracker.com'
    : 'https://dev-api.studytracker.com';
}
```

#### 2. Build-Time Configuration
```bash
# Build with environment variables
flutter build apk --release --dart-define=ENV=production
flutter build ios --release --dart-define=ENV=production
```

### Secrets Management

#### 1. Environment Variables
```bash
# .env file (not committed to git)
DATABASE_ENCRYPTION_KEY=your_secret_key
API_KEY=your_api_key
```

#### 2. Secure Storage
Use `flutter_secure_storage` for sensitive data:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  
  static Future<void> storeApiKey(String apiKey) async {
    await _storage.write(key: 'api_key', value: apiKey);
  }
  
  static Future<String?> getApiKey() async {
    return await _storage.read(key: 'api_key');
  }
}
```

## Performance Optimization

### Build Optimization

#### 1. Code Splitting
```bash
# Enable code splitting for web
flutter build web --split-per-route
```

#### 2. Tree Shaking
```bash
# Optimize bundle size
flutter build apk --release --tree-shake-icons
flutter build web --release --tree-shake-icons
```

#### 3. Obfuscation
```bash
# Obfuscate Dart code (Android/iOS)
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
flutter build ios --release --obfuscate --split-debug-info=build/debug-info
```

### Asset Optimization

#### 1. Image Optimization
- Use appropriate image formats (WebP for web, optimized PNG/JPEG)
- Provide multiple resolution assets (1x, 2x, 3x)
- Compress images before adding to assets

#### 2. Font Optimization
```yaml
# pubspec.yaml - only include needed font weights
flutter:
  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
```

## Database Migration

### Version Management
```dart
// lib/src/services/database_helper.dart
class DatabaseHelper {
  static const int _databaseVersion = 2;
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration from version 1 to 2
      await db.execute('ALTER TABLE projects ADD COLUMN description TEXT');
    }
  }
}
```

### Backup and Restore
```dart
class DatabaseBackupService {
  static Future<void> createBackup() async {
    final dbPath = await DatabaseHelper.getDatabasePath();
    final backupPath = '${dbPath}_backup_${DateTime.now().millisecondsSinceEpoch}';
    
    final dbFile = File(dbPath);
    await dbFile.copy(backupPath);
  }
  
  static Future<void> restoreBackup(String backupPath) async {
    final dbPath = await DatabaseHelper.getDatabasePath();
    final backupFile = File(backupPath);
    await backupFile.copy(dbPath);
  }
}
```

## Troubleshooting

### Common Build Issues

#### 1. Dependency Conflicts
```bash
# Clear dependency cache
flutter clean
flutter pub deps
flutter pub cache repair
```

#### 2. Gradle Build Issues (Android)
```bash
# Clean Gradle cache
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### 3. iOS Build Issues
```bash
# Clean iOS build
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

### Platform-Specific Issues

#### Android
- **Issue**: App crashes on older devices
- **Solution**: Check minimum SDK version, test on various API levels

#### iOS
- **Issue**: App rejected for missing privacy descriptions
- **Solution**: Add required NSUsageDescription keys to Info.plist

#### Web
- **Issue**: CORS errors when accessing local storage
- **Solution**: Configure web server CORS headers properly

### Performance Issues

#### 1. Large APK Size
- Enable R8 optimization
- Use app bundles instead of APKs
- Remove unused resources

#### 2. Slow App Startup
- Implement lazy loading
- Optimize main() function
- Use splash screen effectively

#### 3. Memory Leaks
- Dispose controllers properly
- Use proper lifecycle management
- Monitor memory usage with Flutter Inspector

## Monitoring and Analytics

### Crash Reporting
Consider integrating crash reporting:
```yaml
dependencies:
  firebase_crashlytics: ^3.4.8
```

### Performance Monitoring
```yaml
dependencies:
  firebase_performance: ^0.9.3+8
```

### Usage Analytics
```yaml
dependencies:
  firebase_analytics: ^10.7.4
```

## Security Considerations

### 1. Data Protection
- Encrypt sensitive local data
- Use secure storage for credentials
- Implement proper session management

### 2. Code Protection
- Enable code obfuscation
- Remove debug information from release builds
- Use certificate pinning for network requests

### 3. Permission Management
- Request minimal necessary permissions
- Explain permission usage to users
- Handle permission denials gracefully

## Support and Maintenance

### Post-Release Checklist
- [ ] Monitor crash reports
- [ ] Check app store reviews
- [ ] Monitor performance metrics
- [ ] Plan for regular updates
- [ ] Maintain backward compatibility
- [ ] Document known issues

### Update Strategy
- Regular security updates
- Feature updates based on user feedback
- Performance optimizations
- Platform API updates

---

For additional support, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md) or create an issue in the repository.
