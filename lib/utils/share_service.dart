import 'package:share_plus/share_plus.dart';
import '../models/recipe.dart';

class ShareService {
  static Future<void> shareRecipe(FoodItemData recipe) async {
    final text = '🍽️ ${recipe.title}\n\n'
        '${recipe.description}\n\n'
        '⏱ Prep time: ${recipe.prepTime}\n'
        '⭐ Rating: ${recipe.rating}/5\n'
        '🥗 Servings: ${recipe.servings}\n'
        '🔥 Calories: ${recipe.calories}\n\n'
        'Shared from Food App';
    await Share.share(text, subject: recipe.title);
  }
}
