import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';

class CookedEntry {
  final String recipeTitle;
  final String imageUrl;
  final DateTime cookedAt;

  const CookedEntry({
    required this.recipeTitle,
    required this.imageUrl,
    required this.cookedAt,
  });
}

/// Stores completed cooking sessions using a Hive box.
/// Each entry is encoded as:  `title|||imageUrl|||timestampMs`
class CookingHistory {
  static const _boxName = 'cooking_history';
  static const _sep = '|||';

  static Future<void> init() async {
    await Hive.openBox<String>(_boxName);
  }

  static Future<void> recordCooked(FoodItemData recipe) async {
    final box = Hive.box<String>(_boxName);
    final entry =
        '${recipe.title}$_sep${recipe.imageUrl}$_sep${DateTime.now().millisecondsSinceEpoch}';
    await box.add(entry);
  }

  static List<CookedEntry> getHistory() {
    final box = Hive.box<String>(_boxName);
    final entries = <CookedEntry>[];
    for (final raw in box.values) {
      final parts = raw.split(_sep);
      if (parts.length == 3) {
        final ms = int.tryParse(parts[2]);
        if (ms != null) {
          entries.add(CookedEntry(
            recipeTitle: parts[0],
            imageUrl: parts[1],
            cookedAt: DateTime.fromMillisecondsSinceEpoch(ms),
          ));
        }
      }
    }
    return entries..sort((a, b) => b.cookedAt.compareTo(a.cookedAt));
  }

  static int getCookedCount() => getHistory().length;
}
