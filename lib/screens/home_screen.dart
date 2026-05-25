import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../widgets/app_remote_image.dart';
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
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Categories
                        Text(
                          "Categories",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCategories(context, state.categories, state.foodItems),
                        const SizedBox(height: 24),
                        // Featured Recipe
                        if (state.foodItems.isNotEmpty) ...[
                          Text(
                            '\u2736  Featured Recipe',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildFeaturedCard(context, state.foodItems.first),
                          const SizedBox(height: 24),
                        ],
                        // What's Cooking Now
                        Row(
                          children: [
                            Text(
                              "What's Cooking Now",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.whatshot_rounded,
                                color: AppColors.accentSalmon, size: 20),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildFoodList(context,
                            state.foodItems.length > 1
                                ? state.foodItems.skip(1).toList()
                                : state.foodItems),
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
      BuildContext context,
      List<CategoryData> categories,
      List<FoodItemData> foodItems) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories
            .map((category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
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
                    child: CategoryItem(
                        title: category.title, icon: category.icon),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, FoodItemData item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(foodItem: item),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Image
            SizedBox(
              height: 180,
              width: double.infinity,
              child: AppRemoteImage(imageUrl: item.imageUrl),
            ),
            // Gradient overlay
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.72),
                  ],
                  stops: const [0.35, 1.0],
                ),
              ),
            ),
            // Category badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  item.category.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            // Info bottom
            Positioned(
              bottom: 14,
              left: 14,
              right: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        if (i < item.rating.floor()) {
                          return const Icon(Icons.star_rounded, color: AppColors.accentAmber, size: 13);
                        } else if (i < item.rating) {
                          return const Icon(Icons.star_half_rounded, color: AppColors.accentAmber, size: 13);
                        } else {
                          return const Icon(Icons.star_outline_rounded, color: AppColors.accentAmber, size: 13);
                        }
                      }),
                      const SizedBox(width: 6),
                      Text(
                        item.rating.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.schedule_rounded, color: Colors.white70, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        item.prepTime,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodList(BuildContext context, List<FoodItemData> foodItems) {
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
                  prepTime: item.prepTime,
                ),
              ))
          .toList(),
    );
  }
}
