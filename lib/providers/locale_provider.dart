import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/services/hive_service.dart';

class LocaleProvider extends ChangeNotifier {
  static const _localeKey = 'locale';

  late Box _box;
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  static const List<Locale> supported = [
    Locale('en'),
    Locale('fr'),
    Locale('ar'),
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'fr': 'Français',
    'ar': 'العربية',
  };

  static const Map<String, String> languageFlags = {
    'en': '🇬🇧',
    'fr': '🇫🇷',
    'ar': '🇲🇦',
  };

  Future<void> init() async {
    _box = await HiveService.openBox(HiveService.settingsBox);
    final code = _box.get(_localeKey, defaultValue: 'en') as String;
    _locale = Locale(code);
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    _box.put(_localeKey, locale.languageCode);
    notifyListeners();
  }
}
