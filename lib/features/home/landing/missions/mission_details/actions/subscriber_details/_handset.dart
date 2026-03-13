import 'package:flutter/material.dart';
import 'package:leadership/features/home/landing/missions/mission_details/actions/_shared/mission_sheet_section.dart';
import 'package:leadership/models/remote/mission/prf_mission_subscription.dart';
import 'package:prf_design/prf_design.dart';

class MissionSubscriberDetailsSheet extends StatelessWidget {
  const MissionSubscriberDetailsSheet({
    required this.subscription,
    super.key,
  });

  final PRFMissionSubscription subscription;

  @override
  Widget build(BuildContext context) {
    final member = subscription.member;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PRFSpacingTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: PRFSpacingTokens.lg),
            MissionSheetSection(
              title: 'Subscriber',
              subtitle:
                  'Fellowship member profile for this mission subscription',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow('Name', member!.fullName),
                  _detailRow('Member ULID', member.ulid),
                  ...[
                    _detailRow('Email', member.email),
                    _detailRow('Phone', member.phoneNumber),
                    _detailRow('Residence', member.residence),
                    _detailRow('Pastor', member.pastor),
                  ],
                ],
              ),
            ),
            const SizedBox(height: PRFSpacingTokens.xxl),
            SizedBox(
              width: double.infinity,
              child: PRFPrimaryButton(
                onPressed: () => Navigator.of(context).pop(),
                title: 'Done',
                disabled: false,
              ),
            ),
            const SizedBox(height: PRFSpacingTokens.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
    final safeValue = (value ?? '').trim();
    if (safeValue.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: PRFSpacingTokens.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(safeValue),
        ],
      ),
    );
  }
}
