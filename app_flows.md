# Project Atlas: Application Flow Documentation

**Generated**: June 14, 2025  
**Purpose**: To provide a single source of truth for the primary navigation and data flows within the application.

---

## 🗺️ **1. Navigation Flow**

This flow describes the user's journey through the app's screens.

```mermaid
graph TD
    A[App Start] --> B{Auth State?}
    B -->|Authenticated| C[HomeScreen]
    B -->|Unauthenticated| D[LoginScreen]
    B -->|Loading/Initial| E[SplashScreen/Loading]

    D -->|"Need to Sign Up"| F[SignUpScreen]
    F -->|"Signs Up Successfully"| C
    F -->|"Has Account"| D
    D -->|"Logs In Successfully"| C

    C -->|"User Profile Icon"| G[ProfileScreen]
    G -->|"Logout Button"| D

    C -->|"Create Study"| H[CreateStudyScreen]
    C -->|"Join Study"| I[JoinStudyScreen]
    C -->|"View Study"| J[StudyDetailScreen]

    style A fill:#e1f5fe
    style C fill:#c8e6c9
    style D fill:#ffecb3
    style F fill:#ffecb3
```

### **Key Navigation Components:**

- **`AuthWrapper.dart`**: The central gatekeeper. It listens to the `authStateChangesProvider` and directs the user to either the `LoginScreen` or `HomeScreen`. It is the only component that should perform this top-level routing.
- **`LoginScreen.dart`**: Navigates to `SignUpScreen`.
- **`SignUpScreen.dart`**: Navigates back to `LoginScreen`.
- **`ProfileScreen.dart`** (Future): Will contain the logout button, which triggers the `authProvider.signOut()` method, causing the `AuthWrapper` to automatically redirect to the `LoginScreen`.

---

## 💾 **2. Data Flow: User Authentication**

This flow describes how data moves from user input to the UI during the sign-up process.

```mermaid
sequenceDiagram
    participant User as User
    participant SignUpScreen as SignUpScreen (UI)
    participant AuthProvider as AuthProvider (Riverpod)
    participant AuthService as AuthService (Service)
    participant Firebase as Firebase Auth/Firestore

    User->>SignUpScreen: Enters Email, Pass, Name
    User->>SignUpScreen: Clicks "Begin Adventure" Button

    SignUpScreen->>AuthProvider: Calls signUpWithEmail() with credentials
    activate AuthProvider

    AuthProvider->>AuthProvider: Sets state to AuthData.loading()
    Note right of AuthProvider: UI shows LoadingOverlay

    AuthProvider->>AuthService: Calls signUpWithEmail()
    activate AuthService

    AuthService->>Firebase: createUserWithEmailAndPassword()
    activate Firebase
    Firebase-->>AuthService: Returns UserCredential
    deactivate Firebase

    AuthService->>Firebase: users.doc(uid).set(userModel)
    activate Firebase
    Firebase-->>AuthService: Profile Created
    deactivate Firebase

    AuthService-->>AuthProvider: Returns UserModel
    deactivate AuthService

    AuthProvider->>AuthProvider: Sets state to AuthData.authenticated(userModel)
    Note right of AuthProvider: AuthWrapper detects new auth state via stream and navigates to HomeScreen
    deactivate AuthProvider
```

### **Data Flow Principles:**

1. **UI to Provider**: The UI layer (Screens/Widgets) only calls methods on the Riverpod Notifiers (`AuthProvider`). It never interacts directly with services.
2. **Provider to Service**: The Provider layer (`AuthProvider`) contains the business logic. It orchestrates calls to one or more services (`AuthService`).
3. **Service to External API**: The Service layer (`AuthService`) is the only layer that communicates with external resources (Firebase). It handles the direct API calls, data transformation, and error translation.
4. **Data Flows Up, State Flows Down**: Services return raw data models (`UserModel`). Providers wrap this data in a state object (`AuthData`). The UI consumes this state and rebuilds accordingly.

---

## 🔄 **3. State Management Flow**

This diagram shows how state flows through the Riverpod providers.

```mermaid
graph TD
    A[Firebase Auth Stream] --> B[authStateChangesProvider]
    B --> C[AuthWrapper]
    C --> D{User State?}
    D -->|Null| E[LoginScreen]
    D -->|User| F[HomeScreen]

    G[UI Action] --> H[authProvider]
    H --> I[AuthService]
    I --> J[Firebase Operations]
    J --> K[Update AuthData State]
    K --> L[UI Rebuilds]

    style B fill:#bbdefb
    style H fill:#c8e6c9
    style I fill:#fff3e0
```

### **Provider Responsibilities:**

- **`authStateChangesProvider`** (StreamProvider): 
  - **Purpose**: Real-time authentication state for navigation
  - **Usage**: ONLY in `AuthWrapper` for automatic routing
  - **Data**: Raw `User?` from Firebase Auth stream

- **`authProvider`** (StateNotifierProvider):
  - **Purpose**: UI state management and user actions  
  - **Usage**: In auth screens for login/signup actions and loading states
  - **Data**: Rich `AuthData` state with loading/error information

---

## 📱 **4. Screen-Level Data Flow**

### **Login Screen Flow**

```mermaid
stateDiagram-v2
    [*] --> Initial: Screen loads
    Initial --> Validating: User enters credentials
    Validating --> LoginAttempt: Form is valid
    Validating --> ValidationError: Form has errors
    ValidationError --> Validating: User fixes errors
    
    LoginAttempt --> Loading: AuthProvider.signIn() called
    Loading --> Success: Login successful
    Loading --> Error: Login failed
    
    Success --> [*]: Navigate to HomeScreen
    Error --> Initial: Show error message
```

### **Data Dependencies:**

| Screen | Watches | Calls | Navigates To |
|---|---|---|---|
| `AuthWrapper` | `authStateChangesProvider` | None | `LoginScreen` or `HomeScreen` |
| `LoginScreen` | `authProvider` | `authProvider.signIn()` | `SignUpScreen` |
| `SignUpScreen` | `authProvider` | `authProvider.signUp()` | `LoginScreen` |
| `HomeScreen` | `authProvider` | `authProvider.signOut()` | None (handled by AuthWrapper) |

---

## 🔐 **5. Authentication State Transitions**

```mermaid
stateDiagram-v2
    [*] --> Initial: App starts
    Initial --> Loading: Checking auth state
    Loading --> Unauthenticated: No user found
    Loading --> Authenticated: User found
    
    Unauthenticated --> LoginAttempt: User tries to login
    Unauthenticated --> SignUpAttempt: User tries to signup
    
    LoginAttempt --> Authenticated: Success
    LoginAttempt --> Unauthenticated: Failure
    
    SignUpAttempt --> Authenticated: Success  
    SignUpAttempt --> Unauthenticated: Failure
    
    Authenticated --> Unauthenticated: User logs out
    Authenticated --> Unauthenticated: Session expires
```

---

## 🚀 **6. Future Navigation Flows**

### **Study Management (Planned)**

```mermaid
graph TD
    A[HomeScreen] --> B[StudyListScreen]
    B --> C[StudyDetailScreen]
    B --> D[CreateStudyScreen]
    B --> E[JoinStudyScreen]
    
    C --> F[SessionScreen]
    C --> G[StudySettingsScreen]
    C --> H[ParticipantsScreen]
    
    D --> B
    E --> B
    F --> C
```

### **User Profile (Planned)**

```mermaid
graph TD
    A[Any Screen] --> B[ProfileScreen]
    B --> C[EditProfileScreen]
    B --> D[SettingsScreen]
    B --> E[HelpScreen]
    
    C --> B
    D --> B
    E --> B
```

---

## 📋 **7. Error Handling Flow**

```mermaid
flowchart TD
    A[User Action] --> B[Provider Method]
    B --> C[Service Call]
    C --> D{Success?}
    
    D -->|Yes| E[Update State with Data]
    D -->|No| F[Catch Exception]
    
    F --> G[Translate Error Message]
    G --> H[Update State with Error]
    
    E --> I[UI Rebuilds with Success]
    H --> J[UI Shows Error Message]
    
    J --> K[User Can Retry]
    K --> A
```

### **Error Handling Principles:**

1. **Service Layer**: Catches raw exceptions and translates them to user-friendly messages
2. **Provider Layer**: Wraps errors in state objects (`AuthData.error(message)`)
3. **UI Layer**: Displays error messages and provides retry mechanisms
4. **Consistency**: All Firebase errors use the same translation utility

---

## 🎯 **8. Performance Considerations**

### **State Optimization:**

- **Stream Providers**: Only used for real-time data that needs immediate updates
- **State Notifiers**: Used for complex state with user actions
- **Consumer Widgets**: Placed as low as possible in the widget tree to minimize rebuilds
- **Selectors**: Used when only specific parts of state are needed

### **Navigation Optimization:**

- **Lazy Loading**: Screens are only built when navigated to
- **State Preservation**: User input is preserved during navigation (form data, scroll positions)
- **Memory Management**: Unused screens are disposed of properly

---

## ✅ **9. Flow Validation Checklist**

- [ ] **Authentication**: User can sign up, log in, and log out
- [ ] **Navigation**: All screens are reachable and navigable
- [ ] **State Management**: State updates trigger appropriate UI changes
- [ ] **Error Handling**: All error states are handled gracefully
- [ ] **Loading States**: Users see feedback during async operations
- [ ] **Data Persistence**: User state persists across app restarts
- [ ] **Navigation Guards**: Unauthenticated users cannot access protected screens

This comprehensive flow documentation serves as the single source of truth for understanding how data and navigation work throughout the Project Atlas application.
