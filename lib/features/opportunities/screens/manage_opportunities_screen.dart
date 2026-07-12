import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/opportunity.dart';
import '../../../data/models/startup.dart';
import '../../../shared/widgets/opportunity_card.dart';
import '../../startup/providers/startup_providers.dart';
import '../providers/opportunity_providers.dart';
import 'post_opportunity_screen.dart';

class ManageOpportunitiesScreen extends ConsumerWidget {
  const ManageOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunitiesAsync = ref.watch(myOpportunitiesProvider);
    final startups = ref.watch(myStartupsProvider).value ?? const [];
    final startup = startups.isEmpty ? null : startups.first;
    final canPost = startup?.verificationStatus == VerificationStatus.verified;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Your opportunities')),
      // Gradient FAB instead of the flat default — matches the "Post an
      // opportunity" card style used elsewhere so posting always looks
      // like the same distinct, primary action across the app.
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: canPost ? AppColors.heroGradient : null,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: canPost ? AppShadows.raised(AppColors.navy) : null,
        ),
        child: FloatingActionButton.extended(
          onPressed: !canPost
              ? () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        startup == null
                            ? 'Add your startup first from the Startup tab.'
                            : 'Your startup needs to be verified before you can post.',
                      ),
                    ),
                  )
              : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PostOpportunityScreen(startup: startup),
                    ),
                  ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: Icon(Icons.add_rounded, color: canPost ? Colors.white : null),
          label: Text(
            'Post new',
            style: TextStyle(color: canPost ? Colors.white : null),
          ),
        ),
      ),
      body: opportunitiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Something went wrong: $e')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.work_outline_rounded,
                        size: 40, color: colors.onSurfaceVariant),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      "You haven't posted any opportunities yet.",
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 96,
            ),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final opportunity = items[index];
              return OpportunityCard(
                opportunity: opportunity,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PostOpportunityScreen(existing: opportunity),
                  ),
                ),
                trailing: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: colors.onSurfaceVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PostOpportunityScreen(existing: opportunity),
                        ),
                      );
                    } else if (value == 'applicants') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ApplicationScreen(opportunity: opportunity),
                        ),
                      );
                    } else if (value == 'toggle') {
                      ref
                          .read(opportunityFormControllerProvider.notifier)
                          .toggleStatus(opportunity.id, opportunity.status);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'applicants',
                      child: Text('View applicants'),
                    ),
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(
                        opportunity.status == OpportunityStatus.open
                            ? 'Close applications'
                            : 'Reopen',
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}