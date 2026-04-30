import 'package:flutter/material.dart';

enum PRFThemeMode {
  system,
  light,
  dark
  ;

  ThemeMode toFlutterThemeMode() {
    return switch (this) {
      PRFThemeMode.system => ThemeMode.system,
      PRFThemeMode.light => ThemeMode.light,
      PRFThemeMode.dark => ThemeMode.dark,
    };
  }

  static PRFThemeMode fromFlutterThemeMode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => PRFThemeMode.system,
      ThemeMode.light => PRFThemeMode.light,
      ThemeMode.dark => PRFThemeMode.dark,
    };
  }

  static PRFThemeMode fromString(String value) {
    return switch (value) {
      'light' => PRFThemeMode.light,
      'dark' => PRFThemeMode.dark,
      _ => PRFThemeMode.system,
    };
  }
}
