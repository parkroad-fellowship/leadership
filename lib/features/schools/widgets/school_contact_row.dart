import 'package:flutter/material.dart';
import 'package:leadership/l10n/l10n.dart';
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
    final l10n = context.l10n;
    final success = context.statusColors.success;
    final radius = BorderRadius.circular(PRFRadiusTokens.md);

    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(
            alpha: PRFOpacities.accent,
          ),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTapEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PRFSpacingTokens.md,
            vertical: PRFSpacingTokens.sm,
          ),
          child: Row(
            children: [
              ExcludeSemantics(
                child: CircleAvatar(
                  radius: PRFSizeTokens.iconXxl / 2,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    _getInitials(contact.name),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
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
                label: l10n.edit,
                semanticLabel: l10n.schoolContactsEditSemantics(contact.name),
                onTap: onTapEdit,
                icon: Icons.edit_outlined,
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                borderColor: theme.colorScheme.primary.withValues(
                  alpha: PRFOpacities.muted,
                ),
              ),
              if (contact.phone.isNotEmpty && onTapCall != null) ...[
                const SizedBox(width: PRFSpacingTokens.sm),
                _ActionPill(
                  label: l10n.schoolContactsCall,
                  semanticLabel: l10n.schoolContactsCallSemantics(contact.name),
                  onTap: onTapCall!,
                  icon: Icons.call,
                  backgroundColor: success.background,
                  foregroundColor: success.foreground,
                  borderColor: success.main.withValues(
                    alpha: PRFOpacities.glow,
                  ),
                ),
              ],
            ],
          ),
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
    required this.semanticLabel,
    required this.onTap,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback onTap;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: backgroundColor,
        shape: StadiumBorder(side: BorderSide(color: borderColor)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: PRFSizeTokens.minTouchTarget,
              minWidth: PRFSizeTokens.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PRFSpacingTokens.md,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: PRFSizeTokens.iconSm,
                    color: foregroundColor,
                  ),
                  const SizedBox(width: PRFSpacingTokens.xs),
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
