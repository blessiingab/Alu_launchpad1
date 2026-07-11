import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/opportunity.dart';
import '../../../shared/notification_icon_button.dart';
import '../../../shared/widgets/opportunity_card.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/opportunity_providers.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(filteredOpportunitiesProvider);
    final typeFilter = ref.watch(opportunityTypeFilterProvider);
    final userData = ref.watch(currentUserDataProvider).value;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: feedAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Something went wrong: $e')),
          data: (items) {
            final recommended = items.take(4).toList();

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(openOpportunitiesProvider),
              child: CustomScrollView(
                slivers: [
                  // ---- Header: greeting + bell + avatar ----
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, 0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userData == null
                                      ? 'Hello 👋'
                                      : 'Hello, ${userData.name.split(' ').first} 👋',
                                  style: textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Find meaningful ways to contribute.',
                                  style: textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          const NotificationIconButton(),
                          const SizedBox(width: AppSpacing.xs),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: colors.primary,
                            child: Text(
                              (userData?.name.isNotEmpty ?? false)
                                  ? userData!.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: colors.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ---- Search + filter ----
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (v) => ref
                                  .read(opportunitySearchProvider.notifier)
                                  .state = v,
                              decoration: const InputDecoration(
                                hintText: 'Search opportunities...',
                                prefixIcon: Icon(Icons.search_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              color: typeFilter != null
                                  ? colors.primary
                                  : colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.tune_rounded,
                                color: typeFilter != null
                                    ? colors.onPrimary
                                    : colors.onSurfaceVariant,
                              ),
                              onPressed: () => _showFilterSheet(context, ref),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ---- Recommended: gradient hero carousel ----
                  if (recommended.isNotEmpty) ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.md,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Recommended', style: textTheme.titleLarge),
                            TextButton(
                              onPressed: () => ref
                                  .read(opportunityTypeFilterProvider.notifier)
                                  .state = null,
                              child: const Text('See all'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 190,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                          itemCount: recommended.length,
                          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                          itemBuilder: (context, index) => _HeroCard(
                            opportunity: recommended[index],
                            isBookmarked: userData?.bookmarks
                                    .contains(recommended[index].id) ??
                                false,
                            onTap: () => context
                                .push('/student/opportunity/${recommended[index].id}'),
                            onBookmark: userData == null
                                ? null
                                : () => ref
                                    .read(bookmarkControllerProvider.notifier)
                                    .toggle(recommended[index].id),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // ---- Browse by type ----
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.md,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Text('Browse by type', style: textTheme.titleLarge),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          for (final type in OpportunityType.values) ...[
                            Expanded(
                              child: _CategoryIcon(
                                icon: _iconForType(type),
                                label: opportunityTypeLabel(type),
                                selected: typeFilter == type,
                                onTap: () => ref
                                    .read(opportunityTypeFilterProvider.notifier)
                                    .state = typeFilter == type ? null : type,
                              ),
                            ),
                            if (type != OpportunityType.values.last)
                              const SizedBox(width: AppSpacing.sm),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // ---- Recent opportunities ----
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.md,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Text('Recent opportunities', style: textTheme.titleLarge),
                    ),
                  ),
                  if (items.isEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.all(AppSpacing.xxxl),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 40, color: colors.onSurfaceVariant),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'No opportunities match right now.',
                                style: textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxl,
                      ),
                      sliver: SliverList.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final opportunity = items[index];
                          final isBookmarked =
                              userData?.bookmarks.contains(opportunity.id) ?? false;
                          return OpportunityCard(
                            opportunity: opportunity,
                            onTap: () =>
                                context.push('/student/opportunity/${opportunity.id}'),
                            trailing: IconButton(
                              icon: Icon(
                                isBookmarked
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                color: isBookmarked
                                    ? AppColors.gold
                                    : colors.onSurfaceVariant,
                              ),
                              onPressed: userData == null
                                  ? null
                                  : () => ref
                                      .read(bookmarkControllerProvider.notifier)
                                      .toggle(opportunity.id),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static IconData _iconForType(OpportunityType type) {
    switch (type) {
      case OpportunityType.internship:
        return Icons.school_outlined;
      case OpportunityType.job:
        return Icons.work_outline_rounded;
      case OpportunityType.volunteer:
        return Icons.volunteer_activism_outlined;
      case OpportunityType.project:
        return Icons.lightbulb_outline_rounded;
    }
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        final current = ref.watch(opportunityTypeFilterProvider);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filter by type', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: current == null,
                      onSelected: (_) {
                        ref.read(opportunityTypeFilterProvider.notifier).state = null;
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                    for (final type in OpportunityType.values)
                      ChoiceChip(
                        label: Text(opportunityTypeLabel(type)),
                        selected: current == type,
                        onSelected: (_) {
                          ref.read(opportunityTypeFilterProvider.notifier).state = type;
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Gradient "Recommended" card — the signature visual moment of the
/// Discover screen.
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.opportunity,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmark,
  });

  final Opportunity opportunity;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback? onBookmark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 18),
                ),
                const Spacer(),
                InkWell(
                  onTap: onBookmark,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: Icon(
                    isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              opportunity.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              opportunity.startupName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _HeroTag(opportunityTypeLabel(opportunity.type)),
                if (opportunity.isRemote) const _HeroTag('Remote'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: selected ? colors.primary : colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              color: selected ? colors.onPrimary : colors.onSurfaceVariant,
              size: 22,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}