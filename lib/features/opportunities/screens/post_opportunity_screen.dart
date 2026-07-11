import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/opportunity.dart';
import '../../../data/models/startup.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/skill_chip_input.dart';
import '../providers/opportunity_providers.dart';

/// Quick deadline presets — picking one computes the date automatically
/// instead of requiring a manual trip through the date picker every time.
enum _DeadlinePreset { oneWeek, twoWeeks, oneMonth, custom }

/// Handles both "post a new opportunity" and "edit an existing one" —
/// pass [existing] to pre-fill the form and switch the save action to
/// an update instead of a create.
///
/// [startup] is which startup a *new* opportunity is posted under — an
/// admin can own more than one, so the caller (StartupHubScreen) is
/// responsible for having them pick one before pushing this screen.
/// Not needed when [existing] is set, since an edit keeps its original
/// startupId untouched.
class PostOpportunityScreen extends ConsumerStatefulWidget {
  const PostOpportunityScreen({super.key, this.existing, this.startup})
      : assert(
          existing != null || startup != null,
          'Pass startup when creating a new opportunity.',
        );

  final Opportunity? existing;
  final Startup? startup;

  @override
  ConsumerState<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends ConsumerState<PostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late OpportunityType _type;
  late WorkMode _workMode;
  late List<String> _skills;
  DateTime? _deadline;
  _DeadlinePreset? _deadlinePreset;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _descriptionController = TextEditingController(text: existing?.description ?? '');
    _locationController = TextEditingController(text: existing?.location ?? '');
    _type = existing?.type ?? OpportunityType.internship;
    _workMode = existing?.workMode ?? WorkMode.onsite;
    _skills = existing != null ? List<String>.from(existing.skillsRequired) : [];
    _deadline = existing?.deadline;
    // Pre-existing deadlines were picked manually elsewhere (or before
    // this feature existed) — treat them as custom rather than guessing
    // which preset they might have matched.
    _deadlinePreset = _deadline != null ? _DeadlinePreset.custom : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _applyPreset(_DeadlinePreset preset) async {
    switch (preset) {
      case _DeadlinePreset.oneWeek:
        setState(() {
          _deadlinePreset = preset;
          _deadline = DateTime.now().add(const Duration(days: 7));
        });
      case _DeadlinePreset.twoWeeks:
        setState(() {
          _deadlinePreset = preset;
          _deadline = DateTime.now().add(const Duration(days: 14));
        });
      case _DeadlinePreset.oneMonth:
        setState(() {
          _deadlinePreset = preset;
          _deadline = DateTime.now().add(const Duration(days: 30));
        });
      case _DeadlinePreset.custom:
        final picked = await showDatePicker(
          context: context,
          initialDate: _deadline ?? DateTime.now().add(const Duration(days: 14)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          setState(() {
            _deadlinePreset = preset;
            _deadline = picked;
          });
        }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(opportunityFormControllerProvider.notifier);
    if (_isEditing) {
      await controller.editOpportunity(
        id: widget.existing!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _type,
        skillsRequired: _skills,
        location: _locationController.text.trim(),
        workMode: _workMode,
        deadline: _deadline,
      );
    } else {
      await controller.post(
        startupId: widget.startup!.id,
        startupName: widget.startup!.name,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _type,
        skillsRequired: _skills,
        location: _locationController.text.trim(),
        workMode: _workMode,
        deadline: _deadline,
      );
    }

    final state = ref.read(opportunityFormControllerProvider);
    if (!mounted) return;
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: ${state.error}')),
      );
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(opportunityFormControllerProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit opportunity' : 'Post an opportunity'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'e.g. Frontend Intern'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Give it a title' : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Type', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: OpportunityType.values.map((type) {
                  final selected = _type == type;
                  return ChoiceChip(
                    label: Text(opportunityTypeLabel(type)),
                    selected: selected,
                    onSelected: (_) => setState(() => _type = type),
                    showCheckmark: false,
                    selectedColor: colors.primary,
                    labelStyle: TextStyle(
                      color: selected ? colors.onPrimary : colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Description', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'What will they work on? What does success look like?',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Add a description' : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Work mode', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'How will the student be working with you?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: WorkMode.values.map((mode) {
                  final selected = _workMode == mode;
                  return ChoiceChip(
                    label: Text(workModeLabel(mode)),
                    selected: selected,
                    onSelected: (_) => setState(() => _workMode = mode),
                    showCheckmark: false,
                    selectedColor: colors.primary,
                    labelStyle: TextStyle(
                      color: selected ? colors.onPrimary : colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Location', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                _workMode == WorkMode.remote
                    ? "Optional — most students won't need this for a fully remote role."
                    : 'Where will the in-person part happen?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(hintText: 'e.g. Kigali, Rwanda'),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Skills wanted', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              SkillChipInput(
                values: _skills,
                hintText: 'e.g. Figma, React, Copywriting',
                onChanged: (v) => setState(() => _skills = v),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Application deadline (optional)',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Pick a quick option, or set an exact date.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  ChoiceChip(
                    label: const Text('1 week'),
                    selected: _deadlinePreset == _DeadlinePreset.oneWeek,
                    onSelected: (_) => _applyPreset(_DeadlinePreset.oneWeek),
                    showCheckmark: false,
                  ),
                  ChoiceChip(
                    label: const Text('2 weeks'),
                    selected: _deadlinePreset == _DeadlinePreset.twoWeeks,
                    onSelected: (_) => _applyPreset(_DeadlinePreset.twoWeeks),
                    showCheckmark: false,
                  ),
                  ChoiceChip(
                    label: const Text('1 month'),
                    selected: _deadlinePreset == _DeadlinePreset.oneMonth,
                    onSelected: (_) => _applyPreset(_DeadlinePreset.oneMonth),
                    showCheckmark: false,
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.event_outlined, size: 16),
                    label: Text(
                      _deadlinePreset == _DeadlinePreset.custom && _deadline != null
                          ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                          : 'Custom date',
                    ),
                    onPressed: () => _applyPreset(_DeadlinePreset.custom),
                  ),
                  if (_deadline != null)
                    ActionChip(
                      avatar: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Clear'),
                      onPressed: () => setState(() {
                        _deadline = null;
                        _deadlinePreset = null;
                      }),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxxl),
              PrimaryButton(
                label: _isEditing ? 'Save changes' : 'Post opportunity',
                isLoading: formState.isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}