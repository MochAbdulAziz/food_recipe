import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CategoryData extends Equatable {
  final String title;
  final IconData icon;

  const CategoryData({required this.title, required this.icon});

  factory CategoryData.fromJson(Map<String, dynamic> json) => CategoryData(
        title: json['title'] as String,
        icon: IconData(
          json['iconCodePoint'] as int,
          fontFamily: json['iconFontFamily'] as String? ?? 'MaterialIcons',
        ),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'iconCodePoint': icon.codePoint,
        'iconFontFamily': icon.fontFamily,
      };

  @override
  List<Object> get props => [title, icon];
}
