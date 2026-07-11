import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/startup.dart';

/// Shows a bottom sheet asking which verified startup to post an
/// opportunity under. If there's only one, returns it immediately
/// without showing anything — the picker is only needed when there's
/// a real choice to make.
Future<Startup?> pickVerifiedStartup(
  BuildContext context,
  List<Startup> verifiedStartups,
) async {
  if (verifiedStartups.length == 1) return verifiedStartups.first;
  if (verifiedStartups.isEmpty) return null;

  return showModalBottomSheet<Startup>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm,
            ),
            child: Text(
              'Post under which startup?',
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
          ),
          for (final startup in verifiedStartups)
            ListTile(
              leading: const Icon(Icons.storefront_rounded),
              title: Text(startup.name),
              subtitle: Text(startup.category),
              onTap: () => Navigator.of(sheetContext).pop(startup),
            ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    ),
  );
}