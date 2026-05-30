import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/home/home_cubit.dart';
import '../bloc/home/home_state.dart';
import '../models/collection.dart';
import '../utils/colors.dart';
import '../widgets/app_remote_image.dart';
import 'recipe_detail_screen.dart';

class CollectionsScreen extends StatefulWidget {
  final Set<String> favourites;
  final void Function(String id) onToggleFav;

  const CollectionsScreen({
    super.key,
    required this.favourites,
    required this.onToggleFav,
  });

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  List<RecipeCollection> _collections = [];

  @override
  void initState() {
    super.initState();
    _collections = CollectionStorage.load();
  }

  Future<void> _createCollection() async {
    final name = await _showNameDialog(context, title: 'New Collection');
    if (name == null || name.trim().isEmpty) return;
    final c = await CollectionStorage.create(name);
    setState(() => _collections.add(c));
  }

  Future<void> _renameCollection(RecipeCollection c) async {
    final name =
        await _showNameDialog(context, title: 'Rename', initial: c.name);
    if (name == null || name.trim().isEmpty) return;
    final updated = c.copyWith(name: name.trim());
    await CollectionStorage.update(updated);
    setState(() {
      final i = _collections.indexWhere((x) => x.id == c.id);
      if (i >= 0) _collections[i] = updated;
    });
  }

  Future<void> _deleteCollection(RecipeCollection c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete "${c.name}"?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('This will not remove your favourites.',
            style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete',
                  style: TextStyle(color: AppColors.accentSalmon))),
        ],
      ),
    );
    if (confirm != true) return;
    await CollectionStorage.delete(c.id);
    setState(() => _collections.removeWhere((x) => x.id == c.id));
  }

  Future<String?> _showNameDialog(BuildContext context,
      {required String title, String initial = ''}) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'e.g. Quick Weeknight',
            hintStyle: GoogleFonts.poppins(
                fontSize: 14, color: AppColors.textLight),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.chipBg)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () =>
                  Navigator.pop(context, controller.text),
              child: Text('Save',
                  style: TextStyle(color: AppColors.primary))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                colors: [Color(0xFF4A3B30), AppColors.textDark],
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
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 16),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('YOUR COLLECTION',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.45),
                              letterSpacing: 1.0)),
                      const SizedBox(height: 4),
                      Text('Collections',
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Content ──
          Expanded(
            child: _collections.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    itemCount: _collections.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) =>
                        _CollectionTile(
                          collection: _collections[i],
                          favourites: widget.favourites,
                          onToggleFav: widget.onToggleFav,
                          onRename: () => _renameCollection(_collections[i]),
                          onDelete: () => _deleteCollection(_collections[i]),
                          onUpdated: (updated) => setState(() => _collections[i] = updated),
                        ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createCollection,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('New Collection',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bookmark_border_rounded,
                size: 52, color: AppColors.chipBg),
            const SizedBox(height: 16),
            Text('No collections yet',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 6),
            Text(
                'Create a collection to group your\nfavourite recipes by theme.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textLight, height: 1.7)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _createCollection,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text('Create Collection',
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Collection tile ──────────────────────────────────────────────────────────

class _CollectionTile extends StatelessWidget {
  final RecipeCollection collection;
  final Set<String> favourites;
  final void Function(String id) onToggleFav;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final void Function(RecipeCollection updated) onUpdated;

  const _CollectionTile({
    required this.collection,
    required this.favourites,
    required this.onToggleFav,
    required this.onRename,
    required this.onDelete,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<HomeCubit>(),
            child: _CollectionDetailScreen(
              collection: collection,
              favourites: favourites,
              onToggleFav: onToggleFav,
              onUpdated: onUpdated,
            ),
          ),
        ),
      ),
      onLongPress: () => _showOptions(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: AppColors.textDark.withValues(alpha: 0.07),
                blurRadius: 12,
                offset: const Offset(0, 2))
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.bgMuted,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.bookmark_rounded,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(collection.name,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(
                      '${collection.recipeIds.length} recipe${collection.recipeIds.length != 1 ? 's' : ''}',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textLight)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textLight, size: 20),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.chipBg,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.edit_rounded,
                  color: AppColors.textMid),
              title: Text('Rename',
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                onRename();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded,
                  color: AppColors.accentSalmon),
              title: Text('Delete',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accentSalmon)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Collection detail (recipe list inside a collection) ─────────────────────

class _CollectionDetailScreen extends StatefulWidget {
  final RecipeCollection collection;
  final Set<String> favourites;
  final void Function(String id) onToggleFav;
  final void Function(RecipeCollection updated) onUpdated;

  const _CollectionDetailScreen({
    required this.collection,
    required this.favourites,
    required this.onToggleFav,
    required this.onUpdated,
  });

  @override
  State<_CollectionDetailScreen> createState() =>
      _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<_CollectionDetailScreen> {
  late RecipeCollection _collection;

  @override
  void initState() {
    super.initState();
    _collection = widget.collection;
  }

  Future<void> _removeRecipe(String recipeId) async {
    final updated = _collection.copyWith(
        recipeIds: _collection.recipeIds
            .where((id) => id != recipeId)
            .toList());
    await CollectionStorage.update(updated);
    setState(() => _collection = updated);
    widget.onUpdated(updated);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final allItems =
            state is HomeLoaded ? state.foodItems : <FoodItemData>[];
        final items = allItems
            .where((r) => _collection.recipeIds.contains(r.title))
            .toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // Header
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4A3B30), AppColors.textDark],
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
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('COLLECTION',
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color:
                                      Colors.white.withValues(alpha: 0.45),
                                  letterSpacing: 1.0)),
                          const SizedBox(height: 4),
                          Text(_collection.name,
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 22,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text('${items.length}',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bookmark_border_rounded,
                                  size: 48, color: AppColors.chipBg),
                              const SizedBox(height: 14),
                              Text('Empty collection',
                                  style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark)),
                              const SizedBox(height: 6),
                              Text(
                                  'Bookmark recipes from any detail\npage to add them here.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textLight,
                                      height: 1.7)),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (ctx, i) {
                          final item = items[i];
                          return Dismissible(
                            key: ValueKey(item.title),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              decoration: BoxDecoration(
                                color: AppColors.accentSalmon
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.remove_circle_outline,
                                  color: AppColors.accentSalmon),
                            ),
                            onDismissed: (_) =>
                                _removeRecipe(item.title),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                ctx,
                                MaterialPageRoute(
                                  builder: (_) => RecipeDetailScreen(
                                    foodItem: item,
                                    isFav: widget.favourites
                                        .contains(item.title),
                                    onToggleFav: () =>
                                        widget.onToggleFav(item.title),
                                  ),
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                        color: AppColors.textDark
                                            .withValues(alpha: 0.07),
                                        blurRadius: 12,
                                        offset: const Offset(0, 2))
                                  ],
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                      child: SizedBox(
                                        width: 72,
                                        height: 72,
                                        child: AppRemoteImage(
                                            imageUrl: item.imageUrl),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item.title,
                                              maxLines: 2,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                  color: AppColors.textDark,
                                                  height: 1.3)),
                                          const SizedBox(height: 4),
                                          Text(item.category,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: AppColors.textLight)),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                  Icons.star_rounded,
                                                  color: AppColors.accentAmber,
                                                  size: 12),
                                              const SizedBox(width: 3),
                                              Text(
                                                  item.rating.toString(),
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors.textMid)),
                                              const SizedBox(width: 10),
                                              const Icon(
                                                  Icons
                                                      .access_time_rounded,
                                                  size: 11,
                                                  color: AppColors.textLight),
                                              const SizedBox(width: 3),
                                              Text(item.prepTime,
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      color: AppColors.textLight)),
                                            ],
                                          ),
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
            ],
          ),
        );
      },
    );
  }
}
