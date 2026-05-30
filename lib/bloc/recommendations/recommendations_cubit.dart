import 'package:bloc/bloc.dart';
import '../../models/recipe.dart';
import 'recommendations_state.dart';

/// Computes "You might like" recommendations using simple tag-based matching.
/// Call [compute] whenever favorites or the recipe list change.
class RecommendationsCubit extends Cubit<RecommendationsState> {
  static const int maxRecommendations = 5;

  RecommendationsCubit() : super(RecommendationsEmpty());

  void compute({
    required List<FoodItemData> allItems,
    required Set<String> favourites,
  }) {
    if (allItems.isEmpty) {
      emit(RecommendationsEmpty());
      return;
    }

    List<FoodItemData> candidates;

    if (favourites.isEmpty) {
      // No favourites history — show top-rated recipes
      candidates = List.of(allItems)
        ..sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      // Count how often each category appears in the user's favourites
      final categoryCount = <String, int>{};
      for (final item in allItems.where((r) => favourites.contains(r.title))) {
        categoryCount[item.category] =
            (categoryCount[item.category] ?? 0) + 1;
      }

      // Sort non-favourited items: most-matching category first, then by rating
      candidates = allItems
          .where((r) => !favourites.contains(r.title))
          .toList()
        ..sort((a, b) {
          final catDiff = (categoryCount[b.category] ?? 0)
              .compareTo(categoryCount[a.category] ?? 0);
          return catDiff != 0 ? catDiff : b.rating.compareTo(a.rating);
        });
    }

    final picks = candidates.take(maxRecommendations).toList();
    if (picks.isEmpty) {
      emit(RecommendationsEmpty());
    } else {
      emit(RecommendationsLoaded(picks));
    }
  }
}
