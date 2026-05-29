import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/recipe.dart';
import 'meal_plan_state.dart';

class MealPlanCubit extends Cubit<MealPlanState> {
  MealPlanCubit() : super(const MealPlanState());

  static String dayKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  List<FoodItemData> recipesForDay(DateTime day) =>
      state.plan[dayKey(day)] ?? const [];

  void assignRecipe(DateTime day, FoodItemData recipe) {
    final key = dayKey(day);
    final updated = Map<String, List<FoodItemData>>.from(state.plan);
    final dayList = List<FoodItemData>.from(updated[key] ?? []);
    if (!dayList.any((r) => r.title == recipe.title)) {
      dayList.add(recipe);
    }
    updated[key] = dayList;
    emit(state.copyWith(plan: updated));
  }

  void removeRecipe(DateTime day, String recipeTitle) {
    final key = dayKey(day);
    final updated = Map<String, List<FoodItemData>>.from(state.plan);
    final dayList = List<FoodItemData>.from(updated[key] ?? [])
      ..removeWhere((r) => r.title == recipeTitle);
    if (dayList.isEmpty) {
      updated.remove(key);
    } else {
      updated[key] = dayList;
    }
    emit(state.copyWith(plan: updated));
  }
}
