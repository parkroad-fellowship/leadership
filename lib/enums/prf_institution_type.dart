import 'dart:ui';

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
  juniorSecondarySchool(6, 'Junior Secondary School'),
  ;

  const PRFInstitutionType(this.value, this._label);

  final int value;
  final String _label;

  String get name => _label;

  List<Color> get gradientColors {
    return switch (this) {
      primarySchool || community => [
        PRFColorPalette.navy500,
        PRFColorPalette.navy400,
      ],
      highSchool || juniorSecondarySchool => [
        const Color(0xFF2563EB),
        const Color(0xFF60A5FA),
      ],
      college || university => [
        const Color(0xFFEA580C),
        const Color(0xFFFB923C),
      ],
    };
  }

  Color get accentColor {
    return switch (this) {
      primarySchool || community => PRFColors.limeGreen,
      highSchool || juniorSecondarySchool => const Color(0xFF2563EB),
      college || university => const Color(0xFFEA580C),
    };
  }

  static PRFInstitutionType fromValue(int value) {
    return PRFInstitutionType.values.firstWhere(
      (v) => v.value == value,
      orElse: () => PRFInstitutionType.highSchool,
    );
  }
}
