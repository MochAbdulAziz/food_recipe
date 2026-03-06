import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/category_item.dart';
import '../widgets/food_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home/home_cubit.dart';
import '../bloc/home/home_state.dart';
import '../widgets/custom_app_bar.dart';
import 'category_menu_screen.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const CustomAppBar(),
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is HomeLoaded) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Categories
                        Text(
                          "Categories",
                          style:
                              Theme.of(context).textTheme.headline6?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        _buildCategories(
                            context, state.categories, state.foodItems),
                        const SizedBox(height: 32),
                        // What's Cooking Now
                        Row(
                          children: [
                            Text(
                              "What's Cooking Now",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  ?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.whatshot,
                                color: AppColors.accentRed, size: 24),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFoodList(context, state.foodItems),
                      ],
                    ),
                  ),
                );
              } else if (state is HomeError) {
                return SliverFillRemaining(
                  child: Center(child: Text(state.message)),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(
      context, List<CategoryData> categories, List<FoodItemData> foodItems) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories
          .map((category) => GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryMenuScreen(
                        categoryTitle: category.title,
                        foodItems: foodItems
                            .where((item) => item.category == category.title)
                            .toList(),
                      ),
                    ),
                  );
                },
                child: CategoryItem(title: category.title, icon: category.icon),
              ))
          .toList(),
    );
  }

  Widget _buildFoodList(context, List<FoodItemData> foodItems) {
    return Column(
      children: foodItems
          .map((item) => GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(foodItem: item),
                    ),
                  );
                },
                child: FoodCard(
                  title: item.title,
                  description: item.description,
                  rating: item.rating,
                  imageUrl: item.imageUrl,
                ),
              ))
          .toList(),
    );
  }
}
