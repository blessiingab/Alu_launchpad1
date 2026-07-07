import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, startupAdmin }

UserRole userRoleFromString(String value) {
  switch (value) {
    case 'startup_admin':
      return UserRole.startupAdmin;
    case 'student':
    default:
      return UserRole.student;
  }
}

String userRoleToString(UserRole role) {
  switch (role) {
    case UserRole.startupAdmin:
      return 'startup_admin';
    case UserRole.student:
      return 'student';
  }
}

/// Mirrors a document in the top-level `users` collection.
/// Doc id == Firebase Auth uid.
class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final List<String> skills; // relevant to students
  final String? startupId; // relevant to startupAdmin
  final List<String> bookmarks; // opportunity ids
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.skills = const [],
    this.startupId,
    this.bookmarks = const [],
    this.createdAt,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: userRoleFromString(map['role'] as String? ?? 'student'),
      skills: List<String>.from(map['skills'] as List? ?? const []),
      startupId: map['startupId'] as String?,
      bookmarks: List<String>.from(map['bookmarks'] as List? ?? const []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': userRoleToString(role),
      'skills': skills,
      'startupId': startupId,
      'bookmarks': bookmarks,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }

  AppUser copyWith({
    String? name,
    List<String>? skills,
    String? startupId,
    List<String>? bookmarks,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email,
      role: role,
      skills: skills ?? this.skills,
      startupId: startupId ?? this.startupId,
      bookmarks: bookmarks ?? this.bookmarks,
      createdAt: createdAt,
    );
  }
}
