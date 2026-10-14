import 'package:flutter/material.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/mission/prf_mission.dart';
import 'package:leadership/models/remote/mission/prf_mission_offline_member.dart';
import 'package:leadership/models/remote/mission/prf_mission_subscription.dart';
import 'package:prf_design/prf_design.dart';

class MissionResourceTabView extends StatelessWidget {
  const MissionResourceTabView({
    required this.isLoading,
    required this.error,
    required this.isEmpty,
    required this.onRefresh,
    required this.onAdd,
    required this.addButtonLabel,
    required this.addButtonIcon,
    required this.emptyLabel,
    required this.emptyDescription,
    required this.items,
    super.key,
  });

  final bool isLoading;
  final String? error;
  final bool isEmpty;
  final Future<void> Function() onRefresh;
  final VoidCallback onAdd;
  final String addButtonLabel;
  final IconData addButtonIcon;
  final String emptyLabel;
  final String emptyDescription;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (isLoading && isEmpty) {
      return const Center(child: PRFCircularProgressIndicator());
    }

    if (error != null && isEmpty) {
      return Center(
        child: PRFErrorView.inline(
          title: l10n.missionRecordsLoadErrorTitle,
          message: l10n.missionsLoadErrorMessage,
          retryLabel: l10n.tryAgain,
          onRetry: onRefresh,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          PRFSpacingTokens.lg,
          PRFSpacingTokens.lg,
          PRFSpacingTokens.lg,
          PRFSpacingTokens.xxxl,
        ),
        children: [
          MissionSectionCard(
            title: l10n.missionRecordsTitle,
            subtitle: emptyDescription,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PRFButton(
                  onPressed: onAdd,
                  title: addButtonLabel,
                  icon: addButtonIcon,
                ),
                const SizedBox(height: PRFSpacingTokens.md),
                if (error != null) const MissionSectionErrorBanner(),
                if (isEmpty)
                  PRFEmptyView(label: emptyLabel, description: emptyDescription)
                else
                  ...items,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MissionSectionCard extends StatelessWidget {
  const MissionSectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PRFSpacingTokens.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: PRFOpacities.high),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.md),
          child,
        ],
      ),
    );
  }
}

class MissionResourceCard extends StatelessWidget {
  const MissionResourceCard({
    required this.title,
    required this.subtitle,
    required this.editTooltip,
    required this.onEdit,
    required this.deleteTooltip,
    required this.onDelete,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String editTooltip;
  final VoidCallback onEdit;
  final String deleteTooltip;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: PRFSpacingTokens.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PRFSpacingTokens.md,
          vertical: PRFSpacingTokens.md,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(
              alpha: PRFOpacities.prominent,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: PRFSpacingTokens.sm),
            MissionRowAction(
              label: context.l10n.edit,
              tooltip: editTooltip,
              icon: Icons.edit_outlined,
              onPressed: onEdit,
            ),
            MissionRowAction(
              label: context.l10n.delete,
              tooltip: deleteTooltip,
              icon: Icons.delete_outline,
              onPressed: onDelete,
              destructive: true,
            ),
          ],
        ),
      ),
    );
  }
}

class MissionSubscribersTab extends StatelessWidget {
  const MissionSubscribersTab({
    required this.mission,
    required this.onRefresh,
    required this.subscriptionsSection,
    required this.offlineMembersSection,
    super.key,
  });

  final PRFMission mission;
  final Future<void> Function() onRefresh;
  final Widget subscriptionsSection;
  final Widget offlineMembersSection;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final capacity = mission.capacity;
    final registrationsOpen = mission.missionSubscriptionsNeeded;
    final filled = (capacity - registrationsOpen).clamp(0, capacity);
    final progress = capacity == 0 ? 0.0 : filled / capacity;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          PRFSpacingTokens.lg,
          PRFSpacingTokens.md,
          PRFSpacingTokens.lg,
          PRFSpacingTokens.xxxl,
        ),
        children: [
          MissionSectionCard(
            title: l10n.missionCapacityTitle,
            subtitle: l10n.missionCapacitySubtitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _PeopleMetric(
                        label: l10n.capacity,
                        value: '$capacity',
                        icon: Icons.groups_rounded,
                      ),
                    ),
                    const SizedBox(width: PRFSpacingTokens.md),
                    Expanded(
                      child: _PeopleMetric(
                        label: l10n.missionFilled,
                        value: '$filled',
                        icon: Icons.person_add_alt_rounded,
                      ),
                    ),
                    const SizedBox(width: PRFSpacingTokens.md),
                    Expanded(
                      child: _PeopleMetric(
                        label: l10n.missionOpen,
                        value: '$registrationsOpen',
                        icon: Icons.pending_actions_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PRFSpacingTokens.lg),
                PRFLinearProgressIndicator(
                  value: progress,
                  height: PRFSpacingTokens.sm,
                  borderRadius: PRFRadiusTokens.sm,
                ),
                const SizedBox(height: PRFSpacingTokens.sm),
                Text(
                  l10n.missionPercentFilled(
                    (progress * 100).toStringAsFixed(0),
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.md),
          subscriptionsSection,
          const SizedBox(height: PRFSpacingTokens.md),
          offlineMembersSection,
        ],
      ),
    );
  }
}

class MissionSubscriptionsSection extends StatelessWidget {
  const MissionSubscriptionsSection({
    required this.subscriptions,
    required this.error,
    required this.onSubscribe,
    required this.onViewSubscriber,
    required this.onUnsubscribe,
    required this.formatDate,
    super.key,
  });

  final List<PRFMissionSubscription> subscriptions;
  final String? error;
  final VoidCallback onSubscribe;
  final Future<void> Function(PRFMissionSubscription subscription)
  onViewSubscriber;
  final Future<void> Function(PRFMissionSubscription subscription)
  onUnsubscribe;
  final String Function(DateTime? value) formatDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return MissionSectionCard(
      title: l10n.missionSubscribersTitle,
      subtitle: l10n.missionSubscribersSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.missionSubscribedCount(subscriptions.length)),
          const SizedBox(height: PRFSpacingTokens.sm),
          PRFButton(
            onPressed: onSubscribe,
            title: l10n.missionSubscribeMember,
            icon: Icons.person_add_alt_rounded,
          ),
          const SizedBox(height: PRFSpacingTokens.md),
          if (error != null) const MissionSectionErrorBanner(),
          if (subscriptions.isEmpty)
            PRFEmptyView(
              label: l10n.missionNoSubscribersYet,
              description: l10n.missionNoSubscribersDesc,
            )
          else
            ...subscriptions.map(
              (subscription) => MissionSubscriptionCard(
                subscription: subscription,
                subtitle:
                    '${subscription.missionRole.name} · '
                    '${subscription.status.name} · '
                    '${l10n.missionSubscribedOn(formatDate(subscription.createdAt))}',
                onView: () => onViewSubscriber(subscription),
                onRemove: () => onUnsubscribe(subscription),
              ),
            ),
        ],
      ),
    );
  }
}

class MissionSubscriptionCard extends StatelessWidget {
  const MissionSubscriptionCard({
    required this.subscription,
    required this.subtitle,
    required this.onView,
    required this.onRemove,
    super.key,
  });

  final PRFMissionSubscription subscription;
  final String subtitle;
  final VoidCallback onView;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final name = subscription.member?.fullName ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: PRFSpacingTokens.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PRFSpacingTokens.md,
          vertical: PRFSpacingTokens.md,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(
              alpha: PRFOpacities.prominent,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                label: l10n.missionViewSubscriberDetails(name),
                excludeSemantics: true,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onView,
                    borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: PRFSizeTokens.minTouchTarget,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            l10n.viewDetails,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.missionEditRoleStatus,
              onPressed: onView,
              icon: Icon(Icons.edit_rounded, color: theme.colorScheme.primary),
            ),
            MissionRowAction(
              label: l10n.missionRemove,
              tooltip: l10n.missionRemoveSubscriber,
              icon: Icons.person_remove_alt_1,
              onPressed: onRemove,
              destructive: true,
            ),
          ],
        ),
      ),
    );
  }
}

class MissionOfflineMembersSection extends StatelessWidget {
  const MissionOfflineMembersSection({
    required this.offlineMembers,
    required this.error,
    required this.onAdd,
    required this.onRemove,
    required this.formatDate,
    super.key,
  });

  final List<PRFMissionOfflineMember> offlineMembers;
  final String? error;
  final VoidCallback onAdd;
  final Future<void> Function(PRFMissionOfflineMember member) onRemove;
  final String Function(DateTime? value) formatDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return MissionSectionCard(
      title: l10n.missionNonMembersTitle,
      subtitle: l10n.missionNonMembersSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.missionMissionersCount(offlineMembers.length)),
          const SizedBox(height: PRFSpacingTokens.sm),
          PRFButton(
            onPressed: onAdd,
            title: l10n.missionAddMissioner,
            icon: Icons.person_add_alt_outlined,
            variant: PRFButtonVariant.outlined,
          ),
          const SizedBox(height: PRFSpacingTokens.md),
          if (error != null) const MissionSectionErrorBanner(),
          if (offlineMembers.isEmpty)
            PRFEmptyView(
              label: l10n.missionNoNonMembers,
              description: l10n.missionNoNonMembersDesc,
            )
          else
            ...offlineMembers.map(
              (member) => MissionOfflineMemberCard(
                member: member,
                subtitle: l10n.missionAddedOnDate(formatDate(member.createdAt)),
                onRemove: () => onRemove(member),
              ),
            ),
        ],
      ),
    );
  }
}

class MissionOfflineMemberCard extends StatelessWidget {
  const MissionOfflineMemberCard({
    required this.member,
    required this.subtitle,
    required this.onRemove,
    super.key,
  });

  final PRFMissionOfflineMember member;
  final String subtitle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: PRFSpacingTokens.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PRFSpacingTokens.md,
          vertical: PRFSpacingTokens.md,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(
              alpha: PRFOpacities.prominent,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    member.phone,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            MissionRowAction(
              label: context.l10n.missionRemove,
              tooltip: context.l10n.missionRemoveMissioner,
              icon: Icons.person_remove_alt_1,
              onPressed: onRemove,
              destructive: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _PeopleMetric extends StatelessWidget {
  const _PeopleMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(PRFSpacingTokens.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: PRFSizeTokens.iconMd,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Plain-language banner shown when a record action fails while items are
/// still on screen.
class MissionSectionErrorBanner extends StatelessWidget {
  const MissionSectionErrorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
        padding: const EdgeInsets.all(PRFSpacingTokens.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
        ),
        child: Text(
          context.l10n.missionRecordsActionError,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onErrorContainer,
          ),
        ),
      ),
    );
  }
}

/// Compact, labelled row action (icon + word) with a 48dp touch target.
class MissionRowAction extends StatelessWidget {
  const MissionRowAction({
    required this.label,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.destructive = false,
    super.key,
  });

  final String label;
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = destructive
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(PRFRadiusTokens.sm),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: PRFSizeTokens.minTouchTarget,
                minWidth: PRFSizeTokens.minTouchTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PRFSpacingTokens.xs,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: PRFSizeTokens.iconMd, color: color),
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
