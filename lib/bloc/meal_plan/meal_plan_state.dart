import 'package:equatable/equatable.dart';
import '../../models/recipe.dart';

class MealPlanState extends Equatable {
  /// Key: 'yyyy-MM-dd', Value: list of recipes assigned to that day.
  final Map<String, List<FoodItemData>> plan;

  const MealPlanState({this.plan = const {}});

  MealPlanState copyWith({Map<String, List<FoodItemData>>? plan}) =>
      MealPlanState(plan: plan ?? this.plan);

  @override
  List<Object> get props => [plan];
}
