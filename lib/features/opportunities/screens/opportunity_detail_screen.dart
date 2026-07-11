import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/opportunity.dart';
import '../../../shared/widgets/notched_shape.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../applications/providers/application_provider.dart';
import '../../applications/widgets/application_form.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/opportunity_providers.dart';

class OpportunityDetailScreen extends ConsumerWidget {
  const OpportunityDetailScreen({super.key, required this.opportunityId});

  final String opportunityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunityAsync = ref.watch(opportunityByIdProvider(opportunityId));
    final userData = ref.watch(currentUserDataProvider).value;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Opportunity')),
      body: opportunityAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Something went wrong: $e')),
        data: (opportunity) {
          if (opportunity == null) {
            return const Center(child: Text('This opportunity no longer exists.'));
          }
          final isBookmarked = userData?.bookmarks.contains(opportunity.id) ?? false;
          final closed = opportunity.status == OpportunityStatus.closed;
          final hasAppliedAsync = ref.watch(hasAppliedProvider(opportunity.id));

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- Gradient icon badge + title block ----
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppColors.heroGradient,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opportunity.title,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  opportunity.startupName,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: AppColors.goldDeep,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _InfoChip(
                            icon: Icons.work_outline_rounded,
                            label: opportunityTypeLabel(opportunity.type),
                          ),
                          if (opportunity.workMode != WorkMode.onsite ||
                              opportunity.location.isNotEmpty)
                            _InfoChip(
                              icon: Icons.place_outlined,
                              label: opportunity.workMode == WorkMode.onsite
                                  ? opportunity.location
                                  : workModeLabel(opportunity.workMode),
                            ),
                          if (opportunity.deadline != null)
                            _InfoChip(
                              icon: Icons.event_outlined,
                              label:
                                  'Deadline ${_formatDate(opportunity.deadline!)}',
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      ClipPath(
                        clipper: const NotchedCornerClipper(
                          notch: 20, radius: AppRadius.lg,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          color: colors.surfaceContainerHighest,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('About this opportunity',
                                  style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: AppSpacing.sm),
                              Text(opportunity.description),
                            ],
                          ),
                        ),
                      ),
                      if (opportunity.skillsRequired.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xxl),
                        Text('Skills required',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: opportunity.skillsRequired
                              .map((s) => Chip(label: Text(s)))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      IconButton.outlined(
                        onPressed: userData == null
                            ? null
                            : () => ref
                                .read(bookmarkControllerProvider.notifier)
                                .toggle(opportunity.id),
                        icon: Icon(
                          isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: isBookmarked ? AppColors.gold : colors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: hasAppliedAsync.when(
                          loading: () => const PrimaryButton(
                            label: 'Apply Now',
                            isLoading: true,
                            onPressed: null,
                          ),
                          error: (e, st) => PrimaryButton(
                            label: closed ? 'Applications closed' : 'Apply Now',
                            onPressed: closed
                                ? null
                                : () => _openApplicationForm(context, opportunity),
                          ),
                          data: (hasApplied) => PrimaryButton(
                            label: closed
                                ? 'Applications closed'
                                : hasApplied
                                    ? 'Application sent'
                                    : 'Apply Now',
                            onPressed: (closed || hasApplied || userData == null)
                                ? null
                                : () => _openApplicationForm(context, opportunity),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openApplicationForm(BuildContext context, Opportunity opportunity) {
    showApplicationForm(
      context,
      opportunityId: opportunity.id,
      opportunityTitle: opportunity.title,
      startupId: opportunity.startupId,
      startupName: opportunity.startupName,
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs + 2),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: colors.onSurface),
          ),
        ],
      ),
    );
  }
}