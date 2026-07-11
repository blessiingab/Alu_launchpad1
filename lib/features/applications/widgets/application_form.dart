import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/application_provider.dart';

const _minMessageLength = 10;
const _maxMessageLength = 600;

/// Form for applying to an opportunity. Present with [showApplicationForm]
/// rather than pushing it directly — it's designed to render inside a
/// modal bottom sheet.
class ApplicationForm extends ConsumerStatefulWidget {
  const ApplicationForm({
    super.key,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.startupName,
  });

  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;

  @override
  ConsumerState<ApplicationForm> createState() => _ApplicationFormState();
}

class _ApplicationFormState extends ConsumerState<ApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _messageCtrl = TextEditingController();
  int _messageLength = 0;

  @override
  void initState() {
    super.initState();
    _messageCtrl.addListener(() {
      setState(() => _messageLength = _messageCtrl.text.trim().length);
    });
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref.read(applicationFormControllerProvider.notifier).submit(
          opportunityId: widget.opportunityId,
          opportunityTitle: widget.opportunityTitle,
          startupId: widget.startupId,
          startupName: widget.startupName,
          message: _messageCtrl.text.trim(),
        );

    final state = ref.read(applicationFormControllerProvider);
    if (!mounted) return;
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${state.error}')),
      );
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Application sent!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(applicationFormControllerProvider);
    final userData = ref.watch(currentUserDataProvider).value;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isSubmitting = formState.isLoading;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: AppMotion.fast,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Drag handle ----
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.outline,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),

                // ---- Header ----
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(Icons.send_rounded, color: colors.primary, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Apply', style: textTheme.titleLarge),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.opportunityTitle} · ${widget.startupName}',
                            style: textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Cancel',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // ---- Applicant summary ----
                if (userData != null)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: colors.primary,
                          child: Text(
                            userData.name.isNotEmpty
                                ? userData.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userData.name, style: textTheme.labelLarge),
                              Text(userData.email, style: textTheme.labelMedium),
                            ],
                          ),
                        ),
                        Icon(Icons.verified_rounded,
                            size: 16, color: colors.onSurfaceVariant),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),

                // ---- Message field ----
                Text('Why are you a good fit?', style: textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _messageCtrl,
                  maxLines: 6,
                  maxLength: _maxMessageLength,
                  enabled: !isSubmitting,
                  buildCounter: (context,
                          {required currentLength, required isFocused, maxLength}) =>
                      null,
                  decoration: const InputDecoration(
                    hintText: 'Share relevant experience, projects, or availability.',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => (v == null || v.trim().length < _minMessageLength)
                      ? 'Add a bit more detail ($_minMessageLength+ characters)'
                      : null,
                ),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$_messageLength / $_maxMessageLength',
                    style: textTheme.labelSmall,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ---- Reassurance note ----
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: colors.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.xs + 2),
                    Expanded(
                      child: Text(
                        'This goes straight to ${widget.startupName} along with '
                        'your profile and skills. Track its status under '
                        '"My applications".',
                        style: textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                PrimaryButton(
                  label: 'Send application',
                  isLoading: isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens [ApplicationForm] in a modal bottom sheet.
Future<void> showApplicationForm(
  BuildContext context, {
  required String opportunityId,
  required String opportunityTitle,
  required String startupId,
  required String startupName,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => ApplicationForm(
      opportunityId: opportunityId,
      opportunityTitle: opportunityTitle,
      startupId: startupId,
      startupName: startupName,
    ),
  );
}