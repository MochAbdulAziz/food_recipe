import 'package:equatable/equatable.dart';
import '../../models/category.dart';
import '../../models/recipe.dart';

// Re-export models so existing imports of home_state.dart keep working.
export '../../models/category.dart';
export '../../models/recipe.dart';

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

// Placeholder — kept for file integrity.
