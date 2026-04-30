import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_config.freezed.dart';
part 'remote_config.g.dart';

@freezed
abstract class RemoteConfig with _$RemoteConfig {
  factory RemoteConfig({
    @Default([]) List<ReviewConfig> reviewConfigs,
  }) = _RemoteConfig;

  factory RemoteConfig.fromJson(Map<String, dynamic> json) =>
      _$RemoteConfigFromJson(json);
}

@freezed
abstract class ReviewConfig with _$ReviewConfig {
  factory ReviewConfig({
    required String appStore, // 'ios', 'android', 'huawei', 'all'
    required String appVersion,
    required bool isInReview,
  }) = _ReviewConfig;

  factory ReviewConfig.fromJson(Map<String, dynamic> json) =>
      _$ReviewConfigFromJson(json);
}
