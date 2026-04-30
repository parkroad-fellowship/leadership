import 'package:flutter/material.dart';
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
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return school.name
        .substring(0, school.name.length.clamp(0, 2))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mode = theme.brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;

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
            // Rounded-square initials avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: school.institutionType.gradientColors,
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
            // Name + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    school.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: mode == ThemeMode.dark
                          ? PRFColors.gray100
                          : PRFColors.gray900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: PRFSpacingTokens.xs),
                  Text(
                    '${school.institutionType.name}'
                    ' · ${school.address}',
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
            // Right stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${school.totalStudents}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  '${school.contacts.length}'
                  ' contacts',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: school.institutionType.accentColor,
                    fontWeight: FontWeight.w600,
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
