import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_theme_mode.dart';
import 'package:leadership/services/local_storage/hive/hive_service.dart';

part 'theme_state.dart';
part 'theme_cubit.freezed.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({required HiveService hiveService})
    : _hiveService = hiveService,
      super(const ThemeState.initial()) {
    _loadSavedTheme();
  }

  final HiveService _hiveService;

  PRFThemeMode get currentThemeMode => state.maybeWhen(
    loaded: (themeMode) => themeMode,
    orElse: () => PRFThemeMode.system,
  );

  bool get isDarkMode => currentThemeMode == PRFThemeMode.dark;

  bool get isLightMode => currentThemeMode == PRFThemeMode.light;

  bool get isSystemMode => currentThemeMode == PRFThemeMode.system;

  void _loadSavedTheme() {
    final savedTheme = _hiveService.settings.getThemeMode();
    emit(ThemeState.loaded(themeMode: savedTheme));
  }

  void toggleTheme() {
    final newMode = switch (currentThemeMode) {
      PRFThemeMode.light => PRFThemeMode.dark,
      PRFThemeMode.dark => PRFThemeMode.light,
      PRFThemeMode.system => PRFThemeMode.light,
    };
    _setAndPersistTheme(newMode);
  }

  void setThemeMode(PRFThemeMode mode) {
    _setAndPersistTheme(mode);
  }

  void setLightMode() => setThemeMode(PRFThemeMode.light);

  void setDarkMode() => setThemeMode(PRFThemeMode.dark);

  void setSystemMode() => setThemeMode(PRFThemeMode.system);

  void _setAndPersistTheme(PRFThemeMode mode) {
    _hiveService.settings.setThemeMode(mode);
    emit(ThemeState.loaded(themeMode: mode));
  }
}
