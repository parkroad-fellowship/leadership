import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prf_design/prf_design.dart';

enum PRFInstitutionType {
  @JsonValue(1)
  highSchool,
  @JsonValue(2)
  primarySchool,
  @JsonValue(3)
  college,
  @JsonValue(4)
  university,
  @JsonValue(5)
  community,
  @JsonValue(6)
  juniorSecondarySchool
  ;


  String get name {
    switch (this) {
      case PRFInstitutionType.highSchool:
        return 'High School';
      case PRFInstitutionType.primarySchool:
        return 'Primary School';
      case PRFInstitutionType.college:
        return 'College';
      case PRFInstitutionType.university:
        return 'University';
      case PRFInstitutionType.community:
        return 'Community';
      case PRFInstitutionType.juniorSecondarySchool:
        return 'Junior Secondary School';
    }
  }

  int get value {
    switch (this) {
      case PRFInstitutionType.highSchool:
        return 1;
      case PRFInstitutionType.primarySchool:
        return 2;
      case PRFInstitutionType.college:
        return 3;
      case PRFInstitutionType.university:
        return 4;
      case PRFInstitutionType.community:
        return 5;
      case PRFInstitutionType.juniorSecondarySchool:
        return 6;
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case PRFInstitutionType.primarySchool:
      case PRFInstitutionType.community:
        return [
          PRFColorPalette.navy500,
          PRFColorPalette.navy400,
        ];
      case PRFInstitutionType.highSchool:
      case PRFInstitutionType.juniorSecondarySchool:
        return [
          const Color(0xFF2563EB),
          const Color(0xFF60A5FA),
        ];
      case PRFInstitutionType.college:
      case PRFInstitutionType.university:
        return [
          const Color(0xFFEA580C),
          const Color(0xFFFB923C),
        ];
    }
  }

  Color get accentColor {
    switch (this) {
      case PRFInstitutionType.primarySchool:
      case PRFInstitutionType.community:
        return PRFColors.limeGreen;
      case PRFInstitutionType.highSchool:
      case PRFInstitutionType.juniorSecondarySchool:
        return const Color(0xFF2563EB);
      case PRFInstitutionType.college:
      case PRFInstitutionType.university:
        return const Color(0xFFEA580C);
    }
  }

  static PRFInstitutionType fromValue(int value) {
    switch (value) {
      case 1:
        return PRFInstitutionType.highSchool;
      case 2:
        return PRFInstitutionType.primarySchool;
      case 3:
        return PRFInstitutionType.college;
      case 4:
        return PRFInstitutionType.university;
      case 5:
        return PRFInstitutionType.community;
      case 6:
        return PRFInstitutionType.juniorSecondarySchool;
      default:
        return PRFInstitutionType.highSchool;
    }
  }
}
