// 📍 lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/services/hive_service.dart';

/// Manages dark / light mode toggle.
/// Persists the user's preference in Hive's 'settings' box.
///
/// Usage in Settings screen:
///   final theme = context.read<ThemeProvider>();
///   theme.toggleTheme();
///
/// Usage in any widget:
///   final isDark = context.watch<ThemeProvider>().isDark;
class ThemeProvider extends ChangeNotifier {
  static const _themeKey = 'isDarkMode';

  late Box _box;
  bool _isDark = true; // default: dark (matches the designs)
  bool _initialized = false;

  bool get isDark => _isDark;
  bool get isInitialized => _initialized;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  /// Must be awaited in main() before runApp().
  /// Uses [HiveService.openBox] so opening 'settings' twice never crashes.
  Future<void> init() async {
    _box = await HiveService.openBox(HiveService.settingsBox);
    _isDark = _box.get(_themeKey, defaultValue: true) as bool;
    _initialized = true;
    notifyListeners();
  }

  /// Toggle and instantly persist.
  void toggleTheme() {
    _isDark = !_isDark;
    _box.put(_themeKey, _isDark);
    notifyListeners();
  }

  /// Explicitly set a value (used by the Settings switch).
  void setDark(bool value) {
    if (_isDark == value) return;
    _isDark = value;
    _box.put(_themeKey, _isDark);
    notifyListeners();
  }
}
