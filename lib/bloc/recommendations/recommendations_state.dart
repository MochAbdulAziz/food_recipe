import 'package:equatable/equatable.dart';
import '../../models/recipe.dart';

abstract class RecommendationsState extends Equatable {
  const RecommendationsState();

  @override
  List<Object> get props => [];
}

class RecommendationsEmpty extends RecommendationsState {}

class RecommendationsLoaded extends RecommendationsState {
  final List<FoodItemData> items;

  const RecommendationsLoaded(this.items);

  @override
  List<Object> get props => [items];
}
