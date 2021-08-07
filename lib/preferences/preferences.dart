import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static SharedPreferences? _prefs;
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static List<String> sortOrder() {
    var sortOrder = _prefs?.getStringList("sortOrder");
    if (sortOrder == null) return [];
    return sortOrder;
  }

  static void setSortOrder(List<String> sortOrder) {
    _prefs?.setStringList("sortOrder", sortOrder);
  }
}