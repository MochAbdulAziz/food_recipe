import 'package:shared_preferences/shared_preferences.dart';

/// Persists up to [maxItems] recent search queries using SharedPreferences.
class SearchHistory {
  static const _key = 'search_history_v1';
  static const int maxItems = 20;

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> add(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final history = List<String>.from(prefs.getStringList(_key) ?? []);
    history.remove(q);
    history.insert(0, q);
    if (history.length > maxItems) history.removeLast();
    await prefs.setStringList(_key, history);
  }

  static Future<void> remove(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = List<String>.from(prefs.getStringList(_key) ?? []);
    history.remove(query);
    await prefs.setStringList(_key, history);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
