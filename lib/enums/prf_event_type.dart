import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFEventType {
  @JsonValue(1)
  member,
  @JsonValue(2)
  leadership;

  int get apiKey {
    switch (this) {
      case PRFEventType.member:
        return 1;
      case PRFEventType.leadership:
        return 2;
    }
  }
}
