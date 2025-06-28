# Deployment Guide

## Deployment Overview

Project Atlas Flutter mobile application deployment guide covering development, staging, and production environments across Android and iOS platforms.

## Environment Configuration

### Development Environment
- **Purpose**: Local development and testing
- **Firebase Project**: `project-atlas-dev`
- **Database**: Firestore development instance
- **Authentication**: Firebase Auth with test accounts enabled
- **Debugging**: Enabled with full logging

### Staging Environment
- **Purpose**: Pre-production testing and QA
- **Firebase Project**: `project-atlas-staging`
- **Database**: Firestore staging instance with production-like data
- **Authentication**: Firebase Auth with limited test accounts
- **Debugging**: Limited logging, crash reporting enabled

### Production Environment
- **Purpose**: Live user-facing application
- **Firebase Project**: `project-atlas-prod`
- **Database**: Firestore production instance
- **Authentication**: Firebase Auth with real user accounts only
- **Debugging**: Disabled, crash reporting and analytics enabled

## Pre-Deployment Setup

### 1. Firebase Project Configuration

#### Development Setup
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project
firebase init
```

#### Create Environment-Specific Configuration
```dart
// lib/config/app_config.dart
class AppConfig {
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
  static bool get isProduction => environment == 'production';
  
  static String get firebaseProjectId {
    switch (environment) {
      case 'staging':
        return 'project-atlas-staging';
      case 'production':
        return 'project-atlas-prod';
      default:
        return 'project-atlas-dev';
    }
  }
  
  static String get apiBaseUrl {
    switch (environment) {
      case 'staging':
        return 'https://api-staging.projectatlas.com';
      case 'production':
        return 'https://api.projectatlas.com';
      default:
        return 'https://api-dev.projectatlas.com';
    }
  }
}
```

### 2. Android Configuration

#### Environment-Specific Build Configurations
```gradle
// android/app/build.gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.projectatlas.study_tracker"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
    
    buildTypes {
        debug {
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
            manifestPlaceholders = [environment: "development"]
        }
        
        staging {
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
            manifestPlaceholders = [environment: "staging"]
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        
        release {
            manifestPlaceholders = [environment: "production"]
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    
    flavorDimensions "environment"
    productFlavors {
        development {
            dimension "environment"
            applicationIdSuffix ".dev"
        }
        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
        }
        production {
            dimension "environment"
        }
    }
}
```

#### Firebase Configuration Files
```
android/app/src/development/google-services.json
android/app/src/staging/google-services.json
android/app/src/production/google-services.json
```

#### Signing Configuration
```gradle
// android/app/build.gradle
android {
    signingConfigs {
        release {
            if (project.hasProperty('android.injected.signing.store.file')) {
                storeFile file(project.property('android.injected.signing.store.file'))
                storePassword project.property('android.injected.signing.store.password')
                keyAlias project.property('android.injected.signing.key.alias')
                keyPassword project.property('android.injected.signing.key.password')
            } else {
                storeFile file('keystore.jks')
                storePassword System.getenv('KEYSTORE_PASSWORD')
                keyAlias System.getenv('KEY_ALIAS')
                keyPassword System.getenv('KEY_PASSWORD')
            }
        }
    }
}
```

### 3. iOS Configuration

#### Xcode Project Setup
```swift
// ios/Runner/Info.plist - Development
<key>CFBundleIdentifier</key>
<string>com.projectatlas.studyTracker.dev</string>

// ios/Runner/Info.plist - Staging
<key>CFBundleIdentifier</key>
<string>com.projectatlas.studyTracker.staging</string>

// ios/Runner/Info.plist - Production
<key>CFBundleIdentifier</key>
<string>com.projectatlas.studyTracker</string>
```

#### Firebase Configuration Files
```
ios/Runner/GoogleService-Info-Development.plist
ios/Runner/GoogleService-Info-Staging.plist
ios/Runner/GoogleService-Info-Production.plist
```

#### Build Configurations
1. Open `ios/Runner.xcworkspace` in Xcode
2. Create build configurations:
   - `Debug-Development`
   - `Debug-Staging`
   - `Release-Development`
   - `Release-Staging`
   - `Release-Production`

## Build Process

### Development Builds

#### Android Development Build
```bash
# Build debug APK for development
flutter build apk --debug --flavor development -t lib/main.dart

# Build debug AAB for testing
flutter build appbundle --debug --flavor development -t lib/main.dart

# Install directly to connected device
flutter run --flavor development -t lib/main.dart
```

#### iOS Development Build
```bash
# Build for iOS simulator
flutter build ios --debug --flavor development -t lib/main.dart

# Build for physical device
flutter build ios --debug --flavor development -t lib/main.dart --codesign
```

### Staging Builds

#### Android Staging Build
```bash
# Build staging APK
flutter build apk --release --flavor staging -t lib/main.dart \
  --dart-define=ENVIRONMENT=staging

# Build staging AAB for internal testing
flutter build appbundle --release --flavor staging -t lib/main.dart \
  --dart-define=ENVIRONMENT=staging
```

#### iOS Staging Build
```bash
# Build staging IPA
flutter build ios --release --flavor staging -t lib/main.dart \
  --dart-define=ENVIRONMENT=staging

# Archive for TestFlight
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release-Staging \
  -archivePath build/Runner.xcarchive \
  archive
```

### Production Builds

#### Android Production Build
```bash
# Build production AAB for Play Store
flutter build appbundle --release --flavor production -t lib/main.dart \
  --dart-define=ENVIRONMENT=production \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols

# Build production APK (if needed)
flutter build apk --release --flavor production -t lib/main.dart \
  --dart-define=ENVIRONMENT=production \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols
```

#### iOS Production Build
```bash
# Build production IPA
flutter build ios --release --flavor production -t lib/main.dart \
  --dart-define=ENVIRONMENT=production \
  --obfuscate \
  --split-debug-info=build/ios/symbols

# Archive for App Store
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release-Production \
  -archivePath build/Runner.xcarchive \
  archive

# Export IPA
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportPath build/ \
  -exportOptionsPlist ios/ExportOptions.plist
```

## CI/CD Pipeline

### GitHub Actions Workflow

```yaml
# .github/workflows/deploy.yml
name: Deploy Project Atlas

on:
  push:
    branches: [main, develop, staging]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.3'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test

  build-android:
    needs: test
    runs-on: ubuntu-latest
    strategy:
      matrix:
        flavor: [development, staging, production]
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.3'
      - run: flutter pub get
      
      - name: Setup Android signing
        if: matrix.flavor != 'development'
        run: |
          echo '${{ secrets.KEYSTORE_BASE64 }}' | base64 --decode > android/app/keystore.jks
        
      - name: Build Android AAB
        run: |
          flutter build appbundle --release \
            --flavor ${{ matrix.flavor }} \
            --dart-define=ENVIRONMENT=${{ matrix.flavor }}
        env:
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
      
      - name: Upload AAB
        uses: actions/upload-artifact@v4
        with:
          name: android-${{ matrix.flavor }}-aab
          path: build/app/outputs/bundle/${{ matrix.flavor }}Release/*.aab

  build-ios:
    needs: test
    runs-on: macos-latest
    strategy:
      matrix:
        flavor: [development, staging, production]
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.3'
      - run: flutter pub get
      
      - name: Setup iOS certificates
        if: matrix.flavor != 'development'
        run: |
          # Import certificates and provisioning profiles
          echo '${{ secrets.IOS_CERTIFICATE }}' | base64 --decode > certificate.p12
          echo '${{ secrets.IOS_PROVISIONING_PROFILE }}' | base64 --decode > profile.mobileprovision
          
      - name: Build iOS
        run: |
          flutter build ios --release \
            --flavor ${{ matrix.flavor }} \
            --dart-define=ENVIRONMENT=${{ matrix.flavor }} \
            --no-codesign
            
      - name: Archive iOS
        if: matrix.flavor != 'development'
        run: |
          xcodebuild -workspace ios/Runner.xcworkspace \
            -scheme Runner \
            -configuration Release-${{ matrix.flavor }} \
            -archivePath build/Runner.xcarchive \
            archive
            
      - name: Upload iOS Archive
        if: matrix.flavor != 'development'
        uses: actions/upload-artifact@v4
        with:
          name: ios-${{ matrix.flavor }}-archive
          path: build/Runner.xcarchive

  deploy-staging:
    if: github.ref == 'refs/heads/staging'
    needs: [build-android, build-ios]
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Firebase App Distribution
        run: |
          # Download artifacts and deploy to Firebase App Distribution
          firebase appdistribution:distribute build/app/outputs/bundle/stagingRelease/*.aab \
            --app ${{ secrets.FIREBASE_ANDROID_APP_ID_STAGING }} \
            --groups "internal-testers"

  deploy-production:
    if: github.ref == 'refs/heads/main'
    needs: [build-android, build-ios]
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Deploy to Play Store
        run: |
          # Deploy to Play Store internal track
          fastlane supply --aab build/app/outputs/bundle/productionRelease/*.aab
          
      - name: Deploy to App Store
        run: |
          # Deploy to TestFlight
          fastlane pilot upload --ipa build/Runner.ipa
```

### Fastlane Configuration

#### Android Fastlane
```ruby
# android/fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Deploy to Play Store Internal Track"
  lane :internal do
    upload_to_play_store(
      track: 'internal',
      aab: '../build/app/outputs/bundle/productionRelease/app-production-release.aab',
      skip_upload_apk: true,
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )
  end
  
  desc "Deploy to Play Store Production"
  lane :production do
    upload_to_play_store(
      track: 'production',
      aab: '../build/app/outputs/bundle/productionRelease/app-production-release.aab',
      skip_upload_apk: true
    )
  end
end
```

#### iOS Fastlane
```ruby
# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Deploy to TestFlight"
  lane :beta do
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      configuration: "Release-Production"
    )
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end
  
  desc "Deploy to App Store"
  lane :release do
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      configuration: "Release-Production"
    )
    upload_to_app_store(
      force: true,
      submit_for_review: false
    )
  end
end
```

## Deployment Strategies

### Rolling Deployment
1. **Internal Testing** (10% of users)
   - Deploy to Firebase App Distribution
   - Monitor crash reports and user feedback
   - Duration: 2-3 days

2. **Beta Testing** (25% of users)
   - Deploy to Play Store Internal Track
   - Deploy to TestFlight
   - Monitor performance metrics
   - Duration: 1 week

3. **Staged Rollout** (50% → 100% of users)
   - Gradual rollout on Play Store
   - Monitor user adoption and feedback
   - Duration: 2 weeks

### Blue-Green Deployment
- **Blue Environment**: Current production version
- **Green Environment**: New version being deployed
- **Switch**: Instant traffic redirect after validation
- **Rollback**: Immediate switch back to blue if issues arise

### Canary Deployment
- **Canary Group**: 5% of users receive new version
- **Monitoring**: Real-time metrics and error tracking
- **Decision Point**: Roll forward or rollback based on metrics
- **Full Rollout**: If canary succeeds, deploy to all users

## Environment-Specific Configurations

### Development Environment
```dart
// lib/config/development_config.dart
class DevelopmentConfig {
  static const bool debugMode = true;
  static const bool enableTestAccounts = true;
  static const String logLevel = 'DEBUG';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  static const Map<String, String> testAccounts = {
    'test@example.com': 'password123',
    'admin@example.com': 'admin123',
  };
}
```

### Staging Environment
```dart
// lib/config/staging_config.dart
class StagingConfig {
  static const bool debugMode = false;
  static const bool enableTestAccounts = true;
  static const String logLevel = 'INFO';
  static const Duration apiTimeout = Duration(seconds: 15);
  
  static const List<String> allowedTestUsers = [
    'tester1@company.com',
    'tester2@company.com',
  ];
}
```

### Production Environment
```dart
// lib/config/production_config.dart
class ProductionConfig {
  static const bool debugMode = false;
  static const bool enableTestAccounts = false;
  static const String logLevel = 'ERROR';
  static const Duration apiTimeout = Duration(seconds: 10);
  
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
}
```

## Monitoring and Rollback

### Production Monitoring
```dart
// lib/services/monitoring_service.dart
class MonitoringService {
  static void trackDeployment(String version) {
    FirebaseCrashlytics.instance.setCustomKey('app_version', version);
    FirebaseAnalytics.instance.logEvent(
      name: 'app_deployment',
      parameters: {'version': version},
    );
  }
  
  static void trackError(String error, StackTrace stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
```

### Health Checks
```dart
// lib/services/health_check_service.dart
class HealthCheckService {
  static Future<bool> performHealthCheck() async {
    try {
      // Check Firebase connectivity
      await FirebaseFirestore.instance
          .collection('health')
          .doc('check')
          .get();
      
      // Check authentication service
      final user = FirebaseAuth.instance.currentUser;
      
      // Check critical app functionality
      return true;
    } catch (e) {
      return false;
    }
  }
}
```

### Rollback Procedures

#### Immediate Rollback (Critical Issues)
1. **Detection**: Automated alerts or manual discovery
2. **Decision**: Within 15 minutes of issue detection
3. **Execution**: Deploy previous stable version
4. **Communication**: Notify stakeholders immediately

```bash
# Emergency rollback script
#!/bin/bash
echo "Performing emergency rollback..."

# Deploy previous stable version
firebase hosting:channel:deploy --expires 1h emergency-rollback

# Notify team
slack notify "🚨 Emergency rollback initiated for Project Atlas mobile app"
```

#### Planned Rollback (Gradual Issues)
1. **Detection**: Metrics indicating performance degradation
2. **Analysis**: 2-4 hours to assess impact
3. **Decision**: Rollback or hotfix determination
4. **Execution**: Coordinated rollback with communication

### Post-Deployment Verification

#### Automated Verification
```bash
# Post-deployment verification script
#!/bin/bash

echo "Starting post-deployment verification..."

# Check app store listing
curl -f "https://play.google.com/store/apps/details?id=com.projectatlas.study_tracker"

# Verify Firebase services
firebase database:get / --project project-atlas-prod

# Run smoke tests
flutter drive --target=test_driver/smoke_test.dart

echo "Verification complete ✅"
```

#### Manual Verification Checklist
- [ ] App launches successfully
- [ ] User authentication works
- [ ] Core features functional
- [ ] No critical crashes reported
- [ ] Firebase services responding
- [ ] Analytics data flowing

## Security Considerations

### Code Obfuscation
```bash
# Build with obfuscation for production
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/symbols
```

### Certificate Management
- **Development**: Self-signed certificates
- **Staging**: Valid certificates for testing
- **Production**: Official App Store/Play Store certificates

### API Key Management
```dart
// lib/config/secrets.dart
class Secrets {
  static String get firebaseApiKey => 
    const String.fromEnvironment('FIREBASE_API_KEY');
  
  static String get analyticsKey => 
    const String.fromEnvironment('ANALYTICS_KEY');
}
```

### Build Security
- Store sensitive keys in CI/CD secrets
- Never commit certificates or private keys
- Use secure artifact storage
- Implement signature verification

## Troubleshooting

### Common Build Issues

#### Android Build Failures
```bash
# Clean build
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get

# Fix Gradle issues
cd android && ./gradlew --refresh-dependencies && cd ..

# Update dependencies
flutter pub upgrade
```

#### iOS Build Failures
```bash
# Clean iOS build
flutter clean
cd ios && rm -rf Pods Podfile.lock && cd ..
cd ios && pod install && cd ..
flutter pub get

# Fix CocoaPods issues
cd ios && pod repo update && pod install && cd ..
```

#### Firebase Configuration Issues
```bash
# Verify Firebase configuration
firebase projects:list
firebase use project-atlas-prod

# Check Firebase files
ls -la android/app/google-services.json
ls -la ios/Runner/GoogleService-Info.plist
```

### Performance Issues
- Monitor app startup time
- Check memory usage patterns
- Verify network request performance
- Track frame rendering times

### Deployment Failures
- Verify signing certificates
- Check app store credentials
- Validate app permissions
- Confirm compliance requirements

## Success Metrics

### Deployment Success Criteria
- [ ] Build completes without errors
- [ ] All automated tests pass
- [ ] Security scans show no critical issues
- [ ] Performance benchmarks within acceptable range
- [ ] Smoke tests pass in target environment

### Post-Deployment Metrics
- **Crash Rate**: < 0.1% for production
- **App Store Rating**: Maintain > 4.0 stars
- **Performance**: < 3 second startup time
- **Adoption**: > 80% users on latest version within 30 days

## Continuous Improvement

### Deployment Metrics Tracking
- Build time optimization
- Deployment frequency
- Mean time to recovery (MTTR)
- Change failure rate

### Process Optimization
- Automate manual verification steps
- Implement progressive delivery
- Enhance monitoring and alerting
- Reduce deployment complexity
