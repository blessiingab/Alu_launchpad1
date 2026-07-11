import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/startup.dart';
import '../../../shared/widgets/opportunity_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../auth/providers/auth_providers.dart';
import '../../notifications/providers/notification_providers.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../opportunities/providers/opportunity_providers.dart';
import '../../opportunities/screens/manage_opportunities_screen.dart';
import '../../opportunities/screens/post_opportunity_screen.dart';
import '../providers/startup_providers.dart';
import 'create_startup_screen.dart';
import 'startup_account_profile_screen.dart';

class StartupDashboardScreen extends ConsumerWidget {
  const StartupDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupsAsync = ref.watch(myStartupsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final userData = ref.watch(currentUserDataProvider).value;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(unreadCount > 9 ? '9+' : '$unreadCount'),
              backgroundColor: AppColors.danger,
              child: Icon(
                unreadCount > 0
                    ? Icons.notifications_rounded
                    : Icons.notifications_outlined,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StartupAccountProfileScreen()),
            ),
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: colors.primary,
              child: Text(
                (userData?.name.isNotEmpty ?? false)
                    ? userData!.name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: colors.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: startupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Something went wrong: $e')),
        data: (startups) {
          if (startups.isEmpty) {
            return _NoStartupYet(
              onCreate: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateStartupScreen()),
              ),
            );
          }
          return _DashboardBody(startup: startups.first);
        },
      ),
    );
  }
}

class _NoStartupYet extends StatelessWidget {
  const _NoStartupYet({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_outlined, size: 48, color: colors.onSurfaceVariant),
            const SizedBox(height: AppSpacing.lg),
            Text(
              "You haven't added a startup yet",
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create your startup profile to start posting opportunities.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add your startup'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.startup});

  final Startup startup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVerified = startup.verificationStatus == VerificationStatus.verified;
    final opportunitiesAsync = ref.watch(myOpportunitiesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
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
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    startup.category,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.goldDeep,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(startup.description),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!isVerified)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.pending.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.pending.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.pending),
                  const SizedBox(width: AppSpacing.md),
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
            Row(
              children: [
                Expanded(
                  child: Text('Opportunities',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ManageOpportunitiesScreen()),
                  ),
                  child: const Text('Manage all'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            opportunitiesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, st) => Text('Could not load opportunities: $e'),
              data: (items) {
                if (items.isEmpty) {
                  return _PostOpportunityBanner(startup: startup);
                }
                return Column(
                  children: [
                    for (final opportunity in items.take(3)) ...[
                      OpportunityCard(
                        opportunity: opportunity,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ManageOpportunitiesScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    _PostOpportunityBanner(startup: startup, compact: true),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// The well-designed, gradient "Post opportunity" action — the same
/// visual treatment used on the Startup tab, so posting reads as one
/// consistent, primary action wherever it appears.
class _PostOpportunityBanner extends StatelessWidget {
  const _PostOpportunityBanner({required this.startup, this.compact = false});

  final Startup startup;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.raised(AppColors.navy),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PostOpportunityScreen(startup: startup)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: compact ? AppSpacing.md : AppSpacing.xl,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    compact ? 'Post another opportunity' : 'Post an opportunity',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}