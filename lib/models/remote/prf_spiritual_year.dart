import 'package:freezed_annotation/freezed_annotation.dart';

part 'prf_spiritual_year.freezed.dart';
part 'prf_spiritual_year.g.dart';

@freezed
abstract class PRFSpiritualYear with _$PRFSpiritualYear {
  factory PRFSpiritualYear(String ulid, String name) = _PRFSpiritualYear;

  factory PRFSpiritualYear.fromJson(Map<String, dynamic> json) =>
      _$PRFSpiritualYearFromJson(json);
}
