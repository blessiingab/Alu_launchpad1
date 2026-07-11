import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/application.dart';
import '../../../data/models/notification.dart';
import '../../../data/repositories/application_repository.dart';
import '../../auth/providers/auth_providers.dart';
import '../../notifications/providers/notification_providers.dart';
import '../../startup/providers/startup_providers.dart';

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepository();
});

/// Live stream of the signed-in student's own applications.
final myApplicationsProvider = StreamProvider<List<Application>>((ref) {
  final userData = ref.watch(currentUserDataProvider).value;
  if (userData == null) return Stream.value(const []);
  return ref.watch(applicationRepositoryProvider).myApplicationsStream(userData.uid);
});

/// Live stream of all applications submitted for one opportunity — for the
/// startup admin reviewing candidates.
final applicationsForOpportunityProvider =
    StreamProvider.family<List<Application>, String>((ref, opportunityId) {
  return ref
      .watch(applicationRepositoryProvider)
      .forOpportunityStream(opportunityId);
});

/// Whether the current student has already applied to [opportunityId].
/// Re-evaluates whenever [applicationFormControllerProvider] changes state,
/// so it flips to true right after a successful submit.
final hasAppliedProvider =
    FutureProvider.family<bool, String>((ref, opportunityId) async {
  final userData = ref.watch(currentUserDataProvider).value;
  if (userData == null) return false;
  ref.watch(applicationFormControllerProvider);
  return ref.watch(applicationRepositoryProvider).hasApplied(
        opportunityId: opportunityId,
        studentId: userData.uid,
      );
});

class ApplicationFormController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submit({
    required String opportunityId,
    required String opportunityTitle,
    required String startupId,
    required String startupName,
    required String message,
  }) async {
    final userData = ref.read(currentUserDataProvider).value;
    if (userData == null) {
      state = AsyncError('You need to be signed in to apply.', StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(applicationRepositoryProvider);

      final alreadyApplied = await repo.hasApplied(
        opportunityId: opportunityId,
        studentId: userData.uid,
      );
      if (alreadyApplied) {
        throw StateError("You've already applied to this opportunity.");
      }

      await repo.submitApplication(
        opportunityId: opportunityId,
        opportunityTitle: opportunityTitle,
        startupId: startupId,
        startupName: startupName,
        studentId: userData.uid,
        studentName: userData.name,
        studentEmail: userData.email,
        message: message,
      );

      // Notify every admin on the startup that a new application came
      // in. Best-effort: a failure here shouldn't roll back or surface
      // as an error on an otherwise-successful application submission,
      // so it's deliberately not awaited inside the guarded block above
      // in a way that would fail the whole submit.
      await _notifyStartupOfNewApplication(
        startupId: startupId,
        startupName: startupName,
        opportunityTitle: opportunityTitle,
        studentName: userData.name,
      );
    });
  }

  Future<void> _notifyStartupOfNewApplication({
    required String startupId,
    required String startupName,
    required String opportunityTitle,
    required String studentName,
  }) async {
    try {
      final startupRepo = ref.read(startupRepositoryProvider);
      final startup = await startupRepo.startupStream(startupId).first;
      final notificationRepo = ref.read(notificationRepositoryProvider);

      for (final adminUid in startup?.adminUids ?? const <String>[]) {
        await notificationRepo.create(
          userId: adminUid,
          title: 'New application',
          body: '$studentName applied to "$opportunityTitle"',
          type: NotificationType.applicationReceived,
          relatedId: opportunityTitle,
        );
      }
    } catch (_) {
      // Notification delivery is not critical to the apply flow itself —
      // swallow so a Firestore hiccup here never blocks a real
      // application from having already succeeded above.
    }
  }
}

final applicationFormControllerProvider =
    AsyncNotifierProvider<ApplicationFormController, void>(
  ApplicationFormController.new,
);

/// Lets a startup admin change an application's status (reviewed /
/// accepted / rejected) and notifies the applicant when they do.
class ApplicationStatusController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateStatus(Application application, ApplicationStatus status) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(applicationRepositoryProvider);
      await repo.updateStatus(application.id, status);

      if (status == ApplicationStatus.accepted || status == ApplicationStatus.rejected) {
        try {
          final notificationRepo = ref.read(notificationRepositoryProvider);
          await notificationRepo.create(
            userId: application.studentId,
            title: status == ApplicationStatus.accepted
                ? 'Application accepted'
                : 'Application update',
            body: status == ApplicationStatus.accepted
                ? '${application.startupName} accepted your application for '
                    '"${application.opportunityTitle}"'
                : '${application.startupName} has updated your application for '
                    '"${application.opportunityTitle}"',
            type: NotificationType.applicationStatusChanged,
            relatedId: application.opportunityId,
          );
        } catch (_) {
          // Same reasoning as above — a notification failure shouldn't
          // undo a status update that already succeeded.
        }
      }
    });
  }
}

final applicationStatusControllerProvider =
    AsyncNotifierProvider<ApplicationStatusController, void>(
  ApplicationStatusController.new,
);