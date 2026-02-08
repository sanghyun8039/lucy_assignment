import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _keyThemeMode = 'themeMode';
  static const String _keyLocale = 'locale';

  late Box _box;
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('ko');

  SettingsProvider() {
    _init();
  }

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  Future<void> _init() async {
    _box = await Hive.openBox(_boxName);
    _loadSettings();
  }

  void _loadSettings() {
    final isDark = _box.get(_keyThemeMode);
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }

    final languageCode = _box.get(_keyLocale);
    if (languageCode != null) {
      _locale = Locale(languageCode);
    } else {
      _locale = const Locale('ko');
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _box.put(_keyThemeMode, mode == ThemeMode.dark);
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    await _box.put(_keyLocale, locale.languageCode);
  }
}
