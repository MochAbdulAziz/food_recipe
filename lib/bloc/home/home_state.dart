import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // For IconData

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<CategoryData> categories;
  final List<FoodItemData> foodItems;

  const HomeLoaded({required this.categories, required this.foodItems});

  @override
  List<Object> get props => [categories, foodItems];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}

// Data models for the state
class CategoryData extends Equatable {
  final String title;
  final IconData icon;

  const CategoryData({required this.title, required this.icon});

  @override
  List<Object> get props => [title, icon];
}

class FoodItemData extends Equatable {
  final String title;
  final String description;
  final double rating;
  final String imageUrl;

  const FoodItemData({
    required this.title,
    required this.description,
    required this.rating,
    required this.imageUrl,
  });

  @override
  List<Object> get props => [title, description, rating, imageUrl];
}
