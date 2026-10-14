import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:prf_design/prf_design.dart';

class MemberCard extends StatelessWidget {
  const MemberCard({
    required this.member,
    required this.index,
    required this.onTap,
    super.key,
  });

  final PRFMember member;
  final int index;
  final VoidCallback onTap;

  String get _initials {
    final first = member.firstName.trim();
    final last = member.lastName.trim();
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    return member.fullName
        .substring(0, member.fullName.length.clamp(0, 2))
        .toUpperCase();
  }

  String? get _subtitle {
    if (member.phoneNumber != null && member.phoneNumber!.isNotEmpty) {
      return member.phoneNumber;
    }
    return member.email;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profileUrl = member.profilePicture?.temporaryURL;
    final subtitle = _subtitle;

    final Widget row = Semantics(
      button: true,
      label: context.l10n.membersCardSemantics(member.fullName),
      child: Material(
        color: colorScheme.surface,
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
                bottom: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                // Circle avatar with profile picture or initials
                ExcludeSemantics(
                  child: CircleAvatar(
                    radius: PRFSizeTokens.iconXxxl / 2,
                    backgroundColor: colorScheme.primary.withValues(
                      alpha: PRFOpacities.subtle,
                    ),
                    backgroundImage: profileUrl != null
                        ? NetworkImage(profileUrl)
                        : null,
                    child: profileUrl == null
                        ? Text(
                            _initials,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: PRFSpacingTokens.md),
                // Name + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: PRFSpacingTokens.xs),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Trailing: profession name if available
                if (member.profession != null) ...[
                  const SizedBox(width: PRFSpacingTokens.md),
                  Flexible(
                    flex: 0,
                    child: Text(
                      member.profession!.name,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    final duration = PRFMotionTokens.resolve(
      context,
      PRFMotionTokens.enterShort,
    );
    if (duration == Duration.zero) return row;

    // Cap the stagger so long lists don't make people wait.
    final delay = PRFMotionTokens.stagger1 * math.min(index, 8);
    return row
        .animate()
        .fadeIn(duration: duration, delay: delay)
        .slideX(begin: 0.05, duration: duration, delay: delay);
  }
}
