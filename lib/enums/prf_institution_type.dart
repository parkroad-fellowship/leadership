import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prf_design/prf_design.dart';

enum PRFInstitutionType {
  @JsonValue(1)
  highSchool(1, 'High School'),
  @JsonValue(2)
  primarySchool(2, 'Primary School'),
  @JsonValue(3)
  college(3, 'College'),
  @JsonValue(4)
  university(4, 'University'),
  @JsonValue(5)
  community(5, 'Community'),
  @JsonValue(6)
  juniorSecondarySchool(6, 'Junior Secondary School');

  const PRFInstitutionType(this.value, this._label);

  final int value;
  final String _label;

  String get name => _label;

  /// Brand fill used to tell institution types apart (avatars, headers).
  ///
  /// Fill only: put text/icons on it with [onFillColor].
  Color fillColor(BuildContext context) {
    final colors = context.prfColors;
    return switch (this) {
      primarySchool || community => colors.navyBlue,
      highSchool || juniorSecondarySchool => colors.blue,
      college || university => colors.orange,
    };
  }

  /// Two-stop gradient built from [fillColor].
  List<Color> gradientColors(BuildContext context) {
    final fill = fillColor(context);
    return [fill, fill.withValues(alpha: PRFOpacities.nearOpaque)];
  }

  /// Readable text/icon colour on [fillColor] (WCAG AA).
  Color onFillColor(BuildContext context) =>
      context.statusColors.onColorFor(fillColor(context));

  static PRFInstitutionType fromValue(int value) {
    return PRFInstitutionType.values.firstWhere(
      (v) => v.value == value,
      orElse: () => PRFInstitutionType.highSchool,
    );
  }
}
