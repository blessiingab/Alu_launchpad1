import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/application.dart';
import '../../../shared/widgets/notched_shape.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/skill_chip_input.dart';
import '../../applications/providers/application_provider.dart';
import '../../auth/providers/auth_providers.dart';
import '../../opportunities/providers/opportunity_providers.dart';

class StudentProfileScreen extends ConsumerStatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  ConsumerState<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  final _nameController = TextEditingController();
  List<String> _skills = [];
  bool _initialized = false;
  bool _dirty = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userDataAsync = ref.watch(currentUserDataProvider);
    final formState = ref.watch(authControllerProvider);
    final applicationsCount = ref.watch(myApplicationsProvider).value?.length ?? 0;
    final bookmarksCount = ref.watch(bookmarkedOpportunitiesProvider).value?.length ?? 0;
    final acceptedCount = ref.watch(myApplicationsProvider).value
            ?.where((a) => a.status == ApplicationStatus.accepted)
            .length ??
        0;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign out',
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
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
          if (!_initialized) {
            _nameController.text = userData.name;
            _skills = List<String>.from(userData.skills);
            _initialized = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Avatar + name/location header ----
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: colors.primary,
                        child: Text(
                          userData.name.isNotEmpty
                              ? userData.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        userData.name.isEmpty ? 'Your name' : userData.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(userData.email, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // ---- Stats row ----
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _StatTile(
                        value: applicationsCount,
                        label: 'Applications',
                        corner: NotchCorner.topRight,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _StatTile(
                          value: bookmarksCount,
                          label: 'Bookmarks',
                          corner: NotchCorner.bottomLeft,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _StatTile(
                        value: acceptedCount,
                        label: 'Accepted',
                        corner: NotchCorner.topRight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxxl),

                Text('Name', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _nameController,
                  onChanged: (_) => setState(() => _dirty = true),
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
                const SizedBox(height: AppSpacing.xl),
                Text('Skills & interests', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'These help startups see what you bring to the table.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                SkillChipInput(
                  values: _skills,
                  hintText: 'e.g. Flutter, UI design, marketing',
                  onChanged: (v) => setState(() {
                    _skills = v;
                    _dirty = true;
                  }),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                PrimaryButton(
                  label: 'Save changes',
                  isLoading: formState.isLoading,
                  onPressed: !_dirty
                      ? null
                      : () async {
                          await ref.read(authControllerProvider.notifier).updateProfile(
                                name: _nameController.text.trim(),
                                skills: _skills,
                              );
                          if (context.mounted) {
                            setState(() => _dirty = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile updated')),
                            );
                          }
                        },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label, required this.corner});

  final int value;
  final String label;
  final NotchCorner corner;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ClipPath(
      clipper: NotchedCornerClipper(notch: 14, radius: AppRadius.md, corner: corner),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        color: colors.surfaceContainerHighest,
        child: Column(
          children: [
            Text(
              '$value',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}