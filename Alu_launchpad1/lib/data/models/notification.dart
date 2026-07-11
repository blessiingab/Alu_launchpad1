import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  applicationReceived, // startup admin: a student applied
  applicationStatusChanged, // student: their application was accepted/rejected
  startupVerified, // startup admin: their startup was approved/rejected
  general,
}

NotificationType _typeFromString(String value) {
  return NotificationType.values.firstWhere(
    (t) => t.name == value,
    orElse: () => NotificationType.general,
  );
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.relatedId,
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedId; // e.g. opportunityId or applicationId

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppNotification(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: _typeFromString(data['type'] as String? ?? 'general'),
      isRead: data['isRead'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      relatedId: data['relatedId'] as String?,
    );
  }

  static Map<String, dynamic> createMap({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? relatedId,
  }) {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'isRead': false,
      'relatedId': relatedId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}