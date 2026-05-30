import 'package:bloc/bloc.dart';
import '../../data/offline_cache.dart';
import '../../data/recipe_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final RecipeRepository repository;

  HomeCubit(this.repository) : super(HomeLoading());

  Future<void> loadData() async {
    try {
      emit(HomeLoading());
      final categories = await repository.getCategories();
      final foodItems = await repository.getRecipes(page: 0);
      // Warm offline cache with first-page results
      for (final item in foodItems) {
        OfflineCache.addViewed(item);
      }
      emit(HomeLoaded(
        categories: categories,
        foodItems: foodItems,
        hasMore: repository.hasMoreData(1),
        currentPage: 0,
      ));
    } catch (e) {
      // Fall back to offline cache
      final cached = OfflineCache.getOfflineRecipes();
      if (cached.isNotEmpty) {
        emit(HomeLoaded(
          categories: const [],
          foodItems: cached,
          hasMore: false,
          currentPage: 0,
        ));
      } else {
        emit(const HomeError('Failed to load data'));
      }
    }
  }

  Future<void> loadMore() async {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;
    if (!current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = current.currentPage + 1;
      final more = await repository.getRecipes(page: nextPage);
      for (final item in more) {
        OfflineCache.addViewed(item);
      }
      emit(current.copyWith(
        foodItems: [...current.foodItems, ...more],
        hasMore: repository.hasMoreData(nextPage + 1),
        isLoadingMore: false,
        currentPage: nextPage,
      ));
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}