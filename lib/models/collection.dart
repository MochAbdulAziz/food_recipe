import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RecipeCollection extends Equatable {
  final String id;
  final String name;
  final List<String> recipeIds;

  const RecipeCollection({
    required this.id,
    required this.name,
    this.recipeIds = const [],
  });

  factory RecipeCollection.fromJson(Map<String, dynamic> json) =>
      RecipeCollection(
        id: json['id'] as String,
        name: json['name'] as String,
        recipeIds: (json['recipeIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'recipeIds': recipeIds,
      };

  RecipeCollection copyWith({String? name, List<String>? recipeIds}) =>
      RecipeCollection(
        id: id,
        name: name ?? this.name,
        recipeIds: recipeIds ?? this.recipeIds,
      );

  @override
  List<Object> get props => [id, name, recipeIds];
}

class CollectionStorage {
  static const _boxName = 'collections_v1';

  static Future<void> init() async {
    await Hive.openBox<String>(_boxName);
  }

  static List<RecipeCollection> load() {
    final box = Hive.box<String>(_boxName);
    return box.values
        .map((json) => RecipeCollection.fromJson(
            jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  static Future<RecipeCollection> create(String name) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final collection = RecipeCollection(id: id, name: name.trim());
    final box = Hive.box<String>(_boxName);
    await box.put(id, jsonEncode(collection.toJson()));
    return collection;
  }

  static Future<void> update(RecipeCollection collection) async {
    final box = Hive.box<String>(_boxName);
    await box.put(collection.id, jsonEncode(collection.toJson()));
  }

  static Future<void> delete(String id) async {
    final box = Hive.box<String>(_boxName);
    await box.delete(id);
  }
}
