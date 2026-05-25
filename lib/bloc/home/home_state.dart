import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // For IconData

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<CategoryData> categories;
  final List<FoodItemData> foodItems;

  const HomeLoaded({required this.categories, required this.foodItems});

  @override
  List<Object> get props => [categories, foodItems];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}

// Data models for the state
class CategoryData extends Equatable {
  final String title;
  final IconData icon;

  const CategoryData({required this.title, required this.icon});

  @override
  List<Object> get props => [title, icon];
}

class RecipeStep extends Equatable {
  final String title;
  final String description;
  final String duration;

  const RecipeStep({
    required this.title,
    required this.description,
    required this.duration,
  });

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
    this.prepTime = "15 Min",
    this.proteins = "0 g",
    this.fats = "0 g",
    this.carbs = "0 g",
    this.calories = "0 kcal",
    this.servings = "2",
    this.ingredients = const [],
    this.steps = const [],
  });

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
