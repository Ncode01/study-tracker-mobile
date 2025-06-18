# Feature Map - Project Atlas

## Authentication Features

### 🔐 Login Screen
**Location:** `lib/screens/auth/login_screen.dart`
**Function:** User authentication with email/password
**Key Components:**
- `CustomTextField` for email/password input
- `AuthButton` for sign-in action
- `LoadingOverlay` for processing states
- Animation controllers for smooth transitions
- Forgot password dialog

**Navigation Flow:**
- Entry point for unauthenticated users
- Success → `AuthWrapper` → Home screen
- "Sign Up" link → `SignUpScreen`
- "Forgot Password" → Password reset dialog

**Related Components:**
- `AuthProvider` - State management
- `AuthService` - Firebase integration
- `EmailTextField`, `PasswordTextField` - Form inputs

### 🆕 Sign Up Screen
**Location:** `lib/screens/auth/signup_screen.dart`
**Function:** New user registration with profile creation
**Key Components:**
- Extended form with name, email, password, confirm password
- Form validation with custom validators
- User profile creation in Firestore
- Smooth entry/exit animations

**Navigation Flow:**
- Accessible from login screen
- Success → Auto-login → Home screen
- Back button → Return to login

**Related Components:**
- `UserModel.newUser()` - Profile initialization
- Firebase Auth & Firestore - Account creation

### 🛡️ Auth Wrapper
**Location:** `lib/screens/auth/auth_wrapper.dart`
**Function:** Authentication state router and gatekeeper
**Key Components:**
- Auth state listener and synchronization
- Loading screens during auth checks
- Error handling and retry mechanisms
- Placeholder home screen for authenticated users

**Navigation Logic:**
```dart
AuthState.initial → Loading Screen
AuthState.loading → Loading Screen  
AuthState.authenticated → Home Screen
AuthState.unauthenticated → Login Screen
AuthState.error → Error Screen with retry
```

**Related Components:**
- `AuthProvider` - Primary state source
- `authStateChangesProvider` - Firebase sync
- Firebase Auth stream - External state changes

## State Management Features

### 📊 Auth Provider System
**Location:** `lib/providers/auth_provider.dart`
**Function:** Centralized authentication state management
**Key Providers:**

| Provider | Type | Purpose |
|----------|------|---------|
| `authProvider` | StateNotifier | Main auth state management |
| `authServiceProvider` | Provider | AuthService singleton |
| `authStateChangesProvider` | StreamProvider | Firebase auth stream |
| `isAuthenticatedProvider` | Provider | Auth status check |
| `currentUserProvider` | Provider | Current user access |
| `authErrorProvider` | Provider | Error message access |

**State Management Pattern:**
```dart
AuthData {
  state: AuthState,
  user: UserModel?,
  errorMessage: String?
}
```

## Data Models

### 👤 User Model
**Location:** `lib/models/user_model.dart`
**Function:** User profile and gamification data structure
**Key Features:**
- Level progression system (1-50+)
- XP tracking and next level calculations
- Explorer titles based on level
- Firestore serialization/deserialization
- Profile update and activity tracking

**Gamification System:**
```dart
Level 1: 0 XP (Novice Explorer)
Level 2: 100 XP 
Level 3: 250 XP
Level N: (N * 150 - 50) XP
Level 50+: Legendary Explorer
```

### 🔄 Auth State
**Location:** `lib/models/auth_state.dart`
**Function:** Authentication status enumeration
**States:** `initial`, `loading`, `authenticated`, `unauthenticated`, `error`
**Extensions:** Helper methods and human-readable descriptions

## Service Layer

### 🔥 Firebase Service
**Location:** `lib/services/firebase_service.dart`
**Function:** Firebase initialization and availability checking
**Features:**
- Safe Firebase initialization with error handling
- Availability status checking
- Graceful degradation when Firebase unavailable

### 🔐 Auth Service
**Location:** `lib/services/auth_service.dart`
**Function:** Firebase authentication operations abstraction
**Key Methods:**
- `signUpWithEmail()` - Account creation + profile setup
- `signInWithEmail()` - User authentication
- `signOut()` - Session termination
- `resetPassword()` - Password recovery
- `getUserProfile()` - Firestore profile retrieval
- `updateUserProfile()` - Profile modification

**Test Mode Support:**
- Hardcoded test accounts for development
- Toggle between Firebase and test mode
- Consistent API regardless of backend

## UI Component Library

### 🎨 Theme System
**Location:** `lib/theme/`
**Function:** Traveler's diary aesthetic implementation

**Color Palette (`app_colors.dart`):**
- Primary: Saddle brown, vintage gold, parchment cream
- Secondary: Compass red, treasure green, sky blue
- Neutrals: Ink black, fade gray, parchment white
- Status: Themed success, error, warning, info colors

**Typography (`app_theme.dart`):**
- **Headings:** Caveat font (handwritten feel)
- **Body Text:** Nunito Sans (readable sans-serif)
- **Material 3** design system integration

### 📝 Form Components
**Location:** `lib/widgets/auth/`

**CustomTextField:**
- Parchment-styled input fields
- Focus animations and state management
- Integrated validation and error display
- Specialized email/password variants

**AuthButton:**
- Themed button with multiple variants
- Loading states with spinner integration
- Press animations and tactile feedback
- Primary, secondary, and text button styles

### ⏳ Loading Components
**Location:** `lib/widgets/common/loading_overlay.dart`
**Function:** Progress indication with themed animations
**Features:**
- Compass-inspired loading spinner
- Overlay with semi-transparent backdrop
- Fade animations and smooth transitions
- Simple and complex loading variants

## Navigation Flow

### Main App Flow
```
App Launch
├── Firebase Check → [Success/Failure]
├── Auth State Check
│   ├── Authenticated → Home Screen (Placeholder)
│   └── Unauthenticated → Login Screen
│       ├── Sign In → Home Screen
│       ├── Sign Up → SignUpScreen → Home Screen
│       └── Forgot Password → Email Reset
└── Error States → Error Screen with Retry
```

### Authentication Sub-Flow
```
Login Screen
├── Valid Credentials → AuthProvider.signIn() → Home
├── Invalid Credentials → Error Display → Retry
├── "Create Account" → SignUpScreen
│   ├── Valid Form → Create Account → Auto Sign In → Home
│   └── Invalid Form → Validation Errors → Retry
└── "Forgot Password" → Reset Dialog → Email Sent → Return to Login
```

## Planned vs Implemented Features

### ✅ Fully Implemented
- [x] User Authentication (Email/Password)
- [x] User Registration with Profile Creation
- [x] Authentication State Management
- [x] Form Validation and Error Handling
- [x] Custom UI Component Library
- [x] Theme System (Traveler's Diary)
- [x] Loading States and Animations
- [x] Firebase Integration
- [x] User Profile Model with Gamification

### 🚧 Partially Implemented
- [⚠️] Home Screen (Placeholder only)
- [⚠️] User Profile Display (Basic welcome message)
- [⚠️] Error Handling (Basic implementation)

### 📋 Planned Features
- [ ] **Study Session Management**
  - Create/start/stop study sessions
  - Time tracking with pause/resume
  - Subject categorization
- [ ] **Dashboard and Analytics**
  - Study time visualization
  - Progress charts and statistics
  - Achievement display
- [ ] **Gamification Features**
  - XP earning from study sessions
  - Achievement system and badges
  - Level progression rewards
- [ ] **Social Features**
  - Study group creation
  - Progress sharing
  - Leaderboards
- [ ] **Settings and Preferences**
  - Study reminders and notifications
  - App theme customization
  - Privacy settings
- [ ] **Offline Support**
  - Local data storage
  - Sync when online
  - Offline study tracking

### 🔮 Future Enhancements
- [ ] **Advanced Analytics**
  - Study pattern analysis
  - Productivity insights
  - Personalized recommendations
- [ ] **Integration Features**
  - Calendar synchronization
  - External app integrations
  - Export/import functionality
- [ ] **Premium Features**
  - Advanced analytics
  - Unlimited categories
  - Priority support

## Component Dependencies

### High-Level Dependencies
```
Screens → Widgets → Providers → Services → Models
   ↓         ↓         ↓          ↓        ↓
  UI      Reusable  State     Business  Data
 Logic   Components  Mgmt      Logic   Structure
```

### Specific Relationships
```
AuthWrapper
├── depends on: AuthProvider
├── renders: LoginScreen | HomeScreen
└── listens to: authStateChangesProvider

LoginScreen
├── depends on: AuthProvider, CustomTextField, AuthButton
├── navigates to: SignUpScreen, HomeScreen
└── triggers: AuthService methods

AuthProvider
├── depends on: AuthService, AuthState, UserModel
├── provides state to: All authenticated screens
└── syncs with: Firebase Auth stream
```
