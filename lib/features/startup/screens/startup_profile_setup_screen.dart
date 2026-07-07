import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/primary_button.dart';
import '../providers/startup_providers.dart';

const _categories = [
  'Technology',
  'Agriculture',
  'Media & Content',
  'Fintech',
  'Health',
  'Education',
  'Social Impact',
  'Other',
];

class StartupProfileSetupScreen extends ConsumerStatefulWidget {
  const StartupProfileSetupScreen({super.key});

  @override
  ConsumerState<StartupProfileSetupScreen> createState() =>
      _StartupProfileSetupScreenState();
}

class _StartupProfileSetupScreenState
    extends ConsumerState<StartupProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _verificationCtrl = TextEditingController();
  String _category = _categories.first;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _verificationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(startupProfileControllerProvider.notifier).createStartupProfile(
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          category: _category,
          verificationNote: _verificationCtrl.text.trim(),
        );
    // Once created, myStartupProvider emits the new doc and the router
    // sends the admin to the dashboard automatically.
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(startupProfileControllerProvider);
    ref.listen(startupProfileControllerProvider, (prev, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not create profile. Please try again.'),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Set up your startup')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tell us about your venture',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Your profile is reviewed before you can post opportunities, '
                  'so only startups recognized at ALU appear to students.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Startup name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'What does your startup do?',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Give a short description (10+ characters)'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _verificationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'ALU club / registration reference',
                    hintText: 'e.g. ALU Innovation Hub reg. no. or club name',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'This helps us verify your startup'
                      : null,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Submit for review',
                  isLoading: state.isLoading,
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
