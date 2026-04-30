import 'package:flutter/material.dart';
import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/models/remote/prf_school_term.dart';
import 'package:prf_design/prf_design.dart';

class SchoolTermCard extends StatelessWidget {
  const SchoolTermCard({
    required this.term,
    required this.index,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final PRFSchoolTerm term;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  String get _initials {
    final words = term.name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return term.name.substring(0, term.name.length.clamp(0, 2)).toUpperCase();
  }

  bool get _isActive => term.isActive == PRFActiveStatus.active;

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
            // Rounded-square icon avatar
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
              child: Text(
                _initials,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: PRFColors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(
              width: PRFSpacingTokens.md,
            ),
            // Name + year subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    term.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: PRFColors.gray900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: PRFSpacingTokens.xs),
                  Text(
                    '${term.year}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: PRFColors.gray500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: PRFSpacingTokens.md,
            ),
            // Active/Inactive badge and delete
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PRFSpacingTokens.sm,
                    vertical: PRFSpacingTokens.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _isActive
                        ? PRFColors.successLight
                        : PRFColors.gray100,
                    borderRadius: BorderRadius.circular(PRFRadiusTokens.full),
                  ),
                  child: Text(
                    _isActive ? 'Active' : 'Inactive',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _isActive
                          ? PRFColors.successDark
                          : PRFColors.gray500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: PRFSpacingTokens.xs),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: theme.colorScheme.error.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
