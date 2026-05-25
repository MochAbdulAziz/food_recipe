import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home/home_cubit.dart';
import '../bloc/home/home_state.dart';
import '../utils/colors.dart';
import '../widgets/app_remote_image.dart';
import 'recipe_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final Set<String> favourites;
  final void Function(String id) onToggleFav;

  const SearchScreen({
    super.key,
    required this.favourites,
    required this.onToggleFav,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  final List<String> _recentSearches = [
    'Hot & Spicy Shrimp',
    'Katsu Curry',
    'Pancakes',
  ];

  final List<_CategoryTile> _categoryTiles = const [
    _CategoryTile(label: 'Breakfast', imageUrl: 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=400&auto=format&fit=crop&q=80'),
    _CategoryTile(label: 'Dinner',    imageUrl: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=400&auto=format&fit=crop&q=80'),
    _CategoryTile(label: 'Drinks',    imageUrl: 'https://images.unsplash.com/photo-1517705008128-361805f42e86?w=400&auto=format&fit=crop&q=80'),
    _CategoryTile(label: 'Soup',      imageUrl: 'https://images.unsplash.com/photo-1547592180-85f173990554?w=400&auto=format&fit=crop&q=80'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<FoodItemData> _getResults(List<FoodItemData> all) {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return all.where((r) =>
      r.title.toLowerCase().contains(q) ||
      r.category.toLowerCase().contains(q) ||
      r.ingredients.any((i) => i.toLowerCase().contains(q))
    ).toList();
  }

  void _openRecipe(BuildContext context, FoodItemData item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailScreen(
          foodItem: item,
          isFav: widget.favourites.contains(item.title),
          onToggleFav: () => widget.onToggleFav(item.title),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final allItems = state is HomeLoaded ? state.foodItems : <FoodItemData>[];
          final results = _getResults(allItems);

          return Column(
            children: [
              // ── Search header ──
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDeep, AppColors.primary],
                  ),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            const Icon(Icons.search_rounded, color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                autofocus: true,
                                onChanged: (v) => setState(() => _query = v),
                                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textDark),
                                decoration: InputDecoration(
                                  hintText: 'Find something delicious…',
                                  hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            if (_query.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _controller.clear();
                                  setState(() => _query = '');
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(Icons.close_rounded, size: 18, color: AppColors.textLight),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Content ──
              Expanded(
                child: _query.isEmpty
                    ? _buildBrowse(context)
                    : results.isEmpty
                        ? _buildEmpty()
                        : _buildResults(context, results),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBrowse(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          Text('RECENT SEARCHES',
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1.0)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((s) => GestureDetector(
              onTap: () {
                _controller.text = s;
                setState(() => _query = s);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x14000000)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history_rounded, size: 13, color: AppColors.textLight),
                    const SizedBox(width: 6),
                    Text(s, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMid)),
                  ],
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 28),

          // Popular categories
          Text('POPULAR CATEGORIES',
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1.0)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: _categoryTiles.map((cat) => GestureDetector(
              onTap: () {
                _controller.text = cat.label;
                setState(() => _query = cat.label);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppRemoteImage(imageUrl: cat.imageUrl),
                    Container(color: Colors.black.withValues(alpha: 0.38)),
                    Positioned(
                      bottom: 8, left: 10,
                      child: Text(cat.label,
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, List<FoodItemData> results) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        Text(
          '${results.length} RESULT${results.length != 1 ? 'S' : ''} FOR "${_query.toUpperCase()}"',
          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1.0),
        ),
        const SizedBox(height: 14),
        ...results.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _RecipeListCard(
            item: item,
            isFav: widget.favourites.contains(item.title),
            onToggleFav: () => widget.onToggleFav(item.title),
            onTap: () => _openRecipe(context, item),
          ),
        )),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 52, color: AppColors.chipBg),
            const SizedBox(height: 16),
            Text('Nothing found', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 6),
            Text('Try a recipe name, category,\nor ingredient like "garlic" or "eggs".',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight, height: 1.7)),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile {
  final String label;
  final String imageUrl;
  const _CategoryTile({required this.label, required this.imageUrl});
}

class _RecipeListCard extends StatelessWidget {
  final FoodItemData item;
  final bool isFav;
  final VoidCallback onToggleFav;
  final VoidCallback onTap;

  const _RecipeListCard({
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
              child: SizedBox(
                width: 88, height: 88,
                child: AppRemoteImage(imageUrl: item.imageUrl),
              ),
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
