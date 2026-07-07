import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/startup_repository.dart';
import '../../../data/models/startup.dart';
import '../../auth/providers/auth_providers.dart';

final startupRepositoryProvider = Provider<StartupRepository>((ref) {
  return StartupRepository();
});

/// Live stream of the current startup_admin's own startup profile.
/// Null while the admin hasn't created a profile yet — the router uses
/// that to send them to the "create your startup" screen.
final myStartupProvider = StreamProvider<Startup?>((ref) {
  final userData = ref.watch(currentUserDataProvider).value;
  final startupId = userData?.startupId;
  if (startupId == null) return Stream.value(null);
  return ref.watch(startupRepositoryProvider).startupStream(startupId);
});

class StartupProfileController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createStartupProfile({
    required String name,
    required String description,
    required String category,
    required String verificationNote,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authRepo = ref.read(authRepositoryProvider);
      final startupRepo = ref.read(startupRepositoryProvider);
      final uid = authRepo.currentUser!.uid;

      final startupId = await startupRepo.createStartup(
        name: name,
        description: description,
        category: category,
        verificationNote: verificationNote,
        adminUid: uid,
      );

      await authRepo.attachStartupId(uid, startupId);
    });
  }
}

final startupProfileControllerProvider =
    AsyncNotifierProvider<StartupProfileController, void>(
  StartupProfileController.new,
);
