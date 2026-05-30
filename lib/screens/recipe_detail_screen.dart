import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/home/home_state.dart';
import '../bloc/shopping/shopping_cubit.dart';
import '../data/offline_cache.dart';
import '../models/collection.dart';
import '../utils/colors.dart';
import '../widgets/app_remote_image.dart';
import '../widgets/serving_adjuster.dart';
import 'start_cooking_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final FoodItemData foodItem;
  final bool isFav;
  final VoidCallback? onToggleFav;

  const RecipeDetailScreen({
    super.key,
    required this.foodItem,
    this.isFav = false,
    this.onToggleFav,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late bool _saved;
  late int _servings;

  @override
  void initState() {
    super.initState();
    _saved = widget.isFav;
    _servings = int.tryParse(
            RegExp(r'\d+').firstMatch(widget.foodItem.servings)?.group(0) ?? '2') ??
        2;
    // Track viewed for offline cache
    OfflineCache.addViewed(widget.foodItem);
  }

  @override
  void didUpdateWidget(RecipeDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _saved = widget.isFav;
  }

  double _parseNutrient(String value) {
    final match = RegExp(r'\d+(\.\d+)?').firstMatch(value);
    return match != null ? double.tryParse(match.group(0)!) ?? 0 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.foodItem;
    final proteinFraction = (_parseNutrient(item.proteins) / 60).clamp(0.0, 1.0);
    final fatFraction = (_parseNutrient(item.fats) / 50).clamp(0.0, 1.0);
    final carbsFraction = (_parseNutrient(item.carbs) / 100).clamp(0.0, 1.0);

    return Scaffold(
      body: Stack(
        children: [
          // Hero image
          Positioned.fill(
            child: AppRemoteImage(imageUrl: item.imageUrl),
          ),

          // Top action buttons
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircularButton(
                    Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                Row(
                  children: [
                    _buildCircularButton(
                      Icons.bookmark_add_outlined,
                      () => _showSaveToCollection(context),
                    ),
                    const SizedBox(width: 10),
                    _buildCircularButton(
                      _saved ? Icons.favorite : Icons.favorite_border,
                      () {
                        setState(() => _saved = !_saved);
                        widget.onToggleFav?.call();
                      },
                      iconColor: _saved ? AppColors.accentSalmon : Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Floating ingredient tags
          if (item.ingredients.isNotEmpty)
            _buildIngredientTag(item.ingredients[0], top: 220, left: 80),
          if (item.ingredients.length > 1)
            _buildIngredientTag(item.ingredients[1], top: 175, right: 55),
          if (item.ingredients.length > 2)
            _buildIngredientTag(item.ingredients[2], top: 370, left: 36),

          // Bottom info sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.60,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag indicator
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.chipBg,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Prep time badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0EC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded,
                              color: AppColors.accentSalmon, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            item.prepTime,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentSalmon,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Title
                    Text(
                      item.title,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Rating row
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          if (i < item.rating.floor()) {
                            return const Icon(Icons.star_rounded, color: AppColors.accentAmber, size: 15);
                          } else if (i < item.rating) {
                            return const Icon(Icons.star_half_rounded, color: AppColors.accentAmber, size: 15);
                          } else {
                            return const Icon(Icons.star_outline_rounded, color: AppColors.accentAmber, size: 15);
                          }
                        }),
                        const SizedBox(width: 6),
                        Text(
                          item.rating.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMid,
                          ),
                        ),
                        Text(
                          ' · ${item.servings} Servings · ${item.calories}',
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      item.description,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textLight,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Nutrition section
                    Text(
                      'Nutrition Facts',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildNutritionCard('Protein', item.proteins,
                            const Color(0xFF5B9BD5), proteinFraction),
                        const SizedBox(width: 10),
                        _buildNutritionCard('Fats', item.fats,
                            AppColors.accentSalmon, fatFraction),
                        const SizedBox(width: 10),
                        _buildNutritionCard('Carbs', item.carbs,
                            AppColors.accentAmber, carbsFraction),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Ingredients
                    if (item.ingredients.isNotEmpty) ...[
                      ServingAdjuster(
                        initialServings: item.servings,
                        onChanged: (v) => setState(() => _servings = v),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ingredients',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: item.ingredients
                            .map((ing) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgMuted,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    () {
                                      final baseServings = int.tryParse(
                                              RegExp(r'\d+').firstMatch(item.servings)?.group(0) ?? '2') ??
                                          2;
                                      final multiplier = _servings / baseServings;
                                      return scaleIngredient(ing, multiplier);
                                    }(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMid,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Steps preview strip
                    if (item.steps.isNotEmpty) ...[
                      Row(
                        children: [
                          Text(
                            '${item.steps.length} Steps',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                          ),
                          Text(
                            ' · ${item.prepTime}',
                            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: item.steps.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (ctx, i) {
                            final step = item.steps[i];
                            return Container(
                              width: 96,
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                              decoration: BoxDecoration(
                                color: AppColors.bgMuted,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 24, height: 24,
                                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                    child: Center(
                                      child: Text('${i + 1}',
                                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(step.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.3)),
                                  const Spacer(),
                                  Text(step.duration,
                                    style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textLight)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],

                    // CTA buttons
                    if (item.ingredients.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              context.read<ShoppingCubit>().addFromRecipe(item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Added to shopping list!',
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                  backgroundColor: AppColors.primary,
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            },
                            icon: const Icon(Icons.shopping_cart_outlined,
                                size: 18),
                            label: Text('Add to Shopping List',
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side:
                                  const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDeep],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: item.steps.isEmpty ? null : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StartCookingScreen(recipe: item),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Start Cooking →',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSaveToCollection(BuildContext context) async {
    final collections = CollectionStorage.load();
    if (!context.mounted) return;
    if (collections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No collections yet. Create one from Favourites.',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: AppColors.textDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.chipBg,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Save to Collection',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            ),
            const SizedBox(height: 8),
            ...collections.map((c) {
              final alreadySaved = c.recipeIds.contains(widget.foodItem.title);
              return ListTile(
                leading: Icon(
                  alreadySaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: alreadySaved ? AppColors.primary : AppColors.textMid,
                ),
                title: Text(c.name,
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w500,
                        color: alreadySaved ? AppColors.primary : AppColors.textDark)),
                trailing: alreadySaved
                    ? Text('Saved',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600))
                    : null,
                onTap: () async {
                  Navigator.pop(context);
                  if (!alreadySaved) {
                    final updated = c.copyWith(
                        recipeIds: [...c.recipeIds, widget.foodItem.title]);
                    await CollectionStorage.update(updated);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added to "${c.name}"',
                              style: GoogleFonts.poppins(fontSize: 13)),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  }
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton(IconData icon, VoidCallback onTap,
      {Color iconColor = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.3),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
        ),
        child: Icon(icon, color: iconColor, size: 20),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: AppColors.textDark,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionCard(
      String label, String value, Color color, double fraction) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        decoration: BoxDecoration(
          color: AppColors.bgMuted,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            // Mini bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                backgroundColor: const Color(0xFFE5E0DB),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
