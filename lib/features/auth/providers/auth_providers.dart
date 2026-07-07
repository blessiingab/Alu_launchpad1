import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_user.dart';
import '../../../data/repositories/auth_repository.dart';

/// Singleton repository instance. Every other auth provider reads through
/// this one, so swapping the data source (e.g. for tests, with a fake
/// repository via ProviderScope overrides) never touches UI code.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Raw Firebase auth state (signed in / signed out). This is the root of
/// the app's routing decisions — see core/routing/app_router.dart.
final authStateProvider = StreamProvider<fb.User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Live Firestore profile for the signed-in user. Re-emits automatically
/// whenever the `users/{uid}` doc changes (e.g. bookmarks added elsewhere),
/// which is what makes UI like the verification badge update in real time
/// without any manual refresh call.
final currentUserDataProvider = StreamProvider<AppUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  final uid = authState.value?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(authRepositoryProvider).userDataStream(uid);
});

enum AuthFormMode { login, signup }

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // no-op initial state
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.signIn(email: email, password: password);
    });
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.signUp(
        name: name,
        email: email,
        password: password,
        role: role,
      );
    });
  }

  Future<void> signOut() async {
    await _repo.signOut();
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
