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
              "https://images.unsplash.com/photo-1552590635-27c2c2128abf?w=1000&auto=format&fit=crop&q=80",
          category: "Dinner",
          prepTime: "20 Min",
        ),
        const FoodItemData(
          title: "Japanese Katsu Curry",
          description:
              "A perfect balance of crispy katsu and aromatic curry sauce, crafted for true comfort.",
          rating: 4.7,
          imageUrl:
              "https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=1000&auto=format&fit=crop&q=80",
          category: "Dinner",
          prepTime: "30 Min",
        ),
        const FoodItemData(
          title: "Classic Egg Toast",
          description:
              "Buttery toast layered with perfectly cooked eggs - a timeless breakfast favorite.",
          rating: 4.5,
          imageUrl:
              "https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=1000&auto=format&fit=crop&q=80",
          category: "Breakfast",
          prepTime: "10 Min",
        ),
        const FoodItemData(
          title: "Pancakes with Syrup",
          description:
              "Fluffy pancakes served with maple syrup and fresh berries.",
          rating: 4.8,
          imageUrl:
              "https://images.unsplash.com/photo-1528207776546-384cb1119671?w=1000&auto=format&fit=crop&q=80",
          category: "Breakfast",
          prepTime: "15 Min",
        ),
        const FoodItemData(
          title: "Creamy Tomato Soup",
          description:
              "Rich and creamy tomato soup, perfect for a cozy evening.",
          rating: 4.6,
          imageUrl:
              "https://images.unsplash.com/photo-1547592180-85f173990554?w=1000&auto=format&fit=crop&q=80",
          category: "Soup",
          prepTime: "25 Min",
        ),
        const FoodItemData(
          title: "Chicken Noodle Soup",
          description: "Comforting chicken noodle soup with fresh vegetables.",
          rating: 4.9,
          imageUrl:
              "https://images.unsplash.com/photo-1603105037880-8ea2bc26dcc6?w=1000&auto=format&fit=crop&q=80",
          category: "Soup",
          prepTime: "40 Min",
        ),
        const FoodItemData(
          title: "Iced Caramel Macchiato",
          description:
              "Chilled espresso with milk and a sweet caramel drizzle.",
          rating: 4.7,
          imageUrl:
              "https://images.unsplash.com/photo-1517705008128-361805f42e86?w=1000&auto=format&fit=crop&q=80",
          category: "Drinks",
          prepTime: "5 Min",
        ),
        const FoodItemData(
          title: "Tropical Mango Smoothie",
          description: "Refreshing blend of ripe mangoes, yogurt, and honey.",
          rating: 4.8,
          imageUrl:
              "https://images.unsplash.com/photo-1628557044797-f21a177c37ec?w=1000&auto=format&fit=crop&q=80",
          category: "Drinks",
          prepTime: "5 Min",
        ),
        const FoodItemData(
          title: "Chocolate Lava Cake",
          description:
              "Decadent chocolate cake with a molten chocolate center.",
          rating: 4.9,
          imageUrl:
              "https://images.unsplash.com/photo-1624353365286-3f8d62daad51?w=1000&auto=format&fit=crop&q=80",
          category: "More",
          prepTime: "30 Min",
        ),
        const FoodItemData(
          title: "Classic Caesar Salad",
          description:
              "Crisp romaine lettuce with parmesan, croutons, and Caesar dressing.",
          rating: 4.4,
          imageUrl:
              "https://images.unsplash.com/photo-1550304943-4f24f54fb80c?w=1000&auto=format&fit=crop&q=80",
          category: "More",
          prepTime: "15 Min",
        ),
      ];

      emit(HomeLoaded(categories: categories, foodItems: foodItems));
    } catch (e) {
      emit(const HomeError("Failed to load data"));
    }
  }
}
