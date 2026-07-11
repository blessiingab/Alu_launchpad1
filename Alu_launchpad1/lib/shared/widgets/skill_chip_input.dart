import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A text field + "Add" that builds up a list of short tags (skills).
/// Used for both a student's skill list and an opportunity's required
/// skills — kept generic so it doesn't know which.
class SkillChipInput extends StatefulWidget {
  const SkillChipInput({
    super.key,
    required this.values,
    required this.onChanged,
    this.hintText = 'Add a skill',
  });

  final List<String> values;
  final ValueChanged<List<String>> onChanged;
  final String hintText;

  @override
  State<SkillChipInput> createState() => _SkillChipInputState();
}

class _SkillChipInputState extends State<SkillChipInput> {
  final _controller = TextEditingController();

  void _add() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (widget.values.any((v) => v.toLowerCase() == text.toLowerCase())) {
      _controller.clear();
      return;
    }
    widget.onChanged([...widget.values, text]);
    _controller.clear();
  }

  void _remove(String value) {
    widget.onChanged(widget.values.where((v) => v != value).toList());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: widget.hintText),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _add(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _add,
              icon: const Icon(Icons.add_rounded),
              style: IconButton.styleFrom(backgroundColor: AppColors.navy),
            ),
          ],
        ),
        if (widget.values.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.values
                .map(
                  (v) => Chip(
                    label: Text(v),
                    onDeleted: () => _remove(v),
                    backgroundColor: AppColors.navy.withValues(alpha: 0.06),
                    side: BorderSide.none,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
