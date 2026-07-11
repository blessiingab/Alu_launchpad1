import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/opportunity_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../auth/providers/auth_providers.dart';
import '../../opportunities/providers/opportunity_providers.dart';
import '../../opportunities/screens/manage_opportunities_screen.dart';
import '../providers/startup_providers.dart';

/// The signed-in startup admin's own account info — distinct from the
/// "Startup" tab (which is for *adding* a startup / opportunity). This
/// screen shows personal info (name/email), plus a read-only summary of
/// everything the admin has added: their startup and their opportunities.
class StartupAccountProfileScreen extends ConsumerWidget {
  const StartupAccountProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(currentUserDataProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My profile'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
          ),
        ],
      ),
      body: userDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Something went wrong: $e')),
        data: (userData) {
          if (userData == null) {
            return const Center(child: Text('No profile found.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: colors.primary,
                    child: Text(
                      userData.name.isNotEmpty ? userData.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text('Name', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(userData.name, style: Theme.of(context).textTheme.bodyLarge),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Email', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(userData.email, style: Theme.of(context).textTheme.bodyLarge),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                Text("What you've added", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                const _MyStartupSection(),
                const SizedBox(height: AppSpacing.xl),
                const _MyOpportunitiesSection(),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Read-only summary of the startup this admin has added, if any.
class _MyStartupSection extends ConsumerWidget {
  const _MyStartupSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupsAsync = ref.watch(myStartupsProvider);
    final colors = Theme.of(context).colorScheme;

    return startupsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Text('Could not load your startups: $e'),
      data: (startups) {
        if (startups.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              "You haven't added a startup yet. Use the Startup tab to add one.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        return Column(
          children: [
            for (final startup in startups) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(startup.name,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              startup.category,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.goldDeep,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(status: startup.verificationStatus),
                    ],
                  ),
                ),
              ),
              if (startup != startups.last) const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}

/// Read-only list of the opportunities this admin has posted.
class _MyOpportunitiesSection extends ConsumerWidget {
  const _MyOpportunitiesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunitiesAsync = ref.watch(myOpportunitiesProvider);
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Opportunities posted', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        opportunitiesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, st) => Text('Could not load your opportunities: $e'),
          data: (items) {
            if (items.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  "You haven't posted any opportunities yet.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }
            return Column(
              children: [
                for (final opportunity in items.take(3)) ...[
                  OpportunityCard(
                    opportunity: opportunity,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ManageOpportunitiesScreen()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (items.length > 3)
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ManageOpportunitiesScreen()),
                    ),
                    child: Text('View all ${items.length} opportunities'),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}