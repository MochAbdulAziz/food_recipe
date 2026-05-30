import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CategoryData extends Equatable {
  final String title;
  final IconData icon;

  const CategoryData({required this.title, required this.icon});

  static const _iconMap = <String, IconData>{
    'Soup': Icons.restaurant_menu,
    'Breakfast': Icons.bakery_dining,
    'Drinks': Icons.local_cafe_rounded,
    'Dinner': Icons.dinner_dining,
    'More': Icons.grid_view,
    'Chicken': Icons.restaurant,
    'Beef': Icons.outdoor_grill,
    'Seafood': Icons.set_meal,
    'Pasta': Icons.restaurant,
    'Dessert': Icons.cake,
  };

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String;
    return CategoryData(
      title: title,
      icon: _iconMap[title] ?? Icons.restaurant,
    );
  }

  Map<String, dynamic> toJson() => {'title': title};

  @override
  List<Object> get props => [title, icon];
}
