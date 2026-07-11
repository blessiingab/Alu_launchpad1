import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/startup_repository.dart';
import '../../../data/models/startup.dart';
import '../../auth/providers/auth_providers.dart';

final startupRepositoryProvider = Provider<StartupRepository>((ref) {
  return StartupRepository();
});

/// Every startup the current admin owns, live — one admin can own more
/// than one startup, so this is a list rather than a single stream.
/// Every screen that used to watch a single `myStartupProvider` now
/// watches this and handles zero/one/many.
final myStartupsProvider = StreamProvider<List<Startup>>((ref) {
  final userData = ref.watch(currentUserDataProvider).value;
  final startupIds = userData?.startupIds ?? const [];
  if (startupIds.isEmpty) return Stream.value(const []);
  return ref.watch(startupRepositoryProvider).startupsStream(startupIds);
});

class StartupProfileController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Creates a new startup for the signed-in admin. Safe to call more
  /// than once — each call adds another startup to their startupIds
  /// list rather than replacing the previous one.
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

  /// Edits one of the admin's existing startups. Mirrors
  /// StartupRepository.updateProfile()'s fields only (name/description/
  /// category) — verificationStatus and verificationNote are never
  /// touched here, matching the Firestore rule that blocks a startup
  /// admin from changing their own verification status.
  Future<void> editStartupProfile({
    required String startupId,
    required String name,
    required String description,
    required String category,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final startupRepo = ref.read(startupRepositoryProvider);
      await startupRepo.updateProfile(
        startupId: startupId,
        name: name,
        description: description,
        category: category,
      );
    });
  }
}

final startupProfileControllerProvider =
    AsyncNotifierProvider<StartupProfileController, void>(
  StartupProfileController.new,
);