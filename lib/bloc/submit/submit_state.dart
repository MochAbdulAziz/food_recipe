part of 'submit_cubit.dart';

abstract class SubmitState extends Equatable {
  const SubmitState();

  @override
  List<Object> get props => [];
}

class SubmitInitial extends SubmitState {
  const SubmitInitial();
}

class SubmitInProgress extends SubmitState {
  const SubmitInProgress();
}

class SubmitSuccess extends SubmitState {
  final FoodItemData recipe;
  const SubmitSuccess(this.recipe);

  @override
  List<Object> get props => [recipe];
}

class SubmitError extends SubmitState {
  final String message;
  const SubmitError(this.message);

  @override
  List<Object> get props => [message];
}
