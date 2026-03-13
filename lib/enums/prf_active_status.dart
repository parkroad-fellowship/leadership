import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFActiveStatus {
  @JsonValue(1)
  inactive,
  @JsonValue(2)
  active
  ;

  int get apiKey {
    switch (this) {
      case PRFActiveStatus.inactive:
        return 1;
      case PRFActiveStatus.active:
        return 2;
    }
  }
}
