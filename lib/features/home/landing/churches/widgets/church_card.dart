import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/models/remote/prf_church.dart';
import 'package:prf_design/prf_design.dart';

class ChurchCard extends StatelessWidget {
  const ChurchCard({
    required this.church,
    required this.index,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final PRFChurch church;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PRFSpacingTokens.lg,
              vertical: PRFSpacingTokens.sm,
            ),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: PRFColors.gray100,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.church_outlined,
                    color: PRFColors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: PRFSpacingTokens.md),
                Expanded(
                  child: Text(
                    church.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: PRFColors.gray900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: PRFSpacingTokens.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PRFSpacingTokens.sm,
                    vertical: PRFSpacingTokens.xs,
                  ),
                  decoration: BoxDecoration(
                    color: church.isActive == PRFActiveStatus.active
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                  ),
                  child: Text(
                    church.isActive == PRFActiveStatus.active
                        ? 'Active'
                        : 'Inactive',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: church.isActive == PRFActiveStatus.active
                          ? Colors.green.shade700
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: PRFSpacingTokens.xs),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: theme.colorScheme.error.withValues(alpha: 0.7),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: PRFMotionTokens.enterShort,
          delay: Duration(milliseconds: 50 * index),
        )
        .slideX(begin: 0.1);
  }
}
