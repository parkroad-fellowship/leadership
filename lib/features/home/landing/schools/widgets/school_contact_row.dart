import 'package:flutter/material.dart';
import 'package:leadership/models/remote/prf_contact.dart';
import 'package:prf_design/prf_design.dart';

class SchoolContactRow extends StatelessWidget {
  const SchoolContactRow({
    required this.contact,
    required this.onTapEdit,
    super.key,
    this.onTapCall,
  });

  final PRFContact contact;
  final VoidCallback onTapEdit;
  final VoidCallback? onTapCall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = _buildSubtitle(contact);

    return InkWell(
      onTap: onTapEdit,
      borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PRFSpacingTokens.md,
          vertical: PRFSpacingTokens.md,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.32),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.14,
              ),
              child: Text(
                _getInitials(contact.name),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: PRFSpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            _ActionPill(
              label: 'Edit',
              onTap: onTapEdit,
              icon: Icons.edit_outlined,
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.11,
              ),
              foregroundColor: theme.colorScheme.primary,
              borderColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            ),
            if (contact.phone.isNotEmpty && onTapCall != null) ...[
              const SizedBox(width: PRFSpacingTokens.sm),
              _ActionPill(
                label: 'Call',
                onTap: onTapCall!,
                icon: Icons.call,
                backgroundColor: PRFColorPalette.lime100,
                foregroundColor: PRFColorPalette.lime800,
                borderColor: PRFColorPalette.lime300,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _buildSubtitle(PRFContact contact) {
    final parts = <String>[];
    if (contact.contactType != null) {
      parts.add(contact.contactType!.name);
    }
    if (contact.phone.isNotEmpty) {
      parts.add(contact.phone);
    }
    return parts.join(' \u00B7 ');
  }

  String _getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.onTap,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });

  final String label;
  final VoidCallback onTap;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PRFRadiusTokens.full),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PRFSpacingTokens.sm,
          vertical: PRFSpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(PRFRadiusTokens.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: foregroundColor),
            const SizedBox(width: PRFSpacingTokens.xs / 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
