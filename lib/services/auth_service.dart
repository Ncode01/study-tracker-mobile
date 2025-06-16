import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Authentication service that wraps Firebase Auth operations
/// This is a clean abstraction layer between Firebase and our app logic
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get the current Firebase user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Check if a user is currently authenticated
  bool get isAuthenticated => currentUser != null;

  /// Sign up a new explorer with email and password
  /// Creates both Firebase Auth user and Firestore user profile
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create Firebase Auth user
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Failed to create user account');
      }

      // Update the user's display name
      await user.updateDisplayName(displayName);

      // Create user profile in Firestore
      final userModel = UserModel.newUser(
        uid: user.uid,
        email: email,
        displayName: displayName,
      );

      await _createUserProfile(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  /// Sign in an existing explorer with email and password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Failed to sign in');
      }

      // Get user profile from Firestore and update last active
      final userModel = await getUserProfile(user.uid);
      final updatedUser = userModel.updateLastActive();
      await _updateUserProfile(updatedUser);

      return updatedUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  /// Get user profile from Firestore
  Future<UserModel> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        throw Exception('User profile not found');
      }

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  /// Update user profile in Firestore
  Future<void> updateUserProfile(UserModel user) async {
    await _updateUserProfile(user);
  }

  /// Create a new user profile in Firestore
  Future<void> _createUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toJson());
    } catch (e) {
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }

  /// Update existing user profile in Firestore
  Future<void> _updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  /// Convert Firebase Auth exceptions to user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No explorer found with this email. Ready to start a new journey?';
      case 'wrong-password':
        return 'Incorrect password. Check your credentials and try again.';
      case 'email-already-in-use':
        return 'An explorer with this email already exists. Try signing in instead.';
      case 'weak-password':
        return 'Password is too weak. Choose a stronger password for your journey.';
      case 'invalid-email':
        return 'Invalid email address. Please enter a valid email.';
      case 'user-disabled':
        return 'This explorer account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Take a break and try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      default:
        return 'Authentication failed: ${e.message ?? 'Unknown error'}';
    }
  }

  /// Delete user account (for future implementation)
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }

    try {
      // Delete user profile from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth user
      await user.delete();
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }
}
