import 'package:equatable/equatable.dart';

class RecipeStep extends Equatable {
  final String title;
  final String description;
  final String duration;

  const RecipeStep({
    required this.title,
    required this.description,
    required this.duration,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) => RecipeStep(
        title: json['title'] as String,
        description: json['description'] as String,
        duration: json['duration'] as String,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'duration': duration,
      };

  @override
  List<Object> get props => [title, description, duration];
}

class FoodItemData extends Equatable {
  final String title;
  final String description;
  final double rating;
  final String imageUrl;
  final String category;
  final String prepTime;
  final String proteins;
  final String fats;
  final String carbs;
  final String calories;
  final String servings;
  final List<String> ingredients;
  final List<RecipeStep> steps;

  const FoodItemData({
    required this.title,
    required this.description,
    required this.rating,
    required this.imageUrl,
    required this.category,
    this.prepTime = '15 Min',
    this.proteins = '0 g',
    this.fats = '0 g',
    this.carbs = '0 g',
    this.calories = '0 kcal',
    this.servings = '2',
    this.ingredients = const [],
    this.steps = const [],
  });

  factory FoodItemData.fromJson(Map<String, dynamic> json) => FoodItemData(
        title: json['title'] as String,
        description: json['description'] as String,
        rating: (json['rating'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String,
        category: json['category'] as String,
        prepTime: json['prepTime'] as String? ?? '15 Min',
        proteins: json['proteins'] as String? ?? '0 g',
        fats: json['fats'] as String? ?? '0 g',
        carbs: json['carbs'] as String? ?? '0 g',
        calories: json['calories'] as String? ?? '0 kcal',
        servings: json['servings'] as String? ?? '2',
        ingredients: (json['ingredients'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        steps: (json['steps'] as List<dynamic>?)
                ?.map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'rating': rating,
        'imageUrl': imageUrl,
        'category': category,
        'prepTime': prepTime,
        'proteins': proteins,
        'fats': fats,
        'carbs': carbs,
        'calories': calories,
        'servings': servings,
        'ingredients': ingredients,
        'steps': steps.map((s) => s.toJson()).toList(),
      };

  @override
  List<Object> get props => [
        title,
        description,
        rating,
        imageUrl,
        category,
        prepTime,
        proteins,
        fats,
        carbs,
        calories,
        servings,
        ingredients,
        steps,
      ];
}
