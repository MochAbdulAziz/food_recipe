import '../models/category.dart';
import '../models/recipe.dart';

abstract class RecipeRepository {
  Future<List<CategoryData>> getCategories();

  /// Returns a page of recipes. [page] is 0-based.
  Future<List<FoodItemData>> getRecipes({int page = 0});

  /// Whether there is another page after [nextPage].
  bool hasMoreData(int nextPage);
}
