import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/home/home_state.dart';
import '../data/cooking_history.dart';
import '../utils/colors.dart';
import '../widgets/app_remote_image.dart';
import '../widgets/cooking_timer.dart';

class StartCookingScreen extends StatefulWidget {
  final FoodItemData recipe;

  const StartCookingScreen({super.key, required this.recipe});

  @override
  State<StartCookingScreen> createState() => _StartCookingScreenState();
}

class _StartCookingScreenState extends State<StartCookingScreen> {
  int _stepIndex = 0;
  final Set<String> _checked = {};
  bool _finished = false;

  List<RecipeStep> get _steps => widget.recipe.steps;
  RecipeStep get _current => _steps[_stepIndex];
  bool get _isLast => _stepIndex == _steps.length - 1;

  void _toggleIngredient(String ing) {
    setState(() {
      if (_checked.contains(ing)) {
        _checked.remove(ing);
      } else {
        _checked.add(ing);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_steps.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Start Cooking')),
        body: const Center(child: Text('No steps available.')),
      );
    }

    if (_finished) return _buildFinished(context);
    return _buildCooking(context);
  }

  Widget _buildFinished(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 20),
              Text('Dish Complete!',
                style: GoogleFonts.playfairDisplay(fontSize: 28, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text("You've finished cooking\n",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight, height: 1.75)),
              Text(widget.recipe.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              Text('\nTime to enjoy your meal!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight, height: 1.75)),
              const SizedBox(height: 24),
              ClipOval(
                child: SizedBox(
                  width: 88, height: 88,
                  child: AppRemoteImage(imageUrl: widget.recipe.imageUrl),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  shadowColor: AppColors.primary.withValues(alpha: 0.5),
                  elevation: 6,
                ),
                child: Text('Back to Recipe',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCooking(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Top bar (dark, immersive) ──
          Container(
            color: AppColors.textDark,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 20, right: 20, bottom: 14,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Text('NOW COOKING',
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.white.withValues(alpha: 0.5), letterSpacing: 1.0)),
                        const SizedBox(height: 2),
                        SizedBox(
                          width: 180,
                          child: Text(widget.recipe.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text('${_stepIndex + 1}/${_steps.length}',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.55))),
                  ],
                ),
                const SizedBox(height: 10),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: (_stepIndex + 1) / _steps.length,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentSalmon),
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step dot indicators
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_steps.length, (i) => GestureDetector(
                          onTap: () => setState(() => _stepIndex = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3.5),
                            width: i == _stepIndex ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i <= _stepIndex ? AppColors.primary : AppColors.chipBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        )),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Step header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDeep],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text('${_stepIndex + 1}',
                            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('STEP ${_stepIndex + 1} OF ${_steps.length}',
                              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1.0)),
                            const SizedBox(height: 3),
                            Text(_current.title,
                              style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.25)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Duration pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1EB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_rounded, color: AppColors.accentSalmon, size: 14),
                        const SizedBox(width: 6),
                        Text(_current.duration,
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentSalmon)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Step countdown timer
                  CookingTimer(
                    key: ValueKey('timer_$_stepIndex'),
                    duration: _current.duration,
                    onComplete: () {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Step ${_stepIndex + 1} done! ✓',
                              style: GoogleFonts.poppins(fontSize: 13)),
                          backgroundColor: AppColors.primary,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  // Step description
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.bgMuted,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(_current.description,
                      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textDark, height: 1.8)),
                  ),
                  const SizedBox(height: 18),

                  // Ingredient checklist (first step only)
                  if (_stepIndex == 0 && widget.recipe.ingredients.isNotEmpty) ...[
                    Text('GATHER YOUR INGREDIENTS',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1.0)),
                    const SizedBox(height: 10),
                    ...widget.recipe.ingredients.map((ing) {
                      final isChecked = _checked.contains(ing);
                      return GestureDetector(
                        onTap: () => _toggleIngredient(ing),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isChecked ? AppColors.primary.withValues(alpha: 0.35) : const Color(0x14000000),
                            ),
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 20, height: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isChecked ? AppColors.primary : const Color(0xFFD8D3CE),
                                    width: 2,
                                  ),
                                  color: isChecked ? AppColors.primary : Colors.transparent,
                                ),
                                child: isChecked
                                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Text(ing,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isChecked ? AppColors.textLight : AppColors.textDark,
                                  decoration: isChecked ? TextDecoration.lineThrough : null,
                                )),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),

          // ── Prev / Next navigation ──
          Padding(
            padding: EdgeInsets.only(
              left: 20, right: 20, bottom: MediaQuery.of(context).padding.bottom + 16, top: 0,
            ),
            child: Row(
              children: [
                if (_stepIndex > 0) ...[
                  GestureDetector(
                    onTap: () => setState(() => _stepIndex--),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.bgMuted,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textMid),
                          const SizedBox(width: 6),
                          Text('Prev',
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMid)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_isLast) {
                        CookingHistory.recordCooked(widget.recipe);
                        setState(() => _finished = true);
                      } else {
                        setState(() => _stepIndex++);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isLast
                              ? [AppColors.accentSalmon, const Color(0xFFC85A3C)]
                              : [AppColors.primary, AppColors.primaryDeep],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: (_isLast ? AppColors.accentSalmon : AppColors.primary).withValues(alpha: 0.4),
                            blurRadius: 16, offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _isLast
                              ? '🎉  Finish Cooking!'
                              : 'Next: ${_steps[_stepIndex + 1].title} →',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
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
  }
}
