import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/category_item.dart';
import '../widgets/food_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home/home_cubit.dart';
import '../bloc/home/home_state.dart';
import '../widgets/custom_app_bar.dart';

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
                        _buildCategories(state.categories),
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
                        _buildFoodList(state.foodItems),
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

  Widget _buildCategories(List<CategoryData> categories) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories
          .map((category) =>
              CategoryItem(title: category.title, icon: category.icon))
          .toList(),
    );
  }

  Widget _buildFoodList(List<FoodItemData> foodItems) {
    return Column(
      children: foodItems
          .map((item) => FoodCard(
                title: item.title,
                description: item.description,
                rating: item.rating,
                imageUrl: item.imageUrl,
              ))
          .toList(),
    );
  }
}
