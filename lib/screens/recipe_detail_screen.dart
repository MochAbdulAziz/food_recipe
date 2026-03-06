import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/home/home_state.dart';
import '../utils/colors.dart';

class RecipeDetailScreen extends StatelessWidget {
  final FoodItemData foodItem;

  const RecipeDetailScreen({Key? key, required this.foodItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              foodItem.imageUrl,
              fit: BoxFit.cover,
            ),
          ),

          // Top Action Buttons
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircularButton(
                    Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                _buildCircularButton(Icons.info_outline, () {}),
              ],
            ),
          ),

          // Floating Ingredient Tags (Approximation)
          if (foodItem.ingredients.isNotEmpty) ...[
            _buildIngredientTag(foodItem.ingredients[0], top: 220, left: 80),
            if (foodItem.ingredients.length > 1)
              _buildIngredientTag(foodItem.ingredients[1], top: 180, right: 60),
            if (foodItem.ingredients.length > 2)
              _buildIngredientTag(foodItem.ingredients[2], top: 380, left: 40),
            if (foodItem.ingredients.length > 3)
              _buildIngredientTag(foodItem.ingredients[3], top: 480, left: 180),
            if (foodItem.ingredients.length > 4)
              _buildIngredientTag(foodItem.ingredients[4], top: 400, right: 60),
          ],

          // Bottom Info Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0EC), // Light orange bg
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite,
                            color: Color(0xFFFF7B5C), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          foodItem.prepTime,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFF7B5C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    foodItem.title,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    foodItem.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textDark.withOpacity(0.5),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nutrition Facts
                  _buildNutritionRow('Proteins', foodItem.proteins),
                  const SizedBox(height: 12),
                  _buildNutritionRow('Fats', foodItem.fats),
                  const SizedBox(height: 12),
                  _buildNutritionRow('Carbohydrates', foodItem.carbs),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.3),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildIngredientTag(String text,
      {double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.white.withOpacity(0.4), width: 1),
            ),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 2,
                height: 2,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: List.generate(
                  (constraints.constrainWidth() / 5).floor(),
                  (index) => const SizedBox(
                    width: 2,
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFF7B5C), // Orange color
          ),
        ),
      ],
    );
  }
}
