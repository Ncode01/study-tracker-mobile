import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User model representing the explorer's profile in Project Atlas
/// Pure domain model without any external dependencies
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    requiured String uid,
    required String email,
    required String displayName,
    required int level,
    required int xp,
    required DateTime createdAt,
    required DateTime lastActiveAt,
  }) = _UserModel;

  /// Create a new UserModel with default values for a new explorer
  factory UserModel.newUser({
    required String uid,
    required String email,
    required String displayName,
  }) {
    final now = DateTime.now();
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      level: 1, // Every explorer starts at level 1
      xp: 0, // No XP at the beginning of the journey
      createdAt: now,
      lastActiveAt: now,
    );
  }

  /// Create UserModel from JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

/// Extension methods for UserModel
extension UserModelExtensions on UserModel {
  /// Update the last active timestamp to now
  UserModel updateLastActive() {
    return copyWith(lastActiveAt: DateTime.now());
  }

  /// Explorer title based on level
  String get explorerTitle {
    if (level >= 50) return 'Legendary Explorer';
    if (level >= 30) return 'Master Explorer';
    if (level >= 20) return 'Expert Explorer';
    if (level >= 10) return 'Skilled Explorer';
    if (level >= 5) return 'Experienced Explorer';
    return 'Novice Explorer';
  }

  /// XP required for next level
  int get xpForNextLevel => (level * 100);

  /// Whether the user can level up
  bool get canLevelUp => xp >= xpForNextLevel;

  /// Progress towards next level (0.0 - 1.0)
  double get xpProgress => (xp / xpForNextLevel).clamp(0.0, 1.0);
}
