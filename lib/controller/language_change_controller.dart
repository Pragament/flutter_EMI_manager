import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageChangeController with ChangeNotifier {
  Locale? _appLocale;
  Locale? get applocale => _appLocale;

  void changeLanguage(Locale type) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    _appLocale = type;

    if (type == const Locale('en')) {
      await sp.setString('language_code', 'en');
      sp.setBool('isSet', true);
    } else if (type == const Locale('hi')) {
      sp.setString('language_code', 'hi');
      await sp.setBool('isSet', true);
    } else {
      await sp.setString('language_code', 'te');
      sp.setBool('isSet', true);
    }
    notifyListeners();
  }
}
