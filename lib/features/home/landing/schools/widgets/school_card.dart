import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:prf_design/prf_design.dart';

class SchoolCard extends StatelessWidget {
  const SchoolCard({
    required this.school,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
    super.key,
  });

  final PRFSchool school;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
          ),
          shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.15),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(PRFSpacingTokens.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 14),
                    Divider(
                      color:
                          theme.colorScheme.outline.withValues(alpha: 0.2),
                      height: 0,
                    ),
                    const SizedBox(height: 14),
                    _buildBadges(theme),
                    const SizedBox(height: 10),
                    _buildAddress(theme),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: 500.ms,
          delay: Duration(milliseconds: index * 80),
        )
        .slideY(
          begin: 0.3,
          end: 0,
          delay: Duration(milliseconds: index * 80),
          duration: 500.ms,
        );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(PRFSpacingTokens.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.15),
                theme.colorScheme.primary.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
          ),
          child: Icon(
            Icons.school,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: PRFSpacingTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                school.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: PRFSpacingTokens.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PRFSpacingTokens.sm,
                  vertical: PRFSpacingTokens.xs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  school.institutionType.name,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Edit Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
            child: Container(
              padding: const EdgeInsets.all(PRFSpacingTokens.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                border: Border.all(
                  color:
                      theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: PRFSpacingTokens.sm),
        // Delete Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
            child: Container(
              padding: const EdgeInsets.all(PRFSpacingTokens.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.delete_outline,
                size: 18,
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadges(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '${school.totalStudents} Students',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: PRFSpacingTokens.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.contacts_outlined,
                size: 16,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                '${school.contacts.length} Contacts',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddress(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            school.address,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
