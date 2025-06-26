import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User model representing the explorer's profile in Project Atlas
/// Matches the Firestore 'users' collection structure
@freezed
class UserModel with _$UserModel {
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
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

/// Extension methods for UserModel
extension UserModelExtensions on UserModel {
  /// Update the last active timestamp to now
  UserModel updateLastActive() {
    return copyWith(lastActiveAt: DateTime.now());
  }
}

/// Custom converter for Firestore Timestamp to DateTime
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime dateTime) => Timestamp.fromDate(dateTime);
}
