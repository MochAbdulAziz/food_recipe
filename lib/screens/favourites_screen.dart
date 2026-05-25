import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home/home_cubit.dart';
import '../bloc/home/home_state.dart';
import '../utils/colors.dart';
import '../widgets/app_remote_image.dart';
import 'recipe_detail_screen.dart';

class FavouritesScreen extends StatelessWidget {
  final Set<String> favourites;
  final void Function(String id) onToggleFav;
  final void Function(int index) onTabChange;

  const FavouritesScreen({
    super.key,
    required this.favourites,
    required this.onToggleFav,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final allItems = state is HomeLoaded ? state.foodItems : <FoodItemData>[];
        final favItems = allItems.where((r) => favourites.contains(r.title)).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // ── Header ──
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.textDark, Color(0xFF4A3B30)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 20,
                  right: 20,
                  bottom: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('YOUR COLLECTION',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withValues(alpha: 0.45), letterSpacing: 1.0)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('Favourites',
                          style: GoogleFonts.playfairDisplay(fontSize: 26, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, color: Colors.white)),
                        if (favItems.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentSalmon,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${favItems.length}',
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      favItems.isEmpty
                          ? 'No saved recipes yet'
                          : '${favItems.length} recipe${favItems.length != 1 ? 's' : ''} saved',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.45)),
                    ),
                  ],
                ),
              ),

              // ── Content ──
              Expanded(
                child: favItems.isEmpty
                    ? _buildEmpty(context)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        itemCount: favItems.length + 1,
                        itemBuilder: (ctx, i) {
                          if (i == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Text('SAVED RECIPES',
                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1.0)),
                            );
                          }
                          final item = favItems[i - 1];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _FavCard(
                              item: item,
                              isFav: true,
                              onToggleFav: () => onToggleFav(item.title),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RecipeDetailScreen(
                                    foodItem: item,
                                    isFav: true,
                                    onToggleFav: () => onToggleFav(item.title),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border_rounded, size: 60, color: AppColors.chipBg),
            const SizedBox(height: 16),
            Text('No saved recipes yet',
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text('Tap the ♥ icon on any recipe\nto add it to your collection.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight, height: 1.7)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => onTabChange(0),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Explore Recipes',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavCard extends StatelessWidget {
  final FoodItemData item;
  final bool isFav;
  final VoidCallback onToggleFav;
  final VoidCallback onTap;

  const _FavCard({
    required this.item,
    required this.isFav,
    required this.onToggleFav,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: AppColors.textDark.withValues(alpha: 0.07), blurRadius: 12, offset: const Offset(0, 2))],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(width: 88, height: 88, child: AppRemoteImage(imageUrl: item.imageUrl)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                    maxLines: 2,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.3)),
                  const SizedBox(height: 4),
                  Text(item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight, height: 1.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ...List.generate(5, (i) => Icon(
                        i < item.rating.floor() ? Icons.star_rounded
                          : (i < item.rating ? Icons.star_half_rounded : Icons.star_outline_rounded),
                        color: AppColors.accentAmber, size: 12,
                      )),
                      const SizedBox(width: 4),
                      Text(item.rating.toString(),
                        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMid)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.bgMuted, borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [
                          const Icon(Icons.access_time_rounded, size: 10, color: AppColors.textMid),
                          const SizedBox(width: 3),
                          Text(item.prepTime,
                            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMid)),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onToggleFav,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? AppColors.accentSalmon : const Color(0xFFDDD8D2),
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
