import 'package:bloc/bloc.dart';
import '../../data/recipe_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final RecipeRepository repository;

  HomeCubit(this.repository) : super(HomeLoading());

  void loadData() async {
    try {
      emit(HomeLoading());
      final categories = await repository.getCategories();
      final foodItems = await repository.getRecipes();
      emit(HomeLoaded(categories: categories, foodItems: foodItems));
    } catch (e) {
      emit(const HomeError('Failed to load data'));
    }
  }
}