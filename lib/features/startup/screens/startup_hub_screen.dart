import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/startup.dart';
import '../../opportunities/screens/post_opportunity_screen.dart';
import '../providers/startup_providers.dart';
import 'create_startup_screen.dart';

/// The "Startup" tab. Each admin owns at most one startup: this screen
/// shows it (with an Edit action) if it exists, or an "Add your startup"
/// prompt if it doesn't. Once a startup exists, there is no way to add
/// a second one — editing is the only path forward.
class StartupHubScreen extends ConsumerWidget {
  const StartupHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupsAsync = ref.watch(myStartupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Startup')),
      body: startupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Something went wrong: $e')),
        data: (startups) => _HubBody(startups: startups),
      ),
    );
  }
}

class _HubBody extends StatelessWidget {
  const _HubBody({required this.startups});

  final List<Startup> startups;

  @override
  Widget build(BuildContext context) {
    final startup = startups.isEmpty ? null : startups.first;
    final isVerified = startup?.verificationStatus == VerificationStatus.verified;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl,
      ),
      children: [
        if (startup == null)
          _AddStartupCard(
            onAdd: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateStartupScreen()),
            ),
          )
        else
          _StartupCard(startup: startup),
        const SizedBox(height: AppSpacing.lg),
        _PostOpportunityCard(startup: startup, isVerified: isVerified),
      ],
    );
  }
}

class _AddStartupCard extends StatelessWidget {
  const _AddStartupCard({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
   
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.duskGradientSubtle,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.storefront_rounded, color: Colors.white),
          const SizedBox(height: AppSpacing.md),
          const Text(
            "You haven't added a startup yet.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Add your venture to start posting opportunities to students.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add your startup'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.navyDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StartupCard extends StatelessWidget {
  const _StartupCard({required this.startup});

  final Startup startup;

  String _statusLabel(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
      case VerificationStatus.pending:
        return 'Pending verification';
    }
  }

  Color _statusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return AppColors.verified;
      case VerificationStatus.rejected:
        return AppColors.rejected;
      case VerificationStatus.pending:
        return AppColors.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = _statusColor(startup.verificationStatus);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  child: Icon(Icons.storefront_rounded, color: colors.onPrimaryContainer),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(startup.name, style: Theme.of(context).textTheme.titleMedium),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    _statusLabel(startup.verificationStatus),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(startup.category, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateStartupScreen(existing: startup),
                  ),
                ),
                child: const Text('Edit startup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A visually distinct, gradient "Post opportunity" action — the primary
/// call to action on this screen, so it's designed to stand out rather
/// than look like just another outlined card button.
class _PostOpportunityCard extends StatelessWidget {
  const _PostOpportunityCard({required this.startup, required this.isVerified});

  final Startup? startup;
  final bool isVerified;

  String get _subtitle {
    if (startup == null) return 'Add your startup first before posting opportunities.';
    if (!isVerified) {
      return 'Your startup is awaiting verification — you can post once '
          "it's approved.";
    }
    return 'Share a job, internship, or gig with students.';
  }

  @override
  Widget build(BuildContext context) {
    final enabled = isVerified;

    return Container(
      decoration: BoxDecoration(
        gradient: enabled ? AppColors.heroGradient : null,
        color: enabled ? null : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: enabled ? AppShadows.raised(AppColors.navy) : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: !enabled
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PostOpportunityScreen(startup: startup),
                    ),
                  ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: enabled
                        ? Colors.white.withValues(alpha: 0.18)
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: enabled
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Post an opportunity',
                        style: TextStyle(
                          color: enabled
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle,
                        style: TextStyle(
                          color: enabled
                              ? Colors.white.withValues(alpha: 0.85)
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (enabled)
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}