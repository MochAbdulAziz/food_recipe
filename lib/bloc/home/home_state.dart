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
  final bool hasMore;
  final bool isLoadingMore;
  final int currentPage;

  const HomeLoaded({
    required this.categories,
    required this.foodItems,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.currentPage = 0,
  });

  HomeLoaded copyWith({
    List<CategoryData>? categories,
    List<FoodItemData>? foodItems,
    bool? hasMore,
    bool? isLoadingMore,
    int? currentPage,
  }) =>
      HomeLoaded(
        categories: categories ?? this.categories,
        foodItems: foodItems ?? this.foodItems,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        currentPage: currentPage ?? this.currentPage,
      );

  @override
  List<Object> get props =>
      [categories, foodItems, hasMore, isLoadingMore, currentPage];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}

// Placeholder — kept for file integrity.
