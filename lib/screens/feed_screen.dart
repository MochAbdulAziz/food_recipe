import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth/auth_cubit.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/home/home_cubit.dart';
import '../bloc/home/home_state.dart';
import '../data/cooking_history.dart';
import '../models/recipe.dart';
import '../utils/colors.dart';
import '../widgets/app_remote_image.dart';
import 'recipe_detail_screen.dart';

class FeedScreen extends StatefulWidget {
  final Set<String> favourites;
  final void Function(String) onToggleFav;

  const FeedScreen({
    super.key,
    required this.favourites,
    required this.onToggleFav,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<_FeedEntry> _feed = [];

  static const _mockUsers = [
    _MockUser(
      'Sophie Chen',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop',
    ),
    _MockUser(
      'Marcus Lee',
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&auto=format&fit=crop',
    ),
    _MockUser(
      'Amara Osei',
      'https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?w=200&auto=format&fit=crop',
    ),
    _MockUser(
      'Luis Rivera',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _buildFeed();
  }

  @override
  void didUpdateWidget(FeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _buildFeed();
  }

  void _buildFeed() {
    final history = CookingHistory.getHistory();
    final authState = context.read<AuthCubit>().state;
    final myName = authState is AuthAuthenticated
        ? authState.user.displayName
        : 'You';
    final myPhoto = authState is AuthAuthenticated
        ? (authState.user.photoUrl ?? '')
        : '';

    final entries = <_FeedEntry>[];

    // My own cooking history
    for (final entry in history) {
      entries.add(_FeedEntry(
        userName: myName,
        avatarUrl: myPhoto,
        recipeTitle: entry.recipeTitle,
        imageUrl: entry.imageUrl,
        action: 'cooked',
        timestamp: entry.cookedAt,
        isMe: true,
      ));
    }

    // Mock community entries derived from the recipe catalogue
    final homeState = context.read<HomeCubit>().state;
    final allRecipes =
        homeState is HomeLoaded ? homeState.foodItems : <FoodItemData>[];
    final now = DateTime.now();
    for (int i = 0; i < allRecipes.length && i < 20; i++) {
      final recipe = allRecipes[i];
      final mockUser = _mockUsers[i % _mockUsers.length];
      entries.add(_FeedEntry(
        userName: mockUser.name,
        avatarUrl: mockUser.avatarUrl,
        recipeTitle: recipe.title,
        imageUrl: recipe.imageUrl,
        action: i % 3 == 0 ? 'saved' : 'cooked',
        timestamp: now.subtract(Duration(hours: (i + 1) * 3)),
        isMe: false,
      ));
    }

    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    setState(() => _feed = entries);
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(
                  top: 56, left: 20, right: 20, bottom: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.textDark, Color(0xFF4A3B30)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Community',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                    ),
                  ),
                  Text(
                    'See what others are cooking',
                    style: GoogleFonts.poppins(
                        color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          if (_feed.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people_outline_rounded,
                        size: 64, color: AppColors.textLight),
                    const SizedBox(height: 16),
                    Text(
                      'No activity yet.\nStart cooking to build your feed!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: AppColors.textLight, height: 1.6),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildFeedCard(_feed[i]),
                  childCount: _feed.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedCard(_FeedEntry entry) {
    final homeState = context.read<HomeCubit>().state;
    FoodItemData? recipe;
    if (homeState is HomeLoaded) {
      try {
        recipe =
            homeState.foodItems.firstWhere((r) => r.title == entry.recipeTitle);
      } catch (_) {}
    }

    return GestureDetector(
      onTap: recipe == null
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeDetailScreen(
                    foodItem: recipe!,
                    isFav: widget.favourites.contains(recipe.title),
                    onToggleFav: () => widget.onToggleFav(recipe!.title),
                  ),
                ),
              ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  _buildAvatar(entry),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: AppColors.textDark),
                            children: [
                              TextSpan(
                                text: entry.isMe ? 'You' : entry.userName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: ' ${entry.action} ',
                                style: const TextStyle(
                                    color: AppColors.textMid),
                              ),
                              TextSpan(
                                text: entry.recipeTitle,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _timeAgo(entry.timestamp),
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                  _buildActionChip(entry.action),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: AppRemoteImage(
                imageUrl: entry.imageUrl,
                height: 160,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(String action) {
    final isCook = action == 'cooked';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCook ? const Color(0xFFFFF0EC) : AppColors.bgMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCook
                ? Icons.outdoor_grill_rounded
                : Icons.bookmark_rounded,
            size: 12,
            color: isCook ? AppColors.accentSalmon : AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            action,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isCook ? AppColors.accentSalmon : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(_FeedEntry entry) {
    if (entry.avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.chipBg,
        child: ClipOval(
          child: AppRemoteImage(
              imageUrl: entry.avatarUrl, width: 40, height: 40),
        ),
      );
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.chipBg,
      child: Text(
        entry.userName.isNotEmpty ? entry.userName[0].toUpperCase() : '?',
        style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, color: AppColors.textMid),
      ),
    );
  }
}

class _FeedEntry {
  final String userName;
  final String avatarUrl;
  final String recipeTitle;
  final String imageUrl;
  final String action;
  final DateTime timestamp;
  final bool isMe;

  const _FeedEntry({
    required this.userName,
    required this.avatarUrl,
    required this.recipeTitle,
    required this.imageUrl,
    required this.action,
    required this.timestamp,
    required this.isMe,
  });
}

class _MockUser {
  final String name;
  final String avatarUrl;
  const _MockUser(this.name, this.avatarUrl);
}
