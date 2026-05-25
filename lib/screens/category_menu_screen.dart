import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/home/home_state.dart';
import '../utils/colors.dart';
import '../widgets/food_card.dart';
import 'recipe_detail_screen.dart';

class CategoryMenuScreen extends StatelessWidget {
  final String categoryTitle;
  final List<FoodItemData> foodItems;

  const CategoryMenuScreen({
    Key? key,
    required this.categoryTitle,
    required this.foodItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          categoryTitle,
          style: GoogleFonts.poppins(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: foodItems.isEmpty
          ? Center(
              child: Text(
                'No items found in this category.',
                style: GoogleFonts.poppins(color: AppColors.textDark),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                final item = foodItems[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RecipeDetailScreen(foodItem: item),
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
                );
              },
            ),
    );
  }
}
