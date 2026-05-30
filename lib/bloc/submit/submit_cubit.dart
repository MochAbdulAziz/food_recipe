import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/recipe.dart';

part 'submit_state.dart';

/// Manages user-submitted recipes, persisting them via SharedPreferences.
class SubmitCubit extends Cubit<SubmitState> {
  static const _prefsKey = 'user_submitted_recipes_v1';

  SubmitCubit() : super(const SubmitInitial());

  Future<void> submitRecipe(FoodItemData recipe) async {
    emit(const SubmitInProgress());
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      final list = raw != null
          ? (jsonDecode(raw) as List<dynamic>)
          : <dynamic>[];
      // Replace existing entry with the same title (re-submit)
      list.removeWhere(
          (e) => (e as Map<String, dynamic>)['title'] == recipe.title);
      list.insert(0, recipe.toJson());
      await prefs.setString(_prefsKey, jsonEncode(list));
      emit(SubmitSuccess(recipe));
    } catch (_) {
      emit(const SubmitError('Failed to submit recipe. Please try again.'));
    }
  }

  static Future<List<FoodItemData>> loadSubmitted() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => FoodItemData.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
