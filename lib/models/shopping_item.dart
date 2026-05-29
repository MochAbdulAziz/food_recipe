import 'package:equatable/equatable.dart';

class ShoppingItem extends Equatable {
  final String id;
  final String ingredient;
  final String recipeTitle;
  final bool isChecked;

  const ShoppingItem({
    required this.id,
    required this.ingredient,
    required this.recipeTitle,
    this.isChecked = false,
  });

  ShoppingItem copyWith({bool? isChecked}) => ShoppingItem(
        id: id,
        ingredient: ingredient,
        recipeTitle: recipeTitle,
        isChecked: isChecked ?? this.isChecked,
      );

  @override
  List<Object> get props => [id, ingredient, recipeTitle, isChecked];
}
