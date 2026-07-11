import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/startup.dart';
import '../providers/startup_providers.dart';

/// Lets a startup_admin add their startup profile, or edit an existing
/// one — pass [existing] to pre-fill the form and switch into edit mode.
/// A new profile always lands at VerificationStatus.pending; editing
/// never touches verification status (see StartupProfileController).
class CreateStartupScreen extends ConsumerStatefulWidget {
  const CreateStartupScreen({super.key, this.existing});

  final Startup? existing;

  @override
  ConsumerState<CreateStartupScreen> createState() => _CreateStartupScreenState();
}

class _CreateStartupScreenState extends ConsumerState<CreateStartupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _verificationNoteController;

  static const _categories = [
    'Tech',
    'Agri',
    'Media',
    'Finance',
    'Health',
    'Education',
    'Retail',
    'General',
  ];
  late String _category;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _descriptionController = TextEditingController(text: existing?.description ?? '');
    _verificationNoteController =
        TextEditingController(text: existing?.verificationNote ?? '');
    _category = existing != null && _categories.contains(existing.category)
        ? existing.category
        : _categories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _verificationNoteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(startupProfileControllerProvider.notifier);
    if (_isEditing) {
      await controller.editStartupProfile(
        startupId: widget.existing!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
      );
    } else {
      await controller.createStartupProfile(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        verificationNote: _verificationNoteController.text.trim(),
      );
    }

    if (!mounted) return;

    final state = ref.read(startupProfileControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: ${state.error}')),
      );
      return;
    }

    // When this screen was pushed on top of the hub/dashboard (editing,
    // or a re-entrant create), pop back to it. When it was reached
    // directly (a brand-new admin landed here via the router's redirect,
    // with nothing beneath it on the stack), there's nothing to pop — the
    // router watches myStartupsProvider and will automatically redirect to
    // /startup/dashboard now that the startup exists.
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(startupProfileControllerProvider);
    final isSubmitting = controllerState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit your startup' : 'Add your startup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tell us about your venture',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _isEditing
                    ? 'Editing name, category, and description does not '
                        'affect your verification status.'
                    : 'Your profile starts as pending and is reviewed by the '
                        'platform team before you can post opportunities.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.goldDeep,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Startup name',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Please enter a name'
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final category in _categories)
                    DropdownMenuItem(value: category, child: Text(category)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                minLines: 3,
                maxLines: 6,
                textInputAction: TextInputAction.next,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Please add a short description'
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _verificationNoteController,
                enabled: !_isEditing,
                decoration: InputDecoration(
                  labelText: 'Verification note',
                  hintText: 'e.g. ALU club registration reference',
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                  helperText: _isEditing
                      ? "Can't be changed after submission — contact the "
                          'platform team if this needs correcting.'
                      : null,
                ),
                minLines: 2,
                maxLines: 4,
                textInputAction: TextInputAction.done,
                validator: (value) => (!_isEditing && (value == null || value.trim().isEmpty))
                    ? 'Please add a reference to help us verify you'
                    : null,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              FilledButton(
                onPressed: isSubmitting ? null : _submit,
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Save changes' : 'Create startup profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}