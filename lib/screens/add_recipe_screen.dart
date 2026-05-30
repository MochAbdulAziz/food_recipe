import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/submit/submit_cubit.dart';
import '../models/recipe.dart';
import '../utils/colors.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _prepTimeCtrl = TextEditingController(text: '30 Min');
  final _servingsCtrl = TextEditingController(text: '2');
  final _caloriesCtrl = TextEditingController(text: '0 kcal');
  final _proteinsCtrl = TextEditingController(text: '0 g');
  final _fatsCtrl = TextEditingController(text: '0 g');
  final _carbsCtrl = TextEditingController(text: '0 g');
  String _selectedCategory = 'Dinner';
  final List<TextEditingController> _ingredientCtrls = [
    TextEditingController()
  ];
  final List<_StepEntry> _steps = [_StepEntry()];

  static const _categories = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Snack',
    'Drinks',
    'Soup',
  ];

  @override
  void dispose() {
    for (final c in [
      _titleCtrl,
      _descCtrl,
      _prepTimeCtrl,
      _servingsCtrl,
      _caloriesCtrl,
      _proteinsCtrl,
      _fatsCtrl,
      _carbsCtrl,
    ]) {
      c.dispose();
    }
    for (final c in _ingredientCtrls) c.dispose();
    for (final s in _steps) s.dispose();
    super.dispose();
  }

  void _addIngredient() =>
      setState(() => _ingredientCtrls.add(TextEditingController()));

  void _removeIngredient(int i) {
    if (_ingredientCtrls.length > 1) {
      setState(() {
        _ingredientCtrls[i].dispose();
        _ingredientCtrls.removeAt(i);
      });
    }
  }

  void _addStep() => setState(() => _steps.add(_StepEntry()));

  void _removeStep(int i) {
    if (_steps.length > 1) {
      setState(() {
        _steps[i].dispose();
        _steps.removeAt(i);
      });
    }
  }

  void _onSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final recipe = FoodItemData(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      rating: 0.0,
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=60',
      category: _selectedCategory,
      prepTime: _prepTimeCtrl.text.trim().isEmpty
          ? '30 Min'
          : _prepTimeCtrl.text.trim(),
      servings: _servingsCtrl.text.trim().isEmpty
          ? '2'
          : _servingsCtrl.text.trim(),
      calories: _caloriesCtrl.text.trim().isEmpty
          ? '0 kcal'
          : _caloriesCtrl.text.trim(),
      proteins: _proteinsCtrl.text.trim().isEmpty
          ? '0 g'
          : _proteinsCtrl.text.trim(),
      fats: _fatsCtrl.text.trim().isEmpty ? '0 g' : _fatsCtrl.text.trim(),
      carbs:
          _carbsCtrl.text.trim().isEmpty ? '0 g' : _carbsCtrl.text.trim(),
      ingredients: _ingredientCtrls
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      steps: _steps
          .where((s) => s.titleCtrl.text.trim().isNotEmpty)
          .map((s) => RecipeStep(
                title: s.titleCtrl.text.trim(),
                description: s.descCtrl.text.trim(),
                duration: s.durationCtrl.text.trim().isEmpty
                    ? '5 min'
                    : s.durationCtrl.text.trim(),
              ))
          .toList(),
    );
    context.read<SubmitCubit>().submitRecipe(recipe);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SubmitCubit>(
      create: (_) => SubmitCubit(),
      child: BlocConsumer<SubmitCubit, SubmitState>(
        listener: (context, state) {
          if (state is SubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Recipe submitted!',
                    style: GoogleFonts.poppins(fontSize: 13)),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
            Navigator.pop(context);
          } else if (state is SubmitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message,
                    style: GoogleFonts.poppins(fontSize: 13)),
                backgroundColor: AppColors.accentRed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is SubmitInProgress;
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Submit a Recipe'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _sectionLabel('Basic Info'),
                  _buildTextField(_titleCtrl, 'Recipe Title', required: true),
                  const SizedBox(height: 12),
                  _buildTextField(_descCtrl, 'Short description',
                      maxLines: 3, required: true),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    onChanged: (v) =>
                        setState(() => _selectedCategory = v!),
                    items: _categories
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c,
                                  style: GoogleFonts.poppins(fontSize: 14)),
                            ))
                        .toList(),
                    decoration: _inputDecoration('Category'),
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: _buildTextField(_prepTimeCtrl, 'Prep Time',
                            hint: 'e.g. 30 Min')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildTextField(_servingsCtrl, 'Servings',
                            hint: 'e.g. 2')),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: _buildTextField(_caloriesCtrl, 'Calories',
                            hint: 'e.g. 250 kcal')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildTextField(_proteinsCtrl, 'Proteins',
                            hint: 'e.g. 20 g')),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: _buildTextField(_fatsCtrl, 'Fats',
                            hint: 'e.g. 10 g')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildTextField(_carbsCtrl, 'Carbs',
                            hint: 'e.g. 30 g')),
                  ]),
                  const SizedBox(height: 24),

                  // ── Ingredients ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionLabel('Ingredients'),
                      TextButton.icon(
                        onPressed: _addIngredient,
                        icon: const Icon(Icons.add,
                            size: 18, color: AppColors.primary),
                        label: Text('Add',
                            style: GoogleFonts.poppins(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  ...List.generate(
                    _ingredientCtrls.length,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                                _ingredientCtrls[i], 'Ingredient ${i + 1}'),
                          ),
                          IconButton(
                            onPressed: () => _removeIngredient(i),
                            icon: const Icon(Icons.remove_circle_outline,
                                color: AppColors.accentSalmon, size: 22),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Steps ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionLabel('Cooking Steps'),
                      TextButton.icon(
                        onPressed: _addStep,
                        icon: const Icon(Icons.add,
                            size: 18, color: AppColors.primary),
                        label: Text('Add',
                            style: GoogleFonts.poppins(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  ...List.generate(
                      _steps.length, (i) => _buildStepCard(i)),
                  const SizedBox(height: 24),

                  // ── Submit button ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          isSubmitting ? null : () => _onSubmit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text('Submit Recipe',
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textLight,
            letterSpacing: 0.8,
          ),
        ),
      );

  Widget _buildTextField(
    TextEditingController ctrl,
    String label, {
    String? hint,
    int maxLines = 1,
    bool required = false,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style:
          GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
      validator: required
          ? (v) =>
              (v == null || v.trim().isEmpty) ? '$label is required' : null
          : null,
      decoration: _inputDecoration(label, hint: hint),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle:
          GoogleFonts.poppins(fontSize: 13, color: AppColors.textMid),
      hintStyle:
          GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.chipBg)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.chipBg)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentRed)),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildStepCard(int i) {
    final step = _steps[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.chipBg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _removeStep(i),
                icon: const Icon(Icons.remove_circle_outline,
                    color: AppColors.accentSalmon, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField(step.titleCtrl, 'Step title'),
          const SizedBox(height: 8),
          _buildTextField(step.descCtrl, 'Description', maxLines: 2),
          const SizedBox(height: 8),
          _buildTextField(step.durationCtrl, 'Duration',
              hint: 'e.g. 5 min'),
        ],
      ),
    );
  }
}

class _StepEntry {
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController durationCtrl = TextEditingController();

  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    durationCtrl.dispose();
  }
}
