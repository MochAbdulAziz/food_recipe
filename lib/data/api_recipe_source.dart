import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/recipe.dart';
import 'api_client.dart';
import 'recipe_repository.dart';

/// Fetches recipes from TheMealDB free API.
/// Pagination is simulated by cycling through a list of search terms —
/// each "page" searches a different ingredient keyword.
class ApiRecipeSource implements RecipeRepository {
  final ApiClient _client;

  ApiRecipeSource(this._client);

  /// Each page maps to one search term. 10 pages total.
  static const _searchTerms = [
    'chicken',
    'beef',
    'pasta',
    'fish',
    'pork',
    'rice',
    'soup',
    'lamb',
    'shrimp',
    'cake',
  ];

  // ── Category icon mapping ───────────────────────────────────────────────

  static const _categoryIcons = <String, IconData>{
    'Beef': Icons.outdoor_grill,
    'Breakfast': Icons.bakery_dining,
    'Chicken': Icons.restaurant,
    'Dessert': Icons.cake,
    'Goat': Icons.restaurant_menu,
    'Lamb': Icons.restaurant_menu,
    'Miscellaneous': Icons.grid_view,
    'Pasta': Icons.restaurant,
    'Pork': Icons.lunch_dining,
    'Seafood': Icons.set_meal,
    'Side': Icons.food_bank,
    'Starter': Icons.fastfood,
    'Vegan': Icons.eco,
    'Vegetarian': Icons.grass,
    'Soup': Icons.soup_kitchen,
  };

  // ── RecipeRepository impl ───────────────────────────────────────────────

  @override
  bool hasMoreData(int nextPage) => nextPage < _searchTerms.length;

  @override
  Future<List<CategoryData>> getCategories() async {
    try {
      final data = await _client.get('/categories.php');
      final raw = data['categories'] as List<dynamic>? ?? [];
      return raw
          .map((e) => e as Map<String, dynamic>)
          .map((m) => CategoryData(
                title: m['strCategory'] as String,
                icon: _categoryIcons[m['strCategory']] ?? Icons.restaurant,
              ))
          .toList();
    } catch (_) {
      // Fall back to hard-coded set so the UI always has categories
      return const [
        CategoryData(title: 'Chicken', icon: Icons.restaurant),
        CategoryData(title: 'Beef', icon: Icons.outdoor_grill),
        CategoryData(title: 'Seafood', icon: Icons.set_meal),
        CategoryData(title: 'Pasta', icon: Icons.restaurant),
        CategoryData(title: 'Dessert', icon: Icons.cake),
      ];
    }
  }

  @override
  Future<List<FoodItemData>> getRecipes({int page = 0}) async {
    if (page >= _searchTerms.length) return [];

    final term = _searchTerms[page];
    final data = await _client.get('/search.php', queryParameters: {'s': term});
    final meals = data['meals'] as List<dynamic>?;
    if (meals == null) return [];

    return meals
        .map((e) => _mealToFoodItem(e as Map<String, dynamic>))
        .toList();
  }

  // ── Parsing helpers ─────────────────────────────────────────────────────

  FoodItemData _mealToFoodItem(Map<String, dynamic> m) {
    final ingredients = <String>[];
    for (var i = 1; i <= 20; i++) {
      final ing = (m['strIngredient$i'] as String? ?? '').trim();
      final mea = (m['strMeasure$i'] as String? ?? '').trim();
      if (ing.isNotEmpty) {
        ingredients.add(mea.isNotEmpty ? '$mea $ing' : ing);
      }
    }

    final instructions = (m['strInstructions'] as String? ?? '').trim();
    final steps = _parseInstructions(instructions);
    final category = (m['strCategory'] as String? ?? 'Other');

    return FoodItemData(
      title: m['strMeal'] as String,
      description: _buildDescription(m),
      rating: 4.5,
      imageUrl: (m['strMealThumb'] as String? ?? ''),
      category: category,
      prepTime: '30 Min',
      calories: '350 kcal',
      servings: '4',
      proteins: '25 g',
      fats: '12 g',
      carbs: '40 g',
      ingredients: ingredients,
      steps: steps,
    );
  }

  static String _buildDescription(Map<String, dynamic> m) {
    final area = (m['strArea'] as String? ?? '').trim();
    final cat = (m['strCategory'] as String? ?? '').trim();
    if (area.isNotEmpty && cat.isNotEmpty) {
      return '$area-style $cat dish with rich flavours.';
    }
    if (cat.isNotEmpty) return 'Classic $cat recipe you\'ll love.';
    return 'A delicious homemade dish.';
  }

  static List<RecipeStep> _parseInstructions(String instructions) {
    if (instructions.isEmpty) return [];

    // Try split on numbered markers first
    final parts = instructions
        .split(
          RegExp(r'\r?\n(?=\d+[\.\)])|STEP\s+\d+:?', caseSensitive: false),
        )
        .map((s) => s.replaceAll(RegExp(r'\r?\n'), ' ').trim())
        .where((s) => s.length > 20)
        .toList();

    // If that yields less than 2, fall back to double-newline split
    final chunks = parts.length >= 2
        ? parts
        : instructions
            .split(RegExp(r'\r?\n\r?\n'))
            .map((s) => s.replaceAll(RegExp(r'\r?\n'), ' ').trim())
            .where((s) => s.length > 20)
            .toList();

    return chunks.take(6).toList().asMap().entries.map((e) {
      final clean = e.value
          .replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '')
          .replaceFirst(RegExp(r'^STEP \d+:?\s*', caseSensitive: false), '')
          .trim();
      return RecipeStep(
        title: 'Step ${e.key + 1}',
        description: clean,
        duration: '${5 + e.key * 3} min',
      );
    }).toList();
  }
}
