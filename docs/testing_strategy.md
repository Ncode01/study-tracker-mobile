# Testing Strategy - Project Atlas

## Testing Overview

Project Atlas requires comprehensive testing to ensure reliability, performance, and user experience quality. This strategy outlines testing approaches for the gamified study tracking mobile application, covering unit tests, widget tests, integration tests, and end-to-end user flow validation.

### Current Testing Status
- ❌ **Critical**: No meaningful tests currently exist
- ❌ **Critical**: Test file references wrong app class
- ⚠️ **Needs Setup**: Testing infrastructure not configured
- ⚠️ **Needs Setup**: Mock services not implemented

### Testing Pyramid Strategy
```
                    E2E Tests (10%)
                   ┌─────────────────┐
                  │   User Flows     │
                  │   Integration    │
                 └─────────────────┘
                Widget Tests (30%)
               ┌─────────────────────┐
              │   UI Components     │
              │   User Interactions │
              │   State Changes     │
             └─────────────────────┘
            Unit Tests (60%)
           ┌─────────────────────────┐
          │   Business Logic       │
          │   Models & Services    │
          │   Providers & State    │
          │   Utilities & Helpers  │
         └─────────────────────────┘
```

---

## Unit Testing Strategy

### **Core Business Logic Testing**

#### **1. Authentication Service Tests**
```dart
// test/services/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:study/services/auth_service.dart';
import 'package:study/models/user_model.dart';

@GenerateMocks([FirebaseAuth, User, UserCredential, FirebaseFirestore])
import 'auth_service_test.mocks.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
      
      authService = AuthService(
        firebaseAuth: mockFirebaseAuth,
        firestore: mockFirestore,
      );
    });

    group('signInWithEmail', () {
      const email = 'test@example.com';
      const password = 'password123';

      test('should return UserModel on successful sign in', () async {
        // Arrange
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => mockUserCredential);
        
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test_uid');
        when(mockUser.email).thenReturn(email);
        
        // Mock Firestore user profile retrieval
        final mockDocSnapshot = MockDocumentSnapshot();
        when(mockDocSnapshot.exists).thenReturn(true);
        when(mockDocSnapshot.data()).thenReturn({
          'uid': 'test_uid',
          'email': email,
          'displayName': 'Test User',
          'level': 1,
          'xp': 0,
          'createdAt': Timestamp.now(),
          'lastActiveAt': Timestamp.now(),
        });
        
        when(mockFirestore.collection('users')
            .doc('test_uid')
            .get()).thenAnswer((_) async => mockDocSnapshot);

        // Act
        final result = await authService.signInWithEmail(
          email: email,
          password: password,
        );

        // Assert
        expect(result, isA<UserModel>());
        expect(result.email, equals(email));
        expect(result.uid, equals('test_uid'));
        verify(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).called(1);
      });

      test('should throw AuthException on wrong password', () async {
        // Arrange
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(FirebaseAuthException(
          code: 'wrong-password',
          message: 'Wrong password',
        ));

        // Act & Assert
        expect(
          () => authService.signInWithEmail(email: email, password: password),
          throwsA(isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Incorrect password'),
          )),
        );
      });

      test('should throw AuthException on user not found', () async {
        // Arrange
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(FirebaseAuthException(
          code: 'user-not-found',
          message: 'User not found',
        ));

        // Act & Assert
        expect(
          () => authService.signInWithEmail(email: email, password: password),
          throwsA(isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('No account found'),
          )),
        );
      });
    });

    group('signUpWithEmail', () {
      const email = 'newuser@example.com';
      const password = 'password123';
      const displayName = 'New User';

      test('should create user and profile successfully', () async {
        // Arrange
        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => mockUserCredential);
        
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('new_user_uid');
        when(mockUser.email).thenReturn(email);

        // Mock Firestore profile creation
        final mockDocRef = MockDocumentReference();
        when(mockFirestore.collection('users').doc('new_user_uid'))
            .thenReturn(mockDocRef);
        when(mockDocRef.set(any)).thenAnswer((_) async {});

        // Act
        final result = await authService.signUpWithEmail(
          email: email,
          password: password,
          displayName: displayName,
        );

        // Assert
        expect(result, isA<UserModel>());
        expect(result.email, equals(email));
        expect(result.displayName, equals(displayName));
        expect(result.level, equals(1));
        expect(result.xp, equals(0));
        
        verify(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).called(1);
        verify(mockDocRef.set(any)).called(1);
      });
    });
  });
}
```

#### **2. User Model Tests**
```dart
// test/models/user_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study/models/user_model.dart';

void main() {
  group('UserModel', () {
    late UserModel testUser;

    setUp(() {
      testUser = UserModel(
        uid: 'test_uid',
        email: 'test@example.com',
        displayName: 'Test User',
        level: 5,
        xp: 750,
        createdAt: DateTime(2024, 1, 1),
        lastActiveAt: DateTime(2024, 6, 18),
      );
    });

    group('Level and XP calculations', () {
      test('should calculate XP for next level correctly', () {
        // Level 5 should need 700 XP for level 6
        expect(testUser.xpForNextLevel, equals(700));
      });

      test('should calculate XP progress correctly', () {
        // User has 750 XP, needs 700 for level 6
        // Should be at 100% progress (can level up)
        expect(testUser.xpProgress, equals(1.0));
      });

      test('should detect when user can level up', () {
        expect(testUser.canLevelUp, isTrue);
      });

      test('should not allow level up when XP insufficient', () {
        final lowXpUser = testUser.copyWith(xp: 600);
        expect(lowXpUser.canLevelUp, isFalse);
      });
    });

    group('Explorer titles', () {
      test('should return correct title for level 1', () {
        final novice = testUser.copyWith(level: 1);
        expect(novice.explorerTitle, equals('Novice Explorer'));
      });

      test('should return correct title for level 10', () {
        final skilled = testUser.copyWith(level: 10);
        expect(skilled.explorerTitle, equals('Skilled Explorer'));
      });

      test('should return correct title for level 50+', () {
        final legendary = testUser.copyWith(level: 50);
        expect(legendary.explorerTitle, equals('Legendary Explorer'));
      });
    });

    group('Serialization', () {
      test('should convert to JSON correctly', () {
        final json = testUser.toJson();
        
        expect(json['uid'], equals('test_uid'));
        expect(json['email'], equals('test@example.com'));
        expect(json['displayName'], equals('Test User'));
        expect(json['level'], equals(5));
        expect(json['xp'], equals(750));
      });

      test('should create from JSON correctly', () {
        final json = {
          'uid': 'test_uid',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'level': 5,
          'xp': 750,
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'lastActiveAt': Timestamp.fromDate(DateTime(2024, 6, 18)),
        };

        final user = UserModel.fromJson(json);

        expect(user.uid, equals('test_uid'));
        expect(user.email, equals('test@example.com'));
        expect(user.displayName, equals('Test User'));
        expect(user.level, equals(5));
        expect(user.xp, equals(750));
      });
    });

    group('copyWith', () {
      test('should update specific fields only', () {
        final updated = testUser.copyWith(
          displayName: 'Updated Name',
          xp: 1000,
        );

        expect(updated.displayName, equals('Updated Name'));
        expect(updated.xp, equals(1000));
        expect(updated.uid, equals(testUser.uid)); // Unchanged
        expect(updated.email, equals(testUser.email)); // Unchanged
      });
    });

    group('updateLastActive', () {
      test('should update lastActiveAt to current time', () {
        final now = DateTime.now();
        final updated = testUser.updateLastActive();

        expect(updated.lastActiveAt.isAfter(testUser.lastActiveAt), isTrue);
        expect(
          updated.lastActiveAt.difference(now).inSeconds,
          lessThanOrEqualTo(1),
        );
      });
    });
  });
}
```

#### **3. Provider Tests**
```dart
// test/providers/auth_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';
import 'package:study/providers/auth_provider.dart';
import 'package:study/services/auth_service.dart';
import 'package:study/models/auth_state.dart';
import 'package:study/models/user_model.dart';

@GenerateMocks([AuthService])
import 'auth_provider_test.mocks.dart';

void main() {
  group('AuthProvider', () {
    late ProviderContainer container;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should start with initial state', () {
      final authData = container.read(authProvider);
      expect(authData.state, equals(AuthState.initial));
      expect(authData.user, isNull);
      expect(authData.errorMessage, isNull);
    });

    test('should sign in successfully', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      final mockUser = UserModel.newUser(
        uid: 'test_uid',
        email: email,
        displayName: 'Test User',
      );

      when(mockAuthService.signInWithEmail(
        email: email,
        password: password,
      )).thenAnswer((_) async => mockUser);

      // Act
      await container.read(authProvider.notifier).signInWithEmail(
        email: email,
        password: password,
      );

      // Assert
      final authData = container.read(authProvider);
      expect(authData.state, equals(AuthState.authenticated));
      expect(authData.user, equals(mockUser));
      expect(authData.errorMessage, isNull);
    });

    test('should handle sign in failure', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'wrongpassword';
      const errorMessage = 'Incorrect password';

      when(mockAuthService.signInWithEmail(
        email: email,
        password: password,
      )).thenThrow(AuthException(errorMessage));

      // Act
      await container.read(authProvider.notifier).signInWithEmail(
        email: email,
        password: password,
      );

      // Assert
      final authData = container.read(authProvider);
      expect(authData.state, equals(AuthState.error));
      expect(authData.user, isNull);
      expect(authData.errorMessage, equals(errorMessage));
    });

    test('should set loading state during sign in', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      
      // Create a completer to control when the mock completes
      final completer = Completer<UserModel>();
      when(mockAuthService.signInWithEmail(
        email: email,
        password: password,
      )).thenAnswer((_) => completer.future);

      // Act
      final signInFuture = container.read(authProvider.notifier).signInWithEmail(
        email: email,
        password: password,
      );

      // Assert loading state
      final loadingAuthData = container.read(authProvider);
      expect(loadingAuthData.state, equals(AuthState.loading));

      // Complete the operation
      completer.complete(UserModel.newUser(
        uid: 'test_uid',
        email: email,
        displayName: 'Test User',
      ));
      
      await signInFuture;

      // Assert final state
      final finalAuthData = container.read(authProvider);
      expect(finalAuthData.state, equals(AuthState.authenticated));
    });
  });
}
```

---

## Widget Testing Patterns

### **Custom Widget Tests**

#### **1. Authentication Form Tests**
```dart
// test/widgets/auth/login_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:study/widgets/auth/custom_text_field.dart';
import 'package:study/widgets/auth/auth_button.dart';
import 'package:study/screens/auth/login_screen.dart';
import 'package:study/theme/app_theme.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('should display all form elements', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Welcome Back,'), findsOneWidget);
      expect(find.text('Fellow Explorer'), findsOneWidget);
      expect(find.byType(EmailTextField), findsOneWidget);
      expect(find.byType(PasswordTextField), findsOneWidget);
      expect(find.text('Continue Journey'), findsOneWidget);
      expect(find.text('Begin New Adventure'), findsOneWidget);
    });

    testWidgets('should validate empty email field', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Continue Journey'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Email is required for your journey'), findsOneWidget);
    });

    testWidgets('should validate invalid email format', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(EmailTextField), 'invalid-email');
      await tester.tap(find.text('Continue Journey'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('should validate empty password field', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(EmailTextField), 'test@example.com');
      await tester.tap(find.text('Continue Journey'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('A password is required for your journey'), findsOneWidget);
    });

    testWidgets('should show loading state on form submission', (tester) async {
      // Arrange
      final mockAuthService = MockAuthService();
      final completer = Completer<UserModel>();
      
      when(mockAuthService.signInWithEmail(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(EmailTextField), 'test@example.com');
      await tester.enterText(find.byType(PasswordTextField), 'password123');
      await tester.tap(find.text('Continue Journey'));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Continue Journey'), findsNothing);

      // Complete the operation
      completer.complete(UserModel.newUser(
        uid: 'test_uid',
        email: 'test@example.com',
        displayName: 'Test User',
      ));
      
      await tester.pumpAndSettle();
    });
  });
}
```

#### **2. Custom Component Tests**
```dart
// test/widgets/auth/custom_text_field_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/widgets/auth/custom_text_field.dart';
import 'package:study/theme/app_theme.dart';

void main() {
  group('CustomTextField Widget Tests', () {
    testWidgets('should display label and hint', (tester) async {
      // Arrange
      const label = 'Test Label';
      const hint = 'Test Hint';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CustomTextField(
              label: label,
              hint: hint,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(label), findsOneWidget);
      expect(find.text(hint), findsOneWidget);
    });

    testWidgets('should call validator on text change', (tester) async {
      // Arrange
      bool validatorCalled = false;
      String? validatorInput;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CustomTextField(
              label: 'Test',
              validator: (value) {
                validatorCalled = true;
                validatorInput = value;
                return value?.isEmpty == true ? 'Required' : null;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextFormField), 'test input');
      await tester.pump();

      // Assert
      expect(validatorCalled, isTrue);
      expect(validatorInput, equals('test input'));
    });

    testWidgets('should show error text when provided', (tester) async {
      // Arrange
      const errorText = 'This is an error';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CustomTextField(
              label: 'Test',
              errorText: errorText,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(errorText), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: PasswordTextField(
              label: 'Password',
            ),
          ),
        ),
      );

      // Find the TextFormField to check its obscureText property
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.obscureText, isTrue);

      // Act - tap the visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_off_rounded));
      await tester.pump();

      // Assert - password should now be visible
      final updatedTextField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(updatedTextField.obscureText, isFalse);
      expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);
    });
  });
}
```

#### **3. Animation Widget Tests**
```dart
// test/widgets/common/loading_overlay_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/widgets/common/loading_overlay.dart';

void main() {
  group('LoadingOverlay Widget Tests', () {
    testWidgets('should show child when not visible', (tester) async {
      // Arrange
      const childText = 'Child Widget';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isVisible: false,
              child: Text(childText),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(childText), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should show loading overlay when visible', (tester) async {
      // Arrange
      const childText = 'Child Widget';
      const loadingMessage = 'Loading...';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isVisible: true,
              message: loadingMessage,
              child: Text(childText),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(childText), findsOneWidget);
      expect(find.text(loadingMessage), findsOneWidget);
      // The compass spinner should be present
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('should animate in and out smoothly', (tester) async {
      // Arrange
      bool isVisible = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => isVisible = !isVisible),
                      child: Text('Toggle'),
                    ),
                    LoadingOverlay(
                      isVisible: isVisible,
                      child: Text('Content'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Initial state - not visible
      expect(find.text('Charting your course...'), findsNothing);

      // Act - show loading
      await tester.tap(find.text('Toggle'));
      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));

      // Assert - loading is animating in
      expect(find.text('Charting your course...'), findsOneWidget);

      // Act - hide loading
      await tester.tap(find.text('Toggle'));
      await tester.pump();
      await tester.pump(Duration(milliseconds: 300));

      // Assert - loading should be gone
      expect(find.text('Charting your course...'), findsNothing);
    });
  });
}
```

---

## Integration Testing Strategy

### **User Flow Integration Tests**

#### **1. Authentication Flow Test**
```dart
// integration_test/auth_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:study/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('complete sign up and sign in flow', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 5));

      // Should start on login screen for unauthenticated user
      expect(find.text('Welcome Back,'), findsOneWidget);

      // Navigate to sign up
      await tester.tap(find.text('Begin New Adventure'));
      await tester.pumpAndSettle();

      // Should be on sign up screen
      expect(find.text('Begin Your'), findsOneWidget);
      expect(find.text('Grand Adventure'), findsOneWidget);

      // Fill out sign up form
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final testEmail = 'testuser$timestamp@example.com';
      
      await tester.enterText(
        find.byKey(Key('explorer_name_field')), 
        'Test Explorer'
      );
      await tester.enterText(
        find.byKey(Key('email_field')), 
        testEmail
      );
      await tester.enterText(
        find.byKey(Key('password_field')), 
        'TestPassword123!'
      );
      await tester.enterText(
        find.byKey(Key('confirm_password_field')), 
        'TestPassword123!'
      );

      // Submit sign up form
      await tester.tap(find.text('Start My Journey'));
      await tester.pumpAndSettle(Duration(seconds: 10));

      // Should be signed in and on home screen
      expect(find.text('Welcome to Project Atlas!'), findsOneWidget);
      expect(find.text('Test Explorer'), findsOneWidget);

      // Sign out
      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      // Should be back on login screen
      expect(find.text('Welcome Back,'), findsOneWidget);

      // Sign back in
      await tester.enterText(
        find.byKey(Key('email_field')), 
        testEmail
      );
      await tester.enterText(
        find.byKey(Key('password_field')), 
        'TestPassword123!'
      );

      await tester.tap(find.text('Continue Journey'));
      await tester.pumpAndSettle(Duration(seconds: 5));

      // Should be signed in again
      expect(find.text('Welcome to Project Atlas!'), findsOneWidget);
    });

    testWidgets('should handle invalid credentials', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 5));

      // Try to sign in with invalid credentials
      await tester.enterText(
        find.byKey(Key('email_field')), 
        'nonexistent@example.com'
      );
      await tester.enterText(
        find.byKey(Key('password_field')), 
        'wrongpassword'
      );

      await tester.tap(find.text('Continue Journey'));
      await tester.pumpAndSettle(Duration(seconds: 5));

      // Should show error message
      expect(find.text('No account found with this email address'), findsOneWidget);
      
      // Should still be on login screen
      expect(find.text('Welcome Back,'), findsOneWidget);
    });

    testWidgets('forgot password flow', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 5));

      // Tap forgot password
      await tester.tap(find.text('Forgot your map?'));
      await tester.pumpAndSettle();

      // Should show forgot password dialog
      expect(find.text('Reset Your Password'), findsOneWidget);

      // Enter email
      await tester.enterText(
        find.byKey(Key('reset_email_field')), 
        'test@example.com'
      );

      // Send reset email
      await tester.tap(find.text('Send Reset Email'));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Should show success message
      expect(find.text('Password reset email sent'), findsOneWidget);
    });
  });
}
```

#### **2. Performance Integration Tests**
```dart
// integration_test/performance_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:study/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Integration Tests', () {
    testWidgets('app startup performance', (tester) async {
      // Measure cold start time
      final stopwatch = Stopwatch()..start();
      
      app.main();
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // App should start within 3 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      
      print('Cold start time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('screen transition performance', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to sign up screen and measure transition time
      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.text('Begin New Adventure'));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Screen transition should be under 300ms
      expect(stopwatch.elapsedMilliseconds, lessThan(300));
      
      print('Screen transition time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('frame rate during animations', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Start measuring frame rate
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();

      // Trigger animations by navigating
      await tester.tap(find.text('Begin New Adventure'));
      
      // Measure frame rate during animation
      final frameRateData = await binding.getTimeline();
      
      // Analyze frame rate data
      final frameTimes = frameRateData.map((frame) => frame['ts'] as int).toList();
      final frameDeltas = <int>[];
      
      for (int i = 1; i < frameTimes.length; i++) {
        frameDeltas.add(frameTimes[i] - frameTimes[i - 1]);
      }
      
      // Calculate average frame time
      final avgFrameTime = frameDeltas.reduce((a, b) => a + b) / frameDeltas.length;
      final avgFps = 1000000 / avgFrameTime; // Convert microseconds to FPS
      
      // Should maintain at least 55 FPS during animations
      expect(avgFps, greaterThanOrEqualTo(55));
      
      print('Average FPS during animation: ${avgFps.toStringAsFixed(1)}');
    });
  });
}
```

---

## Mock Data and Test Setup

### **Test Fixtures and Mock Data**

#### **1. Test Data Factory**
```dart
// test/fixtures/test_data_factory.dart
import 'package:study/models/user_model.dart';
import 'package:study/models/auth_state.dart';

class TestDataFactory {
  static UserModel createTestUser({
    String uid = 'test_uid',
    String email = 'test@example.com',
    String displayName = 'Test User',
    int level = 1,
    int xp = 0,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      level: level,
      xp: xp,
      createdAt: DateTime(2024, 1, 1),
      lastActiveAt: DateTime.now(),
    );
  }

  static List<UserModel> createTestUsers(int count) {
    return List.generate(count, (index) => createTestUser(
      uid: 'test_uid_$index',
      email: 'user$index@example.com',
      displayName: 'Test User $index',
      level: (index % 10) + 1,
      xp: index * 100,
    ));
  }

  static AuthData createAuthData({
    AuthState state = AuthState.initial,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthData(
      state: state,
      user: user,
      errorMessage: errorMessage,
    );
  }
}
```

#### **2. Mock Service Implementations**
```dart
// test/mocks/mock_auth_service.dart
import 'package:mockito/mockito.dart';
import 'package:study/services/auth_service.dart';
import 'package:study/models/user_model.dart';

class MockAuthService extends Mock implements AuthService {
  final Map<String, UserModel> _users = {};
  final Map<String, String> _passwords = {};
  
  UserModel? _currentUser;

  void addTestUser(String email, String password, UserModel user) {
    _users[email] = user;
    _passwords[email] = password;
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future.delayed(Duration(milliseconds: 100)); // Simulate network delay
    
    if (!_users.containsKey(email)) {
      throw AuthException('No account found with this email address');
    }
    
    if (_passwords[email] != password) {
      throw AuthException('Incorrect password');
    }
    
    _currentUser = _users[email]!;
    return _currentUser!;
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await Future.delayed(Duration(milliseconds: 200)); // Simulate network delay
    
    if (_users.containsKey(email)) {
      throw AuthException('An account already exists with this email');
    }
    
    final user = UserModel.newUser(
      uid: 'mock_uid_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
    );
    
    _users[email] = user;
    _passwords[email] = password;
    _currentUser = user;
    
    return user;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  UserModel? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => message;
}
```

---

## CI/CD Testing Pipeline

### **GitHub Actions Workflow**
```yaml
# .github/workflows/test.yml
name: Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.29.0'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Run analyzer
      run: flutter analyze
      
    - name: Run unit tests
      run: flutter test --coverage
      
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info
        
  integration_test:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.29.0'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Start iOS Simulator
      uses: futureware-tech/simulator-action@v2
      with:
        model: 'iPhone 14'
        
    - name: Run integration tests
      run: flutter test integration_test/
      
  performance_test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.29.0'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Run performance tests
      run: |
        flutter drive \
          --driver=test_driver/integration_test.dart \
          --target=integration_test/performance_test.dart \
          --profile
```

---

## Test Coverage Goals

### **Coverage Targets**
- **Unit Tests**: 90% coverage for business logic
- **Widget Tests**: 80% coverage for UI components  
- **Integration Tests**: 100% coverage for critical user flows
- **Overall Target**: 85% code coverage

### **Coverage Analysis Setup**
```dart
// test/test_coverage_helper.dart
// This file is used to import all files for coverage analysis
// ignore_for_file: unused_import

import 'package:study/main.dart';
import 'package:study/models/auth_state.dart';
import 'package:study/models/user_model.dart';
import 'package:study/providers/auth_provider.dart';
import 'package:study/screens/auth/auth_wrapper.dart';
import 'package:study/screens/auth/login_screen.dart';
import 'package:study/screens/auth/signup_screen.dart';
import 'package:study/services/auth_service.dart';
import 'package:study/services/firebase_service.dart';
import 'package:study/theme/app_colors.dart';
import 'package:study/theme/app_theme.dart';
import 'package:study/widgets/auth/auth_button.dart';
import 'package:study/widgets/auth/custom_text_field.dart';
import 'package:study/widgets/common/loading_overlay.dart';

void main() {
  // This file exists solely to improve test coverage reporting
}
```

### **Test Execution Scripts**
```bash
#!/bin/bash
# scripts/run_tests.sh

echo "Running Project Atlas Test Suite..."

# Unit tests with coverage
echo "📋 Running unit tests..."
flutter test --coverage

# Widget tests
echo "🎨 Running widget tests..."
flutter test test/widgets/

# Integration tests
echo "🔄 Running integration tests..."
flutter test integration_test/

# Generate coverage report
echo "📊 Generating coverage report..."
genhtml coverage/lcov.info -o coverage/html

echo "✅ All tests completed!"
echo "📄 Coverage report available at: coverage/html/index.html"
```

This comprehensive testing strategy ensures Project Atlas maintains high quality, reliability, and performance as it scales. The combination of unit, widget, and integration tests provides confidence in both individual components and complete user workflows.
