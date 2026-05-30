import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

enum SortOption { rating, prepTime, name }

class FilterOptions {
  final SortOption sortBy;
  final int? maxMinutes;
  final Set<String> dietaryTags;

  const FilterOptions({
    this.sortBy = SortOption.rating,
    this.maxMinutes,
    this.dietaryTags = const {},
  });

  bool get isDefault =>
      sortBy == SortOption.rating &&
      maxMinutes == null &&
      dietaryTags.isEmpty;

  FilterOptions copyWith({
    SortOption? sortBy,
    int? maxMinutes,
    bool clearMaxMinutes = false,
    Set<String>? dietaryTags,
  }) =>
      FilterOptions(
        sortBy: sortBy ?? this.sortBy,
        maxMinutes:
            clearMaxMinutes ? null : (maxMinutes ?? this.maxMinutes),
        dietaryTags: dietaryTags ?? Set.unmodifiable(this.dietaryTags),
      );
}

class FilterSheet extends StatefulWidget {
  final FilterOptions current;

  const FilterSheet({super.key, required this.current});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late SortOption _sortBy;
  late int? _maxMinutes;
  late Set<String> _dietaryTags;

  static const _dietaryOptions = [
    'Vegan',
    'Vegetarian',
    'Gluten-Free',
    'Dairy-Free',
  ];

  static const _timeOptions = <String, int?>{
    'Any time': null,
    '≤ 15 min': 15,
    '15 – 30 min': 30,
    '≤ 60 min': 60,
  };

  @override
  void initState() {
    super.initState();
    _sortBy = widget.current.sortBy;
    _maxMinutes = widget.current.maxMinutes;
    _dietaryTags = Set.from(widget.current.dietaryTags);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 22,
        right: 22,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.chipBg,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter & Sort',
                    style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _sortBy = SortOption.rating;
                      _maxMinutes = null;
                      _dietaryTags = {};
                    });
                  },
                  child: Text('Reset',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Sort by
            _sectionLabel('Sort by'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _sortChip('Top Rated', SortOption.rating),
                _sortChip('Fastest', SortOption.prepTime),
                _sortChip('A → Z', SortOption.name),
              ],
            ),
            const SizedBox(height: 22),

            // Prep time
            _sectionLabel('Prep Time'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeOptions.entries
                  .map((e) => _timeChip(e.key, e.value))
                  .toList(),
            ),
            const SizedBox(height: 22),

            // Dietary
            _sectionLabel('Dietary'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _dietaryOptions.map((d) => _dietaryChip(d)).toList(),
            ),
            const SizedBox(height: 28),

            // Apply button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(
                    context,
                    FilterOptions(
                      sortBy: _sortBy,
                      maxMinutes: _maxMinutes,
                      dietaryTags: Set.unmodifiable(_dietaryTags),
                    )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text('Apply Filters',
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(label,
      style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
          letterSpacing: 1.0));

  Widget _sortChip(String label, SortOption opt) {
    final selected = _sortBy == opt;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = opt),
      child: _chip(label, selected),
    );
  }

  Widget _timeChip(String label, int? minutes) {
    final selected = _maxMinutes == minutes;
    return GestureDetector(
      onTap: () => setState(() => _maxMinutes = minutes),
      child: _chip(label, selected),
    );
  }

  Widget _dietaryChip(String label) {
    final selected = _dietaryTags.contains(label);
    return GestureDetector(
      onTap: () => setState(() {
        if (selected) {
          _dietaryTags.remove(label);
        } else {
          _dietaryTags.add(label);
        }
      }),
      child: _chip(label, selected),
    );
  }

  Widget _chip(String label, bool selected) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.chipBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected
                  ? AppColors.primary
                  : Colors.transparent),
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textMid)),
      );
}
