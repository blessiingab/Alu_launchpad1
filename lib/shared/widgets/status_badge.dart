import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/startup.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final VerificationStatus status;

  (Color, Color, String, IconData) get _visuals {
    switch (status) {
      case VerificationStatus.verified:
        return (
          AppColors.verified.withValues(alpha: 0.12),
          AppColors.verified,
          'Verified startup',
          Icons.verified_rounded,
        );
      case VerificationStatus.rejected:
        return (
          AppColors.rejected.withValues(alpha: 0.12),
          AppColors.rejected,
          'Verification rejected',
          Icons.error_outline_rounded,
        );
      case VerificationStatus.pending:
        return (
          AppColors.pending.withValues(alpha: 0.12),
          AppColors.pending,
          'Verification pending',
          Icons.hourglass_top_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label, icon) = _visuals;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}