import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../../models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

/// Enhanced local authentication repository with complete offline functionality
/// and session persistence
class EnhancedLocalAuthRepository implements AuthRepository {
  final SharedPreferences _prefs;
  final Logger _logger;
  final Map<String, Map<String, dynamic>> _userDatabase = {};
  final StreamController<UserModel?> _authStateController =
      StreamController<UserModel?>.broadcast();

  static const String _userKey = 'atlas_current_user';
  static const String _isLoggedInKey = 'atlas_is_logged_in';
  static const String _usersDbKey = 'atlas_users_database';
  static const String _passwordsKey =
      'atlas_user_passwords'; // Secure in real app

  UserModel? _currentUser;
  bool _isInitialized = false;

  EnhancedLocalAuthRepository(this._prefs, this._logger);

  /// Initialize the repository and restore session
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _logger.i('Initializing Enhanced Local Auth Repository');

      // Load user database
      await _loadUserDatabase();

      // Check for existing session
      await _checkExistingSession();

      _isInitialized = true;
      _logger.i('Enhanced Local Auth Repository initialized successfully');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize auth repository',
        error: e,
        stackTrace: stackTrace,
      );
      _currentUser = null;
      _authStateController.add(null);
    }
  }

  /// Check for existing user session on app start
  Future<void> _checkExistingSession() async {
    try {
      final isLoggedIn = _prefs.getBool(_isLoggedInKey) ?? false;
      final userJson = _prefs.getString(_userKey);

      if (isLoggedIn && userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        final user = UserModel.fromJson(userMap);

        // Update last active time
        final updatedUser = user.updateLastActive();
        await _setCurrentUser(updatedUser);

        _logger.i('Session restored for user: ${user.email}');
      } else {
        _logger.i('No existing session found');
        _currentUser = null;
        _authStateController.add(null);
      }
    } catch (e) {
      _logger.e('Failed to restore session: $e');
      _currentUser = null;
      _authStateController.add(null);
    }
  }

  /// Load user database from SharedPreferences
  Future<void> _loadUserDatabase() async {
    try {
      final usersJson = _prefs.getString(_usersDbKey);
      final passwordsJson = _prefs.getString(_passwordsKey);

      if (usersJson != null) {
        final usersList = jsonDecode(usersJson) as List;
        for (final userJson in usersList) {
          final user = UserModel.fromJson(userJson as Map<String, dynamic>);
          _userDatabase[user.email] = {'user': user};
        }
      }

      if (passwordsJson != null) {
        final passwordsMap = jsonDecode(passwordsJson) as Map<String, dynamic>;
        passwordsMap.forEach((email, password) {
          if (_userDatabase.containsKey(email)) {
            _userDatabase[email]!['password'] = password;
          }
        });
      }

      _logger.i('Loaded ${_userDatabase.length} users from database');
    } catch (e) {
      _logger.e('Failed to load user database: $e');
    }
  }

  /// Save user database to SharedPreferences
  Future<void> _saveUserDatabase() async {
    try {
      final usersList =
          _userDatabase.values
              .map((data) => (data['user'] as UserModel).toJson())
              .toList();

      final passwordsMap = <String, String>{};
      _userDatabase.forEach((email, data) {
        if (data['password'] != null) {
          passwordsMap[email] = data['password'] as String;
        }
      });

      await _prefs.setString(_usersDbKey, jsonEncode(usersList));
      await _prefs.setString(_passwordsKey, jsonEncode(passwordsMap));

      _logger.d('User database saved successfully');
    } catch (e) {
      _logger.e('Failed to save user database: $e');
      throw Exception('Failed to save user data');
    }
  }

  /// Set current user and persist session
  Future<void> _setCurrentUser(UserModel user) async {
    try {
      _currentUser = user;
      await _prefs.setString(_userKey, jsonEncode(user.toJson()));
      await _prefs.setBool(_isLoggedInKey, true);
      _authStateController.add(user);
      _logger.d('Current user set: ${user.email}');
    } catch (e) {
      _logger.e('Failed to set current user: $e');
      throw Exception('Failed to save session');
    }
  }

  /// Clear current user session
  Future<void> _clearCurrentUser() async {
    try {
      _currentUser = null;
      await _prefs.setBool(_isLoggedInKey, false);
      await _prefs.remove(_userKey);
      _authStateController.add(null);
      _logger.d('Current user session cleared');
    } catch (e) {
      _logger.e('Failed to clear user session: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // Validate input
      if (email.isEmpty || password.isEmpty || displayName.isEmpty) {
        throw Exception('All fields are required');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters long');
      }

      // Check if user already exists
      final normalizedEmail = email.toLowerCase().trim();
      if (_userDatabase.containsKey(normalizedEmail)) {
        throw Exception('An account already exists with this email address');
      }

      // Create new user
      final newUser = UserModel.newUser(
        uid: const Uuid().v4(),
        email: normalizedEmail,
        displayName: displayName.trim(),
      );

      // Store user in database
      _userDatabase[normalizedEmail] = {
        'user': newUser,
        'password': password, // In real app, hash this!
      };

      await _saveUserDatabase();
      await _setCurrentUser(newUser);

      _logger.i('User signed up successfully: ${newUser.email}');
      return newUser;
    } catch (e) {
      _logger.e('Signup failed: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      final normalizedEmail = email.toLowerCase().trim();
      final userData = _userDatabase[normalizedEmail];

      if (userData == null) {
        throw Exception('No account found with this email address');
      }

      if (userData['password'] != password) {
        throw Exception('Incorrect password');
      }

      // Update last login time
      final user = userData['user'] as UserModel;
      final updatedUser = user.updateLastActive();

      // Update in database
      _userDatabase[normalizedEmail] = {
        'user': updatedUser,
        'password': password,
      };

      await _saveUserDatabase();
      await _setCurrentUser(updatedUser);

      _logger.i('User signed in successfully: ${updatedUser.email}');
      return updatedUser;
    } catch (e) {
      _logger.e('Signin failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _clearCurrentUser();
      _logger.i('User signed out successfully');
    } catch (e) {
      _logger.e('Signout failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount() async {
    if (_currentUser == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      final email = _currentUser!.email;

      // Remove from database
      _userDatabase.remove(email);
      await _saveUserDatabase();

      // Clear current session
      await _clearCurrentUser();

      _logger.i('Account deleted successfully: $email');
    } catch (e) {
      _logger.e('Account deletion failed: $e');
      rethrow;
    }
  }

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  /// Get current user (convenience method)
  UserModel? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Get all users (for admin/debug purposes)
  List<UserModel> getAllUsers() {
    return _userDatabase.values
        .map((data) => data['user'] as UserModel)
        .toList();
  }

  /// Update user profile
  Future<void> updateUserProfile(UserModel updatedUser) async {
    if (_currentUser == null || _currentUser!.uid != updatedUser.uid) {
      throw Exception('Cannot update profile: user not authenticated');
    }

    try {
      // Update in database
      _userDatabase[updatedUser.email] = {
        'user': updatedUser,
        'password': _userDatabase[updatedUser.email]!['password'],
      };

      await _saveUserDatabase();
      await _setCurrentUser(updatedUser);

      _logger.i('User profile updated: ${updatedUser.email}');
    } catch (e) {
      _logger.e('Failed to update user profile: $e');
      rethrow;
    }
  }

  /// Reset password (simulation for local auth)
  Future<void> resetPassword(String email) async {
    final normalizedEmail = email.toLowerCase().trim();

    if (!_userDatabase.containsKey(normalizedEmail)) {
      throw Exception('No account found with this email address');
    }

    // In a real app, this would send an email
    // For local simulation, we just log it
    _logger.i('Password reset requested for: $normalizedEmail');

    // Could implement a temporary password or reset token here
  }

  /// Clean up resources
  void dispose() {
    _authStateController.close();
  }
}
