import 'package:freezed_annotation/freezed_annotation.dart';

enum PRFEvent {
  @JsonValue(1)
  defaultEvent('Default Event'),
  ;

  const PRFEvent(this._label);

  final String _label;

  String get name => _label;

  static PRFEvent fromIndex(int index) {
    return PRFEvent.values.firstWhere(
      (v) => v.index == index,
      orElse: () => PRFEvent.defaultEvent,
    );
  }
}

enum PRFPresenceEvent {
  @JsonValue(5)
  defaultPresenceEvent('Default Presence Event'),
  ;

  const PRFPresenceEvent(this._label);

  final String _label;

  String get name => _label;

  static PRFPresenceEvent fromIndex(int index) {
    return PRFPresenceEvent.values.firstWhere(
      (v) => v.index == index,
      orElse: () => PRFPresenceEvent.defaultPresenceEvent,
    );
  }
}
