import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/opportunity.dart';

class OpportunityCard extends StatelessWidget {
  const OpportunityCard({
    super.key,
    required this.opportunity,
    this.onTap,
    this.trailing,
  });

  final Opportunity opportunity;
  final VoidCallback? onTap;

  /// Optional widget shown top-right (bookmark icon on the feed, or
  /// edit/close actions on the startup's own list).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final closed = opportunity.status == OpportunityStatus.closed;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opportunity.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          opportunity.startupName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.goldDeep,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Pill(
                    label: opportunityTypeLabel(opportunity.type),
                    icon: Icons.work_outline_rounded,
                  ),
                  if (opportunity.location.isNotEmpty ||
                      opportunity.workMode != WorkMode.onsite)
                    _Pill(
                      label: opportunity.workMode == WorkMode.onsite
                          ? opportunity.location
                          : workModeLabel(opportunity.workMode),
                      icon: Icons.place_outlined,
                    ),
                  if (closed)
                    const _Pill(
                      label: 'Closed',
                      icon: Icons.lock_outline_rounded,
                      color: AppColors.rejected,
                    ),
                ],
              ),
              if (opportunity.skillsRequired.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: opportunity.skillsRequired
                      .take(4)
                      .map((s) => _SkillChip(label: s))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.icon, this.color});

  final String label;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? AppColors.inkMuted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: fg),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.navy,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}