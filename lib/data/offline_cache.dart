import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/recipe.dart';

/// Caches the last [maxViewed] viewed recipes and all saved recipes for offline access.
class OfflineCache {
  static const _viewedBoxName = 'offline_viewed';
  static const _savedBoxName = 'offline_saved';
  static const int maxViewed = 50;

  static Future<void> init() async {
    await Hive.openBox<String>(_viewedBoxName);
    await Hive.openBox<String>(_savedBoxName);
  }

  // ─── Viewed recipes ───────────────────────────────────────────────────────

  static Future<void> addViewed(FoodItemData recipe) async {
    final box = Hive.box<String>(_viewedBoxName);
    final key = recipe.title;
    // Move to top (delete + re-add)
    await box.delete(key);
    await box.put(key, jsonEncode(recipe.toJson()));
    // Trim to maxViewed
    if (box.length > maxViewed) {
      final oldest = box.keys.first;
      await box.delete(oldest);
    }
  }

  static List<FoodItemData> getViewed() {
    final box = Hive.box<String>(_viewedBoxName);
    return box.values
        .map((json) => FoodItemData.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList()
        .reversed
        .toList();
  }

  // ─── Saved / favourites recipes ───────────────────────────────────────────

  static Future<void> addSaved(FoodItemData recipe) async {
    final box = Hive.box<String>(_savedBoxName);
    await box.put(recipe.title, jsonEncode(recipe.toJson()));
  }

  static Future<void> removeSaved(String title) async {
    final box = Hive.box<String>(_savedBoxName);
    await box.delete(title);
  }

  static List<FoodItemData> getSaved() {
    final box = Hive.box<String>(_savedBoxName);
    return box.values
        .map((json) => FoodItemData.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  static bool isSaved(String title) {
    final box = Hive.box<String>(_savedBoxName);
    return box.containsKey(title);
  }

  // ─── Combined offline access ───────────────────────────────────────────────

  /// Returns saved + recently viewed (deduped), for offline fallback.
  static List<FoodItemData> getOfflineRecipes() {
    final saved = getSaved();
    final savedTitles = saved.map((r) => r.title).toSet();
    final viewed = getViewed().where((r) => !savedTitles.contains(r.title)).toList();
    return [...saved, ...viewed];
  }

  static Future<void> clear() async {
    await Hive.box<String>(_viewedBoxName).clear();
    await Hive.box<String>(_savedBoxName).clear();
  }
}
