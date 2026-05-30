import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home/home_cubit.dart';
import '../bloc/home/home_state.dart';
import '../data/search_history.dart';
import '../utils/colors.dart';
import '../widgets/app_remote_image.dart';
import '../widgets/filter_sheet.dart';
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
  List<String> _recentSearches = [];
  FilterOptions _filters = const FilterOptions();

  final List<_CategoryTile> _categoryTiles = const [
    _CategoryTile(label: 'Breakfast', imageUrl: 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=400&auto=format&fit=crop&q=80'),
    _CategoryTile(label: 'Dinner',    imageUrl: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=400&auto=format&fit=crop&q=80'),
    _CategoryTile(label: 'Drinks',    imageUrl: 'https://images.unsplash.com/photo-1517705008128-361805f42e86?w=400&auto=format&fit=crop&q=80'),
    _CategoryTile(label: 'Soup',      imageUrl: 'https://images.unsplash.com/photo-1547592180-85f173990554?w=400&auto=format&fit=crop&q=80'),
  ];

  @override
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final history = await SearchHistory.load();
    if (mounted) setState(() => _recentSearches = history);
  }

  Future<void> _submitSearch(String q) async {
    if (q.trim().isEmpty) return;
    await SearchHistory.add(q.trim());
    _loadHistory();
  }

  Future<void> _removeHistoryItem(String q) async {
    await SearchHistory.remove(q);
    _loadHistory();
  }

  Future<void> _clearHistory() async {
    await SearchHistory.clear();
    setState(() => _recentSearches = []);
  }

  int? _parsePrepMinutes(String prepTime) {
    final match = RegExp(r'(\d+)').firstMatch(prepTime);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  bool _matchesDietary(FoodItemData item, String tag) {
    final ingredients = item.ingredients.map((i) => i.toLowerCase()).toList();
    switch (tag) {
      case 'Vegan':
        const nonVegan = [
          'milk', 'cream', 'butter', 'egg', 'chicken', 'beef', 'pork',
          'fish', 'shrimp', 'tuna', 'salmon', 'cheese', 'yogurt', 'honey',
          'lard', 'gelatin'
        ];
        return !ingredients.any((i) => nonVegan.any((nv) => i.contains(nv)));
      case 'Vegetarian':
        const nonVeg = [
          'chicken', 'beef', 'pork', 'fish', 'shrimp', 'tuna', 'salmon',
          'lamb', 'turkey', 'bacon', 'pepperoni', 'anchov'
        ];
        return !ingredients.any((i) => nonVeg.any((nv) => i.contains(nv)));
      case 'Gluten-Free':
        const gluten = [
          'wheat', 'flour', 'bread', 'pasta', 'barley', 'rye', 'soy sauce',
          'semolina', 'panko', 'breadcrumb'
        ];
        return !ingredients.any((i) => gluten.any((g) => i.contains(g)));
      case 'Dairy-Free':
        const dairy = [
          'milk', 'cream', 'butter', 'cheese', 'yogurt', 'whey', 'lactose'
        ];
        return !ingredients.any((i) => dairy.any((d) => i.contains(d)));
      default:
        return true;
    }
  }

  List<FoodItemData> _getResults(List<FoodItemData> all) {
    if (_query.isEmpty && _filters.isDefault) return [];
    List<FoodItemData> results = List.of(all);

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      results = results
          .where((r) =>
              r.title.toLowerCase().contains(q) ||
              r.category.toLowerCase().contains(q) ||
              r.ingredients.any((i) => i.toLowerCase().contains(q)))
          .toList();
    }

    if (_filters.maxMinutes != null) {
      results = results.where((r) {
        final mins = _parsePrepMinutes(r.prepTime);
        return mins != null && mins <= _filters.maxMinutes!;
      }).toList();
    }

    for (final tag in _filters.dietaryTags) {
      results = results.where((r) => _matchesDietary(r, tag)).toList();
    }

    switch (_filters.sortBy) {
      case SortOption.rating:
        results.sort((a, b) => b.rating.compareTo(a.rating));
      case SortOption.prepTime:
        results.sort((a, b) {
          final am = _parsePrepMinutes(a.prepTime) ?? 999;
          final bm = _parsePrepMinutes(b.prepTime) ?? 999;
          return am.compareTo(bm);
        });
      case SortOption.name:
        results.sort((a, b) => a.title.compareTo(b.title));
    }
    return results;
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

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<FilterOptions>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => FilterSheet(current: _filters),
    );
    if (result != null && mounted) setState(() => _filters = result);
  }

  String _sortLabel(SortOption opt) {
    switch (opt) {
      case SortOption.rating:
        return 'Top Rated';
      case SortOption.prepTime:
        return 'Fastest';
      case SortOption.name:
        return 'A → Z';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final allItems = state is HomeLoaded ? state.foodItems : <FoodItemData>[];
          final results = _getResults(allItems);
          final showResults = _query.isNotEmpty || !_filters.isDefault;

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
                  bottom: 14,
                ),
                child: Column(
                  children: [
                Row(
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
                    const SizedBox(width: 10),
                    // Filter button
                    GestureDetector(
                      onTap: _openFilterSheet,
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: _filters.isDefault
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: _filters.isDefault ? Colors.white : AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                    // Active filter chips
                    if (!_filters.isDefault) ...[                
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (_filters.sortBy != SortOption.rating)
                              _activeChip(_sortLabel(_filters.sortBy),
                                onRemove: () => setState(() => _filters = _filters.copyWith(sortBy: SortOption.rating))),
                            if (_filters.maxMinutes != null)
                              _activeChip('≤ \${_filters.maxMinutes} min',
                                onRemove: () => setState(() => _filters = _filters.copyWith(clearMaxMinutes: true))),
                            ..._filters.dietaryTags.map((tag) => _activeChip(tag,
                              onRemove: () => setState(() {
                                final tags = Set<String>.from(_filters.dietaryTags)..remove(tag);
                                _filters = _filters.copyWith(dietaryTags: tags);
                              }))),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Content ──
              Expanded(
                child: !showResults
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

  Widget _activeChip(String label, {required VoidCallback onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 12, color: AppColors.primary),
          ),
        ],
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
          if (_recentSearches.isNotEmpty) ...[  
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('RECENT SEARCHES',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1.0)),
                GestureDetector(
                  onTap: _clearHistory,
                  child: Text('Clear all',
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((s) => GestureDetector(
                onTap: () {
                  _controller.text = s;
                  setState(() => _query = s);
                  _submitSearch(s);
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
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _removeHistoryItem(s),
                        child: const Icon(Icons.close_rounded, size: 12, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 28),
          ],

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
                _submitSearch(cat.label);
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
    final label = _query.isNotEmpty
        ? '${results.length} RESULT${results.length != 1 ? 'S' : ''} FOR "${_query.toUpperCase()}"'
        : '${results.length} RECIPE${results.length != 1 ? 'S' : ''} FOUND';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        Text(label,
          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1.0)),
        const SizedBox(height: 14),
        ...results.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _RecipeListCard(
            item: item,
            isFav: widget.favourites.contains(item.title),
            onToggleFav: () => widget.onToggleFav(item.title),
            onTap: () {
              if (_query.isNotEmpty) _submitSearch(_query);
              _openRecipe(context, item);
            },
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
            Text('Try adjusting your filters or\nsearch for a different recipe.',
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
