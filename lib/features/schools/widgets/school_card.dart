import 'package:flutter/material.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:prf_design/prf_design.dart';

class SchoolCard extends StatelessWidget {
  const SchoolCard({
    required this.school,
    required this.index,
    required this.onTap,
    super.key,
  });

  final PRFSchool school;
  final int index;
  final VoidCallback onTap;

  String get _initials {
    final words = school.name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2 && words[0].isNotEmpty && words[1].isNotEmpty) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return school.name
        .substring(0, school.name.length.clamp(0, 2))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final type = school.institutionType;
    final students = l10n.schoolsStudentCount(school.totalStudents);
    final contacts = l10n.schoolsContactCount(school.contacts.length);

    return Semantics(
      button: true,
      label: l10n.schoolsCardSemantics(
        school.name,
        type.name,
        students,
        contacts,
      ),
      excludeSemantics: true,
      child: Material(
        color: theme.colorScheme.surface,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: PRFSizeTokens.minTouchTarget,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: PRFSpacingTokens.lg,
              vertical: PRFSpacingTokens.sm,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                // Rounded-square initials avatar
                Container(
                  width: PRFSizeTokens.iconXxxl,
                  height: PRFSizeTokens.iconXxxl,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: type.gradientColors(context),
                    ),
                    borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: type.onFillColor(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: PRFSpacingTokens.md),
                // Name + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        school.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: PRFSpacingTokens.xs),
                      Text(
                        '${type.name} · ${school.address}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: PRFSpacingTokens.md),
                // Right stats
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      students,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      contacts,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
