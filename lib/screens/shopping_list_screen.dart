import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/shopping/shopping_cubit.dart';
import '../bloc/shopping/shopping_state.dart';
import '../models/shopping_item.dart';
import '../utils/colors.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShoppingCubit, ShoppingState>(
      builder: (context, state) {
        // Group items by recipe
        final Map<String, List<ShoppingItem>> grouped = {};
        for (final item in state.items) {
          grouped.putIfAbsent(item.recipeTitle, () => []).add(item);
        }
        final checkedCount = state.items.where((i) => i.isChecked).length;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 20,
                  right: 20,
                  bottom: 16,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFEDE8E3), width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Shopping List',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (state.items.isNotEmpty)
                          TextButton.icon(
                            onPressed: () =>
                                context.read<ShoppingCubit>().clearAll(),
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 16),
                            label: Text('Clear all',
                                style: GoogleFonts.poppins(fontSize: 12)),
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.accentSalmon),
                          ),
                      ],
                    ),
                    if (state.items.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '$checkedCount / ${state.items.length} items checked',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.textLight),
                      ),
                    ],
                  ],
                ),
              ),

              // Body
              Expanded(
                child: state.items.isEmpty
                    ? _buildEmptyState(context)
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        children: [
                          ...grouped.entries.map(
                            (entry) => _buildRecipeGroup(
                              context,
                              recipeTitle: entry.key,
                              items: entry.value,
                            ),
                          ),
                          if (checkedCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 4),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => context
                                      .read<ShoppingCubit>()
                                      .removeChecked(),
                                  icon: const Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 16),
                                  label: Text(
                                    'Remove $checkedCount checked',
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(
                                        color: AppColors.primary),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.bgMuted,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.shopping_cart_outlined,
                  size: 36, color: AppColors.textLight),
            ),
            const SizedBox(height: 20),
            Text(
              'Your list is empty',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Open a recipe and tap "Add to Shopping List" to add ingredients here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textLight, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeGroup(
    BuildContext context, {
    required String recipeTitle,
    required List<ShoppingItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
          child: Text(
            recipeTitle,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: items
                .asMap()
                .entries
                .map((e) => _buildItemTile(context, e.value,
                    isLast: e.key == items.length - 1))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildItemTile(
    BuildContext context,
    ShoppingItem item, {
    required bool isLast,
  }) {
    return InkWell(
      onTap: () => context.read<ShoppingCubit>().toggleItem(item.id),
      borderRadius: isLast
          ? const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16))
          : BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: item.isChecked ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: item.isChecked
                      ? AppColors.primary
                      : AppColors.textLight,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: item.isChecked
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.ingredient,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: item.isChecked
                      ? AppColors.textLight
                      : AppColors.textDark,
                  decoration: item.isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
