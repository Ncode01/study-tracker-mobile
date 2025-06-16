import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing the explorer's profile in Project Atlas
/// Matches the Firestore 'users' collection structure
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final int level;
  final int xp;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.level,
    required this.xp,
    required this.createdAt,
    required this.lastActiveAt,
  });

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
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      level: (json['level'] as num).toInt(),
      xp: (json['xp'] as num).toInt(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      lastActiveAt: (json['lastActiveAt'] as Timestamp).toDate(),
    );
  }

  /// Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'level': level,
      'xp': xp,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
    };
  }

  /// Create a copy of this UserModel with updated values
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    int? level,
    int? xp,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

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

  @override
  String toString() {
    return 'UserModel(uid: $uid, displayName: $displayName, level: $level, xp: $xp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.level == level &&
        other.xp == xp &&
        other.createdAt == createdAt &&
        other.lastActiveAt == lastActiveAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      uid,
      email,
      displayName,
      level,
      xp,
      createdAt,
      lastActiveAt,
    );
  }
}
