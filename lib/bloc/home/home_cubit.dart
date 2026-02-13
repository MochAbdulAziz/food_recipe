import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeLoading());

  void loadData() async {
    try {
      emit(HomeLoading());
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final categories = [
        const CategoryData(title: "Soup", icon: Icons.restaurant_menu),
        const CategoryData(title: "Breakfast", icon: Icons.bakery_dining),
        const CategoryData(title: "Drinks", icon: Icons.local_cafe_rounded),
        const CategoryData(title: "Dinner", icon: Icons.dinner_dining),
        const CategoryData(title: "More", icon: Icons.grid_view),
      ];

      final foodItems = [
        const FoodItemData(
          title: "Hot & Spicy Shrimp Rice",
          description:
              "Spicy fried rice with juicy shrimp and bold flavors in every bite.",
          rating: 5.0,
          imageUrl:
              "https://images.unsplash.com/photo-1552590635-27c2c2128abf?w=500&auto=format&fit=crop&q=60",
        ),
        const FoodItemData(
          title: "Japanese Katsu Curry",
          description:
              "A perfect balance of crispy katsu and aromatic curry sauce, crafted for true comfort.",
          rating: 4.7,
          imageUrl:
              "https://images.unsplash.com/photo-1552590635-27c2c2128abf?w=500&auto=format&fit=crop&q=60",
        ),
        const FoodItemData(
          title: "Classic Egg Toast",
          description:
              "Buttery toast layered with perfectly cooked eggs - a timeless breakfast favorite.",
          rating: 4.5,
          imageUrl:
              "https://images.unsplash.com/photo-1552590635-27c2c2128abf?w=500&auto=format&fit=crop&q=60",
        ),
      ];

      emit(HomeLoaded(categories: categories, foodItems: foodItems));
    } catch (e) {
      emit(const HomeError("Failed to load data"));
    }
  }
}
