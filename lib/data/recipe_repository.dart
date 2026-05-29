import '../models/category.dart';
import '../models/recipe.dart';

abstract class RecipeRepository {
  Future<List<CategoryData>> getCategories();
  Future<List<FoodItemData>> getRecipes();
}
