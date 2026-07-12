import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/application.dart';
import '../../../data/models/opportunity.dart';
import '../providers/application_provider.dart';

/// Local, screen-only filter state — doesn't need to survive navigation
/// away from this tab, unlike the Discover feed's search/type filters.
final _applicationFilterProvider = StateProvider<ApplicationStatus?>((ref) => null);

/// Two modes in one screen, chosen by whether [opportunity] is passed:
///
/// - `ApplicationScreen()` — the student's own "My applications" tab,
///   read-only, with status filter chips. Used as a bottom-nav tab in
///   StudentShellScreen.
/// - `ApplicationScreen(opportunity: someOpportunity)` — the startup
///   side: everyone who applied to that one opportunity, with
///   accept/reject actions. Pushed from ManageOpportunitiesScreen's
///   per-card "View applicants" menu item.
///
/// These used to be two separate classes (ApplicationScreen and
/// ApplicantsScreen) with near-identical names, which repeatedly caused
/// the wrong one to get imported/called by mistake. Merging them into
/// one screen with an optional parameter removes that footgun entirely.
class ApplicationScreen extends ConsumerWidget {
  const ApplicationScreen({super.key, this.opportunity});

  final Opportunity? opportunity;

  bool get _isApplicantsView => opportunity != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _isApplicantsView
        ? _ApplicantsView(opportunity: opportunity!)
        : const _MyApplicationsView();
  }
}

// ---------------------------------------------------------------------
// Student mode: "My applications"
// ---------------------------------------------------------------------

class _MyApplicationsView extends ConsumerWidget {
  const _MyApplicationsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(myApplicationsProvider);
    final filter = ref.watch(_applicationFilterProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('My applications')),
      body: applicationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Something went wrong: $e')),
        data: (allItems) {
          if (allItems.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.send_outlined, size: 40, color: colors.onSurfaceVariant),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      "You haven't applied to anything yet.",
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final items = filter == null
              ? allItems
              : allItems.where((a) => a.status == filter).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0,
                ),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'All (${allItems.length})',
                        selected: filter == null,
                        onTap: () =>
                            ref.read(_applicationFilterProvider.notifier).state = null,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      for (final status in ApplicationStatus.values) ...[
                        _FilterChip(
                          label: applicationStatusLabel(status),
                          selected: filter == status,
                          onTap: () => ref
                              .read(_applicationFilterProvider.notifier)
                              .state = status,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                    ],
                  ),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'No applications with this status.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxl,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) =>
                            _ApplicationCard(application: items[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: colors.primary,
      backgroundColor: colors.surface,
      side: BorderSide(color: colors.outline),
      labelStyle: TextStyle(
        color: selected ? colors.onPrimary : colors.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Read-only card — used in the student's own "My applications" list.
/// (The startup side's actionable version is _ApplicantCard, below.)
class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.application});

  final Application application;

  Color _statusColor() {
    switch (application.status) {
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
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(AppRadius.lg),
            bottomRight: Radius.circular(AppRadius.lg),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      application.opportunityTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Transform.rotate(
                    angle: 0.05,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        applicationStatusLabel(application.status),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                application.startupName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.goldDeep,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (application.message.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  application.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    'Applied ${_formatDate(application.createdAt)}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

// ---------------------------------------------------------------------
// Startup mode: "Applicants" for one opportunity
// ---------------------------------------------------------------------

class _ApplicantsView extends ConsumerWidget {
  const _ApplicantsView({required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicantsAsync = ref.watch(applicationsForOpportunityProvider(opportunity.id));
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Applicants'),
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

/// Actionable card — used only in the startup's "Applicants" view.
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