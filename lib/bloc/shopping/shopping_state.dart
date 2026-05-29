import 'package:equatable/equatable.dart';
import '../../models/shopping_item.dart';

class ShoppingState extends Equatable {
  final List<ShoppingItem> items;

  const ShoppingState({this.items = const []});

  ShoppingState copyWith({List<ShoppingItem>? items}) =>
      ShoppingState(items: items ?? this.items);

  @override
  List<Object> get props => [items];
}
