import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);

    if (isLoading && isEmpty) {
      return const Center(child: PRFCircularProgressIndicator());
    }

    if (error != null && isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: PRFSpacingTokens.lg),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PRFSpacingTokens.xl,
              ),
              child: Text(
                error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            const SizedBox(height: PRFSpacingTokens.lg),
            FilledButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
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
            title: 'Mission Records',
            subtitle: emptyDescription,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: Icon(addButtonIcon),
                  label: Text(addButtonLabel),
                ),
                const SizedBox(height: PRFSpacingTokens.md),
                if (error != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
                    padding: const EdgeInsets.all(PRFSpacingTokens.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
                    ),
                    child: Text(
                      error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
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
          color: theme.colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
              letterSpacing: 0.6,
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
            color: theme.colorScheme.outline.withValues(alpha: 0.38),
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
            Tooltip(
              message: editTooltip,
              child: GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PRFSpacingTokens.sm,
                    vertical: PRFSpacingTokens.xs,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(PRFRadiusTokens.full),
                  ),
                  child: Text(
                    'Edit',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: PRFSpacingTokens.xs),
            Tooltip(
              message: deleteTooltip,
              child: IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
              ),
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
    final theme = Theme.of(context);
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
            title: 'Subscriber Capacity',
            subtitle:
                'Track mission signup progress '
                'and remaining slots.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _PeopleMetric(
                        label: 'Capacity',
                        value: '$capacity',
                        icon: Icons.groups_rounded,
                      ),
                    ),
                    const SizedBox(
                      width: PRFSpacingTokens.md,
                    ),
                    Expanded(
                      child: _PeopleMetric(
                        label: 'Filled',
                        value: '$filled',
                        icon: Icons.person_add_alt_rounded,
                      ),
                    ),
                    const SizedBox(
                      width: PRFSpacingTokens.md,
                    ),
                    Expanded(
                      child: _PeopleMetric(
                        label: 'Open',
                        value: '$registrationsOpen',
                        icon: Icons.pending_actions_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PRFSpacingTokens.lg),
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    PRFRadiusTokens.sm,
                  ),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: progress,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: PRFSpacingTokens.sm),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}'
                  '% filled',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);

    return MissionSectionCard(
      title: 'Mission Subscribers',
      subtitle: 'Manage fellowship members subscribed to this mission.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('${subscriptions.length} subscribed')),
              FilledButton.icon(
                onPressed: onSubscribe,
                icon: const Icon(Icons.person_add_alt_rounded),
                label: const Text('Subscribe Member'),
              ),
            ],
          ),
          const SizedBox(height: PRFSpacingTokens.md),
          if (error != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
              padding: const EdgeInsets.all(PRFSpacingTokens.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
              ),
              child: Text(
                error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          if (subscriptions.isEmpty)
            const PRFEmptyView(
              label: 'No subscribers yet',
              description:
                  'Subscribe fellowship members to this mission from this tab.',
            )
          else
            ...subscriptions.map(
              (subscription) => MissionSubscriptionCard(
                subscription: subscription,
                subtitle:
                    '${subscription.missionRole.name} · '
                    '${subscription.status.name} · '
                    'Subscribed on ${formatDate(subscription.createdAt)}',
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
            color: theme.colorScheme.outline.withValues(alpha: 0.38),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.member!.fullName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.centerLeft,
                      foregroundColor: theme.colorScheme.primary,
                    ),
                    onPressed: onView,
                    child: const Text('View details'),
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
            IconButton(
              tooltip: 'Edit role & status',
              onPressed: onView,
              icon: Icon(
                Icons.edit_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
            IconButton(
              tooltip: 'Remove subscriber',
              onPressed: onRemove,
              icon: Icon(
                Icons.person_remove_alt_1,
                color: theme.colorScheme.error,
              ),
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
    final theme = Theme.of(context);

    return MissionSectionCard(
      title: 'Non-Member Missioners',
      subtitle:
          'People who joined the mission but '
          "aren't registered members.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${offlineMembers.length} missioner'
                  '${offlineMembers.length == 1 ? '' : 's'}',
                ),
              ),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(
                  Icons.person_add_alt_outlined,
                ),
                label: const Text('Add Missioner'),
              ),
            ],
          ),
          const SizedBox(height: PRFSpacingTokens.md),
          if (error != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(
                bottom: PRFSpacingTokens.md,
              ),
              padding: const EdgeInsets.all(
                PRFSpacingTokens.sm,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(
                  PRFRadiusTokens.md,
                ),
              ),
              child: Text(
                error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          if (offlineMembers.isEmpty)
            const PRFEmptyView(
              label: 'No non-member missioners',
              description:
                  'Add people who joined the mission '
                  "but aren't registered members.",
            )
          else
            ...offlineMembers.map(
              (member) => MissionOfflineMemberCard(
                member: member,
                subtitle:
                    'Added ${formatDate(
                      member.createdAt,
                    )}',
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
      padding: const EdgeInsets.only(
        bottom: PRFSpacingTokens.sm,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PRFSpacingTokens.md,
          vertical: PRFSpacingTokens.md,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(
            PRFRadiusTokens.md,
          ),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(
              alpha: 0.38,
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
            IconButton(
              tooltip: 'Remove missioner',
              onPressed: onRemove,
              icon: Icon(
                Icons.person_remove_alt_1,
                color: theme.colorScheme.error,
              ),
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
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
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
