import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/sync_service.dart';
import '../utils/colors.dart';
import '../bloc/home/home_cubit.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'favourites_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late Set<String> _favourites;

  @override
  void initState() {
    super.initState();
    _loadFavourites();
  }

  Future<void> _loadFavourites() async {
    final syncService = context.read<SyncService>();
    final favs = await syncService.loadFavourites();
    if (mounted) setState(() => _favourites = favs);
  }

  void _toggleFav(String id) {
    setState(() {
      if (_favourites.contains(id)) {
        _favourites.remove(id);
      } else {
        _favourites.add(id);
      }
    });
    context.read<SyncService>().saveFavourites(_favourites);
  }

  void _goToTab(int index) => setState(() => _currentIndex = index);

  void _goToSearch() {
    final cubit = context.read<HomeCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: SearchScreen(
            favourites: Set.unmodifiable(_favourites),
            onToggleFav: _toggleFav,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabScreens = [
      HomeScreen(
        favourites: Set.unmodifiable(_favourites),
        onToggleFav: _toggleFav,
        onSearchTap: _goToSearch,
      ),
      FavouritesScreen(
        favourites: Set.unmodifiable(_favourites),
        onToggleFav: _toggleFav,
        onTabChange: _goToTab,
      ),
      ProfileScreen(favouriteCount: _favourites.length),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _currentIndex,
        children: tabScreens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToSearch,
        backgroundColor: AppColors.primary,
        elevation: 6,
        child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      elevation: 8,
      child: SizedBox(
        height: 62,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(icon: Icons.home_rounded, label: 'Home', index: 0),
            _navItem(icon: Icons.search_rounded, label: 'Search', tabIndex: -1),
            const SizedBox(width: 56),
            _navItem(
              icon: Icons.favorite_rounded,
              label: 'Saved',
              index: 1,
              badge: _favourites.length,
            ),
            _navItem(icon: Icons.person_rounded, label: 'Profile', index: 2),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    int index = -1,
    int tabIndex = 0,
    int badge = 0,
  }) {
    final isSearch = index == -1;
    final isActive = !isSearch && _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (isSearch) {
          _goToSearch();
        } else {
          _goToTab(index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: isActive ? AppColors.primary : Colors.grey.shade400, size: 24),
                if (badge > 0)
                  Positioned(
                    top: -4, right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: AppColors.accentSalmon, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(
                        '$badge',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.primary : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}