import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFEvent {
  @JsonValue(1)
  defaultEvent;

  String get name {
    switch (this) {
      case PRFEvent.defaultEvent:
        return 'Default Event';
    }
  }

  static PRFEvent fromIndex(int index) {
    switch (index) {
      default:
        return PRFEvent.defaultEvent;
    }
  }
}

enum PRFPresenceEvent {
  @JsonValue(5)
  defaultPresenceEvent;

  String get name {
    switch (this) {
      case PRFPresenceEvent.defaultPresenceEvent:
        return 'Default Presence Event';
    }
  }

  static PRFPresenceEvent fromIndex(int index) {
    switch (index) {
      default:
        return PRFPresenceEvent.defaultPresenceEvent;
    }
  }
}
