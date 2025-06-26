import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class LocalAuthRepositoryImpl implements AuthRepository {
  final Map<String, Map<String, dynamic>> _users = {};
  final StreamController<UserModel?> _authStateController =
      StreamController<UserModel?>.broadcast();
  static const String _userPrefsKey = 'atlas_current_user';
  UserModel? _currentUser;

  LocalAuthRepositoryImpl();

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userPrefsKey);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        final user = UserModel.fromJson(userMap);
        _currentUser = user;
        _authStateController.add(user);
      } catch (_) {
        _currentUser = null;
        _authStateController.add(null);
      }
    } else {
      _currentUser = null;
      _authStateController.add(null);
    }
  }

  Future<void> _persistUser(UserModel? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user != null) {
      await prefs.setString(_userPrefsKey, jsonEncode(user.toJson()));
    } else {
      await prefs.remove(_userPrefsKey);
    }
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final userData = _users[email];
    if (userData == null) {
      throw Exception('No user found for that email.');
    }
    if (userData['password'] != password) {
      throw Exception('Incorrect password.');
    }
    final user = userData['user'] as UserModel;
    _currentUser = user;
    _authStateController.add(user);
    await _persistUser(user);
    return user;
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (_users.containsKey(email)) {
      throw Exception('Email already in use.');
    }
    final user = UserModel.newUser(
      uid: email, // For local, use email as UID
      email: email,
      displayName: displayName,
    );
    _users[email] = {'user': user, 'password': password};
    _currentUser = user;
    _authStateController.add(user);
    await _persistUser(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
    await _persistUser(null);
  }

  @override
  Future<void> deleteAccount() async {
    // Get current user before deletion
    if (_currentUser != null) {
      // Remove user from local storage
      _users.remove(_currentUser!.email);
    }
    // Clear authentication state
    _currentUser = null;
    _authStateController.add(null);
    await _persistUser(null);
  }

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  /// Ensures the repository is initialized (for hot-restart persistence)
  Future<void> ensureInitialized() async {
    await _init();
  }
}
