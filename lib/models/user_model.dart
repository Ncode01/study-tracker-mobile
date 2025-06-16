import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User model representing the explorer's profile in Project Atlas
/// Matches the Firestore 'users' collection structure
/// 
/// This model uses freezed for immutable data classes with automatic
/// code generation for copyWith, equality, hashCode, and JSON serialization.
@freezed
class UserModel with _$UserModel {
  const UserModel._(); // Private constructor for custom methods

  const factory UserModel({
    required String uid,
    required String email,
    required String displayName,
    required int level,
    required int xp,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime lastActiveAt,
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

  /// Create UserModel from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  /// Update last active timestamp
  UserModel updateLastActive() {
    return copyWith(lastActiveAt: DateTime.now());
  }

  /// Calculate XP needed for next level
  /// Level progression: Level 1 = 0 XP, Level 2 = 100 XP, Level 3 = 250 XP, etc.
  int get xpForNextLevel {
    if (level == 1) return 100;
    return level * 150 - 50; // Progressive XP requirements
  }

  /// Calculate XP progress towards next level (0.0 to 1.0)
  double get xpProgress {
    if (level == 1 && xp < 100) {
      return xp / 100.0;
    }

    final currentLevelXp = (level - 1) * 150 - 50;
    final nextLevelXp = xpForNextLevel;
    final progressXp = xp - currentLevelXp;
    final requiredXp = nextLevelXp - currentLevelXp;

    return (progressXp / requiredXp).clamp(0.0, 1.0);
  }

  /// Check if the explorer can level up
  bool get canLevelUp => xp >= xpForNextLevel;

  /// Get the explorer's title based on level
  String get explorerTitle {
    if (level >= 50) return 'Legendary Explorer';
    if (level >= 40) return 'Master Navigator';
    if (level >= 30) return 'Seasoned Traveler';
    if (level >= 20) return 'Experienced Adventurer';
    if (level >= 10) return 'Skilled Explorer';
    if (level >= 5) return 'Apprentice Traveler';
    return 'Novice Explorer';
  }
}

/// Custom JSON converter for Firestore Timestamps
class TimestampConverter implements JsonConverter<DateTime, Object> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is Timestamp) {
      return json.toDate();
    }
    if (json is String) {
      return DateTime.parse(json);
    }
    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }
    throw ArgumentError('Cannot convert $json to DateTime');
  }

  @override
  Object toJson(DateTime dateTime) => Timestamp.fromDate(dateTime);
}
