import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification.dart';

class NotificationRepository {
  NotificationRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection('notifications');

  /// Live stream of all notifications for [uid], most recent first.
  Stream<List<AppNotification>> myNotificationsStream(String uid) {
    return _notifications
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(AppNotification.fromDoc).toList());
  }

  Future<void> create({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? relatedId,
  }) {
    return _notifications.add(AppNotification.createMap(
      userId: userId,
      title: title,
      body: body,
      type: type,
      relatedId: relatedId,
    ));
  }

  Future<void> markAsRead(String notificationId) {
    return _notifications.doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllAsRead(String uid) async {
    final unread = await _notifications
        .where('userId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}