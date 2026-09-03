import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

    return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PRFSpacingTokens.lg,
              vertical: PRFSpacingTokens.sm,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                // Circle avatar with profile picture or initials
                CircleAvatar(
                  radius: 23,
                  backgroundColor: colorScheme.primary.withValues(
                    alpha: 0.15,
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
                const SizedBox(
                  width: PRFSpacingTokens.md,
                ),
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
                      if (_subtitle != null) ...[
                        const SizedBox(height: PRFSpacingTokens.xs),
                        Text(
                          _subtitle!,
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
                  const SizedBox(
                    width: PRFSpacingTokens.md,
                  ),
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
        )
        .animate()
        .fadeIn(
          duration: PRFMotionTokens.enterShort,
          delay: Duration(milliseconds: 30 * index),
        )
        .slideX(begin: 0.05);
  }
}
