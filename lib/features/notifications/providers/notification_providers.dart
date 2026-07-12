import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/notification.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../auth/providers/auth_providers.dart';

// This file must ONLY contain providers — AppNotification and
// NotificationType live in data/models/notification.dart. Defining them
// again here is what caused the ambiguous_import errors.

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

/// Live stream of the signed-in user's notifications.
final myNotificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final userData = ref.watch(currentUserDataProvider).value;
  if (userData == null) return Stream.value(const []);
  return ref
      .watch(notificationRepositoryProvider)
      .myNotificationsStream(userData.uid);
});

/// Derived unread count — drives the badge on the bell icon.
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(myNotificationsProvider).value ?? const [];
  return notifications.where((n) => !n.isRead).length;
});

class NotificationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> markAsRead(String notificationId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(notificationRepositoryProvider).markAsRead(notificationId),
    );
  } 

  Future<void> markAllAsRead() async {
    final userData = ref.read(currentUserDataProvider).value;
    if (userData == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(notificationRepositoryProvider).markAllAsRead(userData.uid),
    );
  }
}

final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController, void>(
  NotificationController.new,
);