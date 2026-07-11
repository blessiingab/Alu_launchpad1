import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/application.dart';
import '../../../data/models/opportunity.dart';
import '../providers/application_provider.dart';

/// Startup-side screen: everyone who applied to one opportunity, with
/// accept/reject actions. Reached from ManageOpportunitiesScreen's
/// per-card menu ("View applicants").
class ApplicantsScreen extends ConsumerWidget {
  const ApplicantsScreen({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicantsAsync = ref.watch(applicationsForOpportunityProvider(opportunity.id));
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Applicants'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              opportunity.title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
      body: applicantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Something went wrong: $e')),
        data: (applicants) {
          if (applicants.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline_rounded,
                        size: 40, color: colors.onSurfaceVariant),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No one has applied yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: applicants.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) => _ApplicantCard(application: applicants[index]),
          );
        },
      ),
    );
  }
}

class _ApplicantCard extends ConsumerWidget {
  const _ApplicantCard({required this.application});

  final Application application;

  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return AppColors.pending;
      case ApplicationStatus.reviewed:
        return AppColors.goldDeep;
      case ApplicationStatus.accepted:
        return AppColors.verified;
      case ApplicationStatus.rejected:
        return AppColors.rejected;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _statusColor(application.status);
    final controllerState = ref.watch(applicationStatusControllerProvider);
    final isDecided = application.status == ApplicationStatus.accepted ||
        application.status == ApplicationStatus.rejected;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    application.studentName.isNotEmpty
                        ? application.studentName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(application.studentName,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(application.studentEmail,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
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
                    applicationStatusLabel(application.status),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            if (application.message.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(application.message, style: Theme.of(context).textTheme.bodyMedium),
            ],
            if (!isDecided) ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controllerState.isLoading
                          ? null
                          : () => ref
                              .read(applicationStatusControllerProvider.notifier)
                              .updateStatus(application, ApplicationStatus.rejected),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: controllerState.isLoading
                          ? null
                          : () => ref
                              .read(applicationStatusControllerProvider.notifier)
                              .updateStatus(application, ApplicationStatus.accepted),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}