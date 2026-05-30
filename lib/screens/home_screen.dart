import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../widgets/app_remote_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home/home_cubit.dart';
import '../bloc/home/home_state.dart';
import '../bloc/auth/auth_cubit.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/recommendations/recommendations_cubit.dart';
import '../bloc/recommendations/recommendations_state.dart';
import '../widgets/skeleton_card.dart';
import 'category_menu_screen.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final Set<String> favourites;
  final void Function(String id) onToggleFav;
  final VoidCallback onSearchTap;

  const HomeScreen({
    super.key,
    required this.favourites,
    required this.onToggleFav,
    required this.onSearchTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _activeCategory = 'All';
  final List<String> _categories = ['All', 'Soup', 'Breakfast', 'Drinks', 'Dinner'];
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.favourites != widget.favourites) {
      final state = context.read<HomeCubit>().state;
      if (state is HomeLoaded) {
        context.read<RecommendationsCubit>().compute(
          allItems: state.foodItems,
          favourites: widget.favourites,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      context.read<HomeCubit>().loadMore();
    }
  }

  void _openCategory(BuildContext context, String category, List<FoodItemData> items) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryMenuScreen(
          categoryTitle: category,
          foodItems: items,
          favourites: widget.favourites,
          onToggleFav: widget.onToggleFav,
        ),
      ),
    );
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
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(child: SkeletonFeedList()),
          );
        }
        if (state is HomeError) {
          return Scaffold(body: Center(child: Text(state.message)));
        }
        if (state is! HomeLoaded) return const Scaffold();

        final allItems = state.foodItems;
        final filtered = _activeCategory == 'All'
            ? allItems
            : allItems.where((r) => r.category == _activeCategory).toList();
        final featured = allItems.isNotEmpty ? allItems.first : null;
        final listItems = _activeCategory == 'All'
            ? (allItems.length > 1 ? allItems.skip(1).toList() : <FoodItemData>[])
            : filtered;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // ── App bar / header ──
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryDeep, AppColors.primary],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 20, right: 20, bottom: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting row
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, authState) {
                          final user = authState is AuthAuthenticated ? authState.user : null;
                          final name = user?.displayName.split(' ').first ?? 'Chef';
                          final photoUrl = user?.photoUrl ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&auto=format&fit=crop&q=60';
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Good morning',
                                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withValues(alpha: 0.65))),
                                  Row(
                                    children: [
                                      Text('Hi, $name',
                                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                                      const SizedBox(width: 6),
                                      const Text('👋', style: TextStyle(fontSize: 20)),
                                    ],
                                  ),
                                ],
                              ),
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.secondary,
                                child: ClipOval(
                                  child: AppRemoteImage(
                                    imageUrl: photoUrl,
                                    width: 40, height: 40,
                                    fallback: const Icon(Icons.person_rounded, color: AppColors.textMid, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(fontSize: 15, color: Colors.white.withValues(alpha: 0.85), height: 1.4),
                          children: [
                            const TextSpan(text: 'Craving something\n'),
                            TextSpan(text: 'delicious', style: GoogleFonts.poppins(fontSize: 15, fontStyle: FontStyle.italic, fontWeight: FontWeight.w300, color: Colors.white.withValues(alpha: 0.85))),
                            const TextSpan(text: ' today?'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tappable search bar
                      GestureDetector(
                        onTap: widget.onSearchTap,
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 14),
                              Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('Find something delicious…',
                                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400)),
                              ),
                              Container(
                                width: 32, height: 32,
                                margin: const EdgeInsets.only(right: 7),
                                decoration: BoxDecoration(color: AppColors.bgMuted, borderRadius: BorderRadius.circular(9)),
                                child: const Icon(Icons.tune_rounded, size: 16, color: AppColors.textMid),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Category chips ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 0, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isActive = _activeCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _activeCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.primary : AppColors.chipBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(cat,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive ? Colors.white : AppColors.textMid,
                                )),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // ── Content ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Featured recipe (All tab only)
                      if (_activeCategory == 'All' && featured != null) ...[
                        Text('\u2736  Featured Recipe',
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                        const SizedBox(height: 12),
                        _buildFeaturedCard(context, featured),
                        const SizedBox(height: 24),
                      ],

                      // Recommendations (All tab only)
                      if (_activeCategory == 'All')
                        BlocListener<HomeCubit, HomeState>(
                          listenWhen: (prev, next) => next is HomeLoaded && prev is! HomeLoaded,
                          listener: (ctx, homeState) {
                            if (homeState is HomeLoaded) {
                              ctx.read<RecommendationsCubit>().compute(
                                allItems: homeState.foodItems,
                                favourites: widget.favourites,
                              );
                            }
                          },
                          child: BlocBuilder<RecommendationsCubit, RecommendationsState>(
                            builder: (ctx, recState) {
                              if (recState is! RecommendationsLoaded || recState.items.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('You might like',
                                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.auto_awesome_rounded, color: AppColors.accentAmber, size: 18),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 200,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: recState.items.length,
                                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                                      itemBuilder: (ctx, i) {
                                        final rec = recState.items[i];
                                        return GestureDetector(
                                          onTap: () => _openRecipe(context, rec),
                                          child: SizedBox(
                                            width: 150,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(18),
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  AppRemoteImage(imageUrl: rec.imageUrl),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin: Alignment.topCenter,
                                                        end: Alignment.bottomCenter,
                                                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.72)],
                                                        stops: const [0.4, 1.0],
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 10, right: 10,
                                                    child: GestureDetector(
                                                      onTap: () => widget.onToggleFav(rec.title),
                                                      child: Container(
                                                        width: 30, height: 30,
                                                        decoration: BoxDecoration(
                                                          color: Colors.black.withValues(alpha: 0.3),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                          widget.favourites.contains(rec.title)
                                                              ? Icons.favorite_rounded
                                                              : Icons.favorite_border_rounded,
                                                          color: widget.favourites.contains(rec.title)
                                                              ? AppColors.accentSalmon
                                                              : Colors.white,
                                                          size: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 10, left: 10, right: 10,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(rec.title,
                                                          maxLines: 2,
                                                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, height: 1.3)),
                                                        const SizedBox(height: 4),
                                                        Row(children: [
                                                          const Icon(Icons.star_rounded, color: AppColors.accentAmber, size: 11),
                                                          const SizedBox(width: 3),
                                                          Text(rec.rating.toString(),
                                                            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                                                        ]),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              );
                            },
                          ),
                        ),

                      // Section header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                _activeCategory == 'All' ? "What's Cooking Now" : _activeCategory,
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                              ),
                              if (_activeCategory == 'All') ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.whatshot_rounded, color: AppColors.accentSalmon, size: 20),
                              ],
                            ],
                          ),
                          if (_activeCategory != 'All')
                            GestureDetector(
                              onTap: () => _openCategory(context, _activeCategory, listItems),
                              child: Text(
                                'View all →',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Recipe list
                      if (listItems.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text('No $_activeCategory recipes yet.',
                              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight)),
                          ),
                        )
                      else
                        ...listItems.map((item) => RepaintBoundary(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _buildRecipeCard(context, item),
                          ),
                        )),

                      // ── Load-more indicator ──
                      if (state.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (state.hasMore && listItems.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: TextButton(
                              onPressed: () => context.read<HomeCubit>().loadMore(),
                              child: Text(
                                'Load more recipes',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedCard(BuildContext context, FoodItemData item) {
    return GestureDetector(
      onTap: () => _openRecipe(context, item),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            SizedBox(
              height: 180, width: double.infinity,
              child: AppRemoteImage(imageUrl: item.imageUrl),
            ),
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                  stops: const [0.35, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Text(item.category.toUpperCase(),
                  style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.8)),
              ),
            ),
            Positioned(
              bottom: 14, left: 14, right: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ...List.generate(5, (i) => Icon(
                        i < item.rating.floor() ? Icons.star_rounded
                          : (i < item.rating ? Icons.star_half_rounded : Icons.star_outline_rounded),
                        color: AppColors.accentAmber, size: 13,
                      )),
                      const SizedBox(width: 5),
                      Text(item.rating.toString(),
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.85))),
                      const SizedBox(width: 6),
                      Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(item.prepTime,
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
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

  Widget _buildRecipeCard(BuildContext context, FoodItemData item) {
    final isFav = widget.favourites.contains(item.title);
    return GestureDetector(
      onTap: () => _openRecipe(context, item),
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
                    maxLines: 2, overflow: TextOverflow.ellipsis,
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
              onTap: () => widget.onToggleFav(item.title),
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
