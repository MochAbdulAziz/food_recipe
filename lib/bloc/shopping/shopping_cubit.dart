import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/recipe.dart';
import '../../models/shopping_item.dart';
import 'shopping_state.dart';

class ShoppingCubit extends Cubit<ShoppingState> {
  ShoppingCubit() : super(const ShoppingState());

  /// Adds all ingredients from [recipe] if not already in the list.
  void addFromRecipe(FoodItemData recipe) {
    final existingIds = state.items.map((i) => i.id).toSet();
    final toAdd = recipe.ingredients
        .asMap()
        .entries
        .map((e) => ShoppingItem(
              id: '${recipe.title}__${e.key}',
              ingredient: e.value,
              recipeTitle: recipe.title,
            ))
        .where((i) => !existingIds.contains(i.id))
        .toList();

    if (toAdd.isEmpty) return;
    emit(state.copyWith(items: [...state.items, ...toAdd]));
  }

  void toggleItem(String id) {
    emit(state.copyWith(
      items: state.items
          .map((i) => i.id == id ? i.copyWith(isChecked: !i.isChecked) : i)
          .toList(),
    ));
  }

  void removeChecked() {
    emit(state.copyWith(
      items: state.items.where((i) => !i.isChecked).toList(),
    ));
  }

  void clearAll() => emit(const ShoppingState());
}
