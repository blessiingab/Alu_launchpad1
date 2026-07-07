import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/startup.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/startup_providers.dart';

class StartupDashboardScreen extends ConsumerWidget {
  const StartupDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(myStartupProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign out',
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: startupAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Something went wrong: $e')),
        data: (startup) {
          if (startup == null) {
            return const Center(child: Text('No startup profile found.'));
          }
          return _DashboardBody(startup: startup);
        },
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.startup});

  final Startup startup;

  @override
  Widget build(BuildContext context) {
    final isVerified = startup.verificationStatus == VerificationStatus.verified;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          startup.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      StatusBadge(status: startup.verificationStatus),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    startup.category,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.goldDeep,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(startup.description),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!isVerified)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 124, 52, 52).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all( color: const Color.fromARGB(255, 124, 52, 52).withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.pending),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      startup.verificationStatus == VerificationStatus.rejected
                          ? 'Your verification was rejected. Please update your '
                              'details or contact the platform team.'
                          : 'Your startup is awaiting verification. You can post '
                              'opportunities once approved — this usually reflects '
                              'here automatically once reviewed.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Text('Opportunities', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            const _EmptyOpportunities(),
          ],
        ],
      ),
    );
  }
}

class _EmptyOpportunities extends StatelessWidget {
  const _EmptyOpportunities();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          const Icon(Icons.work_outline_rounded, size: 32, color: AppColors.inkMuted),
          const SizedBox(height: 12),
          Text(
            "You haven't posted any opportunities yet.",
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const OutlinedButton(
            // Wired up in the next build phase: opportunity posting screen.
            onPressed: null,
            child: Text('Post an opportunity (coming next)'),
          ),
        ],
      ),
    );
  }
}