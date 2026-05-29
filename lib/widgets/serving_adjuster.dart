import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

/// A +/- widget to adjust serving count.
/// [initialServings] is parsed from the recipe's `servings` string.
/// [onChanged] fires with the new integer serving count.
class ServingAdjuster extends StatefulWidget {
  final String initialServings;
  final ValueChanged<int> onChanged;

  const ServingAdjuster({
    super.key,
    required this.initialServings,
    required this.onChanged,
  });

  @override
  State<ServingAdjuster> createState() => _ServingAdjusterState();
}

class _ServingAdjusterState extends State<ServingAdjuster> {
  late int _servings;
  late int _base;

  @override
  void initState() {
    super.initState();
    _base = int.tryParse(
            RegExp(r'\d+').firstMatch(widget.initialServings)?.group(0) ??
                '2') ??
        2;
    _servings = _base;
  }

  void _adjust(int delta) {
    final next = (_servings + delta).clamp(1, 20);
    if (next == _servings) return;
    setState(() => _servings = next);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Servings',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const Spacer(),
        _StepButton(icon: Icons.remove_rounded, onTap: () => _adjust(-1)),
        const SizedBox(width: 12),
        Text(
          '$_servings',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        _StepButton(icon: Icons.add_rounded, onTap: () => _adjust(1)),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.bgMuted,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}

/// Scales an ingredient string's leading number by [multiplier].
/// e.g. "2 cups flour" × 1.5 → "3.0 cups flour"
String scaleIngredient(String ingredient, double multiplier) {
  if (multiplier == 1.0) return ingredient;
  final match = RegExp(r'^(\d+(?:\.\d+)?)(.*)').firstMatch(ingredient);
  if (match == null) return ingredient;
  final amount = double.parse(match.group(1)!);
  final scaled = amount * multiplier;
  final formatted =
      scaled == scaled.roundToDouble() ? scaled.toInt().toString() : scaled.toStringAsFixed(1);
  return '$formatted${match.group(2)!}';
}
