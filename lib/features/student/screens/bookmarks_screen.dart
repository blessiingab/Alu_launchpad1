import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/opportunity_card.dart';
import '../../opportunities/providers/opportunity_providers.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(bookmarkedOpportunitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: savedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Something went wrong: $e')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bookmark_border_rounded,
                        size: 40, color: AppColors.inkMuted),
                    const SizedBox(height: 12),
                    Text(
                      'Bookmark opportunities to find them here later.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final opportunity = items[index];
              return OpportunityCard(
                opportunity: opportunity,
                onTap: () => context.push('/student/opportunity/${opportunity.id}'),
                trailing: IconButton(
                  icon: const Icon(Icons.bookmark_rounded, color: AppColors.gold),
                  onPressed: () => ref
                      .read(bookmarkControllerProvider.notifier)
                      .toggle(opportunity.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
