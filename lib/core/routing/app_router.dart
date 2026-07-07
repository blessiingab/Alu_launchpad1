import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/app_user.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/startup/providers/startup_providers.dart';
import '../../features/startup/screens/startup_dashboard_screen.dart';
import '../../features/startup/screens/startup_profile_setup_screen.dart';

/// Central place that decides "what screen should be on screen right now"
/// given (a) whether the user is signed in, (b) their role, and
/// (c) — for startup admins — whether they've created a startup profile
/// yet. Keeping this logic here (rather than scattered through
/// initState/navigator calls) is what lets new screens plug in without
/// re-deriving navigation rules each time.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userData = ref.watch(currentUserDataProvider);
  final myStartup = ref.watch(myStartupProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: _RiverpodRefreshStream(ref),
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final loggingInRoutes = {'/login'};
      final signingUpRoute = state.matchedLocation == '/signup';
      final onWelcome = state.matchedLocation == '/';

      // Still resolving Firebase auth on cold start.
      if (authState.isLoading) return null;

      if (!isLoggedIn) {
        // if (onWelcome || loggingInRoutes.contains(state.matchedLocation) ||
        //     signingUpRoute) {
        //   return null;
        // }
        return '/';
      }

      // Logged in but profile doc hasn't streamed in yet — wait rather
      // than bouncing the user around.
      if (userData.isLoading) return null;
      final profile = userData.value;
      if (profile == null) return null;

      // Logged in and on an auth screen -> route into the app.
      final onAuthScreen = onWelcome || loggingInRoutes.contains(state.matchedLocation) ||
          signingUpRoute;

      if (profile.role == UserRole.startupAdmin) {
        if (myStartup.isLoading) return null;
        final hasStartup = myStartup.value != null;

        if (!hasStartup) {
          return state.matchedLocation == '/startup/setup'
              ? null
              : '/startup/setup';
        }
        if (onAuthScreen || state.matchedLocation == '/startup/setup') {
          return '/startup/dashboard';
        }
        return null;
      }

      // Student role.
      if (onAuthScreen) return '/student/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const RoleSelectionScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) {
          final role = state.extra as UserRole? ?? UserRole.student;
          return SignupScreen(role: role);
        },
      ),
      GoRoute(
        path: '/startup/setup',
        builder: (context, state) => const StartupProfileSetupScreen(),
      ),
      GoRoute(
        path: '/startup/dashboard',
        builder: (context, state) => const StartupDashboardScreen(),
      ),
      // Student home is scaffolded next (opportunity discovery feature).
      GoRoute(
        path: '/student/home',
        builder: (context, state) => const _StudentHomePlaceholder(),
      ),
    ],
  );
});

/// Bridges Riverpod's stream providers into a Listenable so go_router
/// re-evaluates `redirect` whenever auth/profile/startup state changes —
/// this is what makes navigation react live to e.g. verification status
/// flipping in Firestore.
class _RiverpodRefreshStream extends ChangeNotifier {
  _RiverpodRefreshStream(Ref ref) {
    ref.listen(authStateProvider, (_, _) => notifyListeners());
    ref.listen(currentUserDataProvider, (_, _) => notifyListeners());
    ref.listen(myStartupProvider, (_, _) => notifyListeners());
  }
}

class _StudentHomePlaceholder extends StatelessWidget {
  const _StudentHomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Opportunities')),
      body: const Center(
        child: Text('Student discovery screen — built in the next phase.'),
      ),
    );
  }
}
