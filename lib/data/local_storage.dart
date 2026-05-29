import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static const _favBoxName = 'favourites';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_favBoxName);
  }

  static Set<String> loadFavourites() {
    final box = Hive.box<String>(_favBoxName);
    return box.values.toSet();
  }

  static Future<void> saveFavourites(Set<String> ids) async {
    final box = Hive.box<String>(_favBoxName);
    await box.clear();
    await box.addAll(ids);
  }
}
