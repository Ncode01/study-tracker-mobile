# API Documentation

## Overview

Comprehensive API documentation for Project Atlas Flutter mobile application, covering Firebase integration, internal service APIs, and third-party integrations.

## Firebase APIs

### Authentication Service API

#### FirebaseAuth Integration
```dart
// lib/services/auth_service.dart
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  /// Signs in user with email and password
  /// 
  /// Parameters:
  /// - [email]: User's email address (must be valid email format)
  /// - [password]: User's password (minimum 6 characters)
  /// 
  /// Returns:
  /// - [UserCredential] on successful authentication
  /// 
  /// Throws:
  /// - [FirebaseAuthException] with specific error codes:
  ///   - 'user-not-found': No user found with this email
  ///   - 'wrong-password': Incorrect password
  ///   - 'invalid-email': Email format is invalid
  ///   - 'user-disabled': User account has been disabled
  ///   - 'too-many-requests': Too many failed attempts
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   final credential = await authService.signInWithEmail(
  ///     'user@example.com',
  ///     'password123'
  ///   );
  ///   print('User signed in: ${credential.user?.uid}');
  /// } on FirebaseAuthException catch (e) {
  ///   print('Sign in failed: ${e.code}');
  /// }
  /// ```
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // Log successful authentication
      await _logAuthEvent('sign_in_success', credential.user?.uid);
      
      return credential;
    } on FirebaseAuthException catch (e) {
      await _logAuthEvent('sign_in_failure', null, error: e.code);
      rethrow;
    }
  }
  
  /// Creates new user account with email and password
  /// 
  /// Parameters:
  /// - [email]: User's email address (must be unique and valid)
  /// - [password]: User's password (minimum 6 characters)
  /// - [displayName]: Optional display name for the user
  /// 
  /// Returns:
  /// - [UserCredential] on successful account creation
  /// 
  /// Throws:
  /// - [FirebaseAuthException] with specific error codes:
  ///   - 'email-already-in-use': Email is already registered
  ///   - 'invalid-email': Email format is invalid
  ///   - 'weak-password': Password is too weak
  ///   - 'operation-not-allowed': Email/password accounts are not enabled
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   final credential = await authService.createUserWithEmail(
  ///     'newuser@example.com',
  ///     'securePassword123',
  ///     displayName: 'John Doe'
  ///   );
  ///   print('Account created: ${credential.user?.uid}');
  /// } on FirebaseAuthException catch (e) {
  ///   print('Account creation failed: ${e.code}');
  /// }
  /// ```
  Future<UserCredential> createUserWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // Update user profile if display name provided
      if (displayName != null && credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
      }
      
      // Log successful account creation
      await _logAuthEvent('account_created', credential.user?.uid);
      
      return credential;
    } on FirebaseAuthException catch (e) {
      await _logAuthEvent('account_creation_failure', null, error: e.code);
      rethrow;
    }
  }
  
  /// Signs out the current user
  /// 
  /// Returns:
  /// - [Future<void>] that completes when sign out is finished
  /// 
  /// Example:
  /// ```dart
  /// await authService.signOut();
  /// print('User signed out');
  /// ```
  Future<void> signOut() async {
    await _logAuthEvent('sign_out', currentUser?.uid);
    await _firebaseAuth.signOut();
  }
  
  /// Gets the current authenticated user
  /// 
  /// Returns:
  /// - [User?] Current user or null if not authenticated
  User? get currentUser => _firebaseAuth.currentUser;
  
  /// Stream of authentication state changes
  /// 
  /// Returns:
  /// - [Stream<User?>] Stream that emits when auth state changes
  /// 
  /// Example:
  /// ```dart
  /// authService.authStateChanges.listen((user) {
  ///   if (user != null) {
  ///     print('User is signed in: ${user.uid}');
  ///   } else {
  ///     print('User is signed out');
  ///   }
  /// });
  /// ```
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
```

#### Authentication Error Handling
```dart
// lib/services/auth_error_handler.dart
class AuthErrorHandler {
  /// Converts Firebase Auth exceptions to user-friendly messages
  /// 
  /// Parameters:
  /// - [exception]: FirebaseAuthException to convert
  /// 
  /// Returns:
  /// - [String] User-friendly error message
  static String getErrorMessage(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password should be at least 6 characters long.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
```

### Firestore Database API

#### User Model and Operations
```dart
// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final Map<String, dynamic> preferences;
  
  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.lastLoginAt,
    this.preferences = const {},
  });
  
  /// Creates UserModel from Firestore document
  /// 
  /// Parameters:
  /// - [doc]: DocumentSnapshot from Firestore
  /// 
  /// Returns:
  /// - [UserModel] instance
  /// 
  /// Throws:
  /// - [FormatException] if document data is invalid
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    
    if (data == null) {
      throw FormatException('Document data is null');
    }
    
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
    );
  }
  
  /// Converts UserModel to Firestore document data
  /// 
  /// Returns:
  /// - [Map<String, dynamic>] Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'preferences': preferences,
    };
  }
}

// lib/services/user_service.dart
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';
  
  /// Creates or updates user document in Firestore
  /// 
  /// Parameters:
  /// - [user]: UserModel to save
  /// 
  /// Returns:
  /// - [Future<void>] that completes when operation finishes
  /// 
  /// Example:
  /// ```dart
  /// final user = UserModel(
  ///   uid: 'user123',
  ///   email: 'user@example.com',
  ///   createdAt: DateTime.now(),
  ///   lastLoginAt: DateTime.now(),
  /// );
  /// await userService.saveUser(user);
  /// ```
  Future<void> saveUser(UserModel user) async {
    await _firestore
        .collection(_usersCollection)
        .doc(user.uid)
        .set(user.toFirestore(), SetOptions(merge: true));
  }
  
  /// Retrieves user document from Firestore
  /// 
  /// Parameters:
  /// - [uid]: User ID to retrieve
  /// 
  /// Returns:
  /// - [Future<UserModel?>] User data or null if not found
  /// 
  /// Example:
  /// ```dart
  /// final user = await userService.getUser('user123');
  /// if (user != null) {
  ///   print('User email: ${user.email}');
  /// }
  /// ```
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }
  
  /// Updates user's last login timestamp
  /// 
  /// Parameters:
  /// - [uid]: User ID to update
  /// 
  /// Returns:
  /// - [Future<void>] that completes when update finishes
  Future<void> updateLastLogin(String uid) async {
    await _firestore
        .collection(_usersCollection)
        .doc(uid)
        .update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }
  
  /// Updates user preferences
  /// 
  /// Parameters:
  /// - [uid]: User ID to update
  /// - [preferences]: New preferences to merge
  /// 
  /// Returns:
  /// - [Future<void>] that completes when update finishes
  /// 
  /// Example:
  /// ```dart
  /// await userService.updatePreferences('user123', {
  ///   'theme': 'dark',
  ///   'notifications': true,
  /// });
  /// ```
  Future<void> updatePreferences(String uid, Map<String, dynamic> preferences) async {
    await _firestore
        .collection(_usersCollection)
        .doc(uid)
        .update({
      'preferences': preferences,
    });
  }
}
```

#### Study Tracking API
```dart
// lib/models/study_session_model.dart
class StudySessionModel {
  final String id;
  final String userId;
  final String subject;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final String? notes;
  final StudyType type;
  final List<String> tags;
  
  const StudySessionModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.startTime,
    this.endTime,
    this.duration,
    this.notes,
    required this.type,
    this.tags = const [],
  });
  
  /// Creates StudySessionModel from Firestore document
  factory StudySessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return StudySessionModel(
      id: doc.id,
      userId: data['userId'],
      subject: data['subject'],
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
      duration: data['durationMs'] != null 
          ? Duration(milliseconds: data['durationMs'])
          : null,
      notes: data['notes'],
      type: StudyType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => StudyType.general,
      ),
      tags: List<String>.from(data['tags'] ?? []),
    );
  }
  
  /// Converts to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'subject': subject,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'durationMs': duration?.inMilliseconds,
      'notes': notes,
      'type': type.name,
      'tags': tags,
    };
  }
}

enum StudyType {
  reading,
  practice,
  review,
  exam,
  general,
}

// lib/services/study_service.dart
class StudyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _sessionsCollection = 'study_sessions';
  
  /// Starts a new study session
  /// 
  /// Parameters:
  /// - [userId]: ID of the user starting the session
  /// - [subject]: Subject being studied
  /// - [type]: Type of study session
  /// - [tags]: Optional tags for categorization
  /// 
  /// Returns:
  /// - [Future<String>] ID of the created session
  /// 
  /// Example:
  /// ```dart
  /// final sessionId = await studyService.startSession(
  ///   'user123',
  ///   'Mathematics',
  ///   StudyType.practice,
  ///   tags: ['algebra', 'equations'],
  /// );
  /// ```
  Future<String> startSession(
    String userId,
    String subject,
    StudyType type, {
    List<String> tags = const [],
  }) async {
    final session = StudySessionModel(
      id: '', // Will be set by Firestore
      userId: userId,
      subject: subject,
      startTime: DateTime.now(),
      type: type,
      tags: tags,
    );
    
    final docRef = await _firestore
        .collection(_sessionsCollection)
        .add(session.toFirestore());
    
    return docRef.id;
  }
  
  /// Ends an active study session
  /// 
  /// Parameters:
  /// - [sessionId]: ID of the session to end
  /// - [notes]: Optional notes about the session
  /// 
  /// Returns:
  /// - [Future<void>] that completes when session is ended
  /// 
  /// Example:
  /// ```dart
  /// await studyService.endSession(
  ///   'session123',
  ///   notes: 'Completed chapter 5 exercises',
  /// );
  /// ```
  Future<void> endSession(String sessionId, {String? notes}) async {
    final endTime = DateTime.now();
    
    // Get the session to calculate duration
    final sessionDoc = await _firestore
        .collection(_sessionsCollection)
        .doc(sessionId)
        .get();
    
    if (sessionDoc.exists) {
      final session = StudySessionModel.fromFirestore(sessionDoc);
      final duration = endTime.difference(session.startTime);
      
      await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .update({
        'endTime': Timestamp.fromDate(endTime),
        'durationMs': duration.inMilliseconds,
        'notes': notes,
      });
    }
  }
  
  /// Gets study sessions for a user
  /// 
  /// Parameters:
  /// - [userId]: ID of the user
  /// - [limit]: Maximum number of sessions to return
  /// - [startAfter]: Start after this document (for pagination)
  /// 
  /// Returns:
  /// - [Future<List<StudySessionModel>>] List of study sessions
  /// 
  /// Example:
  /// ```dart
  /// final sessions = await studyService.getUserSessions(
  ///   'user123',
  ///   limit: 20,
  /// );
  /// ```
  Future<List<StudySessionModel>> getUserSessions(
    String userId, {
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _firestore
        .collection(_sessionsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .limit(limit);
    
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    final querySnapshot = await query.get();
    
    return querySnapshot.docs
        .map((doc) => StudySessionModel.fromFirestore(doc))
        .toList();
  }
  
  /// Gets study statistics for a user
  /// 
  /// Parameters:
  /// - [userId]: ID of the user
  /// - [startDate]: Start date for statistics calculation
  /// - [endDate]: End date for statistics calculation
  /// 
  /// Returns:
  /// - [Future<StudyStatistics>] Study statistics
  Future<StudyStatistics> getStudyStatistics(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final query = await _firestore
        .collection(_sessionsCollection)
        .where('userId', isEqualTo: userId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();
    
    final sessions = query.docs
        .map((doc) => StudySessionModel.fromFirestore(doc))
        .toList();
    
    return StudyStatistics.fromSessions(sessions);
  }
}

class StudyStatistics {
  final int totalSessions;
  final Duration totalStudyTime;
  final Map<String, Duration> timeBySubject;
  final Map<StudyType, int> sessionsByType;
  final double averageSessionDuration;
  
  const StudyStatistics({
    required this.totalSessions,
    required this.totalStudyTime,
    required this.timeBySubject,
    required this.sessionsByType,
    required this.averageSessionDuration,
  });
  
  factory StudyStatistics.fromSessions(List<StudySessionModel> sessions) {
    final timeBySubject = <String, Duration>{};
    final sessionsByType = <StudyType, int>{};
    Duration totalTime = Duration.zero;
    
    for (final session in sessions) {
      if (session.duration != null) {
        totalTime += session.duration!;
        
        timeBySubject[session.subject] = 
            (timeBySubject[session.subject] ?? Duration.zero) + session.duration!;
        
        sessionsByType[session.type] = 
            (sessionsByType[session.type] ?? 0) + 1;
      }
    }
    
    final averageDuration = sessions.isNotEmpty 
        ? totalTime.inMinutes / sessions.length
        : 0.0;
    
    return StudyStatistics(
      totalSessions: sessions.length,
      totalStudyTime: totalTime,
      timeBySubject: timeBySubject,
      sessionsByType: sessionsByType,
      averageSessionDuration: averageDuration,
    );
  }
}
```

## Internal Service APIs

### State Management API (Riverpod)

#### Auth Provider
```dart
// lib/providers/auth_provider.dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  /// Initial state of authentication
  @override
  AuthState build() {
    // Listen to Firebase auth state changes
    _authSubscription = ref
        .read(authServiceProvider)
        .authStateChanges
        .listen(_handleAuthStateChange);
    
    return const AuthState.loading();
  }
  
  /// Signs in user with email and password
  /// 
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  /// 
  /// Returns:
  /// - [Future<void>] that completes when sign in attempt finishes
  /// 
  /// Side Effects:
  /// - Updates state to loading during sign in
  /// - Updates state to authenticated on success
  /// - Updates state to error on failure
  Future<void> signInWithEmail(String email, String password) async {
    state = const AuthState.loading();
    
    try {
      final authService = ref.read(authServiceProvider);
      final credential = await authService.signInWithEmail(email, password);
      
      if (credential.user != null) {
        // Update user's last login
        await ref
            .read(userServiceProvider)
            .updateLastLogin(credential.user!.uid);
        
        state = AuthState.authenticated(credential.user!);
      }
    } on FirebaseAuthException catch (e) {
      final message = AuthErrorHandler.getErrorMessage(e);
      state = AuthState.error(message);
    } catch (e) {
      state = const AuthState.error('An unexpected error occurred');
    }
  }
  
  /// Creates new user account
  /// 
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  /// - [displayName]: Optional display name
  /// 
  /// Returns:
  /// - [Future<void>] that completes when account creation finishes
  Future<void> createAccount(
    String email,
    String password, {
    String? displayName,
  }) async {
    state = const AuthState.loading();
    
    try {
      final authService = ref.read(authServiceProvider);
      final credential = await authService.createUserWithEmail(
        email,
        password,
        displayName: displayName,
      );
      
      if (credential.user != null) {
        // Create user document in Firestore
        final user = UserModel(
          uid: credential.user!.uid,
          email: credential.user!.email!,
          displayName: displayName,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        
        await ref.read(userServiceProvider).saveUser(user);
        
        state = AuthState.authenticated(credential.user!);
      }
    } on FirebaseAuthException catch (e) {
      final message = AuthErrorHandler.getErrorMessage(e);
      state = AuthState.error(message);
    } catch (e) {
      state = const AuthState.error('Failed to create account');
    }
  }
  
  /// Signs out current user
  /// 
  /// Returns:
  /// - [Future<void>] that completes when sign out finishes
  Future<void> signOut() async {
    try {
      await ref.read(authServiceProvider).signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = const AuthState.error('Failed to sign out');
    }
  }
  
  void _handleAuthStateChange(User? user) {
    if (user != null) {
      state = AuthState.authenticated(user);
    } else {
      state = const AuthState.unauthenticated();
    }
  }
}

/// Authentication state representation
@freezed
class AuthState with _$AuthState {
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

/// Provider for authentication state
final authProvider = AuthNotifierProvider<AuthNotifier, AuthState>();
```

#### Study Session Provider
```dart
// lib/providers/study_provider.dart
@riverpod
class StudyNotifier extends _$StudyNotifier {
  @override
  StudySessionState build() {
    return const StudySessionState.idle();
  }
  
  /// Starts a new study session
  /// 
  /// Parameters:
  /// - [subject]: Subject being studied
  /// - [type]: Type of study session
  /// - [tags]: Optional tags
  /// 
  /// Returns:
  /// - [Future<void>] that completes when session starts
  Future<void> startSession(
    String subject,
    StudyType type, {
    List<String> tags = const [],
  }) async {
    final user = ref.read(authProvider).maybeWhen(
      authenticated: (user) => user,
      orElse: () => null,
    );
    
    if (user == null) {
      state = const StudySessionState.error('User not authenticated');
      return;
    }
    
    state = const StudySessionState.starting();
    
    try {
      final sessionId = await ref
          .read(studyServiceProvider)
          .startSession(user.uid, subject, type, tags: tags);
      
      state = StudySessionState.active(
        sessionId: sessionId,
        subject: subject,
        startTime: DateTime.now(),
        type: type,
        tags: tags,
      );
    } catch (e) {
      state = StudySessionState.error('Failed to start session: $e');
    }
  }
  
  /// Ends the active study session
  /// 
  /// Parameters:
  /// - [notes]: Optional notes about the session
  /// 
  /// Returns:
  /// - [Future<void>] that completes when session ends
  Future<void> endSession({String? notes}) async {
    state.whenOrNull(
      active: (sessionId, subject, startTime, type, tags) async {
        state = const StudySessionState.ending();
        
        try {
          await ref
              .read(studyServiceProvider)
              .endSession(sessionId, notes: notes);
          
          state = const StudySessionState.idle();
        } catch (e) {
          state = StudySessionState.error('Failed to end session: $e');
        }
      },
    );
  }
}

@freezed
class StudySessionState with _$StudySessionState {
  const factory StudySessionState.idle() = _Idle;
  const factory StudySessionState.starting() = _Starting;
  const factory StudySessionState.active({
    required String sessionId,
    required String subject,
    required DateTime startTime,
    required StudyType type,
    required List<String> tags,
  }) = _Active;
  const factory StudySessionState.ending() = _Ending;
  const factory StudySessionState.error(String message) = _Error;
}

final studyProvider = StudyNotifierProvider<StudyNotifier, StudySessionState>();
```

### Navigation API

#### App Router Configuration
```dart
// lib/router/app_router.dart
final appRouter = GoRouter(
  initialLocation: '/auth',
  routes: [
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const AuthWrapper(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: '/study',
          name: 'study',
          builder: (context, state) => const StudyScreen(),
        ),
        GoRoute(
          path: '/statistics',
          name: 'statistics',
          builder: (context, state) => const StatisticsScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final authState = ProviderScope.containerOf(context)
        .read(authProvider);
    
    final isAuthRoute = state.matchedLocation.startsWith('/auth') ||
        state.matchedLocation.startsWith('/login') ||
        state.matchedLocation.startsWith('/signup');
    
    return authState.when(
      loading: () => null,
      authenticated: (_) => isAuthRoute ? '/home' : null,
      unauthenticated: () => isAuthRoute ? null : '/auth',
      error: (_) => isAuthRoute ? null : '/auth',
    );
  },
);
```

## Widget APIs

### Custom Widget Documentation

#### AuthButton Widget
```dart
// lib/widgets/auth/auth_button.dart
/// A customizable button widget for authentication actions
/// 
/// This widget provides a consistent button design across the app
/// with loading states and customizable text and actions.
class AuthButton extends StatelessWidget {
  /// Text to display on the button
  final String text;
  
  /// Callback function when button is pressed
  /// If null, button will be disabled
  final VoidCallback? onPressed;
  
  /// Whether the button is in loading state
  /// When true, shows a loading indicator instead of text
  final bool isLoading;
  
  /// Optional icon to display before the text
  final IconData? icon;
  
  /// Button variant for different visual styles
  final AuthButtonVariant variant;
  
  /// Creates an authentication button
  /// 
  /// Parameters:
  /// - [text]: Required text to display
  /// - [onPressed]: Optional callback for button press
  /// - [isLoading]: Whether to show loading state (default: false)
  /// - [icon]: Optional icon to display
  /// - [variant]: Button style variant (default: primary)
  /// 
  /// Example:
  /// ```dart
  /// AuthButton(
  ///   text: 'Sign In',
  ///   onPressed: () => _handleSignIn(),
  ///   isLoading: isSigningIn,
  ///   icon: Icons.login,
  /// )
  /// ```
  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AuthButtonVariant.primary,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getVariantColors(theme);
    
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.background,
          foregroundColor: colors.foreground,
          disabledBackgroundColor: colors.disabled,
          elevation: variant == AuthButtonVariant.primary ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: variant == AuthButtonVariant.outline
                ? BorderSide(color: colors.border)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(colors.foreground),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
  
  _ButtonColors _getVariantColors(ThemeData theme) {
    switch (variant) {
      case AuthButtonVariant.primary:
        return _ButtonColors(
          background: theme.primaryColor,
          foreground: Colors.white,
          disabled: theme.disabledColor,
          border: Colors.transparent,
        );
      case AuthButtonVariant.secondary:
        return _ButtonColors(
          background: theme.colorScheme.secondary,
          foreground: Colors.white,
          disabled: theme.disabledColor,
          border: Colors.transparent,
        );
      case AuthButtonVariant.outline:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: theme.primaryColor,
          disabled: theme.disabledColor,
          border: theme.primaryColor,
        );
    }
  }
}

enum AuthButtonVariant {
  primary,
  secondary,
  outline,
}

class _ButtonColors {
  final Color background;
  final Color foreground;
  final Color disabled;
  final Color border;
  
  const _ButtonColors({
    required this.background,
    required this.foreground,
    required this.disabled,
    required this.border,
  });
}
```

#### CustomTextField Widget
```dart
// lib/widgets/auth/custom_text_field.dart
/// A customizable text input field with validation support
/// 
/// This widget provides consistent text field styling and
/// built-in validation capabilities for forms.
class CustomTextField extends StatefulWidget {
  /// Label text displayed above the field
  final String label;
  
  /// Hint text shown when field is empty
  final String? hint;
  
  /// Text editing controller for the field
  final TextEditingController controller;
  
  /// Whether this is a password field (obscures text)
  final bool isPassword;
  
  /// Keyboard type for the input
  final TextInputType keyboardType;
  
  /// Validation function that returns error message or null
  final String? Function(String?)? validator;
  
  /// Callback when field value changes
  final void Function(String)? onChanged;
  
  /// Icon to display at the start of the field
  final IconData? prefixIcon;
  
  /// Whether the field is enabled
  final bool enabled;
  
  /// Maximum number of lines (default: 1)
  final int maxLines;
  
  /// Creates a custom text field
  /// 
  /// Parameters:
  /// - [label]: Required label for the field
  /// - [controller]: Required text editing controller
  /// - [hint]: Optional hint text
  /// - [isPassword]: Whether to obscure text (default: false)
  /// - [keyboardType]: Keyboard type (default: text)
  /// - [validator]: Optional validation function
  /// - [onChanged]: Optional change callback
  /// - [prefixIcon]: Optional leading icon
  /// - [enabled]: Whether field is enabled (default: true)
  /// - [maxLines]: Maximum lines (default: 1)
  /// 
  /// Example:
  /// ```dart
  /// CustomTextField(
  ///   label: 'Email',
  ///   controller: emailController,
  ///   hint: 'Enter your email',
  ///   keyboardType: TextInputType.emailAddress,
  ///   prefixIcon: Icons.email,
  ///   validator: (value) {
  ///     if (value?.isEmpty ?? true) {
  ///       return 'Email is required';
  ///     }
  ///     return null;
  ///   },
  /// )
  /// ```
  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.enabled = true,
    this.maxLines = 1,
  });
  
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscureText,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
              ),
            ),
            errorText: _errorMessage,
          ),
          validator: (value) {
            final error = widget.validator?.call(value);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _errorMessage = error;
              });
            });
            return error;
          },
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
```

## Error Handling

### Standardized Error Response Format
```dart
// lib/models/api_response.dart
/// Standardized API response wrapper
/// 
/// Used to provide consistent response format across all API calls
class ApiResponse<T> {
  /// Whether the operation was successful
  final bool success;
  
  /// Response data (null if error)
  final T? data;
  
  /// Error message (null if successful)
  final String? error;
  
  /// HTTP status code (for network requests)
  final int? statusCode;
  
  /// Additional metadata
  final Map<String, dynamic>? metadata;
  
  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
    this.metadata,
  });
  
  /// Creates successful response
  factory ApiResponse.success(T data, {Map<String, dynamic>? metadata}) {
    return ApiResponse(
      success: true,
      data: data,
      metadata: metadata,
    );
  }
  
  /// Creates error response
  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }
  
  /// Creates response from exception
  factory ApiResponse.fromException(Exception exception) {
    String errorMessage;
    int? statusCode;
    
    if (exception is FirebaseAuthException) {
      errorMessage = AuthErrorHandler.getErrorMessage(exception);
    } else if (exception is FirebaseException) {
      errorMessage = 'Database error: ${exception.message}';
    } else {
      errorMessage = 'An unexpected error occurred';
    }
    
    return ApiResponse.error(errorMessage, statusCode: statusCode);
  }
}
```

### Global Error Handler
```dart
// lib/services/error_service.dart
class ErrorService {
  static void handleError(dynamic error, StackTrace? stackTrace) {
    // Log error for debugging
    print('Error: $error');
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
    
    // Report to crash analytics
    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      fatal: false,
    );
    
    // Show user-friendly error message
    _showErrorSnackBar(_getUserFriendlyMessage(error));
  }
  
  static String _getUserFriendlyMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return AuthErrorHandler.getErrorMessage(error);
    } else if (error is FirebaseException) {
      return 'A database error occurred. Please try again.';
    } else if (error.toString().contains('network')) {
      return 'Network error. Please check your connection.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
  
  static void _showErrorSnackBar(String message) {
    // Implementation depends on navigation context
    // Could use a global navigator key or overlay
  }
}
```

## Rate Limiting and Quotas

### Firebase Quotas
```dart
// lib/config/firebase_limits.dart
class FirebaseLimits {
  // Firestore Limits
  static const int maxDocumentSize = 1048576; // 1 MB
  static const int maxFieldPathLength = 1500;
  static const int maxDocumentDepth = 20;
  static const int maxWritesPerSecond = 10000;
  static const int maxWritesPerTransaction = 500;
  
  // Authentication Limits
  static const int maxSignInAttemptsPerHour = 5;
  static const int maxAccountsPerIP = 100;
  
  // Usage Guidelines
  static const int recommendedBatchSize = 100;
  static const Duration recommendedCacheTime = Duration(minutes: 5);
}
```

## Testing APIs

### Mock Services for Testing
```dart
// test/mocks/mock_auth_service.dart
class MockAuthService implements AuthService {
  bool _shouldFailSignIn = false;
  User? _currentUser;
  
  void setShouldFailSignIn(bool shouldFail) {
    _shouldFailSignIn = shouldFail;
  }
  
  void setCurrentUser(User? user) {
    _currentUser = user;
  }
  
  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    if (_shouldFailSignIn) {
      throw FirebaseAuthException(
        code: 'wrong-password',
        message: 'The password is invalid.',
      );
    }
    
    // Return mock credential
    return MockUserCredential(_currentUser);
  }
  
  @override
  User? get currentUser => _currentUser;
  
  @override
  Stream<User?> get authStateChanges => Stream.value(_currentUser);
}
```

## API Versioning Strategy

### Future API Versioning
```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String currentApiVersion = 'v1';
  
  static String getApiUrl(String endpoint) {
    return 'https://api.projectatlas.com/$currentApiVersion/$endpoint';
  }
  
  // For future API versions
  static String getVersionedUrl(String endpoint, String version) {
    return 'https://api.projectatlas.com/$version/$endpoint';
  }
}
```

This API documentation provides comprehensive coverage of the Project Atlas mobile application's APIs, including Firebase integration, internal services, widget APIs, error handling, and testing approaches. All APIs are documented with parameters, return types, exceptions, and usage examples.
