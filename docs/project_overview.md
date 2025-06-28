# Project Atlas - Study Tracker Mobile App

## App Purpose

Project Atlas is a gamified study tracking mobile application designed to make learning and progress tracking engaging through a traveler's diary aesthetic. The app helps users track their study sessions, earn experience points (XP), level up, and maintain consistent learning habits.

## Tech Stack

### Core Framework
- **Flutter 3.29.0** - Cross-platform mobile development framework
- **Dart 3.7.0** - Programming language with null safety

### Backend Services
- **Firebase Core 2.32.0** - Backend-as-a-Service platform
- **Firebase Auth 4.20.0** - Authentication service
- **Cloud Firestore 4.17.5** - NoSQL document database

### State Management
- **Flutter Riverpod 2.6.1** - Reactive state management solution

### UI/UX
- **Google Fonts 6.2.1** - Typography (Caveat for headings, Nunito Sans for body text)
- **Custom Theme System** - Traveler's diary aesthetic with warm earth tones

## High-Level Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Presentation  │    │   Application   │    │   Data Layer    │
│     Layer       │    │     Layer       │    │                 │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ • Screens       │◄──►│ • Providers     │◄──►│ • Services      │
│ • Widgets       │    │ • State Mgmt    │    │ • Models        │
│ • Themes        │    │ • Business      │    │ • Firebase      │
│                 │    │   Logic         │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Layer Responsibilities

**Presentation Layer:**
- Screen widgets and UI components
- Custom themed widgets with traveler's diary aesthetic
- User input handling and visual feedback
- Navigation and routing

**Application Layer:**
- Riverpod providers for state management
- Business logic coordination
- Authentication state management
- Data transformation for UI

**Data Layer:**
- Firebase service abstractions
- Data models and serialization
- API communication
- Local data persistence

## Main User Flows

### 1. Authentication Flow
```
App Launch → Check Auth State → [Authenticated] → Home Screen
              ↓ [Unauthenticated]
         Login/Signup Screen → Firebase Auth → User Profile Creation → Home Screen
```

### 2. User Progression System
```
Study Session → XP Earning → Level Progression → Explorer Title Updates
```

### 3. Core Study Tracking (Planned)
```
Create Study Session → Track Time → Complete Session → Earn XP/Rewards
```

## Authentication System

### Current Implementation
- **Firebase Authentication** with email/password
- **Test Mode Support** - Hardcoded accounts for development
- **User Profile Management** - Firestore integration for user data
- **State Management** - Riverpod-based authentication state

### Authentication States
- `initial` - App startup, checking auth status
- `loading` - Authentication operations in progress
- `authenticated` - User successfully logged in
- `unauthenticated` - User needs to login/signup
- `error` - Authentication errors occurred

### User Model Structure
```dart
UserModel {
  uid: String
  email: String
  displayName: String
  level: int (gamification)
  xp: int (experience points)
  createdAt: DateTime
  lastActiveAt: DateTime
}
```

## Current Development Status

### ✅ Implemented Features
- **Authentication System** - Complete login/signup flow
- **User Registration** - Profile creation with Firebase
- **State Management** - Riverpod providers for auth state
- **UI Framework** - Custom themed components
- **Navigation** - Auth-based routing
- **Gamification Base** - User levels and XP system

### 🚧 In Development
- **Study Session Tracking** - Core functionality planned
- **Dashboard** - User progress visualization
- **Settings** - App configuration options

### 📋 Planned Features
- **Study Categories** - Subject organization
- **Time Tracking** - Detailed session analytics
- **Achievements** - Gamification rewards
- **Social Features** - Progress sharing
- **Offline Support** - Local data sync
- **Push Notifications** - Study reminders

## Key Components and Relationships

### Core Components
```
AuthWrapper (Root Router)
├── LoginScreen/SignUpScreen (Unauthenticated)
└── HomeScreen (Authenticated) [Placeholder]

AuthProvider (State Management)
├── AuthService (Firebase Integration)
├── UserModel (Data Structure)
└── AuthState (State Enum)
```

### Service Layer
- **AuthService** - Firebase Auth operations
- **FirebaseService** - Firebase initialization
- **UserProfile Management** - Firestore CRUD operations

### Widget Library
- **CustomTextField** - Form inputs with themed styling
- **AuthButton** - Branded button components
- **LoadingOverlay** - Progress indicators with compass animation

## Project Structure

```
lib/
├── config/           # Configuration files
├── models/           # Data models and state definitions
├── providers/        # Riverpod state management
├── screens/          # Main application screens
│   └── auth/         # Authentication screens
├── services/         # Business logic and API services
├── theme/            # UI theming and styling
└── widgets/          # Reusable UI components
    ├── auth/         # Authentication-specific widgets
    └── common/       # Shared utility widgets
```

## Development Environment

### Build Configuration
- **Android** - Gradle 8.x with Kotlin DSL
- **iOS** - Xcode project with Swift
- **Development Config** - Empty placeholder for environment variables

### Firebase Configuration
- **google-services.json** - Android Firebase config
- **Firebase project** - Cloud backend services
- **Firestore Database** - User profiles and app data

## Next Steps

1. **Complete Core Features** - Implement study session tracking
2. **Testing Strategy** - Add comprehensive test coverage
3. **Performance Optimization** - Optimize build methods and state management
4. **Production Readiness** - Security rules, error handling, monitoring
5. **Platform Publishing** - App store deployment preparation
